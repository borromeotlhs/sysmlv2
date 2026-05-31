# Playwright CLI Setup

## ✅ Installation Complete

The Microsoft Playwright CLI has been successfully installed and configured as a skill for Claude Code.

### What Was Installed

1. **@playwright/cli** (v0.1.13)
   - Installed globally to: `~/.npm-global/lib/node_modules/@playwright/cli`
   - Binary available at: `~/.npm-global/bin/playwright-cli`

2. **Playwright CLI Skill**
   - Installed to: `.claude/skills/playwright-cli/`
   - Skill name: `playwright-cli`
   - Description: "Automate browser interactions, test web pages and work with Playwright tests."

3. **Browser (in progress)**
   - Chromium browser is being downloaded and installed
   - Will be available for headless and headed testing

### PATH Configuration

The npm global bin directory has been added to your PATH in `~/.bashrc`:
```bash
export PATH="$HOME/.npm-global/bin:$PATH"
```

To activate in current session:
```bash
source ~/.bashrc
```

## Using Playwright CLI

### As a Skill

You can now use the `playwright-cli` skill in Claude Code:

```
Use the playwright-cli skill to test the login flow on our SPA at http://127.0.0.1:8081
```

Claude will automatically invoke the skill and use the CLI commands.

### Direct CLI Usage

You can also use playwright-cli directly from the terminal:

```bash
# Open browser
playwright-cli open https://demo.playwright.dev/todomvc --headed

# Take a snapshot to see element references
playwright-cli snapshot

# Interact with elements
playwright-cli type "Buy groceries"
playwright-cli press Enter
playwright-cli check e21
playwright-cli screenshot

# Close browser
playwright-cli close
```

### Key Commands

**Core interactions:**
- `playwright-cli open [url]` - Open browser
- `playwright-cli goto <url>` - Navigate
- `playwright-cli click <target>` - Click element (use refs from snapshot)
- `playwright-cli type <text>` - Type text
- `playwright-cli fill <target> <text>` - Fill input
- `playwright-cli snapshot` - Get element references
- `playwright-cli screenshot` - Take screenshot

**Navigation:**
- `playwright-cli go-back` - Browser back
- `playwright-cli go-forward` - Browser forward
- `playwright-cli reload` - Refresh page

**Tabs:**
- `playwright-cli tab-list` - List all tabs
- `playwright-cli tab-new [url]` - New tab
- `playwright-cli tab-select <index>` - Switch tab

**Sessions:**
- `playwright-cli list` - List browser sessions
- `playwright-cli close-all` - Close all sessions

**Storage:**
- `playwright-cli state-save [filename]` - Save auth state
- `playwright-cli state-load <filename>` - Load auth state
- `playwright-cli cookie-*` - Cookie management
- `playwright-cli localstorage-*` - LocalStorage management

### Full Help

```bash
playwright-cli --help
```

## Skill Configuration

The skill is configured with the following allowed tools:
- `Bash(playwright-cli:*)`
- `Bash(npx:*)`
- `Bash(npm:*)`

This allows Claude Code to run playwright-cli commands automatically.

## Testing with Current Project

To test the SPA with playwright-cli skill:

1. **Start the SPA server:**
   ```bash
   cd python_spa_adapter_ralph_loop
   python3 spa/server.py --host 127.0.0.1 --port 8081
   ```

2. **Use the skill:**
   ```
   Use playwright-cli to:
   1. Open http://127.0.0.1:8081
   2. Take a snapshot
   3. Click on the first architecture file
   4. Verify the text tab shows content
   5. Take a screenshot
   ```

## Playwright CLI vs Playwright Test

### Playwright CLI (What We Just Installed) ✅
- **Best for:** Interactive browser automation via command line
- **Use case:** Testing web apps, automating browser tasks, debugging
- **Token-efficient:** Doesn't load heavy tool schemas into LLM context
- **State management:** Sessions persist between commands
- **Ideal for:** Coding agents that balance automation with large codebases

### Playwright Test (Already Installed)
- **Location:** `python_spa_adapter_ralph_loop/tests/playwright/`
- **Use case:** Structured test suites with assertions
- **Files:** `*.spec.js` test files
- **Run with:** `npx playwright test`

**Both can coexist!** Use:
- **Playwright CLI** for exploratory testing and agent-driven automation
- **Playwright Test** for regression test suites

## Troubleshooting

### Check Installation
```bash
playwright-cli --version
```

### List Available Skills
```bash
ls -la ~/.claude/skills/ 2>/dev/null || ls -la .claude/skills/
```

### Check Browser Installation
```bash
playwright-cli open --help
```

### Network Issues During Browser Download
If browser download fails due to network issues:
```bash
# Retry with higher timeout
export PLAYWRIGHT_DOWNLOAD_TIMEOUT=300000
playwright-cli install-browser chromium
```

## References

- **GitHub Repository:** https://github.com/microsoft/playwright-cli
- **Playwright Documentation:** https://playwright.dev
- **Skill Location:** `.claude/skills/playwright-cli/SKILL.md`

---

**Setup Date:** 2026-05-30  
**Version:** 0.1.13  
**Status:** ✅ Installed and Ready
