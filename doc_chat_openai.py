#!/usr/bin/env python3
"""
Document Chat CLI

Ingests all files in a directory (optionally recursively), chunks each into segments up to MAX_CHUNK_SIZE (2000 characters),
creates a SQLite DB storing contents and embeddings,
and allows interactive chat with the ingested documents.

Requirements:
  - openai (pip install openai)
  - numpy

Usage:
  python doc_chat.py ingest --dir PATH [--db PATH] [--model MODEL_NAME]
  python doc_chat.py chat   [--db PATH] [--model MODEL_NAME] [--topk N]
"""
import os
import sys
import typer
import sqlite3
import numpy as np
from numpy.linalg import norm
import openai
from concurrent.futures import ThreadPoolExecutor, as_completed
from prompt_toolkit import PromptSession
from prompt_toolkit.formatted_text import HTML
from prompt_toolkit.styles import Style
from prompt_toolkit.shortcuts import print_formatted_text
from markdown_it import MarkdownIt
import re
import logging
import json
import csv
import tiktoken
from tqdm import tqdm
import subprocess
import tempfile

app = typer.Typer(help="Document Chat CLI: ingest files, build embeddings, and chat via LLM.")

# Logging setup
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

# Token limit for embedding models (max 8191 tokens)
MAX_TOKENS = 8191

# CLI styling for prompt_toolkit HTML tokens
CLI_STYLE = Style.from_dict({
    "b": "bold ansigreen",
    "ans": "ansicyan",
    "i": "italic",
    "u": "underline ansiyellow"
})

# Markdown renderer for styling
md = MarkdownIt()

# File-type loaders: return string content or raise
FILE_LOADERS = {
    ".txt": lambda p: open(p, "r", encoding="utf-8").read(),
    ".md": lambda p: open(p, "r", encoding="utf-8").read(),
    ".py": lambda p: open(p, "r", encoding="utf-8").read(),
    ".json": lambda p: json.dumps(json.load(open(p, "r", encoding="utf-8")), indent=2),
    ".csv": lambda p: "\n".join([", ".join(row) for row in csv.reader(open(p, "r", encoding="utf-8"))])
}

# Helper to convert markdown to prompt_toolkit HTML
def render_markdown_to_html(md_text: str) -> str:
    """
    Render Markdown text to prompt_toolkit-compatible HTML,
    mapping strong->b, em->i, li->bullet.
    """
    html = md.render(md_text)
    # Convert links to underlined text with URL in parentheses
    html = re.sub(r'<a href="([^"]+)">([^<]+)</a>', r'<u>\2</u> (\1)', html)
    # Map tags to prompt_toolkit HTML
    html = html.replace('<strong>', '<b>').replace('</strong>', '</b>')
    html = html.replace('<em>', '<i>').replace('</em>', '</i>')
    html = html.replace('<ul>', '').replace('</ul>', '')
    html = html.replace('<li>', '• ').replace('</li>', '\n')
    html = html.replace('<p>', '').replace('</p>', '\n\n')
    return html.strip()

# Default parameters
DEFAULT_DB_PATH = ".clai.db"
DEFAULT_MODEL_NAME = "text-embedding-3-small"  # OpenAI embedding model
# Maximum characters per chunk to respect embedding model limits
MAX_CHUNK_SIZE = 32000
# Chunks of up to 2000 characters (~1000 tokens) per embedding request

# Initialize OpenAI client
client = openai.OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

