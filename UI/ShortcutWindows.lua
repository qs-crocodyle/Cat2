-- 配置级快捷窗管理：每个配置可独立显示一个图标快捷窗，同时最多十个。
-- 快捷窗与主界面互相独立；关闭主界面不应关闭快捷窗。窗口位置、布局、缩放、透明度和锁定状态
-- 属于角色 UI 设置，不进入配置导入导出文本。卡片图标状态仍来自对应 profile.steps。
-- 标题光带只在 /cat2 实际触发该配置时播放；短于阈值的轨道不创建可见效果。
--
-- CD显示约定：本文件不解析技能书或物品，只调用 Core/CardCooldown.lua 的统一接口。
-- 所有快捷窗共用一个0.1秒刷新器，并在单轮内按冷却缓存键合并查询；禁止给每个图标各建
-- OnUpdate。图标按钮及CD子框体均通过位置池复用，重绘只换绑定数据，不持续创建新Frame。
-- 当前客户端不认识 Cooldown 框体类型，因此不能使用系统旋转冷却模板；兼容方案是在图标
-- 底部三分之一区域绘制普通Frame暗色遮罩，并在遮罩中央显示剩余时间。
Cat2.UI = Cat2.UI or {}
local ui = Cat2.UI
local ApplyFlatBackdrop = ui.ApplyFlatBackdrop

-- 快捷窗沿用逻辑卡橙色边框；普通图标保持原来的配色。
local function RefreshShortcutBorder(button, hovered)
    local opacity = button.chromeOpacity or 1
    if button.step and button.step.behavior == "logic" then
        if button.step.enabled == 0 then
            button:SetBackdropBorderColor(0.30, 0.22, 0.14, 0.72 * opacity)
        elseif hovered then
            button:SetBackdropBorderColor(0.62, 0.40, 0.20, 0.95 * opacity)
        else
            button:SetBackdropBorderColor(0.48, 0.32, 0.17, 0.9 * opacity)
        end
    elseif hovered then
        button:SetBackdropBorderColor(0.72, 0.7, 0.44, 0.9 * opacity)
    else
        button:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9 * opacity)
    end
end

local maximumShortcutWindows = 10
local shortcutWindows = {}
local titleLightSpeed = 340
-- 1 像素亮点后接逐像素衰减的同色拖尾，避免多层矩形叠加产生色阶。
local titleLightWidth = 1
local titleLightTrailWidth = 28
local titleLightTrailAlpha = {
    0.94, 0.9, 0.86, 0.82, 0.78, 0.74, 0.7,
    0.66, 0.62, 0.58, 0.54, 0.5, 0.46, 0.42,
    0.38, 0.34, 0.3, 0.26, 0.22, 0.185, 0.15,
    0.12, 0.095, 0.072, 0.052, 0.035, 0.022, 0.012
}
local titleTrackAlpha = 0.24
-- 技能CD数字使用暗色底纹增强可读性；遮罩固定贴底，高度只覆盖数字所需区域。
local showShortcutCooldownShade = true
local shortcutCooldownShadeHeight = 14
-- 快捷窗的边缘夹紧沿用 ShaguDPS 的成熟方式：创建时只开启一次原生夹紧；拖动结束后只
-- 保存中心点相对屏幕宽高的比例，不在同一次回调中 ClearAllPoints/SetPoint。所有结构性
-- 重排仍合并到下一帧，并在隐藏状态下完成，避免拖动与尺寸、缩放修改发生重入。
local redrawRequested = false
local redrawDriver = CreateFrame("Frame")
redrawDriver:Hide()

local function SetFrameSizeIfChanged(frame, width, height)
    local currentWidth = frame:GetWidth()
    local currentHeight = frame:GetHeight()
    if not currentWidth or math.abs(currentWidth - width) > 0.01 then
        frame:SetWidth(width)
    end
    if not currentHeight or math.abs(currentHeight - height) > 0.01 then
        frame:SetHeight(height)
    end
end

local function SetFrameScaleIfChanged(frame, scale)
    local currentScale = frame:GetScale()
    if not currentScale or math.abs(currentScale - scale) > 0.001 then
        frame:SetScale(scale)
    end
