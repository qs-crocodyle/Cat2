-- 恢复类功能 50% 被动卡片。
local card = {
    id = "item_recovery_percent_50",
    name = "恢复类药水 界限变50%",
    description = "恢复类药水 统一在50%使用",
    details = "恢复类药水 统一在50%使用。作为被动规则，启用时影响当前流程。",
    sort = 95,
    behavior = "passive",
    unique = true,
    category = "item",
    icons = {
        "Interface\\Icons\\Spell_Holy_Heal",
    },
}

function card.RefreshRuntimeData()
end

-- 被动卡片先于普通卡片应用，共享参数不受自身排列位置影响。
function card.Apply(context)
    context.parameters.recoveryPercent = 50
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
