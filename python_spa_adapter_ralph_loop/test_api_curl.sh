#!/bin/bash
# Test API endpoints using curl

set -e

echo "========================================"
echo "API Endpoints Test Script"
echo "========================================"

# Server URL
SERVER="http://127.0.0.1:8765"

echo ""
echo "1. Testing /api/validate-sysml with valid content..."
VALID_CONTENT='{
  "content": "// Test Architecture\npackage TestArch {\n  part def TestBlock {\n    port testPort;\n  }\n}"
}'

curl -s -X POST "$SERVER/api/validate-sysml" \
  -H "Content-Type: application/json" \
  -d "$VALID_CONTENT" | python -m json.tool

echo ""
echo "2. Testing /api/validate-sysml with invalid content..."
INVALID_CONTENT='{
  "content": "This is not valid SysML!"
}'

curl -s -X POST "$SERVER/api/validate-sysml" \
  -H "Content-Type: application/json" \
  -d "$INVALID_CONTENT" | python -m json.tool

echo ""
echo "3. Testing /api/save-architecture..."
SAVE_REQUEST='{
  "path": "test_api_save.sysml",
  "content": "// Test Architecture from API\n// Domain: test\npackage TestAPIArch {\n  part def TestBlock {\n    port dataIn;\n    port dataOut;\n  }\n}"
}'

curl -s -X POST "$SERVER/api/save-architecture" \
  -H "Content-Type: application/json" \
  -d "$SAVE_REQUEST" | python -m json.tool

echo ""
echo "4. Testing /api/save-architecture with invalid path..."
INVALID_PATH='{
  "path": "../../../etc/passwd.sysml",
  "content": "malicious content"
}'

curl -s -X POST "$SERVER/api/save-architecture" \
  -H "Content-Type: application/json" \
  -d "$INVALID_PATH" || echo "Expected error (status code 400)"

echo ""
echo "========================================"
echo "Tests complete!"
echo "========================================"
