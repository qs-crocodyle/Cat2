-- 玩家运行时信息中心：供 Cat2 所有模块读取角色基础数据与临时状态。
-- 此处不使用 SavedVariables；重新登录或重载界面后会由游戏 API 重新建立数据。
Cat2 = Cat2 or {}

Cat2.PlayerInformation = Cat2.PlayerInformation or {
    basic = {},
    temporary = {}
}

local playerInformation = Cat2.PlayerInformation
local basic = playerInformation.basic
local temporary = playerInformation.temporary

-- 刷新变化频率较低的角色基础信息。
function Cat2.RefreshPlayerBasicInformation()
    local localizedClass, classFile = UnitClass("player")
    local localizedRace, raceFile = UnitRace("player")
    basic.name = UnitName("player")
    _,basic.guid = UnitExists("player")
    basic.realm = GetRealmName()
    basic.localizedClass = localizedClass
    basic.classFile = classFile
    basic.localizedRace = localizedRace
    basic.raceFile = raceFile
    basic.faction = UnitFactionGroup("player")
    basic.sex = UnitSex("player")
    basic.level = UnitLevel("player")
end

-- 重置会频繁变化的临时字段，方便重新登录或后续模块主动清理状态。
function Cat2.ResetPlayerTemporaryInformation()
    temporary.initialized = false
    temporary.inCombat = false
    temporary.health = 0
    temporary.maximumHealth = 0
    temporary.percentHealth = 0
    temporary.power = 0
    temporary.mana = 0
    temporary.maxMana = 0
    temporary.percentMana = 0
    temporary.maximumPower = 0
    temporary.powerType = 0
    temporary.buff = {}
    temporary.gcd = 0
    temporary.behind = true
    temporary.targetExists = false
    temporary.targetGUID = false
    temporary.targetName = nil
    temporary.targetLevel = nil
    temporary.targetClassification = nil
    temporary.targetCreatureType = nil
    temporary.targetCanAttack = false
    temporary.targetIsDead = false
    temporary.targetInCombat = false
    temporary.lastRefreshTime = 0
    temporary.targetBuff = {}
    temporary.targetCombo = 0
    temporary.targetBleed = true
    temporary.targetHealth = 0
    temporary.targetIsBoss = false
    temporary.targetPercentHealth = 0
end

-- 从游戏 API 刷新角色资源、战斗状态和当前目标信息。
function Cat2.RefreshPlayerTemporaryInformation()
    temporary.initialized = true
    temporary.inCombat = UnitAffectingCombat("player") and true or false
    temporary.health = UnitHealth("player") or 0
    temporary.maximumHealth = UnitHealthMax("player") or 0
    temporary.percentHealth = (temporary.health / temporary.maximumHealth) * 100
    temporary.mana = UnitMana("player") or 0
    if Cat2.PlayerInformation.basic.classFile == "DRUID" then
        temporary.power = UnitMana("player") or 0
        temporary.mana = UnitMana("player") or 0
        temporary.maxMana = UnitManaMax("player") or 0
    else
        temporary.power = UnitMana("player") or 0
        temporary.maxMana = UnitManaMax("player")
    end
    temporary.percentMana = (temporary.mana / temporary.maxMana) * 100
    temporary.maximumPower = UnitManaMax("player") or 0
    temporary.powerType = UnitPowerType("player") or 0
    temporary.buff = Cat2.BuffList()
    temporary.gcd = Cat2.GetLeftGCD()
    temporary.behind = Cat2.CheckBehind()
    temporary.targetExists, temporary.targetGUID = UnitExists("target")-- and true or false
    if temporary.targetExists then
        temporary.targetName = UnitName("target")
        temporary.targetLevel = UnitLevel("target")
        temporary.targetClassification = UnitClassification("target")
        temporary.targetCreatureType = UnitCreatureType("target")
        temporary.targetCanAttack = UnitCanAttack("player", "target") and true or false
        temporary.targetIsDead = UnitIsDeadOrGhost("target") and true or false
        temporary.targetInCombat = UnitAffectingCombat("target") and true or false
        temporary.targetBuff = Cat2.BuffList("target")
        temporary.targetCombo = GetComboPoints("target")
        temporary.targetBleed = Cat2.CanBleed("target")
        temporary.targetHealth = UnitHealth("target")
        temporary.targetIsBoss = Cat2.IsBossTarget()
        temporary.targetPercentHealth = UnitHealth("target") / UnitHealthMax("target") * 100
    else
        temporary.targetGUID = nil
        temporary.targetName = nil
        temporary.targetLevel = nil
        temporary.targetClassification = nil
        temporary.targetCreatureType = nil
        temporary.targetCanAttack = false
        temporary.targetIsDead = false
        temporary.targetInCombat = false
        temporary.targetBuff = {}
        temporary.targetCombo = 0
        temporary.targetBleed = true
        temporary.targetHealth = 0
        temporary.targetIsBoss = false
        temporary.targetPercentHealth = 0
    end
    temporary.lastRefreshTime = GetTime()
end

Cat2.ResetPlayerTemporaryInformation()
