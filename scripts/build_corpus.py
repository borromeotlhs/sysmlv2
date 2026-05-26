#!/usr/bin/env python3
"""
Corpus Builder

Builds training corpus JSONL from validated SysML examples.
"""
import json
import argparse
from pathlib import Path
from typing import Dict, Any, List


def build_corpus_entry(
    sysml_path: Path,
    ir_path: Path,
    validation_path: Path,
    label: str
) -> Dict[str, Any]:
    """Build a single corpus entry."""
    # Read files
    with open(sysml_path, 'r') as f:
        sysml_text = f.read()

    ir_data = None
    if ir_path and ir_path.exists():
        with open(ir_path, 'r') as f:
            ir_data = json.load(f)

    validation_data = None
    if validation_path and validation_path.exists():
        with open(validation_path, 'r') as f:
            validation_data = json.load(f)

    entry = {
        "id": sysml_path.stem,
        "sysml": sysml_text,
        "label": label,
        "metadata": {
            "source": str(sysml_path),
            "validator": validation_data.get("validator") if validation_data else "unknown"
        }
    }

    if ir_data:
        entry["ir"] = ir_data

    if validation_data:
        entry["validation"] = validation_data

    return entry


def collect_examples(
    valid_dir: Path,
    invalid_dir: Path,
    candidates_dir: Path
) -> List[Dict[str, Any]]:
    """Collect all examples into corpus entries."""
    entries = []

    # Collect valid examples
    if valid_dir.exists():
        for sysml_file in valid_dir.glob("*.sysml"):
            stem = sysml_file.stem
            ir_path = candidates_dir / f"{stem}.ir.json"
            validation_path = valid_dir / f"{stem}.validation.json"

            entry = build_corpus_entry(
                sysml_file,
                ir_path if ir_path.exists() else None,
                validation_path if validation_path.exists() else None,
                "valid"
            )
            entries.append(entry)

    # Collect invalid examples
    if invalid_dir.exists():
        for sysml_file in invalid_dir.glob("*.sysml"):
            stem = sysml_file.stem
            ir_path = candidates_dir / f"{stem}.ir.json"
            validation_path = invalid_dir / f"{stem}.validation.json"

            entry = build_corpus_entry(
                sysml_file,
                ir_path if ir_path.exists() else None,
                validation_path if validation_path.exists() else None,
                "invalid"
            )
            entries.append(entry)

    return entries


def main():
    parser = argparse.ArgumentParser(
        description="Build training corpus from validated examples"
    )
    parser.add_argument(
        "--valid-dir",
        default="output/valid",
        help="Directory containing valid examples"
    )
    parser.add_argument(
        "--invalid-dir",
        default="output/invalid",
        help="Directory containing invalid examples"
    )
    parser.add_argument(
        "--candidates-dir",
        default="output/candidates",
        help="Directory containing IR files"
    )
    parser.add_argument(
        "--output",
        default="output/corpus/train.jsonl",
        help="Output JSONL file"
    )
    parser.add_argument(
        "--repair-output",
        default="output/corpus/repair.jsonl",
        help="Output JSONL file for repair pairs"
    )

    args = parser.parse_args()

    valid_dir = Path(args.valid_dir)
    invalid_dir = Path(args.invalid_dir)
    candidates_dir = Path(args.candidates_dir)

    # Collect examples
    entries = collect_examples(valid_dir, invalid_dir, candidates_dir)

    if not entries:
        print("[build-corpus] WARNING: No examples found")
        print(f"[build-corpus] Checked {valid_dir} and {invalid_dir}")
        # Create empty corpus file anyway
        Path(args.output).parent.mkdir(parents=True, exist_ok=True)
        with open(args.output, 'w') as f:
            pass
        return

    # Write train corpus
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w') as f:
        for entry in entries:
            f.write(json.dumps(entry) + '\n')

    valid_count = sum(1 for e in entries if e["label"] == "valid")
    invalid_count = sum(1 for e in entries if e["label"] == "invalid")

    print(f"[build-corpus] Built corpus: {output_path}")
    print(f"[build-corpus] Valid examples: {valid_count}")
    print(f"[build-corpus] Invalid examples: {invalid_count}")
    print(f"[build-corpus] Total entries: {len(entries)}")

    # Build repair corpus (invalid -> valid pairs)
    # For MVP, this is just a placeholder
    repair_entries = [e for e in entries if e["label"] == "invalid"]

    if repair_entries:
        repair_path = Path(args.repair_output)
        repair_path.parent.mkdir(parents=True, exist_ok=True)

        with open(repair_path, 'w') as f:
            for entry in repair_entries:
                repair_entry = {
                    "id": entry["id"],
                    "invalid": entry["sysml"],
                    "errors": entry.get("validation", {}).get("errors", []),
                    "valid": None  # Placeholder for future repair logic
                }
                f.write(json.dumps(repair_entry) + '\n')

        print(f"[build-corpus] Built repair corpus: {repair_path}")


if __name__ == "__main__":
    main()
