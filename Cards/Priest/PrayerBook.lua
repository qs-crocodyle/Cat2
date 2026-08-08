-- 祈祷之书技能卡片。
local card = {
    id = "priest_prayer_book",
    name = "祈祷之书",
    description = "施放祈祷之书",
    details = "施放祈祷之书。",
    sort = 45,
    category = "class",
    classes = {
        PRIEST = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Misc_Book_07",
        "Interface\\Icons\\Spell_Holy_FlashHeal",
        "Interface\\Icons\\Spell_Holy_GreaterHeal",
    },
}

function card.RefreshRuntimeData()
end

local switchHeal = 0

function card.Execute(context)

    if switchHeal == 0 then
        switchHeal = 1

        -- 使用 快速治疗
        return Cat2.ExecuteCardById(
            "priest_flash_heal",
            context
        )

    else
        switchHeal = 0

        -- 使用 强效治疗术
        return Cat2.ExecuteCardById(
            "priest_greater_heal",
            context
        )

    end

    return false
end

Cat2.RegisterCard(card)
