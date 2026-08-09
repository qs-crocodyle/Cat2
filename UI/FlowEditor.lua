-- Cat2 流程编辑器模块。
-- 依赖 Cat2.lua、Core/CardRegistry.lua、Core/ClassSpecializations.lua、UI/Controls.lua 与 UI/Notice.lua。
-- 本文件只负责编辑体验与本次登录的流程数据；真正执行步骤由 Core/ConfigurationRunner.lua 完成。
--
-- 设计约束：左侧流程最多 60 张，右侧为按职业筛选后的卡片库。流程项是卡片定义的运行时副本，
-- 可独立暂停、隐藏最小化图标或调整顺序，但不会修改注册中心的原始卡片定义。
-- 最小化栏仅提供启用、暂停和可见性快捷操作，不允许新增、删除或拖放卡片。
local ui = Cat2.UI
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
local function CountTextCharacters(text)
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

local function GetExclusiveGroupColor(groupName)
    AssignExclusiveGroupColor(groupName)
    local colorIndex = exclusiveGroupColorIndexes[groupName]
    if not colorIndex then
        return nil
    end
    return exclusiveGroupColors[colorIndex]
end

-- 主窗口、左右面板、滚动区域和滚动条引用。
local mainWindow = nil
local shortcutWindow = nil
local flowPanel = nil
local availablePanel = nil
local centerGap = nil
local footerActions = nil
local profileActions = nil
local flowScroll = nil
local availableScroll = nil
local flowContent = nil
local availableContent = nil
local flowSlider = nil
local availableSlider = nil
-- 最小化快捷栏：columns 预留给后续设置面板，rows 每次依当前流程数量自动计算。
local minimizedShortcutBlocks = {}
local minimizedFlowLayout = {
    columns = 1,
    rows = 0,
    direction = "horizontal",
    -- 最小化快捷栏整体比例；默认接近主界面卡片图标尺寸，后续设置界面可修改。
    scale = 0.8
}
Cat2.UI.MinimizedFlowLayout = minimizedFlowLayout
-- 拖放辅助视觉：插入位置提示线、空流程提示和数量文本。
local dropIndicator = nil
local emptyHint = nil
local flowCountText = nil
-- 插件文件执行时角色 SavedVariables 尚未加载，因此先建立安全的默认仓库。
-- 真正的数据恢复会延迟到 PLAYER_LOGIN 之后的首次界面打开或流程执行。
local runtimeConfigurations = {
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
Cat2.RuntimeConfigurations = runtimeConfigurations
-- selectedSteps 始终指向当前配置的 steps；切换配置只需更换此引用。
local selectedSteps = runtimeConfigurations.profiles[runtimeConfigurations.activeProfileId].steps
local selectedFlowIndex = nil
-- 每次重绘生成的左右卡片框体引用，用于隐藏旧框体。
local leftBlocks = {}
local availableBlocks = {}
local dragGhost = nil
-- 流程最大容量；达到限制时显示通用提示弹窗。
local maximumFlowSteps = 60
-- 右侧标签页为互斥单选；默认显示全部卡片。
local selectedFilter = "all"
local filterTabs = {}

-- 右侧经过职业筛选后的可用卡片缓存。
local availableSteps = {}

local RedrawFlow = nil
local RedrawAvailable = nil

-- 必须在 SavedVariables 加载完成后调用；重复调用不会覆盖当前会话中的修改。
function Cat2.EnsureConfigurationDataLoaded()
    if configurationDataLoaded then
        return
    end
    runtimeConfigurations = Cat2.LoadConfigurationData()
    Cat2.RuntimeConfigurations = runtimeConfigurations
    selectedSteps = runtimeConfigurations.profiles[runtimeConfigurations.activeProfileId].steps
    minimizedFlowLayout.columns, minimizedFlowLayout.direction = Cat2.GetMinimizedLayout()
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

local function SaveRuntimeConfigurations()
    Cat2.SaveConfigurationData(runtimeConfigurations)
end

-- 由右侧定义卡片创建左侧流程实例，并复制后续执行所需字段。
local function CreateFlowStep(step)
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
        Apply = step.Apply,
        Validate = step.Validate,
        RefreshRuntimeData = step.RefreshRuntimeData,
        Execute = step.Execute,
        enabled = 1,
        -- 新加入流程的卡片默认显示在快捷小窗；之后仍可由用户单独隐藏。
        minimizedVisible = 1
    }
end

-- 根据当前鼠标位置计算拖放时应插入流程的序号。
local function GetFlowInsertIndex()
    local scale = UIParent:GetScale()
    local x, y = GetCursorPosition()
    x = x / scale
    y = y / scale

    local relativeY = flowContent:GetTop() - y
    local index = math.floor(relativeY / 50) + 1
    local total = table.getn(selectedSteps)

    if index < 1 then
        index = 1
    end
    if index > total + 1 then
        index = total + 1
    end
    return index
end

-- 拖动卡片时更新左侧流程中的金色插入提示线。
local function UpdateDropIndicator()
    if not dropIndicator then
        return
    end

    if not dragGhost or not dragGhost:IsVisible() then
        dropIndicator:Hide()
        return
    end

    if not IsCursorInside(flowScroll) then
        dropIndicator:Hide()
        return
    end

    local index = GetFlowInsertIndex()
    dropIndicator:ClearAllPoints()
    dropIndicator:SetPoint("TOPLEFT", flowContent, "TOPLEFT", 0, -1 - (index - 1) * 50)
    dropIndicator:Show()
end

-- 将拖动跟随卡片定位到鼠标，并同步刷新插入提示。
local function UpdateDragGhost()
    if not dragGhost or not dragGhost:IsVisible() then
        return
    end

    local scale = UIParent:GetScale()
    local x, y = GetCursorPosition()
    x = x / scale
    y = y / scale
    dragGhost:ClearAllPoints()
    dragGhost:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    UpdateDropIndicator()
end

-- 创建拖动时显示在鼠标旁的卡片预览；只创建一次。
local function CreateDragGhost()
    dragGhost = CreateFrame("Frame", nil, UIParent)
    dragGhost:SetWidth(330)
    dragGhost:SetHeight(44)
    dragGhost:SetFrameStrata("TOOLTIP")
    dragGhost:SetFrameLevel(20)
    dragGhost:EnableMouse(false)
    ApplyFlatBackdrop(dragGhost, 0.08, 0.12, 0.18, 0.96)

    local icon = dragGhost:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(30)
    icon:SetHeight(30)
    icon:SetPoint("LEFT", dragGhost, "LEFT", 8, 0)
    dragGhost.icon = icon

    local name = dragGhost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, 0)
    name:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    name:SetTextColor(1, 0.82, 0.2)
    dragGhost.name = name

    local description = dragGhost:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    description:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 8, 0)
    description:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    description:SetTextColor(0.82, 0.82, 0.82)
    dragGhost.description = description
    dragGhost:Hide()
end

