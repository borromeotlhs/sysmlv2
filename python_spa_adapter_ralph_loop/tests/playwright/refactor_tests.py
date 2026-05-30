#!/usr/bin/env python3
"""
Script to refactor Playwright tests to use shared browser contexts.
This eliminates the need to restart Chromium and reload the page for each test.
"""

import re
import os

def refactor_test_file(filepath, needs_file_tree=False):
    """
    Refactor a test file to use shared page context.

    Args:
        filepath: Path to the test file
        needs_file_tree: If True, loads file tree in beforeAll. If False, skips tree load.
    """
    with open(filepath, 'r') as f:
        content = f.content()

    # Add shared page variable and serial mode after imports
    if 'let sharedPage;' not in content:
        # Find the end of require statements
        require_end = content.rfind("= require('./helpers');")
        if require_end != -1:
            insert_pos = content.find('\n', require_end) + 1
            content = content[:insert_pos] + '\nlet sharedPage;\n\ntest.describe.configure({ mode: \'serial\' });\n' + content[insert_pos:]

    # Replace test.beforeEach with test.beforeAll
    # Pattern: test.beforeEach(async ({ page }) => {
    beforeEach_pattern = r'test\.beforeEach\(async \(\{ page \}\) => \{'

    if needs_file_tree:
        beforeAll_replacement = '''test.beforeAll(async ({ browser }) => {
    sharedPage = await browser.newPage();
    await sharedPage.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(sharedPage); // Load file tree
  });

  test.afterAll(async () => {
    await sharedPage.close();
  });'''
    else:
        beforeAll_replacement = '''test.beforeAll(async ({ browser }) => {
    sharedPage = await browser.newPage();
    await sharedPage.goto('http://127.0.0.1:8081/');
    await waitForPageLoad(sharedPage, { skipTreeLoad: true });
    await loadArchitecture(sharedPage, 'architecture_001.sysml');
  });

  test.afterAll(async () => {
    await sharedPage.close();
  });'''

    # Find and replace beforeEach block
    # This is tricky because we need to match the entire block including the closing brace
    beforeEach_match = re.search(beforeEach_pattern, content)
    if beforeEach_match:
        start = beforeEach_match.start()
        # Find the matching closing });
        brace_count = 0
        pos = beforeEach_match.end()
        found_first_brace = False

        while pos < len(content):
            if content[pos] == '{':
                brace_count += 1
                found_first_brace = True
            elif content[pos] == '}':
                if found_first_brace:
                    brace_count -= 1
                    if brace_count == -1:
                        # Found the closing brace of the beforeEach function
                        # Look for }); pattern
                        if pos + 2 < len(content) and content[pos:pos+3] == '});':
                            end = pos + 3
                            content = content[:start] + beforeAll_replacement + content[end:]
                            break
            pos += 1

    # Replace all test function signatures: async ({ page }) => to async () => and add const page = sharedPage;
    test_pattern = r'test\([\'"]([^"\']+)[\'"],\s*async\s*\(\{\s*page\s*\}\)\s*=>\s*\{'

    def replace_test_sig(match):
        test_name = match.group(1)
        return f"test('{test_name}', async () => {{\n    const page = sharedPage;"

    content = re.sub(test_pattern, replace_test_sig, content)

    # Also handle test functions with different quote styles
    test_pattern2 = r'test\(([\'"`])([^\1]+)\1,\s*async\s*\(\{\s*page\s*\}\)\s*=>\s*\{'
    content = re.sub(test_pattern2, lambda m: f"test({m.group(1)}{m.group(2)}{m.group(1)}, async () => {{\n    const page = sharedPage;", content)

    return content

def main():
    test_dir = os.path.dirname(os.path.abspath(__file__))

    # Files that don't need file tree (direct architecture loading)
    no_tree_files = [
        'test_3d_view.spec.js',
        'test_bdd_tab.spec.js',
        'test_ibd_tab.spec.js',
        'test_text_tab.spec.js'
    ]

    # Files that need file tree
    tree_files = [
        'test_file_tree.spec.js',
        'test_e2e_workflow.spec.js',
        'test_pair_authoring.spec.js'
    ]

    # Skip test_lazy_load.spec.js as it's a special case

    for filename in no_tree_files:
        filepath = os.path.join(test_dir, filename)
        if os.path.exists(filepath):
            print(f"Refactoring {filename}...")
            refactored_content = refactor_test_file(filepath, needs_file_tree=False)

            # Write to backup first
            backup_path = filepath + '.backup'
            with open(filepath, 'r') as f:
                with open(backup_path, 'w') as bf:
                    bf.write(f.read())

            # Write refactored content
            with open(filepath, 'w') as f:
                f.write(refactored_content)

            print(f"  ✓ Refactored {filename} (backup saved to {filename}.backup)")

    for filename in tree_files:
        filepath = os.path.join(test_dir, filename)
        if os.path.exists(filepath):
            print(f"Refactoring {filename}...")
            refactored_content = refactor_test_file(filepath, needs_file_tree=True)

            # Write to backup first
            backup_path = filepath + '.backup'
            with open(filepath, 'r') as f:
                with open(backup_path, 'w') as bf:
                    bf.write(f.read())

            # Write refactored content
            with open(filepath, 'w') as f:
                f.write(refactored_content)

            print(f"  ✓ Refactored {filename} (backup saved to {filename}.backup)")

    print("\nRefactoring complete!")
    print("\nExpected speedup:")
    print("- test_3d_view: ~19 page reloads avoided → ~3-5 minutes saved")
    print("- test_bdd_tab: ~10 page reloads avoided → ~1-2 minutes saved")
    print("- test_ibd_tab: ~12 page reloads avoided → ~2-3 minutes saved")
    print("- test_text_tab: ~9 page reloads avoided → ~1-2 minutes saved")
    print("- test_file_tree: ~7 page reloads avoided → ~1-2 minutes saved")
    print("- test_e2e_workflow: ~9 page reloads avoided → ~1-2 minutes saved")
    print("- test_pair_authoring: ~10 page reloads avoided → ~1-2 minutes saved")
    print("\nTotal expected speedup: ~10-15 minutes faster test execution")

if __name__ == '__main__':
    main()
