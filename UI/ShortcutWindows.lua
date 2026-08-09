-- 配置级快捷窗管理：每个配置可独立显示一个图标快捷窗，同时最多十个。
Cat2.UI = Cat2.UI or {}
local ui = Cat2.UI
local ApplyFlatBackdrop = ui.ApplyFlatBackdrop

local maximumShortcutWindows = 10
local shortcutWindows = {}
local titleLightSpeed = 340
local titleLightWidth = 6
local titleLightTrailWidth = 12
local titleLightTrailAlpha = { 0.5, 0.44, 0.38, 0.33, 0.28, 0.23, 0.19, 0.15, 0.12, 0.09, 0.06, 0.03 }

local function StopTitleLight(window)
    window.titleLightActive = false
    if window.titleLight then
        window.titleLight:Hide()
    end
    if window.titleLightTrail then
        local trailIndex = 1
        while trailIndex <= table.getn(window.titleLightTrail) do
            window.titleLightTrail[trailIndex]:Hide()
            trailIndex = trailIndex + 1
        end
    end
end

local function PositionTitleLightTexture(window, texture, left, right, trackStart, trackEnd)
    if left < trackStart then
        left = trackStart
    end
    if right > trackEnd then
        right = trackEnd
    end
    if right <= left then
        texture:Hide()
        return
    end
    texture:ClearAllPoints()
    texture:SetPoint("LEFT", window.titleBar, "LEFT", left, -0.5)
    texture:SetPoint("RIGHT", window.titleBar, "LEFT", right, -0.5)
    texture:Show()
end

local function UpdateTitleLight(window, elapsed)
    if not window.titleLightActive then
        return
    end
    local trackStart = window.titleTrackStart
    local trackEnd = window.titleTrackEnd
    if not trackStart or not trackEnd or trackEnd - trackStart < 20 then
        StopTitleLight(window)
        return
    end

    local halfWidth = titleLightWidth / 2
    window.titleLightCenter = window.titleLightCenter + titleLightSpeed * elapsed
    local visibleLeft = window.titleLightCenter - halfWidth
    local visibleRight = window.titleLightCenter + halfWidth
    if visibleLeft - titleLightTrailWidth >= trackEnd then
        StopTitleLight(window)
        return
    end
    PositionTitleLightTexture(window, window.titleLight, visibleLeft, visibleRight, trackStart, trackEnd)

    -- 光带向右移动，左侧十二个 1 像素层依次变淡，形成连续拖尾。
    local trailIndex = 1
    while trailIndex <= titleLightTrailWidth do
        local trailRight = visibleLeft - trailIndex + 1
        local trailLeft = trailRight - 1
        PositionTitleLightTexture(window, window.titleLightTrail[trailIndex], trailLeft, trailRight, trackStart, trackEnd)
        trailIndex = trailIndex + 1
    end
end

function ui.GetMaximumShortcutWindows()
    return maximumShortcutWindows
end

local function GetProfile(profileId)
    local repository = Cat2.RuntimeConfigurations
    if not repository or not repository.profiles then
        return nil
    end
    return repository.profiles[profileId]
end

local function CountVisibleShortcutWindows(excludedProfileId)
    local repository = Cat2.RuntimeConfigurations
    if not repository then
        return 0
    end
    local total = 0
    local index = 1
    local count = table.getn(repository.profileOrder)
    while index <= count do
        local profileId = repository.profileOrder[index]
        if profileId ~= excludedProfileId then
            local visible = Cat2.GetProfileShortcutWindowSettings(profileId)
            if visible then
                total = total + 1
            end
        end
        index = index + 1
    end
    return total
end

local function SaveWindowPosition(window)
    local visible, iconLimit, direction, _, _, scale = Cat2.GetProfileShortcutWindowSettings(window.profileId)
    Cat2.SaveProfileShortcutWindowSettings(window.profileId, visible, iconLimit, direction, window:GetLeft(), window:GetTop(), scale)
end

