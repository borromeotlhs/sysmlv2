#!/usr/bin/env bash
#
# Example: Using Remote SysML Validation
#
# This script demonstrates how to use the remote validation feature.
# It starts a mock validator and the SPA server, then tests validation.

set -e

echo "========================================="
echo "Remote SysML Validation - Example"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Start mock validator
echo -e "${BLUE}Step 1: Starting mock validator on port 9000...${NC}"
python3 mock_remote_validator.py --port 9000 &
VALIDATOR_PID=$!

# Cleanup function
cleanup() {
    echo ""
    echo "Cleaning up..."
    kill $VALIDATOR_PID 2>/dev/null || true
    kill $SERVER_PID 2>/dev/null || true
}
trap cleanup EXIT

# Wait for validator to start
sleep 2

# Step 2: Configure environment
echo -e "${BLUE}Step 2: Configuring environment variables...${NC}"
export SYSML_VALIDATION_MODE=remote
export SYSML_REMOTE_VALIDATOR_URL=http://127.0.0.1:9000/api/validate
export APP_PORT=8765

echo "  SYSML_VALIDATION_MODE=$SYSML_VALIDATION_MODE"
echo "  SYSML_REMOTE_VALIDATOR_URL=$SYSML_REMOTE_VALIDATOR_URL"
echo ""

# Step 3: Start SPA server
echo -e "${BLUE}Step 3: Starting SPA server on port 8765...${NC}"
python3 -m spa.server --port 8765 > /tmp/spa_server.log 2>&1 &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Step 4: Test validation
echo -e "${BLUE}Step 4: Testing validation endpoint...${NC}"
echo ""

# Valid SysML
echo -e "${GREEN}Test 1: Valid SysML${NC}"
python3 - <<'PYTHON'
import json
import urllib.request

content = """
package TestSystem {
    part def Sensor;
    part def Processor;

    part system : System {
        part sensor : Sensor;
        part processor : Processor;
    }
}
"""

payload = json.dumps({'content': content}).encode('utf-8')
req = urllib.request.Request(
    'http://127.0.0.1:8765/api/validate-sysml',
    data=payload,
    headers={'Content-Type': 'application/json'}
)

with urllib.request.urlopen(req, timeout=5) as response:
    result = json.loads(response.read().decode('utf-8'))
    print(f"  Valid: {result['valid']}")
    print(f"  Source: {result.get('validation_source', 'unknown')}")
    print(f"  Errors: {len(result.get('errors', []))}")
PYTHON

echo ""

# Invalid SysML
echo -e "${GREEN}Test 2: Invalid SysML (missing semicolon)${NC}"
python3 - <<'PYTHON'
import json
import urllib.request

content = """
package TestSystem {
    part def Sensor
    part def Processor;
}
"""

payload = json.dumps({'content': content}).encode('utf-8')
req = urllib.request.Request(
    'http://127.0.0.1:8765/api/validate-sysml',
    data=payload,
    headers={'Content-Type': 'application/json'}
)

with urllib.request.urlopen(req, timeout=5) as response:
    result = json.loads(response.read().decode('utf-8'))
    print(f"  Valid: {result['valid']}")
    print(f"  Source: {result.get('validation_source', 'unknown')}")
    print(f"  Errors: {len(result.get('errors', []))}")
    if result.get('errors'):
        print(f"  First error: {result['errors'][0]['message']}")
PYTHON

echo ""
echo "========================================="
echo -e "${GREEN}✓ Example completed successfully!${NC}"
echo "========================================="
echo ""
echo "The SPA server is running at: http://127.0.0.1:8765"
echo "Open it in your browser to test the editor with live validation."
echo ""
echo "Press Ctrl+C to stop the servers."

# Keep running until user interrupts
wait $SERVER_PID
