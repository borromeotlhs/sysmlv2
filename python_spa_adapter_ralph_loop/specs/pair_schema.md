# Pair Schema

Each pair record is a JSON object:

```json
{
  "id": "pair_arch_000001_001",
  "architecture_id": "arch_000001",
  "prompt_id": "prompt_arch_000001_001",
  "prompt": "Human-authored prompt text",
  "target_path": "data/architectures/arch_000001.json",
  "target_format": "json",
  "metadata": {
    "split": "train",
    "authoring_mode": "human_spa"
  }
}
```

The SPA can load an existing array of these records from `data/pairs/*.json`, edit them, and save them again.