-- 创建单张可见卡片；流程卡附带选中、暂停、删除与排序交互。
local function CreateStepBlock(parent, step, index, fromFlow)
    local block = CreateFrame("Button", nil, parent)
    block:SetWidth(316)
    block:SetHeight(44)
    ApplyFlatBackdrop(block, 0.1, 0.12, 0.16, 0.95)
    block:EnableMouse(true)
    block:RegisterForDrag("LeftButton", "RightButton")
    block.step = step
    block.index = index
    block.fromFlow = fromFlow

    -- 归组卡片在右侧内边缘显示同色短竖条，不占用标题空间，也不改变卡片原有底色。
    local groupColor = GetExclusiveGroupColor(step.exclusiveGroup)
    if groupColor then
        local groupMarker = block:CreateTexture(nil, "OVERLAY")
        groupMarker:SetTexture("Interface\\Buttons\\WHITE8X8")
        groupMarker:SetWidth(5)
        groupMarker:SetPoint("TOPRIGHT", block, "TOPRIGHT", -1, -1)
        groupMarker:SetPoint("BOTTOMRIGHT", block, "BOTTOMRIGHT", -1, 1)
        groupMarker:SetVertexColor(groupColor[1], groupColor[2], groupColor[3], 1)
        if fromFlow and step.enabled == 0 then
            groupMarker:SetAlpha(0.58)
        else
            groupMarker:SetAlpha(0.92)
        end
        block.groupMarker = groupMarker
    end

    -- icons 第一项是主图标，其余两项是可选辅助图标。
    local iconPaths = step.icons
    local cardIcons = {}
    local iconIndex = 1
    local iconTotal = table.getn(iconPaths)
    local lastIcon = nil
    if step.id == "common_blank_placeholder" then
        -- 卡片栏保留标准图标框与文字缩进，但框内不绘制任何图标纹理。
        local emptyIconFrame = CreateFrame("Frame", nil, block)
        emptyIconFrame:SetWidth(30)
        emptyIconFrame:SetHeight(30)
        emptyIconFrame:SetPoint("LEFT", block, "LEFT", 8, 0)
        ApplyFlatBackdrop(emptyIconFrame, 0.045, 0.055, 0.075, 0.9)
        emptyIconFrame:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.72)
        lastIcon = emptyIconFrame
    else
        while iconIndex <= iconTotal do
            local cardIcon = block:CreateTexture(nil, "ARTWORK")
            cardIcon:SetTexture(iconPaths[iconIndex])
            cardIcon:SetWidth(30)
            cardIcon:SetHeight(30)
            cardIcon:SetPoint("LEFT", block, "LEFT", 8 + (iconIndex - 1) * 33, 0)
            table.insert(cardIcons, cardIcon)
            lastIcon = cardIcon
            iconIndex = iconIndex + 1
        end
    end

    local name = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", lastIcon, "TOPRIGHT", 8, 0)
    name:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    name:SetTextColor(1, 0.82, 0.2)
    name:SetText(step.name)

    -- 被动标识紧跟卡片标题；快捷小窗不显示文字，仅使用紫色边框。
    local passiveLabel = nil
    if step.behavior == "passive" then
        passiveLabel = block:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        passiveLabel:SetPoint("LEFT", name, "RIGHT", 7, 0)
        passiveLabel:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
        passiveLabel:SetTextColor(0.72, 0.5, 0.94)
        passiveLabel:SetText(Cat2.L("被动"))
        -- 被动卡使用轻微偏紫的边框与淡紫底色，不脱离整体蓝灰主题。
        block:SetBackdropColor(0.145, 0.115, 0.195, 0.95)
        block:SetBackdropBorderColor(0.38, 0.35, 0.56, 0.9)
    end

    local description = block:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    description:SetPoint("BOTTOMLEFT", lastIcon, "BOTTOMRIGHT", 8, 0)
    description:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    description:SetTextColor(0.82, 0.82, 0.82)
    description:SetText(step.description)

    block.normalAlpha = 1
    if fromFlow and step.enabled == 0 then
        block.normalAlpha = 0.45
        name:SetTextColor(0.58, 0.58, 0.58)
        description:SetTextColor(0.5, 0.5, 0.5)
        if passiveLabel then
            passiveLabel:SetTextColor(0.46, 0.36, 0.56)
        end
        local disabledIconIndex = 1
        local disabledIconTotal = table.getn(cardIcons)
        while disabledIconIndex <= disabledIconTotal do
            cardIcons[disabledIconIndex]:SetAlpha(0.5)
            disabledIconIndex = disabledIconIndex + 1
        end
        block:SetAlpha(block.normalAlpha)
    end

    if fromFlow and step.isMissing then
        -- 缺失卡片使用低饱和暗红色，但仍保持 ID 可读，便于定位注册或 TOC 问题。
        ApplyFlatBackdrop(block, 0.22, 0.07, 0.08, 0.82)
        -- 整体亮度与普通暂停卡片一致，只通过暗红色调区分缺失状态。
        block.normalAlpha = 0.45
        block:SetAlpha(block.normalAlpha)
        name:SetTextColor(0.82, 0.52, 0.52)
        description:SetTextColor(0.72, 0.56, 0.56)
        local missingIconIndex = 1
        local missingIconTotal = table.getn(cardIcons)
        while missingIconIndex <= missingIconTotal do
            cardIcons[missingIconIndex]:SetAlpha(0.5)
            missingIconIndex = missingIconIndex + 1
        end
    end

    if fromFlow then
        local visibilityButton = CreateFrame("Button", nil, block)
        visibilityButton:SetWidth(24)
        visibilityButton:SetHeight(24)
        visibilityButton:SetPoint("RIGHT", block, "RIGHT", -74, 0)
        ApplyFlatBackdrop(visibilityButton, 0.08, 0.16, 0.24, 0.98)

        -- O 表示显示在最小化栏，— 表示从最小化栏隐藏。
        local visibilityText = visibilityButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        -- 字体的 O 基线视觉上偏高，向下修正以对齐相邻按钮。
        visibilityText:SetPoint("CENTER", visibilityButton, "CENTER", 0, -1)
        visibilityText:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")

        local function RefreshVisibilityAppearance()
            visibilityButton:SetBackdropColor(0.08, 0.16, 0.24, 0.98)
            visibilityButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            if block.step.minimizedVisible == 0 then
                visibilityText:SetText("—")
                visibilityText:SetTextColor(0.52, 0.56, 0.62)
            else
                visibilityText:SetText("O")
                visibilityText:SetTextColor(0.62, 0.82, 1)
            end
        end
        RefreshVisibilityAppearance()

        -- 非选中状态只用低对比度文字提示隐藏，不占用操作按钮样式。
        local hiddenStatusText = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        hiddenStatusText:SetPoint("RIGHT", block, "RIGHT", -12, 0)
        hiddenStatusText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        hiddenStatusText:SetTextColor(0.48, 0.54, 0.62)
        hiddenStatusText:SetText(Cat2.L("隐"))
        hiddenStatusText:Hide()

        visibilityButton:SetScript("OnEnter", function()
            visibilityButton:SetBackdropColor(0.12, 0.3, 0.42, 1)
            GameTooltip:SetOwner(visibilityButton, "ANCHOR_RIGHT")
            if block.step.minimizedVisible == 0 then
                GameTooltip:SetText(Cat2.L("显示在流程快捷小窗"))
            else
                GameTooltip:SetText(Cat2.L("从流程快捷小窗隐藏"))
            end
        end)
        visibilityButton:SetScript("OnLeave", function()
            RefreshVisibilityAppearance()
            GameTooltip:Hide()
        end)
        visibilityButton:SetScript("OnMouseDown", function()
            visibilityButton:SetBackdropColor(0.04, 0.1, 0.16, 1)
        end)
        visibilityButton:SetScript("OnMouseUp", function()
            RefreshVisibilityAppearance()
        end)
        visibilityButton:SetScript("OnClick", function()
            if block.step.isMissing then
                return
            end
            if block.step.minimizedVisible == 0 then
                block.step.minimizedVisible = 1
            else
                block.step.minimizedVisible = 0
            end
            selectedFlowIndex = block.index
            RedrawFlow()
        end)

        local pauseButton = CreateFrame("Button", nil, block)
        pauseButton:SetWidth(24)
        pauseButton:SetHeight(24)
        pauseButton:SetPoint("RIGHT", block, "RIGHT", -44, 0)
        ApplyFlatBackdrop(pauseButton, 0.1, 0.18, 0.28, 0.98)

        -- 旧客户端会压缩连续的 || 字距，因此拆成两个独立字符以稳定显示暂停符号。
        local pauseLeftText = pauseButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        pauseLeftText:SetPoint("CENTER", pauseButton, "CENTER", -3, 0)
        pauseLeftText:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
        pauseLeftText:SetTextColor(0.55, 0.8, 1)
        pauseLeftText:SetText("|")

        local pauseRightText = pauseButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        pauseRightText:SetPoint("CENTER", pauseButton, "CENTER", 3, 0)
        pauseRightText:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
        pauseRightText:SetTextColor(0.55, 0.8, 1)
        pauseRightText:SetText("|")

        local resumeText = pauseButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        -- > 字形视觉重心偏低，向上微调一像素。
        resumeText:SetPoint("CENTER", pauseButton, "CENTER", 1, 1)
        resumeText:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
        if step.enabled == 0 then
            pauseLeftText:Hide()
            pauseRightText:Hide()
            resumeText:SetTextColor(0.45, 0.85, 0.5)
            resumeText:SetText(">")
        else
            resumeText:Hide()
        end

        pauseButton:SetScript("OnClick", function()
            if block.step.isMissing then
                return
            end
            if block.step.enabled == 0 then
                Cat2.SetFlowStepEnabled(selectedSteps, block.step, 1)
            else
                Cat2.SetFlowStepEnabled(selectedSteps, block.step, 0)
            end
            selectedFlowIndex = block.index
            RedrawFlow()
        end)
        pauseButton:SetScript("OnEnter", function()
            pauseButton:SetBackdropColor(0.14, 0.28, 0.42, 1)
            GameTooltip:SetOwner(pauseButton, "ANCHOR_RIGHT")
            if block.step.enabled == 0 then
                GameTooltip:SetText(Cat2.L("恢复此流程步骤"))
            else
                GameTooltip:SetText(Cat2.L("暂停此流程步骤"))
            end
        end)
        pauseButton:SetScript("OnLeave", function()
            pauseButton:SetBackdropColor(0.1, 0.18, 0.28, 0.98)
            GameTooltip:Hide()
        end)

        local deleteButton = CreateFrame("Button", nil, block)
        deleteButton:SetWidth(24)
        deleteButton:SetHeight(24)
        deleteButton:SetPoint("RIGHT", block, "RIGHT", -14, 0)
        ApplyFlatBackdrop(deleteButton, 0.35, 0.08, 0.08, 0.98)

        local deleteText = deleteButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        deleteText:SetPoint("CENTER", deleteButton, "CENTER", 0, 0)
        deleteText:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
        deleteText:SetTextColor(1, 0.4, 0.4)
        deleteText:SetText("X")

        deleteButton:SetScript("OnEnter", function()
            deleteButton:SetBackdropColor(0.58, 0.1, 0.1, 1)
            GameTooltip:SetOwner(deleteButton, "ANCHOR_RIGHT")
            GameTooltip:SetText(Cat2.L("从当前流程删除此卡片"))
        end)
        deleteButton:SetScript("OnLeave", function()
            deleteButton:SetBackdropColor(0.35, 0.08, 0.08, 0.98)
            GameTooltip:Hide()
        end)
        deleteButton:SetScript("OnClick", function()
            table.remove(selectedSteps, block.index)
            selectedFlowIndex = nil
            RedrawFlow()
        end)

        if block.index == selectedFlowIndex then
            hiddenStatusText:Hide()
            if block.step.isMissing then
                visibilityButton:Hide()
                pauseButton:Hide()
            else
                visibilityButton:Show()
                pauseButton:Show()
            end
            deleteButton:Show()
        else
            visibilityButton:Hide()
            if not block.step.isMissing and block.step.minimizedVisible == 0 then
                hiddenStatusText:Show()
            else
                hiddenStatusText:Hide()
            end
            pauseButton:Hide()
            deleteButton:Hide()
        end

        block:SetScript("OnClick", function()
            -- 客户端可能在拖动结束后紧接着派发一次点击；该点击不应改变选中状态。
            if block.dragEndedAt and GetTime() - block.dragEndedAt < 0.2 then
                return
            end
            if selectedFlowIndex == block.index then
                selectedFlowIndex = nil
            else
                selectedFlowIndex = block.index
            end
            RedrawFlow()
        end)
    end

    local tooltipFontState = nil
    local function RestoreCardTooltipFont()
        if not tooltipFontState then
            return
        end
        if tooltipFontState.titleLine and tooltipFontState.titleFontPath and tooltipFontState.titleFontSize then
            tooltipFontState.titleLine:SetFont(
                tooltipFontState.titleFontPath,
                tooltipFontState.titleFontSize,
                tooltipFontState.titleFontFlags
            )
        end
        if tooltipFontState.detailLine and tooltipFontState.detailFontPath and tooltipFontState.detailFontSize then
            tooltipFontState.detailLine:SetFont(
                tooltipFontState.detailFontPath,
                tooltipFontState.detailFontSize,
                tooltipFontState.detailFontFlags
            )
        end
        tooltipFontState = nil
    end

    block:SetScript("OnDragStart", function()
        RestoreCardTooltipFont()
        GameTooltip:Hide()
        block:SetAlpha(0.25)
        dragGhost.icon:SetTexture(Cat2.GetCardPrimaryIcon(block.step))
        dragGhost.name:SetText(block.step.name)
        dragGhost.description:SetText(block.step.description)
        dragGhost:Show()
        UpdateDragGhost()
    end)
    block:SetScript("OnDragStop", function()
        block.dragEndedAt = GetTime()
        block:SetAlpha(block.normalAlpha)
        dragGhost:Hide()
        dropIndicator:Hide()
        if not IsCursorInside(flowScroll) then
            return
        end

        local insertIndex = GetFlowInsertIndex()
        if block.fromFlow then
            -- 记住原先选中的卡片对象；重排后重新定位它，避免拖动自动选中当前卡片。
            local selectedStep = nil
            if selectedFlowIndex then
                selectedStep = selectedSteps[selectedFlowIndex]
            end
            table.remove(selectedSteps, block.index)
            if insertIndex > block.index then
                insertIndex = insertIndex - 1
            end
            table.insert(selectedSteps, insertIndex, block.step)
            selectedFlowIndex = nil
            if selectedStep then
                local selectedIndex = 1
                local selectedTotal = table.getn(selectedSteps)
                while selectedIndex <= selectedTotal do
                    if selectedSteps[selectedIndex] == selectedStep then
                        selectedFlowIndex = selectedIndex
                        break
                    end
                    selectedIndex = selectedIndex + 1
                end
            end
        else
            if not Cat2.CanAddCardForPlayer(block.step) then
                ShowNotice(Cat2.L("当前正在预览其他职业。\n只有角色本职业可用的共享卡片能够加入流程。"))
                return
            end
            if table.getn(selectedSteps) >= maximumFlowSteps then
                ShowNotice(Cat2.L("流程卡片已经装满，最多可放置 ") .. maximumFlowSteps .. Cat2.L(" 张卡片。"))
                return
            end
            if block.step.unique then
                local existingIndex = 1
                local existingTotal = table.getn(selectedSteps)
                while existingIndex <= existingTotal do
                    if selectedSteps[existingIndex].id == block.step.id then
                        ShowNotice(Cat2.L("被动卡片「") .. block.step.name .. Cat2.L("」在同一配置中只能放置一张。"))
                        return
                    end
                    existingIndex = existingIndex + 1
                end
            end
            local newStep = CreateFlowStep(block.step)
            table.insert(selectedSteps, insertIndex, newStep)
            Cat2.SetFlowStepEnabled(selectedSteps, newStep, 1)
        end
        RedrawFlow()
    end)
    block:SetScript("OnEnter", function()
        if block.step.isMissing then
            -- 缺失卡片悬停时只提高暗红色亮度，不切回普通卡片的蓝灰色。
            block:SetBackdropColor(0.3, 0.1, 0.11, 0.9)
        else
            if block.step.behavior == "passive" then
                block:SetBackdropColor(0.215, 0.17, 0.275, 0.98)
                block:SetBackdropBorderColor(0.48, 0.41, 0.65, 0.95)
            else
                block:SetBackdropColor(0.16, 0.2, 0.27, 0.98)
                block:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            end
        end

        -- 仅右侧可用卡片槽展示详情；左侧流程槽以排序和操作为主，避免 Tooltip 干扰。
        local details = block.step.details
        if not block.fromFlow and details and details ~= "" then
            GameTooltip:SetOwner(block, "ANCHOR_LEFT")
            GameTooltip:ClearLines()

            -- 标题与正文由 name、details 组合；同时兼容旧配置中带有“卡名：”前缀的详情。
            local detailText = details
            local detailPrefix = block.step.name .. "："
            if string.sub(detailText, 1, string.len(detailPrefix)) == detailPrefix then
                detailText = string.sub(detailText, string.len(detailPrefix) + 1)
            end
            GameTooltip:AddLine(block.step.name, 1, 0.66, 0.16, false)
            GameTooltip:AddLine(detailText, 0.92, 0.94, 1, true)

            -- 显示前调整字号，让 Tooltip 按最终字体重新计算高度，避免底部出现多余留白。
            local titleLine = getglobal("GameTooltipTextLeft1")
            local detailLine = getglobal("GameTooltipTextLeft2")
            local titleFontPath = nil
            local titleFontSize = nil
            local titleFontFlags = nil
            local detailFontPath = nil
            local detailFontSize = nil
            local detailFontFlags = nil
            if titleLine then
                titleFontPath, titleFontSize, titleFontFlags = titleLine:GetFont()
            end
            if detailLine then
                detailFontPath, detailFontSize, detailFontFlags = detailLine:GetFont()
            end
            tooltipFontState = {
                titleLine = titleLine,
                titleFontPath = titleFontPath,
                titleFontSize = titleFontSize,
                titleFontFlags = titleFontFlags,
                detailLine = detailLine,
                detailFontPath = detailFontPath,
                detailFontSize = detailFontSize,
                detailFontFlags = detailFontFlags,
            }
            local function AdjustTooltipLineFont(line, sizeOffset)
                if not line then
                    return
                end
                local fontPath, fontSize, fontFlags = line:GetFont()
                if fontPath and fontSize then
                    line:SetFont(fontPath, math.max(8, fontSize + sizeOffset), fontFlags)
                end
            end
            AdjustTooltipLineFont(titleLine, -1)
            AdjustTooltipLineFont(detailLine, 1)
            GameTooltip:Show()
        end
    end)
    block:SetScript("OnLeave", function()
        RestoreCardTooltipFont()
        GameTooltip:Hide()
        if block.step.isMissing then
            block:SetBackdropColor(0.22, 0.07, 0.08, 0.82)
        else
            if block.step.behavior == "passive" then
                block:SetBackdropColor(0.145, 0.115, 0.195, 0.95)
                block:SetBackdropBorderColor(0.38, 0.35, 0.56, 0.9)
            else
                block:SetBackdropColor(0.1, 0.12, 0.16, 0.95)
                block:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            end
        end
    end)

    return block
