-- 杀戮命令 技能卡片。
local card = {
    id = "hunter_kill_command",
    name = "杀戮命令",
    description = "攻击造成暴击时，施放杀戮命令",
    details = "攻击造成暴击时，施放杀戮命令。需要存在有效目标。仅在技能可用时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 1,
    category = "class",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\Ability_Hunter_KillCommand",
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1,19)
end

function card.Execute(context)

    -- 不存在这个天赋
    if allowUse==0 then
        return false
    end

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    if not UnitExists("pet") then
        return false
    end

    -- 暴击时间检测
    if Cat2.GetHunterGoreAllow() then
        if Cat2.SpellReady("杀戮命令") then
            CastSpellByName("杀戮命令")
            return true
        end
    end

    return false

end

Cat2.RegisterCard(card)
