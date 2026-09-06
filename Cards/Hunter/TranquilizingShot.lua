-- 宁神射击 技能卡片。
local card = {
    id = "hunter_tranquilizing_shot",
    name = "宁神射击",
    description = "目标狂暴时，施放宁神射击",
    details = "目标拥有狂乱、疯狂或影爪暴怒时，施放宁神射击。仅在技能冷却完毕时尝试执行。成功执行时会阻断本轮后续卡片。",
    sort = 4,
    category = "class",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_Drowsy",
    },
    cooldown = {
        type = "spell",
        name = "宁神射击",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    if not player.targetExists then
        return false
    end

    local targetBuff = player.targetBuff
    if not targetBuff["狂乱"]
        and not targetBuff["疯狂"]
        and not targetBuff["影爪暴怒"] then
        return false
    end

    if Cat2.SpellReady("宁神射击") then
        Cat2.Cast("宁神射击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)
