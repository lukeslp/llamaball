# File Loader Examples

```python
from pdfminer.high_level import extract_text
text = extract_text('example.pdf')

from docx import Document
doc = Document('example.docx')
text = "\n".join(p.text for p in doc.paragraphs)
```

This snippet shows how the project extracts text from PDF and DOCX files using
`pdfminer.six` and `python-docx`.