end

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

    window.titleLightCenter = window.titleLightCenter + titleLightSpeed * elapsed
    local halfWidth = titleLightWidth / 2
    local visibleLeft = window.titleLightCenter - halfWidth
    local visibleRight = window.titleLightCenter + halfWidth
    if visibleLeft - titleLightTrailWidth >= trackEnd then
        StopTitleLight(window)
        return
    end
    PositionTitleLightTexture(window, window.titleLight, visibleLeft, visibleRight, trackStart, trackEnd)

    -- 光点向右移动，左侧 1 像素尾段保持同色、等高，只逐渐降低透明度。
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
    -- 与 ShaguDPS 一致：只读取中心点并保存比例，不在 OnDragStop 中重新挂锚。
    local centerX, centerY = window:GetCenter()
    if centerX and centerY and Cat2.SaveProfileShortcutWindowCenterPosition then
        Cat2.SaveProfileShortcutWindowCenterPosition(window.profileId, centerX, centerY)
    end
end

-- 只调整快捷窗的非图标元素；技能图标继续保留原亮度与暂停状态效果。
local function ApplyShortcutWindowAppearance(window, opacity)
    window.chromeOpacity = opacity
    window:SetBackdropColor(0.04, 0.05, 0.08, 0.72 * opacity)
    window:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9 * opacity)

    window.titleText:SetAlpha(opacity)
    -- 底纹拥有独立亮度，再乘以用户设置的非图标透明度，避免重绘时覆盖底纹强度。
    window.titleTrack:SetAlpha(titleTrackAlpha * opacity)
    window.titleLight:SetAlpha(opacity)
    local trailIndex = 1
    while trailIndex <= table.getn(window.titleLightTrail) do
        window.titleLightTrail[trailIndex]:SetAlpha(titleLightTrailAlpha[trailIndex] * opacity)
        trailIndex = trailIndex + 1
    end
    window.openButton:SetAlpha(opacity)
    window.closeButton:SetAlpha(opacity)

    local blockIndex = 1
    while blockIndex <= table.getn(window.blocks) do
        local iconButton = window.blocks[blockIndex]
        iconButton.chromeOpacity = opacity
        iconButton:SetBackdropColor(0.08, 0.1, 0.14, 0.96 * opacity)
        RefreshShortcutBorder(iconButton, false)
        blockIndex = blockIndex + 1
    end
end

-- 10秒以内显示一位小数，因此使用0.1秒周期；整数和分钟显示仍复用同一刷新，不另建计时器。
local cooldownRefreshInterval = 0.1
local cooldownRefreshElapsed = 0
local cooldownRefreshRequested = true
local cooldownRefreshDriver = CreateFrame("Frame")

local function RestoreShortcutIconState(iconButton)
    if not iconButton.icon then
        return
    end
    local disabled = iconButton.step and iconButton.step.enabled == 0
    iconButton.icon:SetDesaturated(disabled)
    iconButton.icon:SetAlpha(disabled and 0.4 or 1)
end

local function HideShortcutCooldown(iconButton)
    -- 按钮池会被下一张卡复用，隐藏时必须同时清除旧起点和时长，否则新卡可能继承旧CD画面。
    iconButton.cooldownStart = nil
    iconButton.cooldownDuration = nil
    iconButton.cooldownState = nil
    if iconButton.cooldownFrame then
        iconButton.cooldownFrame:Hide()
    end
    if iconButton.cooldownText then
        iconButton.cooldownText:SetText("")
    end
    RestoreShortcutIconState(iconButton)
end

local function FormatCooldownRemaining(remaining)
    -- 适配38像素小图标：长CD使用分钟，普通CD取整，最后10秒显示一位小数。
    if remaining >= 60 then
        return tostring(math.ceil(remaining / 60)) .. "m"
    end
    if remaining >= 10 then
        return tostring(math.ceil(remaining))
    end
    return string.format("%.1f", remaining)
end

