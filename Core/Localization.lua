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
    ["Cat|cffff3f3f2|r 喵！一键宏"] = "Cat|cffff3f3f2|r Macro",
    ["左键点击打开设置"] = "Left-click to open settings",
    ["打开主界面"] = "Open Main Window",
    ["关闭此快捷窗"] = "Close Shortcut Window",
    ["点击恢复步骤"] = "Click to resume step",
    ["点击暂停步骤"] = "Click to pause step",
    ["快捷窗已达上限，请先关闭其他配置的快捷窗。"] = "Shortcut windows limit reached. Please close other shortcut windows first.",
    ["Cat2 使用规则"] = "Cat2 Usage Rules",
    ["流程顺序"] = "Flow Order",
    ["流程从上向下执行。拖动左侧卡片可以调整顺序。\n部分卡片成功执行后会停止本轮流程，重要卡片请放在合适位置。"] = "Flow runs from top to bottom. Drag cards on the left to adjust order.\nSome cards stop the sequence upon successful execution. Place important cards appropriately.",
    ["卡片状态"] = "Card Status",
    ["点击左侧卡片后，可以暂停、恢复、隐藏或删除。\n被动卡片|cffb880f0（紫色）|r会影响整个流程；暂停后，它的被动效果不会生效。"] = "Click a card on the left to pause, resume, hide, or delete it.\nPassive cards |cffb880f0(purple)|r affect the entire flow; when paused, their passive effects do not apply.",
    ["快捷小窗"] = "Shortcut Windows",
    ["显示在小窗中的卡片可以随时点击暂停或恢复。\n主界面与快捷小窗相互独立，关闭主界面不会关闭小窗。"] = "Cards displayed in shortcut windows can be paused or resumed anytime.\nThe main interface and shortcut windows are independent; closing the main interface won't close shortcut windows.",
    ["配置使用"] = "Profile Usage",
    ["输入 |cffff4fa3/cat2 配置名|r 执行对应流程。配置按角色保存。\n导入配置时会检查职业；同名配置需要确认后才能覆盖。"] = "Type |cffff4fa3/cat2 profileName|r to execute the flow. Profiles are saved per character.\nClass is checked when importing profiles; duplicate profile names require confirmation to overwrite.",
    ["关闭"] = "Close",
    ["确定"] = "OK",
    ["确认删除"] = "Confirm Delete",
    ["取消"] = "Cancel",
    ["创建"] = "Create",
    ["输入内容无效。"] = "Invalid input.",
    ["PlayerInformation 调试"] = "PlayerInformation Debug",
    ["基础"] = "Basic",
    ["临时"] = "Temporary",
    ["空字符串"] = "Empty string",
    ["循环引用"] = "Circular reference",
    ["空表"] = "Empty table",
    ["字段："] = "Fields: ",
    ["分组"] = "Group",
    ["字段"] = "Field",
    ["值"] = "Value",
    ["导入失败"] = "Import Failed",
    ["配置导入成功"] = "Profile imported successfully",
    ["职业不匹配"] = "Class mismatch",
    ["覆盖"] = "Overwrite",
    ["未知错误"] = "Unknown error",
    ["无法识别配置文本"] = "Unrecognized configuration text",
    ["Cat2 加载完成！"] = "Cat2 Loaded Successfully!",
    ["Cat2 快捷窗错误："] = "Cat2 Shortcut Window Error: ",
    ["Cat2 快捷窗初始化失败："] = "Cat2 Shortcut Window Initialization Failed: ",
    ["Cat2 主界面错误："] = "Cat2 Main Interface Error: ",
    ["Cat2 主界面加载失败：请查看 Lua 错误信息。"] = "Cat2 Main Interface Load Failed: Please check Lua error message.",
    ["未命名被动卡片"] = "Unnamed Passive Card",
    ["未命名卡片"] = "Unnamed Card",
    ["Cat2：被动卡片「"] = "Cat2: Passive Card \"",
    ["」应用失败："] = "\" application failed: ",
    ["」检查失败："] = "\" check failed: ",
    ["Cat2：卡片「"] = "Cat2: Card \"",
    ["」执行失败："] = "\" execution failed: ",
    ["Cat2：请输入配置名，例如 /cat2 配置1"] = "Cat2: Please enter profile name, e.g. /cat2 Profile1",
    ["Cat2：调试窗尚未加载，请完整重启游戏。"] = "Cat2: Debug window not loaded yet, please restart game.",
    ["Cat2：找不到配置「"] = "Cat2: Cannot find profile \"",
    ["」。"] = "\".",
    ["Cat2：配置「"] = "Cat2: Profile \"",
    ["」执行完成，共调用 "] = "\" executed successfully, called ",
    [" 张卡片，其中 "] = " cards in total, with ",
    [" 张失败。"] = " failed.",
    ["Cat2：失败卡片："] = "Cat2: Failed cards: ",
    ["名称长度必须为 2-12 个汉字或字符。"] = "Name length must be 2-12 characters.",
    ["debug 是调试指令，不能作为配置名称。"] = "debug is a debug command and cannot be used as a profile name.",
    ["已经存在同名配置。"] = "A profile with the same name already exists.",
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
    ["」吗？\n此操作无法撤销。"] = "\"?\nThis action cannot be undone.",
    ["删除"] = "Delete",
    ["当前配置"] = "Current Profile",
    ["改名"] = "Rename",
    ["配置改名（2-12个字符）"] = "Rename Profile (2-12 chars)",
    ["快捷窗"] = "Shortcut Window",
    ["每行或列图标数"] = "Icons per Row/Col",
    ["排列方向"] = "Layout Direction",
    ["横向优先"] = "Horizontal First",
    ["纵向优先"] = "Vertical First",
    ["快捷窗缩放"] = "Window Scale",
    ["宏命令（点击全选后 Ctrl+C 复制）"] = "Macro Command (Click All then Ctrl+C)",
    ["当前配置的执行命令"] = "Execution command for current profile",
    ["点击自动全选，再按 Ctrl+C 复制到宏中。"] = "Click to select all, then press Ctrl+C to copy into macro.",
    ["还原位置"] = "Reset Position",
    ["配置导出"] = "Profile Export",
    ["正在导出「"] = "Exporting \"",
    ["」。文本已压缩转档，点击“全选”后按 Ctrl+C 复制。"] = "\". Text compressed/encoded, click \"Select All\" then press Ctrl+C to copy.",
    ["全选"] = "Select All",
    ["配置导入"] = "Profile Import",
    ["将其他用户提供的完整配置文本粘贴到下方，然后点击“导入”。"] = "Paste the complete profile text provided by other users below, then click \"Import\".",
    ["导入"] = "Import",
    ["请先粘贴需要导入的配置文本。"] = "Please paste the profile text to import first.",
    ["无法导出配置：「"] = "Cannot export profile: \"",
    ["导入失败："] = "Import Failed: ",
    ["配置「"] = "Profile \"",
    ["」已覆盖，并已切换为当前配置。"] = "\" has been overwritten and switched to current profile.",
    ["」导入成功，并已切换为当前配置。"] = "\" imported successfully and switched to current profile.",
    ["职业不匹配，不能导入。\n配置职业："] = "Class mismatch, cannot import.\nProfile Class: ",
    ["\n当前职业："] = "\nCurrent Class: ",
    ["未知"] = "Unknown",
    ["已经存在同名配置「"] = "A profile with the same name \"",
    ["」。\n覆盖后，原配置的卡片及顺序将被替换。"] = "\".\nAfter overwriting, the original profile's cards and order will be replaced.",
    ["重命名当前配置"] = "Rename current profile",
    ["管理"] = "Manage",
    ["Cat2：配置管理模块尚未加载，请完整重启游戏。"] = "Cat2: Profile management module not loaded yet, please restart game.",

    ["全部"] = "All",
    ["通用"] = "Common",
    ["药水"] = "Potions",
    ["第四系"] = "4th",
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
    [" 喵！"] = " Meow!",
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
    ["」执行完成，共调用 "] = "\" executed successfully, called ",
    [" 张卡片，其中 "] = " cards in total, with ",
    [" 张失败。"] = " failed.",
    ["Cat2：失败卡片："] = "Cat2: Failed cards: ",
    ["Cat2：被动卡片「"] = "Cat2: Passive Card \"",
    ["」应用失败："] = "\" application failed: ",
    ["」检查失败："] = "\" check failed: ",
    ["Cat2：卡片「"] = "Cat2: Card \"",
    ["」执行失败："] = "\" execution failed: ",
    ["「"] = "\"",
    ["」"] = "\"",
    [" 喵！"] = " Meow!",
    ["还原位置"] = "Reset Position",
    ["打开主界面"] = "Open Main Window",
    ["关闭此快捷窗"] = "Close Shortcut Window",
    ["点击恢复步骤"] = "Click to resume step",
    ["点击暂停步骤"] = "Click to pause step",
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
    ["正义圣印"] = "Seal of Justice",
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
    ["审判"] = "Judgment",
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
    ["重整"] = "Reform",
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
    -- TODO 待翻译 (Spells) --
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
    -- TODO 待翻译 (Items) --
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
    ["智慧审判"] = "Judgment of Wisdom",
    ["智慧祝福"] = "Blessing of Wisdom",
    ["枭兽形态"] = "Moonkin Form",
    ["水之护盾"] = "Water Shield",
    ["法术连击"] = "Spell Combo",
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
    ["十字军审判"] = "Judgment of the Crusader",
    ["强化盾牌猛击"] = "Improved Shield Slam",
    ["生命之树形态"] = "Tree of Life Form",
    ["精灵之火（野性）"] = "Faerie Fire (Feral)",
    -- TODO 待翻译 (Buffs) --
    -- 扫击 Rake (debuff), 保护之手 Hand of Protection, 审判类
    ["扫击"] = "Rake",
    -- TODO 自定义服务器名: 昼至 (Wrath/Starfire eclipse aura)
    ["昼至"] = "Daybreak",
    -- TODO 自定义服务器名: 血袭 (druid bleed)
    ["血袭"] = "Blood Assault",
    ["保护之手"] = "Hand of Protection",
    ["光明审判"] = "Judgment of Light",
    ["公正圣印"] = "Seal of Justice",
    -- TODO 自定义服务器名: 利用弱点 (rogue expose)
    ["利用弱点"] = "Exposed Weakness",
    -- TODO 自定义服务器名: 剧毒弹药 (hunter ammo)
    ["剧毒弹药"] = "Toxic Ammo",
    ["拯救祝福"] = "Blessing of Salvation",
    ["正义审判"] = "Judgment of Justice",
    -- TODO 服务器姿态名可能不同 (Battle Stance)
    ["武器姿态"] = "Battle Stance",
    -- TODO 自定义服务器名: 爆炸弹药 (hunter ammo)
    ["爆炸弹药"] = "Explosive Ammo",
    -- TODO 自定义服务器名: 血之狂暴 (enrage buff)
    ["血之狂暴"] = "Blood Frenzy",
    -- TODO 自定义服务器名: 血腥气息 (rogue buff)
    ["血腥气息"] = "Scent of Blood",
    -- TODO 自定义服务器名: 魔力弹药 (hunter ammo)
    ["魔力弹药"] = "Arcane Ammo",
    ["强效拯救祝福"] = "Greater Blessing of Salvation",
    ["强效智慧祝福"] = "Greater Blessing of Wisdom",
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