local function CreateShortcutWindow(profileId)
    local existing = shortcutWindows[profileId]
    if existing then
        return existing
    end

    local window = CreateFrame("Frame", nil, UIParent)
    window.profileId = profileId
    window:SetWidth(50)
    window:SetHeight(70)
    window:SetFrameStrata("MEDIUM")
    window:SetFrameLevel(40)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    ApplyFlatBackdrop(window, 0.04, 0.05, 0.08, 0.72)

    local visible, iconLimit, direction, left, top, scale = Cat2.GetProfileShortcutWindowSettings(profileId)
    window:SetScale(scale)
    if left and top then
        window:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
    else
        local offset = CountVisibleShortcutWindows(profileId) * 56
        window:SetPoint("CENTER", UIParent, "CENTER", offset, 0)
    end
    window:SetScript("OnDragStart", function()
        window:StartMoving()
    end)
    window:SetScript("OnDragStop", function()
        window:StopMovingOrSizing()
        SaveWindowPosition(window)
    end)

    -- 顶部只承担拖动、打开主界面和关闭快捷窗三项职责。
    -- 保持 18 像素高，避免在图标快捷窗上留下过多非功能空白。
    local titleBar = CreateFrame("Frame", nil, window)
    titleBar:SetHeight(14)
    titleBar:SetPoint("TOPLEFT", window, "TOPLEFT", 3, -3)
    titleBar:SetPoint("TOPRIGHT", window, "TOPRIGHT", -3, -3)
    titleBar:SetFrameLevel(window:GetFrameLevel() + 5)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function()
        window:StartMoving()
    end)
    titleBar:SetScript("OnDragStop", function()
        window:StopMovingOrSizing()
        SaveWindowPosition(window)
    end)
    window.titleBar = titleBar

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 5, 0)
    titleText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    titleText:SetTextColor(0.68, 0.84, 1)
    window.titleText = titleText

    -- 紧凑操作按钮：12 乘 12 是当前快捷窗比例下的视觉下限。
    -- 两按钮右侧留 3 像素，彼此留 5 像素，避免贴边或误点。
    local openButton = CreateFrame("Button", nil, titleBar)
    openButton:SetFrameLevel(titleBar:GetFrameLevel() + 5)
    openButton:SetWidth(12)
    openButton:SetHeight(12)
    openButton:SetPoint("RIGHT", titleBar, "RIGHT", -20, -1)
    -- 配置标题只能占用操作按钮左侧的空间，防止长名称在多列小窗中压到按钮上。
    titleText:SetPoint("RIGHT", openButton, "LEFT", -3, 0)
    titleText:SetJustifyH("LEFT")

    -- 标题文字与操作按钮之间的静态底纹；起点会在重绘时按文字实际宽度计算。
    local titleTrack = titleBar:CreateTexture(nil, "ARTWORK")
    titleTrack:SetTexture("Interface\\Buttons\\WHITE8X8")
    titleTrack:SetHeight(3)
    titleTrack:SetVertexColor(0.16, 0.28, 0.4, 0.2)
    titleTrack:Hide()
    window.titleTrack = titleTrack

    -- 宏触发时沿底纹移动的窄光带；位置由 OnUpdate 按固定像素速度推进。
    local titleLight = titleBar:CreateTexture(nil, "OVERLAY")
    titleLight:SetTexture("Interface\\Buttons\\WHITE8X8")
    titleLight:SetHeight(3)
    titleLight:SetVertexColor(0.72, 0.9, 1, 0.78)
    titleLight:Hide()
    window.titleLight = titleLight
    window.titleLightTrail = {}
    local trailIndex = 1
    while trailIndex <= titleLightTrailWidth do
        local trail = titleBar:CreateTexture(nil, "OVERLAY")
        trail:SetTexture("Interface\\Buttons\\WHITE8X8")
        trail:SetHeight(3)
        trail:SetVertexColor(0.56, 0.78, 0.98, titleLightTrailAlpha[trailIndex])
        trail:Hide()
        window.titleLightTrail[trailIndex] = trail
        trailIndex = trailIndex + 1
    end
    window.titleLightActive = false
    titleBar:SetScript("OnUpdate", function()
        UpdateTitleLight(window, arg1)
    end)

    ApplyFlatBackdrop(openButton, 0.08, 0.22, 0.34, 0.98)
    local openText = openButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    openText:SetPoint("CENTER", openButton, "CENTER", 0, 1)
    openText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    openText:SetTextColor(0.72, 0.9, 1)
    openText:SetText("+")
    openButton:SetScript("OnClick", function()
        if ui.SelectConfigurationProfile then
            ui.SelectConfigurationProfile(profileId)
        end
        if ui.ShowMainWindow then
            ui.ShowMainWindow()
        end
    end)
    -- 悬停、按下、离开使用三套明确颜色，不能只依赖系统默认 Button 状态。
    openButton:SetScript("OnEnter", function()
        openButton:SetBackdropColor(0.12, 0.4, 0.58, 1)
        openButton:SetBackdropBorderColor(0.45, 0.82, 1, 1)
        openText:SetTextColor(1, 0.84, 0.28)
        GameTooltip:SetOwner(openButton, "ANCHOR_LEFT")
        GameTooltip:SetText(Cat2.L("打开主界面"))
        GameTooltip:Show()
    end)
    openButton:SetScript("OnLeave", function()
        openButton:SetBackdropColor(0.08, 0.22, 0.34, 0.98)
        openButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
        openText:SetTextColor(0.72, 0.9, 1)
        GameTooltip:Hide()
    end)
    openButton:SetScript("OnMouseDown", function()
        openButton:SetBackdropColor(0.04, 0.14, 0.24, 1)
        openButton:SetBackdropBorderColor(0.28, 0.62, 0.86, 1)
    end)
    openButton:SetScript("OnMouseUp", function()
        openButton:SetBackdropColor(0.12, 0.4, 0.58, 1)
        openButton:SetBackdropBorderColor(0.45, 0.82, 1, 1)
    end)
    window.openButton = openButton

    local closeButton = CreateFrame("Button", nil, titleBar)
    closeButton:SetFrameLevel(titleBar:GetFrameLevel() + 5)
    closeButton:SetWidth(12)
    closeButton:SetHeight(12)
    closeButton:SetPoint("RIGHT", titleBar, "RIGHT", -3, -1)
    ApplyFlatBackdrop(closeButton, 0.32, 0.07, 0.08, 0.98)
    local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeText:SetPoint("CENTER", closeButton, "CENTER", 0, 0)
    closeText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    closeText:SetTextColor(1, 0.8, 0.8)
    closeText:SetText("X")
    closeButton:SetScript("OnClick", function()
        local _, currentLimit, currentDirection, currentLeft, currentTop, currentScale = Cat2.GetProfileShortcutWindowSettings(profileId)
        Cat2.SaveProfileShortcutWindowSettings(profileId, false, currentLimit, currentDirection, currentLeft, currentTop, currentScale)
        StopTitleLight(window)
        window:Hide()
        if ui.RedrawMinimizedShortcuts then
            ui.RedrawMinimizedShortcuts()
        end
        if ui.RefreshShortcutToggleText then
            ui.RefreshShortcutToggleText()
        end
        if ui.RefreshProfileManager then
            ui.RefreshProfileManager()
        end
    end)
    closeButton:SetScript("OnEnter", function()
        closeButton:SetBackdropColor(0.52, 0.1, 0.12, 1)
        closeButton:SetBackdropBorderColor(1, 0.5, 0.5, 1)
        closeText:SetTextColor(1, 0.92, 0.92)
        GameTooltip:SetOwner(closeButton, "ANCHOR_LEFT")
        GameTooltip:SetText(Cat2.L("关闭此快捷窗"))
        GameTooltip:Show()
    end)
    closeButton:SetScript("OnLeave", function()
        closeButton:SetBackdropColor(0.32, 0.07, 0.08, 0.98)
        closeButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
        closeText:SetTextColor(1, 0.8, 0.8)
        GameTooltip:Hide()
    end)
    closeButton:SetScript("OnMouseDown", function()
        closeButton:SetBackdropColor(0.2, 0.03, 0.04, 1)
        closeButton:SetBackdropBorderColor(0.72, 0.26, 0.28, 1)
    end)
    closeButton:SetScript("OnMouseUp", function()
        closeButton:SetBackdropColor(0.52, 0.1, 0.12, 1)
        closeButton:SetBackdropBorderColor(1, 0.5, 0.5, 1)
    end)

    local panel = CreateFrame("Frame", nil, window)
    panel:SetPoint("TOP", window, "TOP", 0, -17)
    panel:SetFrameLevel(window:GetFrameLevel() + 1)
    panel:EnableMouse(true)
    window.panel = panel
    window.blocks = {}
    shortcutWindows[profileId] = window
    window:Hide()
    return window
