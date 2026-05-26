# MVP Acceptance

The MVP is accepted when:

```bash
./ralph/run_mvp_checks.sh
```

passes.

## Required Behavior

The command:

```bash
./scripts/generate_validate_corpus.sh --count 5 --seed 42
```

must:

1. Generate candidate IR files.
2. Render candidate `.sysml` files.
3. Validate rendered files.
4. Sort outputs into `output/valid` and `output/invalid`.
5. Emit validation JSON for every candidate.
6. Emit `output/corpus/train.jsonl`.
7. Produce at least one valid `.sysml` file.

## Required Files

```text
scripts/extract_rules.py
scripts/generate_ir.py
scripts/render_ir.py
scripts/validate_sysml.py
scripts/build_corpus.py
scripts/generate_validate_corpus.sh
```

## Required Honesty

Documentation and validator output must distinguish:

```text
fallback smoke validation
```

from:

```text
real Xtext/SysML semantic validation
```

The MVP may use the fallback validator, but must have an obvious extension point for a real validator JAR.
