-- 小地图入口：只负责创建按钮并打开流程编辑器。
-- 按钮在 PLAYER_LOGIN 后创建，以确保 Minimap 已可用。
Cat2.UI = Cat2.UI or {}
local ui = Cat2.UI

-- 专用于延迟创建小地图按钮的事件框体。
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    local button = CreateFrame("Button", "Cat2MinimapButton", Minimap)
    button:SetWidth(32)
    button:SetHeight(32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:EnableMouse(true)

    -- 技能图标放在背景层，再由系统追踪按钮边框覆盖四角，形成原生圆形小地图图标。
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\Achievement_Halloween_Cat_01")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("CENTER", button, "CENTER", 0, 1)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetWidth(53)
    border:SetHeight(53)
    border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local angle = Cat2.GetMinimapAngle()
    local radius = 80
    local dragging = false
    local moved = false

    local function PositionButton()
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
    end

    local function UpdateDragPosition()
        -- 使用小地图自身的有效缩放，避免玩家调整 UI 或小地图比例后拖动位置偏离鼠标。
        local scale = Minimap:GetEffectiveScale()
        local cursorX, cursorY = GetCursorPosition()
        local centerX, centerY = Minimap:GetCenter()
        cursorX = cursorX / scale
        cursorY = cursorY / scale
        angle = math.atan2(cursorY - centerY, cursorX - centerX)
        moved = true
        PositionButton()
    end

    PositionButton()
    button:RegisterForDrag("LeftButton")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetScript("OnMouseDown", function()
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", button, "CENTER", 1, 0)
        icon:SetAlpha(0.82)
    end)
    button:SetScript("OnMouseUp", function()
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", button, "CENTER", 0, 1)
        icon:SetAlpha(1)
    end)
    button:SetScript("OnDragStart", function()
        dragging = true
        moved = false
        button:SetScript("OnUpdate", UpdateDragPosition)
    end)
    button:SetScript("OnDragStop", function()
        button:SetScript("OnUpdate", nil)
        dragging = false
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", button, "CENTER", 0, 1)
        icon:SetAlpha(1)
        Cat2.SaveMinimapAngle(angle)
    end)
    button:SetScript("OnClick", function()
        if dragging or moved then
            moved = false
            return
        end
        if ui.ToggleMainWindow then
            local succeeded, errorMessage = pcall(ui.ToggleMainWindow)
            if not succeeded then
                DEFAULT_CHAT_FRAME:AddMessage("|cffff5555Cat2 主界面错误：|r" .. tostring(errorMessage))
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff5555Cat2 主界面加载失败：|r请查看 Lua 错误信息。")
        end
    end)
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(button, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Cat|cffff3f3f2|r 喵！一键宏", 1, 0.82, 0.2)
        GameTooltip:AddLine("左键点击打开设置", 0.55, 0.58, 0.62)
        GameTooltip:Show()
        local instructionLine = getglobal("GameTooltipTextLeft2")
        if instructionLine then
            instructionLine:SetFont("Fonts\\FRIZQT__.TTF", 10)
        end
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end)
