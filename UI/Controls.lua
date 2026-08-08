-- 扁平控件、滚动区域和鼠标命中工具。
-- 本文件只提供可复用 UI 基础能力，不保存流程编辑器业务状态。
Cat2.UI = Cat2.UI or {}
local ui = Cat2.UI
local mainWindowDim = nil

-- 弹窗打开时仅压暗 Cat2 主界面，不影响游戏世界与独立流程快捷小窗。
function ui.ShowMainWindowDim()
    local target = getglobal("Cat2MainWindow")
    if not target or not target:IsVisible() then
        return
    end
    if not mainWindowDim then
        mainWindowDim = CreateFrame("Frame", nil, target)
        mainWindowDim:SetAllPoints(target)
        mainWindowDim:SetFrameLevel(target:GetFrameLevel() + 200)
        mainWindowDim:EnableMouse(true)
        local shade = mainWindowDim:CreateTexture(nil, "OVERLAY")
        shade:SetAllPoints(mainWindowDim)
        shade:SetTexture("Interface\\Buttons\\WHITE8X8")
        shade:SetVertexColor(0.025, 0.055, 0.09, 0.62)
        mainWindowDim:SetScript("OnMouseDown", function()
        end)
        mainWindowDim:SetScript("OnMouseUp", function()
        end)
    end
    mainWindowDim:Show()
end

function ui.HideMainWindowDim()
    if mainWindowDim then
        mainWindowDim:Hide()
    end
end

-- 为框体应用 Cat2 统一的扁平背景和细边框。
function ui.ApplyFlatBackdrop(frame, red, green, blue, alpha)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileSize = 8,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    frame:SetBackdropColor(red, green, blue, alpha)
    frame:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
end

-- 返回鼠标当前是否位于指定框体内部；拖放命中判断使用。
function ui.IsCursorInside(frame)
    local scale = UIParent:GetScale()
    local x, y = GetCursorPosition()
    x = x / scale
    y = y / scale
    return x >= frame:GetLeft() and x <= frame:GetRight() and y >= frame:GetBottom() and y <= frame:GetTop()
end

-- 将滚动值限制在合法范围，并同时更新滚动框与滑块。
function ui.SetScrollPosition(scrollFrame, slider, value)
    local maximum = scrollFrame.maxScroll or 0
    if value < 0 then
        value = 0
    end
    if value > maximum then
        value = maximum
    end
    slider:SetValue(value)
    scrollFrame:SetVerticalScroll(value)
end

-- 根据内容高度和滚动框实际高度刷新滑块范围。
function ui.UpdateScrollBar(scrollFrame, slider, contentHeight)
    scrollFrame:UpdateScrollChildRect()
    local maximum = contentHeight - scrollFrame:GetHeight()
    if maximum < 0 then
        maximum = 0
    end
    scrollFrame.maxScroll = maximum
    slider:SetMinMaxValues(0, maximum)
    slider:Show()
    if maximum <= 0 then
        -- 没有可滚动内容时保留滚动条轮廓并继续拦截鼠标，避免点击穿透到游戏世界。
        slider:SetAlpha(0.28)
        slider:EnableMouse(true)
    else
        slider:SetAlpha(1)
        slider:EnableMouse(true)
    end
    ui.SetScrollPosition(scrollFrame, slider, scrollFrame:GetVerticalScroll())
end

-- 创建一个包含 ScrollFrame、内容层、滚动条和透明鼠标命中层的列表区域。
function ui.CreateScrollArea(parent)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent)
    -- 比内容层多留两像素，避免卡片右侧一像素边框落在裁剪边界上而变细。
    scrollFrame:SetWidth(318)
    scrollFrame:SetHeight(392)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(316)
    content:SetHeight(392)
    content:EnableMouse(true)
    local contentHitArea = content:CreateTexture(nil, "BACKGROUND")
    contentHitArea:SetAllPoints()
    contentHitArea:SetTexture("Interface\\Buttons\\WHITE8X8")
    contentHitArea:SetVertexColor(0, 0, 0, 0.01)
    content:SetScript("OnMouseDown", function()
    end)
    content:SetScript("OnMouseUp", function()
    end)
    scrollFrame:SetScrollChild(content)
    scrollFrame:EnableMouse(true)

    local slider = CreateFrame("Slider", nil, parent)
    slider:SetOrientation("VERTICAL")
    slider:SetWidth(12)
    slider:SetHeight(392)
    slider:SetFrameLevel(parent:GetFrameLevel() + 10)
    slider:SetMinMaxValues(0, 0)
    slider:SetValueStep(1)

    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetTexture("Interface\\Buttons\\WHITE8X8")
    track:SetAllPoints()
    track:SetVertexColor(0.05, 0.06, 0.08, 0.95)
    slider:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    slider:SetScript("OnValueChanged", function()
        scrollFrame:SetVerticalScroll(slider:GetValue())
    end)

    local thumb = slider:GetThumbTexture()
    if thumb then
        thumb:SetWidth(12)
        thumb:SetHeight(36)
        thumb:SetVertexColor(0.45, 0.68, 0.95, 0.95)
    end
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function()
        ui.SetScrollPosition(scrollFrame, slider, scrollFrame:GetVerticalScroll() - arg1 * 70)
    end)
    return scrollFrame, content, slider
end
