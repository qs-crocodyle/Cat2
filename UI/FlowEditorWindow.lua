-- 主窗口布局、底部配置操作及显示入口。
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

-- 延迟创建主编辑窗口；窗口仅创建一次并限制在屏幕内移动。
local function CreateMainWindow()
    if editor.mainWindow then
        if editor.mainWindow.cat2ConstructionComplete == true then
            return
        end
        -- 上一次构造中途失败时保持隐藏并继续报错，不能把半成品窗口显示给玩家。
        editor.mainWindow:Hide()
        error(Cat2.L("Cat2 主界面上一次创建未完成，请 /reload 后重试"))
    end

    Cat2.EnsureConfigurationDataLoaded()
    Cat2.UI.CreateShortcutWindow()

    local localizedClass, classFile = UnitClass("player")
    -- 保存在命名空间而非模块局部变量，避免旧版 Lua 的函数上值数量超过 32。
    Cat2.ActualPlayerClassFile = classFile
    Cat2.PlayerClassFile = classFile
    editor.availableSteps = Cat2.GetCardsForClass(classFile)
    local specializationNames = Cat2.ClassSpecializations[classFile]
    if not specializationNames then
        specializationNames = { Cat2.L("第一系"), Cat2.L("第二系"), Cat2.L("第三系") }
    end

    editor.mainWindow = CreateFrame("Frame", "Cat2MainWindow", UIParent)
    editor.mainWindow:SetWidth(784)
    editor.mainWindow:SetHeight(550)
    editor.mainWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    -- 主编辑器保持在普通界面之上，但不能盖住游戏系统菜单使用的对话框层。
    editor.mainWindow:SetFrameStrata("HIGH")
    editor.mainWindow:SetFrameLevel(20)
    editor.mainWindow:SetMovable(true)
    editor.mainWindow:SetClampedToScreen(true)
    editor.mainWindow:EnableMouse(true)
    editor.mainWindow:RegisterForDrag("LeftButton")
    editor.mainWindow:SetScript("OnDragStart", function()
        if editor.mainWindow.Raise then
            editor.mainWindow:Raise()
        end
        editor.mainWindow:StartMoving()
    end)
    editor.mainWindow:SetScript("OnDragStop", function()
        editor.mainWindow:StopMovingOrSizing()
    end)
    ApplyFlatBackdrop(editor.mainWindow, 0.04, 0.05, 0.08, 0.85)
    editor.mainWindow:Hide()

    local titleBar = CreateFrame("Frame", nil, editor.mainWindow)
    titleBar:SetWidth(732)
    titleBar:SetHeight(32)
    titleBar:SetPoint("TOPLEFT", editor.mainWindow, "TOPLEFT", 12, -8)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function()
        editor.mainWindow:StartMoving()
    end)
    titleBar:SetScript("OnDragStop", function()
        editor.mainWindow:StopMovingOrSizing()
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
    editor.mainWindow.titleText = title
    editor.mainWindow.titleNumberText = titleNumber
    editor.mainWindow.titleTailText = titleTail
    editor.mainWindow.titleVersionText = titleVersion
    Cat2.UI.CreateTitleInfoTooltip(titleBar, titleVersion)

    Cat2.UI.CreateClassPreviewDropdown(editor.mainWindow)
    Cat2.UI.CreateModuleStatusBar(editor.mainWindow)

    local minimizeButton = CreateFrame("Button", nil, editor.mainWindow)
    minimizeButton:SetWidth(24)
    minimizeButton:SetHeight(24)
    minimizeButton:SetPoint("TOPRIGHT", editor.mainWindow, "TOPRIGHT", -42, -12)
    minimizeButton:SetFrameLevel(editor.mainWindow:GetFrameLevel() + 20)
    ApplyFlatBackdrop(minimizeButton, 0.08, 0.22, 0.34, 0.98)

    -- 使用纹理绘制窗口符号，避免与配置新增、删除按钮的 + / - 混淆。
    Cat2.UI.CreateShortcutToggleGlyph(minimizeButton, editor.mainWindow)
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
        editor.RefreshShortcutToggleText()
        GameTooltip:Hide()
    end)
    minimizeButton:SetScript("OnMouseDown", function()
        minimizeButton:SetBackdropColor(0.05, 0.14, 0.22, 1)
        editor.mainWindow.shortcutToggleGlyphFrame:ClearAllPoints()
        editor.mainWindow.shortcutToggleGlyphFrame:SetPoint("CENTER", minimizeButton, "CENTER", 1, -1)
        Cat2.UI.SetShortcutToggleGlyphColor(0.32, 0.58, 0.7, 0.2)
    end)
    minimizeButton:SetScript("OnMouseUp", function()
        minimizeButton:SetBackdropColor(0.12, 0.4, 0.58, 1)
        editor.mainWindow.shortcutToggleGlyphFrame:ClearAllPoints()
        editor.mainWindow.shortcutToggleGlyphFrame:SetPoint("CENTER", minimizeButton, "CENTER", 0, 0)
        Cat2.UI.SetShortcutToggleGlyphColor(1, 0.84, 0.28, 0.22)
    end)
    minimizeButton:SetScript("OnClick", function()
        local visible = false
        if Cat2.RuntimeConfigurations and Cat2.RuntimeConfigurations.activeProfileId and Cat2.GetProfileShortcutWindowSettings then
            visible = Cat2.GetProfileShortcutWindowSettings(Cat2.RuntimeConfigurations.activeProfileId)
        end
        Cat2.UI.SetShortcutWindowVisible(not visible)
    end)

    local closeButton = CreateFrame("Button", nil, editor.mainWindow)
    closeButton:SetWidth(24)
    closeButton:SetHeight(24)
    closeButton:SetPoint("TOPRIGHT", editor.mainWindow, "TOPRIGHT", -16, -12)
    ApplyFlatBackdrop(closeButton, 0.35, 0.08, 0.08, 0.98)

    local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeText:SetPoint("CENTER", closeButton, "CENTER", 0, 0)
    closeText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    closeText:SetTextColor(1, 0.82, 0.82)
    closeText:SetText("X")
    editor.mainWindow.closeControl = closeButton
    editor.mainWindow.closeControlText = closeText

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
        if editor.mainWindow.classPreviewMenu then
            editor.mainWindow.classPreviewMenu:Hide()
        end
        if Cat2.UI.HideSettingsWindow then
            Cat2.UI.HideSettingsWindow()
        end
        editor.mainWindow:Hide()
    end)

    editor.flowPanel = CreateFrame("Frame", nil, editor.mainWindow)
    editor.flowPanel:SetWidth(380)
    editor.flowPanel:SetHeight(438)
    editor.flowPanel:SetPoint("TOPLEFT", editor.mainWindow, "TOPLEFT", 16, -48)
    ApplyFlatBackdrop(editor.flowPanel, 0.07, 0.08, 0.12, 0.9)
    -- 大卡片槽独立接收鼠标，避免按住槽位时拖动最底层主窗口。
    editor.flowPanel:EnableMouse(true)
    editor.flowPanel:SetScript("OnMouseDown", function()
    end)
    editor.flowPanel:SetScript("OnMouseUp", function()
    end)

    local flowTitle = editor.flowPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    flowTitle:SetPoint("TOPLEFT", editor.flowPanel, "TOPLEFT", 14, -12)
    flowTitle:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    flowTitle:SetTextColor(0.5, 0.8, 1)
    flowTitle:SetText(Cat2.L("流程"))

    editor.flowCountText = editor.flowPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editor.flowCountText:SetPoint("LEFT", flowTitle, "RIGHT", 8, 0)
    editor.flowCountText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    editor.flowCountText:SetTextColor(0.65, 0.72, 0.84)

    local rulesButton = CreateFrame("Button", nil, editor.flowPanel)
    rulesButton:SetWidth(54)
    rulesButton:SetHeight(21)
    rulesButton:SetPoint("TOPRIGHT", editor.flowPanel, "TOPRIGHT", -12, -7)
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

    editor.flowScroll, editor.flowContent, editor.flowSlider = CreateScrollArea(editor.flowPanel)
    editor.flowScroll:SetWidth(342)
    editor.flowContent:SetWidth(340)
    -- 两侧内容区左边距与滚动条右边距均为12；流程额外的24宽度用于序号，卡片距滚动条均为4。
    -- 顶部与右侧功能卡槽一致，卡片和滚动条共同下移。
    editor.flowScroll:SetPoint("TOPLEFT", editor.flowPanel, "TOPLEFT", 12, -38)
    editor.flowSlider:SetPoint("TOPRIGHT", editor.flowPanel, "TOPRIGHT", -12, -38)

    -- 空白流程区域的槽位引导线；卡片会覆盖已占用位置，只在空槽中露出。
    local guideIndex = 1
    while guideIndex <= 7 do
        local guideLine = editor.flowContent:CreateTexture(nil, "BACKGROUND")
        guideLine:SetTexture("Interface\\Buttons\\WHITE8X8")
        guideLine:SetWidth(304)
        guideLine:SetHeight(1)
        -- 横线靠近槽位底部但位于卡片范围内，放入对应卡片后会被完整覆盖。
        guideLine:SetPoint("TOPLEFT", editor.flowContent, "TOPLEFT", 30, -guideIndex * 50 + 6)
        guideLine:SetVertexColor(0.3, 0.42, 0.56, 0.22)
        guideIndex = guideIndex + 1
    end

    editor.emptyHint = editor.flowContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editor.emptyHint:SetPoint("CENTER", editor.flowContent, "CENTER", 12, 0)
    editor.emptyHint:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    editor.emptyHint:SetTextColor(0.65, 0.65, 0.65)
    editor.emptyHint:SetJustifyH("CENTER")
    editor.emptyHint:SetText(Cat2.L("将右侧步骤拖到这里\n支持鼠标左键或右键拖动\n拖动左侧步骤可以调整顺序"))

    editor.dropIndicator = CreateFrame("Frame", nil, editor.flowContent)
    editor.dropIndicator:SetWidth(316)
    editor.dropIndicator:SetHeight(3)
    ApplyFlatBackdrop(editor.dropIndicator, 1, 0.75, 0.15, 1)
    editor.dropIndicator:Hide()

    editor.availablePanel = CreateFrame("Frame", nil, editor.mainWindow)
    editor.availablePanel:SetWidth(356)
    editor.availablePanel:SetHeight(438)
    editor.availablePanel:SetPoint("TOPRIGHT", editor.mainWindow, "TOPRIGHT", -16, -48)
    ApplyFlatBackdrop(editor.availablePanel, 0.07, 0.08, 0.12, 0.9)
    editor.availablePanel:EnableMouse(true)
    editor.availablePanel:SetScript("OnMouseDown", function()
    end)
    editor.availablePanel:SetScript("OnMouseUp", function()
    end)

    editor.centerGap = CreateFrame("Button", nil, editor.mainWindow)
    editor.centerGap:SetWidth(16)
    editor.centerGap:SetHeight(438)
    editor.centerGap:SetPoint("TOPLEFT", editor.flowPanel, "TOPRIGHT", 0, 0)
    editor.centerGap:SetFrameStrata("HIGH")
    editor.centerGap:SetFrameLevel(50)
    editor.centerGap:EnableMouse(true)
    editor.centerGap:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local gapHitArea = editor.centerGap:CreateTexture(nil, "BACKGROUND")
    gapHitArea:SetAllPoints()
    gapHitArea:SetTexture("Interface\\Buttons\\WHITE8X8")
    gapHitArea:SetVertexColor(0, 0, 0, 0.01)
    editor.centerGap:SetScript("OnMouseDown", function()
    end)
    editor.centerGap:SetScript("OnMouseUp", function()
    end)
    editor.centerGap:SetScript("OnClick", function()
    end)

    editor.CreateFilterTab(editor.availablePanel, "common", Cat2.L("通用"), 8, 40)
    editor.CreateFilterTab(editor.availablePanel, "item", Cat2.L("药水"), 92, 40)
    editor.CreateFilterTab(editor.availablePanel, "spec1", Cat2.L(specializationNames[1]), 134, 66)
    editor.CreateFilterTab(editor.availablePanel, "spec2", Cat2.L(specializationNames[2]), 202, 72)
    editor.CreateFilterTab(editor.availablePanel, "spec3", Cat2.L(specializationNames[3]), 276, 72)
    editor.CreateFilterTab(editor.availablePanel, "spec4", specializationNames[4] and Cat2.L(specializationNames[4]) or Cat2.L("第四系"), 299, 55)
    editor.CreateFilterTab(editor.availablePanel, "logic", Cat2.L("逻辑"), 50, 40)
    -- 复用主窗口构造函数原本已经捕获的 Cat2，不能再新增 ui 这个 upvalue。
    Cat2.UI.LayoutFilterTabs(classFile)
    editor.RefreshFilterTabs()

    editor.availableScroll, editor.availableContent, editor.availableSlider = CreateScrollArea(editor.availablePanel)
    editor.availableScroll:SetHeight(392)
    editor.availableSlider:SetHeight(392)
    editor.availableScroll:SetPoint("TOPLEFT", editor.availablePanel, "TOPLEFT", 12, -38)
    editor.availableSlider:SetPoint("TOPRIGHT", editor.availablePanel, "TOPRIGHT", -12, -38)
    editor.availableContent:SetHeight(392)

    -- 底部操作区只保留导入与导出；调试窗改由 /cat2 debug 控制。
    editor.footerActions = CreateFrame("Frame", nil, editor.mainWindow)
    editor.footerActions:SetWidth(188)
    editor.footerActions:SetHeight(30)
    editor.footerActions:SetPoint("BOTTOMRIGHT", editor.mainWindow, "BOTTOMRIGHT", -16, 12)

    local function CreateFooterButton(labelText, offsetX, onClick)
        local button = CreateFrame("Button", nil, editor.footerActions)
        button:SetWidth(90)
        button:SetHeight(28)
        button:SetPoint("LEFT", editor.footerActions, "LEFT", offsetX, 0)
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
    local commandCopyBox = CreateFrame("EditBox", nil, editor.mainWindow)
    editor.mainWindow.commandCopyBox = commandCopyBox
    commandCopyBox:SetWidth(136)
    commandCopyBox:SetHeight(28)
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
    editor.profileActions = CreateFrame("Frame", nil, editor.mainWindow)
    -- 控件宽度依次为28、52、146、42、42，控件之间统一留4。
    editor.profileActions:SetWidth(326)
    editor.profileActions:SetHeight(30)
    editor.profileActions:SetPoint("BOTTOMLEFT", editor.mainWindow, "BOTTOMLEFT", 16, 12)
    -- 宏指令属于当前配置，紧接配置操作区排列。
    commandCopyBox:SetPoint("LEFT", editor.profileActions, "RIGHT", 4, 0)
    ui.CreateProfileMacroIcon(editor.mainWindow, commandCopyBox)

    local profileMenuEntries = {}

    local profileSelect = CreateFrame("Button", nil, editor.profileActions)
    profileSelect:SetWidth(146)
    profileSelect:SetHeight(28)
    profileSelect:SetPoint("LEFT", editor.profileActions, "LEFT", 88, 0)
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

    local profileMenu = CreateFrame("Frame", nil, editor.profileActions)
    profileMenu:SetWidth(146)
    profileMenu:SetHeight(28)
    profileMenu:SetPoint("BOTTOMLEFT", profileSelect, "TOPLEFT", 0, 3)
    profileMenu:SetFrameLevel(editor.mainWindow:GetFrameLevel() + 30)
    ApplyFlatBackdrop(profileMenu, 0.04, 0.06, 0.1, 1)
    profileMenu:Hide()

    local function UpdateProfileText()
        local activeProfile = editor.runtimeConfigurations.profiles[editor.runtimeConfigurations.activeProfileId]
        profileText:SetText(activeProfile.name)
        SetCommandCopyText(activeProfile.name)
        ui.RefreshProfileMacroIcon()
        editor.RefreshShortcutToggleText()
    end
    editor.mainWindow.UpdateProfileText = UpdateProfileText

    -- 新建与改名共用同一套名称规则；改名时允许保留当前配置自己的名称。
    local function ValidateProfileName(value, ignoredProfileId)
        local characterCount = editor.CountTextCharacters(value)
        if characterCount < 2 or characterCount > 12 then
            return false, Cat2.L("名称长度必须为 2-12 个汉字或字符。")
        end
        -- debug 已由 /cat2 debug 用作调试指令，不能再作为配置名称。
        if string.lower(value) == "debug" then
            return false, Cat2.L("debug 是调试指令，不能作为配置名称。")
        end
        local checkIndex = 1
        local checkTotal = table.getn(editor.runtimeConfigurations.profileOrder)
        while checkIndex <= checkTotal do
            local checkId = editor.runtimeConfigurations.profileOrder[checkIndex]
            if checkId ~= ignoredProfileId and editor.runtimeConfigurations.profiles[checkId].name == value then
                return false, Cat2.L("已经存在同名配置。")
            end
            checkIndex = checkIndex + 1
        end
        return true
    end

    -- 菜单条目只创建一次并循环复用；旧客户端无法真正销毁 Frame，不能每次打开都重新创建。
    -- 点击时按条目当前绑定的配置 ID 读取仓库，配置已被删除时只关闭旧菜单。
    local function BindProfileMenuEntry(entry, entryText)
        entry:SetScript("OnEnter", function()
            entryText:SetTextColor(0.5, 0.82, 1)
        end)
        entry:SetScript("OnLeave", function()
            if entry.profileId == editor.runtimeConfigurations.activeProfileId then
                entryText:SetTextColor(1, 0.82, 0.2)
            else
                entryText:SetTextColor(0.76, 0.82, 0.9)
            end
        end)
        entry:SetScript("OnClick", function()
            local entryProfileId = entry.profileId
            local clickedProfile = editor.runtimeConfigurations.profiles[entryProfileId]
            if not clickedProfile then
                profileMenu:Hide()
                return
            end
            editor.runtimeConfigurations.activeProfileId = entryProfileId
            editor.selectedSteps = clickedProfile.steps
            editor.selectedFlowIndex = nil
            UpdateProfileText()
            profileMenu:Hide()
            editor.RedrawFlow()
        end)
    end

    local function RebuildProfileMenu()
        local oldIndex = 1
        local oldTotal = table.getn(profileMenuEntries)
        while oldIndex <= oldTotal do
            profileMenuEntries[oldIndex]:Hide()
            oldIndex = oldIndex + 1
        end

        local profileIndex = 1
        local profileTotal = table.getn(editor.runtimeConfigurations.profileOrder)
        profileMenu:SetHeight(profileTotal * 26 + 4)
        while profileIndex <= profileTotal do
            local profileId = editor.runtimeConfigurations.profileOrder[profileIndex]
            local profile = editor.runtimeConfigurations.profiles[profileId]
            local entry = profileMenuEntries[profileIndex]
            if not entry then
                entry = CreateFrame("Button", nil, profileMenu)
                entry:SetWidth(140)
                entry:SetHeight(24)

                local entryText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                entryText:SetPoint("LEFT", entry, "LEFT", 7, 0)
                entryText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
                entry.text = entryText
                BindProfileMenuEntry(entry, entryText)
                profileMenuEntries[profileIndex] = entry
            end
            entry.profileId = profileId
            entry:ClearAllPoints()
            entry:SetPoint("TOPLEFT", profileMenu, "TOPLEFT", 3, -2 - (profileIndex - 1) * 26)

            local entryText = entry.text
            entryText:SetText(profile.name)
            if profileId == editor.runtimeConfigurations.activeProfileId then
                entryText:SetTextColor(1, 0.82, 0.2)
            else
                entryText:SetTextColor(0.76, 0.82, 0.9)
            end

            entry:Show()
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
        local button = CreateFrame("Button", nil, editor.profileActions)
        button:SetWidth(buttonWidth or 42)
        button:SetHeight(28)
        button:SetPoint("LEFT", editor.profileActions, "LEFT", offsetX, 0)
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

    local legacyCreateProfileButton = CreateProfileActionButton("+", 238, function()
        profileMenu:Hide()
        ShowTextInput(Cat2.L("新建配置（2-12个字符）"), "", function(value)
            return ValidateProfileName(value, nil)
        end, function(value)
            local newId = editor.runtimeConfigurations.nextProfileId
            editor.runtimeConfigurations.nextProfileId = newId + 1
            editor.runtimeConfigurations.profiles[newId] = {
                id = newId,
                name = value,
                steps = {}
            }
            table.insert(editor.runtimeConfigurations.profileOrder, newId)
            editor.runtimeConfigurations.activeProfileId = newId
            editor.selectedSteps = editor.runtimeConfigurations.profiles[newId].steps
            editor.selectedFlowIndex = nil
            UpdateProfileText()
            editor.RedrawFlow()
        end)
    end)
    local legacyDeleteProfileButton = CreateProfileActionButton("-", 284, function()
        local profileTotal = table.getn(editor.runtimeConfigurations.profileOrder)
        if profileTotal <= 1 then
            ShowNotice(Cat2.L("至少需要保留一个配置，不能删除当前配置。"))
            return
        end
        profileMenu:Hide()
        local deleteId = editor.runtimeConfigurations.activeProfileId
        local deleteProfile = editor.runtimeConfigurations.profiles[deleteId]
        local deleteName = deleteProfile.name
        ShowConfirm(Cat2.L("确定删除配置「") .. deleteName .. Cat2.L("」吗？\n此操作无法撤销。"), function()
            if not editor.runtimeConfigurations.profiles[deleteId] then
                return
            end
            local deleteOrderIndex = nil
            local orderIndex = 1
            local orderTotal = table.getn(editor.runtimeConfigurations.profileOrder)
            while orderIndex <= orderTotal do
                if editor.runtimeConfigurations.profileOrder[orderIndex] == deleteId then
                    deleteOrderIndex = orderIndex
                    break
                end
                orderIndex = orderIndex + 1
            end
            if not deleteOrderIndex then
                return
            end
            table.remove(editor.runtimeConfigurations.profileOrder, deleteOrderIndex)
            if Cat2.RemoveProfileShortcutWindowSettings then
                Cat2.RemoveProfileShortcutWindowSettings(deleteId)
            end
            editor.runtimeConfigurations.profiles[deleteId] = nil
            local remainingTotal = table.getn(editor.runtimeConfigurations.profileOrder)
            if deleteOrderIndex > remainingTotal then
                deleteOrderIndex = remainingTotal
            end
            local nextActiveId = editor.runtimeConfigurations.profileOrder[deleteOrderIndex]
            editor.runtimeConfigurations.activeProfileId = nextActiveId
            editor.selectedSteps = editor.runtimeConfigurations.profiles[nextActiveId].steps
            editor.selectedFlowIndex = nil
            UpdateProfileText()
            editor.RedrawFlow()
        end)
    end)
    -- 快捷窗属于当前配置，将开关放在配置管理入口旁边，比标题栏更容易理解。
    minimizeButton:ClearAllPoints()
    minimizeButton:SetWidth(28)
    minimizeButton:SetHeight(28)
    minimizeButton:SetPoint("LEFT", editor.profileActions, "LEFT", 0, 0)

    CreateProfileActionButton(Cat2.L("管理"), 32, function()
        if Cat2.UI.ToggleProfileManager then
            Cat2.UI.ToggleProfileManager()
        elseif DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage(Cat2.L("|cffff5555Cat2：配置管理模块尚未加载，请完整重启游戏。|r"))
        end
    end, 52)
    UpdateProfileText()

    editor.CreateDragGhost()
    editor.mainWindow:SetScript("OnUpdate", function()
        editor.UpdateDragGhost()
    end)
    editor.mainWindow:SetScript("OnShow", function()
        if editor.mainWindow.Raise then
            editor.mainWindow:Raise()
        end
    end)
    Cat2.UI.RedrawFlow()
    Cat2.UI.RedrawAvailable()
    -- 必须最后写入；此前任何异常都应被识别为未完成构造。
    editor.mainWindow.cat2ConstructionComplete = true
end

-- 供小地图入口调用的显示切换函数。
local function ToggleMainWindow()
    CreateMainWindow()
    if editor.mainWindow:IsVisible() then
        if editor.mainWindow.classPreviewMenu then
            editor.mainWindow.classPreviewMenu:Hide()
        end
        editor.mainWindow:Hide()
    else
        editor.mainWindow:Show()
        UpdateScrollBar(editor.flowScroll, editor.flowSlider, editor.flowContent:GetHeight())
        UpdateScrollBar(editor.availableScroll, editor.availableSlider, editor.availableContent:GetHeight())
    end
end

ui.ToggleMainWindow = ToggleMainWindow

-- 聊天指令等入口只需要确保主界面打开，不能沿用 Toggle 导致已显示时反向关闭。
function ui.ShowMainWindow()
    CreateMainWindow()
    if not editor.mainWindow:IsVisible() then
        editor.mainWindow:Show()
    end
    UpdateScrollBar(editor.flowScroll, editor.flowSlider, editor.flowContent:GetHeight())
    UpdateScrollBar(editor.availableScroll, editor.availableSlider, editor.availableContent:GetHeight())
end