end

-- 依据 selectedSteps 重建左侧流程卡片，并刷新数量和滚动范围。
RedrawFlow = function()
    -- 独立快捷窗可在主编辑器创建前被点击；此时没有左侧列表控件可重绘。
    if not mainWindow or not flowContent or not flowScroll then
        return
    end
    local oldIndex = 1
    local oldTotal = table.getn(leftBlocks)
    while oldIndex <= oldTotal do
        leftBlocks[oldIndex]:Hide()
        oldIndex = oldIndex + 1
    end
    leftBlocks = {}

    local total = table.getn(selectedSteps)
    flowCountText:SetText("(" .. total .. " / " .. maximumFlowSteps .. ")")
    if total == 0 then
        emptyHint:Show()
    else
        emptyHint:Hide()
    end

    local index = 1
    while index <= total do
        local block = CreateStepBlock(flowContent, selectedSteps[index], index, true)
        block:SetPoint("TOPLEFT", flowContent, "TOPLEFT", 0, -2 - (index - 1) * 50)
        leftBlocks[index] = block
        index = index + 1
    end

    local contentHeight = total * 50 + 4
    if contentHeight < 392 then
        contentHeight = 392
    end
    flowContent:SetHeight(contentHeight)
    UpdateScrollBar(flowScroll, flowSlider, contentHeight)

    if Cat2.UI.RedrawMinimizedShortcuts then
        Cat2.UI.RedrawMinimizedShortcuts()
    end
    SaveRuntimeConfigurations()
end

-- 根据当前单选标签页重建右侧卡片列表，并刷新滚动范围。
RedrawAvailable = function()
    -- 主界面尚未创建时只保留数据状态，不能访问右侧列表控件。
    if not mainWindow or not availableContent or not availableScroll then
        return
    end
    local oldIndex = 1
    local oldTotal = table.getn(availableBlocks)
    while oldIndex <= oldTotal do
        availableBlocks[oldIndex]:Hide()
        oldIndex = oldIndex + 1
    end
    availableBlocks = {}

    local sourceIndex = 1
    local sourceTotal = table.getn(availableSteps)
    local displayOrder = {}
    while sourceIndex <= sourceTotal do
        -- 注册表更新或预览职业切换期间可能留下空位；排序前过滤，避免比较函数访问空卡片。
        if availableSteps[sourceIndex] then
            table.insert(displayOrder, sourceIndex)
        end
        sourceIndex = sourceIndex + 1
    end

    -- “全部”分页按功能大类分段，段内仍保留卡片定义的 sort 顺序。
    if selectedFilter == "all" then
        table.sort(displayOrder, function(leftIndex, rightIndex)
            local left = availableSteps[leftIndex]
            local right = availableSteps[rightIndex]
            if not left and not right then
                return false
            end
            if not left then
                return false
            end
            if not right then
                return true
            end
            local leftRank = 7
            local rightRank = 7
            if left.category == "common" then
                leftRank = 1
            elseif left.category == "item" then
                leftRank = 2
            elseif Cat2.GetCardSpecializationForClass(left, Cat2.PlayerClassFile) == 1 then
                leftRank = 3
            elseif Cat2.GetCardSpecializationForClass(left, Cat2.PlayerClassFile) == 2 then
                leftRank = 4
            elseif Cat2.GetCardSpecializationForClass(left, Cat2.PlayerClassFile) == 3 then
                leftRank = 5
            elseif Cat2.GetCardSpecializationForClass(left, Cat2.PlayerClassFile) == 4 then
                leftRank = 6
            end
            if right.category == "common" then
                rightRank = 1
            elseif right.category == "item" then
                rightRank = 2
            elseif Cat2.GetCardSpecializationForClass(right, Cat2.PlayerClassFile) == 1 then
                rightRank = 3
            elseif Cat2.GetCardSpecializationForClass(right, Cat2.PlayerClassFile) == 2 then
                rightRank = 4
            elseif Cat2.GetCardSpecializationForClass(right, Cat2.PlayerClassFile) == 3 then
                rightRank = 5
            elseif Cat2.GetCardSpecializationForClass(right, Cat2.PlayerClassFile) == 4 then
                rightRank = 6
            end
            if leftRank ~= rightRank then
                return leftRank < rightRank
            end
            if left.sort ~= right.sort then
                return left.sort < right.sort
            end
            return left.id < right.id
        end)
    end

    local displayIndex = 1
    local orderIndex = 1
    local orderTotal = table.getn(displayOrder)
    while orderIndex <= orderTotal do
        sourceIndex = displayOrder[orderIndex]
        local step = availableSteps[sourceIndex]
        if step then
            local visible = false
            if selectedFilter == "all" then
                visible = true
            elseif selectedFilter == "common" then
                visible = step.category == "common"
            elseif selectedFilter == "item" then
                visible = step.category == "item"
            elseif selectedFilter == "spec1" then
                visible = step.category == "class" and Cat2.GetCardSpecializationForClass(step, Cat2.PlayerClassFile) == 1
            elseif selectedFilter == "spec2" then
                visible = step.category == "class" and Cat2.GetCardSpecializationForClass(step, Cat2.PlayerClassFile) == 2
            elseif selectedFilter == "spec3" then
                visible = step.category == "class" and Cat2.GetCardSpecializationForClass(step, Cat2.PlayerClassFile) == 3
            elseif selectedFilter == "spec4" then
                visible = step.category == "class" and Cat2.GetCardSpecializationForClass(step, Cat2.PlayerClassFile) == 4
            end
            if visible then
                local block = CreateStepBlock(availableContent, step, sourceIndex, false)
                block:SetPoint("TOPLEFT", availableContent, "TOPLEFT", 0, -2 - (displayIndex - 1) * 50)
                availableBlocks[displayIndex] = block
                displayIndex = displayIndex + 1
            end
        end
        orderIndex = orderIndex + 1
    end

    local contentHeight = (displayIndex - 1) * 50 + 4
    local minimumHeight = availableScroll:GetHeight()
    if contentHeight < minimumHeight then
        contentHeight = minimumHeight
    end
    availableContent:SetHeight(contentHeight)
    UpdateScrollBar(availableScroll, availableSlider, contentHeight)
end

-- 通过 UI 命名空间提供重绘入口，避免主窗口构造函数捕获过多外部变量。
-- 旧版客户端单个函数最多允许 32 个 upvalue，因此这里不能继续直接闭包引用。
ui.RedrawFlow = RedrawFlow

-- 查询同名配置，供导入流程在真正写入前决定是否需要覆盖确认。
function ui.FindConfigurationByName(profileName)
    Cat2.EnsureConfigurationDataLoaded()
    local orderIndex = 1
    local orderTotal = table.getn(runtimeConfigurations.profileOrder)
    while orderIndex <= orderTotal do
        local profileId = runtimeConfigurations.profileOrder[orderIndex]
        local profile = runtimeConfigurations.profiles[profileId]
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
        local existing = runtimeConfigurations.profiles[profileId]
        if not existing then
            return false, Cat2.L("需要覆盖的配置已经不存在")
        end
        existing.name = importedProfile.name
        existing.steps = runtimeSteps
    else
        profileId = runtimeConfigurations.nextProfileId
        runtimeConfigurations.nextProfileId = profileId + 1
        runtimeConfigurations.profiles[profileId] = {
            id = profileId,
            name = importedProfile.name,
            steps = runtimeSteps
        }
        table.insert(runtimeConfigurations.profileOrder, profileId)
    end

    runtimeConfigurations.activeProfileId = profileId
    selectedSteps = runtimeConfigurations.profiles[profileId].steps
    selectedFlowIndex = nil

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

    if mainWindow and mainWindow.UpdateProfileText then
        mainWindow.UpdateProfileText()
    end
    RedrawFlow()
    if ui.RedrawMinimizedShortcuts then
        ui.RedrawMinimizedShortcuts()
    end
    if ui.RefreshProfileManager then
        ui.RefreshProfileManager()
    end
    return true
end
ui.RedrawAvailable = RedrawAvailable

-- 供配置级快捷窗调用：切换编辑器当前配置并刷新依赖当前流程的界面。
function ui.SelectConfigurationProfile(profileId)
    Cat2.EnsureConfigurationDataLoaded()
    local profile = runtimeConfigurations.profiles[profileId]
    if not profile then
        return false
    end
    runtimeConfigurations.activeProfileId = profileId
    selectedSteps = profile.steps
    selectedFlowIndex = nil
    -- 快捷窗可在主界面尚未创建时先切换配置；此时只更新数据，
    -- 由随后 ShowMainWindow 的创建流程完成首次绘制，避免访问尚不存在的列表控件。
    if mainWindow then
        if mainWindow.UpdateProfileText then
            mainWindow.UpdateProfileText()
        end
        if RedrawFlow then
            RedrawFlow()
        end
        if RedrawAvailable then
            RedrawAvailable()
        end
    end
    SaveRuntimeConfigurations()
    return true
end

