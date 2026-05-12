---
name: llm-wiki-source-extractor
description: >
  Converts non-markdown source files into LLM-ready markdown or text artifacts
  for the LLM Wiki ingest pipeline. Prefer Microsoft MarkItDown when installed;
  otherwise use local fallback tools by file type. Use when: a raw source is PDF,
  DOCX, PPTX, XLSX, HTML, CSV, JSON, XML, image, audio, ZIP, EPUB, or another
  format that cannot be directly ingested as markdown/text.
license: MIT
compatibility: opencode
metadata:
  owner: llm-wiki
  type: read-write
  approval: "No for local read/extract; Yes before installing tools, OCR, cloud services, or overwriting extraction artifacts"
---

# llm-wiki-source-extractor

**Owner**: `llm-wiki`
**Type**: `read-write`
**Approval**: `No for local read/extract; Yes before installing tools, OCR, cloud services, or overwriting extraction artifacts`

---

## What I Do

Converts raw non-markdown documents into markdown or plain text processing
artifacts that `llm-wiki-ingest` can read. Raw sources remain immutable; extracted
artifacts are stored under the `llm-wiki` workspace output area.

---

## Conversion Priority

Use this order:

1. **Microsoft MarkItDown**, if installed and suitable for the file type.
2. **Local fallback tools**, selected by extension and availability.
3. **OCR or cloud-enhanced extraction**, only after explicit user approval.
4. **Stop with a clear requirement**, if no safe extractor is available.

MarkItDown is preferred because it supports many LLM-friendly conversions:
PDF, DOCX, PPTX, XLSX/XLS, images with OCR metadata, audio transcription,
HTML/web content, CSV, JSON, XML, notebooks, ZIP, EPUB, Outlook MSG, and more.

---

## When to Use Me

- `llm-wiki-ingest` receives a PDF or binary document
- User asks to convert a document to markdown before ingest
- Source format is Office, HTML, structured data, image, archive, EPUB, audio, or notebook
- Ingest failed because the source was not readable as markdown or text

---

## Context Requirements

```
Requires already loaded:
  .crux/workspace/llm-wiki/MEMORY.md

Loads during execution (lazy):
  source file metadata
  source file content through the selected conversion tool

Does not load:
  broad wiki pages
  raw files unrelated to the requested source

Estimated token cost: ~500 tokens + extracted artifact summary
Unloaded after: extraction artifact and report are produced
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| `source-path` | user / llm-wiki-ingest | Yes |
| `raw-root` | MEMORY.md / user | No — default: `raw/` |
| `output-format` | user | No — default: markdown |
| `overwrite-policy` | user | No — default: preserve existing artifacts |
| `ocr-policy` | user / MEMORY.md | No — default: ask-before-ocr |

---

## Output Location

Write extraction artifacts to:

```text
.crux/workspace/llm-wiki/output/extracted/{source-slug}.md
.crux/workspace/llm-wiki/output/extracted/{source-slug}.metadata.md
```

Do not write converted files into `raw/`.

---

## Tool Detection

```
1. Check MarkItDown first:
   markitdown --version

2. If available:
   use markitdown "{source-path}" -o "{output-path}"

3. If MarkItDown is missing:
   choose a fallback based on file extension and available local tools.

4. If no local fallback exists:
   explain the missing tool and ask whether to install MarkItDown or use another approved extractor.
