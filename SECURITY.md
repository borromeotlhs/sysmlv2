# Security Guidelines

## Overview

This document provides security guidelines for the SysMLv2 project to help maintain the security and integrity of the codebase.

## Secrets Management

### ✅ What We Do Right

- **No hardcoded credentials** in source code
- **No API keys** committed to repository
- **Configuration files** contain only behavioral settings, not secrets
- **Clean git history** - no sensitive data in commit history

### 🔒 Handling Sensitive Data

#### Environment Variables

If you need to add API integrations or credentials in the future:

1. **NEVER commit `.env` files** - they are gitignored
2. **Use `.env.example`** for documentation (with placeholder values)
3. **Document required variables** in README or this file
4. **Access via environment variables** in code:
   ```python
   import os
   api_key = os.getenv('MY_API_KEY')
   ```

#### Configuration Files

The following files are for **configuration only**, not secrets:
- `ralph/config.env` - Ralph loop behavior settings
- `.claude/settings.json` - Claude Code permissions

### 🚫 Never Commit

- API keys, tokens, or credentials
- Private keys (`.pem`, `.key` files)
- Database files with sensitive data
- User data or PII
- `.env` files with real values

## File Protections

### .gitignore Coverage

The `.gitignore` file protects against accidentally committing:
- Secrets and credentials (`*.env`, `*secret*`, `*.key`, `*.pem`)
- Python cache files (`__pycache__/`, `*.pyc`)
- Node modules (`node_modules/`)
- Test artifacts (`test-results/`, `*.png`, `*.webm`)
- IDE files (`.vscode/`, `.idea/`)
- OS files (`.DS_Store`, `Thumbs.db`)
- Logs (`*.log`)

## Security Checklist

Before committing code, ensure:

- [ ] No hardcoded credentials or API keys
- [ ] No sensitive data in comments or debug output
- [ ] Configuration files contain only behavior settings
- [ ] `.env.example` used instead of `.env` for documentation
- [ ] Secrets accessed via environment variables
- [ ] No private keys or certificates

## Running Security Scans

To scan the repository for accidentally committed secrets:

```bash
# Search for common secret patterns
grep -r -E "api[_-]key|apikey|api_secret|password|passwd|secret|token" \
  --include="*.py" --include="*.js" --include="*.json" . \
  | grep -v "node_modules" | grep -v ".git" | grep -v "test"

# Check for specific key formats
grep -r -E "sk-[a-zA-Z0-9]{32,}|ghp_[a-zA-Z0-9]{36}|AKIA[0-9A-Z]{16}" . \
  | grep -v "node_modules" | grep -v ".git"
```

## Reporting Security Issues

If you discover a security vulnerability:

1. **Do NOT** open a public GitHub issue
2. Contact the repository maintainer privately
3. Provide details about the vulnerability
4. Allow time for a fix before public disclosure

## Local Development

### Safe Practices

1. **Use local `.env` files** for development (gitignored)
2. **Never share `.env` files** via chat, email, or screenshots
3. **Rotate credentials** if accidentally exposed
4. **Use minimal permissions** for API keys when possible

### Example .env Setup

Create `.env.example` for documentation:
```bash
# API Configuration
# MY_API_KEY=your_api_key_here
# MY_API_URL=https://api.example.com
```

Create `.env` for local use (gitignored):
```bash
MY_API_KEY=actual_secret_key_here
MY_API_URL=https://api.example.com
```

## Git History

### Checking for Leaked Secrets

```bash
# Check git history for deleted secret files
git log --all --full-history -- "*.env" "*.pem" "*.key"

# Check if a file ever contained secrets
git log -p -- path/to/file | grep -i "secret\|password\|key"
```

### If Secrets Are Committed

If you accidentally commit secrets:

1. **Immediately rotate/revoke** the exposed credentials
2. **Remove from git history** using `git filter-repo` or `BFG Repo-Cleaner`
3. **Force push** to update remote (coordinate with team)
4. **Update all local clones** after history rewrite

## Dependencies

### Security Updates

Regularly update dependencies to patch security vulnerabilities:

```bash
# Python
pip list --outdated
pip install --upgrade package-name

# Node.js
npm audit
npm audit fix
npm update
```

### Dependency Scanning

Consider using tools like:
- **Dependabot** (GitHub) - automated dependency updates
- **Snyk** - vulnerability scanning
- **npm audit** / **pip-audit** - built-in scanners

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
- [Git Secrets](https://github.com/awslabs/git-secrets) - prevent committing secrets

---

**Last Updated:** 2026-05-30  
**Security Audit Status:** ✅ Clean (no secrets found)
