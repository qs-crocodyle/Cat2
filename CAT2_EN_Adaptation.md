# Cat2 英文客户端适配记录

目标：让 Cat2 在 enUS（英文）客户端一切正常显示与运作，同时保留中文客户端兼容（中英文双匹配）。

## 总体策略

- 所有 `Cat2.L.*`（Spell / Buff / Item / UI）走 `Localization.lua` 字典表，enUS 时自动翻译，zhCN 时原样返回。
- 所有 `CastSpellByName` 全局包装（`CatLib.lua:6-14`）先经 `Cat2.L.Spell` 翻译再施法。
- 战斗日志（CatEvent）正则采用"中文 OR 英文"双模式，两个客户端都匹配。
- 内部键（如 `targetBuff["扫击"]`、图腾名变量、`GetShamanEnchantName` 返回值）保持中文，仅在对玩家行匹配/检测的一侧加英文。

## 一、战斗日志正则层（Core\CatEvent*.lua）

中文正则逐条追加英文模式（`or string.find(arg or "", "English")`）：

### CatEvent.lua
- `开始施放(.-)。` → `begins to cast (.-)%`
- `你必须位于目标背后` → `behind the target`
- 英勇打击/顺劈斩/发起的攻击/没有击中/你对/你击中 → Heroic Strike / Cleave / Your attack / missed / You hit / You hit the

### Druid
- 扫击/撕扯/凶猛撕咬 → Your Rake / Your Rip / Your Ferocious Bite（含 dodg/parr/block/miss 判定）
- 月火术/虫群被抵抗 → Your Moonfire / Your Insect Swarm was resisted

### Warrior
- 猛击 → Slam；压制 → Overpower；你的复仇/撕裂/战斗怒吼 → Your Revenge / Your Rend / You gain the effect of Battle Shout
- 你的攻击闪开 / 你躲闪 / 招架 / 格挡 / 被格挡 → dodg / You dodge / You parry / You block / blocked

### Paladin
- 神圣打击/十字军打击/审判 → Your Holy Strike / Crusader Strike / Your Judgement
- 圣印 gain：Zeal、正义/命令/智慧/十字军/光明 → Seal of Righteousness / Command / Wisdom / Crusader / Light
- 狂热消失 / 圣印消失 → Zeal fades / Seal.*fades
- `Cat2.Msg` 圣印名包装为 `Cat2.L(...)`

### Priest
- 神圣之火 → Holy Fire / 精神鞭者 → Your Mind Flay hits / 暗言术：痛 → Your Word: Pain was resisted / 吸血鬼拥抱 → Vampiric Embrace

### Hunter
- 黑名单 add Anomalus / Vek'lor / Vek'nilash
- 自动射击 → Your Auto Shot / 致命 → crits / 奥术射击+免疫 → Arcane Shot immune / 三类钉刺（蛇/蝰/蝎）missed 判定

### Warlock
- 献祭 → Immolate / 腐蚀术 → Corruption（`arg1==` 判别）
- 释放潜力/法力通道/生命通道 gain & fade
- 致命 → crits / 痛苦诅咒/腐蚀术/生命虹吸/献祭 → Your X was resisted
- `Cat2.Msg` 拆为两键（"施放 [暗影收割]" / "重新计算DOT持续时间"）

### Mage
- 炎爆术 → Pyroblast / 抵抗 → resisted / 灼烧/火球 → Your X was resisted / 法术连击 → You gain the effect of Hot Streng

### Rogue
- 破甲 → Your Expose Armor（含五态）/ 突袭 → Surprise / 各躲闪/招架/格挡英文化

### Shaman
- 熔岩爆裂 → Lava Burst / 根基图腾 → Grounding Totem / 图腾召回 → Totemic Recall
- "你施放了(.+)。" → 加 `You cast (.+)%.`，图腾名逐一映射英文
- 烈焰震击/熔岩爆裂/重燃烈火 → Flame Shock / Lava Burst / Raging Flames，附招架/躲闪/格挡/免疫
- 附魔检测 tooltip 加影响了英文关键词（Windfury / Flametongue / Frost / Frostbrand / Rockbiter；plash 提供 "minutes"）

### Warrior
- 见 CatEvent.lua 项 + 战斗怒吼/撕裂/天赋判断（continue）

## 二、物品层

### CatLib.lua `CheckInventoryItemName`
增加英文名二次匹配：先按原传入中文名，再经 `Cat2.L.Item(name)` 取英文名比对。中文客户端行为不变。

### Localization.lua `Cat2.Locals.Items` 新增 23 条（Turtle 装备）
以 `pfQuest zhCN`（ID→中文）+ `itemlevel-turtle Database-Item-enUS-1.0.lua`（ID→英文）关联：

