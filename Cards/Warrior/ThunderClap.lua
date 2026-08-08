-- 雷霆一击 技能卡片。
local card = {
    id = "warrior_thunder_clap",
    name = "雷霆一击",
    description = "对目标保持并施放雷霆一击",
    details = "对目标保持并施放雷霆一击。需要存在有效目标。会检查目标距离。会检查当前资源。成功执行时会阻断本轮后续卡片。",
    sort = 80,
    category = "class",
    classes = {
        WARRIOR = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_ThunderClap",
    },
}

local powerThunderClap = 20

function card.RefreshRuntimeData()

    if Cat2.IsTalentLearned(1,6)==3 then
        powerThunderClap = 20 - 4
    else
        powerThunderClap = 20 - Cat2.IsTalentLearned(1,6)
    end

end

function card.Execute(context)
    local player = Cat2.PlayerInformation.temporary

    -- 没有目标时无需继续。
    if not player.targetExists then
        return false
    end

    -- 近战距离
    if not Cat2.TargetDistance() then
        return false
    end

    -- 狂暴姿态下不执行。
    if Cat2.SetShape("狂暴姿态") then
        return false
    end


    if player.power>=powerThunderClap and not player.targetBuff["雷霆一击"] then
        CastSpellByName("雷霆一击")
        return true
    end

    return false
end

Cat2.RegisterCard(card)