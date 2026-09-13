-- 左右列表重绘、卡片库筛选及职业预览数据。
-- 依赖 FlowEditor.lua；内部接口通过 Cat2.UI.FlowEditor 共享。
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
local editor = ui.FlowEditor

-- 依据 selectedSteps 重建左侧流程卡片，并刷新数量和滚动范围。
editor.RedrawFlow = function()
    -- 独立快捷窗可在主编辑器创建前被点击；此时没有左侧列表控件可重绘。
    if not editor.mainWindow or not editor.flowContent or not editor.flowScroll then
        return
    end
    local oldIndex = 1
    local oldTotal = table.getn(editor.leftBlocks)
    while oldIndex <= oldTotal do
        editor.leftBlocks[oldIndex]:Hide()
        oldIndex = oldIndex + 1
    end
    editor.leftBlocks = {}

    local occurrenceById = {}

    local total = table.getn(editor.selectedSteps)
    editor.flowCountText:SetText("(" .. total .. " / " .. editor.maximumFlowSteps .. ")")
    if total == 0 then
        editor.emptyHint:Show()
    else
        editor.emptyHint:Hide()
    end

    local index = 1
    while index <= total do
        local step = editor.selectedSteps[index]
        local cacheId = step.id or "__missing"
        local occurrence = (occurrenceById[cacheId] or 0) + 1
        occurrenceById[cacheId] = occurrence
        local cacheBucket = editor.flowBlockCache[cacheId]
        if not cacheBucket then
            cacheBucket = {}
            editor.flowBlockCache[cacheId] = cacheBucket
        end
        local block = cacheBucket[occurrence]
        if not block then
            block = editor.CreateStepBlock(editor.flowContent, step, index, true)
            cacheBucket[occurrence] = block
        else
            block.step = step
            block.index = index
            block.fromFlow = true
            block:ClearAllPoints()
            if block.RefreshState then
                block.RefreshState()
            end
            block:Show()
        end
        block:SetPoint("TOPLEFT", editor.flowContent, "TOPLEFT", 24, -2 - (index - 1) * 50)
        editor.leftBlocks[index] = block
        index = index + 1
    end

    local contentHeight = total * 50 + 4
    if contentHeight < 392 then
        contentHeight = 392
    end
    editor.flowContent:SetHeight(contentHeight)
    UpdateScrollBar(editor.flowScroll, editor.flowSlider, contentHeight)

    if Cat2.UI.RedrawMinimizedShortcuts then
        Cat2.UI.RedrawMinimizedShortcuts()
    end
    editor.SaveRuntimeConfigurations()
    ui.RefreshProfileMacroIcon()
end

-- 根据当前单选标签页重建右侧卡片列表，并刷新滚动范围。
editor.RedrawAvailable = function()
    -- 主界面尚未创建时只保留数据状态，不能访问右侧列表控件。
    if not editor.mainWindow or not editor.availableContent or not editor.availableScroll then
        return
    end
    local oldIndex = 1
    local oldTotal = table.getn(editor.availableBlocks)
    while oldIndex <= oldTotal do
        editor.availableBlocks[oldIndex]:Hide()
        oldIndex = oldIndex + 1
    end
    editor.availableBlocks = {}

    local sourceIndex = 1
    local sourceTotal = table.getn(editor.availableSteps)
    local displayOrder = {}
    while sourceIndex <= sourceTotal do
        -- 注册表更新或预览职业切换期间可能留下空位；排序前过滤，避免比较函数访问空卡片。
        if editor.availableSteps[sourceIndex] then
            table.insert(displayOrder, sourceIndex)
        end
        sourceIndex = sourceIndex + 1
    end

    local displayIndex = 1
    local orderIndex = 1
    local orderTotal = table.getn(displayOrder)
    while orderIndex <= orderTotal do
        sourceIndex = displayOrder[orderIndex]
        local step = editor.availableSteps[sourceIndex]
        if step then
            local visible = false
            if editor.selectedFilter == "common" then
                visible = step.category == "common"
            elseif editor.selectedFilter == "logic" then
                visible = step.category == "logic"
            elseif editor.selectedFilter == "item" then
                visible = step.category == "item"
            elseif editor.selectedFilter == "spec1" then
                visible = step.category == "class" and Cat2.GetCardSpecializationForClass(step, Cat2.PlayerClassFile) == 1
            elseif editor.selectedFilter == "spec2" then
                visible = step.category == "class" and Cat2.GetCardSpecializationForClass(step, Cat2.PlayerClassFile) == 2
            elseif editor.selectedFilter == "spec3" then
                visible = step.category == "class" and Cat2.GetCardSpecializationForClass(step, Cat2.PlayerClassFile) == 3
            elseif editor.selectedFilter == "spec4" then
                visible = step.category == "class" and Cat2.GetCardSpecializationForClass(step, Cat2.PlayerClassFile) == 4
            end
            if visible then
                local cacheId = step.id or tostring(sourceIndex)
                local block = editor.availableBlockCache[cacheId]
                if not block then
                    block = editor.CreateStepBlock(editor.availableContent, step, sourceIndex, false)
                    editor.availableBlockCache[cacheId] = block
                else
                    block.step = step
                    block.index = sourceIndex
                    block.fromFlow = false
                    block:ClearAllPoints()
                    if block.RefreshState then
                        block.RefreshState()
                    end
                    block:Show()
                end
                block:SetPoint("TOPLEFT", editor.availableContent, "TOPLEFT", 0, -2 - (displayIndex - 1) * 50)
                editor.availableBlocks[displayIndex] = block
                displayIndex = displayIndex + 1
            end
        end
        orderIndex = orderIndex + 1
    end

    local contentHeight = (displayIndex - 1) * 50 + 4
    local minimumHeight = editor.availableScroll:GetHeight()
    if contentHeight < minimumHeight then
        contentHeight = minimumHeight
    end
    editor.availableContent:SetHeight(contentHeight)
    UpdateScrollBar(editor.availableScroll, editor.availableSlider, contentHeight)
