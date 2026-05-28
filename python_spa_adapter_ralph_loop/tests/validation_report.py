#!/usr/bin/env python3
"""
SysML Validation Report Generator

Runs the SysML validator on all architecture files and generates
an HTML report showing pass/fail status and detailed issues.
"""
import sys
from pathlib import Path
from typing import List, Dict
from collections import defaultdict

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from tests.test_sysml_validation import SysMLValidator, ValidationError, ErrorSeverity


def run_validation_suite(architectures_dir: Path) -> Dict[str, List[ValidationError]]:
    """
    Run validation on all .sysml files in the architectures directory.

    Args:
        architectures_dir: Path to directory containing .sysml files

    Returns:
        Dictionary mapping filename to list of validation errors
    """
    validator = SysMLValidator()
    results = {}

    sysml_files = sorted(architectures_dir.glob('*.sysml'))

    print(f"\nRunning validation on {len(sysml_files)} architecture files...")
    print("=" * 70)

    for sysml_file in sysml_files:
        print(f"\nValidating {sysml_file.name}...", end=" ")

        issues = validator.validate_file(sysml_file)
        results[sysml_file.name] = issues

        # Count by severity
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]
        info = [i for i in issues if i.severity == ErrorSeverity.INFO]

        if errors:
            print(f"FAIL ({len(errors)} errors, {len(warnings)} warnings)")
        elif warnings:
            print(f"PASS with warnings ({len(warnings)} warnings)")
        else:
            print("PASS")

    return results


def print_summary(results: Dict[str, List[ValidationError]]):
    """Print validation summary to console"""

    print("\n" + "=" * 70)
    print("VALIDATION SUMMARY")
    print("=" * 70)

    total_files = len(results)
    files_with_errors = sum(1 for issues in results.values()
                           if any(i.severity == ErrorSeverity.ERROR for i in issues))
    files_with_warnings = sum(1 for issues in results.values()
                             if any(i.severity == ErrorSeverity.WARNING for i in issues)
                             and not any(i.severity == ErrorSeverity.ERROR for i in issues))
    files_clean = total_files - files_with_errors - files_with_warnings

    print(f"\nTotal files: {total_files}")
    print(f"  Clean: {files_clean} ({files_clean/total_files*100:.1f}%)")
    print(f"  Warnings only: {files_with_warnings} ({files_with_warnings/total_files*100:.1f}%)")
    print(f"  Errors: {files_with_errors} ({files_with_errors/total_files*100:.1f}%)")

    # Count issues by category
    category_counts = defaultdict(int)
    for issues in results.values():
        for issue in issues:
            if issue.severity == ErrorSeverity.ERROR:
                category_counts[issue.category] += 1

    if category_counts:
        print("\nTop error categories:")
        for category, count in sorted(category_counts.items(), key=lambda x: -x[1])[:5]:
            print(f"  {category}: {count}")


def print_detailed_issues(results: Dict[str, List[ValidationError]], max_files: int = 10):
    """Print detailed issues for files with errors"""

    print("\n" + "=" * 70)
    print("DETAILED ISSUES (first 10 files with errors)")
    print("=" * 70)

    shown = 0
    for filename, issues in sorted(results.items()):
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]

        if not errors:
            continue

        if shown >= max_files:
            break

        print(f"\n{filename}:")
        print("-" * 70)

        for error in errors[:10]:  # Limit to 10 errors per file
            print(f"  {error}")

        if len(errors) > 10:
            print(f"  ... and {len(errors) - 10} more errors")

        shown += 1


