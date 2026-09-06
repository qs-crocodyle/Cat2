import os
import re

# Scans the uncommitted working tree (not git diff, since changes are unstaged)
# for active-code string literals containing Chinese characters that are NOT
# passed through Cat2.L() localization (i.e. non-comment, non-Localization.lua).

ADDON_ROOT = os.path.dirname(os.path.abspath(__file__))

# Files that define translation dictionaries and are therefore exempt.
DICT_FILES = {"Localization.lua"}

# Pattern to find any string literal in Lua:
# double quotes, single quotes, or double square brackets
string_pattern = re.compile(r'("(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'|\[\[.*?\]\])', re.DOTALL)

chinese_pattern = re.compile(r'[\u4e00-\u9fff]')

# A line is considered "active code" if it is not a pure comment and the
# Chinese string literal is not already wrapped in Cat2.L(...).
def is_localized_callable(line):
    # crude but effective: a line whose string literal is passed to Cat2.L
    return "Cat2.L(" in line

chinese_strings_found = {}
total_files_scanned = 0

for root, dirs, files in os.walk(ADDON_ROOT):
    # Skip hidden/vcs dirs
    dirs[:] = [d for d in dirs if not d.startswith('.') and d != 'node_modules']
    for name in files:
        if not name.endswith(".lua"):
            continue
        if name in DICT_FILES:
            continue
        filepath = os.path.join(root, name)
        total_files_scanned += 1

        try:
            with open(filepath, "r", encoding="utf-8-sig") as f:
                content = f.read()
        except Exception as e:
            print(f"Error reading {filepath}: {e}")
            continue

        lines = content.splitlines()
        for idx, line in enumerate(lines, 1):
            stripped = line.strip()
            # Skip pure comment lines
            if stripped.startswith('--'):
                continue

            if not chinese_pattern.search(line):
                continue

            # Extract string literals from this line
            strings = string_pattern.findall(line)
            for s in strings:
                if chinese_pattern.search(s):
                    # If the whole line is already routed through Cat2.L, skip.
                    if is_localized_callable(line) and s in line and "Cat2.L(" in line:
                        continue
                    if filepath not in chinese_strings_found:
                        chinese_strings_found[filepath] = []
                    chinese_strings_found[filepath].append((idx, line.strip()))

print(f"Scanned {total_files_scanned} .lua files in the working tree.")
print(f"\nFound {len(chinese_strings_found)} files with active code lines containing Chinese string literals not wrapped in Cat2.L():")
for filepath, occurrences in sorted(chinese_strings_found.items()):
    rel = os.path.relpath(filepath, ADDON_ROOT)
    print(f"\nFile: {rel} ({len(occurrences)} occurrences)")
    for line_num, line_text in occurrences[:10]:
        print(f"  Line {line_num:3d}: {line_text}")
    if len(occurrences) > 10:
        print(f"  ... and {len(occurrences) - 10} more.")
