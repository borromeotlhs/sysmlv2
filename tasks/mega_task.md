# Mega Ralph Task: SysML v2 Generator MVP

Build an MVP toolchain that can generate lots of different valid-looking SysML v2 textual files using a controlled architecture pipeline.

## Core Pipeline

```text
rules.json + domain patterns + seed
  ↓
IR generator
  ↓
model.ir.json
  ↓
renderer
  ↓
model.sysml
  ↓
validator
  ↓
valid/invalid outputs
  ↓
training corpus JSONL
```

## Required Scripts

Create these scripts:

```text
scripts/extract_rules.py
scripts/generate_ir.py
scripts/render_ir.py
scripts/validate_sysml.py
scripts/build_corpus.py
scripts/generate_validate_corpus.sh
```

## Required Directories

Create/maintain:

```text
tools/
tests/
tests/fixtures/
output/
output/candidates/
output/valid/
output/invalid/
output/corpus/
output/rules/
```

## MVP Behavior

This command must pass:

```bash
./scripts/generate_validate_corpus.sh --count 5 --seed 42
```

It must produce at least one valid `.sysml` file in:

```text
output/valid/
```

It must produce:

```text
output/corpus/train.jsonl
```

## Design Rules

1. The generator emits IR, not raw SysML text.
2. The renderer emits SysML text from IR.
3. The validator checks rendered SysML.
4. The validator must support a fallback MVP mode.
5. The code must be structured so a real Java/Xtext validator JAR can replace or augment fallback validation later.
6. Use seeded randomness so generation is reproducible.
7. Save both `.ir.json` and `.sysml` outputs.
8. Save `.validation.json` for each generated file.
9. Keep all scripts runnable from the project root.

## Subagent Use

Use these project subagents where useful:

```text
sysml-validator-engineer
grammar-rule-extractor
ir-generator-engineer
sysml-renderer-engineer
corpus-pipeline-engineer
integration-reviewer
```

## MVP Honesty

Do not claim the fallback validator is full SysML v2 validation. It is only a smoke-test validator until the real Xtext/SysML validator is connected.
