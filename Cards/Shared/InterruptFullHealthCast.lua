-- 共享被动卡参考：策略本身不维护职业技能名单，只匹配各治疗卡 castProfile 中的能力标签。
-- 因此新增可中断治疗时应修改对应治疗卡，不需要扩展本文件；禁用本卡即可整体关闭该规则。
local card = {
    id = "shared_interrupt_full_health_cast",
    name = "治疗读条 满血中断",
    description = "技能目标满血时，中断允许取消的治疗读条",
    details = "治疗技能的实际施法目标达到满血时，中断被标记为允许取消的读条或引导。切换当前目标不会改变监控对象。作为被动规则，启用时影响当前流程。",
    sort = 447,
    behavior = "passive",
    unique = true,
    category = "class",
    classes = {
        DRUID = 3,
        SHAMAN = 3,
        PALADIN = 1,
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\Spell_Holy_Heal",
    },
    castInterruptPolicy = {
        mode = "any",
        matchTag = "fullHealthCancelable",
        rules = {
            {
                type = "targetHealthAtLeast",
                value = 100,
                reason = "技能目标已经满血",
            },
        },
    },
}

function card.RefreshRuntimeData()
end

function card.Validate(context)
    return true
end

Cat2.RegisterCard(card)