-- 按当前流程重建最小化后的图标快捷栏。
-- 图标只负责切换步骤的启用状态，不提供删除、添加或拖放等编辑能力。
Cat2.UI.RedrawMinimizedShortcuts = function()
    local shortcutPanel = Cat2.UI.MinimizedShortcutPanel
    if not shortcutPanel then
        return
    end

    local oldIndex = 1
    local oldTotal = table.getn(minimizedShortcutBlocks)
    while oldIndex <= oldTotal do
        minimizedShortcutBlocks[oldIndex]:Hide()
        oldIndex = oldIndex + 1
    end
    minimizedShortcutBlocks = {}

    local columns = minimizedFlowLayout.columns or 1
    columns = math.floor(columns)
    if columns < 1 then
        columns = 1
    end
    minimizedFlowLayout.columns = columns

    local scale = minimizedFlowLayout.scale or 1
    if scale < 0.6 then
        scale = 0.6
    end
    if scale > 1.6 then
        scale = 1.6
    end
    minimizedFlowLayout.scale = scale
    shortcutPanel:ClearAllPoints()
    shortcutPanel:SetPoint("TOP", shortcutWindow, "TOP", 0, -12)

    local sourceTotal = table.getn(selectedSteps)
    local visibleTotal = 0
    local countIndex = 1
    while countIndex <= sourceTotal do
        if selectedSteps[countIndex].minimizedVisible ~= 0 then
            visibleTotal = visibleTotal + 1
        end
        countIndex = countIndex + 1
    end
    local direction = minimizedFlowLayout.direction or "horizontal"
    local actualColumns = columns
    local rows = 1
    if direction == "vertical" then
        rows = columns
        if visibleTotal < rows then
            rows = visibleTotal
        end
        if rows < 1 then
            rows = 1
        end
        actualColumns = math.ceil(visibleTotal / columns)
        if actualColumns < 1 then
            actualColumns = 1
        end
    else
        if visibleTotal < actualColumns then
            actualColumns = visibleTotal
        end
        if actualColumns < 1 then
            actualColumns = 1
        end
        rows = math.ceil(visibleTotal / columns)
        if rows < 1 then
            rows = 1
        end
    end
    minimizedFlowLayout.rows = rows

    -- 使用单层自绘技能框，避免游戏原生贴图夹带额外的内部图案。
    local iconSize = math.floor(42 * scale)
    local iconGap = math.floor(6 * scale)
    -- 最小化托盘只服务于图标快捷操作，保留极小留白即可。
    local padding = math.floor(2 * scale)
    local panelWidth = padding * 2 + actualColumns * iconSize + (actualColumns - 1) * iconGap
    local panelHeight = padding * 2 + rows * iconSize + (rows - 1) * iconGap
    shortcutPanel:SetWidth(panelWidth)
    shortcutPanel:SetHeight(panelHeight)
    -- 快捷小窗按实际图标数量收缩；顶部保留窄拖动区，不再为不存在的图标预留空白。
    shortcutWindow:SetWidth(panelWidth + 4)
    shortcutWindow:SetHeight(panelHeight + 16)

    local sourceIndex = 1
    local displayIndex = 1
    while sourceIndex <= sourceTotal do
        local step = selectedSteps[sourceIndex]
        if step.minimizedVisible ~= 0 then
        local iconButton = CreateFrame("Button", nil, shortcutPanel)
        iconButton:SetWidth(iconSize)
        iconButton:SetHeight(iconSize)
        -- 每个图标使用独立层级，避免较靠后的图标被其他隐藏面板覆盖而收不到悬停事件。
        iconButton:SetFrameLevel(shortcutPanel:GetFrameLevel() + displayIndex + 1)
        if step.id == "common_blank_placeholder" then
            -- 空白占位仍消耗一个布局序号，但不绘制内容，也不创建鼠标交互区域。
            iconButton:EnableMouse(false)
            iconButton:Hide()
        else
        ApplyFlatBackdrop(iconButton, 0.08, 0.1, 0.14, 0.96)
        iconButton:EnableMouse(true)

        local column = 0
        local row = 0
        if direction == "vertical" then
            column = math.floor((displayIndex - 1) / columns)
            row = (displayIndex - 1) - column * columns
        else
            column = (displayIndex - 1) - math.floor((displayIndex - 1) / columns) * columns
            row = math.floor((displayIndex - 1) / columns)
        end
        iconButton:SetPoint("TOPLEFT", shortcutPanel, "TOPLEFT", padding + column * (iconSize + iconGap), -padding - row * (iconSize + iconGap))

        local icon = iconButton:CreateTexture(nil, "ARTWORK")
        -- 默认保留极窄内边距，避免图标视觉上压住外框。
        icon:SetPoint("TOPLEFT", iconButton, "TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", iconButton, "BOTTOMRIGHT", -2, 2)
        icon:SetTexture(Cat2.GetCardPrimaryIcon(step))
        -- 裁掉资源自带的边缘，统一交给快捷栏外框表现。
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        -- 独立的透明描边位于图标上层，图标填满时也不会遮住外框。
        local iconBorder = CreateFrame("Frame", nil, iconButton)
        iconBorder:SetAllPoints(iconButton)
        iconBorder:SetFrameLevel(iconButton:GetFrameLevel() + 1)
        iconBorder:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })

        local hoverHighlight = iconButton:CreateTexture(nil, "OVERLAY")
        hoverHighlight:SetAllPoints(icon)
        hoverHighlight:SetTexture("Interface\\Buttons\\WHITE8X8")
        hoverHighlight:SetVertexColor(0.78, 0.68, 0.32, 0.1)
        hoverHighlight:Hide()
        if step.enabled == 0 then
            icon:SetDesaturated(true)
            icon:SetAlpha(0.38)
            if step.behavior == "passive" then
                iconBorder:SetBackdropBorderColor(0.4, 0.26, 0.5, 0.66)
            else
                iconBorder:SetBackdropBorderColor(0.38, 0.4, 0.44, 0.58)
            end
        else
            icon:SetDesaturated(false)
            icon:SetAlpha(1)
            if step.behavior == "passive" then
                iconBorder:SetBackdropBorderColor(0.64, 0.4, 0.88, 0.95)
            else
                iconBorder:SetBackdropBorderColor(0.56, 0.59, 0.64, 0.58)
            end
        end

        local stepIndex = sourceIndex
        iconButton:SetScript("OnClick", function()
            local currentStep = selectedSteps[stepIndex]
            if not currentStep then
                return
            end
            if currentStep.enabled == 0 then
                Cat2.SetFlowStepEnabled(selectedSteps, currentStep, 1)
            else
                Cat2.SetFlowStepEnabled(selectedSteps, currentStep, 0)
            end
            selectedFlowIndex = nil
            RedrawFlow()
        end)
        iconButton:SetScript("OnEnter", function()
            if step.behavior == "passive" then
                iconBorder:SetBackdropBorderColor(0.82, 0.58, 1, 1)
            else
                iconBorder:SetBackdropBorderColor(0.78, 0.68, 0.32, 0.95)
            end
            hoverHighlight:Show()
        end)
        iconButton:SetScript("OnLeave", function()
            hoverHighlight:Hide()
            if step.enabled == 0 then
                if step.behavior == "passive" then
                    iconBorder:SetBackdropBorderColor(0.4, 0.26, 0.5, 0.66)
                else
                    iconBorder:SetBackdropBorderColor(0.38, 0.4, 0.44, 0.58)
                end
            else
                if step.behavior == "passive" then
                    iconBorder:SetBackdropBorderColor(0.64, 0.4, 0.88, 0.95)
                else
                    iconBorder:SetBackdropBorderColor(0.56, 0.59, 0.64, 0.58)
                end
            end
        end)
        end
        minimizedShortcutBlocks[displayIndex] = iconButton
        displayIndex = displayIndex + 1
        end
        sourceIndex = sourceIndex + 1
    end
end

-- 同步所有标签页的选中外观。
local function RefreshFilterTabs()
    local index = 1
    local total = table.getn(filterTabs)
    while index <= total do
        local tab = filterTabs[index]
        if tab.filterKey == selectedFilter then
            tab:SetBackdropColor(0.12, 0.36, 0.62, 1)
            tab.text:SetTextColor(1, 0.84, 0.28)
            tab.highlight:Show()
        else
            tab:SetBackdropColor(0.07, 0.08, 0.12, 1)
            tab.text:SetTextColor(0.72, 0.78, 0.88)
            tab.highlight:Hide()
        end
        index = index + 1
    end
end

-- 创建传统单选标签页；点击后切换筛选并重绘列表。
local function CreateFilterTab(parent, filterKey, labelText, offsetX, width)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(21)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", offsetX, -7)
    button.filterKey = filterKey
    ApplyFlatBackdrop(button, 0.07, 0.08, 0.12, 1)

    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER", button, "CENTER", 0, 0)
    text:SetWidth(width - 4)
    text:SetJustifyH("CENTER")
    text:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    text:SetText(labelText)
    button.text = text

    -- 选中标签顶部的亮线，沿用传统页签的视觉提示。
    local highlight = button:CreateTexture(nil, "OVERLAY")
    highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
    highlight:SetHeight(2)
    highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
    highlight:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, -1)
    highlight:SetVertexColor(0.42, 0.78, 1, 1)
    highlight:Hide()
    button.highlight = highlight

    button:SetScript("OnEnter", function()
        if selectedFilter ~= filterKey then
            button:SetBackdropColor(0.1, 0.17, 0.25, 1)
            text:SetTextColor(0.86, 0.9, 0.96)
        end
    end)
    button:SetScript("OnLeave", function()
        RefreshFilterTabs()
    end)

    button:SetScript("OnClick", function()
        selectedFilter = filterKey
        RefreshFilterTabs()
        RedrawAvailable()
    end)
    table.insert(filterTabs, button)
end

-- 萨满拥有额外的“图腾”分类；其他职业仍沿用原来的三个职业标签宽度。
function ui.LayoutFilterTabs(classFile)
    local specializationNames = Cat2.ClassSpecializations[classFile]
    local hasFourthGroup = specializationNames and specializationNames[4] ~= nil
    local tabIndex = 1
    local tabTotal = table.getn(filterTabs)
    while tabIndex <= tabTotal do
        local tab = filterTabs[tabIndex]
        local offsetX = 8
        local width = 40
        if hasFourthGroup then
            if tab.filterKey == "common" then
                offsetX = 48
                width = 38
            elseif tab.filterKey == "item" then
                offsetX = 88
                width = 38
            elseif tab.filterKey == "spec1" then
                offsetX = 128
                width = 55
            elseif tab.filterKey == "spec2" then
                offsetX = 185
                width = 55
            elseif tab.filterKey == "spec3" then
                offsetX = 242
                width = 55
            elseif tab.filterKey == "spec4" then
                offsetX = 299
                width = 55
            else
                width = 38
            end
        else
            if tab.filterKey == "common" then
                offsetX = 50
            elseif tab.filterKey == "item" then
                offsetX = 92
            elseif tab.filterKey == "spec1" then
                offsetX = 134
                width = 66
            elseif tab.filterKey == "spec2" then
                offsetX = 202
                width = 72
            elseif tab.filterKey == "spec3" then
                offsetX = 276
                width = 72
            end
        end
        tab:ClearAllPoints()
        tab:SetPoint("TOPLEFT", availablePanel, "TOPLEFT", offsetX, -7)
        tab:SetWidth(width)
        tab.text:SetWidth(width - 4)
        if tab.filterKey == "spec4" and not hasFourthGroup then
            tab:Hide()
        else
            tab:Show()
        end
        tabIndex = tabIndex + 1
    end
    if selectedFilter == "spec4" and not hasFourthGroup then
        selectedFilter = "all"
    end
end

-- 隐藏职业预览开关只改变右侧卡片库；流程槽门禁仍读取角色真实职业。
function ui.SetCardPreviewClass(classFile)
    if not Cat2.ClassSpecializations[classFile] then
        return false
    end
    Cat2.PlayerClassFile = classFile
    availableSteps = Cat2.GetCardsForClass(classFile)

    local specializationNames = Cat2.ClassSpecializations[classFile]
    local tabIndex = 1
    local tabTotal = table.getn(filterTabs)
    while tabIndex <= tabTotal do
        local tab = filterTabs[tabIndex]
        if tab.filterKey == "spec1" then
            tab.text:SetText(Cat2.L(specializationNames[1]))
        elseif tab.filterKey == "spec2" then
            tab.text:SetText(Cat2.L(specializationNames[2]))
        elseif tab.filterKey == "spec3" then
            tab.text:SetText(Cat2.L(specializationNames[3]))
        elseif tab.filterKey == "spec4" and specializationNames[4] then
            tab.text:SetText(Cat2.L(specializationNames[4]))
        end
        tabIndex = tabIndex + 1
    end
    ui.LayoutFilterTabs(classFile)
    RefreshFilterTabs()

    if mainWindow and mainWindow.RefreshClassPreviewDropdown then
        mainWindow.RefreshClassPreviewDropdown()
    end

    if availableScroll then
        availableScroll:SetVerticalScroll(0)
    end
    if availableSlider then
        availableSlider:SetValue(0)
    end
    RedrawAvailable()
    return true
end

-- 顶部职业预览菜单的数据只服务于界面，不写入角色配置。
Cat2.CardPreviewClassOrder = {
    "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST",
    "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"
}
Cat2.CardPreviewClassNames = {
    DRUID = "Druid", HUNTER = "Hunter", MAGE = "Mage",
    PALADIN = "Paladin", PRIEST = "Priest", ROGUE = "Rogue",
    SHAMAN = "Shaman", WARLOCK = "Warlock", WARRIOR = "Warrior"
}
Cat2.CardPreviewClassColors = {
    DRUID = { 1, 0.49, 0.04 }, HUNTER = { 0.67, 0.83, 0.45 },
    MAGE = { 0.41, 0.8, 0.94 }, PALADIN = { 0.96, 0.55, 0.73 },
    PRIEST = { 1, 1, 1 }, ROGUE = { 1, 0.96, 0.41 },
    SHAMAN = { 0, 0.44, 0.87 }, WARLOCK = { 0.58, 0.51, 0.79 },
    WARRIOR = { 0.78, 0.61, 0.43 }
}

