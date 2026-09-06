-- 毒伤（五星）技能卡片。
local card = {
    id = "rogue_envenom_5",
    name = "毒伤（五星）",
    description = "拥有5连击点，毒伤剩余|cff6bc7e0{refreshRemainingSeconds}秒|r时补毒伤",
    details = "目标拥有5连击点，且玩家身上的毒伤不存在或剩余时间低于卡片设定值时施放毒伤。默认续杯时间为1秒，需要存在有效目标。未学习毒伤相关天赋时不会执行。未加载SuperWoW或角色低于60级时，只能判断毒伤是否存在，无法按精确剩余秒数续杯。成功执行时会阻断本轮后续卡片。",
    sort = 55,
    category = "class",
    classes = {
        ROGUE = 1,
    },
    icons = {
        "Interface\\Icons\\INV_Sword_31",
    },
    optionSchema = {
        {
            key = "refreshRemainingSeconds",
            type = "number",
            label = "剩余时间",
            shortLabel = "剩余",
            unit = "秒",
            default = 1,
            minimum = 0,
            maximum = 30,
            integer = false,
        },
    },
}

local allowUse = 0

function card.RefreshRuntimeData()
    allowUse = Cat2.IsTalentLearned(1, 14)
end

function card.Execute(context, step)
    local player = Cat2.PlayerInformation.temporary
    local refreshSeconds = context:GetStepOption(step, "refreshRemainingSeconds") or 1

    if not player.targetExists then
        return false
    end

    if allowUse == 0 then
        return false
    end

    if player.targetCombo == 5 and not Cat2.GetRogueEnvenom(refreshSeconds) then
        Cat2.Cast("毒伤")
        return true
    end

    return false
end

Cat2.RegisterCard(card)

