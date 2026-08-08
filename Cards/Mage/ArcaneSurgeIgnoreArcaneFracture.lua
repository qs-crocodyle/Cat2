-- 奥术涌动忽略奥术溃裂的被动卡片。
local card = {
    id = "mage_arcane_surge_ignore_arcane_fracture",
    name = "奥术涌动 奥术溃裂时忽略",
    description = "奥术溃裂存在时，忽略奥术涌动",
    details = "奥术溃裂存在时，忽略奥术涌动。作为被动规则，启用时影响当前流程。",
    sort = 31,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        MAGE = 1,
    },
    icons = {
        "Interface\\Icons\\INV_Enchant_EssenceMysticalLarge",
        "Interface\\Icons\\Spell_Arcane_Blast",
    },
}

function card.RefreshRuntimeData()
end

function card.Apply(context)
    context.parameters.arcaneSurgeIgnoreArcaneFracture = true
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
