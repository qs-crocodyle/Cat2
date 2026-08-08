-- 割裂（五星）技能卡片。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "rogue_rupture_5",
    -- 界面中显示的卡片标题。
    name = "割裂（五星）",
    -- 卡片标题下方显示的简短说明。
    description = "消耗5连击点施放割裂",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "消耗5连击点施放割裂。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；同一技能的一至五星使用连续数字。
    sort = 45,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        ROGUE = 1,
    },
    -- 使用此技能明确指定的图标。
    icons = {
        "Interface\\Icons\\Ability_Rogue_Rupture",
    },
}

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()
end

-- 仅在目标连击点等于本卡星数时施放，并终止本轮后续流程。
function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    if player.targetCombo == 5 and not Cat2.GetRogueBloody(1) then
        CastSpellByName("割裂")
        return true
    end

    return false
end

Cat2.RegisterCard(card)

