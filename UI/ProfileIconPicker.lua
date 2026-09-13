-- 配置图标选择窗：优先展示配置内图标，支持全部图标分页与恢复自动选择。
-- 自定义图标由 ProfileMacroIcon 按角色、配置 ID 保存，不改动流程卡片。
local ui = Cat2.UI
local picker
local pageSize = 40
local iconTooltipOwner

local function UpdateHover(button)
    if button.showIconPath then
        if button.selected then button.selectionMark:Show() else button.selectionMark:Hide() end
    elseif button.selected then
        button:SetBackdropBorderColor(1, 0.82, 0.2, 1)
    elseif button.hovered and not button.isClose then
        button:SetBackdropBorderColor(0.42, 0.72, 0.9, 1)
    else
        button:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
    end
    if button.isClose then
        if button.pressed then button:SetBackdropColor(0.22, 0.04, 0.04, 1)
        elseif button.hovered then button:SetBackdropColor(0.65, 0.12, 0.12, 1)
        else button:SetBackdropColor(0.35, 0.08, 0.08, 0.98) end
    else
        if button.pressed then button:SetBackdropColor(0.04, 0.09, 0.14, 1)
        elseif button.hovered then button:SetBackdropColor(0.1, 0.24, 0.34, 1)
        else button:SetBackdropColor(0.07, 0.12, 0.18, 1) end
    end
    if button.text then
        button.text:ClearAllPoints()
        button.text:SetPoint("CENTER", button, "CENTER", button.pressed and 1 or 0, button.pressed and -1 or 0)
    end
    if button.showIconPath then
        if button.hovered and button.texture then
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText(button.texture, 1, 1, 1)
            GameTooltip:Show()
            iconTooltipOwner = button
        elseif iconTooltipOwner == button then
            GameTooltip:Hide()
            iconTooltipOwner = nil
        end
    end
end

local function AddHover(button)
    button:SetScript("OnEnter", function() button.hovered = true; UpdateHover(button) end)
    button:SetScript("OnMouseDown", function() button.pressed = true; UpdateHover(button) end)
    button:SetScript("OnMouseUp", function() button.pressed = false; UpdateHover(button) end)
    local function ClearHover() button.hovered = false; button.pressed = false; UpdateHover(button) end
    button:SetScript("OnLeave", ClearHover)
    button:SetScript("OnHide", ClearHover)
end

local function AddIcon(list, seen, texture)
    if type(texture) ~= "string" or texture == "" then return end
    local key = string.lower(string.gsub(texture, "/", "\\"))
    key = string.gsub(key, "%.blp$", "")
    key = string.gsub(key, "%.tga$", "")
    if ui.InvalidProfileIconPaths and ui.InvalidProfileIconPaths[key] then return end
    if not seen[key] then
        seen[key] = true
        table.insert(list, texture)
    end
end

local function BuildIcons(profileId, all)
    local list, seen = {}, {}
    local profile = Cat2.RuntimeConfigurations.profiles[profileId]
    if profile then
        for _, step in ipairs(profile.steps or {}) do
            for _, texture in ipairs(step.icons or {}) do AddIcon(list, seen, texture) end
        end
    end
    -- 当前选择只用于标记，不额外插入列表，避免挤占图标位置。
    if all then
        for _, card in ipairs(Cat2.CardRegistry.Cards) do
            for _, texture in ipairs(card.icons or {}) do AddIcon(list, seen, texture) end
        end
        for index = 1, GetNumMacroIcons() do
            AddIcon(list, seen, GetMacroIconInfo(index))
        end
        for _, name in ipairs(ui.ProfileIconNames or {}) do
            AddIcon(list, seen, "Interface\\Icons\\" .. name)
        end
    end
    return list
end

local function Refresh()
    local profile = Cat2.RuntimeConfigurations.profiles[picker.profileId]
    if not profile then picker:Hide(); return end
    picker.title:SetText(profile.name .. " · " .. Cat2.L("选择图标"))
    local total = table.getn(picker.icons)
    local pages = math.max(1, math.ceil(total / pageSize))
    picker.page = math.max(1, math.min(picker.page, pages))
    picker.pageText:SetText(picker.page .. " / " .. pages)
    local selected = ui.GetProfileMacroIcon(picker.profileId)
    for index = 1, pageSize do
        local cell = picker.cells[index]
        local texture = picker.icons[(picker.page - 1) * pageSize + index]
        cell.texture = texture
        if texture then
            cell.icon:SetTexture(texture)
            cell.selected = texture == selected
            UpdateHover(cell)
            cell:Show()
        else
            cell:Hide()
        end
    end
    picker.configTab.text:SetTextColor(picker.all and 0.7 or 1, picker.all and 0.8 or 0.82, picker.all and 0.9 or 0.2)
    picker.allTab.text:SetTextColor(picker.all and 1 or 0.7, picker.all and 0.82 or 0.8, picker.all and 0.2 or 0.9)
end

local function Button(parent, label, width, onClick)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(22)
    ui.ApplyFlatBackdrop(button, 0.07, 0.12, 0.18, 1)
    AddHover(button)
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    button.text:SetTextColor(1, 1, 1)
    button.text:SetText(label)
    button:SetScript("OnClick", onClick)
    return button
end

-- 用纯色纹理绘制箭头，避免旧客户端字体缺少左右三角字符。
local function PageButton(parent, pointsLeft, onClick)
    local button = Button(parent, "", 25, onClick)
    for column = 1, 7 do
        local strip = button:CreateTexture(nil, "OVERLAY")
        strip:SetTexture(1, 1, 1, 1)
        strip:SetWidth(1)
        strip:SetHeight(2 * (pointsLeft and column or (8 - column)))
        strip:SetPoint("CENTER", button, "CENTER", column - 4, 0)
    end
    return button
