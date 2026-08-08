-- 出血 技能卡片。
local card = {
    id = "rogue_hemorrhage",
    name = "出血",
    description = "根据天赋决定是35/40能量施放出血",
    details = "根据天赋决定是35/40能量施放出血。需要存在有效目标。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 110,
    category = "class",
    canStopSequence = true,
    classes = {
        ROGUE = 3,
    },
    icons = {
        "Interface\\Icons\\Spell_Shadow_LifeDrain",
    },
}

local hemorrhagePower = 40
local allowUse = 0

function card.RefreshRuntimeData()
    
    hemorrhagePower = 40

    local count = Cat2.IsTalentLearned(3,17)
    if count==1 then
        hemorrhagePower = hemorrhagePower -2
    elseif count==2 then
        hemorrhagePower = hemorrhagePower - 5
    end

    allowUse = Cat2.IsTalentLearned(3,10)

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

    if player.power >= hemorrhagePower then
        CastSpellByName("出血")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
