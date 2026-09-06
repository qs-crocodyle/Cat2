-- 自动射击 技能卡片。
local card = {
    id = "hunter_auto_shot",
    name = "自动射击",
    description = "施放并保持自动射击",
    details = "施放并保持自动射击。",
    sort = 10,
    category = "class",
    classes = {
        HUNTER = 2,
    },
    icons = {
        "Interface\\Icons\\INV_Weapon_Rifle_06",
    },
}

function card.RefreshRuntimeData()
end

function Cat2.AutoShot()

	if Cat2.GetAutoShot()==0 then
		Cat2.Cast("自动射击")
	end

end

function Cat2.StopShot()

	if Cat2.GetAutoShot()==1 then
		Cat2.Cast("自动射击")
	end

end


function card.Execute(context)

    local player = Cat2.PlayerInformation.temporary

    -- 没目标就无需继续
    if not player.targetExists then
        return false
    end

    Cat2.AutoShot()
end

Cat2.RegisterCard(card)