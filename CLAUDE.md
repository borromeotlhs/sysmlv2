# Claude Project Guidance

This project is a Mega Ralph scaffold for building a SysML v2 generator MVP.

Follow these rules:

```text
generator → IR → renderer → .sysml → validator
```

Do not collapse the generator and renderer into one raw text generator.

Use subagents in `.claude/agents/` when useful.

The objective command is:

```bash
./ralph/run_mvp_checks.sh
```

Make small, testable changes until it passes.

Do not bypass tests. Do not delete unrelated files. Do not claim full SysML v2 semantic validation unless a real Xtext/SysML validator is wired.
