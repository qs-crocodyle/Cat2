-- Cat2 流程编辑器模块。
-- 依赖 Cat2.lua、Core/CardRegistry.lua、Core/ClassSpecializations.lua、UI/Controls.lua 与 UI/Notice.lua。
-- 本文件负责配置状态；卡片、列表、标题区和窗口构造分别由 FlowEditor 配套模块完成。
-- 真正执行步骤由 Core/ConfigurationRunner.lua 完成。
--
-- 设计约束：左侧流程最多 60 张，右侧为按职业筛选后的卡片库。流程项是卡片定义的运行时副本，
-- 可独立暂停、隐藏最小化图标或调整顺序，但不会修改注册中心的原始卡片定义。
-- 多配置快捷窗完全由 UI/ShortcutWindows.lua 管理，本模块不再保留单窗口实现。
-- RuntimeConfigurations 的创建入口位于本文件，但持久化由 Core/Persistence.lua 负责、执行由
-- Core/ConfigurationRunner.lua 负责。修改 step 结构时必须同时检查这三个模块及导入导出编码器。
-- 重绘应尽量复用已创建 Frame；拖动只改变顺序，单击才改变选中状态。
-- 加载顺序：本文件 → FlowEditorCards → FlowEditorLists → FlowEditorHeader → FlowEditorWindow。
-- 跨模块可变引用统一访问 editor，不另存 selectedSteps/runtimeConfigurations 的局部副本，
-- 避免切换或导入配置后仍操作旧列表；模块自己的临时变量和闭包继续保持 local。
local ui = Cat2.UI
-- 编辑器内部共享对象；其他模块仅通过此对象共享可变状态与内部方法。
local editor = {}
ui.FlowEditor = editor
-- 从 Controls 与 Notice 模块取得的跨文件公共 UI 函数。
local ApplyFlatBackdrop = ui.ApplyFlatBackdrop
local IsCursorInside = ui.IsCursorInside
local SetScrollPosition = ui.SetScrollPosition
local UpdateScrollBar = ui.UpdateScrollBar
local CreateScrollArea = ui.CreateScrollArea
local ShowNotice = ui.ShowNotice
local ShowConfirm = ui.ShowConfirm
local ShowTextInput = ui.ShowTextInput
local CloseAllDialogs = ui.CloseAllDialogs

-- 按 UTF-8 字符计数，中文与英文字符都按一个字符计算。
function editor.CountTextCharacters(text)
    local count = 0
    local index = 1
    local byteTotal = string.len(text)
    while index <= byteTotal do
        local firstByte = string.byte(text, index)
        if firstByte < 128 then
            index = index + 1
        elseif firstByte < 224 then
            index = index + 2
        elseif firstByte < 240 then
            index = index + 3
        else
            index = index + 4
        end
        count = count + 1
    end
    return count
end

-- 将卡片简介中的 {参数名} 替换为当前流程实例的实际参数值。
-- 本函数只由界面重绘调用；/cat2 执行流程不会经过这里，因此不会增加按宏的运行成本。
function editor.GetCardDescriptionText(step)
    if type(step) ~= "table" then
        return ""
    end
    local template = step.description
    if type(template) ~= "string" or template == "" then
        return ""
    end

    local output = ""
    local cursor = 1
    while cursor <= string.len(template) do
        local openIndex = string.find(template, "{", cursor, true)
        if not openIndex then
            output = output .. string.sub(template, cursor)
            break
        end
        local closeIndex = string.find(template, "}", openIndex + 1, true)
        if not closeIndex then
            output = output .. string.sub(template, cursor)
            break
        end
        output = output .. string.sub(template, cursor, openIndex - 1)
        local optionKey = string.sub(template, openIndex + 1, closeIndex - 1)
        local optionValue = nil
        if Cat2.ResolveStepOption then
            optionValue = Cat2.ResolveStepOption(step, optionKey, nil)
        end
        if optionValue == nil then
            output = output .. string.sub(template, openIndex, closeIndex)
        else
            local definition = Cat2.GetCardOptionDefinition and Cat2.GetCardOptionDefinition(step, optionKey) or nil
            if Cat2.GetCardOptionDisplayValue then
                output = output .. (Cat2.GetCardOptionDisplayValue(definition, optionValue, step) or tostring(optionValue))
            else
                output = output .. tostring(optionValue)
            end
        end
        cursor = closeIndex + 1
    end
    return output
end

-- 互斥组使用固定的十二色主题表；颜色保持克制，避免盖过卡片标题和状态反馈。
local exclusiveGroupColors = {
    { 0.36, 0.72, 1 },
    { 1, 0.58, 0.24 },
    { 0.76, 0.48, 1 },
    { 0.35, 0.82, 0.55 },
    { 1, 0.42, 0.52 },
    { 0.28, 0.82, 0.86 },
    { 0.94, 0.75, 0.27 },
    { 0.92, 0.42, 0.78 },
    { 0.42, 0.56, 0.94 },
    { 0.66, 0.78, 0.32 },
    { 0.64, 0.52, 0.82 },
    { 0.86, 0.5, 0.4 }
}

