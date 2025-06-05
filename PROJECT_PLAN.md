# Project Plan: doc_chat_ai

## Overview
`doc_chat_ai` is a CLI tool for local document Q&A using vector search and LLMs (Ollama or OpenAI). It enables users to ingest directories of files, build a vector database, and interactively chat with their documents, optionally running code or shell commands via function-calling.

## Goals
- Fast, local, and private document Q&A
- Support for both open-source (Ollama) and cloud (OpenAI) LLMs
- Easy ingestion and chunking of common file types
- Interactive chat with context retrieval
- Extensible for new file types and LLM providers

## Features
- Ingest: Parse and chunk files, store in SQLite DB, embed with LLM
- Chat: Retrieve relevant chunks, chat with LLM, function-calling (Python/Bash)
- Stats: Show document and embedding counts
- List-files: List all ingested files
- Clear-db: Reset the database

## Architecture
- Python CLI (Typer)
- SQLite for document and embedding storage
- Embedding and chat via Ollama or OpenAI
- Tokenization with tiktoken
- Parallel embedding with ThreadPoolExecutor
- Markdown rendering for CLI output

## Future Tasks
- [ ] Add support for more file types (PDF, DOCX)
- [ ] Improve chunking/tokenization heuristics
- [ ] Add web UI
- [ ] Add authentication for cloud APIs
- [ ] Add tests and CI
- [ ] Add Dockerfile for easy deployment

## Change Log
- Initial version: CLI for ingest, chat, stats, list-files, clear-db (Ollama/OpenAI)