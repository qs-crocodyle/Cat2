-- 种族天赋爆发卡：根据玩家种族选择感知、血性狂怒或狂暴。
local function GetRacialBurstSpellName()
    local raceFile = Cat2.PlayerInformation.basic.raceFile
    if raceFile == "Human" then
        return "感知"
    end
    if raceFile == "Orc" then
        return "血性狂怒"
    end
    if raceFile == "Troll" then
        return "狂暴"
    end
    return nil
end

-- 快捷窗只显示当前角色实际拥有的种族技能CD；其他种族不显示CD数字。
local function GetRacialBurstCooldown()
    local spellName = GetRacialBurstSpellName()
    if not spellName or not Cat2.GetSpellID then
        return nil
    end

    local spellBookIndex = Cat2.GetSpellID(spellName)
    if not spellBookIndex or spellBookIndex == 0 then
        return nil
    end

    return GetSpellCooldown(spellBookIndex, "spell")
end

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
    cooldown = {
        type = "custom",
        cacheKey = "spell:player_racial_burst",
        filterGlobalCooldown = true,
        GetCooldown = GetRacialBurstCooldown,
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
	if Cat2.PlayerInformation.basic.raceFile=="Human" then
		if Cat2.SpellReadyOffset("感知",1.0) then
            Cat2.Cast("感知")
            return true -- 感知有GCD
        end
	end

	-- 开启 兽人-血性狂怒
	if Cat2.PlayerInformation.basic.raceFile=="Orc" then
		if Cat2.SpellReady("血性狂怒") then Cat2.Cast("血性狂怒") end
	end
		
	-- 开启 巨魔-狂暴
	if Cat2.PlayerInformation.basic.raceFile=="Troll" then
		if Cat2.SpellReady("狂暴") then Cat2.Cast("狂暴") end
	end

end

Cat2.RegisterCard(card)
