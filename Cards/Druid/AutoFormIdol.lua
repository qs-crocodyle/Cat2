-- 根据当前野性形态自动装备对应神像；空参数表示该形态不切换。
local idolChoices = {
    { value = "", label = "留空（不切换）" },
    { value = "凶猛神像", label = "|cFF0070DD凶猛神像|r" },
    { value = "野蛮神像", label = "|cFF0070DD野蛮神像|r" },
    { value = "蛮兽神像", label = "|cFF0070DD蛮兽神像|r" },
    { value = "常青神像", label = "|cFF0070DD常青神像|r" },
    { value = "月牙神像", label = "|cFF9D38C8月牙神像|r" },
    { value = "狂野变形者神像", label = "|cFF9D38C8狂野变形者神像|r" },
    { value = "酸蚀神像", label = "|cFF9D38C8酸蚀神像|r" },
    { value = "腐败翡翠神像", label = "|cFF9D38C8腐败翡翠神像|r" },
    { value = "撕裂神像", label = "|cFF9D38C8撕裂神像|r" },
}

local card = {
    id = "druid_auto_form_idol",
    name = "自动形态神像",
    description = "熊形态|cff6bc7e0{bearIdol}|r，猎豹形态|cff6bc7e0{catIdol}|r",
    details = "根据当前形态自动装备所选神像：熊形态与巨熊形态默认使用蛮兽神像，猎豹形态默认使用凶猛神像。选择留空时对应形态不切换。仅在公共冷却结束且未打开银行、拍卖行、邮箱或商人界面时操作装备；已经装备目标神像或背包中没有该神像时不会重复切换。成功换装时会阻断本轮后续卡片。",
    sort = 999,
    category = "class",
    canStopSequence = true,
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\INV_QirajIdol_Night",
        "Interface\\Icons\\Ability_Racial_BearForm",
        "Interface\\Icons\\Ability_Druid_CatForm",
    },
    optionSchema = {
        {
            key = "bearIdol",
            type = "string",
            control = "select",
            hideDefaultChoice = true,
            label = "熊形态神像",
            shortLabel = "熊神像",
            default = "蛮兽神像",
            choices = idolChoices,
        },
        {
            key = "catIdol",
            type = "string",
            control = "select",
            hideDefaultChoice = true,
            label = "猎豹形态神像",
            shortLabel = "猫神像",
            default = "凶猛神像",
            choices = idolChoices,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary

    -- 旧 Cat 的神像舞只在 GCD 小于0.2秒时换装；沿用该门禁，避免形态技能刚触发后立即操作装备。
    if player.gcd >= 0.2 or Cat2.CheckUIStatus() then
        return false
    end

    local desiredIdol = ""
    if player.buff["熊形态"] or player.buff["巨熊形态"] then
        desiredIdol = context:GetStepOption(step, "bearIdol") or ""
    elseif player.buff["猎豹形态"] then
        desiredIdol = context:GetStepOption(step, "catIdol") or ""
    end

    if desiredIdol == "" or Cat2.CheckInventoryItemName(18, desiredIdol) then
        return false
    end

    if Cat2.EquipItemByName(desiredIdol, 18) then
        return true
    end

    return false
end

Cat2.RegisterCard(card)