-- 按卡片注册顺序为不同互斥组依次分配颜色；前十二个组保证不会发生颜色碰撞。
local exclusiveGroupColorIndexes = {}
local nextExclusiveGroupColorIndex = 1

local function AssignExclusiveGroupColor(groupName)
    if type(groupName) ~= "string" or groupName == "" then
        return
    end
    if exclusiveGroupColorIndexes[groupName] then
        return
    end
    exclusiveGroupColorIndexes[groupName] = nextExclusiveGroupColorIndex
    nextExclusiveGroupColorIndex = nextExclusiveGroupColorIndex + 1
    if nextExclusiveGroupColorIndex > table.getn(exclusiveGroupColors) then
        nextExclusiveGroupColorIndex = 1
    end
end

local registeredCardIndex = 1
local registeredCards = Cat2.CardRegistry and Cat2.CardRegistry.Cards or {}
local registeredCardTotal = table.getn(registeredCards)
while registeredCardIndex <= registeredCardTotal do
    AssignExclusiveGroupColor(registeredCards[registeredCardIndex].exclusiveGroup)
    registeredCardIndex = registeredCardIndex + 1
end

function editor.GetExclusiveGroupColor(groupName)
    AssignExclusiveGroupColor(groupName)
    local colorIndex = exclusiveGroupColorIndexes[groupName]
    if not colorIndex then
        return nil
    end
    return exclusiveGroupColors[colorIndex]
end

-- 主窗口、左右面板、滚动区域和滚动条引用。
editor.mainWindow = nil
editor.flowPanel = nil
editor.availablePanel = nil
editor.centerGap = nil
editor.footerActions = nil
editor.profileActions = nil
editor.flowScroll = nil
editor.availableScroll = nil
editor.flowContent = nil
editor.availableContent = nil
editor.flowSlider = nil
editor.availableSlider = nil
-- 拖放辅助视觉：插入位置提示线、空流程提示和数量文本。
editor.dropIndicator = nil
editor.emptyHint = nil
editor.flowCountText = nil
-- 插件文件执行时角色 SavedVariables 尚未加载，因此先建立安全的默认仓库。
-- 真正的数据恢复会延迟到 PLAYER_LOGIN 之后的首次界面打开或流程执行。
editor.runtimeConfigurations = {
    schemaVersion = 1,
    activeProfileId = 1,
    nextProfileId = 2,
    profileOrder = { 1 },
    profiles = {
        [1] = { id = 1, name = "Profile1", steps = {} }
    }
}
local configurationDataLoaded = false
-- 暴露当前角色的运行时配置仓库，供执行器、导入导出和设置模块复用。
Cat2.RuntimeConfigurations = editor.runtimeConfigurations
-- selectedSteps 始终指向当前配置的 steps；切换配置只需更换此引用。
editor.selectedSteps = editor.runtimeConfigurations.profiles[editor.runtimeConfigurations.activeProfileId].steps
editor.selectedFlowIndex = nil
-- 每次重绘生成的左右卡片框体引用，用于隐藏旧框体。
editor.leftBlocks = {}
editor.availableBlocks = {}
-- 卡片框体一经创建便无法由旧客户端真正销毁；按卡片 ID 与重复序号复用，
-- 避免每次选中、排序或切换标签页时累积大量仅被 Hide 的 Frame。
editor.flowBlockCache = {}
editor.availableBlockCache = {}
editor.dragGhost = nil
-- 流程最大容量；达到限制时显示通用提示弹窗。
editor.maximumFlowSteps = 60
-- 右侧标签页为互斥单选；默认显示通用卡片。
editor.selectedFilter = "common"
editor.filterTabs = {}

-- 右侧经过职业筛选后的可用卡片缓存。
editor.availableSteps = {}

editor.RedrawFlow = nil
editor.RedrawAvailable = nil

-- 必须在 SavedVariables 加载完成后调用；重复调用不会覆盖当前会话中的修改。
function Cat2.EnsureConfigurationDataLoaded()
    if configurationDataLoaded then
        return
    end
    editor.runtimeConfigurations = Cat2.LoadConfigurationData()
    Cat2.RuntimeConfigurations = editor.runtimeConfigurations
    editor.selectedSteps = editor.runtimeConfigurations.profiles[editor.runtimeConfigurations.activeProfileId].steps
    configurationDataLoaded = true
end

-- PLAYER_LOGIN 发生时 SavedVariables 已就绪，立即恢复当前角色配置。
local configurationLoadFrame = CreateFrame("Frame")
configurationLoadFrame:RegisterEvent("PLAYER_LOGIN")
configurationLoadFrame:SetScript("OnEvent", function()
    Cat2.EnsureConfigurationDataLoaded()
    -- 每个配置都有独立快捷窗状态，登录时必须统一扫描，不能再依赖旧版单窗口开关。
    if Cat2.UI.RestoreMinimizedWindow then
        Cat2.UI.RestoreMinimizedWindow()
    end
end)

function editor.SaveRuntimeConfigurations()
    Cat2.SaveConfigurationData(editor.runtimeConfigurations)
end

