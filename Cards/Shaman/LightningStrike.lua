-- 闪电打击 技能卡片。
local card = {
    id = "shaman_lightning_strike",
    name = "闪电打击",
    description = "冷却时，施放闪电打击",
    details = "冷却时，施放闪电打击。需要存在有效目标。流程中存在“闪电打击切换图腾”被动卡且图腾名称非空时，仅在技能冷却即将结束且当前处于公共冷却前半段时尝试切换对应圣物。切换装备本身不会阻断流程；技能真正就绪后施放，成功执行时会阻断本轮后续卡片。",
    sort = 60,
    category = "class",
    classes = {
        SHAMAN = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_ThunderClap",
    },
    cooldown = { type = "spell", name = "闪电打击" },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    local desiredTotem = context and context.parameters and context.parameters.shamanLightningStrikeTotem
    if Cat2.SpellReadyOffset("闪电打击", 1.5) then
        Cat2.TryEquipShamanTotem(context, desiredTotem)
    end

    if Cat2.SpellReady("闪电打击") then
        Cat2.Cast("闪电打击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