-- 创建顶部职业下拉菜单；选择仅改变卡片库预览，不改变真实职业门禁。
function ui.CreateClassPreviewDropdown(parent)
    local selector = CreateFrame("Button", nil, parent)
    selector:SetWidth(96)
    selector:SetHeight(24)
    selector:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -42, -12)
    selector:SetFrameLevel(parent:GetFrameLevel() + 20)
    ApplyFlatBackdrop(selector, 0.07, 0.12, 0.18, 0.98)

    local selectedText = selector:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    selectedText:SetPoint("LEFT", selector, "LEFT", 8, 0)
    selectedText:SetWidth(68)
    selectedText:SetJustifyH("LEFT")
    selectedText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    selectedText:SetTextColor(0.72, 0.84, 0.94)

    local arrowText = selector:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arrowText:SetPoint("RIGHT", selector, "RIGHT", -7, 1)
    arrowText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    arrowText:SetTextColor(0.5, 0.8, 1)
    arrowText:SetText("▼")

    local menu = CreateFrame("Frame", nil, parent)
    menu:SetWidth(96)
    menu:SetHeight(238)
    menu:SetPoint("TOPRIGHT", selector, "BOTTOMRIGHT", 0, -3)
    menu:SetFrameLevel(parent:GetFrameLevel() + 50)
    ApplyFlatBackdrop(menu, 0.035, 0.055, 0.09, 1)
    menu:Hide()
    parent.classPreviewMenu = menu

    local entries = {}
    local classIndex = 1
    local classTotal = table.getn(Cat2.CardPreviewClassOrder)
    while classIndex <= classTotal do
        local classFile = Cat2.CardPreviewClassOrder[classIndex]
        local entry = CreateFrame("Button", nil, menu)
        entry:SetWidth(90)
        entry:SetHeight(24)
        entry:SetPoint("TOPLEFT", menu, "TOPLEFT", 3, -2 - (classIndex - 1) * 26)
        entry.classFile = classFile

        -- 与配置菜单一致：条目本身不绘制按钮框，仅在悬停时显示整行底色。
        local entryHighlight = entry:CreateTexture(nil, "BACKGROUND")
        entryHighlight:SetAllPoints(entry)
        entryHighlight:SetTexture("Interface\\Buttons\\WHITE8X8")
        entryHighlight:SetVertexColor(0.12, 0.28, 0.42, 0.55)
        entryHighlight:Hide()

        local entryText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        entryText:SetPoint("LEFT", entry, "LEFT", 7, 0)
        entryText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        entryText:SetText(Cat2.CardPreviewClassNames[classFile])
        local classColor = Cat2.CardPreviewClassColors[classFile]
        entryText:SetTextColor(classColor[1], classColor[2], classColor[3])
        entry.entryText = entryText
        entry.classColor = classColor

        entry:SetScript("OnEnter", function()
            entryHighlight:Show()
        end)
        entry:SetScript("OnLeave", function()
            entryHighlight:Hide()
        end)
        entry:SetScript("OnMouseDown", function()
            entryText:ClearAllPoints()
            entryText:SetPoint("LEFT", entry, "LEFT", 8, -1)
        end)
        entry:SetScript("OnMouseUp", function()
            entryText:ClearAllPoints()
            entryText:SetPoint("LEFT", entry, "LEFT", 7, 0)
        end)
        entry:SetScript("OnClick", function()
            menu:Hide()
            ui.SetCardPreviewClass(entry.classFile)
        end)
        entries[classIndex] = entry
        classIndex = classIndex + 1
    end

    parent.RefreshClassPreviewDropdown = function()
        selectedText:SetText(Cat2.CardPreviewClassNames[Cat2.PlayerClassFile] or Cat2.L("职业"))
        local selectedColor = Cat2.CardPreviewClassColors[Cat2.PlayerClassFile]
        if selectedColor then
            selectedText:SetTextColor(selectedColor[1], selectedColor[2], selectedColor[3])
        end
        -- 非本职业预览使用与缺失卡片相近的暗红底色，避免误以为当前处于真实职业。
        if Cat2.PlayerClassFile ~= Cat2.ActualPlayerClassFile then
            selector:SetBackdropColor(0.22, 0.07, 0.08, 0.98)
            selector:SetBackdropBorderColor(0.5, 0.22, 0.24, 0.95)
        else
            selector:SetBackdropColor(0.07, 0.12, 0.18, 0.98)
            selector:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
        end
        local entryIndex = 1
        local entryTotal = table.getn(entries)
        while entryIndex <= entryTotal do
            local entry = entries[entryIndex]
            entry.entryText:SetTextColor(entry.classColor[1], entry.classColor[2], entry.classColor[3])
            entryIndex = entryIndex + 1
        end
    end

    selector:SetScript("OnEnter", function()
        if Cat2.PlayerClassFile ~= Cat2.ActualPlayerClassFile then
            selector:SetBackdropColor(0.3, 0.1, 0.11, 1)
        else
            selector:SetBackdropColor(0.1, 0.26, 0.38, 1)
        end
    end)
    selector:SetScript("OnLeave", function()
        parent.RefreshClassPreviewDropdown()
    end)
    selector:SetScript("OnMouseDown", function()
        selectedText:ClearAllPoints()
        selectedText:SetPoint("LEFT", selector, "LEFT", 9, -1)
        arrowText:ClearAllPoints()
        arrowText:SetPoint("RIGHT", selector, "RIGHT", -6, 0)
    end)
    selector:SetScript("OnMouseUp", function()
        selectedText:ClearAllPoints()
        selectedText:SetPoint("LEFT", selector, "LEFT", 8, 0)
        arrowText:ClearAllPoints()
        arrowText:SetPoint("RIGHT", selector, "RIGHT", -7, 1)
    end)
    selector:SetScript("OnClick", function()
        if menu:IsVisible() then
            menu:Hide()
        else
            parent.RefreshClassPreviewDropdown()
            menu:Show()
        end
    end)
    parent.RefreshClassPreviewDropdown()
end

function ui.SetShortcutToggleGlyphColor(red, green, blue, bodyAlpha)
    if not mainWindow or not mainWindow.shortcutToggleGlyph then
        return
    end
    local glyph = mainWindow.shortcutToggleGlyph
    glyph.top:SetVertexColor(red, green, blue, 1)
    glyph.bottom:SetVertexColor(red, green, blue, 1)
    glyph.left:SetVertexColor(red, green, blue, 1)
    glyph.right:SetVertexColor(red, green, blue, 1)
    glyph.header:SetVertexColor(red, green, blue, 0.9)
    glyph.body:SetVertexColor(red, green, blue, bodyAlpha)
end

-- 单独构造窗口图案，避免继续增加主窗口构造函数的局部变量数量。
function ui.CreateShortcutToggleGlyph(button, owner)
    local glyphFrame = CreateFrame("Frame", nil, button)
    glyphFrame:SetWidth(14)
    glyphFrame:SetHeight(11)
    glyphFrame:SetPoint("CENTER", button, "CENTER", 0, 0)
    glyphFrame:SetFrameLevel(button:GetFrameLevel() + 1)

    local body = glyphFrame:CreateTexture(nil, "BACKGROUND")
    body:SetTexture("Interface\\Buttons\\WHITE8X8")
    body:SetPoint("TOPLEFT", glyphFrame, "TOPLEFT", 1, -1)
    body:SetPoint("BOTTOMRIGHT", glyphFrame, "BOTTOMRIGHT", -1, 1)

    local top = glyphFrame:CreateTexture(nil, "ARTWORK")
    top:SetTexture("Interface\\Buttons\\WHITE8X8")
    top:SetPoint("TOPLEFT", glyphFrame, "TOPLEFT", 0, 0)
    top:SetPoint("TOPRIGHT", glyphFrame, "TOPRIGHT", 0, 0)
    top:SetHeight(1)

    local bottom = glyphFrame:CreateTexture(nil, "ARTWORK")
    bottom:SetTexture("Interface\\Buttons\\WHITE8X8")
    bottom:SetPoint("BOTTOMLEFT", glyphFrame, "BOTTOMLEFT", 0, 0)
    bottom:SetPoint("BOTTOMRIGHT", glyphFrame, "BOTTOMRIGHT", 0, 0)
    bottom:SetHeight(1)

    local left = glyphFrame:CreateTexture(nil, "ARTWORK")
    left:SetTexture("Interface\\Buttons\\WHITE8X8")
    left:SetPoint("TOPLEFT", glyphFrame, "TOPLEFT", 0, -1)
    left:SetPoint("BOTTOMLEFT", glyphFrame, "BOTTOMLEFT", 0, 1)
    left:SetWidth(1)

    local right = glyphFrame:CreateTexture(nil, "ARTWORK")
    right:SetTexture("Interface\\Buttons\\WHITE8X8")
    right:SetPoint("TOPRIGHT", glyphFrame, "TOPRIGHT", 0, -1)
    right:SetPoint("BOTTOMRIGHT", glyphFrame, "BOTTOMRIGHT", 0, 1)
    right:SetWidth(1)

    local header = glyphFrame:CreateTexture(nil, "OVERLAY")
    header:SetTexture("Interface\\Buttons\\WHITE8X8")
    header:SetPoint("TOPLEFT", glyphFrame, "TOPLEFT", 2, -3)
    header:SetPoint("TOPRIGHT", glyphFrame, "TOPRIGHT", -2, -3)
    header:SetHeight(1)

    owner.shortcutToggleGlyphFrame = glyphFrame
    owner.shortcutToggleGlyph = {
        body = body,
        top = top,
        bottom = bottom,
        left = left,
        right = right,
        header = header
    }
end

-- 空心窗口表示关闭，带淡色填充的亮蓝窗口表示开启。
local function RefreshShortcutToggleText()
    if not mainWindow or not mainWindow.shortcutToggleGlyph then
        return
    end
    -- 多配置快捷窗不能再依赖旧的单窗口引用，直接读取当前配置的持久化开关状态。
    local visible = false
    if Cat2.RuntimeConfigurations and Cat2.RuntimeConfigurations.activeProfileId and Cat2.GetProfileShortcutWindowSettings then
        visible = Cat2.GetProfileShortcutWindowSettings(Cat2.RuntimeConfigurations.activeProfileId)
    end
    mainWindow.shortcutToggleVisible = visible
    if visible then
        ui.SetShortcutToggleGlyphColor(0.38, 0.82, 1, 0.34)
    else
        ui.SetShortcutToggleGlyphColor(0.42, 0.56, 0.68, 0.08)
    end
end

-- 快捷小窗拥有独立显示状态；隐藏主界面不会再影响它。
local function SetShortcutWindowVisible(visible)
    if not shortcutWindow then
        return
    end
    if visible then
        Cat2.UI.RedrawMinimizedShortcuts()
        shortcutWindow:Show()
    else
        shortcutWindow:Hide()
    end
    Cat2.SaveMinimizedWindowVisible(visible)
    RefreshShortcutToggleText()
end

-- 创建独立的流程快捷小窗。顶部窄条用于拖动，图标区仍只响应卡片开关操作。
local function CreateShortcutWindow()
    if shortcutWindow then
        return
    end
    shortcutWindow = CreateFrame("Frame", "Cat2ShortcutWindow", UIParent)
    Cat2.UI.ShortcutWindow = shortcutWindow
    shortcutWindow:SetWidth(50)
    shortcutWindow:SetHeight(50)
    shortcutWindow:SetFrameStrata("MEDIUM")
    shortcutWindow:SetFrameLevel(40)
    shortcutWindow:SetMovable(true)
    shortcutWindow:SetClampedToScreen(true)
    shortcutWindow:EnableMouse(true)
    shortcutWindow:RegisterForDrag("LeftButton")
    ApplyFlatBackdrop(shortcutWindow, 0.04, 0.05, 0.08, 0.6)

    local savedLeft, savedTop = Cat2.GetMinimizedPosition()
    if savedLeft and savedTop then
        shortcutWindow:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", savedLeft, savedTop)
    else
        shortcutWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    shortcutWindow:SetScript("OnDragStart", function()
        shortcutWindow:StartMoving()
    end)
    shortcutWindow:SetScript("OnDragStop", function()
        shortcutWindow:StopMovingOrSizing()
        Cat2.SaveMinimizedPosition(shortcutWindow:GetLeft(), shortcutWindow:GetTop())
    end)

    local dragLine = shortcutWindow:CreateTexture(nil, "ARTWORK")
    dragLine:SetTexture("Interface\\Buttons\\WHITE8X8")
    dragLine:SetPoint("TOPLEFT", shortcutWindow, "TOPLEFT", 5, -5)
    dragLine:SetPoint("TOPRIGHT", shortcutWindow, "TOPRIGHT", -5, -5)
    dragLine:SetHeight(2)
    dragLine:SetVertexColor(0.35, 0.48, 0.62, 0.45)

    local shortcutPanel = CreateFrame("Frame", nil, shortcutWindow)
    shortcutPanel:SetWidth(46)
    shortcutPanel:SetHeight(46)
    shortcutPanel:SetFrameLevel(shortcutWindow:GetFrameLevel() + 1)
    shortcutPanel:EnableMouse(true)
    shortcutPanel:SetScript("OnMouseDown", function()
    end)
    shortcutPanel:SetScript("OnMouseUp", function()
    end)
    Cat2.UI.MinimizedShortcutPanel = shortcutPanel
    shortcutWindow:Hide()
end

