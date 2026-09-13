-- Cat2 国际化与本地化支持模块 (Localization)
Cat2 = Cat2 or {}
Cat2.Locals = Cat2.Locals or {}

local function DetectLocale()
    if Cat2CharacterDB and Cat2CharacterDB.locale then
        return Cat2CharacterDB.locale
    end
    return "enUS"
end

Cat2.CurrentLocale = DetectLocale()

function Cat2.SetLocale(locale)
    if locale == "en" or locale == "enus" or locale == "enUS" or locale == "enGB" then
        Cat2.CurrentLocale = "enUS"
    elseif locale == "zh" or locale == "zhcn" or locale == "zhCN" or locale == "zhtw" then
        Cat2.CurrentLocale = "zhCN"
    else
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff5555Cat2: Usage: /cat2 lang zh | en|r")
        end
        return
    end
    if Cat2CharacterDB then
        Cat2CharacterDB.locale = Cat2.CurrentLocale
    end
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00aaffCat2: Language set to " .. Cat2.CurrentLocale .. ". Please reload UI (/reload) if needed.|r")
    end
end

Cat2.Locals.UI = {
    ["快捷窗已达上限，请先关闭其他配置的快捷窗。"] = "Shortcut windows limit reached. Please close other shortcut windows first.",
    ["流程顺序"] = "Flow Order",
    ["流程从上向下执行。拖动左侧卡片可以调整顺序。\n部分卡片成功执行后会停止本轮流程，重要卡片请放在合适位置。"] = "Flow runs from top to bottom. Drag cards on the left to adjust order.\nSome cards stop the sequence upon successful execution. Place important cards appropriately.",
    ["卡片状态"] = "Card Status",
    ["点击左侧卡片后，可以暂停、恢复、隐藏或删除。\n被动卡片|cffb880f0（紫色）|r会影响整个流程；暂停后，它的被动效果不会生效。"] = "Click a card on the left to pause, resume, hide, or delete it.\nPassive cards |cffb880f0(purple)|r affect the entire flow; when paused, their passive effects do not apply.",
    ["快捷小窗"] = "Shortcut Windows",
    ["显示在小窗中的卡片可以随时点击暂停或恢复。\n主界面与快捷小窗相互独立，关闭主界面不会关闭小窗。"] = "Cards displayed in shortcut windows can be paused or resumed anytime.\nThe main interface and shortcut windows are independent; closing the main interface won't close shortcut windows.",
    ["配置使用"] = "Profile Usage",
    ["输入 |cffff4fa3/cat2 配置名|r 执行对应流程。配置按角色保存。\n导入配置时会检查职业；同名配置需要确认后才能覆盖。"] = "Type |cffff4fa3/cat2 profileName|r to execute the flow. Profiles are saved per character.\nClass is checked when importing profiles; duplicate profile names require confirmation to overwrite.",
    ["关闭"] = "Close",
    ["导入失败"] = "Import Failed",
    ["配置导入成功"] = "Profile imported successfully",
    ["职业不匹配"] = "Class mismatch",
    ["无法识别配置文本"] = "Unrecognized configuration text",
    ["名称长度必须为 2-12 个汉字或字符。"] = "Name length must be 2-12 characters.",
    ["已经存在同名配置。"] = "A profile with the same name already exists.",
    ["」。文本已压缩转档，点击“全选”后按 Ctrl+C 复制。"] = "\". Text compressed/encoded, click \"Select All\" then press Ctrl+C to copy.",
    ["全选"] = "Select All",
    ["将其他用户提供的完整配置文本粘贴到下方，然后点击“导入”。"] = "Paste the complete profile text provided by other users below, then click \"Import\".",
    ["Cat2：配置管理模块尚未加载，请完整重启游戏。"] = "Cat2: Profile management module not loaded yet, please restart game.",
    ["|cffff5555Cat2：配置管理模块尚未加载，请完整重启游戏。|r"] = "|cffff5555Cat2: Profile management module not loaded yet, please restart game.|r",
    ["平衡"] = "Balance",
    ["野性战斗"] = "Feral",
    ["恢复"] = "Restoration",
    ["射击"] = "Marksmanship",
    ["生存"] = "Survival",
    ["野兽控制"] = "Beast Mastery",
    ["奥术"] = "Arcane",
    ["火焰"] = "Fire",
    ["冰霜"] = "Frost",
    ["神圣"] = "Holy",
    ["防护"] = "Protection",
    ["惩戒"] = "Retribution",
    ["戒律"] = "Discipline",
    ["暗影"] = "Shadow",
    ["刺杀"] = "Assassination",
    ["战斗"] = "Combat",
    ["敏锐"] = "Subtlety",
    ["元素"] = "Elemental",
    ["增强"] = "Enhancement",
    ["图腾"] = "Totems",
    ["痛苦"] = "Affliction",
    ["恶魔学识"] = "Demonology",
    ["毁灭"] = "Destruction",
    ["武器"] = "Arms",
    ["狂怒"] = "Fury",
    ["第一系"] = "1st",
    ["第二系"] = "2nd",
    ["第三系"] = "3rd",
    ["小动物"] = "Critter",
    ["盾牌"] = "Shield",
    ["匕首"] = "Dagger",
    ["投掷武器"] = "Thrown",
    ["替换"] = "Replace",
    ["治疗效果，最多(%d+)点"] = "Increases healing by (%d+).",
    ["治疗效果，效果最多(%d+)点"] = "Increases healing effect by up to (%d+).",
    ["治疗效果提高最多(%d+)"] = "Increases healing effect by up to (%d+).",
    ["德鲁伊"] = "Druid",
    ["猎人"] = "Hunter",
    ["法师"] = "Mage",
    ["圣骑士"] = "Paladin",
    ["牧师"] = "Priest",
    ["盗贼"] = "Rogue",
    ["萨满"] = "Shaman",
    ["术士"] = "Warlock",
    ["战士"] = "Warrior",
    ["职业"] = "Class",
    ["版本："] = "Version: ",
    ["流程"] = "Flow",
    ["规则"] = "Rules",
    ["导出"] = "Export",
    ["被动"] = "Passive",
    ["执行"] = "Execute",
    ["隐"] = "Hidden",
    ["改"] = "Rename",
    ["显示在流程快捷小窗"] = "Show in shortcut window",
    ["从流程快捷小窗隐藏"] = "Hide from shortcut window",
    ["恢复此流程步骤"] = "Resume this flow step",
    ["暂停此流程步骤"] = "Pause this flow step",
    ["从当前流程删除此卡片"] = "Remove this card from the flow",
    ["关闭流程快捷小窗"] = "Close flow shortcut window",
    ["打开流程快捷小窗"] = "Open flow shortcut window",
    ["将右侧步骤拖到这里\n支持鼠标左键或右键拖动\n拖动左侧步骤可以调整顺序"] = "Drag steps from the right here\nSupports left-click or right-click drag\nDrag steps on the left to reorder",
    ["当前正在预览其他职业。\n只有角色本职业可用的共享卡片能够加入流程。"] = "Previewing another class.\nOnly shared cards usable by your class can be added to the flow.",
    ["流程卡片已经装满，最多可放置 "] = "The flow is full; up to ",
    [" 张卡片。"] = " cards can be placed.",
    ["被动卡片「"] = "Passive card \"",
    ["」在同一配置中只能放置一张。"] = "\" can only be placed once in the same profile.",
    ["导入配置数据无效"] = "Imported configuration data is invalid",
    ["需要覆盖的配置已经不存在"] = "The profile to overwrite no longer exists",
    ["当前配置的执行指令"] = "Execution command for current profile",
    ["点击输入框自动全选，然后按 Ctrl+C 复制。"] = "Click the input box to select all, then press Ctrl+C to copy.",
    ["可粘贴到宏中，也可以直接在聊天栏使用。"] = "Can be pasted into a macro or used directly in chat.",
    ["重命名当前配置"] = "Rename current profile",
    ["」吗？\n此操作无法撤销。"] = "\"?\nThis action cannot be undone.",
    ["未识别卡片"] = "Unrecognized card",
    ["未知ID"] = "Unknown ID",
    ["Cat2 调试"] = "Cat2 Debug",
    ["未发现BUFF"] = "Buff not found",
    ["配置1"] = "Profile1",
    ["输入内容无效。"] = "Invalid input.",
    ["」。"] = "\".",
    ["」已覆盖，并已切换为当前配置。"] = "\" has been overwritten and switched to current profile.",
    ["」导入成功，并已切换为当前配置。"] = "\" imported successfully and switched to current profile.",
    ["覆盖后，原配置的卡片及顺序将被替换。"] = "After overwriting, the original profile's cards and order will be replaced.",
    ["」。\n"] = "\".\n",
    ["无法导出配置：「"] = "Cannot export profile: \"",
    ["配置导入"] = "Profile Import",
    ["配置导出"] = "Profile Export",
    ["正在导出「"] = "Exporting \"",
    ["」文本已压缩转档，点击“全选”后按 Ctrl+C 复制。"] = "\" text compressed/encoded, click \"Select All\" then press Ctrl+C to copy.",
    ["配置「"] = "Profile \"",
    ["已经存在同名配置「"] = "A profile with the same name \"",
    ["」。\n覆盖后，原配置的卡片及顺序将被替换。"] = "\".\nAfter overwriting, the original profile's cards and order will be replaced.",
    ["职业不匹配，不能导入。\n配置职业："] = "Class mismatch, cannot import.\nProfile Class: ",
    ["\n当前职业："] = "\nCurrent Class: ",
    ["未知"] = "Unknown",
    ["未知错误"] = "Unknown error",
    ["导入失败："] = "Import Failed: ",
    ["导入"] = "Import",
    ["请先粘贴需要导入的配置文本。"] = "Please paste the profile text to import first.",
    ["配置数据无效"] = "Invalid configuration data",
    ["无法识别当前角色职业"] = "Cannot recognize current character class",
    ["配置内容超出导出限制"] = "Configuration content exceeds export limit",
    ["卡片 ID 超出导出限制"] = "Card ID exceeds export limit",
    ["文本长度不正确"] = "Incorrect text length",
    ["文本包含无效字符"] = "Text contains invalid characters",
    ["文本结尾不完整"] = "Text ending is incomplete",
    ["填充字符位置不正确"] = "Incorrect padding character position",
    ["压缩文本不完整"] = "Compressed text is incomplete",
    ["压缩文本引用无效"] = "Invalid compressed text reference",
    ["导入内容超过安全限制"] = "Imported content exceeds safety limit",
    ["配置版本不受支持"] = "Configuration version not supported",
    ["快捷窗布局数据无效"] = "Invalid shortcut window layout data",
    ["配置内容不完整"] = "Incomplete configuration content",
    ["配置内容超过安全限制"] = "Configuration content exceeds safety limit",
    ["卡片配置数据无效"] = "Invalid card configuration data",
    ["卡片参数数量超出导出限制"] = "Card parameter count exceeds export limit",
    ["卡片数字参数无效"] = "Invalid numeric card parameter",
    ["卡片文本参数超出导出限制"] = "Card text parameter exceeds export limit",
    ["卡片参数数据无效"] = "Invalid card parameter data",
    ["卡片参数数据不完整"] = "Incomplete card parameter data",
    ["卡片开关参数无效"] = "Invalid card toggle parameter",
    ["卡片文本参数无效"] = "Invalid card text parameter",
    ["卡片参数类型不受支持"] = "Unsupported card parameter type",
    ["配置末尾包含额外数据"] = "Configuration contains extra data at the end",
    ["没有可导入的文本"] = "No text to import",
    ["导入文本超过长度限制"] = "Imported text exceeds length limit",
    ["这不是 Cat2 配置文本，或配置版本不受支持"] = "This is not Cat2 configuration text, or the version is unsupported",
    ["导入文本不完整"] = "Imported text is incomplete",
    ["校验失败\n文本可能复制不完整或已被修改"] = "Checksum failed\nThe text may have been copied incompletely or modified",
    ["配置管理模块尚未加载，请完整重启游戏。"] = "Profile management module not loaded yet, please restart game.",
    ["Cat2 主界面加载失败：请查看 Lua 错误信息。"] = "Cat2 Main Interface Load Failed: Please check Lua error message.",
    ["Cat2 主界面错误："] = "Cat2 Main Interface Error: ",
    ["Cat2 使用规则"] = "Cat2 Usage Rules",
    ["Cat2 加载完成！"] = "Cat2 Loaded Successfully!",
    ["Cat2 快捷窗初始化失败："] = "Cat2 Shortcut Window Initialization Failed: ",
    ["Cat2 快捷窗错误："] = "Cat2 Shortcut Window Error: ",
    ["Cat|cffff3f3f2|r 喵！一键宏"] = "Cat|cffff3f3f2|r Macro",
    ["左键点击打开设置"] = "Left-click to open settings",
    ["PlayerInformation 调试"] = "PlayerInformation Debug",
    ["debug 是调试指令，不能作为配置名称。"] = "debug is a debug command and cannot be used as a profile name.",
    ["Cat2：请输入配置名，例如 /cat2 配置1"] = "Cat2: Please enter profile name, e.g. /cat2 Profile1",
    ["Cat2：调试窗尚未加载，请完整重启游戏。"] = "Cat2: Debug window not loaded yet, please restart game.",
    ["Cat2：找不到配置「"] = "Cat2: Cannot find profile \"",
    ["Cat2：配置「"] = "Cat2: Profile \"",
    ["Cat2："] = "Cat2: ",
    ["」执行完成，共调用 "] = "\" executed successfully, called ",
    [" 张卡片，其中 "] = " cards in total, with ",
    [" 张失败。"] = " failed.",
    ["Cat2：失败卡片："] = "Cat2: Failed cards: ",
    ["Cat2：被动卡片「"] = "Cat2: Passive Card \"",
    ["」应用失败："] = "\" application failed: ",
    ["」检查失败："] = "\" check failed: ",
    ["Cat2：卡片「"] = "Cat2: Card \"",
    ["」执行失败："] = "\" execution failed: ",
    ["」的跳转编号无效，必须是当前流程内1至60的整数编号；本轮已终止。"] = "\" has an invalid jump target; must be an integer from 1 to 60 within the current profile; this round has been stopped.",
    ["已达到60步上限"] = "Reached 60-step execution limit",
    ["「"] = "\"",
    ["」"] = "\"",
    [" 喵！"] = " Meow!",
    ["还原位置"] = "Reset Position",
    ["打开主界面"] = "Open Main Window",
    ["关闭此快捷窗"] = "Close Shortcut Window",
    ["点击恢复步骤"] = "Click to resume step",
    ["点击暂停步骤"] = "Click to pause step",
    ["背包中没有该物品"] = "Item not in inventory",
    ["当前配置"] = "Current Profile",
    ["快捷窗"] = "Shortcut Window",
    ["已开启"] = "Enabled",
    ["已关闭"] = "Disabled",
    ["已开启快捷窗："] = "Active Shortcut Windows: ",
    ["配置与快捷窗管理"] = "Profiles & Shortcut Windows",
    ["配置列表"] = "Profile List",
    ["新建配置"] = "New Profile",
    ["新建配置（2-12个字符）"] = "New Profile (2-12 chars)",
    ["删除配置"] = "Delete Profile",
    ["至少需要保留一个配置，不能删除当前配置。"] = "At least one profile must be kept; cannot delete current profile.",
    ["确定删除配置「"] = "Are you sure you want to delete profile \"",
    ["删除"] = "Delete",
    ["改名"] = "Rename",
    ["配置改名（2-12个字符）"] = "Rename Profile (2-12 chars)",
    ["快捷窗缩放"] = "Window Scale",
    ["非图标透明度"] = "Non-Icon Opacity",
    ["解除锁定"] = "Unlock Position",
    ["位置锁定"] = "Lock Position",
    ["显示冷却"] = "Show Cooldowns",
    ["隐藏冷却"] = "Hide Cooldowns",
    ["每行或列图标数"] = "Icons per Row/Col",
    ["排列方向"] = "Layout Direction",
    ["横向优先"] = "Horizontal First",
    ["纵向优先"] = "Vertical First",
    ["宏命令（点击全选后 Ctrl+C 复制）"] = "Macro Command (Click All then Ctrl+C)",
    ["当前配置的执行命令"] = "Execution command for current profile",
    ["点击自动全选，再按 Ctrl+C 复制到宏中。"] = "Click to select all, then press Ctrl+C to copy into macro.",
    ["管理"] = "Manage",
    ["全部"] = "All",
    ["通用"] = "Common",
    ["药水"] = "Potions",
    ["第四系"] = "4th",
    ["确定"] = "OK",
    ["确认删除"] = "Confirm Delete",
    ["取消"] = "Cancel",
    ["创建"] = "Create",
    ["覆盖"] = "Overwrite",
    ["未命名被动卡片"] = "Unnamed Passive Card",
    ["未命名卡片"] = "Unnamed Card",
    ["保存"] = "Save",
    ["卡片参数："] = "Card Parameters: ",
    ["「"] = "\"",
    ["」请选择有效选项。"] = "\" please select a valid option.",
    [" 到 "] = " and ",
    ["」请输入 "] = "\" must be a number between ",
    [" 之间的数字。"] = ".",
    ["开启"] = "On",
    ["」请输入开启或关闭。"] = "\" must be On or Off.",
    ["未选择"] = "Not selected",
    ["（默认）"] = " (default)",
    ["未设置"] = "Not set",
    ["使用默认值（"] = "Use default (",
    ["）"] = ")",
    ["该卡片没有参数可修改"] = "This card has no available parameters",
    ["设置卡片参数"] = "Configure Card Parameters",
    ["当前没有独立设置，运行时使用卡片的继承值或默认值。"] = "No custom settings; inherits values or defaults at runtime.",
    ["部分或全部参数使用本卡片实例的独立设置。"] = "Some or all parameters use custom settings for this card instance.",
    ["未设置过的参数会显示卡片默认值；输入项留空或下拉选择默认值可取消独立设置。"] = "Parameters without custom settings show the card default; leave a field blank or select \"Use default\" to clear a custom setting.",
    ["空字符串"] = "Empty string",
    ["循环引用"] = "Circular reference",
    ["空表"] = "Empty table",
    ["字段："] = "Fields: ",
    ["分组"] = "Group",
    ["字段"] = "Field",
    ["值"] = "Value",
    ["基础"] = "Basic",
    ["临时"] = "Temporary",
}

Cat2.Locals.UI["："] = ":"
Cat2.Locals.UI["0至3星神像"] = "Idol 0-3 CP"
Cat2.Locals.UI["0至4星神像"] = "Idol 0-4 CP"
Cat2.Locals.UI["4至5星神像"] = "Idol 4-5 CP"
Cat2.Locals.UI["5星神像"] = "Idol 5 CP"
Cat2.Locals.UI["|cFF0070DD怒气图腾|r"] = "|cFF0070DDRage Totem|r"
Cat2.Locals.UI["|cFF0070DD星火图腾|r"] = "|cFF0070DDStarfire Totem|r"
Cat2.Locals.UI["|cFF0070DD腐根图腾|r"] = "|cFF0070DDRotten Root Totem|r"
Cat2.Locals.UI["|cFF0070DD腐潮图腾|r"] = "|cFF0070DDRot Tide Totem|r"
Cat2.Locals.UI["|cFF9D38C8余震图腾|r"] = "|cFF9D38C8Aftershock Totem|r"
Cat2.Locals.UI["|cFF9D38C8召雷图腾|r"] = "|cFF9D38C8Thunder Totem|r"
Cat2.Locals.UI["|cFF9D38C8平衡神像|r"] = "|cFF9D38C8Balance Idol|r"
Cat2.Locals.UI["|cFF9D38C8月牙神像|r"] = "|cFF9D38C8Crescent Idol|r"
Cat2.Locals.UI["|cFF9D38C8潮汐神像|r"] = "|cFF9D38C8Tidal Idol|r"
Cat2.Locals.UI["|cFF9D38C8破碎大地图腾|r"] = "|cFF9D38C8Shattered Earth Totem|r"
Cat2.Locals.UI["|cFF9D38C8裂石图腾|r"] = "|cFF9D38C8Split Stone Totem|r"
Cat2.Locals.UI["|cFF9D38C8裂雷图腾|r"] = "|cFF9D38C8Split Thunder Totem|r"
Cat2.Locals.UI["|cFF9D38C8酸蚀神像|r"] = "|cFF9D38C8Corrosive Idol|r"
Cat2.Locals.UI["主技能冷却阈值"] = "Main Skill Cooldown Threshold"
Cat2.Locals.UI["人数阈值"] = "Enemy Count Threshold"
Cat2.Locals.UI["低血量圣契"] = "Low Health Relic"
Cat2.Locals.UI["使用怒气"] = "Rage Used"
Cat2.Locals.UI["保险蓝量"] = "Safe Mana"
Cat2.Locals.UI["停止触发"] = "Stop Threshold"
Cat2.Locals.UI["剩余时间"] = "Remaining Time"
Cat2.Locals.UI["召回距离"] = "Recall Distance"
Cat2.Locals.UI["周围敌人数量"] = "Nearby Enemy Count"
Cat2.Locals.UI["图腾名称"] = "Totem Name"
Cat2.Locals.UI["宠物最低生命值"] = "Pet Min Health"
Cat2.Locals.UI["宠物法力值"] = "Pet Mana"
Cat2.Locals.UI["宠物生命值"] = "Pet Health"
Cat2.Locals.UI["射击阈值"] = "Shot Threshold"
Cat2.Locals.UI["常规圣契"] = "Regular Relic"
Cat2.Locals.UI["怒气上限"] = "Max Rage"
Cat2.Locals.UI["怒气阈值"] = "Rage Threshold"
Cat2.Locals.UI["打断技能名"] = "Interrupt Spell Name"
Cat2.Locals.UI["扫描距离"] = "Scan Range"
Cat2.Locals.UI["技能等级"] = "Spell Rank"
Cat2.Locals.UI["撕咬保留怒气"] = "Rage Kept for Bite"
Cat2.Locals.UI["敌人数阈值"] = "Enemy Threshold"
Cat2.Locals.UI["施法等级"] = "Cast Rank"
Cat2.Locals.UI["普攻剩余时间"] = "Remaining Swing Time"
Cat2.Locals.UI["最低怒气"] = "Min Rage"
Cat2.Locals.UI["最低蓝量"] = "Min Mana"
Cat2.Locals.UI["最低血量"] = "Min Health"
Cat2.Locals.UI["最大等级"] = "Max Rank"
Cat2.Locals.UI["最小等级"] = "Min Rank"
Cat2.Locals.UI["最终审判圣契"] = "Final Judgment Relic"
Cat2.Locals.UI["最高怒气"] = "Max Rage"
Cat2.Locals.UI["最高能量"] = "Max Energy"
Cat2.Locals.UI["永恒之塔圣契"] = "Eternal Tower Relic"
Cat2.Locals.UI["点燃每跳伤害阈值"] = "Ignite Per-Tick Damage Threshold"
Cat2.Locals.UI["热忱圣契"] = "Ardent Relic"
Cat2.Locals.UI["热情圣契"] = "Passion Relic"
Cat2.Locals.UI["熊形态神像"] = "Bear Form Idol"
Cat2.Locals.UI["狂热剩余时间"] = "Frenzy Remaining Time"
Cat2.Locals.UI["猎豹形态神像"] = "Cat Form Idol"
Cat2.Locals.UI["猛虎保护时间"] = "Tiger's Protection Time"
Cat2.Locals.UI["目标最低血量"] = "Target Min Health"
Cat2.Locals.UI["神像名称"] = "Idol Name"
Cat2.Locals.UI["神圣领域圣契"] = "Holy Domain Relic"
Cat2.Locals.UI["续杯时间"] = "Refresh Window"
Cat2.Locals.UI["聊天窗口"] = "Chat Window"
Cat2.Locals.UI["能量上限"] = "Max Energy"
Cat2.Locals.UI["能量阈值"] = "Energy Threshold"
Cat2.Locals.UI["血腥等待"] = "Bloody Wait"
Cat2.Locals.UI["触发仇恨"] = "Trigger Threat"
Cat2.Locals.UI["触发生命"] = "Trigger Health"
Cat2.Locals.UI["触发能量"] = "Trigger Energy"
Cat2.Locals.UI["触发蓝量"] = "Trigger Mana"
Cat2.Locals.UI["触发血量"] = "Trigger Health Percent"
Cat2.Locals.UI["锁敌距离"] = "Target Lock Range"
Cat2.Locals.UI["鱼饵名称"] = "Bait Item Name"
Cat2.Locals.UI["%"] = "%"
Cat2.Locals.UI["个"] = " enemies"
Cat2.Locals.UI["人"] = " players"
Cat2.Locals.UI["伤害"] = " damage"
Cat2.Locals.UI["怒气"] = " rage"
Cat2.Locals.UI["码"] = " yd"
Cat2.Locals.UI["秒"] = " sec"
Cat2.Locals.UI["级"] = ""
Cat2.Locals.UI["能量"] = " energy"