-- 由右侧定义卡片创建左侧流程实例，并复制后续执行所需字段。
function editor.CreateFlowStep(step)
    return {
        id = step.id,
        name = step.name,
        description = step.description,
        details = step.details,
        icons = step.icons,
        category = step.category,
        classes = step.classes,
        sort = step.sort,
        behavior = step.behavior,
        unique = step.unique,
        exclusiveGroup = step.exclusiveGroup,
        canStopSequence = step.canStopSequence,
        optionSchema = step.optionSchema,
        optionValues = {},
        Apply = step.Apply,
        Validate = step.Validate,
        RefreshRuntimeData = step.RefreshRuntimeData,
        Execute = step.Execute,
        enabled = 1,
        -- 新加入流程的卡片默认显示在快捷小窗；之后仍可由用户单独隐藏。
        minimizedVisible = 1
    }
end


-- 查询同名配置，供导入流程在真正写入前决定是否需要覆盖确认。
function ui.FindConfigurationByName(profileName)
    Cat2.EnsureConfigurationDataLoaded()
    local orderIndex = 1
    local orderTotal = table.getn(editor.runtimeConfigurations.profileOrder)
    while orderIndex <= orderTotal do
        local profileId = editor.runtimeConfigurations.profileOrder[orderIndex]
        local profile = editor.runtimeConfigurations.profiles[profileId]
        if profile and profile.name == profileName then
            return profileId
        end
        orderIndex = orderIndex + 1
    end
    return nil
end

-- 写入已经通过格式、校验和及职业检查的配置，并立即切换主界面当前配置。
function ui.ApplyImportedConfiguration(importedProfile, overwriteProfileId)
    Cat2.EnsureConfigurationDataLoaded()
    if type(importedProfile) ~= "table" or type(importedProfile.steps) ~= "table" then
        return false, Cat2.L("导入配置数据无效")
    end

    local runtimeSteps = {}
    local stepIndex = 1
    local stepTotal = table.getn(importedProfile.steps)
    while stepIndex <= stepTotal do
        local restored = Cat2.RestoreConfigurationStep(importedProfile.steps[stepIndex])
        if restored then
            table.insert(runtimeSteps, restored)
        end
        stepIndex = stepIndex + 1
    end
    Cat2.NormalizeExclusiveFlowSteps(runtimeSteps)

    local profileId = overwriteProfileId
    if profileId then
        local existing = editor.runtimeConfigurations.profiles[profileId]
        if not existing then
            return false, Cat2.L("需要覆盖的配置已经不存在")
        end
        existing.name = importedProfile.name
        existing.steps = runtimeSteps
    else
        profileId = editor.runtimeConfigurations.nextProfileId
        editor.runtimeConfigurations.nextProfileId = profileId + 1
        editor.runtimeConfigurations.profiles[profileId] = {
            id = profileId,
            name = importedProfile.name,
            steps = runtimeSteps
        }
        table.insert(editor.runtimeConfigurations.profileOrder, profileId)
    end

    editor.runtimeConfigurations.activeProfileId = profileId
    editor.selectedSteps = editor.runtimeConfigurations.profiles[profileId].steps
    editor.selectedFlowIndex = nil

    -- 第三版配置文本携带快捷窗排列方式；旧版文本没有这些字段时保留本地设置。
    if importedProfile.direction and importedProfile.iconLimit and Cat2.GetProfileShortcutWindowSettings and Cat2.SaveProfileShortcutWindowSettings then
        local visible, _, _, left, top, scale = Cat2.GetProfileShortcutWindowSettings(profileId)
        Cat2.SaveProfileShortcutWindowSettings(
            profileId,
            visible,
            importedProfile.iconLimit,
            importedProfile.direction,
            left,
            top,
            scale
        )
    end

    if editor.mainWindow and editor.mainWindow.UpdateProfileText then
        editor.mainWindow.UpdateProfileText()
    end
    editor.RedrawFlow()
    if ui.RedrawMinimizedShortcuts then
        ui.RedrawMinimizedShortcuts()
    end
    if ui.RefreshProfileManager then
        ui.RefreshProfileManager()
    end
    return true
end

-- 供配置级快捷窗调用：切换编辑器当前配置并刷新依赖当前流程的界面。
function ui.SelectConfigurationProfile(profileId)
    Cat2.EnsureConfigurationDataLoaded()
    local profile = editor.runtimeConfigurations.profiles[profileId]
    if not profile then
        return false
    end
    editor.runtimeConfigurations.activeProfileId = profileId
    editor.selectedSteps = profile.steps
    editor.selectedFlowIndex = nil
    -- 快捷窗可在主界面尚未创建时先切换配置；此时只更新数据，
    -- 由随后 ShowMainWindow 的创建流程完成首次绘制，避免访问尚不存在的列表控件。
    if editor.mainWindow then
        if editor.mainWindow.UpdateProfileText then
            editor.mainWindow.UpdateProfileText()
        end
        if editor.RedrawFlow then
            editor.RedrawFlow()
        end
        if editor.RedrawAvailable then
            editor.RedrawAvailable()
        end
    end
    editor.SaveRuntimeConfigurations()
    return true
end
