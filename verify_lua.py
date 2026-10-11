# -*- coding: utf-8 -*-
"""Post-edit safety gate for the Cat2 enUS addon.

Catches the class of bug that broke Localization.lua in the 2026-10-11 sync:
a scripted dict edit that left truncated lines / unbalanced quotes, which made
the whole chunk fail to load (surfacing later as `Cat2.L is nil`).

Checks (all offline, stdlib only):
  1. Lua chunk structure of every .lua file (strings/comments/long-brackets
     tokenized, then {}()/block-keyword balance). A single unclosed string
     fails the whole file in-game, so any hit here is fatal.
  2. TOC coverage: every .lua on disk is listed; every entry exists.
  3. Cards-dict coverage: every registered card id has a Localization entry.
  4. L-key coverage: every Cat2.L.Spell/Buff/Item/L() key used OUTSIDE
     Localization.lua exists in the matching dict (missing keys silently
     disable cards on enUS).

Usage:  python3 verify_lua.py   (exit 0 = clean, 1 = problems)
Run it after ANY scripted edit and before every commit.
"""
import os
import re
import sys

ADDON_ROOT = os.path.dirname(os.path.abspath(__file__))
FAILURES = []


def fail(msg):
    FAILURES.append(msg)
    print("FAIL: " + msg)


def lua_struct_errors(src):
    """Tokenize out strings/comments, then check delimiter + block balance.
    Returns a list of error strings (empty = structurally valid)."""
    out = []
    i, n = 0, len(src)
    line = 1
    errs = []
    while i < n:
        c = src[i]
        if c == "\n":
            line += 1
            i += 1
            continue
        if c == "-" and src[i:i + 2] == "--":
            if src[i:i + 4] == "--[[":
                j = src.find("]]", i + 4)
                if j < 0:
                    errs.append("unclosed long comment at line %d" % line)
                    break
                line += src.count("\n", i, j)
                i = j + 2
                continue
            j = src.find("\n", i)
            i = n if j < 0 else j
            continue
        if c in "\"'":
            q = c
            j = i + 1
            closed = False
            while j < n:
                if src[j] == "\\":
                    j += 2
                    continue
                if src[j] == "\n":
                    break
                if src[j] == q:
                    closed = True
                    break
                j += 1
            if not closed:
                errs.append("unclosed string at line %d" % line)
                k = src.find("\n", i)
                line += 1
                i = n if k < 0 else k + 1
                continue
            i = j + 1
            continue
        if c == "[" and src[i:i + 2] == "[[":
            j = src.find("]]", i + 2)
            if j < 0:
                errs.append("unclosed long string at line %d" % line)
                break
            line += src.count("\n", i, j)
            i = j + 2
            continue
        if c in "{}()":
            out.append(c)
            i += 1
            continue
        if c.isalpha() or c == "_":
            m = re.match(r"[A-Za-z_][A-Za-z0-9_]*", src[i:])
            w = m.group(0)
            # NOTE: `do` opens a block, but `for`/`while` must NOT also push:
            # `for...do...end` shares a single `end`. A bare `do...end`
            # still needs its `end`, hence `do` is tracked and for/while not.
            # Words after `.`/`:` are field/method names (e.g. `t.end`), not
            # keywords.
            prev = src[i - 1] if i > 0 else ""
            if prev not in (".", ":"):
                if w in ("function", "if", "do", "repeat"):
                    out.append(w)
                elif w in ("end", "until"):
                    out.append(w)
            i += len(w)
            continue
        i += 1
    # NOTE: `do` is intentionally not tracked: `for...do` / `while...do` share
    # one `end`, so counting `do` as an opener always over-counts.
    stack = []
    pairs = {")": "(", "}": "{"}
    for t in out:
        if t in "({":
            stack.append(t)
        elif t in ")}":
            if not stack or stack[-1] != pairs[t]:
                errs.append("mismatched %s" % t)
                break
            stack.pop()
    if stack:
        errs.append("unclosed delimiters: %s" % "".join(stack))
    bstack = []
    for t in out:
        if t in ("function", "if", "do", "repeat"):
            bstack.append(t)
        elif t == "end":
            if not bstack:
                errs.append("stray end")
                break
            bstack.pop()
        elif t == "until":
            if not bstack or bstack[-1] != "repeat":
                errs.append("until without repeat")
                break
            bstack.pop()
    if bstack:
        errs.append("unclosed blocks: %s" % bstack)
    return errs


def lua_files():
    for root, dirs, files in os.walk(ADDON_ROOT):
        dirs[:] = [d for d in dirs
                   if not d.startswith(".") and d != "node_modules"]
        for name in files:
            if name.endswith(".lua"):
                yield os.path.join(root, name)


