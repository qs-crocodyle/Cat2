-- 割裂（四星）技能卡片。
local card = {
    id = "rogue_rupture_4",
    name = "割裂（四星）",
    description = "拥有4连击点，割裂剩余|cff6bc7e0{refreshRemainingSeconds}秒|r时补割裂",
    details = "目标拥有4连击点，目标身上的割裂不存在或剩余时间低于卡片设定值时施放割裂。默认续杯时间为1秒，需要存在有效目标；目标不吃流血时不会施放。未加载SuperWoW或角色低于60级时，无法按精确剩余秒数续杯。成功执行时会阻断本轮后续卡片。",
    sort = 44,
    category = "class",
    classes = {
        ROGUE = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Rupture",
    },
    optionSchema = {
        {
            key = "refreshRemainingSeconds",
            type = "number",
            label = "剩余时间",
            shortLabel = "剩余",
            unit = "秒",
            default = 1,
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
    local refreshSeconds = context:GetStepOption(step, "refreshRemainingSeconds") or 1

    if not player.targetExists then
        return false
    end

    if not player.targetBleed then
        return false
    end

    if player.targetCombo == 4 and not Cat2.GetRuptureDot(refreshSeconds) then
        Cat2.Cast("割裂")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
