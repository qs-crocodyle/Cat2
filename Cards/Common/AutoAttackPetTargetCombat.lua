-- 仅对已经进入战斗的目标命令宠物开始攻击。
local card = {
    id = "common_auto_attack_pet_target_combat",
    name = "宠物自动攻击（已进入战斗目标）",
    description = "目标进入战斗后，让宠物开始或维持普通攻击",
    details = "宠物存在且当前目标已经进入战斗时，让宠物开始或维持普通攻击。",
    -- 紧随“宠物自动攻击”，并位于远程攻击卡之前。
    sort = 11.5,
    category = "common",
    icons = {
        "Interface\\Icons\\Ability_Rogue_ShadowStrikes",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not UnitExists("pet") then
        return false
    end

    if player.targetInCombat then
        PetAttack()
    end
end

Cat2.RegisterCard(card)
