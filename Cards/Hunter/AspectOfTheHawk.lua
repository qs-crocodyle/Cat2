-- 雄鹰守护 技能卡片。
local card = {
    id = "hunter_aspect_of_the_hawk",
    name = "雄鹰守护",
    description = "切换并保持雄鹰守护",
    details = "切换并保持雄鹰守护。",
    sort = 10,
    category = "class",
    exclusiveGroup = "hunter_aspect",
    classes = {
        HUNTER = 1,
    },
    icons = {
        "Interface\\Icons\\Spell_Nature_RavenForm",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)

    local AutoViper = Cat2.CardRegistry.ById["hunter_auto_aspect_of_the_viper"]

    if context:IsCardActive("hunter_auto_aspect_of_the_viper")
        and AutoViper
        and type(AutoViper.GetCustomValue) == "function" then

        -- 检测自动蝰蛇守护是否运行中
        local value = AutoViper.GetCustomValue()
        if value then
            return false
        end
    end


    if not Cat2.PlayerInformation.temporary.buff["雄鹰守护"] then
        Cat2.Cast("雄鹰守护")
    end

end

Cat2.RegisterCard(card)