Cat2.Locals.UI["|cffff8000当前UnitXP模块版本不支持！|r"] = "|cffff8000This UnitXP module version is not supported!|r"
Cat2.Locals.UI["|cffff8000当前UnitXP模组版本不支持！|r"] = "|cffff8000This UnitXP module version is not supported!|r"
Cat2.Locals.UI["|cffff8000当前UnitXP版本不支持成串锁敌，已降级为普通8码外锁敌。|r"] = "|cffff8000This UnitXP version does not support chained target locking; downgraded to normal 8-yard target locking.|r"
Cat2.Locals.UI["|cffffb347治疗技能缺少 |cffb87ff0[治疗指向]|r |cffffb347的被动卡|r"] = "|cffffb347Healing skill is missing the |cffb87ff0[Healing Target]|r |cffffb347passive card|r"
Cat2.Locals.UI["|cffffb347驱散技能缺少 |cffb87ff0[治疗指向]|r |cffffb347的被动卡|r"] = "|cffffb347Dispel skill is missing the |cffb87ff0[Healing Target]|r |cffffb347passive card|r"
Cat2.Locals.UI["扫击续杯失败，重置计时！"] = "Rake refresh failed, resetting timer!"
Cat2.Locals.UI["凶猛撕咬（紧急续杯）"] = "Ferocious Bite (Emergency Refill)"
Cat2.Locals.UI["撕扯续杯失败，重置计时！"] = "Rip refresh failed, resetting timer!"
Cat2.Locals.UI[" 张。"] = " card(s)."
Cat2.Locals.UI["Cat2 主界面上一次创建未完成，请 /reload 后重试"] = "Cat2 main window creation was not completed last time; please /reload and try again."
Cat2.Locals.UI["Cat|cffff291a2|r 喵！"] = "Cat|cffff291a2|r meow!"
Cat2.Locals.UI["」执行完成，失败卡片 "] = "」 completed, failed cards: "
Cat2.Locals.UI["」执行异常："] = "」 execution error: "
Cat2.Locals.UI["个人爱好制作，完全免费，不作商业化用途；允许在本插件基础上修改或扩展。"] = "Made as a hobby, completely free, not for commercial use; modifications and extensions are allowed."
Cat2.Locals.UI["全部图标"] = "All Icons"
Cat2.Locals.UI["占位宏已创建，暂时无法确认读取结果；不会继续新增，请 /reload 后重试。"] = "Placeholder macro created, but the read result could not be confirmed; no more will be added, please /reload and retry."
Cat2.Locals.UI["发布者："] = "Publisher: "
Cat2.Locals.UI["对象扫描、GUID选敌等功能会受限。请确认模组已随客户端加载。"] = "Object scanning, GUID target selection, etc. will be limited. Please confirm the module is loaded with the client."
Cat2.Locals.UI["已存在专用占位宏，但暂时无法确认其内容；已停止重复创建，请检查宏内容后重试。"] = "A dedicated placeholder macro already exists, but its content could not be confirmed; stopped creating duplicates, please check the macro and retry."
Cat2.Locals.UI["已检测到模组，但无法确认版本支持情况。"] = "Module detected, but version support could not be confirmed."
Cat2.Locals.UI["当前检测基线：1.5及以上，并可读取单位GUID和技能信息。旧版本标为待确认，并非认定不能使用。"] = "Current detection baseline: 1.5 or higher, and able to read unit GUIDs and spell info. Older versions are marked as unconfirmed, not deemed unusable."
Cat2.Locals.UI["当前检测基线：4.0.0及以上，并具备施法状态、移动状态及施法队列配置接口。旧版按部分支持显示。"] = "Current detection baseline: 4.0.0 or higher, with cast state, movement state and spell queue configuration interfaces. Older versions display as partial support."
Cat2.Locals.UI["感谢所有参与经验分享、脚本制作、设计与测试的朋友。"] = "Thanks to all friends who contributed experience, scripting, design and testing."
Cat2.Locals.UI["成串锁敌版本门槛：2026-07-20（编译时间戳1784505600）。自动扫描选敌还需要SuperWoW。"] = "Chained target locking version threshold: 2026-07-20 (compile timestamp 1784505600). Auto-scan target selection also requires SuperWoW."
Cat2.Locals.UI["拖动到技能条"] = "Drag to action bar"
Cat2.Locals.UI["接口受限"] = "Interfaces limited"
Cat2.Locals.UI["接口存在，但无法读取有效编译版本，不能确认成串锁敌支持。"] = "Interface exists, but a valid compile version could not be read; chained target locking support cannot be confirmed."
Cat2.Locals.UI["接口存在，但版本读取失败或格式无法识别。"] = "Interface exists, but version read failed or format could not be recognized."
Cat2.Locals.UI["插件版本："] = "Addon version: "
Cat2.Locals.UI["支持"] = "Supported"
Cat2.Locals.UI["施法队列控制和部分战斗事件功能受限。请确认模组已加载。"] = "Spell queue control and some combat event features are limited. Please confirm the module is loaded."
Cat2.Locals.UI["施法队列配置未能完整读取。"] = "Spell queue configuration could not be fully read."
Cat2.Locals.UI["无法创建专用占位宏，请预留一个角色宏位置后重试。"] = "Unable to create the dedicated placeholder macro; please free a character macro slot and retry."
Cat2.Locals.UI["无法更新功能宏说明："] = "Unable to update function macro description: "
Cat2.Locals.UI["旧版可使用兼容路径，部分施法状态与战斗事件能力受限。"] = "Older versions can use the compatibility path; some cast state and combat event abilities are limited."
Cat2.Locals.UI["旧版待确认"] = "Old version unconfirmed"
Cat2.Locals.UI["未检测到"] = "Not detected"
Cat2.Locals.UI["未能确认单位GUID或技能信息接口，部分卡片可能受限。"] = "Unit GUID or spell info interface could not be confirmed; some cards may be limited."
Cat2.Locals.UI["未读取到"] = "Not read"
Cat2.Locals.UI["检测版本："] = "Detected version: "
Cat2.Locals.UI["此图标未绑定有效配置，请从Cat2配置旁重新拖入动作条。"] = "This icon is not bound to a valid profile; please drag it back from the Cat2 profile onto the action bar."
Cat2.Locals.UI["测距与视野接口可用，编译版本满足成串锁敌门槛；方位能力按版本识别。"] = "Range and line-of-sight interfaces available; compile version meets the chained target locking threshold; facing ability recognized by version."
Cat2.Locals.UI["测距与视野接口可用；8码成串锁敌会降级为普通8码外锁敌。"] = "Range and line-of-sight interfaces available; 8-yard chained target locking degrades to normal 8-yard outward target locking."
Cat2.Locals.UI["点击或按动作条快捷键执行此Cat2配置。"] = "Click or press the action bar hotkey to run this Cat2 profile."
Cat2.Locals.UI["版本低于当前检测基线，建议更新后使用。"] = "Version is below the current detection baseline; update recommended."
Cat2.Locals.UI["版本未知"] = "Version unknown"
Cat2.Locals.UI["版本满足基线，但缺少施法状态或移动状态接口。"] = "Version meets the baseline, but cast state or movement state interface is missing."
Cat2.Locals.UI["版本满足检测基线，单位GUID与技能信息接口可用。"] = "Version meets the detection baseline; unit GUID and spell info interfaces are available."
Cat2.Locals.UI["版本满足检测基线，施法状态、移动与队列配置接口可用。"] = "Version meets the detection baseline; cast state, movement and queue configuration interfaces are available."
Cat2.Locals.UI["版权与使用说明"] = "Copyright and usage"
Cat2.Locals.UI["精确距离、方位判断及成串锁敌受限。请确认模组已加载。"] = "Precise range, facing judgment and chained target locking are limited. Please confirm the module is loaded."
Cat2.Locals.UI["编译时间戳 "] = "Compile timestamp "
Cat2.Locals.UI["自动选择"] = "Auto select"
Cat2.Locals.UI["请从Cat2重新拖入有效配置。"] = "Please drag a valid profile from Cat2 again."
Cat2.Locals.UI["距离或视野接口未通过只读检测。"] = "Range or line-of-sight interface failed the read-only check."
Cat2.Locals.UI["选择图标"] = "Choose Icon"
Cat2.Locals.UI["选择配置图标"] = "Choose profile icon"
Cat2.Locals.UI["通过卡片自由组合各职业的一键宏执行流程。"] = "Freely combine cards to build one-button macro execution flows for every class."
Cat2.Locals.UI["逻辑"] = "Logic"
Cat2.Locals.UI["部分支持"] = "Partial support"
Cat2.Locals.UI["配置图标"] = "Profile Icon"
Cat2.Locals.UI["配置已删除"] = "Profile deleted"
Cat2.Locals.UI["颜色表示Cat2检测基线与接口状态，不代表是否为最新版本。"] = "Colors indicate Cat2 detection baseline and interface status, not whether it is the latest version."
Cat2.Locals.UI["版本："] = "Version: "
Cat2.Locals.Spells = {
    ["攻击"] = "Attack",
    ["致死打击"] = "Mortal Strike",
    ["压制"] = "Overpower",
    ["复仇"] = "Revenge",
    ["盾牌猛击"] = "Shield Slam",
    ["盾牌格挡"] = "Shield Block",
    ["盾击"] = "Shield Bash",
    ["盾墙"] = "Shield Wall",
    ["破釜沉舟"] = "Last Stand",
    ["震荡猛击"] = "Concussion Blow",
    ["斩杀"] = "Execute",
    ["嗜血"] = "Bloodthirst",
    ["冲锋"] = "Charge",
    ["拦截"] = "Intercept",
    ["战斗姿态"] = "Battle Stance",
    ["防御姿态"] = "Defensive Stance",
    ["狂暴姿态"] = "Berserker Stance",
    ["战斗怒吼"] = "Battle Shout",
    ["挫志怒吼"] = "Demoralizing Shout",
    ["断筋"] = "Hamstring",
    ["撕裂"] = "Rend",
    ["破甲攻击"] = "Sunder Armor",
    ["雷霆一击"] = "Thunder Clap",
    ["旋风斩"] = "Whirlwind",
    ["英雄打击"] = "Heroic Strike",
    ["猛击"] = "Slam",
    ["鲁莽"] = "Recklessness",
    ["死亡之愿"] = "Death Wish",
    ["血性狂怒"] = "Bloodrage",
    ["血性狂暴"] = "Bloodrage",
    ["横扫攻击"] = "Sweeping Strikes",
    ["特效打击"] = "Special Strike",
    ["拳击"] = "Pummel",
    ["顺劈斩"] = "Cleave",
    ["狂暴之怒"] = "Berserker Rage",
    ["十字军打击"] = "Crusader Strike",
    ["神圣打击"] = "Holy Strike",
    ["奉献"] = "Consecration",
    ["圣洁光环"] = "Sanctity Aura",
    ["愤怒之锤"] = "Hammer of Wrath",
    ["驱邪术"] = "Exorcism",
    ["神圣愤怒"] = "Holy Wrath",
    ["忏悔"] = "Repentance",
    ["光明圣印"] = "Seal of Light",
    ["智慧圣印"] = "Seal of Wisdom",
    ["正义圣印"] = "Seal of Righteousness",
    ["命令圣印"] = "Seal of Command",
    ["十字军圣印"] = "Seal of the Crusader",
    ["圣光术"] = "Holy Light",
    ["圣光闪现"] = "Flash of Light",
    ["圣疗术"] = "Lay on Hands",
    ["神圣震击"] = "Holy Shock",
    ["专注光环"] = "Concentration Aura",
    ["虔诚光环"] = "Devotion Aura",
    ["正义之怒"] = "Righteous Fury",
    ["神圣盾击"] = "Holy Shield",
    ["保护祝福"] = "Hand of Protection",
    ["圣盾术"] = "Divine Shield",
    ["闪电箭"] = "Lightning Bolt",
    ["闪电链"] = "Chain Lightning",
    ["熔岩猛击"] = "Lava Burst",
    ["地震术"] = "Earthquake",
    ["大地震击"] = "Earth Shock",
    ["烈焰震击"] = "Flame Shock",
    ["冰霜震击"] = "Frost Shock",
    ["闪电之盾"] = "Lightning Shield",
    ["大地之盾"] = "Earth Shield",
    ["水之盾"] = "Water Shield",
    ["治疗波"] = "Healing Wave",
    ["次级治疗波"] = "Lesser Healing Wave",
    ["治疗链"] = "Chain Heal",
    ["战栗图腾"] = "Tremor Totem",
    ["根基图腾"] = "Grounding Totem",
    ["祛病图腾"] = "Disease Cleansing Totem",
    ["净化图腾"] = "Poison Cleansing Totem",
    ["宁静之风图腾"] = "Tranquil Air Totem",
    ["风怒图腾"] = "Windfury Totem",
    ["力量大地图腾"] = "Strength of Earth Totem",
    ["空气之优雅图腾"] = "Grace of Air Totem",
    ["火焰新星图腾"] = "Fire Nova Totem",
    ["灼热图腾"] = "Searing Totem",
    ["岩浆图腾"] = "Magma Totem",
    ["风暴打击"] = "Stormstrike",
    ["石爪图腾"] = "Stoneclaw Totem",
    ["地缚图腾"] = "Earthbind Totem",
    ["寒冰箭"] = "Frostbolt",
    ["火球术"] = "Fireball",
    ["炎爆术"] = "Pyroblast",
    ["灼烧"] = "Scorch",
    ["火焰冲击"] = "Fire Blast",
    ["冰霜新星"] = "Frost Nova",
    ["冰锥术"] = "Cone of Cold",
    ["唤醒"] = "Evocation",
    ["气定神闲"] = "Presence of Mind",
    ["奥术强化"] = "Arcane Power",
    ["法术反制"] = "Counterspell",
    ["法力护盾"] = "Mana Shield",
    ["寒冰护体"] = "Ice Barrier",
    ["寒冰屏障"] = "Ice Block",
    ["冰甲术"] = "Ice Armor",
    ["霜甲术"] = "Frost Armor",
    ["魔甲术"] = "Mage Armor",
    ["防护火焰结界"] = "Fire Ward",
    ["防护冰霜结界"] = "Frost Ward",
    ["潜行"] = "Stealth",
    ["影袭"] = "Sinister Strike",
    ["背刺"] = "Backstab",
    ["剔骨"] = "Eviscerate",
    ["切割"] = "Slice and Dice",
    ["破甲"] = "Expose Armor",
    ["肾击"] = "Kidney Shot",
    ["割裂"] = "Rupture",
    ["踢击"] = "Kick",
    ["闪避"] = "Evasion",
    ["疾跑"] = "Sprint",
    ["消失"] = "Vanish",
    ["剑刃乱舞"] = "Blade Flurry",
    ["冲动"] = "Adrenaline Rush",
    ["偷袭"] = "Cheap Shot",
    ["伏击"] = "Ambush",
    ["盲目"] = "Blind",
    ["闷棍"] = "Sap",
    ["锁喉"] = "Garrote",
    ["毁伤"] = "Mutilate",
    ["毒刃"] = "Shiv",
    ["冷血"] = "Cold Blood",
    ["预谋"] = "Preparation",
    ["出血"] = "Hemorrhage",
    ["鬼魅攻击"] = "Ghostly Strike",
    ["致命投掷"] = "Deadly Throw",
    ["治疗术"] = "Heal",
    ["强效治疗术"] = "Greater Heal",
    ["次级治疗术"] = "Lesser Heal",
    ["闪光治疗"] = "Flash Heal",
    ["快速治疗"] = "Flash Heal",
    ["恢复"] = "Renew",
    ["真言术：盾"] = "Power Word: Shield",
    ["心灵震爆"] = "Mind Blast",
    ["暗言术：痛"] = "Shadow Word: Pain",
    ["精神鞭笞"] = "Mind Flay",
    ["惩击"] = "Smite",
    ["神圣之火"] = "Holy Fire",
    ["渐隐术"] = "Fade",
    ["心灵专注"] = "Inner Focus",
    ["沉默"] = "Silence",
    ["吸血鬼的拥抱"] = "Vampiric Embrace",
    ["暗影形态"] = "Shadowform",
    ["治疗祷言"] = "Prayer of Healing",
    ["神圣新星"] = "Holy Nova",
    ["自动射击"] = "Auto Shot",
    ["奥术射击"] = "Arcane Shot",
    ["多重射击"] = "Multi-Shot",
    ["瞄准射击"] = "Aimed Shot",
    ["毒蛇钉刺"] = "Serpent Sting",
    ["蝰蛇钉刺"] = "Viper Sting",
    ["毒蝎钉刺"] = "Scorpid Sting",
    ["猎人印记"] = "Hunter's Mark",
    ["震荡射击"] = "Concussive Shot",
    ["猛禽一击"] = "Raptor Strike",
    ["猫鼬撕咬"] = "Mongoose Bite",
    ["摔绊"] = "Wing Clip",
    ["急速射击"] = "Rapid Fire",
    ["强击光环"] = "Trueshot Aura",
    ["驱散射击"] = "Scatter Shot",
    ["冰冻陷阱"] = "Frost Trap",
    ["献祭陷阱"] = "Immolation Trap",
    ["爆炸陷阱"] = "Explosive Trap",
    ["杀戮命令"] = "Kill Command",
    ["威吓"] = "Intimidation",
    ["野性怒火"] = "Bestial Wrath",
    ["痛苦诅咒"] = "Curse of Agony",
    ["腐蚀术"] = "Corruption",
    ["暗影箭"] = "Shadow Bolt",
    ["献祭"] = "Immolate",
    ["燃烧"] = "Conflagrate",
    ["生命分流"] = "Life Tap",
    ["厄运诅咒"] = "Curse of Doom",
    ["元素诅咒"] = "Curse of the Elements",
    ["暗影诅咒"] = "Curse of Shadow",
    ["虚弱诅咒"] = "Curse of Weakness",
    ["语言诅咒"] = "Curse of Tongues",
    ["疲劳诅咒"] = "Curse of Exhaustion",
    ["鲁莽诅咒"] = "Curse of Recklessness",
    ["吸取生命"] = "Drain Life",
    ["吸取法术"] = "Drain Mana",
    ["吸取灵魂"] = "Drain Soul",
    ["生命虹吸"] = "Siphon Life",
    ["恶魔支配"] = "Fel Domination",
    ["灵魂之火"] = "Soul Fire",
    ["暗影灼烧"] = "Shadowburn",
    ["佯攻"] = "Feint",
    ["冰柱"] = "Ice Lance",
    ["切碎"] = "Slice",
    ["割伤"] = "Lacerate",
    ["启发"] = "Enlightenment",
    ["审判"] = "Judgement",
    ["愈合"] = "Regrowth",
    ["感知"] = "Perception",
    ["愤怒"] = "Wrath",
    ["撕扯"] = "Rip",
    ["撕碎"] = "Shred",
    ["槌击"] = "Maul",
    ["毒伤"] = "Envenom",
    ["爪击"] = "Claw",
    ["狂怒"] = "Frenzy",
    ["狂暴"] = "Berserk",
    ["畏缩"] = "Cower",
    ["突袭"] = "Dash",
    ["绞喉"] = "Garrote",
    ["胁迫"] = "Intimidation",
    ["脚踢"] = "Kick",
    ["虫群"] = "Insect Swarm",
    ["还击"] = "Retaliation",
    ["重整"] = "Reshift",
    ["回春术"] = "Rejuvenation",
    ["星火术"] = "Starfire",
    ["月火术"] = "Moonfire",
    ["树皮术"] = "Barkskin",
    ["熊形态"] = "Bear Form",
    ["魔爆术"] = "Arcane Explosion",
    ["伺机待发"] = "Preparation",
    ["元素掌握"] = "Elemental Mastery",
    ["冰封武器"] = "Frostbrand Weapon",
    ["冰霜陷阱"] = "Frost Trap",
    ["凶猛撕咬"] = "Ferocious Bite",
    ["制裁之锤"] = "Hammer of Justice",
    ["吸取法力"] = "Drain Mana",
    ["奥术涌动"] = "Arcane Surge",
    ["奥术溃裂"] = "Arcane Fracture",
    ["奥术飞弹"] = "Arcane Missiles",
    ["孤狼守护"] = "Aspect of the Lone Wolf",
    ["巨熊形态"] = "Dire Bear Form",
    ["心灵之火"] = "Inner Fire",
    ["抗寒图腾"] = "Frost Resistance Totem",
    ["抗火图腾"] = "Fire Resistance Totem",
    ["挫志咆哮"] = "Demoralizing Roar",
    ["暗影收割"] = "Shadow Harvest",
    ["施放 [暗影收割]"] = "Cast Shadow Harvest",
    ["，持续时间"] = ", duration",
    ["重新计算DOT持续时间"] = ", recalculating DOT durations",
    ["枭兽形态"] = "Moonkin Form",
    ["死亡标记"] = "Mark for Death",
    ["水之护盾"] = "Water Shield",
    ["治疗之触"] = "Healing Touch",
    ["清毒图腾"] = "Poison Cleansing Totem",
    ["火舌图腾"] = "Flametongue Totem",
    ["火舌武器"] = "Flametongue Weapon",
    ["灵猴守护"] = "Aspect of the Monkey",
    ["灵魂链接"] = "Spirit Link",
    ["灼热之痛"] = "Searing Pain",
    ["熔岩图腾"] = "Magma Totem",
    ["熔岩爆裂"] = "Lava Burst",
    ["狂野怒火"] = "Bestial Wrath",
    ["猎豹守护"] = "Aspect of the Cheetah",
    ["猎豹形态"] = "Cat Form",
    ["猛虎之怒"] = "Tiger's Fury",
    ["生命通道"] = "Health Funnel",
    ["石化武器"] = "Rockbiter Weapon",
    ["石肤图腾"] = "Stoneskin Totem",
    ["神圣之盾"] = "Divine Shield",
    ["稳固射击"] = "Steady Shot",
    ["精灵之火"] = "Faerie Fire",
    ["绝望祷言"] = "Desperate Prayer",
    ["英勇打击"] = "Heroic Strike",
    ["蝰蛇守护"] = "Aspect of the Viper",
    ["豹群守护"] = "Aspect of the Pack",
    ["超凡入圣"] = "Transcendence",
    ["迅捷治愈"] = "Swiftmend",
    ["邪恶攻击"] = "Sinister Strike",
    ["野兽守护"] = "Aspect of the Beast",
    ["野性守护"] = "Aspect of the Wild",
    ["闪电打击"] = "Lightning Strike",
    ["雄鹰守护"] = "Aspect of the Hawk",
    ["风墙图腾"] = "Windwall Totem",
    ["风怒武器"] = "Windfury Weapon",
    ["大地之力图腾"] = "Strength of Earth Totem",
    ["治疗之泉图腾"] = "Healing Stream Totem",
    ["法力之泉图腾"] = "Mana Spring Totem",
    ["生命之树形态"] = "Tree of Life Form",
    ["自然抗性图腾"] = "Nature Resistance Totem",
    ["风之优雅图腾"] = "Grace of Air Totem",
    ["树皮术（野性）"] = "Barkskin (Feral)",
    ["精灵之火（野性）"] = "Faerie Fire (Feral)",
    ["兴奋"] = "Adrenaline Rush",
    ["扫击"] = "Rake",
    ["挥击"] = "Swipe",
    ["毁灭"] = "Ravage",
    ["责罚"] = "Chastise",
    ["保护之手"] = "Hand of Protection",
    ["公正圣印"] = "Seal of Justice",
    ["双刃毒袭"] = "Noxious Assault",
    ["正义壁垒"] = "Bulwark of the Righteous",
    ["法力通道"] = "Mana Funnel",
    ["痛苦尖刺"] = "Pain Spike",
    ["超越之力"] = "Power Overwhelming",
    ["野蛮撕咬"] = "Savage Bite",
}

Cat2.Locals.Items = {
    ["特效治疗药水"] = "Major Healing Potion",
    ["特效法力药水"] = "Major Mana Potion",
    ["极效治疗石"] = "Healthstone",
    ["鞭根草"] = "Whipper Root Tuber",
    ["草药茶"] = "Herbal Tea",
    ["赞达拉英雄茶"] = "Juju Flurry",
    ["强效怒气药水"] = "Great Rage Potion",
    ["加速药水"] = "Haste Potion",
    ["刺络茶"] = "Thistle Tea",
    ["法力翡翠"] = "Mana Emerald",
    ["灵魂碎片"] = "Soul Shard",
    ["鞭根块茎"] = "Whipper Root Tuber",
    ["法力红宝石"] = "Mana Ruby",
    ["法力黄水晶"] = "Mana Citrine",
    ["特效治疗药膏"] = "Major Healing Salve",
    ["特效活力药水"] = "Major Rejuvenation Potion",
    ["诺达纳尔草药茶"] = "Nordanaar Herbal Tea",
    ["糖水茶"] = "Tea with Sugar",
    ["菊花茶"] = "Thistle Tea",
    ["魂能之速"] = "Juju Flurry",
    ["特效治疗石"] = "Major Healthstone",
    ["起源皮盔"] = "Genesis Helmet",
    ["起源肩垫"] = "Genesis Shoulderpads",
    ["起源长袍"] = "Genesis Raiments",
    ["起源短裤"] = "Genesis Pants",
    ["起源便靴"] = "Genesis Treads",
    ["梦游者头饰"] = "Dreamwalker Headpiece",
    ["梦游者肩饰"] = "Dreamwalker Spaulders",
    ["梦游者外套"] = "Dreamwalker Tunic",
    ["梦游者束带"] = "Dreamwalker Belt",
    ["梦游者护手"] = "Dreamwalker Handguards",
    ["梦游者护腿"] = "Dreamwalker Legguards",
    ["梦游者长靴"] = "Dreamwalker Boots",
    ["梦游者腕甲"] = "Dreamwalker Bracers",
    ["梦游者之戒"] = "Ring of the Dreamwalker",
    ["兄弟会头盔"] = "Helmet of the Brotherhood",
    ["兄弟会项链"] = "Choker of the Brotherhood",
    ["兄弟会肩甲"] = "Shoulderguards of the Brotherhood",
    ["兄弟会胸甲"] = "Chestguard of the Brotherhood",
    ["兄弟会护腿"] = "Legguards of the Brotherhood",
    ["兄弟会胫甲"] = "Greaves of the Brotherhood",
    ["凶猛神像"] = "Idol of Ferocity",
    ["蛮兽神像"] = "Idol of Brutality",
    ["休眠腐化之眼"] = "Eye of Dormant Corruption",
}