end

local function RefreshWindowAlias()
    local repository = Cat2.RuntimeConfigurations
    if not repository then
        return
    end
    ui.ShortcutWindow = CreateShortcutWindow(repository.activeProfileId)
end

local function RedrawShortcutWindow(profileId)
    local profile = GetProfile(profileId)
    if not profile then
        return
    end
    local window = CreateShortcutWindow(profileId)
    local visible, iconLimit, direction, _, _, scale = Cat2.GetProfileShortcutWindowSettings(profileId)
    window:SetScale(scale)
    local oldIndex = 1
    while oldIndex <= table.getn(window.blocks) do
        window.blocks[oldIndex]:Hide()
        oldIndex = oldIndex + 1
    end
    window.blocks = {}
    window.titleText:SetText(profile.name)

    if not visible then
        StopTitleLight(window)
        window:Hide()
        return
    end

    local visibleSteps = {}
    local stepIndex = 1
    while stepIndex <= table.getn(profile.steps) do
        local step = profile.steps[stepIndex]
        if step.minimizedVisible ~= 0 then
            table.insert(visibleSteps, { step = step, index = stepIndex })
        end
        stepIndex = stepIndex + 1
    end

    local total = table.getn(visibleSteps)
    local rows = 1
    local columns = 1
    if direction == "vertical" then
        rows = iconLimit
        if total < rows then
            rows = total
        end
        if rows < 1 then
            rows = 1
        end
        columns = math.ceil(total / iconLimit)
        if columns < 1 then
            columns = 1
        end
    else
        columns = iconLimit
        if total < columns then
            columns = total
        end
        if columns < 1 then
            columns = 1
        end
        rows = math.ceil(total / iconLimit)
        if rows < 1 then
            rows = 1
        end
    end

    local iconSize = 38
    local iconGap = 4
    local padding = 3
    local panelWidth = padding * 2 + columns * iconSize + (columns - 1) * iconGap
    local panelHeight = padding * 2 + rows * iconSize + (rows - 1) * iconGap
    window.panel:SetWidth(panelWidth)
    window.panel:SetHeight(panelHeight)
    window:SetWidth(panelWidth + 6)
    window:SetHeight(panelHeight + 20)

    -- 单列窗口没有可用标题区域，直接隐藏标题，避免文字和按钮互相遮挡。
    if columns == 1 then
        window.titleText:Hide()
        window.titleTrack:Hide()
        window.titleTrackStart = nil
        window.titleTrackEnd = nil
        StopTitleLight(window)
    else
        local titleStart = 5
        window.titleText:Show()
        window.titleText:ClearAllPoints()
        window.titleText:SetPoint("LEFT", window.titleBar, "LEFT", titleStart, 0)
        window.titleText:SetPoint("RIGHT", window.openButton, "LEFT", -3, 0)

        -- 文字后留 5 像素，按钮前留 6 像素；标题过长时不强行绘制短线。
        local titleWidth = window.titleText:GetStringWidth() or 0
        local trackStart = titleStart + titleWidth + 5
        -- 直接使用本次布局算出的宽度，避免设置图标数后 GetWidth 仍短暂返回旧值。
        local trackEnd = panelWidth - 38
        window.titleTrack:ClearAllPoints()
        if trackEnd - trackStart >= 20 then
            window.titleTrackStart = trackStart
            window.titleTrackEnd = trackEnd
            window.titleTrack:SetPoint("LEFT", window.titleBar, "LEFT", trackStart, -0.5)
            window.titleTrack:SetPoint("RIGHT", window.openButton, "LEFT", -6, -0.5)
            window.titleTrack:Show()
        else
            window.titleTrack:Hide()
            window.titleTrackStart = nil
            window.titleTrackEnd = nil
            StopTitleLight(window)
        end
    end

    local displayIndex = 1
    while displayIndex <= total do
        local entry = visibleSteps[displayIndex]
        local step = entry.step
        -- 空白占位只消耗布局位置，不创建框体、图标、提示或任何鼠标事件。
        if step.id ~= "common_blank_placeholder" then
        local iconButton = CreateFrame("Button", nil, window.panel)
        iconButton:SetWidth(iconSize)
        iconButton:SetHeight(iconSize)
        iconButton:SetFrameLevel(window.panel:GetFrameLevel() + displayIndex + 1)
        ApplyFlatBackdrop(iconButton, 0.08, 0.1, 0.14, 0.96)

        local column = 0
        local row = 0
        if direction == "vertical" then
            column = math.floor((displayIndex - 1) / iconLimit)
            row = (displayIndex - 1) - column * iconLimit
        else
            column = (displayIndex - 1) - math.floor((displayIndex - 1) / iconLimit) * iconLimit
            row = math.floor((displayIndex - 1) / iconLimit)
        end
        iconButton:SetPoint("TOPLEFT", window.panel, "TOPLEFT", padding + column * (iconSize + iconGap), -padding - row * (iconSize + iconGap))

        local icon = iconButton:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", iconButton, "TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", iconButton, "BOTTOMRIGHT", -2, 2)
        icon:SetTexture(Cat2.GetCardPrimaryIcon(step))
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        if step.enabled == 0 then
            icon:SetDesaturated(true)
            icon:SetAlpha(0.4)
        end

        local stepIndexInProfile = entry.index
        iconButton:SetScript("OnClick", function()
            local currentStep = profile.steps[stepIndexInProfile]
            if not currentStep then
                return
            end
            if currentStep.enabled == 0 then
                Cat2.SetFlowStepEnabled(profile.steps, currentStep, 1)
            else
                Cat2.SetFlowStepEnabled(profile.steps, currentStep, 0)
            end
            Cat2.SaveConfigurationData(Cat2.RuntimeConfigurations)
            if ui.RedrawFlow then
                ui.RedrawFlow()
            end
            if ui.RedrawMinimizedShortcuts then
                ui.RedrawMinimizedShortcuts()
            end
        end)
        iconButton:SetScript("OnEnter", function()
            iconButton:SetBackdropBorderColor(0.72, 0.7, 0.44, 0.9)
            GameTooltip:SetOwner(iconButton, "ANCHOR_LEFT")
            -- 快捷窗归属已由窗口标题表达，卡片提示仅描述卡片本身，避免重复冗长。
            GameTooltip:SetText(step.name)
            GameTooltip:AddLine(step.enabled == 0 and Cat2.L("点击恢复步骤") or Cat2.L("点击暂停步骤"), 0.72, 0.84, 0.96)
            GameTooltip:Show()
        end)
        iconButton:SetScript("OnLeave", function()
            iconButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            GameTooltip:Hide()
        end)
        -- 占位卡不会加入缓存，因此使用连续数组，确保下次重绘能隐藏全部旧按钮。
        table.insert(window.blocks, iconButton)
        end
        displayIndex = displayIndex + 1
    end
    window:Show()
