-- 剔骨（四星）技能卡片。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "rogue_eviscerate_4",
    -- 界面中显示的卡片标题。
    name = "剔骨（四星）",
    -- 卡片标题下方显示的简短说明。
    description = "消耗4连击点施放剔骨",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "消耗4连击点施放剔骨。需要存在有效目标。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；同一技能的一至五星使用连续数字。
    sort = 24,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        ROGUE = 1,
    },
    -- 使用此技能明确指定的图标。
    icons = {
        "Interface\\Icons\\Ability_Rogue_Eviscerate",
    },
}

local HasBloody = 0

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()

    -- 这里天赋是两点，判断以0为标准
    HasBloody = Cat2.IsTalentLearned(1,10)

end

-- 仅在目标连击点等于本卡星数时施放，并终止本轮后续流程。
function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end


    -- 割裂卡片 前置处理
    -- 如果加入割裂卡片，割裂buff未上前，不打剔骨
    -- 这是个逻辑特殊处理，用于管理先后次序
    -- 有血腥气息才需要优先割裂
    if HasBloody>0 then
        if context:IsCardActive("rogue_rupture_1") or context:IsCardActive("rogue_rupture_2") or context:IsCardActive("rogue_rupture_3") or context:IsCardActive("rogue_rupture_4") or context:IsCardActive("rogue_rupture_5") then
            if not Cat2.GetRogueBloody(1) then
                return false
            end
        end
    end


    if player.targetCombo == 4 then
        CastSpellByName("剔骨")
        return true
    end

    return false
end

Cat2.RegisterCard(card)

