# API Endpoints Documentation

## Overview

This document describes the backend API endpoints for saving architectures and validating SysML syntax.

## Base URL

Development: `http://127.0.0.1:8765`

---

## POST /api/save-architecture

Save a new or edited SysML architecture file.

### Request

**Headers:**
- `Content-Type: application/json`

**Body:**
```json
{
  "path": "data/architectures/my_arch.sysml",
  "content": "package MyArch { ... }"
}
```

**Fields:**
- `path` (string, required): File path where the architecture should be saved
  - Can be relative (to `data/architectures/`) or absolute (under project root)
  - Must have `.sysml` extension
  - Maximum size: 5 MB
- `content` (string, required): SysML v2 textual content

### Response

**Success (201 Created):**
```json
{
  "ok": true,
  "path": "data/architectures/my_arch.sysml",
  "size": 1234
}
```

**Error (400 Bad Request):**
```json
{
  "error": "Invalid path: Path contains directory traversal (..) - not allowed"
}
```

### Security

The endpoint implements multiple security checks:

1. **Path Validation:**
   - Blocks directory traversal (`../`)
   - Ensures paths are under project root
   - Only allows `.sysml` extension
   - Sanitizes filenames (no special characters like `<>:"|?*`)

2. **Content Validation:**
   - Maximum file size: 5 MB
   - UTF-8 encoding

---

## POST /api/validate-sysml

Validate SysML v2 textual content in real-time.

### Request

**Headers:**
- `Content-Type: application/json`

**Body:**
```json
{
  "content": "package Test { ... }"
}
```

**Fields:**
- `content` (string, required): SysML v2 textual content to validate
  - Maximum size: 5 MB

### Response

**Valid Content (200 OK):**
```json
{
  "valid": true,
  "errors": []
}
```

**Invalid Content (200 OK):**
```json
{
  "valid": false,
  "errors": [
    {
      "line": 5,
      "column": null,
      "message": "Missing semicolon: part testPart : TestType",
      "severity": "error",
      "category": "SyntaxError"
    }
  ]
}
```

### Error Object Structure

Each error object contains:
- `line` (integer or null): Line number where the error occurred
- `column` (integer or null): Column number (currently not tracked)
- `message` (string): Human-readable error message
- `severity` (string): `"error"`, `"warning"`, or `"info"`
- `category` (string): Error category (SyntaxError, SemanticError, etc.)

### Validation Levels

1. **Syntax Validation:** Package structure, brace matching, semicolons
2. **Semantic Validation:** Undefined references, circular dependencies
3. **Style Validation:** Naming conventions, indentation, documentation

---

## Testing

### Manual Testing

```bash
python test_endpoints_manual.py
```

### Integration Testing

```bash
bash test_api_curl.sh
```