def init_db(db_path: str) -> sqlite3.Connection:
    """
    Initialize SQLite database with tables for documents and embeddings.
    """
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    # Reset tables to ensure correct schema
    c.execute("DROP TABLE IF EXISTS documents")
    c.execute("DROP TABLE IF EXISTS embeddings")
    c.execute("DROP TABLE IF EXISTS files")
    # Documents table: filename, chunk index, and content
    c.execute("""
        CREATE TABLE IF NOT EXISTS documents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            filename TEXT,
            chunk_idx INTEGER,
            content TEXT,
            UNIQUE(filename, chunk_idx)
        )
    """)
    # Embeddings table: doc_id and embedding blob
    c.execute("""
        CREATE TABLE IF NOT EXISTS embeddings (
            doc_id INTEGER PRIMARY KEY,
            embedding BLOB,
            FOREIGN KEY(doc_id) REFERENCES documents(id)
        )
    """)
    # Files table to track processed file mtimes
    c.execute("""
    CREATE TABLE IF NOT EXISTS files (
        filename TEXT PRIMARY KEY,
        mtime REAL
    )
    """)
    conn.commit()
    return conn


def get_embedding(text: str, model: str) -> np.ndarray:
    """Get embedding from OpenAI API"""
    response = client.embeddings.create(
        input=text,
        model=model
    )
    embedding = np.array(response.data[0].embedding, dtype=np.float32)
    return embedding

def _insert_chunk(cursor, filename, idx, text):
    cursor.execute(
        "INSERT OR IGNORE INTO documents (filename, chunk_idx, content) VALUES (?, ?, ?)",
        (filename, idx, text)
    )
    cursor.connection.commit()

# --- Function-calling tool helpers ---
def run_python_code_func(code: str) -> str:
    """Execute Python code in a temp file and return stdout or stderr."""
    try:
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write(code)
            temp_path = f.name
        proc = subprocess.run(
            [sys.executable, temp_path],
            capture_output=True,
            text=True,
            check=False
        )
        os.unlink(temp_path)
        if proc.stderr:
            return f"Error:\n{proc.stderr}"
        return proc.stdout or ""
    except Exception as e:
        return f"Error running Python code: {e}"

def run_bash_command_func(command: str) -> str:
    """Execute a bash command safely and return stdout or stderr."""
    unsafe = ['sudo', 'rm -rf', '>', '>>', '|', '&', ';']
    if any(tok in command for tok in unsafe):
        return "Error: Command contains unsafe operations"
    try:
        proc = subprocess.run(
            ['sh', '-c', command],
            capture_output=True,
            text=True,
            check=False
        )
        if proc.stderr:
            return f"Error:\n{proc.stderr}"
        return proc.stdout or ""
    except Exception as e:
        return f"Error running bash command: {e}"

