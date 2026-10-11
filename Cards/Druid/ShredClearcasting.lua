-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_shred_clearcasting",
    -- 界面中显示的卡片标题。
    name = "撕碎（清晰预兆）",
    -- 卡片标题下方显示的简短说明。
    description = "仅在清晰预兆存在时，从背后施放撕碎",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "仅在清晰预兆触发的节能施法效果存在时施放撕碎。需要存在有效目标，并满足原撕碎卡的背后判定。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 421.1,
    -- 仅能是 common、item、class 三种分类之一。
    category = "class",
    canStopSequence = true,
    -- 游戏职业文件代码；仅职业卡需要设置。
    classes = {
        DRUID = 2,
    },
    -- 魔兽客户端图标纹理路径。
    icons = {
        "Interface\\Icons\\Spell_Shadow_VampiricAura",
        "Interface\\Icons\\Spell_Nature_CrystalBall",
    },
}


local shredPower = 60

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()

    -- 天赋
    shredPower = 60- ( Cat2.IsTalentLearned(2,13) * 6 )

	-- 猫德T2.5套装特效
    local count = 0
	if Cat2.CheckInventoryItemName(1,"起源皮盔") then count=count+1 end
	if Cat2.CheckInventoryItemName(3,"起源肩垫") then count=count+1 end
	if Cat2.CheckInventoryItemName(5,"起源长袍") then count=count+1 end
	if Cat2.CheckInventoryItemName(7,"起源短裤") then count=count+1 end
	if Cat2.CheckInventoryItemName(8,"起源便靴") then count=count+1 end
	if count >2 then shredPower = shredPower-3 end

end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    -- 清晰预兆触发后，实际 Buff 名称为“节能施法”。
    if not player.buff["节能施法"] then
        return false
    end

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    if player.behind then
        if player.buff["节能施法"] then
            Cat2.CastWithNampower("撕碎")
            return true
        end
    end

    return false
end

Cat2.RegisterCard(card)