local function ApplyShortcutCooldown(iconButton, startTime, duration, enabled, remaining, state)
    if state == "missing_item" then
        HideShortcutCooldown(iconButton)
        if iconButton.step and iconButton.step.enabled == 0 then
            return
        end
        iconButton.cooldownState = state
        iconButton.cooldownFrame:Show()
        iconButton.cooldownText:SetText("0")
        iconButton.cooldownText:SetTextColor(0.9, 0.52, 0.5, 0.95)
        return
    end

    if not startTime or not duration or not remaining or remaining <= 0 then
        HideShortcutCooldown(iconButton)
        return
    end

    RestoreShortcutIconState(iconButton)
    iconButton.cooldownState = nil
    -- 起点或总时长变化才更新记录；数字仍按共享刷新周期更新。
    if iconButton.cooldownStart ~= startTime or iconButton.cooldownDuration ~= duration then
        iconButton.cooldownStart = startTime
        iconButton.cooldownDuration = duration
    end
    iconButton.cooldownFrame:Show()
    iconButton.cooldownText:SetText(FormatCooldownRemaining(remaining))
    if iconButton.step and iconButton.step.enabled == 0 then
        iconButton.cooldownText:SetTextColor(0.72, 0.76, 0.82, 0.72)
    else
        iconButton.cooldownText:SetTextColor(1, 1, 1, 1)
    end
end

-- 所有快捷窗共用一次刷新和一次查询缓存，避免给每个图标安装独立 OnUpdate。
-- 暂停卡仍显示CD，但数字降低亮度；隐藏卡和空白占位不进入这里。
local function RefreshShortcutCooldowns()
    if not Cat2.QueryCardCooldown then
        return
    end

    local queryCache = {}
    for _, window in pairs(shortcutWindows) do
        if window:IsVisible() and window.layoutShouldShow then
            local blockIndex = 1
            local blockTotal = table.getn(window.blocks)
            while blockIndex <= blockTotal do
                local iconButton = window.blocks[blockIndex]
                if window.showCooldown and iconButton:IsVisible() and iconButton.step then
                    local cacheKey = Cat2.GetCardCooldownCacheKey and Cat2.GetCardCooldownCacheKey(iconButton.step)
                    local result
                    if cacheKey then
                        result = queryCache[cacheKey]
                        if not result then
                            local startTime, duration, enabled, remaining, state = Cat2.QueryCardCooldown(iconButton.step)
                            result = {
                                startTime = startTime,
                                duration = duration,
                                enabled = enabled,
                                remaining = remaining,
                                state = state,
                            }
                            queryCache[cacheKey] = result
                        end
                    else
                        local startTime, duration, enabled, remaining, state = Cat2.QueryCardCooldown(iconButton.step)
                        result = {
                            startTime = startTime,
                            duration = duration,
                            enabled = enabled,
                            remaining = remaining,
                            state = state,
                        }
                    end
                    ApplyShortcutCooldown(iconButton, result.startTime, result.duration, result.enabled, result.remaining, result.state)
                else
                    HideShortcutCooldown(iconButton)
                end
                blockIndex = blockIndex + 1
            end
        end
    end
end