Cat2.Locals.Buffs = {
    ["鲁莽"] = "Recklessness",
    ["死亡之愿"] = "Death Wish",
    ["血性狂怒"] = "Bloodrage",
    ["盾牌格挡"] = "Shield Block",
    ["盾墙"] = "Shield Wall",
    ["破釜沉舟"] = "Last Stand",
    ["横扫攻击"] = "Sweeping Strikes",
    ["战斗怒吼"] = "Battle Shout",
    ["挫志怒吼"] = "Demoralizing Shout",
    ["撕裂"] = "Rend",
    ["断筋"] = "Hamstring",
    ["真言术：盾"] = "Power Word: Shield",
    ["恢复"] = "Renew",
    ["暗言术：痛"] = "Shadow Word: Pain",
    ["痛苦诅咒"] = "Curse of Agony",
    ["腐蚀术"] = "Corruption",
    ["献祭"] = "Immolate",
    ["乱舞"] = "Flurry",
    ["启发"] = "Enlightenment",
    ["夜至"] = "Nightfall",
    ["愈合"] = "Regrowth",
    ["撕扯"] = "Rip",
    ["日蚀"] = "Solar Eclipse",
    ["月蚀"] = "Lunar Eclipse",
    ["毒伤"] = "Envenom",
    ["自律"] = "Forbearance",
    ["虫群"] = "Insect Swarm",
    ["回春术"] = "Rejuvenation",
    ["放逐术"] = "Banish",
    ["月火术"] = "Moonfire",
    ["熊形态"] = "Bear Form",
    ["冰冷血脉"] = "Icy Veins",
    ["冰霜速冻"] = "Frost Freeze",
    ["奥术光辉"] = "Arcane Brilliance",
    ["奥术智慧"] = "Arcane Intellect",
    ["奥术溃裂"] = "Arcane Fracture",
    ["孤狼守护"] = "Aspect of the Lone Wolf",
    ["巨熊形态"] = "Dire Bear Form",
    ["心灵之火"] = "Inner Fire",
    ["挫志咆哮"] = "Demoralizing Roar",
    ["智慧审判"] = "Judgement of Wisdom",
    ["智慧祝福"] = "Blessing of Wisdom",
    ["枭兽形态"] = "Moonkin Form",
    ["水之护盾"] = "Water Shield",
    ["法术连击"] = "Hot Streak",
    ["火焰易伤"] = "Fire Vulnerability",
    ["灵猴守护"] = "Aspect of the Monkey",
    ["猎豹守护"] = "Aspect of the Cheetah",
    ["猎豹形态"] = "Cat Form",
    ["神圣之灵"] = "Divine Spirit",
    ["精灵之火"] = "Faerie Fire",
    ["精神祷言"] = "Prayer of Spirit",
    ["节能施法"] = "Clearcasting",
    ["荷枪实弹"] = "Lock and Load",
    ["虚弱灵魂"] = "Weakened Soul",
    ["蝰蛇守护"] = "Aspect of the Viper",
    ["豹群守护"] = "Aspect of the Pack",
    ["野兽守护"] = "Aspect of the Beast",
    ["野性守护"] = "Aspect of the Wild",
    ["雄鹰守护"] = "Aspect of the Hawk",
    ["十字军审判"] = "Judgement of the Crusader",
    ["强化盾牌猛击"] = "Improved Shield Slam",
    ["生命之树形态"] = "Tree of Life Form",
    ["精灵之火（野性）"] = "Faerie Fire (Feral)",
    ["扫击"] = "Rake",
    ["血之狂暴"] = "Enrage",
    ["血袭"] = "Pounce Bleed",
    ["保护之手"] = "Hand of Protection",
    ["光明审判"] = "Judgement of Light",
    ["公正圣印"] = "Seal of Justice",
    ["拯救祝福"] = "Blessing of Salvation",
    ["正义审判"] = "Judgement of Justice",
    ["强效拯救祝福"] = "Greater Blessing of Salvation",
    ["强效智慧祝福"] = "Greater Blessing of Wisdom",
    ["武器姿态"] = "Battle Stance",
    ["血腥气息"] = "Taste for Blood",
    ["剧毒弹药"] = "Poisonous Ammunition",
    ["爆炸弹药"] = "Explosive Ammunition",
    ["魔力弹药"] = "Enchanted Ammunition",
    -- TODO 自定义服务器名
    ["昼至"] = "Natural Boon",
    -- TODO 自定义服务器名
    ["利用弱点"] = "Mark for Death",
}

Cat2.Locals.Cards = {
    ["common_auto_attack"] = { name = "Auto Attack", description = "Attack target with auto-attack", details = "Perform auto attack when target exists." },
    ["common_auto_attack_pet"] = { name = "Pet Attack", description = "Command pet to attack target", details = "Send pet to attack target." },
    ["common_auto_pick"] = { name = "Auto Loot", description = "Automatically loot items", details = "Automatically loot items from corpses." },
    ["common_auto_target"] = { name = "Auto Target", description = "Select nearest target", details = "Automatically target nearest enemy." },
    ["common_auto_target_distant"] = { name = "Distant Target", description = "Select distant target", details = "Select target at distance." },
    ["common_auto_trinket_upper"] = { name = "Upper Trinket", description = "Use top trinket", details = "Use equipped upper trinket." },
    ["common_auto_trinket_lower"] = { name = "Lower Trinket", description = "Use bottom trinket", details = "Use equipped lower trinket." },
    ["warrior_mortal_strike"] = { name = "Mortal Strike", description = "Cast Mortal Strike when ready", details = "Cast Mortal Strike when cooldown is ready and has enough rage." },
    ["warrior_charge"] = { name = "Charge", description = "Cast Charge", details = "Cast Charge in combat start." },
    ["warrior_execute"] = { name = "Execute", description = "Cast Execute on low health target", details = "Execute target when health is below 20%." },
    ["warrior_overpower"] = { name = "Overpower", description = "Cast Overpower on dodge", details = "Cast Overpower when target dodges." },
    ["warrior_bloodthirst"] = { name = "Bloodthirst", description = "Cast Bloodthirst", details = "Cast Bloodthirst when ready." },
    ["warrior_slam"] = { name = "Slam", description = "Cast Slam", details = "Cast Slam." },
    ["warrior_whirlwind"] = { name = "Whirlwind", description = "Cast Whirlwind", details = "Cast Whirlwind." },
    ["warrior_battle_stance"] = { name = "Battle Stance", description = "Switch to Battle Stance", details = "Switch stance to Battle Stance." },
    ["warrior_defensive_stance"] = { name = "Defensive Stance", description = "Switch to Defensive Stance", details = "Switch stance to Defensive Stance." },
    ["warrior_berserker_stance"] = { name = "Berserker Stance", description = "Switch to Berserker Stance", details = "Switch stance to Berserker Stance." },
    ["warrior_battle_shout"] = { name = "Battle Shout", description = "Maintain Battle Shout", details = "Cast Battle Shout when buff is missing." },
    ["warrior_demoralizing_shout"] = { name = "Demoralizing Shout", description = "Cast Demoralizing Shout", details = "Debuff enemy attack power." },
    ["warrior_thunder_clap"] = { name = "Thunder Clap", description = "Cast Thunder Clap", details = "Slow enemy attack speed." },
    ["warrior_sweeping_strikes"] = { name = "Sweeping Strikes", description = "Cast Sweeping Strikes", details = "Cleave extra targets." },
    ["warrior_rend"] = { name = "Rend", description = "Maintain Rend dot", details = "Keep Rend bleeding on target." },
    ["warrior_revenge"] = { name = "Revenge", description = "Cast Revenge", details = "Cast Revenge on block/parry/dodge." },
    ["warrior_shield_block"] = { name = "Shield Block", description = "Cast Shield Block", details = "Increase block chance." },
    ["warrior_shield_bash"] = { name = "Shield Bash", description = "Cast Shield Bash", details = "Interrupt spellcasting." },
    ["warrior_shield_wall"] = { name = "Shield Wall", description = "Cast Shield Wall", details = "Massive damage reduction." },
    ["warrior_last_stand"] = { name = "Last Stand", description = "Cast Last Stand", details = "Temporary health boost." },
    ["warrior_shield_slam"] = { name = "Shield Slam", description = "Cast Shield Slam", details = "Heavy shield damage." },
    ["warrior_concussion_blow"] = { name = "Concussion Blow", description = "Cast Concussion Blow", details = "Stun target." },
    ["warrior_bloodrage"] = { name = "Bloodrage", description = "Cast Bloodrage", details = "Generate rage." },
    ["warrior_intercept"] = { name = "Intercept", description = "Cast Intercept", details = "Charge stun enemy." },
    ["warrior_cleave"] = { name = "Cleave", description = "Cast Cleave", details = "Next swing hits two targets." },
    ["warrior_pummel"] = { name = "Pummel", description = "Cast Pummel", details = "Interrupt spellcasting in Berserker Stance." },
    ["warrior_death_wish"] = { name = "Death Wish", description = "Cast Death Wish", details = "Increase physical damage taken and dealt." },
    ["warrior_recklessness"] = { name = "Recklessness", description = "Cast Recklessness", details = "Massive critical strike chance increase." },
}

-- Additional card translations (extended English support)
Cat2.Locals.Cards["common_auto_cancel_caster_buffs"] = { name = "Auto Remove Caster Buffs", description = "Automatically removes caster buffs such as Arcane Intellect and Prayer of Spirit", details = "Automatically removes caster buffs such as Arcane Intellect and Prayer of Spirit." }
Cat2.Locals.Cards["common_auto_cancel_salvation"] = { name = "Auto Cancel Salvation", description = "Automatically cancels the Salvation buff, good for tanks", details = "Automatically cancels the Salvation buff, good for tanks." }
Cat2.Locals.Cards["common_blank_placeholder"] = { name = "Blank Placeholder", description = "No function, only used as a placeholder for window layout", details = "No function, only used as a placeholder for window layout." }
Cat2.Locals.Cards["common_pause_when_target_banished"] = { name = "Pause When Target Banished", description = "Pause the flow while the target is affected by Banish", details = "Pause the flow while the target is affected by Banish. Requires a valid target. Stops the rest of the round when executed." }
Cat2.Locals.Cards["common_racial_burst"] = { name = "Racial Burst", description = "Human-Perception, Orc-Blood Fury, Troll-Berserking", details = "Human: Perception, Orc: Blood Fury, Troll: Berserking. Checks target distance and combat state. Attempts only when the ability is usable." }
Cat2.Locals.Cards["common_trinkets_only_boss"] = { name = "Trinkets/Burst vs Bosses Only", description = "Only enable trinkets and burst against elite enemies", details = "Only enable trinkets and burst against elite enemies. Passive rule; affects the current flow while enabled." }
Cat2.Locals.Cards["common_trinkets_only_melee"] = { name = "Trinkets/Burst Melee Only", description = "Only enable trinkets and burst when close to an enemy", details = "Only enable trinkets and burst when close to an enemy. Passive rule; affects the current flow while enabled." }

