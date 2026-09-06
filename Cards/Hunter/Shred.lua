-- 切碎 技能卡片。
local card = {
    id = "hunter_shred",
    name = "切碎",
    description = "目标在8码内且触发条件满足时，施放切碎",
    details = "目标在8码内且触发条件满足时，施放切碎。需要存在有效目标。会检查目标距离。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 29,
    category = "class",
    classes = {
        HUNTER = 3,
    },
    icons = {
        "Interface\\Icons\\INV_ThrowingKnife_06",
    },
    cooldown = {
        type = "spell",
        name = "切碎",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(3,10)
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    -- 目标必须位于8码范围内。
    if not Cat2.TargetDistance("target", 8) then
        return false
    end

    if Cat2.SpellReady("切碎") then
        Cat2.Cast("切碎")
        return true
    end

    return false

end

Cat2.RegisterCard(card)
