# Cat2 (enUS Adaptation)

English-client adaptation of the Chinese **Cat2** card-based macro addon
(all-class one-button macro flows for Turtle WoW 1.12).

- Works on **enUS** while staying **zhCN**-compatible: combat-log matchers are
  Chinese-OR-English dual patterns, display names go through
  `Core/Localization.lua`, and spell casts pass through a localizing wrapper.
- In-game language switch: `/cat2 lang zh | en`.

## Sync history

- 2026-09-04 / 2026-09-12: CN sync + full EN localization pass.
- 2026-09-20: EN names verified against local oracles; fixes applied.
- **2026-10-11: synced CN 2026-09-16 → 2026-10-11**
  (`Cat2.Version = "2026-10-11"`). 66 new cards (poisons, call-configuration,
  custom consumables, new class cards), 2 new Core modules, Core/UI deltas
  ported with EN duals kept, localization dictionaries extended.

Verification: `scan_zh_matchers` → FLAG 9 (known-safe), REVIEW 75, DICT 0.

Known gaps: `污秽之爪` has no confirmed English name yet; poison `charges`
tooltip wording unconfirmed live (fallback covers it).

## Layout

- `Cat2.lua` — namespace + version (loads first).
- `Core/` — base services, event trackers, card infrastructure.
- `Cards/` — self-registering card definitions.
- `UI/` — editor, shortcut windows, profile UI.
- `CAT2_EN_Adaptation.md` — EN adaptation notes per class/file.