def check_structure():
    checked = 0
    for path in lua_files():
        try:
            with open(path, "r", encoding="utf-8-sig") as f:
                src = f.read()
        except Exception as e:
            fail("cannot read %s: %s" % (path, e))
            continue
        checked += 1
        for e in lua_struct_errors(src):
            fail("%s: %s" % (os.path.relpath(path, ADDON_ROOT), e))
    print("structure: %d files checked" % checked)


def read_loc():
    with open(os.path.join(ADDON_ROOT, "Core", "Localization.lua"),
              "r", encoding="utf-8-sig") as f:
        return f.read()


def check_toc():
    with open(os.path.join(ADDON_ROOT, "Cat2.toc"), "r",
              encoding="utf-8-sig") as f:
        entries = [l.strip() for l in f if l.strip().endswith(".lua")]
    disk = []
    for path in lua_files():
        disk.append(os.path.relpath(path, ADDON_ROOT).replace("/", "\\"))
    for rel in sorted(set(disk) - set(entries)):
        if rel.startswith("Tests\\"):
            continue  # intentionally not loaded
        fail("not in Cat2.toc: %s" % rel)
    for rel in sorted(set(entries) - set(disk)):
        fail("TOC entry missing on disk: %s" % rel)
    print("toc: %d entries, %d files" % (len(entries), len(disk)))


def check_cards_dict(loc):
    ids = set()
    for path in lua_files():
        if os.path.basename(path) == "Localization.lua":
            continue
        if "Tests" + os.sep in path:
            continue  # test-only dummy ids, never loaded in-game
        try:
            with open(path, "r", encoding="utf-8-sig") as f:
                t = f.read()
        except Exception:
            continue
        for m in re.finditer(r'id\s*=\s*"([^"]+)"', t):
            ids.add(m.group(1))
        for m in re.finditer(r'CreateWeaponPoisonCard\("([^"]+)"', t):
            ids.add(m.group(1))
    missing = sorted(i for i in ids if 'Cards["%s"]' % i not in loc)
    for i in missing:
        fail("no Cards-dict entry: %s" % i)
    print("cards: %d ids, %d missing" % (len(ids), len(missing)))


def dict_has(loc, section, key):
    m = re.search(r"Cat2\.Locals\." + section + r" = \{(.*?)\n\}",
                  loc, re.DOTALL)
    if m and ('["%s"]' % key) in m.group(1):
        return True
    # appended `Cat2.Locals.UI["k"] = "v"` form lives outside the block
    if section == "UI" and ('Cat2.Locals.UI["%s"]' % key) in loc:
        return True
    return False


# Pre-existing gaps grandfathered in: used via Cat2.L() but stored in the Spells
# dict (CatEvent-Warlock Shadow-Harvest messages, untouched since the 09 pass).
# New code must NOT add entries here — add the missing dict key instead.
KNOWN_L_GAPS = {
    ("UI", "施放 [暗影收割]"),
    ("UI", "，持续时间"),
    ("UI", "重新计算DOT持续时间"),
}


def check_l_keys(loc):
    need = {"Spells": set(), "Buffs": set(), "Items": set(), "UI": set()}
    for path in lua_files():
        if os.path.basename(path) == "Localization.lua":
            continue
        try:
            with open(path, "r", encoding="utf-8-sig") as f:
                t = f.read()
        except Exception:
            continue
        rel = os.path.relpath(path, ADDON_ROOT)
        for m in re.finditer(r'Cat2\.L\.Spell\("([^"]+)"\)', t):
            need["Spells"].add((m.group(1), rel))
        for m in re.finditer(r'Cat2\.L\.Buff\("([^"]+)"\)', t):
            need["Buffs"].add((m.group(1), rel))
        for m in re.finditer(r'Cat2\.L\.Item\("([^"]+)"\)', t):
            need["Items"].add((m.group(1), rel))
        for m in re.finditer(r'Cat2\.L\("([^"]+)"\)', t):
            need["UI"].add((m.group(1), rel))
    for section, keys in need.items():
        missing = sorted(k for k, _ in keys
                         if not dict_has(loc, section, k)
                         and (section, k) not in KNOWN_L_GAPS)
        for k in missing:
            users = sorted(r for kk, r in keys if kk == k)[:3]
            fail("L.%s key missing: %s (used by %s)" %
                 (section, k, ", ".join(users)))
    print("l-keys: %d checked" % sum(len(v) for v in need.values()))


if __name__ == "__main__":
    loc = read_loc()
    check_structure()
    check_toc()
    check_cards_dict(loc)
    check_l_keys(loc)
    if FAILURES:
        print("\n%d FAILURE(S)" % len(FAILURES))
        sys.exit(1)
    print("\nALL CHECKS PASSED")
