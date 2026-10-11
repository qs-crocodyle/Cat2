-- 威慑：学习生存天赋后，在生命值低于设定比例时开启。
local card = {
    id = "hunter_deterrence",
    name = "威慑",
    description = "生命低于|cff6bc7e0{triggerPercent}%|r时开启威慑",
    details = "已学习威慑天赋，且生命低于设定比例、技能冷却就绪时开启威慑。默认触发生命为30%。不要求存在目标；威慑效果已存在时不重复施放。执行后结束本轮流程。",
    sort = 109,
    category = "class",
    canStopSequence = true,
    classes = { HUNTER = 3 },
    icons = { "Interface\\Icons\\Ability_Whirlwind" },
    cooldown = { type = "spell", name = "威慑" },
    optionSchema = {
        {
            key = "triggerPercent",
            type = "number",
            label = "触发生命",
            shortLabel = "血",
            unit = "%",
            default = 30,
            minimum = 1,
            maximum = 99,
        },
    },
    runtimeDataRefreshTriggers = { talents = true, spells = true },
}

local hasDeterrence = false

function card.RefreshRuntimeData()
    hasDeterrence = false
    -- 按名称查找生存天赋，避免不同天赋树版本的序号变化造成误判。
    local index = 1
    local total = GetNumTalents(3) or 0
    while index <= total do
        local name, _, _, _, rank = GetTalentInfo(3, index)
        if name == "威慑" or name == "Deterrence" then
            hasDeterrence = (rank or 0) > 0
            return
        end
        index = index + 1
    end
end

function card.Execute(context, step)
    if not hasDeterrence then return false end

    local player = Cat2.PlayerInformation.temporary
    local triggerPercent = context:GetStepOption(step, "triggerPercent") or 30
    if player.percentHealth >= triggerPercent or player.health <= 0 then return false end
    if player.buff and player.buff["威慑"] then return false end
    if not Cat2.SpellReady("威慑") then return false end

    Cat2.Cast("威慑")
    return true
end

Cat2.RegisterCard(card)
