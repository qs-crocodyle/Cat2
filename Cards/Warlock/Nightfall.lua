-- 夜幕技能卡片：暗影冥思触发时施放瞬发暗影箭。
local card = {
    id = "warlock_nightfall",
    name = "夜幕",
    description = "暗影冥思触发时施放顺发暗影箭",
    details = "暗影冥思触发时施放顺发暗影箭。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    sort = 135,
    category = "class",
    classes = { WARLOCK = 1 },
    icons = { "Interface\\Icons\\Spell_Shadow_Twilight",
        "Interface\\Icons\\Spell_Shadow_ShadowBolt",
    },
}

local allowUse = 0
local distance = 30

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,11)
    distance = tonumber(Cat2.Match(Cat2.GetSpellTooltip("暗影箭", "等级 1"), "(%d+)码距离"))
    if not distance then
        distance = 30
    end
end

function card.Execute(context)
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if Cat2.UnitXP then
        local targetDistance = UnitXP("distanceBetween", "player", "target")
        if targetDistance and targetDistance > distance then
            return false
        end
    end

    local elapsed = GetTime() - Cat2.GetShadowTwilightTimer()
    if elapsed>1.5 and Cat2.BuffFromTex("Interface\\Icons\\Spell_Shadow_Twilight") then
        Cat2.CastWarlockWithDrainInterrupt(context, "warlockNightfallInterruptChannel", "暗影箭")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
