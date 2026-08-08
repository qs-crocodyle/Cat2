-- 炎爆术 技能卡片。
local card = {
    id = "mage_pyroblast",
    name = "炎爆术",
    description = "施放炎爆术",
    details = "施放炎爆术。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 50,
    category = "class",
    classes = {
        MAGE = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Fire_Fireball02",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(2,8)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    Cat2.CastWithoutNampower("炎爆术")

    return true

end

Cat2.RegisterCard(card)