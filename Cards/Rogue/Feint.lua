-- 佯攻技能卡片；冷却完成且能量足够时施放。
local card = {
    id = "rogue_feint",
    name = "佯攻",
    description = "仇恨>|cff6bc7e0{threatPercent}%|r时施放佯攻",
    details = "存在有效目标时，佯攻冷却完成且自身仇恨高于卡片设定值时施放。默认仇恨门槛为80%；暂无有效仇恨数据时按原后备逻辑处理。",
    sort = 92,
    category = "class",
    canStopSequence = true,
    classes = {
        ROGUE = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Feint",
    },
    cooldown = {
        type = "spell",
        name = "佯攻",
    },
    optionSchema = {
        {
            key = "threatPercent",
            type = "number",
            label = "触发仇恨",
            shortLabel = "仇恨",
            unit = "%",
            default = 80,
            minimum = 1,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local threatPercent = context:GetStepOption(step, "threatPercent") or 80

    if not player.targetExists then
        return false
    end

    -- 获取仇恨值
    local Threat = Cat2.GetHatredFromTWT()

    if Threat == -1 then
        if player.power>=20 and Cat2.SpellReady("佯攻") then
            Cat2.Cast("佯攻")
            return true
        end
    else
        if Threat>threatPercent then
            if player.power>=20 and Cat2.SpellReady("佯攻") then
                Cat2.Cast("佯攻")
                return true
            end
        end
    end


    return false
end

Cat2.RegisterCard(card)