def ingest_files(directory: str, db_path: str, model_name: str, recursive: bool) -> None:
    """
    Ingest files with plugin loaders, chunk by token boundaries,
    skip unchanged files, and enqueue embedding tasks.
    """
    # Determine walker
    walker = os.walk(directory) if recursive else [(directory, [], os.listdir(directory))]

    # Setup DB
    conn = init_db(db_path)
    c = conn.cursor()

    # Always use cl100k_base tokenizer for embeddings
    encoder = tiktoken.get_encoding("cl100k_base")
    logger.info(f"Using 'cl100k_base' tokenizer for model {model_name}")

    embed_tasks = []
    for root, dirs, files in walker:
        for fname in files:
            path = os.path.join(root, fname)
            rel_path = os.path.relpath(path, directory) if recursive else fname
            ext = os.path.splitext(fname)[1].lower()
            loader = FILE_LOADERS.get(ext)
            if not loader or not os.path.isfile(path):
                logger.debug(f"Skipping unsupported or non-file: {rel_path}")
                continue

            mtime = os.path.getmtime(path)
            c.execute("SELECT mtime FROM files WHERE filename = ?", (rel_path,))
            row = c.fetchone()
            if row and row[0] == mtime:
                logger.info(f"Skipping unchanged file: {rel_path}")
                continue

            try:
                content = loader(path).strip()
            except Exception as e:
                logger.warning(f"Error loading {rel_path}: {e}")
                continue
            if not content:
                continue

            # Split on paragraph boundaries
            paragraphs = re.split(r'\n\s*\n', content)
            token_buffer = []
            for para in paragraphs:
                para_tokens = encoder.encode(para)
                if len(token_buffer) + len(para_tokens) > MAX_TOKENS:
                    # flush buffer
                    text_chunk = encoder.decode(token_buffer)
                    # insert chunk
                    _insert_chunk(c, rel_path, len(embed_tasks), text_chunk)
                    embed_tasks.append((rel_path, text_chunk))
                    token_buffer = para_tokens
                else:
                    token_buffer += para_tokens
            if token_buffer:
                text_chunk = encoder.decode(token_buffer)
                _insert_chunk(c, rel_path, len(embed_tasks), text_chunk)
                embed_tasks.append((rel_path, text_chunk))

            # update file mtime
            c.execute("INSERT OR REPLACE INTO files (filename, mtime) VALUES (?, ?)", (rel_path, mtime))
            conn.commit()

    conn.close()
    logger.info(f"Queued {len(embed_tasks)} chunks for embedding")

    # Parallel embedding with progress bar
    def embed_worker(task):
        rel_path, chunk = task
        # retrieve doc_id
        conn_thread = sqlite3.connect(db_path, check_same_thread=False)
        c_thread = conn_thread.cursor()
        c_thread.execute("SELECT id FROM documents WHERE filename = ? AND content = ?", (rel_path, chunk))
        row = c_thread.fetchone()
        if not row:
            return
        doc_id = row[0]
        try:
            emb = get_embedding(chunk, model_name)
            emb_blob = emb.tobytes()
            c_thread.execute("INSERT OR REPLACE INTO embeddings (doc_id, embedding) VALUES (?, ?)", (doc_id, emb_blob))
            conn_thread.commit()
            logger.info(f"Embedded {rel_path} (doc_id={doc_id})")
        except Exception as e:
            logger.error(f"Error embedding {rel_path}: {e}")
        finally:
            conn_thread.close()

    with ThreadPoolExecutor(max_workers=5) as pool:
        list(tqdm(pool.map(embed_worker, embed_tasks), total=len(embed_tasks), desc="Embedding"))


@app.command()
def ingest(
    dir: str = typer.Option(..., "--dir", help="Directory containing files to ingest"),
    db: str = typer.Option(DEFAULT_DB_PATH, "--db", help="SQLite DB path"),
    model: str = typer.Option(DEFAULT_MODEL_NAME, "--model", help="OpenAI embedding model"),
    recursive: bool = typer.Option(False, "--recursive", help="Recursively ingest files in subdirectories")
):
    """
    Ingest files and build embeddings DB.
    """
    # Prompt if not specified
    if not recursive:
        recursive = typer.confirm("Recursively ingest files in subdirectories?")
    ingest_files(dir, db, model, recursive)


def search_embeddings(query: str,
                      db_path: str,
                      model_name: str,
                      top_k: int) -> list:
    """
    Search the SQLite DB for the top_k documents most similar to the query.
    """
    # Compute query embedding with OpenAI
    query_emb = get_embedding(query, model_name)

    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    c.execute("SELECT doc_id, embedding FROM embeddings")

    scores = []
    for doc_id, emb_blob in c.fetchall():
        emb = np.frombuffer(emb_blob, dtype=np.float32)
        sim = float(np.dot(query_emb, emb) / (norm(query_emb) * norm(emb)))
        scores.append((doc_id, sim))
    conn.close()

    # Sort by similarity descending
    scores.sort(key=lambda x: x[1], reverse=True)
    top = scores[:top_k]

    # Retrieve document info
    results = []
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    for doc_id, score in top:
        c.execute("SELECT filename, content FROM documents WHERE id = ?", (doc_id,))
        fname, content = c.fetchone()
        results.append((fname, content, score))
    conn.close()
    return results

SYSTEM_PROMPT = (
    "You are an assistant that identifies the most feature-complete and robust version of code files "
    "based on the provided context."
)

