# Remote SysML v2 Validation

This document describes the remote validation feature implemented in the Python SPA Adapter.

## Overview

The SPA server can now validate SysML v2 content using either:
1. **Remote validation** - Call an external validation API
2. **Local validation** - Use the built-in Python validator
3. **Auto mode** - Try remote first, fall back to local if unavailable

## Configuration

### Environment Variables

#### `SYSML_VALIDATION_MODE`
Controls which validation strategy to use:
- `auto` (default) - Try remote first, fall back to local on failure
- `remote` - Only use remote validation (fail if unavailable)
- `local` - Only use local validation (skip remote entirely)

#### `SYSML_REMOTE_VALIDATOR_URL`
URL of the remote validation endpoint (required for remote validation).

Example: `http://localhost:9000/api/validate`

### Examples

```bash
# Use local validation only
export SYSML_VALIDATION_MODE=local
python spa/server.py

# Use remote validation with fallback
export SYSML_VALIDATION_MODE=auto
export SYSML_REMOTE_VALIDATOR_URL=http://validator.example.com/api/validate
python spa/server.py

# Use remote validation only (fail if unavailable)
export SYSML_VALIDATION_MODE=remote
export SYSML_REMOTE_VALIDATOR_URL=http://validator.example.com/api/validate
python spa/server.py
```

## API Specification

### Remote Validator Endpoint

The remote validator must accept POST requests with the following format:

**Request:**
```json
POST /api/validate
Content-Type: application/json

{
  "content": "package Test { ... }"
}
```

**Response (Success):**
```json
{
  "valid": true,
  "errors": []
}
```

**Response (Validation Errors):**
```json
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

**Error Response:**
```json
{
  "error": "Detailed error message"
}
```

### Timeout

Remote validation requests have a 5-second timeout. If the remote validator takes longer than 5 seconds, the request will fail and (in auto mode) fall back to local validation.

## Response Format

All validation responses include a `validation_source` field indicating which validator was used:

```json
{
  "valid": true,
  "errors": [],
  "validation_source": "remote"  // or "local" or "basic"
}
```

### Validation Sources

- `remote` - Validation performed by remote API
- `local` - Validation performed by local SysMLValidator
- `basic` - Basic parse-only validation (fallback)
- `error` - All validation methods failed

## Testing

Run the test script to verify the implementation:

```bash
cd /mnt/c/Users/borrth/offline/_now/LEAD/Claude\ Code/sysmlv2/python_spa_adapter_ralph_loop
python test_remote_validation.py
```

The test script verifies:
1. Local validation works with valid SysML
2. Local validation detects invalid SysML
3. Remote validation fails gracefully when URL not configured
4. Auto mode falls back to local when remote unavailable
5. Response format is correct

## Integration with SPA

The `/api/validate-sysml` endpoint automatically uses the configured validation mode:

```javascript
// From browser/frontend
fetch('/api/validate-sysml', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ content: sysmlCode })
})
.then(res => res.json())
.then(result => {
  console.log('Valid:', result.valid);
  console.log('Source:', result.validation_source);
  console.log('Errors:', result.errors);
});
```

The frontend receives the same response format regardless of which validation method was used.

## Fallback Behavior

In `auto` mode, the validation process follows this sequence:

```
1. Try remote validation
   ↓ (on failure)
2. Try local validation
   ↓ (on failure)
3. Try basic parser validation
   ↓ (on failure)
4. Return error with details from all attempts
```

This ensures validation always returns a result, even if some validators are unavailable.

## Security

- Remote validation requests have a 5-second timeout to prevent hanging
- Content size is limited to 5 MB (same as file upload limit)
- Remote URL must be explicitly configured (no default)
- TLS/HTTPS is supported for secure communication

## Production Deployment

For production use:

1. Set `SYSML_VALIDATION_MODE=auto` for resilience
2. Configure `SYSML_REMOTE_VALIDATOR_URL` to your validation service
3. Ensure the remote validator is highly available
4. Monitor validation source in responses to track remote vs. local usage
5. Set `SPA_QUIET=1` to suppress fallback messages in logs

## Known Limitations

- Remote validator must return responses within 5 seconds
- No retry logic for remote validation failures
- No authentication/authorization for remote API (add if needed)
- Column numbers may not be available from all validators
- Local validator has limited semantic validation compared to official Xtext validator

## Future Enhancements

Potential improvements:
- Configurable timeout duration
- Retry logic with exponential backoff
- Authentication/API key support
- Caching of validation results
- Batch validation for multiple files
- WebSocket support for real-time validation
- Health check endpoint for remote validator