end

local function CreatePicker(parent)
    picker = CreateFrame("Frame", nil, parent)
    ui.ProfileIconPicker = picker
    picker:SetWidth(380)
    picker:SetHeight(320)
    picker:SetFrameStrata("FULLSCREEN_DIALOG")
    picker:SetFrameLevel(parent:GetFrameLevel() + 210)
    picker:SetClampedToScreen(true)
    picker:EnableMouse(true)
    -- 透明点击层位于弹窗下方，截住外部点击；松开后关闭，避免点击穿透。
    local outsideClick = CreateFrame("Frame", nil, parent)
    outsideClick:SetAllPoints(UIParent)
    outsideClick:SetFrameStrata("FULLSCREEN_DIALOG")
    outsideClick:SetFrameLevel(picker:GetFrameLevel() - 1)
    outsideClick:EnableMouse(true)
    outsideClick:SetScript("OnMouseUp", function() picker:Hide() end)
    outsideClick:Hide()
    picker:SetScript("OnShow", function()
        ui.ShowMainWindowDim()
        outsideClick:Show()
    end)
    picker:SetScript("OnHide", function()
        outsideClick:Hide()
        ui.HideMainWindowDim()
        if iconTooltipOwner then GameTooltip:Hide(); iconTooltipOwner = nil end
    end)
    ui.ApplyFlatBackdrop(picker, 0.04, 0.06, 0.1, 1)
    picker.title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    picker.title:SetPoint("TOPLEFT", picker, "TOPLEFT", 10, -9)
    picker.title:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    picker.title:SetTextColor(1, 0.82, 0.2)
    local close = Button(picker, "X", 24, function() picker:Hide() end)
    close:SetHeight(24)
    close.isClose = true
    close.text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    close.text:SetTextColor(1, 0.82, 0.82)
    UpdateHover(close)
    close:SetPoint("TOPRIGHT", picker, "TOPRIGHT", -7, -5)
    local function SelectTab(all)
        picker.all = all
        picker.page = 1
        picker.icons = BuildIcons(picker.profileId, all)
        Refresh()
    end
    picker.configTab = Button(picker, Cat2.L("当前配置"), 84, function() SelectTab(false) end)
    picker.configTab:SetPoint("TOPLEFT", picker, "TOPLEFT", 10, -32)
    picker.allTab = Button(picker, Cat2.L("全部图标"), 84, function() SelectTab(true) end)
    picker.allTab:SetPoint("LEFT", picker.configTab, "RIGHT", 5, 0)
    local auto = Button(picker, Cat2.L("自动选择"), 96, function()
        if ui.SetProfileMacroIcon(picker.profileId, nil) then picker:Hide() end
    end)
    auto:SetPoint("BOTTOMLEFT", picker, "BOTTOMLEFT", 10, 9)
    local previous = PageButton(picker, true, function() picker.page = picker.page - 1; Refresh() end)
    previous:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -100, 9)
    local nextPage = PageButton(picker, false, function() picker.page = picker.page + 1; Refresh() end)
    nextPage:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -10, 9)
    picker.pageText = picker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    picker.pageText:SetPoint("CENTER", picker, "BOTTOMRIGHT", -67, 20)
    picker.pageText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    picker.pageText:SetTextColor(1, 1, 1)
    picker.cells = {}
    for index = 1, pageSize do
        local cell = CreateFrame("Button", nil, picker)
        cell:SetWidth(40)
        cell:SetHeight(40)
        local column = math.mod(index - 1, 8)
        local row = math.floor((index - 1) / 8)
        cell:SetPoint("TOPLEFT", picker, "TOPLEFT", 16 + column * 44, -62 - row * 43)
        -- 图标自带轮廓，不再叠加格子边线；底色仍保留悬停反馈。
        cell:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        cell:SetBackdropColor(0.07, 0.12, 0.18, 1)
        cell.icon = cell:CreateTexture(nil, "ARTWORK")
        cell.icon:SetPoint("TOPLEFT", cell, "TOPLEFT", 2, -2)
        cell.icon:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", -2, 2)
        cell.selectionMark = cell:CreateTexture(nil, "OVERLAY")
        cell.selectionMark:SetWidth(5)
        cell.selectionMark:SetHeight(5)
        cell.selectionMark:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", -2, 2)
        cell.selectionMark:SetTexture(1, 0.82, 0.2, 1)
        cell.selectionMark:Hide()
        cell.showIconPath = true
        AddHover(cell)
        cell:SetScript("OnClick", function()
            if cell.texture and ui.SetProfileMacroIcon(picker.profileId, cell.texture) then picker:Hide() end
        end)
        picker.cells[index] = cell
    end
    picker:EnableMouseWheel(true)
    picker:SetScript("OnMouseWheel", function()
        picker.page = picker.page - (arg1 or 0)
        Refresh()
    end)
    picker:Hide()
end

function ui.HideProfileIconPicker()
    if picker then picker:Hide() end
end

function ui.ToggleProfileIconPicker(parent, anchor, profileId)
    Cat2.EnsureConfigurationDataLoaded()
    if not Cat2.RuntimeConfigurations.profiles[profileId] then return end
    if not picker then CreatePicker(parent) end
    if picker:IsShown() and picker.profileId == profileId then picker:Hide(); return end
    ui.CloseAllDialogs()
    if ui.HideSettingsWindow then ui.HideSettingsWindow() end
    if ui.HideProfileManager then ui.HideProfileManager() end
    GameTooltip:Hide()
    picker.profileId = profileId
    picker.all = false
    picker.page = 1
    picker.icons = BuildIcons(profileId, false)
    picker:ClearAllPoints()
    picker:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, 6)
    Refresh()
    picker:Show()
end