@app.command()
def chat(
    db: str = typer.Option(DEFAULT_DB_PATH, "--db", help="SQLite DB path"),
    model: str = typer.Option(DEFAULT_MODEL_NAME, "--model", help="OpenAI embedding model"),
    topk: int = typer.Option(3, "--topk", help="Number of top documents to use as context")
):
    """
    Enter interactive chat mode.
    """
    session = PromptSession(style=CLI_STYLE)
    typer.echo("\nDocument Chat. Type 'exit' or 'quit' to end.\n")
    history = []
    while True:
        user_input = session.prompt(HTML("<b>You:</b> "), style=CLI_STYLE)
        if user_input.lower() in ("exit", "quit"):
            typer.echo("Goodbye!")
            raise typer.Exit()
        history.append({"role": "user", "content": user_input})
        # Retrieve top-k matching documents
        docs = search_embeddings(user_input, db, model, topk)
        # Build context
        context = ""
        for fname, content, score in docs:
            context += f"== {fname} (score={score:.4f}) ==\n{content}\n\n"
        # Create prompt
        prompt = (
            context +
            "Question: " + user_input + "\nAnswer:"
        )
        # Prepare messages
        messages = [{"role": "system", "content": SYSTEM_PROMPT}] + history + [{"role": "user", "content": prompt}]
        # Prepare function definitions
        functions = [
            {
                "name": "run_python_code",
                "description": "Execute Python code and return the output.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "code": {"type": "string", "description": "Python code to run"}
                    },
                    "required": ["code"]
                }
            },
            {
                "name": "run_bash_command",
                "description": "Execute a bash command and return the output.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "command": {"type": "string", "description": "Bash command to run"}
                    },
                    "required": ["command"]
                }
            }
        ]
        # Initial call with function support
        try:
            response = client.chat.completions.create(
                model="gpt-4.1-nano",  # adjust if needed
                messages=messages,
                functions=functions,
                function_call="auto",
                temperature=0.2,
                max_tokens=32000,
            )
            msg = response.choices[0].message
            if msg.get("function_call"):
                fname = msg.function_call.name
                args = json.loads(msg.function_call.arguments)
                if fname == "run_python_code":
                    tool_result = run_python_code_func(args["code"])
                else:
                    tool_result = run_bash_command_func(args["command"])
                # Send the function result back to the model
                followup = client.chat.completions.create(
                    model="gpt-4.1-nano",
                    messages=messages + [msg, {"role": "function", "name": fname, "content": tool_result}],
                    temperature=0.2,
                    max_tokens=32000,
                )
                answer = followup.choices[0].message.content
            else:
                answer = msg.content
            # Render assistant response
            html_response = render_markdown_to_html(answer)
            print_formatted_text(HTML(f"<ans>Assistant:</ans>\n{html_response}\n"), style=CLI_STYLE)
        except Exception as e:
            typer.echo(f"[Error] OpenAI API call failed: {e}")

@app.command()
def stats(db: str = typer.Option(DEFAULT_DB_PATH, "--db")):
    """Show document & embedding counts."""
    conn = sqlite3.connect(db); c = conn.cursor()
    docs = c.execute("SELECT COUNT(*) FROM documents").fetchone()[0]
    embs = c.execute("SELECT COUNT(*) FROM embeddings").fetchone()[0]
    typer.echo(f"Documents: {docs}, Embeddings: {embs}")
    conn.close()

@app.command("list-files")
def list_files(db: str = typer.Option(DEFAULT_DB_PATH, "--db")):
    """List all ingested files."""
    conn = sqlite3.connect(db); c = conn.cursor()
    for fname, mtime in c.execute("SELECT filename, mtime FROM files"):
        typer.echo(f"{fname} (mtime={mtime})")
    conn.close()

@app.command("clear-db")
def clear_db(db: str = typer.Option(DEFAULT_DB_PATH, "--db")):
    """Recreate database schema (drops all data)."""
    conn = sqlite3.connect(db); conn.close()
    init_db(db)
    typer.echo("Database schema reset.")

if __name__ == "__main__":
    app()
