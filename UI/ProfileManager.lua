-- Cat2 配置与快捷窗管理界面。
-- 此模块刻意与 FlowEditor 分离：配置改名和每个配置专属快捷窗的设置集中在这里，
-- 避免继续扩大主流程编辑器的职责。
Cat2.UI = Cat2.UI or {}
local ui = Cat2.UI
local ApplyFlatBackdrop = ui.ApplyFlatBackdrop

local CreateScrollArea = ui.CreateScrollArea
local UpdateScrollBar = ui.UpdateScrollBar
local SetScrollPosition = ui.SetScrollPosition

local managerWindow = nil
local selectedProfileId = nil
local profileEntries = {}

local function CreateButton(parent, label, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(height)
    ApplyFlatBackdrop(button, 0.08, 0.18, 0.27, 0.98)
    button.baseRed = 0.08
    button.baseGreen = 0.18
    button.baseBlue = 0.27
    button.hoverRed = 0.12
    button.hoverGreen = 0.4
    button.hoverBlue = 0.58
    button.downRed = 0.04
    button.downGreen = 0.1
    button.downBlue = 0.16
    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER", button, "CENTER", 0, 0)
    text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    text:SetTextColor(0.78, 0.9, 1)
    text:SetText(label)
    button.text = text
    button.ApplyBaseColor = function()
        button:SetBackdropColor(button.baseRed, button.baseGreen, button.baseBlue, 0.98)
    end
    button.SetColors = function(baseRed, baseGreen, baseBlue, hoverRed, hoverGreen, hoverBlue, downRed, downGreen, downBlue)
        button.baseRed = baseRed
        button.baseGreen = baseGreen
        button.baseBlue = baseBlue
        button.hoverRed = hoverRed
        button.hoverGreen = hoverGreen
        button.hoverBlue = hoverBlue
        button.downRed = downRed
        button.downGreen = downGreen
        button.downBlue = downBlue
    end
    button:SetScript("OnEnter", function()
        button:SetBackdropColor(button.hoverRed, button.hoverGreen, button.hoverBlue, 1)
        text:SetTextColor(1, 0.84, 0.28)
    end)
    button:SetScript("OnLeave", function()
        button:ApplyBaseColor()
        text:SetTextColor(0.78, 0.9, 1)
    end)
    -- 所有管理按钮统一提供按下反馈：颜色压暗且文字轻微下移，抬起后回到悬停状态。
    button:SetScript("OnMouseDown", function()
        button:SetBackdropColor(button.downRed, button.downGreen, button.downBlue, 1)
        text:ClearAllPoints()
        text:SetPoint("CENTER", button, "CENTER", 1, -1)
    end)
    button:SetScript("OnMouseUp", function()
        button:SetBackdropColor(button.hoverRed, button.hoverGreen, button.hoverBlue, 1)
        text:ClearAllPoints()
        text:SetPoint("CENTER", button, "CENTER", 0, 0)
    end)
    return button
end

local function CountVisibleWindows()
    local repository = Cat2.RuntimeConfigurations
    local total = 0
    local index = 1
    while index <= table.getn(repository.profileOrder) do
        local profileId = repository.profileOrder[index]
        local visible = Cat2.GetProfileShortcutWindowSettings(profileId)
        if visible then
            total = total + 1
        end
        index = index + 1
    end
    return total
end

local function ValidateProfileName(value, ignoredProfileId)
    local length = string.len(value or "")
    if length < 2 or length > 36 then
        return false, Cat2.L("名称长度必须为 2-12 个汉字或字符。")
    end
    -- debug 已由 /cat2 debug 用作调试指令，不能再作为配置名称。
    if string.lower(value) == "debug" then
        return false, Cat2.L("debug 是调试指令，不能作为配置名称。")
    end
    local repository = Cat2.RuntimeConfigurations
    local index = 1
    while index <= table.getn(repository.profileOrder) do
        local profileId = repository.profileOrder[index]
        local profile = repository.profiles[profileId]
        if profileId ~= ignoredProfileId and profile and profile.name == value then
            return false, Cat2.L("已经存在同名配置。")
        end
        index = index + 1
    end
    return true
end

-- 旧版客户端兼容：不用 string.format 的百分号格式化，固定显示一位小数。
local function FormatScale(value)
    local tenths = math.floor(value * 10 + 0.5)
    local integer = math.floor(tenths / 10)
    local decimal = tenths - integer * 10
    return integer .. "." .. decimal
end

local function FormatOpacity(value)
    return math.floor(value * 100 + 0.5) .. "%"
end

local function RefreshManager()
    if not managerWindow then
        return
    end
    Cat2.EnsureConfigurationDataLoaded()
    local repository = Cat2.RuntimeConfigurations
    if not repository.profiles[selectedProfileId] then
        selectedProfileId = repository.activeProfileId
    end
    local profile = repository.profiles[selectedProfileId]
    if not profile then
        return
    end

    local oldIndex = 1
    while oldIndex <= table.getn(profileEntries) do
        profileEntries[oldIndex]:Hide()
        oldIndex = oldIndex + 1
    end
    local index = 1
    local selectedOrderIndex = nil
    while index <= table.getn(repository.profileOrder) do
        local profileId = repository.profileOrder[index]
        local entryProfile = repository.profiles[profileId]
        local entry = profileEntries[index]
        if not entry then
            entry = CreateFrame("Button", nil, managerWindow.listContent)
            entry:SetWidth(148)
            entry:SetHeight(30)
            ApplyFlatBackdrop(entry, 0.06, 0.08, 0.12, 0.94)
            local text = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", entry, "LEFT", 9, 0)
            text:SetPoint("RIGHT", entry, "RIGHT", -6, 0)
            text:SetJustifyH("LEFT")
            text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
            entry.text = text
            entry:SetScript("OnClick", function()
                selectedProfileId = entry.profileId
                if ui.SelectConfigurationProfile then
                    ui.SelectConfigurationProfile(entry.profileId)
                end
                RefreshManager()
            end)
            entry:SetScript("OnEnter", function()
                if entry.profileId ~= selectedProfileId then
                    entry:SetBackdropColor(0.1, 0.2, 0.3, 1)
                end
            end)
            entry:SetScript("OnLeave", function()
                if entry.profileId ~= selectedProfileId then
                    entry:SetBackdropColor(0.06, 0.08, 0.12, 0.94)
                end
            end)
            entry:SetScript("OnMouseDown", function()
                entry.text:ClearAllPoints()
                entry.text:SetPoint("LEFT", entry, "LEFT", 10, -1)
            end)
            entry:SetScript("OnMouseUp", function()
                entry.text:ClearAllPoints()
                entry.text:SetPoint("LEFT", entry, "LEFT", 9, 0)
            end)
            profileEntries[index] = entry
        end
        entry.profileId = profileId
        entry.text:SetText(entryProfile.name)
        entry:ClearAllPoints()
        entry:SetPoint("TOPLEFT", managerWindow.listContent, "TOPLEFT", 1, -1 - (index - 1) * 33)
        if profileId == selectedProfileId then
            selectedOrderIndex = index
            entry:SetBackdropColor(0.1, 0.28, 0.42, 0.98)
            entry.text:SetTextColor(1, 0.84, 0.28)
        else
            entry:SetBackdropColor(0.06, 0.08, 0.12, 0.94)
            entry.text:SetTextColor(0.78, 0.88, 0.96)
        end
        entry:Show()
        index = index + 1
    end

    local contentHeight = table.getn(repository.profileOrder) * 33 + 2
    local minimumHeight = managerWindow.listScroll:GetHeight()
    if contentHeight < minimumHeight then
        contentHeight = minimumHeight
    end
    managerWindow.listContent:SetHeight(contentHeight)
    UpdateScrollBar(managerWindow.listScroll, managerWindow.listSlider, contentHeight)

    -- 新建配置或从外部切换配置后，保证当前项自动进入可见区域。
    if selectedOrderIndex then
        local entryTop = (selectedOrderIndex - 1) * 33
        local entryBottom = entryTop + 30
        local scrollTop = managerWindow.listScroll:GetVerticalScroll()
        local scrollBottom = scrollTop + managerWindow.listScroll:GetHeight()
        if entryTop < scrollTop then
            SetScrollPosition(managerWindow.listScroll, managerWindow.listSlider, entryTop)
        elseif entryBottom > scrollBottom then
            SetScrollPosition(managerWindow.listScroll, managerWindow.listSlider, entryBottom - managerWindow.listScroll:GetHeight())
        end
    end

    managerWindow.profileName:SetText(profile.name)
    if managerWindow.UpdateCommandText then
        managerWindow.UpdateCommandText(profile.name)
    end
    local visible, iconLimit, direction, _, _, scale, opacity, locked, showCooldown = Cat2.GetProfileShortcutWindowSettings(selectedProfileId)
    managerWindow.visible = visible
    managerWindow.iconLimit = iconLimit
    managerWindow.direction = direction
    managerWindow.scale = scale
    managerWindow.opacity = opacity
    managerWindow.locked = locked
    managerWindow.showCooldown = showCooldown
    managerWindow.visibilityButton.text:SetText(visible and Cat2.L("已开启") or Cat2.L("已关闭"))
    if visible then
        managerWindow.visibilityButton.SetColors(0.08, 0.3, 0.18, 0.14, 0.45, 0.28, 0.04, 0.16, 0.09)
    else
        managerWindow.visibilityButton.SetColors(0.32, 0.07, 0.08, 0.48, 0.1, 0.12, 0.18, 0.03, 0.04)
    end
    managerWindow.visibilityButton:ApplyBaseColor()
    managerWindow.limitText:SetText(iconLimit)
    managerWindow.scaleText:SetText(FormatScale(scale))
    managerWindow.opacityText:SetText(FormatOpacity(opacity))
    managerWindow.lockButton.text:SetText(locked and Cat2.L("解除锁定") or Cat2.L("位置锁定"))
    if locked then
        managerWindow.lockButton.SetColors(0.1, 0.28, 0.42, 0.14, 0.4, 0.58, 0.05, 0.16, 0.24)
    else
        managerWindow.lockButton.SetColors(0.08, 0.18, 0.27, 0.12, 0.4, 0.58, 0.04, 0.1, 0.16)
    end
    managerWindow.lockButton:ApplyBaseColor()
    managerWindow.cooldownButton.text:SetText(showCooldown and Cat2.L("显示冷却") or Cat2.L("隐藏冷却"))
    if showCooldown then
        managerWindow.cooldownButton.SetColors(0.08, 0.3, 0.18, 0.14, 0.45, 0.28, 0.04, 0.16, 0.09)
    else
        managerWindow.cooldownButton.SetColors(0.32, 0.07, 0.08, 0.48, 0.1, 0.12, 0.18, 0.03, 0.04)
    end
    managerWindow.cooldownButton:ApplyBaseColor()
    managerWindow.horizontalButton:SetBackdropColor(direction == "horizontal" and 0.12 or 0.08, direction == "horizontal" and 0.4 or 0.18, direction == "horizontal" and 0.58 or 0.27, 0.98)
    managerWindow.verticalButton:SetBackdropColor(direction == "vertical" and 0.12 or 0.08, direction == "vertical" and 0.4 or 0.18, direction == "vertical" and 0.58 or 0.27, 0.98)
    local maximumWindows = 10
    if ui.GetMaximumShortcutWindows then
        maximumWindows = ui.GetMaximumShortcutWindows()
    end
    managerWindow.windowCount:SetText(Cat2.L("已开启快捷窗：") .. CountVisibleWindows() .. " / " .. maximumWindows)
end

local function SaveLayout(visible, iconLimit, direction, scale, opacity, locked, showCooldown)
    if scale == nil then
        scale = managerWindow.scale
    end
    if opacity == nil then
        opacity = managerWindow.opacity
    end
    if locked == nil then
        locked = managerWindow.locked
    end
    if showCooldown == nil then
        showCooldown = managerWindow.showCooldown
    end
    Cat2.SaveProfileShortcutWindowSettings(selectedProfileId, visible, iconLimit, direction, nil, nil, scale, opacity, locked, showCooldown)
    if ui.RedrawMinimizedShortcuts then
        ui.RedrawMinimizedShortcuts()
    end
    RefreshManager()
end

local function CreateManager()
    if managerWindow then
        return
    end
    managerWindow = CreateFrame("Frame", "Cat2ProfileManagerWindow", UIParent)
    managerWindow:SetWidth(600)
    managerWindow:SetHeight(432)
    managerWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    managerWindow:SetFrameStrata("FULLSCREEN_DIALOG")
    managerWindow:SetFrameLevel(120)
    managerWindow:SetMovable(true)
    managerWindow:SetClampedToScreen(true)
    managerWindow:EnableMouse(true)
    managerWindow:RegisterForDrag("LeftButton")
    -- 配置管理是标准可关闭窗口，登记到原生 ESC 列表；快捷小窗不接管 ESC。
    if type(UISpecialFrames) == "table" then
        table.insert(UISpecialFrames, "Cat2ProfileManagerWindow")
    end
    ApplyFlatBackdrop(managerWindow, 0.04, 0.05, 0.08, 0.99)
    managerWindow:SetScript("OnDragStart", function()
        managerWindow:StartMoving()
    end)
    managerWindow:SetScript("OnDragStop", function()
        managerWindow:StopMovingOrSizing()
    end)
    managerWindow:SetScript("OnHide", function()
        if ui.HideMainWindowDim then
            ui.HideMainWindowDim()
        end
    end)

    local title = managerWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", managerWindow, "TOPLEFT", 18, -16)
    title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    title:SetTextColor(1, 0.78, 0.16)
    title:SetText(Cat2.L("配置与快捷窗管理"))

    local close = CreateButton(managerWindow, "X", 26, 24)
    close:SetPoint("TOPRIGHT", managerWindow, "TOPRIGHT", -12, -11)
    close:SetScript("OnClick", function()
        managerWindow:Hide()
    end)

    managerWindow.list = CreateFrame("Frame", nil, managerWindow)
    managerWindow.list:SetWidth(184)
    managerWindow.list:SetHeight(356)
    managerWindow.list:SetPoint("TOPLEFT", managerWindow, "TOPLEFT", 16, -56)
    ApplyFlatBackdrop(managerWindow.list, 0.06, 0.08, 0.12, 0.96)

    local listTitle = managerWindow.list:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    listTitle:SetPoint("TOPLEFT", managerWindow.list, "TOPLEFT", 10, -10)
    listTitle:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    listTitle:SetTextColor(0.5, 0.82, 1)
    listTitle:SetText(Cat2.L("配置列表"))

    -- 标题和底部操作按钮固定，只让中间配置条目滚动。
    managerWindow.listScroll, managerWindow.listContent, managerWindow.listSlider = CreateScrollArea(managerWindow.list)
    managerWindow.listScroll:SetWidth(150)
    managerWindow.listScroll:SetHeight(278)
    managerWindow.listScroll:SetPoint("TOPLEFT", managerWindow.list, "TOPLEFT", 7, -34)
    managerWindow.listContent:SetWidth(148)
    managerWindow.listContent:SetHeight(278)
    managerWindow.listSlider:SetWidth(12)
    managerWindow.listSlider:SetHeight(278)
    managerWindow.listSlider:SetPoint("TOPRIGHT", managerWindow.list, "TOPRIGHT", -7, -34)

    -- 配置的创建与删除集中放在列表底部，避免主界面与管理界面各维护一套入口。
    local createProfileButton = CreateButton(managerWindow.list, Cat2.L("新建配置"), 78, 28)
    createProfileButton:SetPoint("BOTTOMLEFT", managerWindow.list, "BOTTOMLEFT", 7, 8)
    createProfileButton.SetColors(0.06, 0.24, 0.13, 0.1, 0.4, 0.22, 0.03, 0.12, 0.06)
    createProfileButton:ApplyBaseColor()
    createProfileButton:SetScript("OnClick", function()
        if not ui.ShowTextInput then
            return
        end
        managerWindow:Hide()
        ui.ShowTextInput(Cat2.L("新建配置（2-12个字符）"), "", function(value)
            return ValidateProfileName(value, nil)
        end, function(value)
            local repository = Cat2.RuntimeConfigurations
            local newId = repository.nextProfileId
            repository.nextProfileId = newId + 1
            repository.profiles[newId] = {
                id = newId,
                name = value,
                steps = {}
            }
            table.insert(repository.profileOrder, newId)
            repository.activeProfileId = newId
            selectedProfileId = newId
            Cat2.SaveConfigurationData(repository)
            if ui.SelectConfigurationProfile then
                ui.SelectConfigurationProfile(newId)
            end
            if ui.RedrawMinimizedShortcuts then
                ui.RedrawMinimizedShortcuts()
            end
            managerWindow:Show()
            RefreshManager()
        end, Cat2.L("创建"))
    end)

    local deleteProfileButton = CreateButton(managerWindow.list, Cat2.L("删除配置"), 78, 28)
    deleteProfileButton:SetPoint("BOTTOMRIGHT", managerWindow.list, "BOTTOMRIGHT", -7, 8)
    deleteProfileButton.SetColors(0.32, 0.07, 0.08, 0.48, 0.1, 0.12, 0.18, 0.03, 0.04)
    deleteProfileButton:ApplyBaseColor()
    deleteProfileButton:SetScript("OnClick", function()
        local repository = Cat2.RuntimeConfigurations
        if table.getn(repository.profileOrder) <= 1 then
            if ui.ShowNotice then
                ui.ShowNotice(Cat2.L("至少需要保留一个配置，不能删除当前配置。"))
            end
            return
        end
        local deletingProfile = repository.profiles[selectedProfileId]
        if not deletingProfile or not ui.ShowConfirm then
            return
        end
        local deletingName = deletingProfile.name
        ui.ShowConfirm(Cat2.L("确定删除配置「") .. deletingName .. Cat2.L("」吗？\n此操作无法撤销。"), function()
            local orderIndex = 1
            local deletingOrderIndex = nil
            while orderIndex <= table.getn(repository.profileOrder) do
                if repository.profileOrder[orderIndex] == selectedProfileId then
                    deletingOrderIndex = orderIndex
                    break
                end
                orderIndex = orderIndex + 1
            end
            if not deletingOrderIndex then
                return
            end
            local deletedId = selectedProfileId
            table.remove(repository.profileOrder, deletingOrderIndex)
            repository.profiles[deletedId] = nil
            if ui.RemoveShortcutWindow then
                ui.RemoveShortcutWindow(deletedId)
            end
            if Cat2.RemoveProfileShortcutWindowSettings then
                Cat2.RemoveProfileShortcutWindowSettings(deletedId)
            end
            if deletingOrderIndex > table.getn(repository.profileOrder) then
                deletingOrderIndex = table.getn(repository.profileOrder)
            end
            selectedProfileId = repository.profileOrder[deletingOrderIndex]
            repository.activeProfileId = selectedProfileId
            Cat2.SaveConfigurationData(repository)
            if ui.SelectConfigurationProfile then
                ui.SelectConfigurationProfile(selectedProfileId)
            end
            if ui.RedrawMinimizedShortcuts then
                ui.RedrawMinimizedShortcuts()
            end
            RefreshManager()
        end, Cat2.L("删除"))
    end)

    local content = CreateFrame("Frame", nil, managerWindow)
    content:SetWidth(370)
    content:SetHeight(356)
    content:SetPoint("TOPRIGHT", managerWindow, "TOPRIGHT", -16, -56)
    ApplyFlatBackdrop(content, 0.06, 0.08, 0.12, 0.96)

    local profileLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profileLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -16)
    profileLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    profileLabel:SetTextColor(0.72, 0.84, 0.96)
    profileLabel:SetText(Cat2.L("当前配置"))
    managerWindow.profileName = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    managerWindow.profileName:SetPoint("LEFT", profileLabel, "RIGHT", 12, 0)
    managerWindow.profileName:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    managerWindow.profileName:SetTextColor(1, 0.82, 0.2)

    local rename = CreateButton(content, Cat2.L("改名"), 56, 24)
    rename:SetPoint("TOPRIGHT", content, "TOPRIGHT", -14, -11)
    rename:SetScript("OnClick", function()
        local repository = Cat2.RuntimeConfigurations
        local profile = repository.profiles[selectedProfileId]
        if not profile or not ui.ShowTextInput then
            return
        end
        managerWindow:Hide()
        ui.ShowTextInput(Cat2.L("配置改名（2-12个字符）"), profile.name, function(value)
            return ValidateProfileName(value, selectedProfileId)
        end, function(value)
            local current = Cat2.RuntimeConfigurations.profiles[selectedProfileId]
            if not current then
                return
            end
            current.name = value
            Cat2.SaveConfigurationData(Cat2.RuntimeConfigurations)
            -- 主界面的下拉名称和宏命令框依赖当前配置名，需要与快捷窗标题同时刷新。
            if ui.SelectConfigurationProfile then
                ui.SelectConfigurationProfile(selectedProfileId)
            end
            if ui.RedrawMinimizedShortcuts then
                ui.RedrawMinimizedShortcuts()
            end
            managerWindow:Show()
            RefreshManager()
        end, Cat2.L("改名"))
    end)

    local separator = content:CreateTexture(nil, "ARTWORK")
    separator:SetTexture("Interface\\Buttons\\WHITE8X8")
    separator:SetVertexColor(0.22, 0.33, 0.46, 0.9)
    separator:SetPoint("TOPLEFT", content, "TOPLEFT", 14, -49)
    separator:SetPoint("TOPRIGHT", content, "TOPRIGHT", -14, -49)
    separator:SetHeight(1)

    local visibleLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    visibleLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -68)
    visibleLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    visibleLabel:SetTextColor(0.72, 0.84, 0.96)
    visibleLabel:SetText(Cat2.L("快捷窗"))
    managerWindow.visibilityButton = CreateButton(content, Cat2.L("已关闭"), 76, 26)
    managerWindow.visibilityButton:SetPoint("LEFT", visibleLabel, "RIGHT", 18, 0)
    managerWindow.visibilityButton:SetScript("OnClick", function()
        if ui.SelectConfigurationProfile then
            ui.SelectConfigurationProfile(selectedProfileId)
        end
        if ui.SetShortcutWindowVisible then
            ui.SetShortcutWindowVisible(not managerWindow.visible)
        end
        RefreshManager()
    end)
    managerWindow.windowCount = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    managerWindow.windowCount:SetPoint("LEFT", managerWindow.visibilityButton, "RIGHT", 12, 0)
    managerWindow.windowCount:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    managerWindow.windowCount:SetTextColor(0.58, 0.7, 0.82)

    local limitLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    limitLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -104)
    limitLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    limitLabel:SetTextColor(0.72, 0.84, 0.96)
    limitLabel:SetText(Cat2.L("每行或列图标数"))
    local decrease = CreateButton(content, "-", 26, 24)
    decrease:SetPoint("LEFT", limitLabel, "RIGHT", 16, 0)
    managerWindow.limitText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    managerWindow.limitText:SetPoint("LEFT", decrease, "RIGHT", 12, 0)
    managerWindow.limitText:SetWidth(20)
    managerWindow.limitText:SetJustifyH("CENTER")
    managerWindow.limitText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    managerWindow.limitText:SetTextColor(1, 0.82, 0.2)
    local increase = CreateButton(content, "+", 26, 24)
    increase:SetPoint("LEFT", managerWindow.limitText, "RIGHT", 12, 0)
    decrease:SetScript("OnClick", function()
        local value = managerWindow.iconLimit - 1
        if value < 1 then
            value = 1
        end
        SaveLayout(managerWindow.visible, value, managerWindow.direction)
    end)
    increase:SetScript("OnClick", function()
        local value = managerWindow.iconLimit + 1
        if value > 10 then
            value = 10
        end
        SaveLayout(managerWindow.visible, value, managerWindow.direction)
    end)

    local directionLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    directionLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -140)
    directionLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    directionLabel:SetTextColor(0.72, 0.84, 0.96)
    directionLabel:SetText(Cat2.L("排列方向"))
    managerWindow.horizontalButton = CreateButton(content, Cat2.L("横向优先"), 86, 26)
    managerWindow.horizontalButton:SetPoint("LEFT", directionLabel, "RIGHT", 28, 0)
    managerWindow.verticalButton = CreateButton(content, Cat2.L("纵向优先"), 86, 26)
    managerWindow.verticalButton:SetPoint("LEFT", managerWindow.horizontalButton, "RIGHT", 8, 0)
    managerWindow.horizontalButton:SetScript("OnClick", function()
        SaveLayout(managerWindow.visible, managerWindow.iconLimit, "horizontal", managerWindow.scale)
    end)
    managerWindow.verticalButton:SetScript("OnClick", function()
        SaveLayout(managerWindow.visible, managerWindow.iconLimit, "vertical", managerWindow.scale)
    end)

    local scaleLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    scaleLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -176)
    scaleLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    scaleLabel:SetTextColor(0.72, 0.84, 0.96)
    scaleLabel:SetText(Cat2.L("快捷窗缩放"))
    local scaleDecrease = CreateButton(content, "-", 26, 24)
    scaleDecrease:SetPoint("LEFT", scaleLabel, "RIGHT", 40, 0)
    managerWindow.scaleText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    managerWindow.scaleText:SetPoint("LEFT", scaleDecrease, "RIGHT", 12, 0)
    managerWindow.scaleText:SetWidth(30)
    managerWindow.scaleText:SetJustifyH("CENTER")
    managerWindow.scaleText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    managerWindow.scaleText:SetTextColor(1, 0.82, 0.2)
    local scaleIncrease = CreateButton(content, "+", 26, 24)
    scaleIncrease:SetPoint("LEFT", managerWindow.scaleText, "RIGHT", 12, 0)
    scaleDecrease:SetScript("OnClick", function()
        local value = managerWindow.scale - 0.1
        if value < 0.5 then
            value = 0.5
        end
        SaveLayout(managerWindow.visible, managerWindow.iconLimit, managerWindow.direction, value)
    end)
    scaleIncrease:SetScript("OnClick", function()
        local value = managerWindow.scale + 0.1
        if value > 1.8 then
            value = 1.8
        end
        SaveLayout(managerWindow.visible, managerWindow.iconLimit, managerWindow.direction, value)
    end)

    -- 非图标透明度：标题、底纹、按钮边框等界面元素共用同一亮度调节。
    local opacityLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    opacityLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -212)
    opacityLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    opacityLabel:SetTextColor(0.72, 0.84, 0.96)
    opacityLabel:SetText(Cat2.L("非图标透明度"))
    local opacityDecrease = CreateButton(content, "-", 26, 24)
    opacityDecrease:SetPoint("LEFT", opacityLabel, "RIGHT", 40, 0)
    managerWindow.opacityText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    managerWindow.opacityText:SetPoint("LEFT", opacityDecrease, "RIGHT", 12, 0)
    managerWindow.opacityText:SetWidth(42)
    managerWindow.opacityText:SetJustifyH("CENTER")
    managerWindow.opacityText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    managerWindow.opacityText:SetTextColor(1, 0.82, 0.2)
    local opacityIncrease = CreateButton(content, "+", 26, 24)
    opacityIncrease:SetPoint("LEFT", managerWindow.opacityText, "RIGHT", 12, 0)
    opacityDecrease:SetScript("OnClick", function()
        local value = managerWindow.opacity - 0.1
        if value < 0 then
            value = 0
        end
        SaveLayout(managerWindow.visible, managerWindow.iconLimit, managerWindow.direction, managerWindow.scale, value)
    end)
    opacityIncrease:SetScript("OnClick", function()
        local value = managerWindow.opacity + 0.1
        if value > 1 then
            value = 1
        end
        SaveLayout(managerWindow.visible, managerWindow.iconLimit, managerWindow.direction, managerWindow.scale, value)
    end)

    local commandLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    commandLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -247)
    commandLabel:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    commandLabel:SetTextColor(0.72, 0.84, 0.96)
    commandLabel:SetText(Cat2.L("宏命令（点击全选后 Ctrl+C 复制）"))

    local commandBox = CreateFrame("EditBox", nil, content)
    commandBox:SetWidth(278)
    commandBox:SetHeight(26)
    commandBox:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -265)
    commandBox:SetAutoFocus(false)
    commandBox:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    commandBox:SetTextColor(0.68, 0.78, 0.88)
    commandBox:SetTextInsets(8, 8, 0, 0)
    commandBox:SetMaxLetters(64)
    ApplyFlatBackdrop(commandBox, 0.04, 0.06, 0.1, 0.98)
    local commandValue = ""
    local commandUpdating = false
    managerWindow.UpdateCommandText = function(profileName)
        commandValue = "/cat2 " .. profileName
        commandUpdating = true
        commandBox:SetText(commandValue)
        commandUpdating = false
    end
    commandBox:SetScript("OnEditFocusGained", function()
        commandBox:HighlightText()
    end)
    commandBox:SetScript("OnMouseUp", function()
        commandBox:SetFocus()
        commandBox:HighlightText()
    end)
    commandBox:SetScript("OnTextChanged", function()
        if not commandUpdating and commandBox:GetText() ~= commandValue then
            commandUpdating = true
            commandBox:SetText(commandValue)
            commandBox:HighlightText()
            commandUpdating = false
        end
    end)
    commandBox:SetScript("OnEscapePressed", function()
        commandBox:ClearFocus()
        commandBox:HighlightText(0, 0)
    end)
    commandBox:SetScript("OnEnter", function()
        commandBox:SetBackdropColor(0.08, 0.13, 0.2, 1)
        GameTooltip:SetOwner(commandBox, "ANCHOR_TOP")
        GameTooltip:SetText(Cat2.L("当前配置的执行命令"))
        GameTooltip:AddLine(Cat2.L("点击自动全选，再按 Ctrl+C 复制到宏中。"), 0.72, 0.84, 0.96)
        GameTooltip:Show()
    end)
    commandBox:SetScript("OnLeave", function()
        commandBox:SetBackdropColor(0.04, 0.06, 0.1, 0.98)
        GameTooltip:Hide()
    end)

    local reset = CreateButton(content, Cat2.L("还原位置"), 88, 28)
    reset:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 16, 16)
    reset:SetScript("OnClick", function()
        if ui.ResetMinimizedWindowPosition then
            ui.ResetMinimizedWindowPosition(selectedProfileId)
        end
    end)
    managerWindow.lockButton = CreateButton(content, Cat2.L("位置锁定"), 88, 28)
    managerWindow.lockButton:SetPoint("LEFT", reset, "RIGHT", 12, 0)
    managerWindow.lockButton:SetScript("OnClick", function()
        SaveLayout(managerWindow.visible, managerWindow.iconLimit, managerWindow.direction, managerWindow.scale, managerWindow.opacity, not managerWindow.locked)
    end)
    managerWindow.cooldownButton = CreateButton(content, Cat2.L("显示冷却"), 88, 28)
    managerWindow.cooldownButton:SetPoint("LEFT", managerWindow.lockButton, "RIGHT", 12, 0)
    managerWindow.cooldownButton:SetScript("OnClick", function()
        SaveLayout(managerWindow.visible, managerWindow.iconLimit, managerWindow.direction, managerWindow.scale, managerWindow.opacity, managerWindow.locked, not managerWindow.showCooldown)
    end)
    managerWindow:Hide()
end

-- 打开时同步选中主编辑器当前配置；在这里切换配置会同时切换主编辑器，避免出现两个界面指向不同配置。
function ui.ToggleProfileManager()
    CreateManager()
    if managerWindow:IsVisible() then
        managerWindow:Hide()
        return
    end
    if ui.CloseAllDialogs then
        ui.CloseAllDialogs()
    end
    Cat2.EnsureConfigurationDataLoaded()
    selectedProfileId = Cat2.RuntimeConfigurations.activeProfileId
    RefreshManager()
    if ui.ShowMainWindowDim then
        ui.ShowMainWindowDim()
    end
    managerWindow:Show()
end

function ui.HideProfileManager()
    if managerWindow then
        managerWindow:Hide()
    end
end

-- 快捷窗可在管理界面之外被关闭；窗口可见时立即同步开关文字、颜色和数量。
function ui.RefreshProfileManager()
    if managerWindow and managerWindow:IsVisible() then
        RefreshManager()
    end
end
