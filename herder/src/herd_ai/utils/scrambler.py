###############################################################################
# Herd AI - scrambler.py
#
# This module provides utility functions for:
#   - Scrambling (randomly renaming) files in a directory for anonymization.
#   - Generating a set of sample files with various common file extensions.
#
# Both functions support optional logging via a callback function.
#
# No credentials are required for these utilities.
#
###############################################################################

import random
import string
from pathlib import Path
import zipfile
import gzip
from typing import Callable, Optional

###############################################################################
# scramble_directory
#
# Randomly renames all non-hidden, non-special files in the specified directory.
# This is useful for anonymizing file names in datasets or test folders.
#
# Arguments:
#   target_dir (Path): The directory containing files to scramble.
#   log_callback (Optional[Callable[[str], None]]): Optional function to receive
#       log messages (e.g., for CLI or GUI feedback).
#
# Returns:
#   int: The number of files successfully renamed.
#
# Behavior:
#   - Only files (not directories) are renamed.
#   - Hidden files (starting with '.') and special files (starting with '|_')
#     are ignored.
#   - A log of original and new file names is saved as 'scramble_rename_log.txt'
#     in the target directory.
#   - If a log_callback is provided, progress and errors are reported.
###############################################################################
def scramble_directory(
    target_dir: Path,
    log_callback: Optional[Callable[[str], None]] = None
) -> int:
    files = [
        f for f in target_dir.glob('*')
        if not f.name.startswith('.') and not f.name.startswith('|_')
    ]
    if not files:
        if log_callback:
            log_callback("No files found in directory.")
        return 0
    if log_callback:
        log_callback(f"Found {len(files)} files to rename in {target_dir}")
    rename_log = []
    for file_path in files:
        if file_path.is_file():
            random_name = ''.join(random.choices(string.ascii_lowercase + string.digits, k=10))
            new_name = f"{random_name}{file_path.suffix}"
            new_path = file_path.parent / new_name
            while new_path.exists():
                random_name = ''.join(random.choices(string.ascii_lowercase + string.digits, k=10))
                new_name = f"{random_name}{file_path.suffix}"
                new_path = file_path.parent / new_name
            try:
                file_path.rename(new_path)
                rename_log.append((str(file_path), str(new_path)))
                if log_callback:
                    log_callback(f"Renamed: {file_path.name} → {new_name}")
            except Exception as e:
                if log_callback:
                    log_callback(f"Error renaming {file_path.name}: {e}")
    log_path = target_dir / "scramble_rename_log.txt"
    try:
        with open(log_path, 'w', encoding='utf-8') as f:
            f.write("Original Name,New Name\n")
            for original, new in rename_log:
                f.write(f"{original},{new}\n")
        if log_callback:
            log_callback(f"Rename log saved to {log_path}")
    except Exception as e:
        if log_callback:
            log_callback(f"Error saving rename log: {e}")
    if log_callback:
        log_callback(f"Successfully scrambled {len(rename_log)} filenames!")
    return len(rename_log)

###############################################################################
# generate_sample_files
#
# Generates a set of sample files with a variety of common file extensions in
# the specified directory. This is useful for testing file handling, uploads,
# or UI components.
#
# Arguments:
#   target_dir (Path): The directory in which to create sample files.
#   files_per_ext (int): Number of files to generate per extension (default: 3).
#   log_callback (Optional[Callable[[str], None]]): Optional function to receive
#       log messages (e.g., for CLI or GUI feedback).
#
# Returns:
#   int: The total number of files generated.
#
# Behavior:
#   - For each extension, creates the specified number of files with random names.
#   - For certain extensions (images, archives, etc.), writes minimal valid or
#     dummy binary content; for others, writes simple text.
#   - If a log_callback is provided, progress and errors are reported.
###############################################################################
def generate_sample_files(
    target_dir: Path,
    files_per_ext: int = 3,
    log_callback: Optional[Callable[[str], None]] = None
) -> int:
    sample_extensions = [
        ".jpg", ".png", ".gif", ".heic", ".docx", ".pptx", ".zip", ".gz",
        ".txt", ".pdf", ".csv", ".json", ".xml", ".mp3", ".mp4", ".avi",
        ".mkv", ".html", ".css", ".js", ".py", ".rb", ".java", ".c",
        ".cpp", ".sh", ".bat", ".iso"
    ]
    total_files = len(sample_extensions) * files_per_ext
    if log_callback:
        log_callback(f"Generating {total_files} sample files in {target_dir}")
    generated_files = []
    sample_image_bytes = {
        ".jpg": b'\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00\xff\xd9',
        ".png": b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\nIDAT\x08\xd7c\x00\x01\x00\x00\x05\x00\x01\r\n,\x89\x00\x00\x00\x00IEND\xaeB`\x82',
        ".gif": b'GIF89a\x01\x00\x01\x00\x80\xff\x00\xff\xff\xff\x00\x00\x00,\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x02D\x01\x00;',
        ".heic": b'\x00\x00\x00\x18ftypheic\x00\x00\x00\x00heic'
    }
    def create_sample_file(new_path: Path, ext: str) -> None:
        """
        Helper function to create a single sample file with the given extension.

        Args:
            new_path (Path): Full path to the new file.
            ext (str): File extension (including dot).
        """
        try:
            if ext in sample_image_bytes:
                with open(new_path, "wb") as f:
                    f.write(sample_image_bytes[ext])
            elif ext in {".zip", ".docx", ".pptx"}:
                with zipfile.ZipFile(new_path, 'w') as zf:
                    zf.writestr("dummy.txt", f"This is a dummy file inside the {ext} archive.")
            elif ext == ".gz":
                with gzip.open(new_path, 'wb') as f:
                    f.write(f"Dummy content for {ext} file.".encode('utf-8'))
            elif ext == ".pdf":
                pdf_content = b"%PDF-1.4\n%Dummy PDF content\n%%EOF"
                with open(new_path, "wb") as f:
                    f.write(pdf_content)
            elif ext in {".mp3", ".mp4", ".avi", ".mkv", ".iso"}:
                content = f"Dummy binary content for {ext} file.".encode('utf-8')
                with open(new_path, "wb") as f:
                    f.write(content)
            else:
                with open(new_path, "w", encoding="utf-8") as f:
                    f.write(f"Sample content for {ext} file.")
        except Exception as e:
            if log_callback:
                log_callback(f"Error creating {new_path.name}: {e}")
    for ext in sample_extensions:
        for _ in range(files_per_ext):
            random_name = ''.join(random.choices(string.ascii_lowercase + string.digits, k=10))
            new_name = f"{random_name}{ext}"
            new_path = target_dir / new_name
            while new_path.exists():
                random_name = ''.join(random.choices(string.ascii_lowercase + string.digits, k=10))
                new_name = f"{random_name}{ext}"
                new_path = target_dir / new_name
            create_sample_file(new_path, ext)
            generated_files.append(str(new_path))
            if log_callback:
                log_callback(f"Created: {new_name}")
    if log_callback:
        log_callback(f"Successfully generated {len(generated_files)} sample files!")
    return len(generated_files)