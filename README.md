# Mega Ralph SysML v2 Generator Kit

This scaffold is meant to be unzipped into a project folder and run with Claude Code.

Goal:

```text
Build an MVP toolchain that can generate many different valid SysML v2 textual files.
```

The intended pipeline is:

```text
SysML.xtext
  ↓
rule extractor
  ↓
rules.json
  ↓
IR generator
  ↓
model.ir.json
  ↓
renderer
  ↓
candidate.sysml
  ↓
validator
  ↓
valid / invalid / corpus outputs
```

The Ralph loop itself is:

```text
Claude Code implements
  ↓
local checks run
  ↓
failures are fed back
  ↓
Claude repairs
  ↓
repeat until MVP checks pass
```

## First Use

From the project root:

```bash
unzip mega-ralph-sysml-kit.zip
chmod +x ralph/*.sh
cp ralph/config.example.env ralph/config.env
./ralph/check_env.sh
```

Edit:

```bash
$EDITOR ralph/config.env
```

Then run:

```bash
./ralph/mega_ralph.sh
```

## What Claude Code Should Build

Claude Code should implement the MVP described in:

```text
specs/mvp_acceptance.md
specs/architecture.md
specs/ir_schema_v0.md
tasks/mega_task.md
```

## Expected MVP Outputs

After Claude Code finishes, this command should work:

```bash
./scripts/generate_validate_corpus.sh --count 25 --seed 42
```

Expected output shape:

```text
output/
  candidates/
  valid/
    *.ir.json
    *.sysml
    *.validation.json
  invalid/
    *.ir.json
    *.sysml
    *.validation.json
  corpus/
    train.jsonl
    repair.jsonl
```

## Recommended Build Order

```text
1. Create project structure and command wrappers.
2. Implement renderer from IR to .sysml.
3. Implement mock/local validator fallback.
4. Implement batch generator using IR schema.
5. Implement rule extractor interface.
6. Add real Xtext/SysML validator integration hook.
7. Add tests and fixtures.
8. Make generate_validate_corpus.sh pass.
```

## Important Design Constraint

Do not make the neural model or generator emit raw SysML text directly.

Use:

```text
generator → IR → renderer → .sysml → validator
```

The IR is the control surface. The `.sysml` file is the artifact.