Cat2.Locals.Cards["druid_barkskin"] = { name = "Barkskin", description = "Cast Barkskin when health is below 30% to reduce damage taken", details = "Cast Barkskin when health is below 30% to reduce damage taken. Checks combat state. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_barkskin_feral"] = { name = "Barkskin (Feral)", description = "Cast Barkskin when health is below 30% to reduce damage taken", details = "Cast Barkskin when health is below 30% to reduce damage taken. Checks combat state. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_bear_form"] = { name = "Bear Form", description = "Shift into and maintain Bear Form", details = "Shift into and maintain Bear Form." }
Cat2.Locals.Cards["druid_berserk"] = { name = "Berserk", description = "Cast Berserk when off cooldown and energy is below 40", details = "Cast Berserk when off cooldown and energy is below 40. Requires a valid target. Checks target distance and current resources. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_berserk_boss"] = { name = "Berserk (Bosses Only)", description = "Cast Berserk against elite enemies when energy is below 40", details = "Cast Berserk against elite enemies only when energy is below 40. Requires a valid target. Checks target distance and current resources. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_cat_form"] = { name = "Cat Form", description = "Switch to and maintain Cat Form", details = "Switch to and maintain Cat Form." }
Cat2.Locals.Cards["druid_claw"] = { name = "Claw", description = "Deal damage and gain a combo point", details = "Deal damage and gain a combo point. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_cower"] = { name = "Cower", description = "Cast Cower when off cooldown and energy is sufficient", details = "Cast Cower while in Cat Form when off cooldown and energy is at least 20. Checks current resources and spell cooldown. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_demoralizing_roar"] = { name = "Demoralizing Roar", description = "Trigger when the target lacks the demoralize debuff", details = "Trigger when the target lacks the demoralize debuff. Requires a valid target. Checks target distance and current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_enrage"] = { name = "Enrage", description = "Gain rage; not used while Bloodrage is active", details = "Gain rage, but not used while Bloodrage is active. Requires a valid target. Checks target distance and combat state. Attempts only when the ability is usable." }
Cat2.Locals.Cards["druid_faerie_fire"] = { name = "Faerie Fire", description = "Reduce the target's armor", details = "Reduce the target's armor. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_faerie_fire_feral"] = { name = "Faerie Fire (Feral)", description = "Reduce the target's armor", details = "Reduce the target's armor. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_faerie_fire_feral_target_combat"] = { name = "Faerie Fire (Feral) Target in Combat", description = "Reduce the target's armor while it is in combat", details = "Reduce the target's armor only while it is in combat. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_faerie_fire_target_combat"] = { name = "Faerie Fire (Target in Combat)", description = "Reduce the target's armor while it is in combat", details = "Reduce the target's armor only while it is in combat. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_ferocious_bite1_50"] = { name = "Ferocious Bite (1 CP, Energy < 50)", description = "Spend 4 combo points for a finisher with energy below 50", details = "Spend 4 combo points for a finisher with energy below 50. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_ferocious_bite2_50"] = { name = "Ferocious Bite (2 CP, Energy < 50)", description = "Spend 4 combo points for a finisher with energy below 50", details = "Spend 4 combo points for a finisher with energy below 50. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_ferocious_bite3_50"] = { name = "Ferocious Bite (3 CP, Energy < 50)", description = "Spend 3 combo points for a finisher with energy below 50", details = "Spend 3 combo points for a finisher with energy below 50. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_ferocious_bite4_50"] = { name = "Ferocious Bite (4 CP, Energy < 50)", description = "Spend 4 combo points for a finisher with energy below 50", details = "Spend 4 combo points for a finisher with energy below 50. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_ferocious_bite5_50"] = { name = "Ferocious Bite (5 CP, Energy < 50)", description = "Spend 5 combo points for a finisher with energy below 50", details = "Spend 5 combo points for a finisher with energy below 50. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_ferocious_bite_energy_40"] = { name = "Ferocious Bite Energy < 40", description = "Set the energy threshold of Ferocious Bite to 40", details = "Set the energy threshold of Ferocious Bite to 40. Passive rule: affects the current flow while enabled." }
Cat2.Locals.Cards["druid_ferocious_bite_energy_60"] = { name = "Ferocious Bite Energy < 60", description = "Set the energy threshold of Ferocious Bite to 60", details = "Set the energy threshold of Ferocious Bite to 60. Passive rule: affects the current flow while enabled." }
Cat2.Locals.Cards["druid_healing_touch_target"] = { name = "Healing Touch", description = "Cast an adaptive-rank Healing Touch according to the passive card rules", details = "Cast an adaptive-rank Healing Touch according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health." }
Cat2.Locals.Cards["druid_hundred_flowers"] = { name = "Hundred Flowers", description = "In Tree Form, allow continuously overwriting Regrowth", details = "In Tree Form, allow continuously overwriting Regrowth. Passive rule: affects the current flow while enabled." }
Cat2.Locals.Cards["druid_insect_swarm"] = { name = "Insect Swarm", description = "Cast a Nature damage over time effect", details = "Cast a Nature damage over time effect. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_maul"] = { name = "Maul", description = "Empower the next Bear Form attack", details = "Empower the next Bear Form attack. Requires a valid target. Checks current resources. Attempts only when the ability is usable." }
Cat2.Locals.Cards["druid_moonfire"] = { name = "Moonfire", description = "Cast an Arcane damage over time effect", details = "Cast an Arcane damage over time effect. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_moonkin_form"] = { name = "Moonkin Form", description = "Switch to and maintain Moonkin Form", details = "Switch to and maintain Moonkin Form." }
Cat2.Locals.Cards["druid_rake"] = { name = "Rake", description = "Cause bleed and gain a combo point, auto-detects bleed immunity", details = "Cause bleed and gain a combo point, auto-detects bleed immunity. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_reform"] = { name = "Reform", description = "Conditions: energy < 25, GCD < 0.2, Tiger's Protection 8 sec", details = "Conditions: energy < 25, GCD < 0.2, Tiger's Protection 8 sec. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_regrowth"] = { name = "Regrowth", description = "Cast an adaptive-rank heal with a heal over time according to the passive card rules", details = "Cast an adaptive-rank Regrowth with a heal over time according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health." }
Cat2.Locals.Cards["druid_rejuvenation"] = { name = "Rejuvenation", description = "Cast an adaptive-rank heal over time according to the passive card rules", details = "Cast an adaptive-rank Rejuvenation according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health." }
Cat2.Locals.Cards["druid_rejuvenation_move"] = { name = "Rejuvenation (While Moving)", description = "Cast an adaptive-rank heal over time while moving according to the passive card rules", details = "While moving, cast an adaptive-rank Rejuvenation according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health and movement state." }
Cat2.Locals.Cards["druid_rip1"] = { name = "Rip (1 CP)", description = "Spend 1 combo point to cause bleed, auto-detects bleed immunity", details = "Spend 1 combo point to cause bleed, auto-detects bleed immunity. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_rip2"] = { name = "Rip (2 CP)", description = "Spend 2 combo points to cause bleed, auto-detects bleed immunity", details = "Spend 2 combo points to cause bleed, auto-detects bleed immunity. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_rip3"] = { name = "Rip (3 CP)", description = "Spend 3 combo points to cause bleed, auto-detects bleed immunity", details = "Spend 3 combo points to cause bleed, auto-detects bleed immunity. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_rip4"] = { name = "Rip (4 CP)", description = "Spend 4 combo points to cause bleed, auto-detects bleed immunity", details = "Spend 4 combo points to cause bleed, auto-detects bleed immunity. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_rip5"] = { name = "Rip (5 CP)", description = "Spend 5 combo points to cause bleed, auto-detects bleed immunity", details = "Spend 5 combo points to cause bleed, auto-detects bleed immunity. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_rip_lowHP"] = { name = "Rip: Skip Low HP", description = "Do not Rip a target with less than 3000 health", details = "Do not Rip targets with less than 3000 health. Passive rule: affects the current flow while enabled." }
Cat2.Locals.Cards["druid_savagebite"] = { name = "Savage Bite", description = "Savage bite on the target", details = "Deal a savage bite to the target. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_shred"] = { name = "Shred", description = "Deal high damage from behind and gain a combo point", details = "Deal high damage from behind and gain a combo point. Requires a valid target. Checks current resources and position relative to the target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_shredclaw"] = { name = "Balance: Shred / Claw", description = "Auto-pick: Shred from behind, Claw from the front", details = "Auto-pick: Shred from behind, Claw in front. Requires a valid target. Checks current resources and position relative to the target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_starfire"] = { name = "Starfire", description = "Cast a high-damage Arcane spell", details = "Cast a high-damage Arcane spell. Requires a valid target." }
Cat2.Locals.Cards["druid_starfire_lunar_eclipse"] = { name = "Starfire (Lunar Eclipse)", description = "Cast the high-damage Arcane spell while Lunar Eclipse is boosting it", details = "Cast the high-damage Arcane spell while Lunar Eclipse is boosting it. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_starfire_solar_peak"] = { name = "Starfire (Solar Peak)", description = "When Solar cannot trigger Lunar Eclipse, cast an Arcane spell", details = "When Solar cannot trigger Lunar Eclipse, cast an Arcane spell. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_stealth"] = { name = "Stealth Rake/Ambush", description = "Do not trigger auto attack while stealthed", details = "While stealthed, do not trigger auto-attack. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_swiftmend"] = { name = "Swiftmend", description = "Cast emergency heal on the lowest health member according to the passive card rules", details = "Cast emergency heal on the lowest health member according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health. Attempts only when the ability is usable." }
Cat2.Locals.Cards["druid_swipe"] = { name = "Swipe", description = "Attack multiple nearby enemies", details = "Attack multiple nearby enemies. Requires a valid target. Checks current resources. Attempts only when the ability is usable." }
Cat2.Locals.Cards["druid_tigers_fury"] = { name = "Tiger's Fury", description = "Automatically maintain Tiger's Fury", details = "Automatically maintain Tiger's Fury. Checks combat state and current resources." }
Cat2.Locals.Cards["druid_tree_form"] = { name = "Tree of Life Form", description = "Switch to and maintain Tree of Life Form", details = "Switch to and maintain Tree of Life Form." }
Cat2.Locals.Cards["druid_wrath"] = { name = "Wrath", description = "Cast a Nature damage spell", details = "Cast a Nature damage spell. Requires a valid target." }
Cat2.Locals.Cards["druid_wrath_lunar_peak"] = { name = "Wrath (Lunar Peaks)", description = "When Lunar cannot trigger Solar Eclipse, cast a Nature spell", details = "When Lunar cannot trigger Solar Eclipse, cast a Nature spell. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_wrath_solar_eclipse"] = { name = "Wrath (Solar Eclipse)", description = "Cast a Nature spell while Solar Eclipse is boosting it", details = "Cast a Nature spell while Solar Eclipse is boosting it. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["hunter_aimed_shot"] = { name = "Aimed Shot", description = "Reduce auto-shot interference; Lock n Load affects the timing of Aimed Shot", details = "Reduce auto-shot interference; Lock and Load affects the timing of Aimed Shot. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_arcane_shot"] = { name = "Arcane Shot", description = "Cast Arcane Shot", details = "Cast Arcane Shot. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_arcane_shot_magic_ammo"] = { name = "Arcane Shot (Magic Ammo)", description = "When Magic Ammo procs, cast Arcane Shot", details = "When Magic Ammo procs, cast Arcane Shot. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_aspect_of_the_beast"] = { name = "Aspect of the Beast", description = "Switch to and maintain Aspect of the Beast", details = "Switch to and maintain Aspect of the Beast." }
Cat2.Locals.Cards["hunter_aspect_of_the_cheetah"] = { name = "Aspect of the Cheetah", description = "Switch to and maintain Aspect of the Cheetah", details = "Switch to and maintain Aspect of the Cheetah." }
Cat2.Locals.Cards["hunter_aspect_of_the_hawk"] = { name = "Aspect of the Hawk", description = "Switch to and maintain Aspect of the Hawk", details = "Switch to and maintain Aspect of the Hawk." }
Cat2.Locals.Cards["hunter_aspect_of_the_lone_wolf"] = { name = "Aspect of the Lone Wolf", description = "Switch to and maintain Aspect of the Lone Wolf", details = "Switch to and maintain Aspect of the Lone Wolf." }
Cat2.Locals.Cards["hunter_aspect_of_the_monkey"] = { name = "Aspect of the Monkey", description = "Switch to and maintain Aspect of the Monkey", details = "Switch to and maintain Aspect of the Monkey." }
Cat2.Locals.Cards["hunter_aspect_of_the_pack"] = { name = "Aspect of the Pack", description = "Switch to and maintain Aspect of the Pack", details = "Switch to and maintain Aspect of the Pack." }
Cat2.Locals.Cards["hunter_aspect_of_the_viper"] = { name = "Aspect of the Viper", description = "Switch to and maintain Aspect of the Viper", details = "Switch to and maintain Aspect of the Viper." }
Cat2.Locals.Cards["hunter_aspect_of_the_wild"] = { name = "Aspect of the Wild", description = "Switch to and maintain Aspect of the Wild", details = "Switch to and maintain Aspect of the Wild." }
Cat2.Locals.Cards["hunter_auto_shot"] = { name = "Auto Shot", description = "Cast and keep Auto Shot active", details = "Cast and keep Auto Shot active." }
Cat2.Locals.Cards["hunter_bestial_wrath"] = { name = "Bestial Wrath", description = "Cast Bestial Wrath when off cooldown", details = "Cast Bestial Wrath when off cooldown. Requires a valid target. Checks combat state. Attempts only when the ability is usable." }
Cat2.Locals.Cards["hunter_concussive_shot"] = { name = "Concussive Shot", description = "Cast Concussive Shot", details = "Cast Concussive Shot. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_explosive_trap"] = { name = "Explosive Trap", description = "Cast Explosive Trap at melee range; requires SuperWoW", details = "Cast Explosive Trap at melee range; requires SuperWoW. Requires a valid target. Checks target distance. Attempts only when the ability is usable." }
Cat2.Locals.Cards["hunter_frost_trap"] = { name = "Frost Trap", description = "Cast Frost Trap at melee range; requires SuperWoW", details = "Cast Frost Trap at melee range; requires SuperWoW. Requires a valid target. Checks target distance. Attempts only when the ability is usable." }
Cat2.Locals.Cards["hunter_hunters_mark"] = { name = "Hunter's Mark", description = "Cast and maintain Hunter's Mark on the target", details = "Cast and maintain Hunter's Mark on the target. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_immolation_trap"] = { name = "Immolation Trap", description = "Cast Immolation Trap at melee range; requires SuperWoW", details = "Cast Immolation Trap at melee range; requires SuperWoW. Requires a valid target. Checks target distance. Attempts only when the ability is usable." }
Cat2.Locals.Cards["hunter_intimidation"] = { name = "Intimidation", description = "Cast Intimidation", details = "Cast Intimidation. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_kill_command"] = { name = "Kill Command", description = "Cast Kill Command when an attack critically strikes", details = "Cast Kill Command when an attack critically strikes. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_lacerate"] = { name = "Lacerate", description = "Cast Lacerate when the distance is suitable", details = "Cast Lacerate when the distance is suitable. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_mongoose_bite"] = { name = "Mongoose Bite", description = "Cast Mongoose Bite when off cooldown", details = "Cast Mongoose Bite when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_multi_shot"] = { name = "Multi-Shot", description = "Cast Multi-Shot", details = "Cast Multi-Shot. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_multi_shot_explosive_ammo"] = { name = "Multi-Shot (Explosive Ammo)", description = "Cast Multi-Shot when Explosive Ammo procs", details = "Cast Multi-Shot when Explosive Ammo procs. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_rapid_fire"] = { name = "Rapid Fire", description = "Cast Rapid Fire when off cooldown", details = "Cast Rapid Fire when off cooldown. Requires a valid target. Checks combat state. Attempts only when the ability is usable." }
Cat2.Locals.Cards["hunter_rapid_fire_boss"] = { name = "Rapid Fire (Bosses Only)", description = "Cast Rapid Fire against elite enemies when off cooldown", details = "Cast Rapid Fire against elite enemies when off cooldown. Requires a valid target. Checks combat state. Attempts only when the ability is usable." }
Cat2.Locals.Cards["hunter_raptor_strike"] = { name = "Raptor Strike", description = "Cast Raptor Strike when off cooldown", details = "Cast Raptor Strike when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_scatter_shot"] = { name = "Scatter Shot", description = "Cast Scatter Shot when ready", details = "Cast Scatter Shot when ready. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_scorpid_sting"] = { name = "Scorpid Sting", description = "Cast and maintain Scorpid Sting", details = "Cast and maintain Scorpid Sting. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_serpent_sting"] = { name = "Serpent Sting", description = "Cast Serpent Sting", details = "Cast Serpent Sting. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_serpent_sting_toxic_ammo"] = { name = "Serpent Sting (Toxic Ammo)", description = "Cast Serpent Sting when Toxic Ammo procs", details = "Cast Serpent Sting when Toxic Ammo procs. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_shred"] = { name = "Slice", description = "Cast Slice when an attack critically strikes", details = "Cast Slice when an attack critically strikes. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_steady_shot"] = { name = "Steady Shot", description = "Cast Steady Shot and prevent it from occupying Auto Shot", details = "Cast Steady Shot and prevent it from occupying Auto Shot. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_trueshot_aura"] = { name = "Trueshot Aura", description = "Enable and maintain Trueshot Aura", details = "Enable and maintain Trueshot Aura." }
Cat2.Locals.Cards["hunter_viper_sting"] = { name = "Viper Sting", description = "Cast and maintain Viper Sting", details = "Cast and maintain Viper Sting. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["hunter_wing_clip"] = { name = "Wing Clip", description = "Maintain and cast Wing Clip on the target", details = "Maintain and cast Wing Clip on the target. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["item_burst_only_boss"] = { name = "Burst Potion (Bosses Only)", description = "Only use burst potions against elite enemies", details = "Only use burst potions against elite enemies. Passive rule: affects the current flow while enabled." }
Cat2.Locals.Cards["item_great_rage_potion"] = { name = "Great Rage Potion", description = "Use Great Rage Potion when a warrior has <20 rage or when off-cooldown for others", details = "Use Great Rage Potion when a warrior has less than 20 rage or when off-cooldown for other classes. Checks combat state and current resources." }
Cat2.Locals.Cards["item_haste_potion"] = { name = "Haste Potion", description = "Use Haste Potion when off cooldown", details = "Use Haste Potion when off cooldown. Checks combat state." }
Cat2.Locals.Cards["item_healthstone"] = { name = "Healthstone", description = "Use a Healthstone created by a warlock when health is below 30%", details = "Use a Healthstone created by a warlock when health is below 30%. Checks combat state." }
Cat2.Locals.Cards["item_herbal_tea_hp"] = { name = "Herbal Tea (Health)", description = "Use Herbal Tea when health is below 30%", details = "Use Herbal Tea when health is below 30%. Checks combat state." }
Cat2.Locals.Cards["item_herbal_tea_mp"] = { name = "Herbal Tea (Mana)", description = "Use Herbal Tea when mana is below 30%", details = "Use Herbal Tea when mana is below 30%. Checks combat state." }
Cat2.Locals.Cards["item_juju_flurry"] = { name = "Juju Flurry", description = "Use Juju Flurry when off cooldown", details = "Use Juju Flurry when off cooldown. Checks combat state." }
Cat2.Locals.Cards["item_major_healing_potion"] = { name = "Major Healing Potion", description = "Use Major Healing Potion when health is below 30%", details = "Use Major Healing Potion when health is below 30%. Checks combat state." }
Cat2.Locals.Cards["item_major_healing_salve"] = { name = "Major Healing Salve", description = "Use Major Healing Salve when health is below 30%", details = "Use Major Healing Salve when health is below 30%. Checks combat state." }
Cat2.Locals.Cards["item_major_mana_potion"] = { name = "Major Mana Potion", description = "Use Major Mana Potion when mana is below 30%", details = "Use Major Mana Potion when mana is below 30%. Checks combat state." }
Cat2.Locals.Cards["item_major_rejuvenation_potion_hp"] = { name = "Major Rejuvenation Potion (Health)", description = "Use Major Rejuvenation Potion when health is below 30%", details = "Use Major Rejuvenation Potion when health is below 30%. Checks combat state." }
Cat2.Locals.Cards["item_major_rejuvenation_potion_mp"] = { name = "Major Rejuvenation Potion (Mana)", description = "Use Major Rejuvenation Potion when mana is below 30%", details = "Use Major Rejuvenation Potion when mana is below 30%. Checks combat state." }
Cat2.Locals.Cards["item_recovery_percent_50"] = { name = "Recovery Potion Threshold 50%", description = "Recovery potions are used at 50%", details = "Recovery potions are used at 50%. Passive rule: affects the current flow while enabled." }
Cat2.Locals.Cards["item_thistle_tea"] = { name = "Thistle Tea", description = "Use Thistle Tea when energy is below 15; rogues only", details = "Use Thistle Tea when energy is below 15; rogues only. Checks combat state and current resources." }
Cat2.Locals.Cards["item_whipper_root_tuber"] = { name = "Whipper Root Tuber", description = "Use Whipper Root Tuber when health is below 30%", details = "Use Whipper Root Tuber when health is below 30%. Checks combat state." }

Cat2.Locals.Cards["mage_arcane_explosion"] = { name = "Arcane Explosion", description = "Cast Arcane Explosion when there are more than 3 nearby enemies; requires UnitXP", details = "Cast Arcane Explosion when there are more than 3 nearby enemies; requires UnitXP. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_arcane_fracture"] = { name = "Arcane Fracture", description = "Cast Arcane Fracture when off cooldown", details = "Cast Arcane Fracture when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_arcane_missiles"] = { name = "Arcane Missiles", description = "Cast Arcane Missiles; good as a filler spell", details = "Cast Arcane Missiles; good as a filler spell. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_arcane_power"] = { name = "Arcane Power", description = "Cast Arcane Power when off cooldown and mana is above 50%", details = "Cast Arcane Power when off cooldown and mana is above 50%. Checks combat state. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_arcane_power_boss"] = { name = "Arcane Power (Bosses Only)", description = "Cast Arcane Power against elite enemies when off cooldown and mana is above 50%", details = "Cast Arcane Power against elite enemies when off cooldown and mana is above 50%. Requires a valid target. Checks combat state. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_arcane_power_fuse"] = { name = "Arcane Power Fuse", description = "Block the flow when mana is below 25% during Arcane Power; place early in the flow", details = "Block the rest of the sequence when Arcane Power is active and mana falls below 25%. Place this card near the top of the flow, or cards before it will still execute." }
Cat2.Locals.Cards["mage_arcane_surge"] = { name = "Arcane Surge", description = "Cast Arcane Surge when conditions are met", details = "Cast Arcane Surge when conditions are met. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_arcane_surge_ignore_arcane_fracture"] = { name = "Arcane Surge: Ignore while Arcane Fracture", description = "Ignore Arcane Surge while Arcane Fracture is active", details = "Ignore Arcane Surge while Arcane Fracture is active. Passive rule: affects the current flow while enabled." }
Cat2.Locals.Cards["mage_arcane_surge_ignore_arcane_power"] = { name = "Arcane Surge: Ignore while Arcane Power", description = "Ignore Arcane Surge while Arcane Power is active", details = "Ignore Arcane Surge while Arcane Power is active. Passive rule: affects the current flow while enabled." }
Cat2.Locals.Cards["mage_combustion"] = { name = "Combustion", description = "Cast Combustion when off cooldown", details = "Cast Combustion when off cooldown. Requires a valid target. Attempts only when the ability is usable." }
Cat2.Locals.Cards["mage_combustion_boss"] = { name = "Combustion (Bosses Only)", description = "Cast Combustion against elite enemies when off cooldown", details = "Cast Combustion against elite enemies when off cooldown. Requires a valid target. Attempts only when the ability is usable." }
Cat2.Locals.Cards["mage_cone_of_cold"] = { name = "Cone of Cold", description = "Cast Cone of Cold within range when off cooldown", details = "Cast Cone of Cold within range when off cooldown. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_conjure_mana_agate"] = { name = "Conjure Mana Agate", description = "Use the conjured Mana Agate when mana is below 50%", details = "Use the conjured Mana Agate when mana is below 50%. Checks combat state." }
Cat2.Locals.Cards["mage_conjure_mana_citrine"] = { name = "Conjure Mana Citrine", description = "Use the conjured Mana Citrine when mana is below 50%", details = "Use the conjured Mana Citrine when mana is below 50%. Checks combat state." }
Cat2.Locals.Cards["mage_conjure_mana_emerald"] = { name = "Conjure Mana Emerald", description = "Use the conjured Mana Emerald when mana is below 50%", details = "Use the conjured Mana Emerald when mana is below 50%. Checks combat state." }
Cat2.Locals.Cards["mage_conjure_mana_ruby"] = { name = "Conjure Mana Ruby", description = "Use the conjured Mana Ruby when mana is below 50%", details = "Use the conjured Mana Ruby when mana is below 50%. Checks combat state." }
Cat2.Locals.Cards["mage_counterspell"] = { name = "Counterspell", description = "Cast Counterspell while the target is casting", details = "Cast Counterspell while the target is casting. Requires a valid target. Attempts only when the ability is usable." }
Cat2.Locals.Cards["mage_evocation"] = { name = "Evocation", description = "Cast Evocation when mana is below 30%", details = "Cast Evocation when mana is below 30%. Checks combat state. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_fireball"] = { name = "Fireball", description = "Cast Fireball; good as a filler spell", details = "Cast Fireball; good as a filler spell. Requires a valid target." }
Cat2.Locals.Cards["mage_fire_blast"] = { name = "Fire Blast", description = "Cast Fire Blast when off cooldown", details = "Cast Fire Blast when off cooldown. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_fire_ward"] = { name = "Fire Ward", description = "Cast Fire Ward when off cooldown", details = "Cast Fire Ward when off cooldown. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_frost_armor"] = { name = "Frost Armor", description = "Switch to and maintain Frost Armor", details = "Switch to and maintain Frost Armor. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_frostbolt"] = { name = "Frostbolt", description = "Cast Frostbolt; good as a filler spell", details = "Cast Frostbolt; good as a filler spell. Requires a valid target." }
Cat2.Locals.Cards["mage_frost_nova"] = { name = "Frost Nova", description = "Cast Frost Nova within range when off cooldown", details = "Cast Frost Nova within range when off cooldown. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_frost_ward"] = { name = "Frost Ward", description = "Cast Frost Ward when off cooldown", details = "Cast Frost Ward when off cooldown. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_ice_armor"] = { name = "Ice Armor", description = "Switch to and maintain Ice Armor", details = "Switch to and maintain Ice Armor." }
Cat2.Locals.Cards["mage_ice_barrier"] = { name = "Ice Barrier", description = "Cast Ice Barrier when off cooldown", details = "Cast Ice Barrier when off cooldown. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_ice_barrier_icy_veins"] = { name = "Ice Barrier (Icy Veins)", description = "Cast Ice Barrier after Icy Veins has faded", details = "Cast Ice Barrier after Icy Veins has faded. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_ice_block"] = { name = "Ice Block", description = "Cast Ice Block when health is below 15% as an emergency", details = "Cast Ice Block when health is below 15% as an emergency. Checks combat state. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_ice_pillar"] = { name = "Ice Lance", description = "Cast Ice Lance when off cooldown", details = "Cast Ice Lance when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_ice_pillar_frost_freeze"] = { name = "Ice Lance (Frost Freeze)", description = "Cast Ice Lance when Frost Freeze procs", details = "Cast Ice Lance when Frost Freeze procs. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_mage_armor"] = { name = "Mage Armor", description = "Switch to and maintain Mage Armor", details = "Switch to and maintain Mage Armor." }
Cat2.Locals.Cards["mage_mana_shield"] = { name = "Mana Shield", description = "Cast Mana Shield after it has faded", details = "Cast Mana Shield after it has faded. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_presence_of_mind"] = { name = "Presence of Mind", description = "Cast Presence of Mind when off cooldown", details = "Cast Presence of Mind when off cooldown. Attempts only when the ability is usable." }
Cat2.Locals.Cards["mage_presence_of_mind_boss"] = { name = "Presence of Mind (Bosses Only)", description = "Cast Presence of Mind against elite enemies when off cooldown", details = "Cast Presence of Mind against elite enemies when off cooldown. Requires a valid target. Attempts only when the ability is usable." }
Cat2.Locals.Cards["mage_pyroblast"] = { name = "Pyroblast", description = "Cast Pyroblast", details = "Cast Pyroblast. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_pyroblast_spell_combo_1"] = { name = "Pyroblast (1 Stack Spell Combo)", description = "Cast Pyroblast at 1 stack of Spell Combo", details = "Cast Pyroblast at 1 stack of Spell Chain. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_pyroblast_spell_combo_2"] = { name = "Pyroblast (2 Stacks Spell Combo)", description = "Cast Pyroblast at 2 stacks of Spell Combo", details = "Cast Pyroblast at 2 stacks of Spell Combo. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_pyroblast_spell_combo_3"] = { name = "Pyroblast (3 Stacks Spell Combo)", description = "Cast Pyroblast at 3 stacks of Spell Combo", details = "Cast Pyroblast at 3 stacks of Spell Combo. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_pyroblast_spell_combo_4"] = { name = "Pyroblast (4 Stacks Spell Combo)", description = "Cast Pyroblast at 4 stacks of Spell Combo", details = "Cast Pyroblast at 4 stacks of Spell Combo. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_pyroblast_spell_combo_5"] = { name = "Pyroblast (5 Stacks Spell Combo)", description = "Cast Pyroblast at 5 stacks of Spell Combo", details = "Cast Pyroblast at 5 stacks of Spell Combo. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["mage_scorch"] = { name = "Scorch", description = "Cast Scorch; good as a filler spell", details = "Cast Scorch; good as a filler spell. Requires a valid target." }
Cat2.Locals.Cards["mage_scorch_maintain_vulnerability_5"] = { name = "Scorch (Maintain 5 Stacks)", description = "Cast Scorch to maintain 5 stacks of vulnerability; requires SuperWoW", details = "Cast Scorch to maintain 5 stacks of vulnerability; requires SuperWoW. Requires a valid target. Stops the rest of the sequence on success." }

-- Additional card translations (Paladin / Priest / Rogue / Warrior / Shaman / Warlock / Shared)
Cat2.Locals.Cards["paladin_concentration_aura"] = { name = "Concentration Aura", description = "Switch to and maintain Concentration Aura", details = "Switch to and maintain Concentration Aura." }
Cat2.Locals.Cards["paladin_consecration"] = { name = "Consecration", description = "Cast Consecration when in melee range", details = "Cast Consecration when in melee range. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_crusader_strike"] = { name = "Crusader Strike / Holy Strike", description = "Cast based on buff timing, Crusader Strike cast first", details = "Cast based on buff timing, Crusader Strike cast first. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_crusader_strike_single"] = { name = "Crusader Strike", description = "Cast Crusader Strike at melee range", details = "Cast Crusader Strike at melee range. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_devotion_aura"] = { name = "Devotion Aura", description = "Switch to and maintain Devotion Aura", details = "Switch to and maintain Devotion Aura." }
Cat2.Locals.Cards["paladin_divine_shield"] = { name = "Divine Shield", description = "Cast Divine Shield when health is below 15% in an emergency", details = "Cast Divine Shield when health is below 15% in an emergency. Checks combat state. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_exorcism"] = { name = "Exorcism", description = "Cast Exorcism when the target is Undead", details = "Cast Exorcism when the target is Undead. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_flash_of_light"] = { name = "Flash of Light", description = "Cast an adaptive-rank Flash of Light according to the |cffb87ff0[Passive Card]|r rules", details = "Cast an adaptive-rank Flash of Light according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_hammer_of_justice"] = { name = "Hammer of Justice", description = "Cast Hammer of Justice on the target when off cooldown", details = "Cast Hammer of Justice on the target when off cooldown. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_hammer_of_wrath"] = { name = "Hammer of Wrath", description = "Cast Hammer of Wrath when the ability conditions are met", details = "Cast Hammer of Wrath when the ability conditions are met. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_hand_of_protection"] = { name = "Hand of Protection (Self)", description = "Cast Hand of Protection on yourself when health is below 15% in an emergency", details = "Cast Hand of Protection on yourself when health is below 15% in an emergency. Checks combat state. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_holy_light"] = { name = "Holy Light", description = "Cast an adaptive-rank Holy Light when health is below 70% according to the |cffb87ff0[Passive Card]|r rules", details = "Cast an adaptive-rank Holy Light when health is below 70% according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_holy_shield"] = { name = "Holy Shield", description = "Cast Holy Shield when off cooldown", details = "Cast Holy Shield when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_holy_shock"] = { name = "Holy Shock", description = "Cast Holy Shock when health is below 70% according to the |cffb87ff0[Passive Card]|r rules", details = "Cast Holy Shock when health is below 70% according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_holy_strike"] = { name = "Holy Strike / Crusader Strike", description = "Cast based on buff timing, Holy Strike cast first", details = "Cast based on buff timing, Holy Strike cast first. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_holy_strike_no_target"] = { name = "Holy Strike (No Target)", description = "For melee healers, cast Holy Strike without switching targets", details = "For melee healers, cast Holy Strike without switching targets. Attempts only when the ability is usable." }
Cat2.Locals.Cards["paladin_holy_strike_single"] = { name = "Holy Strike", description = "Cast Holy Strike at melee range", details = "Cast Holy Strike at melee range. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_holy_wrath"] = { name = "Holy Wrath", description = "Cast Holy Wrath when in range", details = "Cast Holy Wrath when in range. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_keep_crusader_judgement"] = { name = "Maintain Judgement of the Crusader on Target", description = "Maintain Judgement of the Crusader on the target", details = "Maintain Judgement of the Crusader on the target. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_keep_justice_judgement"] = { name = "Maintain Judgement of Justice on Target", description = "Maintain Judgement of Justice on the target", details = "Maintain Judgement of Justice on the target. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_keep_light_judgement"] = { name = "Maintain Judgement of Light on Target", description = "Maintain Judgement of Light on the target", details = "Maintain Judgement of Light on the target. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_keep_wisdom_judgement"] = { name = "Maintain Judgement of Wisdom on Target", description = "Maintain Judgement of Wisdom on the target", details = "Maintain Judgement of Wisdom on the target. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_lay_on_hands"] = { name = "Lay on Hands", description = "Cast Lay on Hands when health falls below 15% in an emergency according to the |cffb87ff0[Passive Card]|r rules", details = "Cast Lay on Hands when health falls below 15% in an emergency according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks combat state. Checks relevant health. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_lay_on_hands_self"] = { name = "Lay on Hands (Self)", description = "Cast Lay on Hands on yourself when your health drops below 15%", details = "Cast Lay on Hands on yourself when your health drops below 15%. Checks combat state. Checks relevant health. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_repentance"] = { name = "Repentance", description = "Cast Repentance when in range", details = "Cast Repentance when in range. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_righteous_bulwark"] = { name = "Righteous Bulwark", description = "Cast Righteous Bulwark when health is below 30%", details = "Cast Righteous Bulwark when health is below 30%. Requires a valid target. Checks combat state. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_righteous_fury"] = { name = "Righteous Fury", description = "Enable and maintain Righteous Fury", details = "Enable and maintain Righteous Fury." }
Cat2.Locals.Cards["paladin_sanctity_aura"] = { name = "Sanctity Aura", description = "Switch to and maintain Sanctity Aura", details = "Switch to and maintain Sanctity Aura." }
Cat2.Locals.Cards["paladin_seal_of_command"] = { name = "Maintain Seal of Command / Judgement", description = "Maintain Seal of Command while casting Judgement to attack", details = "Maintain Seal of Command while casting Judgement to attack. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_seal_of_justice"] = { name = "Seal of Justice", description = "Cast and maintain Seal of Justice", details = "Cast and maintain Seal of Justice. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_seal_of_light"] = { name = "Seal of Light", description = "Cast and maintain Seal of Light", details = "Cast and maintain Seal of Light. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_seal_of_righteousness"] = { name = "Maintain Seal of Righteousness / Judgement", description = "Maintain Seal of Righteousness while casting Judgement to attack", details = "Maintain Seal of Righteousness while casting Judgement to attack. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_seal_of_the_crusader"] = { name = "Seal of the Crusader", description = "Cast and maintain Seal of the Crusader", details = "Cast and maintain Seal of the Crusader. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["paladin_seal_of_wisdom"] = { name = "Seal of Wisdom", description = "Cast and maintain Seal of Wisdom", details = "Cast and maintain Seal of Wisdom. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_apotheosis"] = { name = "Apotheosis", description = "Cast Apotheosis when it comes off cooldown", details = "Cast Apotheosis when it comes off cooldown. Attempts only when the ability is usable." }
Cat2.Locals.Cards["priest_chastise"] = { name = "Chastise (Self)", description = "Maintain and cast Chastise on yourself", details = "Maintain and cast Chastise on yourself. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_desperate_prayer"] = { name = "Desperate Prayer", description = "Cast Desperate Prayer when health is below 15% in an emergency according to the |cffb87ff0[Passive Card]|r rules", details = "Cast Desperate Prayer when health is below 15% in an emergency according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks combat state. Checks relevant health. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_enlightenment"] = { name = "Enlightenment (Self)", description = "Maintain and cast Enlightenment on yourself", details = "Maintain and cast Enlightenment on yourself. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_fade"] = { name = "Fade", description = "Cast Fade when off cooldown", details = "Cast Fade when off cooldown. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_flash_heal"] = { name = "Flash Heal", description = "Cast an adaptive-rank Flash Heal according to the |cffb87ff0[Passive Card]|r rules", details = "Cast an adaptive-rank Flash Heal according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health." }
Cat2.Locals.Cards["priest_greater_heal"] = { name = "Greater Heal", description = "Cast an adaptive-rank Greater Heal when health is below 70% according to the |cffb87ff0[Passive Card]|r rules", details = "Cast an adaptive-rank Greater Heal when health is below 70% according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health." }
Cat2.Locals.Cards["priest_heal"] = { name = "Heal", description = "Cast an adaptive-rank Heal when health is below 80% according to the |cffb87ff0[Passive Card]|r rules", details = "Cast an adaptive-rank Heal when health is below 80% according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health." }
Cat2.Locals.Cards["priest_holy_fire"] = { name = "Holy Fire", description = "Maintain and cast Holy Fire", details = "Maintain and cast Holy Fire. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_holy_nova"] = { name = "Holy Nova", description = "Cast Holy Nova when more than 3 enemies are nearby (requires the UnitXP module)", details = "Cast Holy Nova when more than 3 enemies are nearby (requires the UnitXP module). Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_inner_fire"] = { name = "Inner Fire", description = "Maintain and cast Inner Fire", details = "Maintain and cast Inner Fire. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_inner_focus"] = { name = "Inner Focus", description = "Cast Inner Focus when it comes off cooldown", details = "Cast Inner Focus when it comes off cooldown. Attempts only when the ability is usable." }
Cat2.Locals.Cards["priest_lesser_heal"] = { name = "Lesser Heal", description = "Cast an adaptive-rank Lesser Heal according to the |cffb87ff0[Passive Card]|r rules", details = "Cast an adaptive-rank Lesser Heal according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health." }
Cat2.Locals.Cards["priest_mind_blast"] = { name = "Mind Blast", description = "Cast Mind Blast when off cooldown", details = "Cast Mind Blast when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_mind_flay"] = { name = "Mind Flay", description = "Cast Mind Flay on the target", details = "Cast Mind Flay on the target. Requires a valid target." }
Cat2.Locals.Cards["priest_mind_flay_second"] = { name = "Mind Flay (Second)", description = "Cast the second-tier Mind Flay on the target", details = "Cast the second-tier Mind Flay on the target. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_mind_flay_second_five_stacks"] = { name = "Mind Flay (Second, 5 Vulnerability Stacks Only)", description = "Cast the second-tier Mind Flay before vulnerability reaches 5 stacks", details = "Cast the second-tier Mind Flay before vulnerability reaches 5 stacks. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_pain_spike"] = { name = "Pain Spike", description = "Cast Pain Spike on the target when off cooldown", details = "Cast Pain Spike on the target when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_power_word_shield"] = { name = "Power Word: Shield", description = "Cast Power Word: Shield on low-health allies according to the |cffb87ff0[Passive Card]|r rules", details = "Cast Power Word: Shield on low-health allies according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_power_word_shield_move"] = { name = "Power Word: Shield (While Moving)", description = "While moving, cast Power Word: Shield on low-health allies according to the |cffb87ff0[Passive Card]|r rules", details = "While moving, cast Power Word: Shield on low-health allies according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health. Attempts only when the ability is usable. Checks movement state. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_prayer_book"] = { name = "Prayer Book", description = "Cast Prayer Book", details = "Cast Prayer Book." }
Cat2.Locals.Cards["priest_prayer_of_healing"] = { name = "Prayer of Healing", description = "Cast Prayer of Healing when 3 party members are below 80% health", details = "Cast Prayer of Healing when 3 party members are below 80% health. Checks relevant health. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_renew"] = { name = "Renew", description = "Cast an adaptive-rank Renew according to the |cffb87ff0[Passive Card]|r rules", details = "Cast an adaptive-rank Renew according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_renew_move"] = { name = "Renew (While Moving)", description = "While moving, cast an adaptive-rank Renew according to the |cffb87ff0[Passive Card]|r rules", details = "While moving, cast an adaptive-rank Renew according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health. Checks movement state. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_shadowform"] = { name = "Shadowform", description = "Maintain and cast Shadowform", details = "Maintain and cast Shadowform. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_shadow_word_pain"] = { name = "Shadow Word: Pain", description = "Maintain and cast Shadow Word: Pain on the target", details = "Maintain and cast Shadow Word: Pain on the target. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_silence"] = { name = "Silence", description = "Cast Silence when the target is casting (requires the SuperWoW module)", details = "Cast Silence when the target is casting (requires the SuperWoW module). Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["priest_smite"] = { name = "Smite", description = "Cast Smite, good as a filler ability", details = "Cast Smite, good as a filler ability." }
Cat2.Locals.Cards["priest_vampiric_embrace"] = { name = "Vampiric Embrace", description = "Maintain and cast Vampiric Embrace on the target", details = "Maintain and cast Vampiric Embrace on the target. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["rogue_adrenaline_rush"] = { name = "Adrenaline Rush", description = "Cast Adrenaline Rush when off cooldown and energy is below 40", details = "Cast Adrenaline Rush when off cooldown and energy is below 40. Requires a valid target. Checks target distance and current resources. Attempts only when the ability is usable." }

Cat2.Locals.Cards["rogue_adrenaline_rush_boss"] = { name = "Adrenaline Rush (Bosses Only)", description = "Cast Adrenaline Rush against elite enemies when energy is low", details = "Cast Adrenaline Rush against elite enemies only when energy is low. Requires a valid target. Checks target distance and current resources. Attempts only when the ability is usable." }

Cat2.Locals.Cards["rogue_backstab"] = { name = "Backstab (Adaptive Weapon)", description = "Cast Backstab from behind the target with 60 energy", details = "Casts Backstab from behind the target with 60 energy while wielding a dagger, otherwise uses Sinister Strike. Requires a valid target. Checks current resources and position relative to the target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_backstab_sinister"] = { name = "Balance: Backstab / Sinister Strike", description = "Auto-pick: Backstab from behind, Sinister Strike from the front", details = "Auto-pick, adapts to the main-hand weapon: Backstab from behind, Sinister Strike from the front. Requires a valid target. Checks current resources and position relative to the target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_blade_flurry"] = { name = "Blade Flurry", description = "Automatically toggle Blade Flurry on/off with multiple enemies nearby, requires SuperWoW", details = "Automatically toggles Blade Flurry on/off with multiple enemies nearby, requires SuperWoW. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_cold_blood"] = { name = "Cold Blood", description = "Cast Cold Blood when the target exists, is attackable, and Cold Blood is ready", details = "Cast Cold Blood when the target exists, is attackable, and Cold Blood is ready. Requires a valid target. Checks target distance and combat state." }

Cat2.Locals.Cards["rogue_cold_blood_boss"] = { name = "Cold Blood (Bosses Only)", description = "Cast Cold Blood against elite enemies when off cooldown", details = "Cast Cold Blood against elite enemies when off cooldown. Requires a valid target. Checks target distance and combat state." }

Cat2.Locals.Cards["rogue_deadly_throw"] = { name = "Deadly Throw", description = "Cast Deadly Throw when off cooldown", details = "Cast Deadly Throw when off cooldown. Requires a valid target. Checks target distance and current resources. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_deadly_throw_interrupt"] = { name = "Deadly Throw (Interrupt)", description = "Interrupt the target's cast with Deadly Throw while it is casting, requires SuperWoW module", details = "Interrupt the target's cast with Deadly Throw while it is casting, requires SuperWoW module. Requires a valid target. Checks target distance and current resources. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_dual_blade_poison_strike"] = { name = "Dual Blade Poison Strike", description = "Cast Dual Blade Poison Strike at 45 energy", details = "Cast Dual Blade Poison Strike at 45 energy. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_envenom_1"] = { name = "Envenom (1 CP)", description = "Spend 1 combo point to cast Envenom", details = "Spend 1 combo point to cast Envenom. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_envenom_2"] = { name = "Envenom (2 CP)", description = "Spend 2 combo points to cast Envenom", details = "Spend 2 combo points to cast Envenom. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_envenom_3"] = { name = "Envenom (3 CP)", description = "Spend 3 combo points to cast Envenom", details = "Spend 3 combo points to cast Envenom. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_envenom_4"] = { name = "Envenom (4 CP)", description = "Spend 4 combo points to cast Envenom", details = "Spend 4 combo points to cast Envenom. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_envenom_5"] = { name = "Envenom (5 CP)", description = "Spend 5 combo points to cast Envenom", details = "Spend 5 combo points to cast Envenom. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_evasion"] = { name = "Evasion", description = "Cast Evasion when focused by the target and health is below 30%", details = "Cast Evasion when focused by the target and health is below 30%. Requires a valid target. Attempts only when the ability is usable." }

Cat2.Locals.Cards["rogue_eviscerate_1"] = { name = "Eviscerate (1 CP)", description = "Spend 1 combo point to cast Eviscerate", details = "Spend 1 combo point to cast Eviscerate. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_eviscerate_2"] = { name = "Eviscerate (2 CP)", description = "Spend 2 combo points to cast Eviscerate", details = "Spend 2 combo points to cast Eviscerate. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_eviscerate_3"] = { name = "Eviscerate (3 CP)", description = "Spend 3 combo points to cast Eviscerate", details = "Spend 3 combo points to cast Eviscerate. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_eviscerate_4"] = { name = "Eviscerate (4 CP)", description = "Spend 4 combo points to cast Eviscerate", details = "Spend 4 combo points to cast Eviscerate. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_eviscerate_5"] = { name = "Eviscerate (5 CP)", description = "Spend 5 combo points to cast Eviscerate", details = "Spend 5 combo points to cast Eviscerate. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_excitement_1"] = { name = "Excitement (1 CP)", description = "Spend 1 combo point to cast Excitement", details = "Spend 1 combo point to cast Excitement. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_excitement_2"] = { name = "Excitement (2 CP)", description = "Spend 2 combo points to cast Excitement", details = "Spend 2 combo points to cast Excitement. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_excitement_3"] = { name = "Excitement (3 CP)", description = "Spend 3 combo points to cast Excitement", details = "Spend 3 combo points to cast Excitement. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_excitement_4"] = { name = "Excitement (4 CP)", description = "Spend 4 combo points to cast Excitement", details = "Spend 4 combo points to cast Excitement. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_excitement_5"] = { name = "Excitement (5 CP)", description = "Spend 5 combo points to cast Excitement", details = "Spend 5 combo points to cast Excitement. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_expose_armor_1"] = { name = "Expose Armor (1 CP)", description = "Spend 1 combo point to cast Expose Armor", details = "Spend 1 combo point to cast Expose Armor. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_expose_armor_2"] = { name = "Expose Armor (2 CP)", description = "Spend 2 combo points to cast Expose Armor", details = "Spend 2 combo points to cast Expose Armor. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_expose_armor_3"] = { name = "Expose Armor (3 CP)", description = "Spend 3 combo points to cast Expose Armor", details = "Spend 3 combo points to cast Expose Armor. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_expose_armor_4"] = { name = "Expose Armor (4 CP)", description = "Spend 4 combo points to cast Expose Armor", details = "Spend 4 combo points to cast Expose Armor. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_expose_armor_5"] = { name = "Expose Armor (5 CP)", description = "Spend 5 combo points to cast Expose Armor", details = "Spend 5 combo points to cast Expose Armor. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_feint"] = { name = "Feint", description = "Cast Feint when off cooldown and energy is sufficient", details = "Cast Feint when a valid target exists, off cooldown, and energy is at least 20. Checks current resources and spell cooldown. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_ghostly_strike"] = { name = "Ghostly Strike", description = "Cast Ghostly Strike when off cooldown", details = "Cast Ghostly Strike when off cooldown. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_hemorrhage"] = { name = "Hemorrhage", description = "Cast Hemorrhage at 35/40 energy depending on talents", details = "Cast Hemorrhage at 35/40 energy depending on talents. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_kick"] = { name = "Kick", description = "Cast Kick while the target is casting, requires SuperWoW module", details = "Cast Kick while the target is casting, requires SuperWoW module. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_kidney_shot_1"] = { name = "Kidney Shot (1 CP)", description = "Spend 1 combo point to cast Kidney Shot", details = "Spend 1 combo point to cast Kidney Shot. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_kidney_shot_2"] = { name = "Kidney Shot (2 CP)", description = "Spend 2 combo points to cast Kidney Shot", details = "Spend 2 combo points to cast Kidney Shot. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_kidney_shot_3"] = { name = "Kidney Shot (3 CP)", description = "Spend 3 combo points to cast Kidney Shot", details = "Spend 3 combo points to cast Kidney Shot. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_kidney_shot_4"] = { name = "Kidney Shot (4 CP)", description = "Spend 4 combo points to cast Kidney Shot", details = "Spend 4 combo points to cast Kidney Shot. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_kidney_shot_5"] = { name = "Kidney Shot (5 CP)", description = "Spend 5 combo points to cast Kidney Shot", details = "Spend 5 combo points to cast Kidney Shot. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_marked_for_death"] = { name = "Marked for Death", description = "Cast Marked for Death when off cooldown", details = "Cast Marked for Death when off cooldown. Requires a valid target. Checks target distance and current resources. Attempts only when the ability is usable." }

Cat2.Locals.Cards["rogue_marked_for_death_boss"] = { name = "Marked for Death (Bosses Only)", description = "Cast Marked for Death against elite enemies when off cooldown", details = "Cast Marked for Death against elite enemies when off cooldown. Requires a valid target. Checks target distance and current resources. Attempts only when the ability is usable." }

Cat2.Locals.Cards["rogue_preparation"] = { name = "Preparation", description = "Cast Preparation when Marked for Death goes on cooldown", details = "Cast Preparation when Marked for Death goes on cooldown. Requires a valid target. Checks combat state. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_riposte"] = { name = "Riposte", description = "Attempt to cast Riposte when available", details = "Attempt to cast Riposte when available. Requires a valid target. Checks current resources." }

Cat2.Locals.Cards["rogue_rupture_1"] = { name = "Rupture (1 CP)", description = "Spend 1 combo point to cast Rupture", details = "Spend 1 combo point to cast Rupture. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_rupture_2"] = { name = "Rupture (2 CP)", description = "Spend 2 combo points to cast Rupture", details = "Spend 2 combo points to cast Rupture. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_rupture_3"] = { name = "Rupture (3 CP)", description = "Spend 3 combo points to cast Rupture", details = "Spend 3 combo points to cast Rupture. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_rupture_4"] = { name = "Rupture (4 CP)", description = "Spend 4 combo points to cast Rupture", details = "Spend 4 combo points to cast Rupture. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_rupture_5"] = { name = "Rupture (5 CP)", description = "Spend 5 combo points to cast Rupture", details = "Spend 5 combo points to cast Rupture. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_rush"] = { name = "Rush", description = "Cast Rush when the target dodges", details = "Cast Rush when the target dodges. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_sinister_strike"] = { name = "Sinister Strike", description = "Cast Sinister Strike at 40 energy", details = "Cast Sinister Strike at 40 energy. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_slice_and_dice_1"] = { name = "Slice and Dice (1 CP)", description = "Spend 1 combo point to cast Slice and Dice", details = "Spend 1 combo point to cast Slice and Dice. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_slice_and_dice_2"] = { name = "Slice and Dice (2 CP)", description = "Spend 2 combo points to cast Slice and Dice", details = "Spend 2 combo points to cast Slice and Dice. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_slice_and_dice_3"] = { name = "Slice and Dice (3 CP)", description = "Spend 3 combo points to cast Slice and Dice", details = "Spend 3 combo points to cast Slice and Dice. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_slice_and_dice_4"] = { name = "Slice and Dice (4 CP)", description = "Spend 4 combo points to cast Slice and Dice", details = "Spend 4 combo points to cast Slice and Dice. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_slice_and_dice_5"] = { name = "Slice and Dice (5 CP)", description = "Spend 5 combo points to cast Slice and Dice", details = "Spend 5 combo points to cast Slice and Dice. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["rogue_stealth"] = { name = "Stealth Garrote/Ambush", description = "While stealthed, pick the opener based on the target's bleed state", details = "While stealthed, pick the opener based on the target's bleed state. Requires a valid target. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["warrior_death_wish_boss"] = { name = "Death Wish (Bosses Only)", description = "Cast Death Wish against elite enemies when off cooldown", details = "Cast Death Wish against elite enemies when off cooldown. Requires a valid target. Checks target distance and current resources. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["warrior_execute_high_rage"] = { name = "Execute (High Rage)", description = "Cast Execute when conditions are met and rage is above 50", details = "Cast Execute when conditions are met and rage is above 50. Requires a valid target. Checks current resources. When Interrupt Cast for Execute is enabled, interrupts the current Slam cast before casting. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["warrior_execute_nearby_target"] = { name = "Execute: Nearby Executable Target", description = "Cast Execute on nearby targets whose health meets the execute condition", details = "Cast Execute on nearby targets whose health meets the execute condition. Affects attackable targets only. Checks current resources and relevant health. When Interrupt Cast for Execute is enabled, interrupts the current Slam cast before casting." }

Cat2.Locals.Cards["warrior_hamstring"] = { name = "Hamstring", description = "Maintain Hamstring on the target", details = "Maintain and cast Hamstring on the target. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["warrior_hamstring_flurry"] = { name = "Hamstring (Trigger Flurry)", description = "Cast Hamstring to trigger Flurry", details = "Cast Hamstring to trigger Flurry. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["warrior_heroic_strike"] = { name = "Heroic Strike", description = "Cast Heroic Strike when rage is above 50", details = "Cast Heroic Strike when rage is above 50. Requires a valid target. Checks current resources." }

Cat2.Locals.Cards["warrior_heroic_strike_alt"] = { name = "Auto: Heroic Strike / Cleave", description = "Cast Heroic Strike or Cleave based on nearby enemy count when rage is above 50", details = "Cast Heroic Strike or Cleave based on the number of nearby enemies when rage is above 50. Requires a valid target. Checks current resources." }

Cat2.Locals.Cards["warrior_interrupt_cast_for_execute"] = { name = "Interrupt Cast for Execute", description = "Allow the flow to interrupt the current cast when entering the Execute phase", details = "Allow the flow to interrupt the current cast when entering the Execute phase. As a passive rule, affects the current flow while enabled." }

Cat2.Locals.Cards["warrior_rage_threshold_40"] = { name = "Rage Threshold >40", description = "Set the Heroic Strike/Cleave threshold to above 40 rage", details = "Set the Heroic Strike/Cleave threshold to above 40 rage. As a passive rule, affects the current flow while enabled." }

Cat2.Locals.Cards["warrior_rage_threshold_60"] = { name = "Rage Threshold >60", description = "Set the Heroic Strike/Cleave threshold to above 60 rage", details = "Set the Heroic Strike/Cleave threshold to above 60 rage. As a passive rule, affects the current flow while enabled." }

Cat2.Locals.Cards["warrior_recklessness_boss"] = { name = "Recklessness (Bosses Only)", description = "Cast Recklessness against elite enemies when off cooldown", details = "Cast Recklessness against elite enemies when off cooldown. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["warrior_slam_flurry"] = { name = "Slam (Flurry)", description = "Cast Slam while Flurry is active, preserving auto-attacks", details = "Cast Slam only while Flurry is active, preserving auto-attacks and casting Slam when the remaining auto-attack time is greater than 1.5 seconds. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["warrior_slam_unorthodox"] = { name = "Slam (Unorthodox)", description = "Ignore auto-attacks; cast Slam when the auto-attack cycle is above 0.5 seconds", details = "Ignore auto-attacks; cast Slam when the auto-attack cycle is above 0.5 seconds. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["warrior_special_strike"] = { name = "Special Strike", description = "Cast the special strike when off cooldown", details = "Cast the special strike when off cooldown. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["warrior_sunder_armor"] = { name = "Sunder Armor", description = "Spam Sunder Armor, good as a filler", details = "Spam Sunder Armor indefinitely, good as a filler. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["warrior_sunder_armor_one"] = { name = "Sunder Armor (First Stack)", description = "Apply Sunder Armor to the target only once, requires SuperWoW module", details = "Apply Sunder Armor to the target only once, requires SuperWoW module. Requires a valid target. Checks current resources. Stops the rest of the sequence on success." }

Cat2.Locals.Cards["warrior_whirlwind_group"] = { name = "Whirlwind (Group Only)", description = "Cast Whirlwind when off cooldown with more than 2 nearby enemies, never on single targets", details = "Cast Whirlwind when off cooldown with a group of enemies, never on single targets. Requires a valid target. Checks target distance and current resources. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_bloodlust"] = { name = "Bloodlust", description = "Cast Bloodlust when off cooldown and in melee range", details = "Cast Bloodlust when off cooldown and in melee range. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_bloodlust_boss"] = { name = "Bloodlust (Bosses Only)", description = "Cast Bloodlust against elite enemies when off cooldown", details = "Cast Bloodlust against elite enemies when off cooldown. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_chain_heal"] = { name = "Chain Heal", description = "Cast an adaptive-rank Chain Heal according to the |cffb87ff0[Passive Card]|r rules", details = "Cast an adaptive-rank Chain Heal according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health." }
Cat2.Locals.Cards["shaman_chain_lightning"] = { name = "Chain Lightning", description = "Cast Chain Lightning when off cooldown", details = "Cast Chain Lightning when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_disease_cleansing_totem"] = { name = "Disease Cleansing Totem", description = "Maintain and cast Disease Cleansing Totem", details = "Maintain and cast Disease Cleansing Totem." }
Cat2.Locals.Cards["shaman_earthbind_totem"] = { name = "Earthbind Totem", description = "Maintain and cast Earthbind Totem", details = "Maintain and cast Earthbind Totem." }
Cat2.Locals.Cards["shaman_earthquake"] = { name = "Earthquake", description = "Cast Earthquake when off cooldown", details = "Cast Earthquake when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_earth_shield"] = { name = "Earth Shield", description = "Cast Earth Shield; only one shield can be active at a time", details = "Cast Earth Shield; only one shield can be active at a time." }
Cat2.Locals.Cards["shaman_earth_shock"] = { name = "Earth Shock", description = "Cast Earth Shock when off cooldown", details = "Cast Earth Shock when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_earth_shock_interrupt"] = { name = "Earth Shock (Interrupt)", description = "Cast Earth Shock to interrupt the target while it is casting", details = "Cast Earth Shock to interrupt the target while it is casting. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_elemental_mastery"] = { name = "Elemental Mastery", description = "Cast Elemental Mastery when off cooldown", details = "Cast Elemental Mastery when off cooldown. Requires a valid target. Attempts only when the ability is usable." }
Cat2.Locals.Cards["shaman_elemental_mastery_boss"] = { name = "Elemental Mastery (Bosses Only)", description = "Cast Elemental Mastery against elite enemies when off cooldown", details = "Cast Elemental Mastery against elite enemies when off cooldown. Requires a valid target. Attempts only when the ability is usable." }
Cat2.Locals.Cards["shaman_fire_nova_totem"] = { name = "Fire Nova Totem", description = "Maintain and cast Fire Nova Totem", details = "Maintain and cast Fire Nova Totem." }
Cat2.Locals.Cards["shaman_fire_resistance_totem"] = { name = "Fire Resistance Totem", description = "Maintain and cast Fire Resistance Totem", details = "Maintain and cast Fire Resistance Totem." }
Cat2.Locals.Cards["shaman_flame_shock"] = { name = "Flame Shock", description = "Cast Flame Shock when off cooldown", details = "Cast Flame Shock when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_flame_shock_lava_followup"] = { name = "Lava Burst Maintains Flame Shock", description = "Maintain the Flame Shock DoT via Flame Shock; requires SuperWoW", details = "Maintain the Flame Shock DoT via Flame Shock; requires SuperWoW. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_flame_shock_lava_maximize"] = { name = "Flame Shock & Lava Burst Maximize", description = "Maintain Flame Shock and cast Lava Burst when off cooldown", details = "Maintain Flame Shock and cast Lava Burst when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_flametongue_totem"] = { name = "Flametongue Totem", description = "Maintain and cast Flametongue Totem", details = "Maintain and cast Flametongue Totem." }
Cat2.Locals.Cards["shaman_flametongue_weapon"] = { name = "Flametongue Weapon", description = "Cast Flametongue Weapon on yourself", details = "Cast Flametongue Weapon on yourself. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_frostbrand_weapon"] = { name = "Frostbrand Weapon", description = "Cast Frostbrand Weapon on yourself", details = "Cast Frostbrand Weapon on yourself. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_frost_resistance_totem"] = { name = "Frost Resistance Totem", description = "Maintain and cast Frost Resistance Totem", details = "Maintain and cast Frost Resistance Totem." }
Cat2.Locals.Cards["shaman_frost_shock"] = { name = "Frost Shock", description = "Cast Frost Shock when off cooldown", details = "Cast Frost Shock when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_grace_of_air_totem"] = { name = "Grace of Air Totem", description = "Maintain and cast Grace of Air Totem", details = "Maintain and cast Grace of Air Totem." }
Cat2.Locals.Cards["shaman_grounding_totem"] = { name = "Grounding Totem", description = "Maintain and cast Grounding Totem", details = "Maintain and cast Grounding Totem." }
Cat2.Locals.Cards["shaman_healing_stream_totem"] = { name = "Healing Stream Totem", description = "Maintain and cast Healing Stream Totem", details = "Maintain and cast Healing Stream Totem." }
Cat2.Locals.Cards["shaman_healing_wave"] = { name = "Healing Wave", description = "Cast an adaptive-rank Healing Wave when health is below 70% according to the |cffb87ff0[Passive Card]|r rules", details = "Cast an adaptive-rank Healing Wave when health is below 70% according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health." }
Cat2.Locals.Cards["shaman_lava_burst"] = { name = "Lava Burst", description = "Unconditionally cast Lava Burst; useful as a filler", details = "Unconditionally cast Lava Burst; useful as a filler. Requires a valid target." }
Cat2.Locals.Cards["shaman_lesser_healing_wave"] = { name = "Lesser Healing Wave", description = "Cast an adaptive-rank Lesser Healing Wave according to the |cffb87ff0[Passive Card]|r rules", details = "Cast an adaptive-rank Lesser Healing Wave according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks relevant health." }
Cat2.Locals.Cards["shaman_lightning_bolt"] = { name = "Lightning Bolt", description = "Unconditionally cast Lightning Bolt; useful as a filler", details = "Unconditionally cast Lightning Bolt; useful as a filler. Requires a valid target." }
Cat2.Locals.Cards["shaman_lightning_shield"] = { name = "Lightning Shield", description = "Cast Lightning Shield; only one shield can be active at a time", details = "Cast Lightning Shield; only one shield can be active at a time." }
Cat2.Locals.Cards["shaman_lightning_strike"] = { name = "Lightning Strike", description = "Cast Lightning Strike when off cooldown", details = "Cast Lightning Strike when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_magma_totem"] = { name = "Magma Totem", description = "Maintain and cast Magma Totem", details = "Maintain and cast Magma Totem." }
Cat2.Locals.Cards["shaman_mana_spring_totem"] = { name = "Mana Spring Totem", description = "Maintain and cast Mana Spring Totem", details = "Maintain and cast Mana Spring Totem." }
Cat2.Locals.Cards["shaman_nature_resistance_totem"] = { name = "Nature Resistance Totem", description = "Maintain and cast Nature Resistance Totem", details = "Maintain and cast Nature Resistance Totem." }
Cat2.Locals.Cards["shaman_poison_cleansing_totem"] = { name = "Poison Cleansing Totem", description = "Maintain and cast Poison Cleansing Totem", details = "Maintain and cast Poison Cleansing Totem." }
Cat2.Locals.Cards["shaman_rockbiter_weapon"] = { name = "Rockbiter Weapon", description = "Cast Rockbiter Weapon on yourself", details = "Cast Rockbiter Weapon on yourself. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_searing_totem"] = { name = "Searing Totem", description = "Maintain and cast Searing Totem", details = "Maintain and cast Searing Totem." }
Cat2.Locals.Cards["shaman_spirit_link"] = { name = "Spirit Link", description = "Cast Spirit Link when health is below 15% according to the |cffb87ff0[Passive Card]|r rules", details = "Cast Spirit Link when health is below 15% according to the |cffb87ff0[Passive Card]|r rules. Requires a valid target. Affects attackable targets only. Checks combat state. Checks relevant health. Attempts only when the ability is usable." }
Cat2.Locals.Cards["shaman_stoneclaw_totem"] = { name = "Stoneclaw Totem", description = "Maintain and cast Stoneclaw Totem", details = "Maintain and cast Stoneclaw Totem." }
Cat2.Locals.Cards["shaman_stoneskin_totem"] = { name = "Stoneskin Totem", description = "Maintain and cast Stoneskin Totem", details = "Maintain and cast Stoneskin Totem." }
Cat2.Locals.Cards["shaman_stormstrike"] = { name = "Stormstrike", description = "Cast Stormstrike when off cooldown", details = "Cast Stormstrike when off cooldown. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_strength_of_earth_totem"] = { name = "Strength of Earth Totem", description = "Maintain and cast Strength of Earth Totem", details = "Maintain and cast Strength of Earth Totem." }
Cat2.Locals.Cards["shaman_totem_difference_override"] = { name = "Totem Difference Override", description = "Force-overwrite an existing different totem of the same school", details = "Force-overwrite an existing (already placed) different totem of the same school. Passive rule; affects the current flow while enabled." }
Cat2.Locals.Cards["shaman_tranquil_air_totem"] = { name = "Tranquil Air Totem", description = "Maintain and cast Tranquil Air Totem", details = "Maintain and cast Tranquil Air Totem." }
Cat2.Locals.Cards["shaman_tremor_totem"] = { name = "Tremor Totem", description = "Maintain and cast Tremor Totem", details = "Maintain and cast Tremor Totem." }
Cat2.Locals.Cards["shaman_water_shield"] = { name = "Water Shield", description = "Cast Water Shield; only one shield can be active at a time", details = "Cast Water Shield; only one shield can be active at a time." }
Cat2.Locals.Cards["shaman_windfury_totem"] = { name = "Windfury Totem", description = "Maintain and cast Windfury Totem", details = "Maintain and cast Windfury Totem." }
Cat2.Locals.Cards["shaman_windfury_weapon"] = { name = "Windfury Weapon", description = "Cast Windfury Weapon on yourself", details = "Cast Windfury Weapon on yourself. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shaman_windwall_totem"] = { name = "Windwall Totem", description = "Maintain and cast Windwall Totem", details = "Maintain and cast Windwall Totem." }
Cat2.Locals.Cards["warlock_conflagrate"] = { name = "Conflagrate", description = "Cast Conflagrate when off cooldown", details = "Cast Conflagrate when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_conflagrate_immolate"] = { name = "Conflagrate (Immolate)", description = "Cast Conflagrate when off cooldown while Immolate has enough remaining time", details = "Cast Conflagrate when off cooldown while Immolate has enough remaining time. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_corruption"] = { name = "Corruption", description = "Maintain and cast Corruption on the target", details = "Maintain and cast Corruption on the target. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_curse_of_agony"] = { name = "Curse of Agony", description = "Maintain and cast Curse of Agony", details = "Maintain and cast Curse of Agony. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_curse_of_doom"] = { name = "Curse of Doom", description = "Cast Curse of Doom when off cooldown", details = "Cast Curse of Doom when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_curse_of_exhaustion"] = { name = "Curse of Exhaustion", description = "Maintain and cast Curse of Exhaustion", details = "Maintain and cast Curse of Exhaustion. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_curse_of_recklessness"] = { name = "Curse of Recklessness", description = "Maintain and cast Curse of Recklessness", details = "Maintain and cast Curse of Recklessness. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_curse_of_recklessness_hex"] = { name = "Curse of Recklessness (Curse of Agony)", description = "Maintain and cast Curse of Recklessness and Curse of Agony", details = "Maintain and cast Curse of Recklessness and Curse of Agony. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_curse_of_shadow"] = { name = "Curse of Shadow", description = "Maintain and cast Curse of Shadow", details = "Maintain and cast Curse of Shadow. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_curse_of_shadow_hex"] = { name = "Curse of Shadow (Curse of Agony)", description = "Maintain and cast Curse of Shadow and Curse of Agony", details = "Maintain and cast Curse of Shadow and Curse of Agony. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_curse_of_the_elements"] = { name = "Curse of the Elements", description = "Maintain and cast Curse of the Elements", details = "Maintain and cast Curse of the Elements. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_curse_of_the_elements_hex"] = { name = "Curse of the Elements (Curse of Agony)", description = "Maintain and cast Curse of the Elements and Curse of Agony", details = "Maintain and cast Curse of the Elements and Curse of Agony. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_curse_of_tongues"] = { name = "Curse of Tongues", description = "Maintain and cast Curse of Tongues", details = "Maintain and cast Curse of Tongues. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_curse_of_weakness"] = { name = "Curse of Weakness", description = "Maintain and cast Curse of Weakness", details = "Maintain and cast Curse of Weakness. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_drain_life"] = { name = "Drain Life", description = "Cast Drain Life", details = "Cast Drain Life. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_drain_mana"] = { name = "Drain Mana", description = "Cast Drain Mana", details = "Cast Drain Mana. Requires a valid target." }
Cat2.Locals.Cards["warlock_drain_soul"] = { name = "Drain Soul", description = "Cast Drain Soul", details = "Cast Drain Soul. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_fel_domination"] = { name = "Fel Domination", description = "Cast Fel Domination when off cooldown", details = "Cast Fel Domination when off cooldown. Attempts only when the ability is usable." }
Cat2.Locals.Cards["warlock_health_funnel"] = { name = "Health Funnel", description = "Cast Health Funnel", details = "Cast Health Funnel. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_immolate"] = { name = "Immolate", description = "Maintain and cast Immolate on the target", details = "Maintain and cast Immolate on the target. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_life_tap"] = { name = "Life Tap (Mana < 50%)", description = "Cast Life Tap when mana is below 50%", details = "Cast Life Tap when mana is below 50%. Checks relevant health. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_life_tap_30"] = { name = "Life Tap (Mana < 30%)", description = "Cast Life Tap when mana is below 30%", details = "Cast Life Tap when mana is below 30%. Checks relevant health. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_life_tap_70"] = { name = "Life Tap (Mana < 70%)", description = "Cast Life Tap when mana is below 70%", details = "Cast Life Tap when mana is below 70%. Checks relevant health. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_major_curse_only_boss"] = { name = "Major Curse (Elite Enemies Only)", description = "Major curses only apply to elite enemies", details = "Major curses only apply to elite enemies. Passive rule; affects the current flow while enabled." }
Cat2.Locals.Cards["warlock_mana_channel"] = { name = "Mana Channel", description = "Cast Mana Channel", details = "Cast Mana Channel. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_nightfall"] = { name = "Nightfall", description = "Cast an instant Shadow Bolt when Nightfall triggers", details = "Cast an instant Shadow Bolt when Nightfall triggers. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_power_overwhelming"] = { name = "Power Overwhelming", description = "Strengthen the current summoned demon", details = "Strengthen the current summoned demon. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_searing_pain"] = { name = "Searing Pain", description = "Cast Searing Pain; useful as a filler", details = "Cast Searing Pain; useful as a filler. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_shadow_bolt"] = { name = "Shadow Bolt", description = "Cast Shadow Bolt; useful as a filler", details = "Cast Shadow Bolt; useful as a filler. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_shadowburn"] = { name = "Shadowburn", description = "Cast Shadowburn when off cooldown", details = "Cast Shadowburn when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_shadow_harvest"] = { name = "Shadow Harvest", description = "Channel Shadow Harvest when off cooldown", details = "Channel Shadow Harvest when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_siphon_life"] = { name = "Siphon Life", description = "Maintain and cast Siphon Life on the target", details = "Maintain and cast Siphon Life on the target. Requires a valid target. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["warlock_soul_fire"] = { name = "Soul Fire", description = "Cast Soul Fire when off cooldown", details = "Cast Soul Fire when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["shared_healing_party"] = { name = "Priority Party", description = "Healing strategy: prioritize healing party members", details = "Healing strategy: prioritize healing party members. Passive rule; affects the current flow while enabled." }
Cat2.Locals.Cards["shared_healing_self"] = { name = "Priority Self", description = "Healing strategy: prioritize healing yourself", details = "Healing strategy: prioritize healing yourself. Passive rule; affects the current flow while enabled." }
Cat2.Locals.Cards["shared_healing_target"] = { name = "Priority Target", description = "Healing strategy: prioritize healing the target", details = "Healing strategy: prioritize healing the target. Passive rule; affects the current flow while enabled." }
Cat2.Locals.Cards["shared_healing_target_target"] = { name = "Priority Target of Target", description = "Healing strategy: prioritize healing the target of the target", details = "Healing strategy: prioritize healing the target of the target. Passive rule; affects the current flow while enabled." }
Cat2.Locals.Cards["shared_healing_team"] = { name = "Heal Team - Lowest Health", description = "Heal team members, prioritizing the member with the lowest health", details = "Heal team members, prioritizing the member with the lowest health. Passive rule; affects the current flow while enabled." }
Cat2.Locals.Cards["shared_healing_team_priority_tank"] = { name = "Heal Team - Priority Tank (Untested)", description = "Heal team members prioritizing maximum health; tanks usually have the most", details = "Heal team members prioritizing maximum total health; tanks usually have the highest total health. Passive rule; affects the current flow while enabled." }
Cat2.Locals.Cards["shared_random_healing_team"] = { name = "Heal Team - Random", description = "Heal team members, randomly selecting one that has taken damage", details = "Heal team members, randomly selecting one that has taken damage. Passive rule; affects the current flow while enabled." }

Cat2.Locals.Cards["common_auto_attack"] = { name = "Auto Attack", description = "Start or maintain an auto attack", details = "Start or maintain an auto attack." }
Cat2.Locals.Cards["common_auto_attack_pet"] = { name = "Pet Auto Attack", description = "Send the pet to start or maintain an auto attack", details = "When a pet is present, sends it to start or maintain an auto attack without restricting whether the target is already in combat." }
Cat2.Locals.Cards["common_auto_attack_pet_target_combat"] = { name = "Pet Auto Attack (In-Combat Target)", description = "After the target enters combat, send the pet to start or maintain an auto attack", details = "When the pet is present and the current target has entered combat, sends the pet to start or maintain an auto attack." }
Cat2.Locals.Cards["common_auto_pick"] = { name = "Auto Interact", description = "Auto loot objects such as corpses and robots; requires module support", details = "Auto loot objects such as monster corpses and robots. Requires the Interact module or the WSLoot module. Checks target distance." }
Cat2.Locals.Cards["common_auto_target"] = { name = "Auto Target (Melee)", description = "Select a nearby hostile target in front of you", details = "Selects the nearest nearby hostile target, checking facing and line of sight. Dead targets are discarded; otherwise the current target is kept when no suitable replacement exists. Refreshes character data immediately after switching or clearing the target and continues the round. Without SuperWoW, falls back to the native nearest target: no guarantee of melee range, facing, line of sight, or critter filtering." }
Cat2.Locals.Cards["common_auto_target_distant"] = { name = "Auto Target (Farthest Enemy)", description = "Select a distant hostile target within the facing cone; requires the UnitXP module", details = "Selects the farthest hostile target within 8 to 41 yards in front of you. Only applies to attackable, alive, non-critter targets. With Auto Target: Ignore Out-of-Combat enabled, targets that have not entered combat are also excluded. Dead targets are discarded; otherwise the current target is kept when no suitable replacement exists. Refreshes character data immediately after switching or clearing the target and continues the round. Without SuperWoW, enemies cannot be scanned and this card will not auto-target." }
Cat2.Locals.Cards["common_auto_target_ignore_out_of_combat"] = { name = "Auto Target: Ignore Out-of-Combat Targets", description = "Auto Target and its branches will not select targets that have not entered combat", details = "While enabled, Auto Target (Melee), Auto Target (Ranged), Auto Target (Outside 8 yd), and Auto Target (Farthest Enemy) only select hostile targets already in combat. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["common_auto_target_outside_8"] = { name = "Auto Target (Outside 8 yd)", description = "For |cffABD473Hunters|r; selects targets beyond 8 yards; requires UnitXP 20260720 or newer", details = "For hunters, prioritizes pierced and strung targets among hostile enemies within 8 to 41 yards in front of you. Dead targets are discarded; otherwise the current target is kept when no suitable replacement exists. Refreshes character data immediately after switching or clearing the target and continues the round. With insufficient UnitXP versions, degrades to scanning and selecting the nearest eligible target; without SuperWoW, auto-targeting is unavailable." }
Cat2.Locals.Cards["common_auto_target_ranged"] = { name = "Auto Target (Ranged)", description = "Select the nearest hostile target in front of you within |cff6bc7e0{maximumDistance} yd|r", details = "Selects the nearest hostile target within the configured distance, checking facing and line of sight; the default maximum distance is 41 yards. Dead targets are discarded; otherwise the current target is kept when no suitable replacement exists. Refreshes character data immediately after switching or clearing the target and continues the round. Without SuperWoW, falls back to the native nearest target: no guarantee of distance, facing, line of sight, or critter filtering." }
Cat2.Locals.Cards["common_auto_trinket_lower"] = { name = "Auto Trinket (Lower Slot)", description = "Use the trinket in the lower trinket slot", details = "Uses the trinket in the lower trinket slot. Checks target distance. Checks combat state. Attempts only when the item is usable." }
Cat2.Locals.Cards["common_auto_trinket_upper"] = { name = "Auto Trinket (Upper Slot)", description = "Use the trinket in the upper trinket slot", details = "Uses the trinket in the upper trinket slot. Checks target distance. Checks combat state. Attempts only when the item is usable." }
Cat2.Locals.Cards["common_burst_auto_trinket_lower"] = { name = "Burst Auto Trinket (Lower Slot)", description = "Automatically use the lower trinket when it matches the burst whitelist", details = "Automatically uses the trinket in the lower slot when it is equipped from the burst trinket whitelist. Checks target distance. Checks combat state. Attempts only when the item is usable." }
Cat2.Locals.Cards["common_burst_auto_trinket_upper"] = { name = "Burst Auto Trinket (Upper Slot)", description = "Automatically use the upper trinket when it matches the burst whitelist", details = "Automatically uses the trinket in the upper slot when it is equipped from the burst trinket whitelist. Checks target distance. Checks combat state. Attempts only when the item is usable." }
Cat2.Locals.Cards["common_capture_elemental_immunity"] = { name = "Capture Elemental Immunity", description = "While the flow runs, allow capturing elemental damage immunities", details = "While enabled, each run of the current flow opens or renews a 3-second elemental immunity capture window; three seconds after the flow stops running, no new immunities are learned. Already-captured results remain in effect for the current game session, and the static immunity list is unaffected. Requires SuperWoW." }
Cat2.Locals.Cards["common_fishing_auto_bait"] = { name = "Fishing (Auto Bait)", description = "Use |cff6bc7e0{baitItemName}|r to automatically bait the fishing rod and cast", details = "Starts fishing; when the fishing rod lacks a bait effect, attempts to use the bait item entered in the parameters, defaulting to the Bright Bauble. Skips baiting when the bait name is empty or the item is not in the bag." }
Cat2.Locals.Cards["common_flow_terminate"] = { name = "Flow Terminate", description = "Immediately terminate the current round and block subsequent cards", details = "On execution, returns success and terminates the current round; subsequent cards will not run. Mainly used for debugging and isolating issues in the flow." }
Cat2.Locals.Cards["common_ranged_attack"] = { name = "Ranged Attack (Shoot/Wand/Throw)", description = "Use the equipped ranged weapon to attack at range", details = "Automatically selects wand shooting, auto shot, bow/gun/crossbow shooting, or throwing based on the currently equipped ranged weapon. Does nothing when no valid ranged weapon is equipped." }
Cat2.Locals.Cards["common_view_my_casts"] = { name = "View My Casts", description = "After a successful cast, print the spell name and rank to chat", details = "Listens for spells actively cast by the player and prints the spell name and rank to chat. With an empty chat window it uses the default chat frame; entering a window tab name attempts to output to that window, falling back to the default frame if not found. Filters spellbook passives and most triggered effects. Only active while the current flow is enabled." }
Cat2.Locals.Cards["common_view_my_casts_detailed"] = { name = "View My Casts (Detailed)", description = "Show the full event information for player casts and procs", details = "Listens to the player's full cast events, including active spells, passive effects, and triggered procs, printing the spell name, rank, and target to chat. With an empty chat window it uses the default chat frame; entering a window tab name attempts to output to that window, falling back to the default frame if not found. Only active while the current flow is enabled." }
Cat2.Locals.Cards["druid_abolish_poison"] = { name = "Abolish Poison", description = "Cast Abolish Poison when poisoned, following the |cffb87ff0[Passive Card]|r rules", details = "Casts Abolish Poison when the current target is a living ally with a poison effect. Attempts only when the ability is usable; stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["druid_auto_form_idol"] = { name = "Auto Form Idol", description = "Bear form: |cff6bc7e0{bearIdol}|r, cat form: |cff6bc7e0{catIdol}|r", details = "Automatically equips the selected idol based on the current form: Bear Form and Dire Bear Form default to the Brutal Idol, Cat Form defaults to the Ferocious Idol. Leaving a selection empty skips switching for that form. Only swaps gear when the global cooldown has ended and the bank, auction house, mailbox, or vendor frame is not open. Does not swap repeatedly when the target idol is already equipped or is not in the bag. Stops the rest of the round after a successful swap." }
Cat2.Locals.Cards["druid_berserk_bear"] = { name = "Berserk (Bear)", description = "Cast Berserk when health is below |cff6bc7e0{triggerPercent}%|r", details = "When the ability is off cooldown and health is below the card threshold, casts Berserk. Requires a valid target. Checks target distance. Checks current health. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_berserk_bear_boss"] = { name = "Berserk (Bear, Elite Enemies Only)", description = "Cast Berserk only against elite enemies when health is below |cff6bc7e0{triggerPercent}%|r", details = "Casts Berserk only against elite enemies when health is below the card threshold. Requires a valid target. Checks target distance. Checks current health. Attempts only when the ability is usable. Stops the rest of the sequence on success." }
Cat2.Locals.Cards["druid_combo_point_idol_4"] = { name = "Combo Point Idol (4+ CP)", description = "Equip |cff6bc7e0{lowComboIdol}|r, then equip |cff6bc7e0{highComboIdol}|r at 4-5 combo points", details = "Only in Cat Form, switches the idol based on the current target's combo points: 0-3 default to the Ferocious Idol, 4-5 default to the Shredding Idol. Leaving a selection empty skips switching for that combo point range. Only swaps gear when the global cooldown has ended and the bank, auction house, mailbox, or vendor frame is not open. Does not swap repeatedly when the target idol is already equipped or is not in the bag. Stops the rest of the round after a successful swap." }
Cat2.Locals.Cards["druid_combo_point_idol_5"] = { name = "Combo Point Idol (5+ CP)", description = "Equip |cff6bc7e0{lowComboIdol}|r, then equip |cff6bc7e0{highComboIdol}|r at 5 combo points", details = "Only in Cat Form, switches the idol based on the current target's combo points: 0-4 default to the Ferocious Idol, 5 default to the Shredding Idol. Leaving a selection empty skips switching for that combo point range. Only swaps gear when the global cooldown has ended and the bank, auction house, mailbox, or vendor frame is not open. Does not swap repeatedly when the target idol is already equipped or is not in the bag. Stops the rest of the round after a successful swap." }
Cat2.Locals.Cards["druid_faerie_fire_clearcasting"] = { name = "Faerie Fire (Clearcasting)", description = "Cast Faerie Fire to gamble for a Clearcasting proc", details = "Casts Faerie Fire to gamble for a Clearcasting proc. Requires a valid target. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["druid_faerie_fire_feral_clearcasting"] = { name = "Faerie Fire (Feral, Clearcasting)", description = "Cast Faerie Fire to gamble for a Clearcasting proc", details = "Casts Faerie Fire to gamble for a Clearcasting proc. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["druid_faerie_fire_feral_melee_only"] = { name = "Faerie Fire (Feral, Melee Range Only)", description = "Both Feral Faerie Fire cards only work within melee range", details = "While enabled, Faerie Fire (Feral) and Faerie Fire (Feral, Clearcasting) only execute when the target is within melee range. Does not affect the Balance Faerie Fire. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["druid_feral_charge_auto_form"] = { name = "Feral Charge (Auto Form)", description = "Automatically switch to Bear Form and cast Feral Charge from beyond 8 yards", details = "When the target is beyond 8 yards and Feral Charge is usable, automatically switches to Bear Form or Dire Bear Form and casts Feral Charge. Works both in and out of combat. Requires a valid target; at least 5 rage in Bear Form. Checks the ability, target distance, and current resources. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["druid_frenzied_regeneration"] = { name = "Frenzied Regeneration", description = "Cast Frenzied Regeneration when health is below |cff6bc7e0{triggerPercent}%|r", details = "Casts Frenzied Regeneration when your health is below the card threshold. The default trigger health is 30%. Attempts only when the ability is usable; stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["druid_hurricane_self"] = { name = "Hurricane (Self)", description = "Cast Hurricane centered on yourself; requires UnitXP 202607 or newer", details = "When the ability is off cooldown, casts Hurricane centered on yourself. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["druid_hurricane_target"] = { name = "Hurricane (Target)", description = "Cast Hurricane centered on the target; requires UnitXP 202607 or newer", details = "When the ability is off cooldown and a valid target exists, casts Hurricane centered on the target. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["druid_insect_swarm_solar_eclipse"] = { name = "Insect Swarm (Solar Eclipse)", description = "Cast Nature damage over time while Solar Eclipse is active", details = "Runs the original Insect Swarm logic only while Solar Eclipse is active. Requires a valid target; does not cast when the target is Nature-immune or already affected by Insect Swarm. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["druid_moonfire_lunar_eclipse"] = { name = "Moonfire (Lunar Eclipse)", description = "Cast Arcane damage over time while Lunar Eclipse is active", details = "Runs the original Moonfire logic only while Lunar Eclipse is active. Requires a valid target; does not cast when the target is Arcane-immune or already affected by Moonfire. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["druid_natures_swiftness_healing_touch"] = { name = "Nature's Swiftness: Healing Touch", description = "Cast when health is below |cff6bc7e0{triggerPercent}%|r, following the |cffb87ff0[Passive Card]|r rules", details = "Casts Nature's Swiftness followed by Healing Touch when health falls below the card threshold, following the |cffb87ff0[Passive Card]|r rules. Uses the default value 30% when not set separately. Requires a valid target. Affects friendly living targets only. Checks combat state, distance, line of sight, relevant health, and ability availability." }
Cat2.Locals.Cards["druid_natures_swiftness_regrowth"] = { name = "Nature's Swiftness: Regrowth", description = "Cast when health is below |cff6bc7e0{triggerPercent}%|r, following the |cffb87ff0[Passive Card]|r rules", details = "Casts Nature's Swiftness followed by Regrowth when health falls below the card threshold, following the |cffb87ff0[Passive Card]|r rules. Uses the default value 30% when not set separately. Requires a valid target. Affects friendly living targets only. Checks combat state, distance, line of sight, relevant health, and ability availability." }
Cat2.Locals.Cards["druid_rake_only_boss"] = { name = "Rake (Elite Enemies Only)", description = "Rake only affects elite enemy targets", details = "While enabled, Rake only targets enemies marked as elites; normal targets are ignored. This card only writes a flow flag and does not actively cast. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["druid_remove_curse"] = { name = "Remove Curse", description = "Cast Remove Curse when cursed, following the |cffb87ff0[Passive Card]|r rules", details = "Scans friendly units in the target order provided by the healing-target passive card and casts Remove Curse when a curse effect is found. Checks the casting state, global cooldown, distance, and line of sight." }
Cat2.Locals.Cards["druid_rip_only_boss"] = { name = "Rip (Elite Enemies Only)", description = "Rip only affects elite enemy targets", details = "While enabled, Rip of 1-5 combo points only targets enemies marked as elites; normal targets are ignored. This card only writes a flow flag and does not actively cast. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["druid_shred_preferred_claw_assist"] = { name = "Shred Preferred with Claw Assist", description = "Auto-detect: primarily Shred, Claw when energy would overflow from the front", details = "Auto-detect: Shred from behind, Claw from the front. Requires a valid target. Checks current resources. Checks relative position to the target. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["druid_starfire_idol_switch"] = { name = "Starfire Idol Switch", description = "Switch to |cff6bc7e0{idolName}|r before casting Starfire", details = "When Starfire or its branches meet the cast conditions, attempts to switch the relic slot to the selected idol before actually casting. Does not repeat when the idol is already equipped or is not in the bag. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["druid_wrath_idol_switch"] = { name = "Wrath Idol Switch", description = "Switch to |cff6bc7e0{idolName}|r before casting Wrath", details = "When Wrath or its branches meet the cast conditions, attempts to switch the relic slot to the selected idol before actually casting. Does not repeat when the idol is already equipped or is not in the bag. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["hunter_aimed_shot_lock_and_load"] = { name = "Aimed Shot (Lock and Load)", description = "Only when Lock and Load is active and the target is at least 8 yards away", details = "Uses Aimed Shot only while Lock and Load is active. Reduces auto-shot interference when the target is at least 8 yards away. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["hunter_auto_aspect_of_the_viper"] = { name = "Auto Aspect of the Viper (Mana Regen)", description = "Start mana regen when mana is below |cff6bc7e0{triggerManaPercent}%|r, stop when above |cff6bc7e0{stopManaPercent}%|r", details = "When mana falls below the trigger value, automatically switches to and maintains Aspect of the Viper; when mana rises above the stop value, leaves mana regen. Uses trigger mana 30% and stop trigger 50% when not set separately. This card is not part of the aspect group and can be loaded alongside normal aspect cards." }
Cat2.Locals.Cards["hunter_auto_trap"] = { name = "Auto Trap", description = "While the target is in combat, automatically pick a trap based on nearby enemy count; requires SuperWoW", details = "When the target is in combat and enemies are nearby, picks the trap based on enemy count: Explosive Trap with at least 2 enemies, Immolation Trap with 1 enemy. Requires SuperWoW." }
Cat2.Locals.Cards["hunter_feign_death_boss_watching"] = { name = "Feign Death (Elite Watching)", description = "Feign Death when watched by a current elite in combat; blocks the flow while feigning", details = "In combat, when the current target is judged an elite and its target is you, casts Feign Death once the ability is off cooldown and ends the round. Captures the Feign Death buff removal event via Nampower and restores the cooldown record from when the effect ends. While the Feign Death buff exists, executing this card blocks subsequent cards regardless of combat state or having a target. No configurable parameters. Recommended near the front of the flow to prevent earlier attack cards from interrupting Feign Death." }
Cat2.Locals.Cards["hunter_flare_self"] = { name = "Flare (Self)", description = "Use Flare centered on yourself; requires UnitXP 202607 or newer", details = "When the ability is off cooldown, uses Flare centered on yourself. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["hunter_flare_target"] = { name = "Flare (Target)", description = "Use Flare centered on the target; requires UnitXP 202607 or newer", details = "When the ability is off cooldown and a valid target exists, uses Flare centered on the target. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["hunter_hunters_mark_boss"] = { name = "Hunter's Mark (Elite Enemies Only)", description = "Apply and maintain Hunter's Mark only on elite enemy targets", details = "Applies and maintains Hunter's Mark only on elite enemy targets. Requires a valid target; does not cast when the target is Arcane-immune. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["hunter_multi_shot_multiple_targets"] = { name = "Multi-Shot (Multiple Targets Only)", description = "Only cast Multi-Shot when multiple targets are present; requires SuperWoW + UnitXP", details = "Casts Multi-Shot only when multiple targets are present and the target is at least 8 yards away. Requires SuperWoW + UnitXP. Attempts only when the ability is usable. Successfully casting stops the rest of the round." }
Cat2.Locals.Cards["hunter_tranquilizing_shot"] = { name = "Tranquilizing Shot", description = "Cast Tranquilizing Shot when the target enrages", details = "Casts Tranquilizing Shot when the target has Frenzy, Insanity, or Shadow Claw Enrage. Attempts only when the ability is off cooldown. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["hunter_volley_target"] = { name = "Volley (Target)", description = "Use Volley centered on the target; requires UnitXP 202607 or newer", details = "When the ability is off cooldown and a valid target exists, uses Volley centered on the target. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["hunter_wing_clip_always"] = { name = "Wing Clip (Always Cast)", description = "Cast Wing Clip directly when the target is within 8 yards and off cooldown", details = "Casts Wing Clip directly when the target is within 8 yards of melee range and the ability is off cooldown, without checking whether the target already has Wing Clip. Requires a valid target. Checks target distance. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["item_burst_only_melee"] = { name = "Burst Potions (Melee Range Only)", description = "Burst potions only activate when close to an enemy", details = "Burst potions only activate within melee range. As a passive rule, affects Thistle Tea, Swiftness Potion, Great Rage Potion, and Haste Potion in the current flow while enabled." }
Cat2.Locals.Cards["item_demonic_rune_mana"] = { name = "Demonic Rune (Mana)", description = "Use a Demonic Rune when mana is below |cff6bc7e0{manaPercent}%|r and health is above |cff6bc7e0{minimumHealth}|r", details = "Uses a Demonic Rune when mana is below the configured value and current health is above the configured value. Uses default mana 30% and minimum health 1100 when not set separately." }
Cat2.Locals.Cards["item_dense_dynamite_self"] = { name = "Dense Dynamite (Self)", description = "Throw Dense Dynamite at your own location; requires UnitXP 202607 or newer", details = "When the item is off cooldown, throws Dense Dynamite at your own location. Stops the rest of the round after a successful use." }
Cat2.Locals.Cards["item_dense_dynamite_target"] = { name = "Dense Dynamite (Target)", description = "Throw Dense Dynamite at the target; requires UnitXP 202607 or newer", details = "When the item is off cooldown and a valid target exists, throws Dense Dynamite at the target. Stops the rest of the round after a successful use." }
Cat2.Locals.Cards["item_goblin_sapper_bomb"] = { name = "Goblin Sapper Charge", description = "Use when at least |cff6bc7e0{enemyThreshold}|r enemies are nearby and off cooldown; requires SuperWoW", details = "Uses a Goblin Sapper Charge when the number of nearby enemies reaches the card threshold and the cooldown is ready. The default enemy threshold is 6. Enemy scanning requires the SuperWoW module. Stops the rest of the round after a successful use." }
Cat2.Locals.Cards["item_limited_invulnerability_potion"] = { name = "Limited Invulnerability Potion", description = "Use a Limited Invulnerability Potion when health is below |cff6bc7e0{triggerPercent}%|r", details = "Uses a Limited Invulnerability Potion when health in combat is below the card threshold. Uses the default value 30% when not set separately." }
Cat2.Locals.Cards["item_limited_invulnerability_potion_boss_watching"] = { name = "Limited Invulnerability Potion (Elite Watching)", description = "Use a Limited Invulnerability Potion when the current elite target is facing you", details = "In combat, uses a Limited Invulnerability Potion when the current target is judged an elite and its target is you. This card has no configurable parameters." }
Cat2.Locals.Cards["item_stratholme_holy_water_self"] = { name = "Stratholme Holy Water (Self)", description = "Throw Holy Water at your own location; requires UnitXP 202607 or newer", details = "When the item is off cooldown, throws Stratholme Holy Water at your own location. Requires UnitXP 202607 or newer; Stops the rest of the round after a successful use." }
Cat2.Locals.Cards["item_stratholme_holy_water_target"] = { name = "Stratholme Holy Water (Target)", description = "Throw Holy Water at the target; requires UnitXP 202607 or newer", details = "When the item is off cooldown and a valid target exists, throws Stratholme Holy Water at the target. Requires UnitXP 202607 or newer; Stops the rest of the round after a successful use." }
Cat2.Locals.Cards["mage_arcane_fracture_interrupt_channel"] = { name = "Arcane Fracture (Interrupt Channel)", description = "Without the Arcane Fracture buff, allow interrupting Arcane Missiles to cast Arcane Fracture", details = "When the player lacks the Arcane Fracture buff and the ability is off cooldown, only allows interrupting the current Arcane Missiles channel to cast Arcane Fracture. Other channels or unidentifiable channels are not interrupted. Casts normally when no channel is active. Requires a valid target; does not cast when the target is Arcane-immune. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["mage_arcane_fracture_without_buff"] = { name = "Arcane Fracture (Without Buff)", description = "Cast Arcane Fracture when the Arcane Fracture buff is missing", details = "Casts Arcane Fracture when the player lacks the Arcane Fracture buff and the ability is off cooldown. Requires a valid target; does not cast when the target is Arcane-immune. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["mage_arcane_surge_arcane_fracture_ending"] = { name = "Arcane Surge: Arcane Fracture Ending", description = "Ignore Arcane Surge while Arcane Fracture is present", details = "Ignores Arcane Surge while Arcane Fracture is present. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["mage_blast_wave"] = { name = "Blast Wave", description = "Cast Blast Wave when at least one enemy is within |cff6bc7e0{scanRange} yd|r", details = "Casts Blast Wave when the spell is learned and at least 1 enemy is within the configured distance, defaulting to a 10-yard scan. Enemy scanning requires SuperWoW and UnitXP. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["mage_blizzard_self"] = { name = "Blizzard (Self)", description = "Cast Blizzard of rank |cff6bc7e0{spellRank}|r centered on yourself", details = "Casts Blizzard of the configured rank centered on yourself, dynamically using the highest learned rank by default; requires UnitXP 202607 or newer. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["mage_blizzard_target"] = { name = "Blizzard (Target)", description = "Cast Blizzard of rank |cff6bc7e0{spellRank}|r centered on the target", details = "Casts Blizzard of the configured rank centered on the target, dynamically using the highest learned rank by default; requires UnitXP 202607 or newer. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["mage_combustion_after_five_vulnerability"] = { name = "Combustion (After Five Vulnerability)", description = "Combustion and its branches only cast when the target has five Fire vulnerabilities", details = "While enabled, Combat and Combustion (Elite Enemies Only) in the flow wait until the current target reaches five Fire vulnerabilities before casting. The passive effect is not affected by this card's placement in the flow; pausing or removing this card restores the original logic of both Combustion cards." }
Cat2.Locals.Cards["mage_continue_ignite_scorch_fire_blast"] = { name = "Continue Ignite (Scorch, Fire Blast)", description = "When Ignite per-tick damage exceeds |cff6bc7e0{igniteDamageThreshold}|r, attempt to continue the Ignite", details = "Requires SuperWoW, Nampower, and UnitXP. When the current target has an Ignite belonging to the player and the current per-tick damage is strictly above the configured threshold: if the remaining time is under 1 second and Fire Blast is off cooldown, casts Fire Blast; otherwise keeps casting Scorch. Does not cast when the target is Fire-immune or beyond the cast range of either spell. Does nothing and does not block when required modules are missing or the damage has not reached the threshold; Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["mage_fire_blast_move"] = { name = "Fire Blast (While Moving)", description = "Cast Fire Blast while moving when off cooldown", details = "Casts Fire Blast while moving when off cooldown. Requires a valid target; does not cast when the target is Fire-immune. Checks target distance and movement state. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["mage_flamestrike_self"] = { name = "Flamestrike (Self)", description = "Cast Flamestrike centered on yourself; requires UnitXP 202607 or newer", details = "Casts Flamestrike centered on yourself. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["mage_flamestrike_target"] = { name = "Flamestrike (Target)", description = "Cast Flamestrike centered on the target; requires UnitXP 202607 or newer", details = "When a valid target exists, casts Flamestrike and places the ground marker on the current target's position. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["mage_remove_lesser_curse"] = { name = "Remove Lesser Curse", description = "Cast Remove Lesser Curse when cursed, following the |cffb87ff0[Passive Card]|r rules", details = "Scans friendly units in the target order provided by the healing-target passive card and casts Remove Lesser Curse when a curse effect is found. Checks the casting state, global cooldown, distance, and line of sight." }
Cat2.Locals.Cards["mage_view_my_ignite"] = { name = "View My Ignite", description = "Show Ignite start, end, target, and current per-tick damage", details = "Identifies Ignite ownership via Nampower structured damage and aura events, showing only Ignites owned by the player: start, end, hit target, and current per-tick damage, without predicted or accumulated total damage. With an empty chat window it uses the default chat frame; entering a window tab name attempts to output to that window, falling back to the default frame if not found. Only active while the current flow is enabled." }
Cat2.Locals.Cards["paladin_blessing_of_sanctuary_self"] = { name = "Blessing of Sanctuary (Self)", description = "Cast and keep Blessing of Sanctuary on yourself", details = "Casts Blessing of Sanctuary on yourself when you lack either Blessing of Sanctuary or Greater Blessing of Sanctuary. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["paladin_cleanse"] = { name = "Cleanse", description = "Dispel poison, disease, or magic debuffs, following the |cffb87ff0[Passive Card]|r rules", details = "Scans friendly units in the target order provided by the healing-target passive card and casts Cleanse when a poison, disease, or magic debuff is found. Checks the casting state, global cooldown, distance, and line of sight." }
Cat2.Locals.Cards["paladin_crusader_strike_no_target"] = { name = "Crusader Strike (No Target Switch)", description = "Cast Crusader Strike without switching targets, for melee healers", details = "Casts Crusader Strike without switching targets, for melee healers. Attempts only when the ability is usable." }
Cat2.Locals.Cards["paladin_fire_resistance_aura"] = { name = "Fire Resistance Aura", description = "Switch to and keep Fire Resistance Aura active", details = "Switches to and keeps Fire Resistance Aura active." }
Cat2.Locals.Cards["paladin_frost_resistance_aura"] = { name = "Frost Resistance Aura", description = "Switch to and keep Frost Resistance Aura active", details = "Switches to and keeps Frost Resistance Aura active." }
Cat2.Locals.Cards["paladin_holy_shield_target_watching"] = { name = "Holy Shield (Target Watching You)", description = "Cast Holy Shield when off cooldown and the target is facing you", details = "Casts Holy Shield when off cooldown and the target is facing you. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["paladin_holy_shock_attack"] = { name = "Holy Shock (Attack)", description = "Cast Holy Shock on the current enemy target", details = "Casts Holy Shock on the current attackable target. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["paladin_holy_shock_move"] = { name = "Holy Shock (Heal, While Moving)", description = "While moving, cast when health is below |cff6bc7e0{triggerPercent}%|r, following the |cffb87ff0[Passive Card]|r rules", details = "While moving, casts Holy Shock when health falls below the card threshold, following the |cffb87ff0[Passive Card]|r rules. Uses the default value 90% when not set separately. Requires a valid target. Affects attackable targets only. Checks relevant health and movement state. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["paladin_keep_frenzy_no_target"] = { name = "Keep Frenzy (No Target Switch)", description = "When Frenzy has at most |cff6bc7e0{frenzyRemainingSeconds} sec|r left, cast Crusader Strike without switching targets", details = "When Frenzy is absent, ended, or has no more than the card threshold remaining, attempts to cast following the original no-target Crusader Strike logic. The default refresh window is 10 seconds. Attempts only when the ability is usable." }
Cat2.Locals.Cards["paladin_punishment_aura"] = { name = "Retribution Aura", description = "Switch to and keep Retribution Aura active", details = "Switches to and keeps Retribution Aura active." }
Cat2.Locals.Cards["paladin_repentance_boss"] = { name = "Repentance (Elite Enemies Only)", description = "Cast Repentance only on elite enemy targets", details = "Casts Repentance only on elite enemy targets. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["paladin_reset_holy_shock_no_target"] = { name = "Reset: Holy Shock (No Target Switch)", description = "Cast Crusader Strike without switching targets while Holy Shock is on cooldown", details = "Only when a learned Holy Shock is on its own cooldown (the global cooldown is not mistaken for Holy Shock's cooldown), attempts to cast following the original no-target Crusader Strike logic. Attempts only while Crusader Strike is usable." }
Cat2.Locals.Cards["paladin_shadow_resistance_aura"] = { name = "Shadow Resistance Aura", description = "Switch to and keep Shadow Resistance Aura active", details = "Switches to and keeps Shadow Resistance Aura active." }
Cat2.Locals.Cards["paladin_target_health_relic_switch"] = { name = "Target Health Relic Switch", description = "Equip |cff6bc7e0{lowHealthRelic}|r when target health is below 35%, otherwise equip |cff6bc7e0{normalRelic}|r", details = "When a target exists and the global cooldown is about to end, switches the relic based on target health: equips the Low Health Relic below 35%, otherwise the Regular Relic. Both parameters can be picked from the dropdown or typed directly with another relic name; does not switch when the selected relic is not in the bag. Stops the rest of the round after a successful swap." }
Cat2.Locals.Cards["priest_chastise_target"] = { name = "Chastise", description = "Cast Chastise on the current target", details = "Casts Chastise on the current target. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["priest_cure_disease"] = { name = "Cure Disease", description = "Cast Cure Disease when diseased, following the |cffb87ff0[Passive Card]|r rules", details = "Scans friendly units in the target order provided by the healing-target passive card and casts Cure Disease when a disease effect is found and the target does not already have the Cure Disease effect. Checks the casting state, global cooldown, distance, and line of sight." }
Cat2.Locals.Cards["priest_dispel_magic"] = { name = "Dispel Magic", description = "Cast Dispel Magic when under a magic debuff, following the |cffb87ff0[Passive Card]|r rules", details = "Scans friendly units in the target order provided by the healing-target passive card and casts Dispel Magic when a magic debuff is found. Checks the casting state, global cooldown, distance, and line of sight." }
Cat2.Locals.Cards["rogue_backstab_preferred_sinister_assist"] = { name = "Backstab Preferred with Sinister Assist", description = "Auto-detect: prioritize Backstab, Sinister Strike when energy would overflow", details = "Auto-detect, adapting to the main-hand weapon: Backstab from behind, Sinister Strike from the front. Requires a valid target. Checks current resources. Checks relative position to the target. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["rogue_distract_self"] = { name = "Distract (Self)", description = "Use Distract at your own location; requires UnitXP 202607 or newer", details = "When the ability is off cooldown, uses Distract at your own location. Stops the rest of the round after a successful use." }
Cat2.Locals.Cards["rogue_distract_target"] = { name = "Distract (Target)", description = "Use Distract at the target's location; requires UnitXP 202607 or newer", details = "When the ability is off cooldown and a valid target exists, uses Distract at the target's location. Stops the rest of the round after a successful use." }
Cat2.Locals.Cards["rogue_four_weapon_dual_poison_switch"] = { name = "Four-Weapon Dual Poison Switch", description = "Switch among four weapons between dual Dissolve and dual Instant", details = "Reserves four weapons and switches based on the target type; supports only switching between dual Dissolve and dual Instant, and you must keep the backup weapons poisoned in the bag yourself. The switch check interval is 0.1 seconds." }
Cat2.Locals.Cards["rogue_rupture_bloody_1"] = { name = "Rupture (Bloody Breath, 1 CP)", description = "With 1 combo point, refresh Rupture when Bloody Breath has at most |cff6bc7e0{refreshRemainingSeconds} sec|r left", details = "Casts Rupture when the target has 1 combo point and the player's Bloody Breath is absent or has less than the card threshold remaining. The default refresh window is 3 seconds; requires a valid target. Without SuperWoW or below level 60, only the presence of Bloody Breath can be detected, not the exact remaining seconds. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["rogue_rupture_bloody_2"] = { name = "Rupture (Bloody Breath, 2 CP)", description = "With 2 combo points, refresh Rupture when Bloody Breath has at most |cff6bc7e0{refreshRemainingSeconds} sec|r left", details = "Casts Rupture when the target has 2 combo points and the player's Bloody Breath is absent or has less than the card threshold remaining. The default refresh window is 3 seconds; requires a valid target. Without SuperWoW or below level 60, only the presence of Bloody Breath can be detected, not the exact remaining seconds. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["rogue_rupture_bloody_3"] = { name = "Rupture (Bloody Breath, 3 CP)", description = "With 3 combo points, refresh Rupture when Bloody Breath has at most |cff6bc7e0{refreshRemainingSeconds} sec|r left", details = "Casts Rupture when the target has 3 combo points and the player's Bloody Breath is absent or has less than the card threshold remaining. The default refresh window is 3 seconds; requires a valid target. Without SuperWoW or below level 60, only the presence of Bloody Breath can be detected, not the exact remaining seconds. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["rogue_rupture_bloody_4"] = { name = "Rupture (Bloody Breath, 4 CP)", description = "With 4 combo points, refresh Rupture when Bloody Breath has at most |cff6bc7e0{refreshRemainingSeconds} sec|r left", details = "Casts Rupture when the target has 4 combo points and the player's Bloody Breath is absent or has less than the card threshold remaining. The default refresh window is 3 seconds; requires a valid target. Without SuperWoW or below level 60, only the presence of Bloody Breath can be detected, not the exact remaining seconds. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["rogue_rupture_bloody_5"] = { name = "Rupture (Bloody Breath, 5 CP)", description = "With 5 combo points, refresh Rupture when Bloody Breath has at most |cff6bc7e0{refreshRemainingSeconds} sec|r left", details = "Casts Rupture when the target has 5 combo points and the player's Bloody Breath is absent or has less than the card threshold remaining. The default refresh window is 3 seconds; requires a valid target. Without SuperWoW or below level 60, only the presence of Bloody Breath can be detected, not the exact remaining seconds. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["rogue_vanish"] = { name = "Vanish", description = "Cast Vanish when watched by the target and health is below |cff6bc7e0{triggerPercent}%|r", details = "Casts Vanish when watched by the target and health is below the card threshold. Requires a valid target. Attempts only when the ability is usable." }
Cat2.Locals.Cards["shaman_ancestral_swiftness"] = { name = "Ancestral Swiftness: Chain Heal", description = "Cast when health is below |cff6bc7e0{triggerPercent}%|r, following the |cffb87ff0[Passive Card]|r rules", details = "Casts Ancestral Swiftness when health falls below the card threshold, following the |cffb87ff0[Passive Card]|r rules. Uses the default value 30% when not set separately. Requires a valid target. Affects friendly living targets only. Checks combat state, distance, line of sight, relevant health, and ability availability." }
Cat2.Locals.Cards["shaman_ancestral_swiftness_healing_wave"] = { name = "Ancestral Swiftness: Healing Wave", description = "Cast when health is below |cff6bc7e0{triggerPercent}%|r, following the |cffb87ff0[Passive Card]|r rules", details = "Casts Ancestral Swiftness followed by Healing Wave when health falls below the card threshold, following the |cffb87ff0[Passive Card]|r rules. Uses the default value 30% when not set separately. Requires a valid target. Affects friendly living targets only. Checks combat state, distance, line of sight, relevant health, and ability availability." }
Cat2.Locals.Cards["shaman_auto_water_shield_mana"] = { name = "Auto Water Shield (Mana Regen)", description = "Start mana regen when mana is below |cff6bc7e0{triggerManaPercent}%|r, stop when above |cff6bc7e0{stopManaPercent}%|r", details = "When mana falls below the trigger value, automatically casts and maintains Water Shield; when mana rises above the stop value, leaves mana regen. Uses trigger mana 30% and stop trigger 50% when not set separately. This card is not part of the shield group and can be loaded alongside normal shield cards." }
Cat2.Locals.Cards["shaman_cure_disease"] = { name = "Cure Disease", description = "Cast Cure Disease when diseased, following the |cffb87ff0[Passive Card]|r rules", details = "Scans friendly units in the target order provided by the healing-target passive card and casts Cure Disease when a disease effect is found. Checks the casting state, global cooldown, distance, and line of sight." }
Cat2.Locals.Cards["shaman_cure_poison"] = { name = "Cure Poison", description = "Cast Cure Poison when poisoned, following the |cffb87ff0[Passive Card]|r rules", details = "Scans friendly units in the target order provided by the healing-target passive card and casts Cure Poison when a poison effect is found. Checks the casting state, global cooldown, distance, and line of sight." }
Cat2.Locals.Cards["shaman_earth_shock_totem_switch"] = { name = "Earth Shock Totem Switch", description = "Switch to |cff6bc7e0{totemName}|r when using Earth Shock", details = "When the original Earth Shock card's cooldown is about to end and the global cooldown is in its first half, attempts to switch the relic slot to the selected totem without affecting Earth Shock's other branches. The swap itself does not block the flow; only the first eligible totem-linked card of the round is processed. The parameter can be picked from the menu or typed manually with another name; does not repeat when the selected totem is already equipped or is not in the bag. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["shaman_flame_shock_dot"] = { name = "Flame Shock (DoT)", description = "Cast Flame Shock when the target lacks the Flame Shock damage over time", details = "Casts Flame Shock when the target lacks the Flame Shock damage over time. Requires a valid target; does not cast when the target is Fire-immune. When the Shock Totem Switch passive card exists in the flow and its totem name is not empty, pre-swaps gear only within 1.5 seconds before the cooldown ends and while the global cooldown is in its first half; casts only after the ability is truly ready. The gear swap itself does not block the flow. This link only affects the Flame Shock (DoT) card, not other branches. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["shaman_lightning_strike_totem_switch"] = { name = "Lightning Strike Totem Switch", description = "Switch to |cff6bc7e0{totemName}|r when using Lightning Strike", details = "When Lightning Strike's cooldown is about to end and the global cooldown is in its first half, attempts to switch the relic slot to the selected totem. The swap itself does not block the flow; only the first eligible totem-linked card of the round is processed. The parameter can be picked from the menu or typed manually with another name; does not repeat when the selected totem is already equipped or is not in the bag. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["shaman_purge"] = { name = "Purge", description = "Cast Purge when the target has a purgable magic buff", details = "Reads the enemy target's beneficial auras via Nampower and casts Purge only when a purgable magic buff is found. Checks the casting state, global cooldown, target distance, and line of sight; produces no cast action when there is no purgable magic. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["shaman_shock_totem_switch"] = { name = "Shock Totem Switch", description = "Switch to |cff6bc7e0{totemName}|r when using a shock", details = "When Earth Shock, Frost Shock, Flame Shock, or Flame Shock (DoT) cooldowns are about to end and the global cooldown is in its first half, attempts to switch the relic slot to the selected totem without affecting the other branches of these abilities. When Earth Shock has its own dedicated switch passive, that parameter takes priority. The swap itself does not block the flow; only the first eligible totem-linked card of the round is processed. The parameter can be picked from the menu or typed manually with another name; does not repeat when the selected totem is already equipped or is not in the bag. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["shaman_stormstrike_totem_switch"] = { name = "Stormstrike Totem Switch", description = "Switch to |cff6bc7e0{totemName}|r when using Stormstrike", details = "When Stormstrike's cooldown is about to end and the global cooldown is in its first half, attempts to switch the relic slot to the selected totem. The swap itself does not block the flow; only the first eligible totem-linked card of the round is processed. The parameter can be picked from the menu or typed manually with another name; does not repeat when the selected totem is already equipped or is not in the bag. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["shaman_totem_recall"] = { name = "Totem Recall", description = "Recall when farther than |cff6bc7e0{recallDistance} yd|r from a totem; requires the UnitXP module", details = "When you exceed the configured distance from any totem, automatically casts Totem Recall; this occurs when every totem exceeds the distance." }
Cat2.Locals.Cards["shaman_water_shield_highest_stacks"] = { name = "Water Shield (Keep Highest Stacks)", description = "Cast Water Shield; only one shield can persist at a time", details = "Casts Water Shield; only one shield can persist at a time." }
Cat2.Locals.Cards["shared_interrupt_full_health_cast"] = { name = "Interrupt Full-Health Heal Cast", description = "Interrupt a cancellable heal cast when the spell's target reaches full health", details = "When the actual target of a healing spell reaches full health, interrupts the cast or channel marked as cancellable. Switching the current target does not change the monitored target. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["warlock_conflagrate_immolate_auto_timing"] = { name = "Conflagrate (Immolate Auto-Timing)", description = "Cast Conflagrate after the cooldown when sufficient Immolate time remains", details = "Casts Conflagrate after the cooldown when sufficient Immolate time remains. Requires a valid target; does not cast when the target is Fire-immune. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warlock_conflagrate_immolate_present"] = { name = "Conflagrate (Immolate)", description = "Cast Conflagrate after the cooldown when the target has Immolate", details = "Casts Conflagrate after the cooldown when the target has Immolate, without requiring extra remaining time on Immolate. Requires a valid target; does not cast when the target is Fire-immune. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warlock_corruption_multi_dot"] = { name = "Corruption (Multi-Target DoT)", description = "Cast Corruption on nearby enemies without Corruption", details = "Scans enemies within Corruption's range and casts Corruption without a target on those that lack Corruption and are not Shadow-immune. Requires SuperWoW; picks at most one enemy per round." }
Cat2.Locals.Cards["warlock_curse_of_agony_multi_dot"] = { name = "Curse of Agony (Multi-Target DoT)", description = "Cast Curse of Agony on nearby enemies without Curse of Agony", details = "Scans enemies within Curse of Agony's range and casts Curse of Agony without a target on those that lack the curse and are not Shadow-immune. Requires SuperWoW; picks at most one enemy per round." }
Cat2.Locals.Cards["warlock_curse_of_recklessness_hex_multi_dot"] = { name = "Curse of Recklessness (Hex, Multi-Target DoT)", description = "Cast Curse of Recklessness on nearby enemies without Curse of Agony", details = "Scans enemies within Curse of Recklessness's range and casts Curse of Recklessness without a target on those lacking Curse of Agony. Requires the Improved Curse of Agony talent (Hex) and SuperWoW; picks at most one enemy per round." }
Cat2.Locals.Cards["warlock_curse_of_shadow_hex_multi_dot"] = { name = "Curse of Shadow (Hex, Multi-Target DoT)", description = "Cast Curse of Shadow on nearby enemies without Curse of Agony", details = "Scans enemies within Curse of Shadow's range and casts Curse of Shadow without a target on those lacking Curse of Agony. Requires the Improved Curse of Agony talent (Hex) and SuperWoW; picks at most one enemy per round." }
Cat2.Locals.Cards["warlock_curse_of_the_elements_hex_multi_dot"] = { name = "Curse of the Elements (Hex, Multi-Target DoT)", description = "Cast Curse of the Elements on nearby enemies without Curse of Agony", details = "Scans enemies within Curse of the Elements's range and casts Curse of the Elements without a target on those lacking Curse of Agony. Requires the Improved Curse of Agony talent (Hex) and SuperWoW; picks at most one enemy per round." }
Cat2.Locals.Cards["warlock_demon_armor"] = { name = "Demon Armor", description = "Cast Demon Armor when the Demon Armor effect is missing", details = "Casts Demon Armor when the player lacks the Demon Armor buff, keeping the self-armor effect active." }
Cat2.Locals.Cards["warlock_dot_interrupt_channel"] = { name = "Allow DoTs to Interrupt Drains", description = "When a DoT needs refreshing, allow interrupting the three drain-type channels", details = "While enabled, when an Affliction damage-over-time spell needs refreshing, only allows interrupting Drain Life, Drain Mana, or Drain Soul before casting the corresponding DoT. Other channels are not interrupted. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["warlock_dot_only_boss"] = { name = "DoTs: Ignore Non-Elite Enemies", description = "Affliction DoTs only apply to elite enemy targets", details = "Affliction damage-over-time spells only apply to elite enemy targets; normal targets are ignored. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["warlock_hellfire"] = { name = "Hellfire", description = "Cast Hellfire when more than |cff6bc7e0{enemyThreshold}|r enemies are within 10 yards", details = "Casts Hellfire when the number of enemies within 10 yards exceeds the card threshold, defaulting to more than 2 enemies. Enemy scanning requires SuperWoW and UnitXP. Attempts only when learned and usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warlock_immolate_auto_timing"] = { name = "Immolate (Auto-Timing)", description = "Automatically compute Immolate's remaining time to refresh it", details = "Recasts based on the target's remaining Immolate time factoring in cast time, keeping the existing channel-protection mechanism. Requires a valid target; does not cast when the target is Fire-immune. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warlock_immolate_multi_dot"] = { name = "Immolate (Multi-Target DoT)", description = "Cast Immolate on nearby enemies without Immolate", details = "Scans enemies within Immolate's range and casts Immolate without a target on those lacking Immolate, not Fire-immune, and facing the player. Requires SuperWoW; picks at most one enemy per round." }
Cat2.Locals.Cards["warlock_life_tap_exact"] = { name = "Life Tap (Exact)", description = "Cast Life Tap when mana is below |cff6bc7e0{manaThreshold}|r and health is at least |cff6bc7e0{minimumHealth}|r", details = "Casts Life Tap when the current absolute mana is below the configured value and current health is not below the configured floor. Defaults to a mana threshold of 3000 and a minimum health of 400; does not cast when health is below the floor. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warlock_life_tap_move"] = { name = "Life Tap (While Moving)", description = "Cast Life Tap while moving and mana is below |cff6bc7e0{triggerPercent}%|r", details = "Casts Life Tap while the player is moving and mana is below the card threshold. Checks relevant health; does not execute while stationary. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warlock_multi_dot_only_combat_enemies"] = { name = "Multi-Target DoTs: In-Combat Enemies Only", description = "Multi-target DoTs only apply to enemies in combat", details = "While enabled, the warlock's multi-target DoT cards only pick enemies already in combat; nearby enemies that have not entered combat are ignored. As a passive rule, affects all warlock multi-target DoT cards in the current flow." }
Cat2.Locals.Cards["warlock_nightfall_interrupt_channel"] = { name = "Allow Nightfall to Interrupt Drains", description = "When Nightfall procs, allow interrupting the three drain-type channels", details = "While enabled, the instant Shadow Bolt from Nightfall only allows interrupting Drain Life, Drain Mana, or Drain Soul. Other channels are not interrupted. As a passive rule, affects the current flow while enabled." }
Cat2.Locals.Cards["warlock_rain_of_fire_self"] = { name = "Rain of Fire (Self)", description = "Cast Rain of Fire centered on yourself; requires UnitXP 202607 or newer", details = "Casts Rain of Fire centered on yourself. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warlock_rain_of_fire_target"] = { name = "Rain of Fire (Target)", description = "Cast Rain of Fire centered on the target; requires UnitXP 202607 or newer", details = "Casts Rain of Fire centered on the target. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warlock_searing_pain_before_potential_three_stacks"] = { name = "Searing Pain (Before Three Potential Stacks)", description = "Cast Searing Pain while the pet has fewer than three Potential stacks", details = "Casts Searing Pain while the pet has fewer than three Potential stacks, to stack quickly. Requires a valid target and a pet; does not cast when the target is Fire-immune. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warlock_shadow_harvest_interrupt_channel"] = { name = "Allow Shadow Harvest to Interrupt Drains", description = "When Shadow Harvest is usable, allow interrupting the three drain-type channels", details = "While enabled, Shadow Harvest only allows interrupting Drain Life, Drain Mana, or Drain Soul. Other channels are not interrupted. As a passive rule, affects both normal Shadow Harvest and the Shadow Vulnerability version." }
Cat2.Locals.Cards["warlock_shadow_harvest_shadow_vulnerability"] = { name = "Shadow Harvest (Shadow Vulnerability)", description = "Channel Shadow Harvest after the cooldown when the target has Shadow Vulnerability", details = "Channels Shadow Harvest after the cooldown when the target has Shadow Vulnerability. Requires a valid target; does not cast when the target is Shadow-immune. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warlock_shadowburn_shadow_vulnerability"] = { name = "Shadowburn (Shadow Vulnerability)", description = "Cast Shadowburn after the cooldown when the target has Shadow Vulnerability", details = "Casts Shadowburn after the cooldown when the target has Shadow Vulnerability. Requires a valid target; does not cast when the target is Shadow-immune. Checks target distance and soul shards. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warlock_siphon_life_multi_dot"] = { name = "Siphon Life (Multi-Target DoT)", description = "Cast Siphon Life on nearby enemies without Siphon Life", details = "Scans enemies within Siphon Life's range and casts Siphon Life without a target on those lacking Siphon Life, drainable, and not Shadow-immune. Requires the Siphon Life talent and SuperWoW; picks at most one enemy per round." }
Cat2.Locals.Cards["warlock_soul_fire_boss"] = { name = "Soul Fire (Elite Enemies Only)", description = "Cast Soul Fire only against elite enemies with at least |cff6bc7e0{minimumTargetHealth}|r health", details = "Casts Soul Fire only on elite enemy targets whose health is not below the card threshold once the ability is off cooldown; does not cast when target health is below the threshold. The default minimum target health is 3000. Requires a valid target; does not cast when the target is Fire-immune. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warlock_spell_lock"] = { name = "Spell Lock", description = "Use Spell Lock when the target casts |cff6bc7e0{interruptSpellName}|r; interrupt any cast when empty", details = "Commands the pet to cast Spell Lock while the target is casting. When the interrupt spell name is empty, interrupts any captured enemy cast; when filled, only casts when the enemy spell name exactly matches. Requires a living pet with Spell Lock on its action bar, so other demons do not falsely trigger. Checks the pet-to-target distance and pet ability cooldowns; the player's own cast is not interrupted. Requires the SuperWoW module. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_battle_shout"] = { name = "Battle Shout", description = "Keep and cast Battle Shout", details = "Keeps and casts Battle Shout. Checks current resources. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_battle_stance"] = { name = "Battle Stance", description = "Switch to and keep Battle Stance", details = "Switches to and keeps Battle Stance. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_berserker_stance"] = { name = "Berserker Stance", description = "Switch to and keep Berserker Stance", details = "Switches to and keeps Berserker Stance. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_bloodrage"] = { name = "Bloodrage", description = "Cast Bloodrage when rage is below |cff6bc7e0{maximumRage}|r", details = "Casts Bloodrage when rage is below the card threshold. Requires a valid target. Checks target distance. Checks combat state. Checks current resources. Attempts only when the ability is usable." }
Cat2.Locals.Cards["warrior_bloodthirst"] = { name = "Bloodthirst", description = "Cast Bloodthirst when rage reaches |cff6bc7e0{rageThreshold}|r and off cooldown", details = "Casts Bloodthirst when rage reaches the card threshold and the ability is off cooldown. Uses the default value 30 when not set separately. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_charge"] = { name = "Charge", description = "Cast Charge from 8-25 yards when out of combat", details = "Casts Charge from 8-25 yards when out of combat. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_charge_auto_stance"] = { name = "Charge (Auto Stance)", description = "When rage is at most |cff6bc7e0{maximumRage}|r, automatically switch stance and cast Charge", details = "When current rage is no higher than the card threshold, automatically switches to Battle Stance and casts Charge when out of combat with the target at 8-25 yards. Requires a valid target. Checks current rage and target distance. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_cleave"] = { name = "Cleave", description = "Cast Cleave when rage reaches |cff6bc7e0{rageThreshold}|r", details = "Casts Cleave when rage reaches the card threshold. Requires a valid target. Checks current resources." }
Cat2.Locals.Cards["warrior_concussion_blow"] = { name = "Concussion Blow", description = "Cast Concussion Blow when off cooldown", details = "Casts Concussion Blow when off cooldown. Requires a valid target. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_death_wish"] = { name = "Death Wish", description = "Cast Death Wish when off cooldown", details = "Casts Death Wish when off cooldown. Requires a valid target. Checks target distance. Checks current resources. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_defensive_stance"] = { name = "Defensive Stance", description = "Switch to and keep Defensive Stance", details = "Switches to and keeps Defensive Stance. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_demoralizing_shout"] = { name = "Demoralizing Shout", description = "Trigger when the target lacks a demoralize effect", details = "Triggers when the target lacks a demoralize effect. Requires a valid target. Checks target distance. Checks current resources. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_execute"] = { name = "Execute", description = "Cast Execute when the target enters the execute range", details = "Casts Execute when conditions are met. Requires a valid target. Checks current resources. With Interrupt Cast for Execute enabled, interrupts the Slam cast before casting. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_intercept"] = { name = "Intercept", description = "Cast Intercept from 8-25 yards when off cooldown", details = "Casts Intercept from 8-25 yards when off cooldown. Requires a valid target. Checks target distance. Checks current resources. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_intercept_auto_stance"] = { name = "Intercept (Auto Stance)", description = "When rage is at most |cff6bc7e0{maximumRage}|r, automatically switch stance and cast Intercept", details = "When current rage is at least 10 and no higher than the card threshold, automatically switches to Berserker Stance and casts Intercept when the target is at 8-25 yards. Requires a valid target. Checks current rage and target distance. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_intervene_auto_stance"] = { name = "Intervene (Auto Stance)", description = "When rage is at most |cff6bc7e0{maximumRage}|r, automatically switch stance and cast Intervene", details = "When current rage is at least 10 and no higher than the card threshold, automatically switches to Defensive Stance and casts Intervene on a friendly target at 8-25 yards. Requires a valid friendly target. Checks current rage and target distance. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_last_stand"] = { name = "Last Stand", description = "Cast Last Stand when health is below |cff6bc7e0{triggerPercent}%|r", details = "Casts Last Stand when health is below the card threshold. Checks combat state. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_lifegiving_gem"] = { name = "Lifegiving Gem", description = "Use the Lifegiving Gem when health is below |cff6bc7e0{triggerPercent}%|r", details = "Uses the Lifegiving Gem equipped in the upper or lower trinket slot when health in combat is below the card threshold. Executes only when the trinket is usable and stops the rest of the round after a successful use." }
Cat2.Locals.Cards["warrior_mortal_strike"] = { name = "Mortal Strike", description = "Cast Mortal Strike when rage reaches |cff6bc7e0{rageThreshold}|r and off cooldown", details = "Casts Mortal Strike when rage reaches the card threshold and the ability is off cooldown. Uses the default value 30 when not set separately. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_overpower"] = { name = "Overpower", description = "When rage is below |cff6bc7e0{maximumRage}|r, switch to Battle Stance and cast Overpower", details = "When rage is below the card threshold, switches to Battle Stance and casts Overpower. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_overpower_after_main_skill"] = { name = "Overpower (After Main Skill)", description = "Cast when the main skill cooldown exceeds |cff6bc7e0{mainSkillCooldownThreshold} sec|r and rage is below |cff6bc7e0{maximumRage}|r", details = "Only when the remaining cooldown of Mortal Strike or Bloodthirst exceeds the card threshold, switches to Battle Stance and casts Overpower following the original logic. Defaults to a 2-second main skill cooldown threshold and 30 max rage. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_pummel"] = { name = "Pummel", description = "Use Pummel when the target casts |cff6bc7e0{interruptSpellName}|r; interrupt any cast when empty", details = "Casts Pummel while the target is casting. When the interrupt spell name is empty, keeps the original mechanic of interrupting any captured enemy cast; when filled, only casts when the enemy spell name exactly matches. Requires the SuperWoW module. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_pummel_flurry"] = { name = "Pummel (Trigger Flurry)", description = "Cast Pummel when Flurry is not active and rage reaches |cff6bc7e0{rageThreshold}|r", details = "Does not check whether the target is casting; casts Pummel only when Flurry is not active, rage reaches the configured value, and Pummel is usable, defaulting to 10 rage. Requires a valid target; does not execute in Defensive Stance. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_recklessness"] = { name = "Recklessness", description = "Cast Recklessness when off cooldown", details = "Casts Recklessness when off cooldown. Requires a valid target. Checks target distance. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_rend"] = { name = "Rend", description = "Cast and keep Rend on the target", details = "Casts and keeps Rend on the target. Requires a valid target. Checks current resources. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_revenge"] = { name = "Revenge", description = "Cast Revenge when conditions are met", details = "Casts Revenge when conditions are met. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_shield_bash"] = { name = "Shield Bash", description = "Use Shield Bash when the target casts |cff6bc7e0{interruptSpellName}|r; interrupt any cast when empty", details = "Casts Shield Bash while the target is casting. When the interrupt spell name is empty, keeps the original mechanic of interrupting any captured enemy cast; when filled, only casts when the enemy spell name exactly matches. Requires the SuperWoW module. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_shield_block"] = { name = "Shield Block", description = "When health is below |cff6bc7e0{triggerPercent}%|r, keep Improved Blocking and cast Shield Block", details = "When health is below the card threshold, keeps Improved Blocking and casts Shield Block. The default trigger health is 100%; does not cast when the Shield Slam block buff is present or at full health. Checks target distance, combat state, and shield equipment. Attempts only when the ability is usable." }
Cat2.Locals.Cards["warrior_shield_slam"] = { name = "Shield Slam", description = "Cast Shield Slam when off cooldown", details = "Casts Shield Slam when off cooldown. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_shield_wall"] = { name = "Shield Wall", description = "Cast Shield Wall when health is below |cff6bc7e0{triggerPercent}%|r", details = "Casts Shield Wall when health is below the card threshold. Checks combat state. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_shield_wall_auto_stance"] = { name = "Shield Wall (Auto Stance)", description = "When health is below |cff6bc7e0{triggerPercent}%|r, switch stance and cast Shield Wall", details = "When health is below the card threshold, switches to Defensive Stance and casts Shield Wall. Checks combat state. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_slam"] = { name = "Slam", description = "Cast Slam when rage reaches |cff6bc7e0{rageThreshold}|r and |cff6bc7e0{minimumSwingTime} sec|r of auto-attack time remains", details = "Casts Slam when rage reaches the configured value and the remaining auto-attack time exceeds the configured value. Defaults to 15 rage and 1.5 seconds. Requires a valid target. Checks current resources. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_slam_after_main_skills"] = { name = "Slam (After Main Skills)", description = "Cast when a main skill cooldown exceeds |cff6bc7e0{mainSkillCooldownThreshold} sec|r, rage reaches |cff6bc7e0{rageThreshold}|r, and |cff6bc7e0{minimumSwingTime} sec|r of auto-attack remains", details = "Does not cast when any of the Whirlwind, Bloodthirst, or Mortal Strike cooldowns has at most the configured remaining time. Defaults to a 2-second main skill cooldown threshold, 15 rage, and 1.5 seconds of auto-attack time. Requires a valid target. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_sunder_armor_boss"] = { name = "Sunder Armor (Elite Enemies Only)", description = "Cast Sunder Armor on elite enemies only when rage reaches |cff6bc7e0{rageThreshold}|r", details = "Only on elite enemy targets, spams Sunder Armor when rage reaches the card threshold, requiring 30 rage by default. Requires a valid target. Checks current resources. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_sunder_armor_five"] = { name = "Sunder Armor (Five Stacks)", description = "Keep five Sunder Armor stacks on the target when rage reaches |cff6bc7e0{rageThreshold}|r", details = "Once rage reaches the card threshold, keeps casting Sunder Armor until the target has five stacks; at five stacks, refreshes when the remaining duration is at most five seconds, requiring 30 rage by default; requires the SuperWoW module. Requires a valid target. Checks current resources. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_sunder_armor_five_boss"] = { name = "Sunder Armor (Five Stacks, Elite Enemies Only)", description = "Keep five Sunder Armor stacks on elite enemies when rage reaches |cff6bc7e0{rageThreshold}|r", details = "Only on elite enemy targets. Once rage reaches the card threshold, keeps casting Sunder Armor until the target has five stacks; at five stacks, refreshes when the remaining duration is at most five seconds, requiring 30 rage by default; requires the SuperWoW module. Requires a valid target. Checks current resources. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_sweeping_strikes"] = { name = "Sweeping Strikes", description = "Start Sweeping Strikes when multiple enemies are within |cff6bc7e0{scanRange} yd|r and rage is below |cff6bc7e0{maximumRage}|r", details = "Starts Sweeping Strikes when multiple enemies exist within the configured distance and rage is below the card threshold; enemy scanning requires SuperWoW. Requires a valid target. Checks current resources. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_thunder_clap"] = { name = "Thunder Clap", description = "Keep and cast Thunder Clap on the target", details = "Keeps and casts Thunder Clap on the target. Requires a valid target. Checks target distance. Checks current resources. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_thunder_clap_offensive"] = { name = "Thunder Clap (Offensive)", description = "Cast Thunder Clap when rage reaches |cff6bc7e0{rageThreshold}|r and at least |cff6bc7e0{minimumEnemies}|r enemies are nearby", details = "Casts Thunder Clap when rage reaches the card threshold and the number of enemies within 8 yards reaches the configured value. Defaults to 20 rage and 2 enemies; the actual rage requirement is never lower than the talent-adjusted cost. Enemy scanning requires SuperWoW. Requires a valid target. Checks target distance. Stops the rest of the round after a successful cast." }
Cat2.Locals.Cards["warrior_whirlwind"] = { name = "Whirlwind", description = "Cast Whirlwind when rage reaches |cff6bc7e0{rageThreshold}|r and off cooldown", details = "Casts Whirlwind when rage reaches the card threshold and the ability is off cooldown. Requires 25 rage by default; when equipment reduces the cost and no custom override is set, automatically lowers it to 20 rage. Requires a valid target. Checks target distance. Checks current resources. Attempts only when the ability is usable. Stops the rest of the round after a successful cast." }

-- Build reverse maps
Cat2.Locals.SpellsReverse = {}
for k, v in pairs(Cat2.Locals.Spells) do Cat2.Locals.SpellsReverse[v] = k end

Cat2.Locals.ItemsReverse = {}
for k, v in pairs(Cat2.Locals.Items) do Cat2.Locals.ItemsReverse[v] = k end

Cat2.Locals.BuffsReverse = {}
for k, v in pairs(Cat2.Locals.Buffs) do Cat2.Locals.BuffsReverse[v] = k end

local originalText = function(text)
    if not text then return "" end
    if Cat2.CurrentLocale == "enUS" then
        return Cat2.Locals.UI[text] or text
    end
    return text
end
Cat2.L = setmetatable({}, {
    __call = function(_, text)
        return originalText(text)
    end,
    __index = function(_, key)
        return originalText[key]
    end
})
Cat2.L.Get = Cat2.L

function Cat2.L.Spell(name)
    if not name then return "" end

    -- 处理带等级的施法名，如 "回春术(等级 7)" / "Rejuvenation(Rank 7)"
    local base, rankNum = string.match(name, "^(.-)%((.-)%d+%)$")
    if base and rankNum then
        local translatedBase
        if Cat2.CurrentLocale == "enUS" then
            translatedBase = Cat2.Locals.Spells[base] or base
        else
            translatedBase = Cat2.Locals.SpellsReverse[base] or base
        end
        local n = string.match(rankNum, "(%d+)")
        if n then
            if Cat2.CurrentLocale == "enUS" then
                return translatedBase .. "(Rank " .. n .. ")"
            else
                return translatedBase .. "(等级 " .. n .. ")"
            end
        end
        return translatedBase
    end

    if Cat2.CurrentLocale == "enUS" then
        return Cat2.Locals.Spells[name] or name
    else
        return Cat2.Locals.SpellsReverse[name] or name
    end
end

function Cat2.L.Item(name)
    if not name then return "" end
    if Cat2.CurrentLocale == "enUS" then
        return Cat2.Locals.Items[name] or name
    else
        return Cat2.Locals.ItemsReverse[name] or name
    end
end

function Cat2.L.Buff(name)
    if not name then return "" end
    if Cat2.CurrentLocale == "enUS" then
        return Cat2.Locals.Buffs[name] or name
    else
        return Cat2.Locals.BuffsReverse[name] or name
    end
end

-- 本地化技能等级文本，如 "等级 5" / "Rank 5" 统一为当前客户端格式
function Cat2.L.Rank(rank)
    if not rank then return rank end
    local n = string.match(rank, "(%d+)")
    if not n then return rank end
    if Cat2.CurrentLocale == "enUS" then
        return "Rank " .. n
    else
        return "等级 " .. n
    end
end

function Cat2.GetLocalizedCardText(card, field)
    if not card then return "" end
    local locale = Cat2.CurrentLocale
    if locale == "enUS" then
        if card.id and Cat2.Locals.Cards and Cat2.Locals.Cards[card.id] then
            local t = Cat2.Locals.Cards[card.id]
            if field == "name" then return t.name or card.name_zh or card.name end
            if field == "description" then return t.description or card.description_zh or card.description end
            if field == "details" then return t.details or card.details_zh or card.details end
        end
        return card[field .. "_zh"] or card[field]
    else
        return card[field .. "_zh"] or card[field]
    end
end
