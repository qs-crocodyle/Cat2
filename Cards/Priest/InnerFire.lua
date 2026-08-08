-- 心灵之火 技能卡片。
local card = {
    id = "priest_inner_fire",
    name = "心灵之火",
    description = "保持并施放心灵之火",
    details = "保持并施放心灵之火。成功执行时会阻断本轮后续卡片。",
    sort = 30,
    category = "class",
    classes = {
        PRIEST = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_InnerFire",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.buff["心灵之火"] then
        Cat2.CastWithoutNampower("心灵之火")
        return true
    end

    return false

end

Cat2.RegisterCard(card)