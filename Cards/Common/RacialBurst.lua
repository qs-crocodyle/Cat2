-- 种族天赋爆发卡：具体种族技能选择与施放条件留待后续实现。
local card = {
    id = "common_racial_burst",
    name = "自动种族天赋（爆发）",
    description = "人类-感知，兽人-血性狂怒，巨魔-狂暴",
    details = "人类-感知，兽人-血性狂怒，巨魔-狂暴。会检查目标距离。会检查战斗状态。仅在技能可用时尝试执行。",
    sort = 42,
    category = "common",
    icons = {
        "Interface\\Icons\\Racial_Troll_Berserk",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 必须战斗中才有意义
    if not player.inCombat then
        return false
    end

    -- 近战距离 被动卡
    local melee = context and context.parameters and context.parameters.trinketsOnlyMelee
    if melee then
        if not Cat2.TargetDistance() then
            return false
        end
    end

    -- 强敌 被动卡
    local boss = context and context.parameters and context.parameters.trinketsOnlyBoss
    if boss then
        if not Cat2.IsBossTarget() then
            return false
        end
    end

	-- 开启 人类-感知
	if player.raceFile=="Human" then
		if Cat2.SpellReady("感知") then CastSpellByName("感知") end
	end

	-- 开启 兽人-血性狂怒
	if player.raceFile=="Orc" then
		if Cat2.SpellReady("血性狂怒") then CastSpellByName("血性狂怒") end
	end
		
	-- 开启 巨魔-狂暴
	if player.raceFile=="Troll" then
		if Cat2.SpellReady("狂暴") then CastSpellByName("狂暴") end
	end

end

Cat2.RegisterCard(card)
