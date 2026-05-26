# Architecture: Validator-Guided Grammar-Constrained SysML Synthesis

## Intent

Generate diverse SysML v2 textual examples while minimizing invalid syntax by separating concerns:

```text
generator → IR → renderer → .sysml → validator
```

## Components

### Rule Extractor

Input:

```text
SysML.xtext, if available
```

Output:

```text
output/rules/rules.json
```

The MVP may use a fallback hand-authored minimal rule catalog, but the interface should allow replacement with a real Xtext grammar AST traversal later.

### IR Generator

Input:

```text
rules.json
domain patterns
random seed
count
```

Output:

```text
output/candidates/*.ir.json
```

The generator controls architecture randomness:
- system family
- subsystem count
- subsystem kinds
- components
- requirements
- verification cases
- simple relationships

### Renderer

Input:

```text
*.ir.json
```

Output:

```text
*.sysml
```

The renderer is deterministic. It owns punctuation, indentation, braces, semicolons, and keyword formatting.

### Validator

Input:

```text
*.sysml
```

Output:

```text
*.validation.json
```

Exit codes:
- 0 valid
- 1 invalid
- 2 tool/config error

The MVP fallback validator is not full SysML v2 validation. It is a smoke validator that can be replaced by a Java/Xtext validator.

### Corpus Builder

Input:

```text
valid and invalid generated examples
```

Output:

```text
output/corpus/train.jsonl
output/corpus/repair.jsonl
```

## Long-Term Upgrade Path

```text
fallback validator
  → Java/Xtext validator JAR
  → rule extractor via Xtext/EMF AST
  → neural IR action generator
  → validator-guided RL / repair loop
```