end

local function RedrawAllShortcutWindows()
    Cat2.EnsureConfigurationDataLoaded()
    RefreshWindowAlias()
    local repository = Cat2.RuntimeConfigurations

    -- 已删除配置不会再出现在 profileOrder 中，先清理其缓存窗口，避免快捷窗残留。
    for profileId, window in pairs(shortcutWindows) do
        if not repository.profiles[profileId] then
            StopTitleLight(window)
            window:Hide()
            shortcutWindows[profileId] = nil
            if ui.ShortcutWindow == window then
                ui.ShortcutWindow = nil
            end
        end
    end

    local visibleTotal = 0
    local index = 1
    while index <= table.getn(repository.profileOrder) do
        local profileId = repository.profileOrder[index]
        local visible = Cat2.GetProfileShortcutWindowSettings(profileId)
        if visible and visibleTotal < maximumShortcutWindows then
            RedrawShortcutWindow(profileId)
            visibleTotal = visibleTotal + 1
        else
            local window = shortcutWindows[profileId]
            if window then
                StopTitleLight(window)
                window:Hide()
            end
        end
        index = index + 1
    end
end

-- 删除配置时立即关闭并释放对应的快捷窗缓存。
function ui.RemoveShortcutWindow(profileId)
    local window = shortcutWindows[profileId]
    if not window then
        return
    end
    StopTitleLight(window)
    window:Hide()
    shortcutWindows[profileId] = nil
    if ui.ShortcutWindow == window then
        ui.ShortcutWindow = nil
    end
