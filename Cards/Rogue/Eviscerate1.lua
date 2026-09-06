-- 剔骨（一星）技能卡片。
local card = {
    id = "rogue_eviscerate_1",
    name = "剔骨（一星）",
    description = "消耗1连击点施放剔骨，血腥等待|cff6bc7e0{bloodyWaitSeconds}秒|r",
    details = "消耗1连击点施放剔骨，若血腥气息即将结束，则等待。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 21,
    category = "class",
    classes = {
        ROGUE = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Eviscerate",
    },
    optionSchema = {
        {
            key = "bloodyWaitSeconds",
            type = "number",
            label = "血腥等待",
            shortLabel = "等待",
            unit = "秒",
            default = 3,
            minimum = 0,
            maximum = 30,
            integer = false,
        },
    },
}

local HasBloody = 0

function card.RefreshRuntimeData()
    HasBloody = Cat2.IsTalentLearned(1, 10)
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local bloodyWaitSeconds = context:GetStepOption(step, "bloodyWaitSeconds") or 3

    if not player.targetExists then
        return false
    end

    -- 存在更高星级割裂卡时，优先等待血腥气息保护。
    if HasBloody > 0 then
        if context:IsCardActive("rogue_rupture_bloody_1")
        or context:IsCardActive("rogue_rupture_bloody_2")
        or context:IsCardActive("rogue_rupture_bloody_3")
        or context:IsCardActive("rogue_rupture_bloody_4")
        or context:IsCardActive("rogue_rupture_bloody_5") then
            if not Cat2.GetRogueBloody(bloodyWaitSeconds) then
                return false
            end
        end
    end

    if player.power >= 30 and player.targetCombo == 1 then
        Cat2.Cast("剔骨")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
