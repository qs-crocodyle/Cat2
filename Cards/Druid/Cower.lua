-- 畏缩技能卡片；猎豹形态下冷却完成且能量足够时施放。
local card = {
    id = "druid_cower",
    name = "畏缩",
    description = "猎豹形态下，仇恨>|cff6bc7e0{threatPercent}%|r时施放畏缩",
    details = "猎豹形态下，畏缩冷却完成且自身仇恨高于卡片设定值时施放。默认仇恨门槛为80%；暂无有效仇恨数据时按原后备逻辑处理。",
    sort = 423.3,
    category = "class",
    canStopSequence = true,
    classes = {
        DRUID = 2,
    },
    icons = {
        "Interface\\Icons\\Ability_Druid_Cower",
    },
    cooldown = { type = "spell", name = "畏缩" },
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

    if not player.buff["猎豹形态"] then
        return false
    end

    -- 获取仇恨值
    local Threat = Cat2.GetHatredFromTWT()

    if Threat == -1 then

        -- 暂无有效目标、队伍或服务端仇恨数据。
        if player.power>=20 and Cat2.SpellReady("畏缩") then
            Cat2.Cast("畏缩")
            return true
        end

    else

        if Threat>threatPercent then
            if player.power>=20 and Cat2.SpellReady("畏缩") then
                Cat2.Cast("畏缩")
                return true
            end
        end

    end

    return false
end

Cat2.RegisterCard(card)