| 中文 | 英文 |
|---|---|
| 起源皮盔/肩垫/长袍/短裤/便靴 | Genesis Helmet / Shoulder / Raiments / Pants / Treads |
| 梦游者头饰/肩饰/外套/束带/护手/护腿/长靴/腕甲/之戒 | Dreamwalker Head / Spaulders / Tunic / Belt / Handguards / Legguards / Boots / Bracers / Ring |
| 兄弟会头盔/项链/肩甲/胸甲/护腿/胫甲 | Helmet/Choker / Shouldeguards / Chestguard / Legguards / Greaves of the Brotherhood |
| 凶猛神像 / 蛮兽神像 | Idol of Ferocity / Idol of Brutality |
| 休眠腐化之眼 | Eye of Dormant Corruption |

## 验证

- 语法：`lua.compile` 全插件 444 个 lua 文件，0 失败
- 语义/真实加载：按 TOC 顺序载入 30 个模块（Stub 补齐 GameTooltip:SetOwner 等），全部 OK
- `L.Buff("猫科") → Cat Form`、`L.Item("起源皮盔") → Genesis Helmet` 等抽查通过

## 待办 / 注意事项

- Shaman 附魔 tooltip 的英文文本依赖实际客户端提示（minutes 等），建议英文端实机确认。
- 其余英文片段有 Turtle 专属名（Anomalus / Hot Streng / Raging Flames 等），按服上实况为准。
- 若后续发现未覆盖翻译，仍按`Localization.lua` 字典补充。

## 2026-10-11 同步（CN 2026-09-16 → 2026-10-11）

新增 Core：`CardDuration.lua`（持续时间显示服务，原样）；`RoguePoison.lua`（武器毒药涂抹，
加英文双匹配：附魔提示基名经 `L.Spell`、次数 `(%d+)%s*次 or charges`、背包全名经 `L.Spell`）。

新增卡片 66 个：毒药 40（`CreateWeaponPoisonCard`，行为走 `RoguePoison` 双匹配）、
`EviscerateSimple1-5`、`CallConfiguration`（ cardio 显示经 `L()`，导入导出名绑定）、
`FlowJumpPowerAbove/Below`、`WeaponSwitch`、`AutoCancelCustomBuff`、`CustomConsumableHP/MP`、
`CustomCastConsumableSelf/Target/Cursor`、`ShredClearcasting`、`ShredClawClearcasting`、
`ArcaneShotMove`、`Deterrence`（天赋名 `威慑 or Deterrence`）、`FeignDeathFlowTerminate`、
`ArcaneSurgeMove`、`DivineProtection`、`VampiricEmbraceBoss`、`SlamFlurryAfterMainSkills`、
`Custom/HunterCannon`、`HunterOrbitalMissile`（`小动物 or Critter`）。

Core 增量移植（保留 EN 双正则）：`CardRegistry`（`preserveUnknownValue`）、
`CardEventDispatcher`/`CastInterruptMonitor`（`CurrentExecutionContext.profileId` 跟随子配置）、
`CatEvent-Druid`（Rip/Ravage `<=` + 延迟清计时，新增 `GetRipDotCheckData`）、
`CatEvent-Paladin`（圣印 combat-log 分支仅 `not SuperWoW` 时走，增加 duration 清零；
`Seal()` 同理）、`CatEvent-Shaman`（`shaman_totem` duration provider）、
`CatLib`（爆发饰品 +`污秽之爪`，EN 名待用户确认，暂缺省）、
`ClassSpecializations`（盗贼 +`毒药`分组）、`ConfigurationCodec`/`ConfigurationRunner`
（配置调用：`RunProfile(session)` 共享 60 步预算、防递归，提示语走 `L()`）、
`CatImmuneLib`（6 系中文免疫名单补增，EN 名待确认，按文档缺口原样收录）。

字典：Spells 补毒药各等级（速效 II-VI、致命 II-V、麻痹 II-III、致残 II、致伤、
腐蚀/II=Corrosive Poison）＋`威慑`=Deterrence、`圣佑术`=Divine Protection；
修正 `溶解毒药`=Dissolvent Poison（itemDB 54009/54010 对应两阶卡）＋`溶解毒药 II`；
Buffs 补 `威慑`、`假死`；UI 补 `毒药`＋调用配置 12 条；Cards 新增 66 条、更新 22 条
（圣印/审判等级参数、Eviscerate 血腥气息优先、MindFlay 独立二阶、有限无敌 1-100%）。

UI 增量：FlowEditor 系拖放/悬停/ESC 收尾、ShortcutWindows 持续时间（绿字）优先显示、
ProfileManager/ImportExport/Notice/IconPicker 二级窗自管 ESC。

验证：`scan_zh_matchers` → FLAG 9（圣印内部链 6＋免疫 CN 侧 2＋旋风斩内部键 1，均为已知安全），
REVIEW 75（新增 5 处已 eyeball：Critter×2、Deterrence、charges、主手显示），DICT MISSING 0；
`check_completeness` 仅中文展示串（Cards 字典覆盖）。