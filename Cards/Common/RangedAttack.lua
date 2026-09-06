-- 远程（魔杖/射击/投掷）通用卡片。
-- 根据远程武器栏当前装备的类型，选择对应的远程自动攻击技能。
local card = {
    id = "common_ranged_attack",
    name = "远程（射击/魔杖/投掷）",
    description = "使用当前装备的武器进行远程攻击",
    details = "根据远程武器栏当前装备的类型，自动选择魔杖射击、自动射击、弓箭/枪械/弩射击或投掷。没有装备有效远程武器时不会执行。",
    sort = 12,
    category = "common",
    icons = {
        "Interface\\Icons\\Ability_Marksmanship",
        "Interface\\Icons\\Ability_ShootWand",
        "Interface\\Icons\\Ability_Throw",
    },
}

-- 保存魔杖与射击类技能的自动重复状态，防止反复触发时将其关闭。
local autoRepeatActive = false
local autoRepeatFrame = CreateFrame("Frame")

-- 不同 1.12 客户端扩展对 GetItemInfo 的类型字段位置可能略有差异。
-- 只接受这张卡实际支持的远程武器子类型，避免把“武器”等大类误认为子类型。
local supportedRangedSubTypes = {
    ["投掷武器"] = true,
    ["魔杖"] = true,
    ["弓"] = true,
    ["枪械"] = true,
    ["弩"] = true,
}

autoRepeatFrame:RegisterEvent("START_AUTOREPEAT_SPELL")
autoRepeatFrame:RegisterEvent("STOP_AUTOREPEAT_SPELL")

autoRepeatFrame:SetScript("OnEvent", function()
    if event == "START_AUTOREPEAT_SPELL" then
        autoRepeatActive = true
    elseif event == "STOP_AUTOREPEAT_SPELL" then
        autoRepeatActive = false
    end
end)

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 返回角色已经学会的第一个候选技能。
local function GetKnownSpellName(spellNames)
    for _, spellName in ipairs(spellNames) do
        if Cat2.GetSpellID(spellName) ~= 0 then
            return spellName
        end
    end

    return nil
end

-- 根据远程武器子类型选择客户端中的对应技能名称。
local function GetRangedAttackSpell(itemSubType)
    local _, playerClass = UnitClass("player")

    if itemSubType == "投掷武器" then
        return GetKnownSpellName({ "投掷" })
    end

    if itemSubType == "魔杖" then
        return GetKnownSpellName({ "射击" })
    end

    -- 猎人使用自动射击；其他职业使用武器类型对应的射击技能。
    if playerClass == "HUNTER" then
        return GetKnownSpellName({ "自动射击" })
    end

    if itemSubType == "弓" then
        return GetKnownSpellName({ "弓射击", "射击" })
    end

    if itemSubType == "枪械" then
        return GetKnownSpellName({ "枪械射击", "射击" })
    end

    if itemSubType == "弩" then
        return GetKnownSpellName({ "弩射击", "射击" })
    end

    return nil
end

-- 使用当前装备的远程武器开始或维持远程攻击。
function card.Execute(context)
    local itemLink = GetInventoryItemLink("player", 18)
    if not itemLink then
        return false
    end

    -- 该客户端用完整物品链接查询时可能尚未返回缓存信息；提取数字 ID 更稳定。
    local itemID = Cat2.Match(itemLink, "item:(%d+):")
    if not itemID then
        return false
    end

    local _, _, _, _, value5, value6, value7 = GetItemInfo(Cat2.ToNumber(itemID))
    local itemSubType
    if supportedRangedSubTypes[value6] then
        itemSubType = value6
    elseif supportedRangedSubTypes[value7] then
        itemSubType = value7
    elseif supportedRangedSubTypes[value5] then
        itemSubType = value5
    end

    if not itemSubType then
        return false
    end

    local spellName = GetRangedAttackSpell(itemSubType)
    if not spellName then
        return false
    end

    -- 自动重复攻击已经开启时不再次施放，避免把当前远程攻击关闭。
    -- 如果某类远程技能不是自动重复技能，该状态不会被置为真，仍可在下次流程中继续触发。
    if not autoRepeatActive then
        Cat2.Cast(spellName)
    end

    return false
end

Cat2.RegisterCard(card)
