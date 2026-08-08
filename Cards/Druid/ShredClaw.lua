-- 卡片数据定义。
local card = {
    -- 稳定唯一标识；用于后续保存流程与跨版本迁移。
    id = "druid_shredclaw",
    -- 界面中显示的卡片标题。
    name = "平衡 撕碎/爪击",
    -- 卡片标题下方显示的简短说明。
    description = "自动判断，背后撕碎/正面爪击",
    -- 预留给后续详情面板或 Tooltip 的完整功能说明。
    details = "自动判断，背后撕碎/正面爪击。需要存在有效目标。会检查当前资源。会检查与目标的相对位置。成功执行时会阻断本轮后续卡片。",
    -- 同一分类内按升序排列；建议留出间隙以便新增卡片。
    sort = 422,
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
    "Interface\\Icons\\Ability_Druid_Rake",
    },
}


local shredPower = 60
local clawPower = 45

-- 插件启动时注册卡片后调用一次。
function card.RefreshRuntimeData()

    -- 天赋
    shredPower = 60- ( Cat2.IsTalentLearned(2,13) * 6 )
    clawPower = 45-Cat2.IsTalentLearned(2,1)

	-- 猫德T2.5套装特效
    local count = 0
	if Cat2.CheckInventoryItemName(1,"起源皮盔") then count=count+1 end
	if Cat2.CheckInventoryItemName(3,"起源肩垫") then count=count+1 end
	if Cat2.CheckInventoryItemName(5,"起源长袍") then count=count+1 end
	if Cat2.CheckInventoryItemName(7,"起源短裤") then count=count+1 end
	if Cat2.CheckInventoryItemName(8,"起源便靴") then count=count+1 end
	if count >2 then shredPower = shredPower-3 end
	if count >2 then clawPower = clawPower-3 end

	if Cat2.CheckInventoryItemName(18,"凶猛神像") then clawPower = clawPower-3 end

end

-- 返回后续流程执行器读取的动作描述。
function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end


    if player.behind then
        if player.power>=shredPower or player.buff["节能施法"] then
            CastSpellByName("撕碎")
            return true
        end
    else
        if player.power>=clawPower or player.buff["节能施法"] then
            CastSpellByName("爪击")
            return true
        end
    end

    return false
end

Cat2.RegisterCard(card)