-- 经 UI 命名空间调用，避免庞大的主窗口构造函数超过旧版 Lua 的 32 个 upvalue 限制。
Cat2.UI.RefreshShortcutToggleText = RefreshShortcutToggleText
Cat2.UI.SetShortcutWindowVisible = SetShortcutWindowVisible
Cat2.UI.CreateShortcutWindow = CreateShortcutWindow

-- 延迟创建主编辑窗口；窗口仅创建一次并限制在屏幕内移动。
local function CreateMainWindow()
    if mainWindow then
        return
    end

    Cat2.EnsureConfigurationDataLoaded()
    Cat2.UI.CreateShortcutWindow()

    local localizedClass, classFile = UnitClass("player")
    -- 保存在命名空间而非模块局部变量，避免旧版 Lua 的函数上值数量超过 32。
    Cat2.ActualPlayerClassFile = classFile
    Cat2.PlayerClassFile = classFile
    availableSteps = Cat2.GetCardsForClass(classFile)
    local specializationNames = Cat2.ClassSpecializations[classFile]
    if not specializationNames then
        specializationNames = { Cat2.L("第一系"), Cat2.L("第二系"), Cat2.L("第三系") }
    end

    mainWindow = CreateFrame("Frame", "Cat2MainWindow", UIParent)
    mainWindow:SetWidth(760)
    mainWindow:SetHeight(550)
    mainWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    -- 主编辑器保持在普通界面之上，但不能盖住游戏系统菜单使用的对话框层。
    mainWindow:SetFrameStrata("HIGH")
    mainWindow:SetFrameLevel(20)
    mainWindow:SetMovable(true)
    mainWindow:SetClampedToScreen(true)
    mainWindow:EnableMouse(true)
    mainWindow:RegisterForDrag("LeftButton")
    mainWindow:SetScript("OnDragStart", function()
        if mainWindow.Raise then
            mainWindow:Raise()
        end
        mainWindow:StartMoving()
    end)
    mainWindow:SetScript("OnDragStop", function()
        mainWindow:StopMovingOrSizing()
    end)
    ApplyFlatBackdrop(mainWindow, 0.04, 0.05, 0.08, 0.98)
    mainWindow:Hide()

    local titleBar = CreateFrame("Frame", nil, mainWindow)
    titleBar:SetWidth(708)
    titleBar:SetHeight(32)
    titleBar:SetPoint("TOPLEFT", mainWindow, "TOPLEFT", 12, -8)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function()
        mainWindow:StartMoving()
    end)
    titleBar:SetScript("OnDragStop", function()
        mainWindow:StopMovingOrSizing()
    end)

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", titleBar, "LEFT", 6, 0)
    title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    title:SetTextColor(1, 0.78, 0.16)
    title:SetText("Cat")

    local titleNumber = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleNumber:SetPoint("LEFT", title, "RIGHT", -2, 0)
    titleNumber:SetFont("Fonts\\FRIZQT__.TTF", 18, "THICKOUTLINE")
    titleNumber:SetTextColor(1, 0.16, 0.1)
    titleNumber:SetText("2")

    local titleTail = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleTail:SetPoint("LEFT", titleNumber, "RIGHT", 0, 0)
    titleTail:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    titleTail:SetTextColor(1, 0.78, 0.16)
    titleTail:SetText(Cat2.L(" 喵！"))

    -- 版本号使用独立的小号低对比度文字，不影响主标题的醒目配色。
    local titleVersion = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleVersion:SetPoint("LEFT", titleTail, "RIGHT", 8, -1)
    titleVersion:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    titleVersion:SetTextColor(0.5, 0.56, 0.64)
    titleVersion:SetText(Cat2.L("版本：") .. Cat2.Version)
    mainWindow.titleText = title
    mainWindow.titleNumberText = titleNumber
    mainWindow.titleTailText = titleTail
    mainWindow.titleVersionText = titleVersion

    Cat2.UI.CreateClassPreviewDropdown(mainWindow)

    local minimizeButton = CreateFrame("Button", nil, mainWindow)
    minimizeButton:SetWidth(24)
    minimizeButton:SetHeight(24)
    minimizeButton:SetPoint("TOPRIGHT", mainWindow, "TOPRIGHT", -42, -12)
    minimizeButton:SetFrameLevel(mainWindow:GetFrameLevel() + 20)
    ApplyFlatBackdrop(minimizeButton, 0.08, 0.22, 0.34, 0.98)

    -- 使用纹理绘制窗口符号，避免与配置新增、删除按钮的 + / - 混淆。
    Cat2.UI.CreateShortcutToggleGlyph(minimizeButton, mainWindow)
    Cat2.UI.RefreshShortcutToggleText()

    minimizeButton:SetScript("OnEnter", function()
        minimizeButton:SetBackdropColor(0.12, 0.4, 0.58, 1)
        minimizeButton:SetBackdropBorderColor(0.45, 0.82, 1, 1)
        Cat2.UI.SetShortcutToggleGlyphColor(1, 0.84, 0.28, 0.22)
        GameTooltip:SetOwner(minimizeButton, "ANCHOR_TOP")
        local visible = false
        if Cat2.RuntimeConfigurations and Cat2.RuntimeConfigurations.activeProfileId and Cat2.GetProfileShortcutWindowSettings then
            visible = Cat2.GetProfileShortcutWindowSettings(Cat2.RuntimeConfigurations.activeProfileId)
        end
        if visible then
            GameTooltip:SetText(Cat2.L("关闭流程快捷小窗"))
        else
            GameTooltip:SetText(Cat2.L("打开流程快捷小窗"))
        end
    end)
    minimizeButton:SetScript("OnLeave", function()
        minimizeButton:SetBackdropColor(0.08, 0.22, 0.34, 0.98)
        minimizeButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
        RefreshShortcutToggleText()
        GameTooltip:Hide()
    end)
    minimizeButton:SetScript("OnMouseDown", function()
        minimizeButton:SetBackdropColor(0.05, 0.14, 0.22, 1)
        mainWindow.shortcutToggleGlyphFrame:ClearAllPoints()
        mainWindow.shortcutToggleGlyphFrame:SetPoint("CENTER", minimizeButton, "CENTER", 1, -1)
        Cat2.UI.SetShortcutToggleGlyphColor(0.32, 0.58, 0.7, 0.2)
    end)
    minimizeButton:SetScript("OnMouseUp", function()
        minimizeButton:SetBackdropColor(0.12, 0.4, 0.58, 1)
        mainWindow.shortcutToggleGlyphFrame:ClearAllPoints()
        mainWindow.shortcutToggleGlyphFrame:SetPoint("CENTER", minimizeButton, "CENTER", 0, 0)
        Cat2.UI.SetShortcutToggleGlyphColor(1, 0.84, 0.28, 0.22)
    end)
    minimizeButton:SetScript("OnClick", function()
        local visible = false
        if Cat2.RuntimeConfigurations and Cat2.RuntimeConfigurations.activeProfileId and Cat2.GetProfileShortcutWindowSettings then
            visible = Cat2.GetProfileShortcutWindowSettings(Cat2.RuntimeConfigurations.activeProfileId)
        end
        Cat2.UI.SetShortcutWindowVisible(not visible)
    end)

    local closeButton = CreateFrame("Button", nil, mainWindow)
    closeButton:SetWidth(24)
    closeButton:SetHeight(24)
    closeButton:SetPoint("TOPRIGHT", mainWindow, "TOPRIGHT", -12, -12)
    ApplyFlatBackdrop(closeButton, 0.35, 0.08, 0.08, 0.98)

    local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeText:SetPoint("CENTER", closeButton, "CENTER", 0, 0)
    closeText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    closeText:SetTextColor(1, 0.82, 0.82)
    closeText:SetText("X")
    mainWindow.closeControl = closeButton
    mainWindow.closeControlText = closeText

    closeButton:SetScript("OnEnter", function()
        closeButton:SetBackdropColor(0.65, 0.12, 0.12, 1)
    end)
    closeButton:SetScript("OnLeave", function()
        closeButton:SetBackdropColor(0.35, 0.08, 0.08, 0.98)
    end)
    closeButton:SetScript("OnMouseDown", function()
        closeButton:SetBackdropColor(0.22, 0.04, 0.04, 1)
        closeText:ClearAllPoints()
        closeText:SetPoint("CENTER", closeButton, "CENTER", 1, -1)
    end)
    closeButton:SetScript("OnMouseUp", function()
        closeButton:SetBackdropColor(0.65, 0.12, 0.12, 1)
        closeText:ClearAllPoints()
        closeText:SetPoint("CENTER", closeButton, "CENTER", 0, 0)
    end)
    closeButton:SetScript("OnClick", function()
        CloseAllDialogs()
        if mainWindow.classPreviewMenu then
            mainWindow.classPreviewMenu:Hide()
        end
        if Cat2.UI.HideSettingsWindow then
            Cat2.UI.HideSettingsWindow()
        end
        mainWindow:Hide()
    end)

    flowPanel = CreateFrame("Frame", nil, mainWindow)
    flowPanel:SetWidth(356)
    flowPanel:SetHeight(438)
    flowPanel:SetPoint("TOPLEFT", mainWindow, "TOPLEFT", 16, -48)
    ApplyFlatBackdrop(flowPanel, 0.07, 0.08, 0.12, 0.9)
    -- 大卡片槽独立接收鼠标，避免按住槽位时拖动最底层主窗口。
    flowPanel:EnableMouse(true)
    flowPanel:SetScript("OnMouseDown", function()
    end)
    flowPanel:SetScript("OnMouseUp", function()
    end)

    local flowTitle = flowPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    flowTitle:SetPoint("TOPLEFT", flowPanel, "TOPLEFT", 14, -12)
    flowTitle:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    flowTitle:SetTextColor(0.5, 0.8, 1)
    flowTitle:SetText(Cat2.L("流程"))

    flowCountText = flowPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    flowCountText:SetPoint("LEFT", flowTitle, "RIGHT", 8, 0)
    flowCountText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    flowCountText:SetTextColor(0.65, 0.72, 0.84)

    local rulesButton = CreateFrame("Button", nil, flowPanel)
    rulesButton:SetWidth(54)
    rulesButton:SetHeight(21)
    rulesButton:SetPoint("TOPRIGHT", flowPanel, "TOPRIGHT", -18, -7)
    rulesButton:EnableMouse(true)
    rulesButton:RegisterForClicks("LeftButtonUp")
    ApplyFlatBackdrop(rulesButton, 0.07, 0.12, 0.18, 1)
    local rulesText = rulesButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rulesText:SetPoint("CENTER", rulesButton, "CENTER", 0, 0)
    rulesText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    rulesText:SetTextColor(0.64, 0.78, 0.9)
    rulesText:SetText(Cat2.L("规则"))
    rulesButton:SetScript("OnEnter", function()
        rulesButton:SetBackdropColor(0.1, 0.24, 0.34, 1)
        rulesButton:SetBackdropBorderColor(0.42, 0.72, 0.9, 1)
        rulesText:SetTextColor(1, 0.84, 0.28)
    end)
    rulesButton:SetScript("OnLeave", function()
        rulesButton:SetBackdropColor(0.07, 0.12, 0.18, 1)
        rulesButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
        rulesText:SetTextColor(0.64, 0.78, 0.9)
    end)
    rulesButton:SetScript("OnMouseDown", function()
        rulesButton:SetBackdropColor(0.04, 0.09, 0.14, 1)
        rulesText:ClearAllPoints()
        rulesText:SetPoint("CENTER", rulesButton, "CENTER", 1, -1)
    end)
    rulesButton:SetScript("OnMouseUp", function()
        rulesButton:SetBackdropColor(0.1, 0.24, 0.34, 1)
        rulesText:ClearAllPoints()
        rulesText:SetPoint("CENTER", rulesButton, "CENTER", 0, 0)
    end)
    rulesButton:SetScript("OnClick", function()
        if Cat2.UI.ShowRulesWindow then
            Cat2.UI.ShowRulesWindow()
        end
    end)

    flowScroll, flowContent, flowSlider = CreateScrollArea(flowPanel)
    flowScroll:SetPoint("TOPLEFT", flowPanel, "TOPLEFT", 10, -32)
    flowSlider:SetPoint("TOPRIGHT", flowPanel, "TOPRIGHT", -12, -32)

    -- 空白流程区域的槽位引导线；卡片会覆盖已占用位置，只在空槽中露出。
    local guideIndex = 1
    while guideIndex <= 7 do
        local guideLine = flowContent:CreateTexture(nil, "BACKGROUND")
        guideLine:SetTexture("Interface\\Buttons\\WHITE8X8")
        guideLine:SetWidth(304)
        guideLine:SetHeight(1)
        -- 横线靠近槽位底部但位于卡片范围内，放入对应卡片后会被完整覆盖。
        guideLine:SetPoint("TOPLEFT", flowContent, "TOPLEFT", 6, -guideIndex * 50 + 6)
        guideLine:SetVertexColor(0.3, 0.42, 0.56, 0.22)
        guideIndex = guideIndex + 1
    end

    emptyHint = flowContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    emptyHint:SetPoint("CENTER", flowContent, "CENTER", 0, 0)
    emptyHint:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    emptyHint:SetTextColor(0.65, 0.65, 0.65)
    emptyHint:SetJustifyH("CENTER")
    emptyHint:SetText(Cat2.L("将右侧步骤拖到这里\n支持鼠标左键或右键拖动\n拖动左侧步骤可以调整顺序"))

    dropIndicator = CreateFrame("Frame", nil, flowContent)
    dropIndicator:SetWidth(316)
    dropIndicator:SetHeight(3)
    ApplyFlatBackdrop(dropIndicator, 1, 0.75, 0.15, 1)
    dropIndicator:Hide()

    availablePanel = CreateFrame("Frame", nil, mainWindow)
    availablePanel:SetWidth(356)
    availablePanel:SetHeight(438)
    availablePanel:SetPoint("TOPRIGHT", mainWindow, "TOPRIGHT", -16, -48)
    ApplyFlatBackdrop(availablePanel, 0.07, 0.08, 0.12, 0.9)
    availablePanel:EnableMouse(true)
    availablePanel:SetScript("OnMouseDown", function()
    end)
    availablePanel:SetScript("OnMouseUp", function()
    end)

    centerGap = CreateFrame("Button", nil, mainWindow)
    centerGap:SetWidth(16)
    centerGap:SetHeight(438)
    centerGap:SetPoint("TOPLEFT", flowPanel, "TOPRIGHT", 0, 0)
    centerGap:SetFrameStrata("HIGH")
    centerGap:SetFrameLevel(50)
    centerGap:EnableMouse(true)
    centerGap:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local gapHitArea = centerGap:CreateTexture(nil, "BACKGROUND")
    gapHitArea:SetAllPoints()
    gapHitArea:SetTexture("Interface\\Buttons\\WHITE8X8")
    gapHitArea:SetVertexColor(0, 0, 0, 0.01)
    centerGap:SetScript("OnMouseDown", function()
    end)
    centerGap:SetScript("OnMouseUp", function()
    end)
    centerGap:SetScript("OnClick", function()
    end)

    CreateFilterTab(availablePanel, "all", Cat2.L("全部"), 8, 40)
    CreateFilterTab(availablePanel, "common", Cat2.L("通用"), 50, 40)
    CreateFilterTab(availablePanel, "item", Cat2.L("药水"), 92, 40)
    CreateFilterTab(availablePanel, "spec1", Cat2.L(specializationNames[1]), 134, 66)
    CreateFilterTab(availablePanel, "spec2", Cat2.L(specializationNames[2]), 202, 72)
    CreateFilterTab(availablePanel, "spec3", Cat2.L(specializationNames[3]), 276, 72)
    CreateFilterTab(availablePanel, "spec4", specializationNames[4] and Cat2.L(specializationNames[4]) or Cat2.L("第四系"), 299, 55)
    -- 复用主窗口构造函数原本已经捕获的 Cat2，不能再新增 ui 这个 upvalue。
    Cat2.UI.LayoutFilterTabs(classFile)
    RefreshFilterTabs()

    availableScroll, availableContent, availableSlider = CreateScrollArea(availablePanel)
    availableScroll:SetHeight(392)
    availableSlider:SetHeight(392)
    availableScroll:SetPoint("TOPLEFT", availablePanel, "TOPLEFT", 10, -38)
    availableSlider:SetPoint("TOPRIGHT", availablePanel, "TOPRIGHT", -12, -38)
    availableContent:SetHeight(392)

    -- 底部操作区只保留导入与导出；调试窗改由 /cat2 debug 控制。
    footerActions = CreateFrame("Frame", nil, mainWindow)
    footerActions:SetWidth(188)
    footerActions:SetHeight(30)
    footerActions:SetPoint("BOTTOMRIGHT", mainWindow, "BOTTOMRIGHT", -16, 12)

    local function CreateFooterButton(labelText, offsetX, onClick)
        local button = CreateFrame("Button", nil, footerActions)
        button:SetWidth(90)
        button:SetHeight(28)
        button:SetPoint("LEFT", footerActions, "LEFT", offsetX, 0)
        ApplyFlatBackdrop(button, 0.08, 0.18, 0.27, 0.98)
        -- Backdrop 细边框在部分 UI 缩放下会产生横竖粗细差异，改用四条独立纹理稳定显示。
        button:SetBackdropBorderColor(0, 0, 0, 0)

        local topBorder = button:CreateTexture(nil, "OVERLAY")
        topBorder:SetTexture("Interface\\Buttons\\WHITE8X8")
        topBorder:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
        topBorder:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
        topBorder:SetHeight(1)
        topBorder:SetVertexColor(0.3, 0.4, 0.52, 0.9)

        local bottomBorder = button:CreateTexture(nil, "OVERLAY")
        bottomBorder:SetTexture("Interface\\Buttons\\WHITE8X8")
        bottomBorder:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
        bottomBorder:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        bottomBorder:SetHeight(1)
        bottomBorder:SetVertexColor(0.3, 0.4, 0.52, 0.9)

        local leftBorder = button:CreateTexture(nil, "OVERLAY")
        leftBorder:SetTexture("Interface\\Buttons\\WHITE8X8")
        leftBorder:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -1)
        leftBorder:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 1)
        leftBorder:SetWidth(1)
        leftBorder:SetVertexColor(0.3, 0.4, 0.52, 0.9)

        local rightBorder = button:CreateTexture(nil, "OVERLAY")
        rightBorder:SetTexture("Interface\\Buttons\\WHITE8X8")
        rightBorder:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, -1)
        rightBorder:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 1)
        rightBorder:SetWidth(1)
        rightBorder:SetVertexColor(0.3, 0.4, 0.52, 0.9)

        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER", button, "CENTER", 0, 0)
        text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        text:SetTextColor(0.78, 0.9, 1)
        text:SetText(labelText)

        button:SetScript("OnEnter", function()
            button:SetBackdropColor(0.12, 0.4, 0.58, 1)
            text:SetTextColor(1, 0.84, 0.28)
        end)
        button:SetScript("OnLeave", function()
            button:SetBackdropColor(0.08, 0.18, 0.27, 0.98)
            text:SetTextColor(0.78, 0.9, 1)
        end)
        button:SetScript("OnMouseDown", function()
            button:SetBackdropColor(0.05, 0.12, 0.18, 1)
            text:ClearAllPoints()
            text:SetPoint("CENTER", button, "CENTER", 1, -1)
        end)
        button:SetScript("OnMouseUp", function()
            button:SetBackdropColor(0.12, 0.4, 0.58, 1)
            text:ClearAllPoints()
            text:SetPoint("CENTER", button, "CENTER", 0, 0)
        end)
        button:SetScript("OnClick", onClick or function()
        end)
    end

    CreateFooterButton(Cat2.L("导出"), 0, function()
        if Cat2.UI.ShowExportWindow then
            Cat2.UI.ShowExportWindow()
        end
    end)
    CreateFooterButton(Cat2.L("导入"), 98, function()
        if Cat2.UI.ShowImportWindow then
            Cat2.UI.ShowImportWindow()
        end
    end)

    -- 当前配置的执行指令；旧版客户端不能直接写入系统剪贴板，因此点击后自动全选供 Ctrl+C 复制。
    local commandCopyBox = CreateFrame("EditBox", nil, mainWindow)
    mainWindow.commandCopyBox = commandCopyBox
    commandCopyBox:SetWidth(176)
    commandCopyBox:SetHeight(28)
    commandCopyBox:SetPoint("BOTTOMLEFT", mainWindow, "BOTTOMLEFT", 358, 13)
    commandCopyBox:SetAutoFocus(false)
    commandCopyBox:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    commandCopyBox:SetTextColor(0.68, 0.78, 0.88)
    commandCopyBox:SetTextInsets(9, 9, 0, 0)
    commandCopyBox:SetMaxLetters(64)
    ApplyFlatBackdrop(commandCopyBox, 0.06, 0.09, 0.14, 0.98)

    local commandCopyValue = ""
    local commandCopyUpdating = false
    local function SetCommandCopyText(profileName)
        commandCopyValue = "/cat2 " .. profileName
        commandCopyUpdating = true
        commandCopyBox:SetText(commandCopyValue)
        commandCopyUpdating = false
    end

    commandCopyBox:SetScript("OnEditFocusGained", function()
        commandCopyBox:HighlightText()
    end)
    commandCopyBox:SetScript("OnMouseUp", function()
        commandCopyBox:SetFocus()
        commandCopyBox:HighlightText()
    end)
    commandCopyBox:SetScript("OnTextChanged", function()
        if not commandCopyUpdating and commandCopyBox:GetText() ~= commandCopyValue then
            commandCopyUpdating = true
            commandCopyBox:SetText(commandCopyValue)
            commandCopyBox:HighlightText()
            commandCopyUpdating = false
        end
    end)
    commandCopyBox:SetScript("OnEscapePressed", function()
        commandCopyBox:ClearFocus()
        commandCopyBox:HighlightText(0, 0)
    end)
    commandCopyBox:SetScript("OnEnterPressed", function()
        commandCopyBox:HighlightText()
    end)
    commandCopyBox:SetScript("OnEnter", function()
        commandCopyBox:SetBackdropColor(0.09, 0.15, 0.22, 1)
        GameTooltip:SetOwner(commandCopyBox, "ANCHOR_TOP")
        GameTooltip:SetText(Cat2.L("当前配置的执行指令"))
        GameTooltip:AddLine(Cat2.L("点击输入框自动全选，然后按 Ctrl+C 复制。"), 0.78, 0.86, 0.96)
        GameTooltip:AddLine(Cat2.L("可粘贴到宏中，也可以直接在聊天栏使用。"), 0.64, 0.7, 0.8)
        GameTooltip:Show()
    end)
    commandCopyBox:SetScript("OnLeave", function()
        commandCopyBox:SetBackdropColor(0.06, 0.09, 0.14, 0.98)
        GameTooltip:Hide()
    end)

    -- 左下角 Profile 选择区；当前先维护运行时配置，后续可直接接入 SavedVariables。
    profileActions = CreateFrame("Frame", nil, mainWindow)
    profileActions:SetWidth(330)
    profileActions:SetHeight(30)
    profileActions:SetPoint("BOTTOMLEFT", mainWindow, "BOTTOMLEFT", 16, 12)

    local profileMenuEntries = {}

    local profileSelect = CreateFrame("Button", nil, profileActions)
    profileSelect:SetWidth(146)
    profileSelect:SetHeight(28)
    profileSelect:SetPoint("LEFT", profileActions, "LEFT", 92, 0)
    ApplyFlatBackdrop(profileSelect, 0.07, 0.1, 0.15, 0.98)

    local profileText = profileSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profileText:SetPoint("LEFT", profileSelect, "LEFT", 9, 0)
    profileText:SetWidth(112)
    profileText:SetJustifyH("LEFT")
    profileText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    profileText:SetTextColor(0.78, 0.9, 1)

    local profileArrow = profileSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profileArrow:SetPoint("RIGHT", profileSelect, "RIGHT", -8, 0)
    profileArrow:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    profileArrow:SetTextColor(0.5, 0.75, 0.95)
    profileArrow:SetText("▲")

    local profileMenu = CreateFrame("Frame", nil, profileActions)
    profileMenu:SetWidth(146)
    profileMenu:SetHeight(28)
    profileMenu:SetPoint("BOTTOMLEFT", profileSelect, "TOPLEFT", 0, 3)
    profileMenu:SetFrameLevel(mainWindow:GetFrameLevel() + 30)
    ApplyFlatBackdrop(profileMenu, 0.04, 0.06, 0.1, 1)
    profileMenu:Hide()

    local function UpdateProfileText()
        local activeProfile = runtimeConfigurations.profiles[runtimeConfigurations.activeProfileId]
        profileText:SetText(activeProfile.name)
        SetCommandCopyText(activeProfile.name)
        RefreshShortcutToggleText()
    end
    mainWindow.UpdateProfileText = UpdateProfileText

    -- 新建与改名共用同一套名称规则；改名时允许保留当前配置自己的名称。
    local function ValidateProfileName(value, ignoredProfileId)
        local characterCount = CountTextCharacters(value)
        if characterCount < 2 or characterCount > 12 then
            return false, "名称长度必须为 2-12 个汉字或字符。"
        end
        -- debug 已由 /cat2 debug 用作调试指令，不能再作为配置名称。
        if string.lower(value) == "debug" then
            return false, "debug 是调试指令，不能作为配置名称。"
        end
        local checkIndex = 1
        local checkTotal = table.getn(runtimeConfigurations.profileOrder)
        while checkIndex <= checkTotal do
            local checkId = runtimeConfigurations.profileOrder[checkIndex]
            if checkId ~= ignoredProfileId and runtimeConfigurations.profiles[checkId].name == value then
                return false, "已经存在同名配置。"
            end
            checkIndex = checkIndex + 1
        end
        return true
    end

    local function RebuildProfileMenu()
        local oldIndex = 1
        local oldTotal = table.getn(profileMenuEntries)
        while oldIndex <= oldTotal do
            profileMenuEntries[oldIndex]:Hide()
            oldIndex = oldIndex + 1
        end
        profileMenuEntries = {}

        local profileIndex = 1
        local profileTotal = table.getn(runtimeConfigurations.profileOrder)
        profileMenu:SetHeight(profileTotal * 26 + 4)
        while profileIndex <= profileTotal do
            local profileId = runtimeConfigurations.profileOrder[profileIndex]
            local profile = runtimeConfigurations.profiles[profileId]
            local entry = CreateFrame("Button", nil, profileMenu)
            entry:SetWidth(140)
            entry:SetHeight(24)
            entry:SetPoint("TOPLEFT", profileMenu, "TOPLEFT", 3, -2 - (profileIndex - 1) * 26)

            local entryText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            entryText:SetPoint("LEFT", entry, "LEFT", 7, 0)
            entryText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
            entryText:SetText(profile.name)
            if profileId == runtimeConfigurations.activeProfileId then
                entryText:SetTextColor(1, 0.82, 0.2)
            else
                entryText:SetTextColor(0.76, 0.82, 0.9)
            end

            local entryProfileId = profileId
            entry:SetScript("OnEnter", function()
                entryText:SetTextColor(0.5, 0.82, 1)
            end)
            entry:SetScript("OnLeave", function()
                if entryProfileId == runtimeConfigurations.activeProfileId then
                    entryText:SetTextColor(1, 0.82, 0.2)
                else
                    entryText:SetTextColor(0.76, 0.82, 0.9)
                end
            end)
            entry:SetScript("OnClick", function()
                runtimeConfigurations.activeProfileId = entryProfileId
                selectedSteps = runtimeConfigurations.profiles[entryProfileId].steps
                selectedFlowIndex = nil
                UpdateProfileText()
                profileMenu:Hide()
                RedrawFlow()
            end)
            profileMenuEntries[profileIndex] = entry
            profileIndex = profileIndex + 1
        end

    end

    profileSelect:SetScript("OnEnter", function()
        profileSelect:SetBackdropColor(0.1, 0.24, 0.35, 1)
    end)
    profileSelect:SetScript("OnLeave", function()
        profileSelect:SetBackdropColor(0.07, 0.1, 0.15, 0.98)
    end)
    profileSelect:SetScript("OnClick", function()
        if profileMenu:IsVisible() then
            profileMenu:Hide()
        else
            RebuildProfileMenu()
            profileMenu:Show()
        end
    end)

    local function CreateProfileActionButton(labelText, offsetX, onClick, buttonWidth)
        local isAddButton = labelText == "+"
        local isDeleteButton = labelText == "-"
        local isRenameButton = labelText == Cat2.L("改名")
        local isManagerButton = labelText == Cat2.L("管理")
        local button = CreateFrame("Button", nil, profileActions)
        button:SetWidth(buttonWidth or 42)
        button:SetHeight(28)
        button:SetPoint("LEFT", profileActions, "LEFT", offsetX, 0)
        if isAddButton then
            ApplyFlatBackdrop(button, 0.06, 0.2, 0.13, 0.98)
        elseif isDeleteButton then
            ApplyFlatBackdrop(button, 0.22, 0.07, 0.09, 0.98)
        else
            ApplyFlatBackdrop(button, 0.08, 0.18, 0.27, 0.98)
        end

        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        if isRenameButton or isManagerButton then
            text:SetPoint("CENTER", button, "CENTER", 0, 0)
        else
            text:SetPoint("CENTER", button, "CENTER", 0, 1)
        end
        if isAddButton or isDeleteButton then
            text:SetFont("Fonts\\FRIZQT__.TTF", 20, "THICKOUTLINE")
        elseif isRenameButton then
            text:SetFont("Fonts\\FRIZQT__.TTF", 12, "THICKOUTLINE")
        else
            text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        end
        if isAddButton then
            text:SetTextColor(0.42, 1, 0.56)
        elseif isDeleteButton then
            text:SetTextColor(1, 0.42, 0.44)
        else
            text:SetTextColor(0.68, 0.88, 1)
        end
        if isRenameButton then
            text:SetText(Cat2.L("改"))
        else
            text:SetText(labelText)
        end

        button:SetScript("OnEnter", function()
            if isAddButton then
                button:SetBackdropColor(0.09, 0.38, 0.2, 1)
                text:SetTextColor(0.68, 1, 0.72)
            elseif isDeleteButton then
                button:SetBackdropColor(0.45, 0.1, 0.12, 1)
                text:SetTextColor(1, 0.68, 0.68)
            else
                button:SetBackdropColor(0.12, 0.4, 0.58, 1)
                text:SetTextColor(1, 0.84, 0.28)
                if isRenameButton then
                    GameTooltip:SetOwner(button, "ANCHOR_TOP")
                    GameTooltip:SetText(Cat2.L("重命名当前配置"))
                    GameTooltip:Show()
                end
            end
        end)
        button:SetScript("OnLeave", function()
            if isAddButton then
                button:SetBackdropColor(0.06, 0.2, 0.13, 0.98)
                text:SetTextColor(0.42, 1, 0.56)
            elseif isDeleteButton then
                button:SetBackdropColor(0.22, 0.07, 0.09, 0.98)
                text:SetTextColor(1, 0.42, 0.44)
            else
                button:SetBackdropColor(0.08, 0.18, 0.27, 0.98)
                text:SetTextColor(0.68, 0.88, 1)
                if isRenameButton then
                    GameTooltip:Hide()
                end
            end
        end)
        button:SetScript("OnMouseDown", function()
            button:SetBackdropColor(0.05, 0.12, 0.18, 1)
            text:ClearAllPoints()
            if isRenameButton or isManagerButton then
                text:SetPoint("CENTER", button, "CENTER", 1, -1)
            else
                text:SetPoint("CENTER", button, "CENTER", 1, 0)
            end
        end)
        button:SetScript("OnMouseUp", function()
            if isAddButton then
                button:SetBackdropColor(0.09, 0.38, 0.2, 1)
            elseif isDeleteButton then
                button:SetBackdropColor(0.45, 0.1, 0.12, 1)
            else
                button:SetBackdropColor(0.12, 0.4, 0.58, 1)
            end
            text:ClearAllPoints()
            if isRenameButton or isManagerButton then
                text:SetPoint("CENTER", button, "CENTER", 0, 0)
            else
                text:SetPoint("CENTER", button, "CENTER", 0, 1)
            end
        end)
        button:SetScript("OnClick", onClick)
        return button
    end

    local legacyCreateProfileButton = CreateProfileActionButton("+", 242, function()
        profileMenu:Hide()
        ShowTextInput(Cat2.L("新建配置（2-12个字符）"), "", function(value)
            return ValidateProfileName(value, nil)
        end, function(value)
            local newId = runtimeConfigurations.nextProfileId
            runtimeConfigurations.nextProfileId = newId + 1
            runtimeConfigurations.profiles[newId] = {
                id = newId,
                name = value,
                steps = {}
            }
            table.insert(runtimeConfigurations.profileOrder, newId)
            runtimeConfigurations.activeProfileId = newId
            selectedSteps = runtimeConfigurations.profiles[newId].steps
            selectedFlowIndex = nil
            UpdateProfileText()
            RedrawFlow()
        end)
    end)
    local legacyDeleteProfileButton = CreateProfileActionButton("-", 288, function()
        local profileTotal = table.getn(runtimeConfigurations.profileOrder)
        if profileTotal <= 1 then
            ShowNotice(Cat2.L("至少需要保留一个配置，不能删除当前配置。"))
            return
        end
        profileMenu:Hide()
        local deleteId = runtimeConfigurations.activeProfileId
        local deleteProfile = runtimeConfigurations.profiles[deleteId]
        local deleteName = deleteProfile.name
        ShowConfirm(Cat2.L("确定删除配置「") .. deleteName .. Cat2.L("」吗？\n此操作无法撤销。"), function()
            if not runtimeConfigurations.profiles[deleteId] then
                return
            end
            local deleteOrderIndex = nil
            local orderIndex = 1
            local orderTotal = table.getn(runtimeConfigurations.profileOrder)
            while orderIndex <= orderTotal do
                if runtimeConfigurations.profileOrder[orderIndex] == deleteId then
                    deleteOrderIndex = orderIndex
                    break
                end
                orderIndex = orderIndex + 1
            end
            if not deleteOrderIndex then
                return
            end
            table.remove(runtimeConfigurations.profileOrder, deleteOrderIndex)
            if Cat2.RemoveProfileShortcutWindowSettings then
                Cat2.RemoveProfileShortcutWindowSettings(deleteId)
            end
            runtimeConfigurations.profiles[deleteId] = nil
            local remainingTotal = table.getn(runtimeConfigurations.profileOrder)
            if deleteOrderIndex > remainingTotal then
                deleteOrderIndex = remainingTotal
            end
            local nextActiveId = runtimeConfigurations.profileOrder[deleteOrderIndex]
            runtimeConfigurations.activeProfileId = nextActiveId
            selectedSteps = runtimeConfigurations.profiles[nextActiveId].steps
            selectedFlowIndex = nil
            UpdateProfileText()
            RedrawFlow()
        end)
    end)
    -- 快捷窗属于当前配置，将开关放在配置管理入口旁边，比标题栏更容易理解。
    minimizeButton:ClearAllPoints()
    minimizeButton:SetWidth(28)
    minimizeButton:SetHeight(28)
    minimizeButton:SetPoint("LEFT", profileActions, "LEFT", 0, 0)

    CreateProfileActionButton(Cat2.L("管理"), 34, function()
        if Cat2.UI.ToggleProfileManager then
            Cat2.UI.ToggleProfileManager()
        elseif DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff5555" .. Cat2.L("配置管理模块尚未加载，请完整重启游戏。") .. "|r")
        end
    end, 52)
    UpdateProfileText()

    CreateDragGhost()
    mainWindow:SetScript("OnUpdate", function()
        UpdateDragGhost()
    end)
    mainWindow:SetScript("OnShow", function()
        if mainWindow.Raise then
            mainWindow:Raise()
        end
    end)
    Cat2.UI.RedrawFlow()
    Cat2.UI.RedrawAvailable()
