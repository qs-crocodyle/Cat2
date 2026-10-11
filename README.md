# Cat2 (enUS Adaptation)

English-client adaptation of the Chinese **Cat2** card-based macro addon
(all-class one-button macro flows for Turtle WoW 1.12).

- Works on the **enUS** client while staying compatible with **zhCN**:
  combat-log matchers are Chinese-OR-English dual patterns, spell/item/buff
  display names go through `Core/Localization.lua` dictionaries, and all
  `CastSpellByName` calls pass through a localizing wrapper.
- Internal keys (buff-table keys, totem-name vars, shaman-enchant names,
  `Cat2.Seal` params) stay Chinese on every locale by design.
- In-game language switch: `/cat2 lang zh | en`.

## Sync history

- 2026-09-04 / 2026-09-12: CN sync + full EN localization pass
  (combat-log dual regexes per class, Turtle-gear Items dict, UI strings,
  per-card EN display text).
- 2026-09-20: verified EN names against local oracles
  (`itemlevel-turtle` + `pfQuest` ID-joined items, `DPSMate_ParserENUS`
  combat-log fragments); fixed wrong item names; immune-target EN
  fallbacks; bait/lure tooltip branches.
- **2026-10-11: synced CN 2026-09-16 → 2026-10-11**
  (`Cat2.Version = "2026-10-11"`).

### What changed in the 2026-10-11 sync

New Core:

- `Core/CardDuration.lua` — card duration-display service (ported as-is).
- `Core/RoguePoison.lua` — weapon-poison apply; EN dual matching added
  (enchant-tooltip base name via `L.Spell`, charge count `次/charges`,
  bag-item full name via `L.Spell`).

New cards (66): 40 rogue poison cards (`CreateWeaponPoisonCard`),
`EviscerateSimple1-5`, `CallConfiguration` (prompts via `L()`; import/export
carries the target name, binds to the local profile id on import),
`FlowJumpPowerAbove/Below`, `WeaponSwitch`, `AutoCancelCustomBuff`,
`CustomConsumableHP/MP`, `CustomCastConsumableSelf/Target/Cursor`,
`ShredClearcasting`, `ShredClawClearcasting`, `ArcaneShotMove`,
`Deterrence` (talent check `威慑 or Deterrence`), `FeignDeathFlowTerminate`,
`ArcaneSurgeMove`, `DivineProtection`, `VampiricEmbraceBoss`,
`SlamFlurryAfterMainSkills`, `Custom/HunterCannon` + `HunterOrbitalMissile`
(creature check `小动物 or Critter`).

Core deltas (EN dual regexes preserved):

- `CardRegistry` (`preserveUnknownValue`), `CardEventDispatcher` /
  `CastInterruptMonitor` (follow `CurrentExecutionContext.profileId` into
  sub-configurations), `ConfigurationCodec` + `ConfigurationRunner`
  (configuration calls: shared 60-step budget, recursion guard, prompts
  via `L()`), `CatEvent-Druid` (Rip/Ravage timer fix, `GetRipDotCheckData`),
  `CatEvent-Paladin` (seal combat-log branches only when `not SuperWoW`),
  `CatEvent-Shaman` (`shaman_totem` duration provider), `CatLib`
  (burst-trinket list + 污秽之爪), `ClassSpecializations` (rogue +毒药 group),
  `CatImmuneLib` (holy/fire/nature/frost/shadow/arcane CN immune-name top-ups).

Localization (`Core/Localization.lua`):

- Spells: ranked poison names (Instant II-VI, Deadly II-V, Mind-numbing II-III,
  Crippling II, Wound, Dissolvent II, Corrosive + II), `威慑` = Deterrence,
  `圣佑术` = Divine Protection. **Correction:** `溶解毒药` is now
  Dissolvent Poison (item DB 54009/54010 match its two card ranks);
  `腐蚀毒药` = Corrosive Poison (47408/47409).
- Buffs: `威慑`, `假死`. UI: `毒药` + 12 Call-Configuration strings.
- Cards: 66 new display entries, 22 updated (seal/judgement rank options,
  Taste-for-Blood-first Eviscerate names, standalone second-tick Mind Flay,
  Limited Invulnerability Potion 1-100%).

UI deltas: drag/drop indicator + hover suppression, `EnsureFlowDropVisible`,
green duration display preferred over cooldowns in shortcut windows,
ESC self-handling for secondary windows, main-window `OnHide` cleanup.

Verification: `scan_zh_matchers` → FLAG 9 (all known-safe internal-CN
compares), REVIEW 75 (5 new spots eyeballed), DICT MISSING 0;
per-file EN-vs-CN diff audit; block-balance check vs CN originals.

Known gaps: `污秽之爪` has no confirmed English item name yet (ported CN-only,
not burst-recognized on enUS); poison `charges` tooltip wording unconfirmed
live (bag/API-count fallback covers it).

## Layout

- `Cat2.lua` — namespace + version (must load first).
- `Core/` — base services, event trackers, card infrastructure.
- `Cards/` — card definitions, self-registering via `Cat2.RegisterCard`.
- `UI/` — editor, shortcut windows, profile/macro UI.
- `CAT2_EN_Adaptation.md` — EN dual-regex strategy notes per class/file.
- `check_completeness.py` — flags active-code Chinese literals outside `Cat2.L()`.
