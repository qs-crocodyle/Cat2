-- 猎豹形态下根据当前目标连击点切换神像；四星及以上使用高星参数。
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
    id = "druid_combo_point_idol_4",
    name = "连击点神像（>四星）",
    description = "装备|cff6bc7e0{lowComboIdol}|r，4-5星装备|cff6bc7e0{highComboIdol}|r",
    details = "仅在猎豹形态下，根据当前目标的连击点切换神像：0至3默认使用凶猛神像，4至5个连击点默认使用撕裂神像。选择留空时对应连击点区间不切换。仅在公共冷却结束且未打开银行、拍卖行、邮箱或商人界面时操作装备；已经装备目标神像或背包中没有该神像时不会重复切换。成功换装时会阻断本轮后续卡片。",
    sort = 1000,
    category = "class",
    canStopSequence = true,
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\INV_QirajIdol_Night",
    },
    optionSchema = {
        {
            key = "lowComboIdol",
            type = "string",
            control = "select",
            hideDefaultChoice = true,
            label = "0至3星神像",
            shortLabel = "低星神像",
            default = "凶猛神像",
            choices = idolChoices,
        },
        {
            key = "highComboIdol",
            type = "string",
            control = "select",
            hideDefaultChoice = true,
            label = "4至5星神像",
            shortLabel = "四星神像",
            default = "撕裂神像",
            choices = idolChoices,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary

    -- 连击点规则只用于猎豹形态，避免覆盖自动形态神像为熊形态选择的神像。
    if not player.buff["猎豹形态"] then
        return false
    end

    if player.gcd >= 0.2 or Cat2.CheckUIStatus() then
        return false
    end

    local comboPoints = player.targetCombo or 0
    local desiredIdol = ""
    if comboPoints >= 4 then
        desiredIdol = context:GetStepOption(step, "highComboIdol") or ""
    else
        desiredIdol = context:GetStepOption(step, "lowComboIdol") or ""
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
