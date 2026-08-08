-- Cat2 用户规则说明窗口。
-- 内容只描述用户操作与流程行为，不包含卡片编写和内部实现细节。
Cat2.UI = Cat2.UI or {}
local ui = Cat2.UI
local rulesWindow = nil

local function CreateRuleButton(parent, labelText, width)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(26)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")
    ui.ApplyFlatBackdrop(button, 0.08, 0.18, 0.27, 1)

    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER", button, "CENTER", 0, 0)
    text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    text:SetTextColor(0.78, 0.9, 1)
    text:SetText(labelText)

    button:SetScript("OnEnter", function()
        button:SetBackdropColor(0.12, 0.4, 0.58, 1)
        button:SetBackdropBorderColor(0.45, 0.82, 1, 1)
        text:SetTextColor(1, 0.84, 0.28)
    end)
    button:SetScript("OnLeave", function()
        button:SetBackdropColor(0.08, 0.18, 0.27, 1)
        button:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
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
    button.text = text
    return button
end

local function AddSeparator(parent, offsetY)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", 22, offsetY)
    line:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -22, offsetY)
    line:SetVertexColor(0.28, 0.4, 0.55, 0.55)
end

local function AddSection(parent, titleText, bodyText, offsetY)
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, offsetY)
    title:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    title:SetTextColor(0.52, 0.82, 1)
    title:SetText(titleText)

    local body = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    body:SetPoint("TOPLEFT", parent, "TOPLEFT", 34, offsetY - 24)
    body:SetWidth(380)
    body:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    body:SetTextColor(0.78, 0.82, 0.88)
    body:SetJustifyH("LEFT")
    body:SetSpacing(3)
    body:SetText(bodyText)
end

local function HideRulesWindow()
    if rulesWindow then
        rulesWindow:Hide()
    end
end

local function CreateRulesWindow()
    if rulesWindow then
        return
    end

    rulesWindow = CreateFrame("Frame", "Cat2RulesWindow", UIParent)
    rulesWindow:SetWidth(450)
    rulesWindow:SetHeight(430)
    rulesWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 18)
    rulesWindow:SetFrameStrata("FULLSCREEN_DIALOG")
    rulesWindow:SetFrameLevel(130)
    rulesWindow:EnableMouse(true)
    rulesWindow:EnableKeyboard(true)
    rulesWindow:SetMovable(true)
    rulesWindow:SetClampedToScreen(true)
    rulesWindow:RegisterForDrag("LeftButton")
    ui.ApplyFlatBackdrop(rulesWindow, 0.04, 0.05, 0.08, 0.99)
    rulesWindow:SetScript("OnDragStart", function()
        rulesWindow:StartMoving()
    end)
    rulesWindow:SetScript("OnDragStop", function()
        rulesWindow:StopMovingOrSizing()
    end)
    rulesWindow:SetScript("OnHide", function()
        ui.HideMainWindowDim()
    end)
    rulesWindow:SetScript("OnKeyDown", function()
        if arg1 == "ESCAPE" then
            HideRulesWindow()
        end
    end)

    local heading = rulesWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    heading:SetPoint("TOPLEFT", rulesWindow, "TOPLEFT", 20, -17)
    heading:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    heading:SetTextColor(1, 0.78, 0.16)
    heading:SetText("Cat2 使用规则")

    local closeX = CreateRuleButton(rulesWindow, "X", 28)
    closeX:SetPoint("TOPRIGHT", rulesWindow, "TOPRIGHT", -12, -11)
    closeX:SetScript("OnClick", HideRulesWindow)

    AddSeparator(rulesWindow, -50)
    AddSection(rulesWindow, "流程顺序", "流程从上向下执行。拖动左侧卡片可以调整顺序。\n部分卡片成功执行后会停止本轮流程，重要卡片请放在合适位置。", -66)
    AddSeparator(rulesWindow, -130)
    AddSection(rulesWindow, "卡片状态", "点击左侧卡片后，可以暂停、恢复、隐藏或删除。\n被动卡片|cffb880f0（紫色）|r会影响整个流程；暂停后，它的被动效果不会生效。", -146)
    AddSeparator(rulesWindow, -210)
    AddSection(rulesWindow, "快捷小窗", "显示在小窗中的卡片可以随时点击暂停或恢复。\n主界面与快捷小窗相互独立，关闭主界面不会关闭小窗。", -226)
    AddSeparator(rulesWindow, -290)
    AddSection(rulesWindow, "配置使用", "输入 |cffff4fa3/cat2 配置名|r 执行对应流程。配置按角色保存。\n导入配置时会检查职业；同名配置需要确认后才能覆盖。", -306)

    local closeButton = CreateRuleButton(rulesWindow, "关闭", 96)
    closeButton:SetPoint("BOTTOM", rulesWindow, "BOTTOM", 0, 13)
    closeButton:SetScript("OnClick", HideRulesWindow)
    rulesWindow:Hide()
end

function ui.ShowRulesWindow()
    if ui.CloseAllDialogs then
        ui.CloseAllDialogs()
    end
    if ui.HideSettingsWindow then
        ui.HideSettingsWindow()
    end
    CreateRulesWindow()
    ui.ShowMainWindowDim()
    rulesWindow:Show()
end

function ui.HideRulesWindow()
    HideRulesWindow()
end