end

function ui.RedrawMinimizedShortcuts()
    local succeeded, errorMessage = pcall(RedrawAllShortcutWindows)
    if not succeeded then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff5555" .. Cat2.L("Cat2 快捷窗错误：") .. "|r" .. tostring(errorMessage))
    end
end

-- 触发指定配置快捷窗的标题光带；上一轮尚未结束时不重置当前位置。
function ui.TriggerShortcutWindowTitleLight(profileId)
    local window = shortcutWindows[profileId]
    if not window or not window:IsVisible() or window.titleLightActive then
        return false
    end
    if not window.titleTrack:IsVisible() or not window.titleTrackStart or not window.titleTrackEnd then
        return false
    end
    if window.titleTrackEnd - window.titleTrackStart < 20 then
        return false
    end
    window.titleLightCenter = window.titleTrackStart - titleLightWidth / 2
    window.titleLightActive = true
    window.titleLight:Hide()
    return true
end

function ui.SetShortcutWindowVisible(visible)
    Cat2.EnsureConfigurationDataLoaded()
    local profileId = Cat2.RuntimeConfigurations.activeProfileId
    local wasVisible, iconLimit, direction, left, top, scale = Cat2.GetProfileShortcutWindowSettings(profileId)
    if visible and not wasVisible and CountVisibleShortcutWindows(profileId) >= maximumShortcutWindows then
        if ui.ShowNotice then
            ui.ShowNotice(Cat2.L("快捷窗已达上限，请先关闭其他配置的快捷窗。"))
        end
        return false
    end
    Cat2.SaveProfileShortcutWindowSettings(profileId, visible, iconLimit, direction, left, top, scale)
    ui.RedrawMinimizedShortcuts()
    if ui.RefreshShortcutToggleText then
        ui.RefreshShortcutToggleText()
    end
    return true
end

function ui.CreateShortcutWindow()
    local succeeded, errorMessage = pcall(function()
        Cat2.EnsureConfigurationDataLoaded()
        RefreshWindowAlias()
    end)
    if not succeeded then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff5555" .. Cat2.L("Cat2 快捷窗初始化失败：") .. "|r" .. tostring(errorMessage))
    end
end

function ui.RestoreMinimizedWindow()
    Cat2.EnsureConfigurationDataLoaded()
    ui.RedrawMinimizedShortcuts()
end

function ui.ApplyMinimizedLayout()
    ui.RedrawMinimizedShortcuts()
end

function ui.ResetMinimizedWindowPosition(profileId)
    Cat2.EnsureConfigurationDataLoaded()
    if not profileId then
        profileId = Cat2.RuntimeConfigurations.activeProfileId
    end
    Cat2.ResetProfileShortcutWindowPosition(profileId)
    local window = shortcutWindows[profileId]
    if window then
        window:ClearAllPoints()
        window:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end