end

-- 通过 UI 命名空间提供重绘入口，避免主窗口构造函数捕获过多外部变量。
-- 旧版客户端单个函数最多允许 32 个 upvalue，因此这里不能继续直接闭包引用。
ui.RedrawFlow = editor.RedrawFlow
ui.RedrawAvailable = editor.RedrawAvailable


-- 同步所有标签页的选中外观。
function editor.RefreshFilterTabs()
    local index = 1
    local total = table.getn(editor.filterTabs)
    while index <= total do
        local tab = editor.filterTabs[index]
        if tab.filterKey == editor.selectedFilter then
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
function editor.CreateFilterTab(parent, filterKey, labelText, offsetX, width)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(21)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", offsetX, -7)
    button.filterKey = filterKey
    ApplyFlatBackdrop(button, 0.07, 0.08, 0.12, 1)
    button:SetBackdropBorderColor(0.3, 0.4, 0.52, 1) -- 共用边线不因半透明叠加而变色。

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
        if editor.selectedFilter ~= filterKey then
            button:SetBackdropColor(0.1, 0.17, 0.25, 1)
            text:SetTextColor(0.86, 0.9, 0.96)
        end
    end)
    button:SetScript("OnLeave", function()
        editor.RefreshFilterTabs()
    end)

    button:SetScript("OnClick", function()
        editor.selectedFilter = filterKey
        editor.RefreshFilterTabs()
        editor.RedrawAvailable()
    end)
    table.insert(editor.filterTabs, button)
end

-- 分类栏按可见标签等分；萨满包含“图腾”，其他职业隐藏第四分类。
function ui.LayoutFilterTabs(classFile)
    local specializationNames = Cat2.ClassSpecializations[classFile]
    local hasFourthGroup = specializationNames and specializationNames[4] ~= nil
    local tabTotal = table.getn(editor.filterTabs)
    local visibleCount = 0
    for tabIndex = 1, tabTotal do
        if editor.filterTabs[tabIndex].filterKey ~= "spec4" or hasFourthGroup then
            visibleCount = visibleCount + 1
        end
    end
    if visibleCount == 0 then
        return
    end

    local padding = 12 -- 与下方卡片的左边界对齐，左右内边距统一为12。
    local rightPadding = 12 -- 与卡库滚动条的右边界对齐。
    local spacing = -1 -- 相邻的1单位边框重合，交界处只呈现一条边线。
    local width = (editor.availablePanel:GetWidth() - padding - rightPadding - spacing * (visibleCount - 1)) / visibleCount
    local visibleIndex = 0
    for tabIndex = 1, tabTotal do
        local tab = editor.filterTabs[tabIndex]
        if tab.filterKey == "spec4" and not hasFourthGroup then
            tab:Hide()
        else
            tab:ClearAllPoints()
            tab:SetPoint("TOPLEFT", editor.availablePanel, "TOPLEFT", padding + visibleIndex * (width + spacing), -7)
            tab:SetWidth(width)
            tab.text:SetWidth(width - 4)
            tab:Show()
            visibleIndex = visibleIndex + 1
        end
    end
    if editor.selectedFilter == "spec4" and not hasFourthGroup then
        editor.selectedFilter = "common"
    end
end

-- 隐藏职业预览开关只改变右侧卡片库；流程槽门禁仍读取角色真实职业。
function ui.SetCardPreviewClass(classFile)
    if not Cat2.ClassSpecializations[classFile] then
        return false
    end
    Cat2.PlayerClassFile = classFile
    editor.availableSteps = Cat2.GetCardsForClass(classFile)

    local specializationNames = Cat2.ClassSpecializations[classFile]
    local tabIndex = 1
    local tabTotal = table.getn(editor.filterTabs)
    while tabIndex <= tabTotal do
        local tab = editor.filterTabs[tabIndex]
        if tab.filterKey == "spec1" then
            tab.text:SetText(specializationNames[1])
        elseif tab.filterKey == "spec2" then
            tab.text:SetText(specializationNames[2])
        elseif tab.filterKey == "spec3" then
            tab.text:SetText(specializationNames[3])
        elseif tab.filterKey == "spec4" and specializationNames[4] then
            tab.text:SetText(specializationNames[4])
        end
        tabIndex = tabIndex + 1
    end
    ui.LayoutFilterTabs(classFile)
    editor.RefreshFilterTabs()

    if editor.mainWindow and editor.mainWindow.RefreshClassPreviewDropdown then
        editor.mainWindow.RefreshClassPreviewDropdown()
    end

    if editor.availableScroll then
        editor.availableScroll:SetVerticalScroll(0)
    end
    if editor.availableSlider then
        editor.availableSlider:SetValue(0)
    end
    editor.RedrawAvailable()
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
