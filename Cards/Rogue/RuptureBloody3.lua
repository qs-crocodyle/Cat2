-- 撕裂（血腥气息，三星）技能卡片；保留原割裂（三星）的当前机制。
local card = {
    id = "rogue_rupture_bloody_3",
    name = "撕裂（血腥气息，三星）",
    description = "拥有3连击点，血腥气息剩余|cff6bc7e0{refreshRemainingSeconds}秒|r时补割裂",
    details = "目标拥有3连击点，且玩家身上的血腥气息不存在或剩余时间低于卡片设定值时施放割裂。默认续杯时间为3秒，需要存在有效目标。未加载SuperWoW或角色低于60级时，只能判断血腥气息是否存在，无法按精确剩余秒数续杯。成功执行时会阻断本轮后续卡片。",
    sort = 45.3,
    category = "class",
    classes = {
        ROGUE = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Rupture",
        "Interface\\Icons\\INV_Misc_Bone_09",
    },
    optionSchema = {
        {
            key = "refreshRemainingSeconds",
            type = "number",
            label = "剩余时间",
            shortLabel = "剩余",
            unit = "秒",
            default = 3,
            minimum = 0,
            maximum = 30,
            integer = false,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local refreshSeconds = context:GetStepOption(step, "refreshRemainingSeconds") or 3

    if not player.targetExists then
        return false
    end

    if player.targetCombo == 3 and not Cat2.GetRogueBloody(refreshSeconds) then
        Cat2.Cast("割裂")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