```

If installation is needed, request approval first. Recommended install command:

```bash
pip install 'markitdown[all]'
```

or, if the workspace uses `uv`:

```bash
uv pip install 'markitdown[all]'
```

---

## Fallback Matrix

| Format | Preferred | Local fallback options | Notes |
|---|---|---|---|
| `.pdf` | `markitdown` | `pdftotext`, `mutool draw -F text`, Python `pypdf`, Python `pdfplumber` | If extracted text is near-empty, treat as scanned PDF and ask before OCR |
| `.docx` | `markitdown` | `pandoc`, Python `python-docx`, macOS `textutil` | Preserve headings and tables when possible |
| `.pptx` | `markitdown` | `pandoc`, Python `python-pptx` | Speaker notes and slide order should be preserved when possible |
| `.xlsx`, `.xls` | `markitdown` | Python `openpyxl`, `xlsx2csv`, LibreOffice headless export | Prefer markdown tables or sheet sections |
| `.html`, `.htm` | `markitdown` | `pandoc`, Python BeautifulSoup/html2text | Keep links where useful |
| `.csv`, `.tsv` | `markitdown` | direct markdown table or fenced text | Large files may need summary instead of full table |
| `.json` | `markitdown` | Python JSON pretty-print to fenced block or table summary | Do not invent schema |
| `.xml` | `markitdown` | Python XML parse or fenced text | Preserve hierarchy |
| `.ipynb` | `markitdown` | `jupyter nbconvert --to markdown` | Include markdown and code cells; outputs only when useful |
| `.jpg`, `.jpeg`, `.png`, `.webp`, `.gif` | `markitdown` | EXIF extraction; OCR via `tesseract` only with approval | If image meaning matters, ask before LLM vision/cloud use |
| `.zip` | `markitdown` | list contents; extract only with approval | Avoid unpacking untrusted archives silently |
| `.epub` | `markitdown` | `pandoc`, `ebook-convert` | Preserve chapter boundaries |
| `.txt`, `.md` | direct read | copy to artifact with metadata if needed | No conversion needed |

---

## Steps

```
1. Validate source path
   Confirm file exists.
   Confirm source is under raw-root unless user explicitly approves an external source.
   Never modify the source file.

2. Determine file type
   Use extension and, if available, file metadata.

3. Prepare output paths
   Create .crux/workspace/llm-wiki/output/extracted/ if missing.
   If artifact exists, preserve by default and ask before overwrite.

4. Try MarkItDown first
   IF markitdown is installed:
     run markitdown source-path -o output.md
     validate output is non-empty and readable
     set method = markitdown
   ELSE:
     continue to fallback matrix

5. Run local fallback if needed
   Select the least invasive local extractor for the file type.
   Write markdown or text with source metadata header.

6. Detect low-quality extraction
   Flag:
     - empty or near-empty output
     - obvious OCR need
     - lost tables
     - missing slide/page boundaries
     - binary/object dumps

7. Ask before OCR, cloud, or install
   Do not use external services by default.
   Do not install dependencies without approval.

8. Write metadata report
   Include source path, output path, method, file type, extraction date,
   quality notes, and whether OCR/cloud/LLM vision was used.

9. Return extraction result to caller
   Provide output artifact path and quality warnings.
```

---

## Artifact Format

**Writes to**: `.crux/workspace/llm-wiki/output/extracted/{source-slug}.md`
**Format**: `markdown`

```markdown
---
title: "{Source Filename}"
type: extracted-source
created: YYYY-MM-DD
source_path: "{source-path}"
extraction_method: "markitdown | pdftotext | pypdf | textutil | pandoc | direct | other"
ocr_used: false
quality: good | partial | poor
---

# Extracted Source: {Source Filename}

> Source of truth: `{source-path}`
> Extraction artifact for LLM Wiki ingest. Do not edit raw source based on this file.

{converted markdown or text}
```

Metadata report:

```markdown
# Extraction Metadata

Source: `{source-path}`
Output: `{output-path}`
Method: `{method}`
Created: YYYY-MM-DD
OCR used: yes/no
Cloud service used: yes/no
Quality: good/partial/poor

## Warnings

- ...

## Next Step

Use `{output-path}` as the readable input for `llm-wiki-ingest`, while citing
the original raw source as provenance.
```

---

## Approval Gate

Ask for explicit approval before:

- Installing MarkItDown or any fallback dependency
- Running OCR tools on scanned documents
- Using Azure Document Intelligence, LLM image descriptions, transcription APIs, or any cloud service
- Extracting ZIP archives rather than listing contents
- Overwriting an existing extraction artifact
- Writing extracted content outside `.crux/workspace/llm-wiki/output/extracted/`

```
1. State the conversion method and exact command or tool
2. State whether data leaves the machine
3. Show input and output paths
4. Explain overwrite or OCR implications
5. Wait for explicit approval
```

---

## Error Handling

| Condition | Action |
|---|---|
| MarkItDown not installed | Try local fallback; if none exists, ask whether to install MarkItDown |
| PDF extraction returns near-empty text | Mark quality poor and ask before OCR |
| Unsupported file type | Ask whether to treat as plain text, install MarkItDown, or skip |
| Output artifact already exists | Preserve and ask before overwrite |
| Conversion creates unreadable output | Try next fallback and report quality warning |
| External service would be needed | Stop and ask for approval |
| Unexpected failure | Stop. Write error to bus. Notify user. |