cooldownRefreshDriver:RegisterEvent("SPELL_UPDATE_COOLDOWN")
cooldownRefreshDriver:RegisterEvent("BAG_UPDATE_COOLDOWN")
cooldownRefreshDriver:SetScript("OnEvent", function()
    cooldownRefreshRequested = true
end)
cooldownRefreshDriver:SetScript("OnUpdate", function()
    cooldownRefreshElapsed = cooldownRefreshElapsed + arg1
    if not cooldownRefreshRequested and cooldownRefreshElapsed < cooldownRefreshInterval then
        return
    end
    cooldownRefreshElapsed = 0
    cooldownRefreshRequested = false
    RefreshShortcutCooldowns()
end)

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
    -- 与 ShaguDPS 一致，只在窗口创建阶段设置一次，重绘期间不反复切换夹紧状态。
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    ApplyFlatBackdrop(window, 0.04, 0.05, 0.08, 0.72)

    local visible, iconLimit, direction, left, top, scale, opacity, locked, showCooldown = Cat2.GetProfileShortcutWindowSettings(profileId)
    window.positionLocked = locked
    window.showCooldown = showCooldown
    window:SetMovable(not locked)
    window:SetScale(scale)
    local centerX, centerY
    if Cat2.GetProfileShortcutWindowCenterPosition then
        centerX, centerY = Cat2.GetProfileShortcutWindowCenterPosition(profileId)
    end
    local anchorPoint, anchorRelativePoint, anchorX, anchorY
    if not centerX and Cat2.GetProfileShortcutWindowAnchor then
        anchorPoint, anchorRelativePoint, anchorX, anchorY = Cat2.GetProfileShortcutWindowAnchor(profileId)
    end
    if centerX and centerY then
        window:SetPoint("CENTER", UIParent, "BOTTOMLEFT", centerX, centerY)
    elseif anchorPoint and anchorX and anchorY then
        window:SetPoint(anchorPoint, UIParent, anchorRelativePoint or anchorPoint, anchorX, anchorY)
    elseif left and top then
        -- 兼容尚未经过一次拖动保存的旧版绝对位置。
        window:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
    else
        local offset = CountVisibleShortcutWindows(profileId) * 56
        window:SetPoint("CENTER", UIParent, "CENTER", offset, 0)
    end
    window:SetScript("OnDragStart", function()
        if window.positionLocked then
            return
        end
        window:StartMoving()
    end)
    window:SetScript("OnDragStop", function()
        if window.positionLocked then
            return
        end
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
        if window.positionLocked then
            return
        end
        window:StartMoving()
    end)
    titleBar:SetScript("OnDragStop", function()
        if window.positionLocked then
            return
        end
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
    titleTrack:SetVertexColor(0.16, 0.28, 0.4)
    titleTrack:SetAlpha(titleTrackAlpha)
    titleTrack:Hide()
    window.titleTrack = titleTrack

    -- 宏触发时沿底纹移动的光点；每个拖尾纹理只占 1 像素，以连续透明度模拟柔和渐变。
    window.titleLightTrail = {}
    local trailIndex = 1
    while trailIndex <= titleLightTrailWidth do
        local trail = titleBar:CreateTexture(nil, "OVERLAY")
        trail:SetTexture("Interface\\Buttons\\WHITE8X8")
        trail:SetHeight(3)
        -- 1.12 客户端不可靠地处理 SetVertexColor 的第四个参数，透明度必须单独设置。
        trail:SetVertexColor(0.68, 0.9, 1)
        trail:SetAlpha(titleLightTrailAlpha[trailIndex])
        trail:Hide()
        window.titleLightTrail[trailIndex] = trail
        trailIndex = trailIndex + 1
    end

    local titleLight = titleBar:CreateTexture(nil, "OVERLAY")
    titleLight:SetTexture("Interface\\Buttons\\WHITE8X8")
    titleLight:SetHeight(3)
    titleLight:SetVertexColor(0.68, 0.9, 1)
    titleLight:Hide()
    window.titleLight = titleLight
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
    window.closeButton = closeButton

    local panel = CreateFrame("Frame", nil, window)
    panel:SetPoint("TOP", window, "TOP", 0, -17)
    panel:SetFrameLevel(window:GetFrameLevel() + 1)
    panel:EnableMouse(true)
    window.panel = panel
    -- 图标按钮使用位置池复用；旧客户端无法销毁 Frame，重绘时只更新绑定数据与位置。
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

local function RedrawShortcutWindow(profileId, keepHidden)
    local profile = GetProfile(profileId)
    if not profile then
        return
    end
    local window = CreateShortcutWindow(profileId)
    local visible, iconLimit, direction, _, _, scale, opacity, locked, showCooldown = Cat2.GetProfileShortcutWindowSettings(profileId)
    if keepHidden then
        window:Hide()
    end
    window.positionLocked = locked
    window.showCooldown = showCooldown
    window:SetMovable(not locked)
    SetFrameScaleIfChanged(window, scale)
    local oldIndex = 1
    while oldIndex <= table.getn(window.blocks) do
        window.blocks[oldIndex]:Hide()
        oldIndex = oldIndex + 1
    end
    window.titleText:SetText(profile.name)

    if not visible then
        window.layoutShouldShow = false
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
    SetFrameSizeIfChanged(window.panel, panelWidth, panelHeight)
    SetFrameSizeIfChanged(window, panelWidth + 6, panelHeight + 20)

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
    local blockIndex = 1
    -- 重绘期间窗口处于隐藏状态，常规0.1秒刷新器不会处理它。这里保留一份仅供本次重绘使用的
    -- 查询缓存，让按钮重新显示前就拥有正确CD画面，避免先清空、下一帧再恢复造成闪烁。
    local redrawCooldownCache = {}
    while displayIndex <= total do
        local entry = visibleSteps[displayIndex]
        local step = entry.step
        -- 空白占位只消耗布局位置，不创建框体、图标、提示或任何鼠标事件。
        if step.id ~= "common_blank_placeholder" then
        local iconButton = window.blocks[blockIndex]
        if not iconButton then
        iconButton = CreateFrame("Button", nil, window.panel)
        iconButton:SetWidth(iconSize)
        iconButton:SetHeight(iconSize)
        local icon = iconButton:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", iconButton, "TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", iconButton, "BOTTOMRIGHT", -2, 2)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        iconButton.icon = icon

        -- 此客户端没有 Cooldown 框体类型，使用普通 Frame 在图标底部三分之一区域绘制暗色遮罩。
        -- 遮罩和文字层都关闭鼠标，点击必须继续由底层 iconButton 处理暂停/恢复。
        local cooldownFrame = CreateFrame("Frame", nil, iconButton)
        cooldownFrame:SetPoint("BOTTOMLEFT", iconButton, "BOTTOMLEFT", 2, 2)
        cooldownFrame:SetPoint("BOTTOMRIGHT", iconButton, "BOTTOMRIGHT", -2, 2)
        cooldownFrame:SetHeight(shortcutCooldownShadeHeight)
        cooldownFrame:EnableMouse(false)
        local cooldownShade = cooldownFrame:CreateTexture(nil, "ARTWORK")
        cooldownShade:SetAllPoints(cooldownFrame)
        cooldownShade:SetTexture("Interface\\Buttons\\WHITE8X8")
        cooldownShade:SetVertexColor(0.02, 0.03, 0.05, 0.50)
        if not showShortcutCooldownShade then
            cooldownShade:Hide()
        end
        cooldownFrame:Hide()
        iconButton.cooldownFrame = cooldownFrame

        local cooldownTextLayer = CreateFrame("Frame", nil, iconButton)
        cooldownTextLayer:SetAllPoints(iconButton)
        cooldownTextLayer:EnableMouse(false)
        local cooldownText = cooldownTextLayer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cooldownText:SetPoint("CENTER", cooldownFrame, "CENTER", 0, -1)
        cooldownText:SetFont("Fonts\\ARIALN.TTF", 13, "OUTLINE")
        cooldownText:SetTextColor(1, 1, 1, 1)
        cooldownText:SetText("")
        iconButton.cooldownTextLayer = cooldownTextLayer
        iconButton.cooldownText = cooldownText

        iconButton:SetScript("OnClick", function()
            local currentProfile = iconButton.profile
            local currentStep = currentProfile and currentProfile.steps[iconButton.stepIndexInProfile]
            if not currentStep then
                return
            end
            if currentStep.enabled == 0 then
                Cat2.SetFlowStepEnabled(currentProfile.steps, currentStep, 1)
            else
                Cat2.SetFlowStepEnabled(currentProfile.steps, currentStep, 0)
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
            RefreshShortcutBorder(iconButton, true)
            GameTooltip:SetOwner(iconButton, "ANCHOR_LEFT")
            -- 快捷窗归属已由窗口标题表达，卡片提示仅描述卡片本身，避免重复冗长。
            local currentStep = iconButton.step
            GameTooltip:SetText(currentStep.name)
            GameTooltip:AddLine(currentStep.enabled == 0 and Cat2.L("点击恢复步骤") or Cat2.L("点击暂停步骤"), 0.72, 0.84, 0.96)
            if iconButton.cooldownState == "missing_item" then
                GameTooltip:AddLine(Cat2.L("背包中没有该物品"), 0.72, 0.46, 0.42)
            end
            GameTooltip:Show()
        end)
        iconButton:SetScript("OnLeave", function()
            RefreshShortcutBorder(iconButton, false)
            GameTooltip:Hide()
        end)
        window.blocks[blockIndex] = iconButton
        end

        iconButton.profile = profile
        iconButton.step = step
        iconButton.stepIndexInProfile = entry.index
        iconButton:SetFrameLevel(window.panel:GetFrameLevel() + displayIndex + 1)
        iconButton.cooldownFrame:SetFrameLevel(iconButton:GetFrameLevel() + 1)
        iconButton.cooldownTextLayer:SetFrameLevel(iconButton:GetFrameLevel() + 2)
        iconButton:ClearAllPoints()
        ApplyFlatBackdrop(iconButton, 0.08, 0.1, 0.14, 0.96)
        RefreshShortcutBorder(iconButton, false)

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
        iconButton.icon:SetTexture(Cat2.GetCardPrimaryIcon(step))
        iconButton.icon:SetDesaturated(step.enabled == 0)
        iconButton.icon:SetAlpha(step.enabled == 0 and 0.4 or 1)
        if window.showCooldown and Cat2.QueryCardCooldown then
            local cacheKey = Cat2.GetCardCooldownCacheKey and Cat2.GetCardCooldownCacheKey(step)
            local cooldownResult = cacheKey and redrawCooldownCache[cacheKey]
            if not cooldownResult then
                local startTime, duration, enabled, remaining, state = Cat2.QueryCardCooldown(step)
                cooldownResult = {
                    startTime = startTime,
                    duration = duration,
                    enabled = enabled,
                    remaining = remaining,
                    state = state,
                }
                if cacheKey then
                    redrawCooldownCache[cacheKey] = cooldownResult
                end
            end
            ApplyShortcutCooldown(
                iconButton,
                cooldownResult.startTime,
                cooldownResult.duration,
                cooldownResult.enabled,
                cooldownResult.remaining,
                cooldownResult.state
            )
        else
            HideShortcutCooldown(iconButton)
        end
        iconButton:Show()
        blockIndex = blockIndex + 1
        end
        displayIndex = displayIndex + 1
    end
    ApplyShortcutWindowAppearance(window, opacity)
    cooldownRefreshRequested = true
    window.layoutShouldShow = true
    if keepHidden then
        window:Hide()
    else
        window:Show()
    end
end

local function RedrawAllShortcutWindows(keepHidden)
    Cat2.EnsureConfigurationDataLoaded()
    RefreshWindowAlias()
    local repository = Cat2.RuntimeConfigurations

    -- 已删除配置不会再出现在 profileOrder 中，先清理其缓存窗口，避免快捷窗残留。
    for profileId, window in pairs(shortcutWindows) do
        if not repository.profiles[profileId] then
            window.layoutShouldShow = false
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
            RedrawShortcutWindow(profileId, keepHidden)
            visibleTotal = visibleTotal + 1
        else
            local window = shortcutWindows[profileId]
            if window then
                window.layoutShouldShow = false
                StopTitleLight(window)
                window:Hide()
            end
        end
        index = index + 1
    end
end

local function HideShortcutWindowsForLayout()
    for _, window in pairs(shortcutWindows) do
        if window:IsVisible() then
            window:Hide()
        end
    end
end

local function RestoreShortcutWindowVisibility()
    for _, window in pairs(shortcutWindows) do
        if window.layoutShouldShow then
            window:Show()
        else
            window:Hide()
        end
    end
end

redrawDriver:SetScript("OnUpdate", function()
    if not redrawRequested then
        this:Hide()
        return
    end

    -- 在下一帧的一次回调中完成全部操作；Hide 与 Show 之间没有渲染机会，因此不会闪烁。
    redrawRequested = false
    HideShortcutWindowsForLayout()
    local succeeded, errorMessage = pcall(RedrawAllShortcutWindows, true)
    if not succeeded then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff5555" .. Cat2.L("Cat2 快捷窗错误：") .. "|r" .. tostring(errorMessage))
    end
    RestoreShortcutWindowVisibility()

    -- 理论上重排期间不会产生嵌套请求；若其他模块确实追加了请求，则留到下一帧继续合并。
    if not redrawRequested then
        this:Hide()
    end
end)

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
    redrawRequested = true
    redrawDriver:Show()
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
    StopTitleLight(window)
    window.titleLightCenter = window.titleTrackStart - titleLightWidth / 2
    window.titleLightActive = true
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
