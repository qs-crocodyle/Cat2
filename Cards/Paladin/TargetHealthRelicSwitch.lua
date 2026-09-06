-- 根据目标血量切换圣契；低于35%使用最终审判圣契，否则使用设定的常规圣契。
local card = {
    id = "paladin_target_health_relic_switch",
    name = "目标血量 切换圣契",
    description = "目标血量<35%装备|cff6bc7e0{lowHealthRelic}|r否则装备|cff6bc7e0{normalRelic}|r",
    details = "存在目标且公共冷却即将结束时，根据目标血量切换圣契。目标血量低于35%时装备低血量圣契，否则装备常规圣契。两个参数均可从下拉菜单选择，也可直接输入其他圣契名称；所选圣契不在背包中时不会切换。成功切换装备时会阻断本轮后续卡片。",
    sort = 999,
    category = "class",
    canStopSequence = true,
    classes = {
        PALADIN = 3,
    },
    icons = {
        "Interface\\Icons\\INV_Relics_LibramofTruth",
    },
    optionSchema = {
        {
            key = "lowHealthRelic",
            type = "string",
            control = "select",
            allowCustom = true,
            label = "低血量圣契",
            shortLabel = "低血",
            default = "最终审判圣契",
            choices = {
                { value = "最终审判圣契", label = "最终审判圣契" },
            },
        },
        {
            key = "normalRelic",
            type = "string",
            control = "select",
            allowCustom = true,
            label = "常规圣契",
            shortLabel = "常规",
            default = "永恒之塔圣契",
            choices = {
                { value = "永恒之塔圣契", label = "永恒之塔圣契" },
                { value = "热忱圣契", label = "热忱圣契" },
                { value = "神圣领域圣契", label = "神圣领域圣契" },
                { value = "热情圣契", label = "热情圣契" },
            },
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    -- 避免在公共冷却中频繁尝试换装，也避免与商人、银行等交互时操作背包。
    if player.gcd >= 0.3 or Cat2.CheckUIStatus() then
        return false
    end

    local lowHealthRelic = context:GetStepOption(step, "lowHealthRelic") or "最终审判圣契"
    local normalRelic = context:GetStepOption(step, "normalRelic") or "永恒之塔圣契"
    local desiredRelic = normalRelic
    if player.targetPercentHealth < 35 then
        desiredRelic = lowHealthRelic
    end

    -- 圣契使用远程/圣物栏位18；已经装备目标圣契时无需重复搜索背包。
    if Cat2.CheckInventoryItemName(18, desiredRelic) then
        return false
    end

    if Cat2.EquipItemByName(desiredRelic, 18) then
        return true
    end

    return false
end

Cat2.RegisterCard(card)