def generate_html_report(results: Dict[str, List[ValidationError]], output_path: Path):
    """Generate HTML validation report"""

    html_parts = []

    # Header
    html_parts.append("""
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>SysML Validation Report</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        .summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .summary-card {
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }
        .summary-card.clean {
            background-color: #e8f5e9;
            border-left: 4px solid #4CAF50;
        }
        .summary-card.warnings {
            background-color: #fff3e0;
            border-left: 4px solid #FF9800;
        }
        .summary-card.errors {
            background-color: #ffebee;
            border-left: 4px solid #f44336;
        }
        .summary-card h3 {
            margin: 0;
            font-size: 2em;
            color: #333;
        }
        .summary-card p {
            margin: 10px 0 0 0;
            color: #666;
        }
        .file-list {
            margin-top: 30px;
        }
        .file-item {
            margin-bottom: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
            overflow: hidden;
        }
        .file-header {
            padding: 15px;
            background-color: #f9f9f9;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
        }
        .file-header:hover {
            background-color: #f0f0f0;
        }
        .file-name {
            font-weight: bold;
            font-family: monospace;
        }
        .status-badge {
            padding: 5px 12px;
            border-radius: 4px;
            font-size: 0.9em;
            font-weight: bold;
        }
        .status-badge.pass {
            background-color: #4CAF50;
            color: white;
        }
        .status-badge.warning {
            background-color: #FF9800;
            color: white;
        }
        .status-badge.fail {
            background-color: #f44336;
            color: white;
        }
        .file-details {
            display: none;
            padding: 15px;
            background-color: white;
        }
        .file-item.expanded .file-details {
            display: block;
        }
        .issue {
            padding: 10px;
            margin: 5px 0;
            border-left: 4px solid #ddd;
            background-color: #f9f9f9;
            font-family: monospace;
            font-size: 0.9em;
        }
        .issue.error {
            border-left-color: #f44336;
            background-color: #ffebee;
        }
        .issue.warning {
            border-left-color: #FF9800;
            background-color: #fff3e0;
        }
        .issue.info {
            border-left-color: #2196F3;
            background-color: #e3f2fd;
        }
        .issue-severity {
            font-weight: bold;
            margin-right: 10px;
        }
        .issue-category {
            color: #666;
            margin-right: 10px;
        }
        .toggle-all {
            margin: 20px 0;
        }
        .toggle-all button {
            padding: 10px 20px;
            margin-right: 10px;
            border: none;
            border-radius: 4px;
            background-color: #2196F3;
            color: white;
            cursor: pointer;
            font-size: 1em;
        }
        .toggle-all button:hover {
            background-color: #1976D2;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>SysML v2 Validation Report</h1>
""")

    # Summary statistics
    total_files = len(results)
    files_with_errors = sum(1 for issues in results.values()
                           if any(i.severity == ErrorSeverity.ERROR for i in issues))
    files_with_warnings = sum(1 for issues in results.values()
                             if any(i.severity == ErrorSeverity.WARNING for i in issues)
                             and not any(i.severity == ErrorSeverity.ERROR for i in issues))
    files_clean = total_files - files_with_errors - files_with_warnings

    html_parts.append(f"""
        <div class="summary">
            <div class="summary-card clean">
                <h3>{files_clean}</h3>
                <p>Clean Files</p>
            </div>
            <div class="summary-card warnings">
                <h3>{files_with_warnings}</h3>
                <p>Files with Warnings</p>
            </div>
            <div class="summary-card errors">
                <h3>{files_with_errors}</h3>
                <p>Files with Errors</p>
            </div>
        </div>

        <div class="toggle-all">
            <button onclick="expandAll()">Expand All</button>
            <button onclick="collapseAll()">Collapse All</button>
        </div>

        <div class="file-list">
""")

    # File details
    for filename, issues in sorted(results.items()):
        errors = [i for i in issues if i.severity == ErrorSeverity.ERROR]
        warnings = [i for i in issues if i.severity == ErrorSeverity.WARNING]
        info = [i for i in issues if i.severity == ErrorSeverity.INFO]

        # Determine status
        if errors:
            status = "fail"
            status_text = f"FAIL ({len(errors)} errors)"
        elif warnings:
            status = "warning"
            status_text = f"PASS ({len(warnings)} warnings)"
        else:
            status = "pass"
            status_text = "PASS"

        html_parts.append(f"""
            <div class="file-item">
                <div class="file-header" onclick="toggleFile(this)">
                    <span class="file-name">{filename}</span>
                    <span class="status-badge {status}">{status_text}</span>
                </div>
                <div class="file-details">
""")

        if issues:
            for issue in issues:
                severity_class = issue.severity.value
                html_parts.append(f"""
                    <div class="issue {severity_class}">
                        <span class="issue-severity">[{issue.severity.value.upper()}]</span>
                        <span class="issue-category">{issue.category}:</span>
                        {issue.message}
                        {f" (line {issue.line_number})" if issue.line_number else ""}
                    </div>
""")
        else:
            html_parts.append("<p>No issues found.</p>")

        html_parts.append("""
                </div>
            </div>
""")

    # Footer with JavaScript
    html_parts.append("""
        </div>
    </div>
    <script>
        function toggleFile(header) {
            const fileItem = header.parentElement;
            fileItem.classList.toggle('expanded');
        }
        function expandAll() {
            document.querySelectorAll('.file-item').forEach(item => {
                item.classList.add('expanded');
            });
        }
        function collapseAll() {
            document.querySelectorAll('.file-item').forEach(item => {
                item.classList.remove('expanded');
            });
        }
    </script>
</body>
</html>
""")

    # Write to file
    html_content = ''.join(html_parts)
    output_path.write_text(html_content, encoding='utf-8')
    print(f"\nHTML report generated: {output_path}")


def main():
    """Main entry point"""

    # Find architectures directory
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    architectures_dir = project_root / 'data' / 'architectures'

    if not architectures_dir.exists():
        print(f"Error: Architectures directory not found: {architectures_dir}")
        sys.exit(1)

    # Run validation
    results = run_validation_suite(architectures_dir)

    # Print summary
    print_summary(results)
    print_detailed_issues(results)

    # Generate HTML report
    output_path = project_root / 'validation_report.html'
    generate_html_report(results, output_path)

    # Exit with error code if any files have errors
    files_with_errors = sum(1 for issues in results.values()
                           if any(i.severity == ErrorSeverity.ERROR for i in issues))

    if files_with_errors > 0:
        print(f"\n\nValidation FAILED: {files_with_errors} files have errors")
        sys.exit(1)
    else:
        print("\n\nValidation PASSED: All files are valid")
        sys.exit(0)


if __name__ == '__main__':
    main()
