-- 破甲（二星）技能卡片。
local card = {
    id = "rogue_expose_armor_2",
    name = "破甲（二星）",
    description = "拥有2连击点，破甲剩余|cff6bc7e0{refreshRemainingSeconds}秒|r时补破甲",
    details = "目标拥有2连击点，且目标身上的破甲不存在或剩余时间低于卡片设定值时施放破甲。默认续杯时间为5秒，需要存在有效目标。未加载SuperWoW或角色低于60级时，只能判断破甲是否存在，无法按精确剩余秒数续杯。成功执行时会阻断本轮后续卡片。",
    sort = 62,
    category = "class",
    classes = {
        ROGUE = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Warrior_Riposte",
    },
    optionSchema = {
        {
            key = "refreshRemainingSeconds",
            type = "number",
            label = "剩余时间",
            shortLabel = "剩余",
            unit = "秒",
            default = 5,
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
    local refreshSeconds = context:GetStepOption(step, "refreshRemainingSeconds") or 5

    if not player.targetExists then
        return false
    end

    if player.targetCombo == 2 and not Cat2.GetExposeArmorDot(refreshSeconds) then
        Cat2.Cast("破甲")
        return true
    end

    return false
end

Cat2.RegisterCard(card)

