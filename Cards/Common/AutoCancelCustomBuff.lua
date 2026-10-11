-- 按自定义名称取消玩家身上的 Buff。
local card = {
    id = "common_auto_cancel_custom_buff",
    name = "「自定义」自动取消Buff",
    description = "自动取消自身的|cff6bc7e0{buffName}|r增益效果",
    details = "填写要取消的Buff完整名称。自身存在该Buff时取消，不存在或名称为空时跳过；不阻断本轮后续卡片。",
    -- 紧随“自动取消法系Buff”。
    sort = 53,
    category = "common",
    icons = {
        "Interface\\Icons\\Spell_Holy_DispelMagic",
    },
    optionSchema = {
        {
            key = "buffName",
            type = "string",
            label = "Buff名称",
            shortLabel = "Buff",
            default = "",
        },
    },
}

function card.Execute(context, step)
    local buffName = context:GetStepOption(step, "buffName")
    if type(buffName) ~= "string" or buffName == "" then
        return false
    end

    -- 共用接口实时检查玩家Buff，只有完整名称匹配时才取消。
    Cat2.CancelBuffByName(buffName)
    return false
end

Cat2.RegisterCard(card)