end

-- 供小地图入口调用的显示切换函数。
local function ToggleMainWindow()
    CreateMainWindow()
    if mainWindow:IsVisible() then
        if mainWindow.classPreviewMenu then
            mainWindow.classPreviewMenu:Hide()
        end
        mainWindow:Hide()
    else
        mainWindow:Show()
        UpdateScrollBar(flowScroll, flowSlider, flowContent:GetHeight())
        UpdateScrollBar(availableScroll, availableSlider, availableContent:GetHeight())
    end
end

ui.ToggleMainWindow = ToggleMainWindow

-- 聊天指令等入口只需要确保主界面打开，不能沿用 Toggle 导致已显示时反向关闭。
function ui.ShowMainWindow()
    CreateMainWindow()
    if not mainWindow:IsVisible() then
        mainWindow:Show()
    end
    UpdateScrollBar(flowScroll, flowSlider, flowContent:GetHeight())
    UpdateScrollBar(availableScroll, availableSlider, availableContent:GetHeight())
end

-- 登录恢复入口：只恢复独立快捷小窗，不自动打开主编辑界面。
function ui.RestoreMinimizedWindow()
    CreateMainWindow()
    SetShortcutWindowVisible(true)
end

-- 设置面板调用：即时应用网格尺寸，并同步快捷小窗外框大小。
function ui.ApplyMinimizedLayout()
    if not shortcutWindow then
        return
    end
    Cat2.UI.RedrawMinimizedShortcuts()
end

function ui.ResetMinimizedWindowPosition()
    Cat2.ResetMinimizedPositionData()
    if not shortcutWindow then
        return
    end
    shortcutWindow:ClearAllPoints()
    shortcutWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end
