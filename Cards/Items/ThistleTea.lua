-- 菊花茶卡片。
local card = {
    id = "item_thistle_tea",
    name = "菊花茶",
    description = "能量低于|cff6bc7e0{energyLimit}|r时使用菊花茶，仅限盗贼",
    details = "盗贼战斗中能量低于卡片设定值时使用菊花茶。未单独设置时使用默认值15。会检查战斗状态与当前资源。",
    sort = 100,
    category = "item",
    icons = {
        "Interface\\Icons\\INV_Drink_Milk_05",
    },
    cooldown = {
        type = "item",
        name = "菊花茶",
    },
    optionSchema = {
        {
            key = "energyLimit",
            type = "number",
            label = "触发能量",
            shortLabel = "能量",
            default = 15,
            minimum = 1,
            maximum = 100,
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)

    local player = Cat2.PlayerInformation.temporary
    local energyLimit = context:GetStepOption(step, "energyLimit") or 15

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    local boss = context and context.parameters and context.parameters.burstOnlyBoss
    if boss then
        if not Cat2.IsBossTarget() then
            return false
        end
    end

    local melee = context and context.parameters and context.parameters.burstOnlyMelee
    if melee and not Cat2.TargetDistance() then
        return false
    end


    if Cat2.PlayerInformation.basic.classFile == "ROGUE" then

        if player.power < energyLimit then
            Cat2.UseItemByName("菊花茶")
        end

    end

end

Cat2.RegisterCard(card)
