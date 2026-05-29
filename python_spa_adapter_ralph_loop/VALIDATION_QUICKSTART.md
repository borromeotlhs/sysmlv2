# SysML Validation - Quick Start Guide

## Overview

The SPA server supports three validation modes:
1. **Local** - Built-in Python validator (default)
2. **Remote** - External validation API
3. **Auto** - Try remote, fall back to local

## Quick Start

### Use Local Validation (Default)

```bash
# No configuration needed - local validation is the default
python spa/server.py
```

### Use Remote Validation

```bash
# Set environment variables
export SYSML_VALIDATION_MODE=remote
export SYSML_REMOTE_VALIDATOR_URL=http://your-validator.com/api/validate

# Start server
python spa/server.py
```

### Use Auto Mode (Resilient)

```bash
# Auto mode tries remote first, falls back to local if remote fails
export SYSML_VALIDATION_MODE=auto
export SYSML_REMOTE_VALIDATOR_URL=http://your-validator.com/api/validate

# Start server
python spa/server.py
```

## Testing with Mock Validator

For development and testing, use the included mock validator:

```bash
# Terminal 1: Start mock validator
python mock_remote_validator.py --port 9000

# Terminal 2: Start SPA with remote validation
export SYSML_VALIDATION_MODE=remote
export SYSML_REMOTE_VALIDATOR_URL=http://localhost:9000/api/validate
python spa/server.py --port 8765

# Terminal 3: Run tests
python test_remote_validation.py
```

Or use the all-in-one example script:

```bash
bash example_remote_validation.sh
```

## Environment Variables

| Variable | Values | Description |
|----------|--------|-------------|
| `SYSML_VALIDATION_MODE` | `auto` (default), `remote`, `local` | Which validation method to use |
| `SYSML_REMOTE_VALIDATOR_URL` | URL string | Remote validator endpoint |

## API Response Format

All validation responses include these fields:

```json
{
  "valid": true,
  "errors": [],
  "validation_source": "remote"
}
```

### Validation Sources

- `remote` - Validated by remote API
- `local` - Validated by local Python validator
- `basic` - Basic parse-only validation (fallback)
- `error` - All validation methods failed

## Remote Validator Requirements

Your remote validator must:

1. Accept POST requests to a validation endpoint
2. Accept JSON payload: `{"content": "..."}`
3. Return JSON response: `{"valid": bool, "errors": [...]}`
4. Respond within 5 seconds (configurable timeout)

### Example Remote Validator API

```python
# Request
POST /api/validate
Content-Type: application/json

{
  "content": "package Test { part def Foo; }"
}

# Response (valid)
{
  "valid": true,
  "errors": []
}

# Response (invalid)
{
  "valid": false,
  "errors": [
    {
      "line": 5,
      "column": 10,
      "message": "Missing semicolon",
      "severity": "error",
      "category": "SyntaxError"
    }
  ]
}
```

## Testing

### Unit Tests
```bash
python test_remote_validation.py
```

### Integration Tests
```bash
python test_validation_endpoint.py
```

### Manual Testing
```bash
# Start servers
bash example_remote_validation.sh

# Open browser
open http://localhost:8765

# Test validation in the editor
```

## Troubleshooting

### "SYSML_REMOTE_VALIDATOR_URL not configured"

Set the environment variable:
```bash
export SYSML_REMOTE_VALIDATOR_URL=http://your-validator.com/api/validate
```

### "Remote validation connection error"

Check:
1. Is the remote validator running?
2. Is the URL correct?
3. Can you reach the validator? Try: `curl http://your-validator.com/health`

### "Remote validation failed, falling back to local"

This is normal in `auto` mode when:
- Remote validator is unavailable
- Remote validator times out (>5 seconds)
- Remote validator returns an error

To require remote validation (no fallback):
```bash
export SYSML_VALIDATION_MODE=remote
```

### Validation always uses "basic" source

This means both remote and local validation failed. Check:
1. Is the local validator installed? (tests/test_sysml_validation.py)
2. Are there import errors in the logs?
3. Try setting `SPA_QUIET=0` to see error messages

## Production Recommendations

For production deployments:

```bash
# Use auto mode for resilience
export SYSML_VALIDATION_MODE=auto

# Set remote validator URL
export SYSML_REMOTE_VALIDATOR_URL=https://validator.prod.example.com/api/validate

# Enable quiet mode for cleaner logs
export SPA_QUIET=1

# Start server
python spa/server.py
```

Monitor the `validation_source` field in API responses to track remote vs. local usage.

## Further Reading

- [REMOTE_VALIDATION.md](REMOTE_VALIDATION.md) - Detailed technical documentation
- [mock_remote_validator.py](mock_remote_validator.py) - Mock validator implementation
- [test_remote_validation.py](test_remote_validation.py) - Test examples
