-- 摔绊 技能卡片。
local card = {
    id = "hunter_wing_clip",
    name = "摔绊",
    description = "对目标保持并施放摔绊",
    details = "对目标保持并施放摔绊。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    category = "class",
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\Ability_Rogue_Trip",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 沿用断筋的保持机制：目标缺少摔绊时才施放。
    if not player.targetBuff["摔绊"] then
        CastSpellByName("摔绊")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
