-- 标题提示、职业选择器及快捷窗开关外观。
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

-- 提示仅覆盖左上角标题和版本，不占用模组状态栏；沿用标题栏拖动操作。
function ui.CreateTitleInfoTooltip(titleBar, titleVersion)
    local region = CreateFrame("Frame", nil, titleBar)
    region:SetHeight(32)
    region:SetPoint("LEFT", titleBar, "LEFT", 0, 0)
    region:SetPoint("RIGHT", titleVersion, "RIGHT", 6, 1)
    region:EnableMouse(true)
    region:RegisterForDrag("LeftButton")
    region:SetScript("OnEnter", function()
        GameTooltip:SetOwner(region, "ANCHOR_BOTTOMLEFT")
        GameTooltip:SetText(Cat2.L("Cat|cffff291a2|r 喵！"), 1, 0.78, 0.16)
        GameTooltip:AddLine(Cat2.L("版本：") .. tostring(Cat2.Version), 0.8, 0.85, 0.92)
        local packageVersion = GetAddOnMetadata("Cat2", "Version")
        if packageVersion then
            GameTooltip:AddLine(Cat2.L("插件版本：") .. packageVersion, 0.65, 0.72, 0.82)
        end
        GameTooltip:AddLine(Cat2.L("发布者：") .. (GetAddOnMetadata("Cat2", "Author") or "妖姬变"), 0.8, 0.85, 0.92)
        GameTooltip:AddLine(Cat2.L("通过卡片自由组合各职业的一键宏执行流程。"), 0.85, 0.87, 0.9, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(Cat2.L("版权与使用说明"), 1, 0.78, 0.16)
        GameTooltip:AddLine(Cat2.L("个人爱好制作，完全免费，不作商业化用途；允许在本插件基础上修改或扩展。"), 0.75, 0.8, 0.87, true)
        GameTooltip:AddLine(Cat2.L("感谢所有参与经验分享、脚本制作、设计与测试的朋友。"), 0.65, 0.72, 0.82, true)
        GameTooltip:Show()
    end)
    region:SetScript("OnLeave", function() GameTooltip:Hide() end)
    region:SetScript("OnHide", function()
        if GameTooltip:IsOwned(region) then GameTooltip:Hide() end
    end)
    region:SetScript("OnDragStart", function()
        GameTooltip:Hide()
        editor.mainWindow:StartMoving()
    end)
    region:SetScript("OnDragStop", function() editor.mainWindow:StopMovingOrSizing() end)
end

-- 创建顶部职业下拉菜单；选择仅改变卡片库预览，不改变真实职业门禁。
function ui.CreateClassPreviewDropdown(parent)
    local selector = CreateFrame("Button", nil, parent)
    selector:SetWidth(96)
    selector:SetHeight(24)
    selector:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -46, -12)
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
    if not editor.mainWindow or not editor.mainWindow.shortcutToggleGlyph then
        return
    end
    local glyph = editor.mainWindow.shortcutToggleGlyph
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
function editor.RefreshShortcutToggleText()
    if not editor.mainWindow or not editor.mainWindow.shortcutToggleGlyph then
        return
    end
    -- 多配置快捷窗不能再依赖旧的单窗口引用，直接读取当前配置的持久化开关状态。
    local visible = false
    if Cat2.RuntimeConfigurations and Cat2.RuntimeConfigurations.activeProfileId and Cat2.GetProfileShortcutWindowSettings then
        visible = Cat2.GetProfileShortcutWindowSettings(Cat2.RuntimeConfigurations.activeProfileId)
    end
    editor.mainWindow.shortcutToggleVisible = visible
    if visible then
        ui.SetShortcutToggleGlyphColor(0.38, 0.82, 1, 0.34)
    else
        ui.SetShortcutToggleGlyphColor(0.42, 0.56, 0.68, 0.08)
    end
end


-- 经 UI 命名空间调用，避免庞大的主窗口构造函数超过旧版 Lua 的 32 个 upvalue 限制。
Cat2.UI.RefreshShortcutToggleText = editor.RefreshShortcutToggleText
