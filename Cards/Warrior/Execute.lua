-- 斩杀 技能卡片。
local card = {
    id = "warrior_execute",
    name = "斩杀",
    description = "条件满足时，施放斩杀",
    details = "条件满足时，施放斩杀。需要存在有效目标。会检查当前资源。启用“斩杀时中断读条”后，施放前会中断猛击读条。成功执行时会阻断本轮后续卡片。",
    sort = 95,
    category = "class",
    classes = {
        WARRIOR = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Sword_48",
    },
}

local powerExecute = 15

function card.RefreshRuntimeData()

    powerExecute = 15

    if Cat2.IsTalentLearned(2,13) == 1 then
        powerExecute = powerExecute - 2
    elseif Cat2.IsTalentLearned(2,13) == 2 then
        powerExecute = powerExecute - 5
    end

end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end


    if player.power>=powerExecute and player.targetPercentHealth<19.9 then
        if context.parameters.warriorInterruptCastForExecute then
            if Cat2.GetIsCast() then
                SpellStopCasting()
            end
        end
        CastSpellByName("斩杀")
        return true
    end

end

Cat2.RegisterCard(card)
