-- 卡片控件与拖放交互；保留控件复用及原有鼠标行为。
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

-- 逻辑类型由 behavior 标记，与卡片所在的 logic 分类独立；按原顺序调用 Execute。
local function ApplyLogicAppearance(block, disabled, hovered)
    if disabled then
        block:SetBackdropColor(0.085, 0.06, 0.035, 0.8)
        block:SetBackdropBorderColor(0.30, 0.22, 0.14, 0.72)
    elseif hovered then
        block:SetBackdropColor(0.215, 0.145, 0.075, 0.98)
        block:SetBackdropBorderColor(0.62, 0.40, 0.20, 0.95)
    else
        block:SetBackdropColor(0.15, 0.105, 0.06, 0.95)
        block:SetBackdropBorderColor(0.48, 0.32, 0.17, 0.9)
    end
end

local function SetTypeLabelColor(label, step, disabled)
    if step.behavior == "logic" then
        if disabled then label:SetTextColor(0.45, 0.33, 0.22)
        else label:SetTextColor(0.76, 0.49, 0.25) end
    else
        if disabled then label:SetTextColor(0.46, 0.36, 0.56)
        else label:SetTextColor(0.72, 0.5, 0.94) end
    end
end

-- 根据当前鼠标位置计算拖放时应插入流程的序号。
local function GetFlowInsertIndex()
    local scale = UIParent:GetScale()
    local x, y = GetCursorPosition()
    x = x / scale
    y = y / scale

    local relativeY = editor.flowContent:GetTop() - y
    local index = math.floor(relativeY / 50) + 1
    local total = table.getn(editor.selectedSteps)

    if index < 1 then
        index = 1
    end
    if index > total + 1 then
        index = total + 1
    end
    return index
end

-- 拖动卡片时更新左侧流程中的金色插入提示线。
local function UpdateDropIndicator()
    if not editor.dropIndicator then
        return
    end

    if not editor.dragGhost or not editor.dragGhost:IsVisible() then
        editor.dropIndicator:Hide()
        return
    end

    if not IsCursorInside(editor.flowScroll) then
        editor.dropIndicator:Hide()
        return
    end

    local index = GetFlowInsertIndex()
    editor.dropIndicator:ClearAllPoints()
    editor.dropIndicator:SetPoint("TOPLEFT", editor.flowContent, "TOPLEFT", 24, -1 - (index - 1) * 50)
    editor.dropIndicator:Show()
end

-- 将拖动跟随卡片定位到鼠标，并同步刷新插入提示。
function editor.UpdateDragGhost()
    if not editor.dragGhost or not editor.dragGhost:IsVisible() then
        return
    end

    local scale = UIParent:GetScale()
    local x, y = GetCursorPosition()
    x = x / scale
    y = y / scale
    editor.dragGhost:ClearAllPoints()
    editor.dragGhost:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    UpdateDropIndicator()
end

-- 创建拖动时显示在鼠标旁的卡片预览；只创建一次。
function editor.CreateDragGhost()
    editor.dragGhost = CreateFrame("Frame", nil, UIParent)
    editor.dragGhost:SetWidth(330)
    editor.dragGhost:SetHeight(44)
    editor.dragGhost:SetFrameStrata("TOOLTIP")
    editor.dragGhost:SetFrameLevel(20)
    editor.dragGhost:EnableMouse(false)
    ApplyFlatBackdrop(editor.dragGhost, 0.08, 0.12, 0.18, 0.96)

    local icon = editor.dragGhost:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(30)
    icon:SetHeight(30)
    icon:SetPoint("LEFT", editor.dragGhost, "LEFT", 8, 0)
    editor.dragGhost.icon = icon

    local name = editor.dragGhost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, 0)
    name:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    name:SetTextColor(1, 0.82, 0.2)
    editor.dragGhost.name = name

    local description = editor.dragGhost:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    description:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 8, 0)
    description:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    description:SetTextColor(0.82, 0.82, 0.82)
    editor.dragGhost.description = description
    editor.dragGhost:Hide()
end

-- 创建单张可见卡片；流程卡附带选中、暂停、删除与排序交互。
function editor.CreateStepBlock(parent, step, index, fromFlow)
    local block = CreateFrame("Button", nil, parent)
    block:SetWidth(316)
    block:SetHeight(44)
    ApplyFlatBackdrop(block, 0.1, 0.12, 0.16, 0.95)
    block:EnableMouse(true)
    block:RegisterForDrag("LeftButton", "RightButton")
    block.step = step
    block.index = index
    block.fromFlow = fromFlow

    -- 流程序号位于卡片外侧的独立留白栏中；卡片重排时由 RefreshState 更新。
    if fromFlow then
        block.orderText = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        block.orderText:SetPoint("RIGHT", block, "LEFT", -4, 0)
        block.orderText:SetWidth(24)
        block.orderText:SetJustifyH("RIGHT")
        block.orderText:SetFont(DAMAGE_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
        block.orderText:SetTextColor(0.44, 0.54, 0.65)
        block.orderText:SetAlpha(0.38)

        -- 旧客户端不能调整 FontString 字距；两位数拆成两个单字，压缩中心间距并允许轻微重叠。
        block.orderTensText = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        block.orderTensText:SetPoint("CENTER", block, "LEFT", -18, 0)
        block.orderTensText:SetWidth(24)
        block.orderTensText:SetJustifyH("CENTER")
        block.orderTensText:SetFont(DAMAGE_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
        block.orderTensText:SetTextColor(0.44, 0.54, 0.65)
        block.orderTensText:SetAlpha(0.38)
        block.orderTensText:Hide()

        block.orderOnesText = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        block.orderOnesText:SetPoint("CENTER", block, "LEFT", -10, 0)
        block.orderOnesText:SetWidth(24)
        block.orderOnesText:SetJustifyH("CENTER")
        block.orderOnesText:SetFont(DAMAGE_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
        block.orderOnesText:SetTextColor(0.44, 0.54, 0.65)
        block.orderOnesText:SetAlpha(0.38)
        block.orderOnesText:Hide()

        block.SetOrderTextAppearance = function(red, green, blue, alpha)
            block.orderText:SetTextColor(red, green, blue)
            block.orderText:SetAlpha(alpha)
            block.orderTensText:SetTextColor(red, green, blue)
            block.orderTensText:SetAlpha(alpha)
            block.orderOnesText:SetTextColor(red, green, blue)
            block.orderOnesText:SetAlpha(alpha)
        end

        block.RefreshOrderText = function()
            if block.index >= 10 then
                local tens = math.floor(block.index / 10)
                local ones = block.index - tens * 10
                block.orderText:Hide()
                block.orderTensText:SetText(tostring(tens))
                block.orderOnesText:SetText(tostring(ones))
                block.orderTensText:Show()
                block.orderOnesText:Show()
            else
                block.orderTensText:Hide()
                block.orderOnesText:Hide()
                block.orderText:SetText(tostring(block.index))
                block.orderText:Show()
            end
        end
        block.RefreshOrderText()
    end

    -- 归组卡片在右侧内边缘显示同色短竖条，不占用标题空间，也不改变卡片原有底色。
    local groupColor = editor.GetExclusiveGroupColor(step.exclusiveGroup)
    local groupMarker = nil
    if groupColor then
        groupMarker = block:CreateTexture(nil, "OVERLAY")
        groupMarker:SetTexture("Interface\\Buttons\\WHITE8X8")
        groupMarker:SetWidth(5)
        groupMarker:SetPoint("TOPRIGHT", block, "TOPRIGHT", -1, -1)
        groupMarker:SetPoint("BOTTOMRIGHT", block, "BOTTOMRIGHT", -1, 1)
        groupMarker:SetVertexColor(groupColor[1], groupColor[2], groupColor[3], 1)
        if fromFlow and step.enabled == 0 then
            groupMarker:SetAlpha(0.58)
        else
            groupMarker:SetAlpha(0.92)
        end
        block.groupMarker = groupMarker
    end

    -- icons 第一项是主图标，其余两项是可选辅助图标。
    local iconPaths = step.icons
    local cardIcons = {}
    local iconIndex = 1
    local iconTotal = table.getn(iconPaths)
    local lastIcon = nil
    if step.id == "common_blank_placeholder" then
        -- 卡片栏保留标准图标框与文字缩进，但框内不绘制任何图标纹理。
        local emptyIconFrame = CreateFrame("Frame", nil, block)
        emptyIconFrame:SetWidth(30)
        emptyIconFrame:SetHeight(30)
        emptyIconFrame:SetPoint("LEFT", block, "LEFT", 8, 0)
        ApplyFlatBackdrop(emptyIconFrame, 0.045, 0.055, 0.075, 0.9)
        emptyIconFrame:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.72)
        lastIcon = emptyIconFrame
    else
        while iconIndex <= iconTotal do
            local cardIcon = block:CreateTexture(nil, "ARTWORK")
            cardIcon:SetTexture(iconPaths[iconIndex])
            cardIcon:SetWidth(30)
            cardIcon:SetHeight(30)
            cardIcon:SetPoint("LEFT", block, "LEFT", 8 + (iconIndex - 1) * 33, 0)
            table.insert(cardIcons, cardIcon)
            lastIcon = cardIcon
            iconIndex = iconIndex + 1
        end
    end

    -- 正文低于小组标记的OVERLAY层，长文字经过色条时由色条覆盖。
    local name = block:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    name:SetPoint("TOPLEFT", lastIcon, "TOPRIGHT", 8, 0)
    name:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    name:SetTextColor(1, 0.82, 0.2)
    name:SetText(step.name)

    -- 类型标识紧跟标题：被动为紫色，逻辑为橙色。
    local typeLabel = nil
    if step.behavior == "passive" or step.behavior == "logic" then
        typeLabel = block:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        typeLabel:SetPoint("LEFT", name, "RIGHT", 7, 0)
        typeLabel:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
        SetTypeLabelColor(typeLabel, step, false)
        typeLabel:SetText(step.behavior == "logic" and Cat2.L("逻辑") or Cat2.L("被动"))
        if step.behavior == "logic" then
            ApplyLogicAppearance(block, false, false)
        else
            block:SetBackdropColor(0.145, 0.115, 0.195, 0.95)
            block:SetBackdropBorderColor(0.38, 0.35, 0.56, 0.9)
        end
    end

    -- 参数定义仅供右侧参数按钮和编辑器使用；参数值改由卡片描述模板表达，
    -- 不再附加在标题后方，避免标题区域拥挤。
    local optionSchema = type(step.optionSchema) == "table" and step.optionSchema or nil
    local optionTotal = optionSchema and table.getn(optionSchema) or 0

    local description = block:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    description:SetPoint("BOTTOMLEFT", lastIcon, "BOTTOMRIGHT", 8, 0)
    -- 延伸至卡片内边缘，让色条覆盖末端；限制单行，避免越过卡片边界。
    description:SetPoint("BOTTOMRIGHT", block, "BOTTOMRIGHT", -1, 7)
    description:SetHeight(12)
    description:SetJustifyH("LEFT")
    description:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    description:SetTextColor(0.82, 0.82, 0.82)
    description:SetText(editor.GetCardDescriptionText(step))

    block.normalAlpha = 1
    if fromFlow and step.enabled == 0 then
        -- 不能降低整个 block 的透明度，否则选中的参数、显示、暂停和删除按钮也会继承变暗。
        -- 暂停状态仅压低卡片正文与底色，功能按钮始终保持可辨识、可操作的亮度。
        if step.behavior == "logic" then
            ApplyLogicAppearance(block, true, false)
        elseif step.behavior == "passive" then
            ApplyFlatBackdrop(block, 0.08, 0.06, 0.105, 0.8)
            block:SetBackdropBorderColor(0.24, 0.21, 0.35, 0.72)
        else
            ApplyFlatBackdrop(block, 0.055, 0.065, 0.085, 0.8)
            block:SetBackdropBorderColor(0.2, 0.27, 0.36, 0.72)
        end
        name:SetTextColor(0.58, 0.58, 0.58)
        description:SetTextColor(0.5, 0.5, 0.5)
        if typeLabel then
            SetTypeLabelColor(typeLabel, block.step, true)
        end
        local disabledIconIndex = 1
        local disabledIconTotal = table.getn(cardIcons)
        while disabledIconIndex <= disabledIconTotal do
            cardIcons[disabledIconIndex]:SetAlpha(0.5)
            disabledIconIndex = disabledIconIndex + 1
        end
    end

    if fromFlow and step.isMissing then
        -- 缺失卡片使用低饱和暗红色，但仍保持 ID 可读，便于定位注册或 TOC 问题。
        ApplyFlatBackdrop(block, 0.22, 0.07, 0.08, 0.82)
        -- 不降低整个容器透明度，避免选中后删除等功能按钮也跟着变暗。
        name:SetTextColor(0.82, 0.52, 0.52)
        description:SetTextColor(0.72, 0.56, 0.56)
        local missingIconIndex = 1
        local missingIconTotal = table.getn(cardIcons)
        while missingIconIndex <= missingIconTotal do
            cardIcons[missingIconIndex]:SetAlpha(0.5)
            missingIconIndex = missingIconIndex + 1
        end
    end

    if fromFlow then
        local optionButton = nil
        do
            optionButton = CreateFrame("Button", nil, block)
            optionButton:SetFrameLevel(block:GetFrameLevel() + 5)
            optionButton:SetWidth(24)
            optionButton:SetHeight(24)
            optionButton:SetPoint("RIGHT", block, "RIGHT", -104, 0)
            ApplyFlatBackdrop(optionButton, 0.08, 0.2, 0.25, 0.98)

            -- 直接绘制三条横线，避免客户端字体把“≡”显示得过细。
            local optionSymbol = CreateFrame("Frame", nil, optionButton)
            optionSymbol:SetWidth(14)
            optionSymbol:SetHeight(12)
            optionSymbol:SetPoint("CENTER", optionButton, "CENTER", 0, 0)
            local optionLines = {}
            local lineOffsets = { 4, 0, -4 }
            local lineIndex = 1
            while lineIndex <= table.getn(lineOffsets) do
                local shadow = optionSymbol:CreateTexture(nil, "ARTWORK")
                shadow:SetTexture("Interface\\Buttons\\WHITE8X8")
                shadow:SetWidth(14)
                shadow:SetHeight(3)
                shadow:SetPoint("CENTER", optionSymbol, "CENTER", 1, lineOffsets[lineIndex] - 1)
                shadow:SetVertexColor(0.015, 0.025, 0.045, 0.95)

                local line = optionSymbol:CreateTexture(nil, "OVERLAY")
                line:SetTexture("Interface\\Buttons\\WHITE8X8")
                line:SetWidth(12)
                line:SetHeight(2)
                line:SetPoint("CENTER", optionSymbol, "CENTER", 0, lineOffsets[lineIndex])
                line:SetVertexColor(0.5, 0.84, 0.94, 1)
                table.insert(optionLines, line)
                lineIndex = lineIndex + 1
            end

            local function SetOptionSymbolColor(red, green, blue)
                local colorIndex = 1
                local colorTotal = table.getn(optionLines)
                while colorIndex <= colorTotal do
                    optionLines[colorIndex]:SetVertexColor(red, green, blue, 1)
                    colorIndex = colorIndex + 1
                end
            end

            local function RefreshOptionAppearance()
                if optionTotal > 0 then
                    optionButton:SetBackdropColor(0.08, 0.2, 0.25, 0.98)
                    optionButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
                    SetOptionSymbolColor(0.5, 0.84, 0.94)
                else
                    -- 无参数按钮使用中性灰，与卡片底色拉开层次，同时保持禁用感。
                    optionButton:SetBackdropColor(0.17, 0.18, 0.2, 0.96)
                    optionButton:SetBackdropBorderColor(0.38, 0.41, 0.46, 0.82)
                    SetOptionSymbolColor(0.52, 0.55, 0.6)
                end
            end
            RefreshOptionAppearance()

            optionButton:SetScript("OnEnter", function()
                if optionTotal == 0 then
                    RefreshOptionAppearance()
                    GameTooltip:SetOwner(optionButton, "ANCHOR_RIGHT")
                    GameTooltip:SetText(Cat2.L("该卡片没有参数可修改"))
                    GameTooltip:Show()
                    return
                end
                optionButton:SetBackdropColor(0.1, 0.3, 0.36, 1)
                SetOptionSymbolColor(0.65, 0.94, 1)
                GameTooltip:SetOwner(optionButton, "ANCHOR_RIGHT")
                GameTooltip:SetText(Cat2.L("设置卡片参数"))
                local hasSavedValue = false
                local savedIndex = 1
                while savedIndex <= optionTotal do
                    local definition = optionSchema[savedIndex]
                    if block.step.optionValues and block.step.optionValues[definition.key] ~= nil then
                        hasSavedValue = true
                        break
                    end
                    savedIndex = savedIndex + 1
                end
                if not hasSavedValue then
                    GameTooltip:AddLine(Cat2.L("当前没有独立设置，运行时使用卡片的继承值或默认值。"), 0.72, 0.74, 0.82, true)
                else
                    GameTooltip:AddLine(Cat2.L("部分或全部参数使用本卡片实例的独立设置。"), 0.72, 0.74, 0.82, true)
                end
                GameTooltip:Show()
            end)
            optionButton:SetScript("OnLeave", function()
                RefreshOptionAppearance()
                GameTooltip:Hide()
            end)
            optionButton:SetScript("OnMouseDown", function()
                if optionTotal == 0 then
                    return
                end
                optionButton:SetBackdropColor(0.04, 0.12, 0.15, 1)
                optionSymbol:ClearAllPoints()
                optionSymbol:SetPoint("CENTER", optionButton, "CENTER", 1, -1)
            end)
            optionButton:SetScript("OnMouseUp", function()
                if optionTotal == 0 then
                    return
                end
                optionSymbol:ClearAllPoints()
                optionSymbol:SetPoint("CENTER", optionButton, "CENTER", 0, 0)
            end)
            optionButton:SetScript("OnClick", function()
                if optionTotal == 0 then
                    return
                end
                ui.ShowCardOptionEditor(block.step, function(optionValues)
                    block.step.optionValues = optionValues
                    editor.selectedFlowIndex = block.index
                    editor.RedrawFlow()
                end)
            end)
        end

        local visibilityButton = CreateFrame("Button", nil, block)
        visibilityButton:SetWidth(24)
        visibilityButton:SetHeight(24)
        visibilityButton:SetPoint("RIGHT", block, "RIGHT", -74, 0)
        ApplyFlatBackdrop(visibilityButton, 0.08, 0.16, 0.24, 0.98)

        -- O 表示显示在最小化栏，— 表示从最小化栏隐藏。
        local visibilityText = visibilityButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        -- 字体的 O 基线视觉上偏高，向下修正以对齐相邻按钮。
        visibilityText:SetPoint("CENTER", visibilityButton, "CENTER", 0, -1)
        visibilityText:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")

        local function RefreshVisibilityAppearance()
            visibilityButton:SetBackdropColor(0.08, 0.16, 0.24, 0.98)
            visibilityButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            if block.step.minimizedVisible == 0 then
                visibilityText:SetText("—")
                visibilityText:SetTextColor(0.52, 0.56, 0.62)
            else
                visibilityText:SetText("O")
                visibilityText:SetTextColor(0.62, 0.82, 1)
            end
        end
        RefreshVisibilityAppearance()

        -- 非选中状态只用低对比度文字提示隐藏，不占用操作按钮样式。
        local hiddenStatusText = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        hiddenStatusText:SetPoint("RIGHT", block, "RIGHT", -12, 0)
        hiddenStatusText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        hiddenStatusText:SetTextColor(0.48, 0.54, 0.62)
        hiddenStatusText:SetText(Cat2.L("隐"))
        hiddenStatusText:Hide()

        visibilityButton:SetScript("OnEnter", function()
            visibilityButton:SetBackdropColor(0.12, 0.3, 0.42, 1)
            GameTooltip:SetOwner(visibilityButton, "ANCHOR_RIGHT")
            if block.step.minimizedVisible == 0 then
                GameTooltip:SetText(Cat2.L("显示在流程快捷小窗"))
            else
                GameTooltip:SetText(Cat2.L("从流程快捷小窗隐藏"))
            end
        end)
        visibilityButton:SetScript("OnLeave", function()
            RefreshVisibilityAppearance()
            GameTooltip:Hide()
        end)
        visibilityButton:SetScript("OnMouseDown", function()
            visibilityButton:SetBackdropColor(0.04, 0.1, 0.16, 1)
        end)
        visibilityButton:SetScript("OnMouseUp", function()
            RefreshVisibilityAppearance()
        end)
        visibilityButton:SetScript("OnClick", function()
            if block.step.isMissing then
                return
            end
            if block.step.minimizedVisible == 0 then
                block.step.minimizedVisible = 1
            else
                block.step.minimizedVisible = 0
            end
            editor.selectedFlowIndex = block.index
            editor.RedrawFlow()
        end)

        local pauseButton = CreateFrame("Button", nil, block)
        pauseButton:SetWidth(24)
        pauseButton:SetHeight(24)
        pauseButton:SetPoint("RIGHT", block, "RIGHT", -44, 0)
        ApplyFlatBackdrop(pauseButton, 0.1, 0.18, 0.28, 0.98)

        -- 旧客户端会压缩连续的 || 字距，因此拆成两个独立字符以稳定显示暂停符号。
        local pauseLeftText = pauseButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        pauseLeftText:SetPoint("CENTER", pauseButton, "CENTER", -3, 0)
        pauseLeftText:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
        pauseLeftText:SetTextColor(0.55, 0.8, 1)
        pauseLeftText:SetText("|")

        local pauseRightText = pauseButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        pauseRightText:SetPoint("CENTER", pauseButton, "CENTER", 3, 0)
        pauseRightText:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
        pauseRightText:SetTextColor(0.55, 0.8, 1)
        pauseRightText:SetText("|")

        local resumeText = pauseButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        -- > 字形视觉重心偏低，向上微调一像素。
        resumeText:SetPoint("CENTER", pauseButton, "CENTER", 1, 1)
        resumeText:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
        if step.enabled == 0 then
            pauseLeftText:Hide()
            pauseRightText:Hide()
            resumeText:SetTextColor(0.45, 0.85, 0.5)
            resumeText:SetText(">")
        else
            resumeText:Hide()
        end

        pauseButton:SetScript("OnClick", function()
            if block.step.isMissing then
                return
            end
            if block.step.enabled == 0 then
                Cat2.SetFlowStepEnabled(editor.selectedSteps, block.step, 1)
            else
                Cat2.SetFlowStepEnabled(editor.selectedSteps, block.step, 0)
            end
            editor.selectedFlowIndex = block.index
            editor.RedrawFlow()
        end)
        pauseButton:SetScript("OnEnter", function()
            pauseButton:SetBackdropColor(0.14, 0.28, 0.42, 1)
            GameTooltip:SetOwner(pauseButton, "ANCHOR_RIGHT")
            if block.step.enabled == 0 then
                GameTooltip:SetText(Cat2.L("恢复此流程步骤"))
            else
                GameTooltip:SetText(Cat2.L("暂停此流程步骤"))
            end
        end)
        pauseButton:SetScript("OnLeave", function()
            pauseButton:SetBackdropColor(0.1, 0.18, 0.28, 0.98)
            GameTooltip:Hide()
        end)

        local deleteButton = CreateFrame("Button", nil, block)
        deleteButton:SetWidth(24)
        deleteButton:SetHeight(24)
        deleteButton:SetPoint("RIGHT", block, "RIGHT", -14, 0)
        ApplyFlatBackdrop(deleteButton, 0.35, 0.08, 0.08, 0.98)

        local deleteText = deleteButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        deleteText:SetPoint("CENTER", deleteButton, "CENTER", 0, 0)
        deleteText:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
        deleteText:SetTextColor(1, 0.4, 0.4)
        deleteText:SetText("X")

        deleteButton:SetScript("OnEnter", function()
            deleteButton:SetBackdropColor(0.58, 0.1, 0.1, 1)
            GameTooltip:SetOwner(deleteButton, "ANCHOR_RIGHT")
            GameTooltip:SetText(Cat2.L("从当前流程删除此卡片"))
        end)
        deleteButton:SetScript("OnLeave", function()
            deleteButton:SetBackdropColor(0.35, 0.08, 0.08, 0.98)
            GameTooltip:Hide()
        end)
        deleteButton:SetScript("OnClick", function()
            table.remove(editor.selectedSteps, block.index)
            editor.selectedFlowIndex = nil
            editor.RedrawFlow()
        end)

        if block.index == editor.selectedFlowIndex then
            hiddenStatusText:Hide()
            if block.step.isMissing then
                visibilityButton:Hide()
                pauseButton:Hide()
            else
                visibilityButton:Show()
                pauseButton:Show()
                if optionButton then
                    optionButton:Show()
                end
            end
            deleteButton:Show()
        else
            visibilityButton:Hide()
            if not block.step.isMissing and block.step.minimizedVisible == 0 then
                hiddenStatusText:Show()
            else
                hiddenStatusText:Hide()
            end
            pauseButton:Hide()
            if optionButton then
                optionButton:Hide()
            end
            deleteButton:Hide()
        end

        block:SetScript("OnClick", function()
            -- 客户端可能在拖动结束后紧接着派发一次点击；该点击不应改变选中状态。
            if block.dragEndedAt and GetTime() - block.dragEndedAt < 0.2 then
                return
            end
            if editor.selectedFlowIndex == block.index then
                editor.selectedFlowIndex = nil
            else
                editor.selectedFlowIndex = block.index
            end
            editor.RedrawFlow()
        end)

        -- 复用流程卡片框体时，集中恢复所有会随实例状态变化的视觉内容。
        block.RefreshState = function()
            block.RefreshOrderText()
            name:SetText(block.step.name)
            description:SetText(editor.GetCardDescriptionText(block.step))
            name:SetTextColor(1, 0.82, 0.2)
            description:SetTextColor(0.82, 0.82, 0.82)
            if typeLabel then
                SetTypeLabelColor(typeLabel, block.step, false)
            end

            ApplyFlatBackdrop(block, 0.1, 0.12, 0.16, 0.95)
            block:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            if block.step.behavior == "logic" then
                ApplyLogicAppearance(block, false, false)
            elseif block.step.behavior == "passive" then
                block:SetBackdropColor(0.145, 0.115, 0.195, 0.95)
                block:SetBackdropBorderColor(0.38, 0.35, 0.56, 0.9)
            end

            block.normalAlpha = 1
            local stateIconIndex = 1
            while stateIconIndex <= table.getn(cardIcons) do
                cardIcons[stateIconIndex]:SetAlpha(1)
                stateIconIndex = stateIconIndex + 1
            end
            if groupMarker then
                groupMarker:SetAlpha(block.step.enabled == 0 and 0.58 or 0.92)
            end

            if block.step.enabled == 0 then
                -- 与首次创建保持一致：仅正文和底色变暗，功能按钮不继承透明度。
                if block.step.behavior == "logic" then
                    ApplyLogicAppearance(block, true, false)
                elseif block.step.behavior == "passive" then
                    ApplyFlatBackdrop(block, 0.08, 0.06, 0.105, 0.8)
                    block:SetBackdropBorderColor(0.24, 0.21, 0.35, 0.72)
                else
                    ApplyFlatBackdrop(block, 0.055, 0.065, 0.085, 0.8)
                    block:SetBackdropBorderColor(0.2, 0.27, 0.36, 0.72)
                end
                name:SetTextColor(0.58, 0.58, 0.58)
                description:SetTextColor(0.5, 0.5, 0.5)
                if typeLabel then
                    SetTypeLabelColor(typeLabel, block.step, true)
                end
                stateIconIndex = 1
                while stateIconIndex <= table.getn(cardIcons) do
                    cardIcons[stateIconIndex]:SetAlpha(0.5)
                    stateIconIndex = stateIconIndex + 1
                end
            end

            if block.step.isMissing then
                ApplyFlatBackdrop(block, 0.22, 0.07, 0.08, 0.82)
                name:SetTextColor(0.82, 0.52, 0.52)
                description:SetTextColor(0.72, 0.56, 0.56)
                stateIconIndex = 1
                while stateIconIndex <= table.getn(cardIcons) do
                    cardIcons[stateIconIndex]:SetAlpha(0.5)
                    stateIconIndex = stateIconIndex + 1
                end
            end
            block:SetAlpha(block.normalAlpha)

            RefreshVisibilityAppearance()
            pauseLeftText:Hide()
            pauseRightText:Hide()
            resumeText:Hide()
            if block.step.enabled == 0 then
                resumeText:SetTextColor(0.45, 0.85, 0.5)
                resumeText:SetText(">")
                resumeText:Show()
            else
                pauseLeftText:Show()
                pauseRightText:Show()
            end

            visibilityButton:Hide()
            pauseButton:Hide()
            deleteButton:Hide()
            hiddenStatusText:Hide()
            if optionButton then
                optionButton:Hide()
            end
            if block.index == editor.selectedFlowIndex then
                if not block.step.isMissing then
                    visibilityButton:Show()
                    pauseButton:Show()
                    if optionButton then
                        optionButton:Show()
                    end
                end
                deleteButton:Show()
            elseif not block.step.isMissing and block.step.minimizedVisible == 0 then
                hiddenStatusText:Show()
            end
        end
    end

    if not fromFlow then
        block.RefreshState = function()
            name:SetText(block.step.name)
            description:SetText(editor.GetCardDescriptionText(block.step))
            block:SetAlpha(1)
            if block.step.behavior == "logic" then
                ApplyLogicAppearance(block, false, false)
            elseif block.step.behavior == "passive" then
                block:SetBackdropColor(0.145, 0.115, 0.195, 0.95)
                block:SetBackdropBorderColor(0.38, 0.35, 0.56, 0.9)
            else
                block:SetBackdropColor(0.1, 0.12, 0.16, 0.95)
                block:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            end
        end
    end

    local tooltipFontState = nil
    local function RestoreCardTooltipFont()
        if not tooltipFontState then
            return
        end
        if tooltipFontState.titleLine and tooltipFontState.titleFontPath and tooltipFontState.titleFontSize then
            tooltipFontState.titleLine:SetFont(
                tooltipFontState.titleFontPath,
                tooltipFontState.titleFontSize,
                tooltipFontState.titleFontFlags
            )
        end
        if tooltipFontState.detailLine and tooltipFontState.detailFontPath and tooltipFontState.detailFontSize then
            tooltipFontState.detailLine:SetFont(
                tooltipFontState.detailFontPath,
                tooltipFontState.detailFontSize,
                tooltipFontState.detailFontFlags
            )
        end
        tooltipFontState = nil
    end

    block:SetScript("OnDragStart", function()
        RestoreCardTooltipFont()
        GameTooltip:Hide()
        block:SetAlpha(0.25)
        if block.step.behavior == "logic" then
            ApplyLogicAppearance(editor.dragGhost, false, false)
        else
            ApplyFlatBackdrop(editor.dragGhost, 0.08, 0.12, 0.18, 0.96)
        end
        editor.dragGhost.icon:SetTexture(Cat2.GetCardPrimaryIcon(block.step))
        editor.dragGhost.name:SetText(block.step.name)
        editor.dragGhost.description:SetText(editor.GetCardDescriptionText(block.step))
        editor.dragGhost:Show()
        editor.UpdateDragGhost()
    end)
    block:SetScript("OnDragStop", function()
        block.dragEndedAt = GetTime()
        block:SetAlpha(block.normalAlpha)
        editor.dragGhost:Hide()
        editor.dropIndicator:Hide()
        if not IsCursorInside(editor.flowScroll) then
            return
        end

        local insertIndex = GetFlowInsertIndex()
        if block.fromFlow then
            -- 记住原先选中的卡片对象；重排后重新定位它，避免拖动自动选中当前卡片。
            local selectedStep = nil
            if editor.selectedFlowIndex then
                selectedStep = editor.selectedSteps[editor.selectedFlowIndex]
            end
            table.remove(editor.selectedSteps, block.index)
            if insertIndex > block.index then
                insertIndex = insertIndex - 1
            end
            table.insert(editor.selectedSteps, insertIndex, block.step)
            editor.selectedFlowIndex = nil
            if selectedStep then
                local selectedIndex = 1
                local selectedTotal = table.getn(editor.selectedSteps)
                while selectedIndex <= selectedTotal do
                    if editor.selectedSteps[selectedIndex] == selectedStep then
                        editor.selectedFlowIndex = selectedIndex
                        break
                    end
                    selectedIndex = selectedIndex + 1
                end
            end
        else
            if not Cat2.CanAddCardForPlayer(block.step) then
                ShowNotice(Cat2.L("当前正在预览其他职业。\n只有角色本职业可用的共享卡片能够加入流程。"))
                return
            end
            if table.getn(editor.selectedSteps) >= editor.maximumFlowSteps then
                ShowNotice(Cat2.L("流程卡片已经装满，最多可放置 ") .. editor.maximumFlowSteps .. Cat2.L(" 张卡片。"))
                return
            end
            if block.step.unique then
                local existingIndex = 1
                local existingTotal = table.getn(editor.selectedSteps)
                while existingIndex <= existingTotal do
                    if editor.selectedSteps[existingIndex].id == block.step.id then
                        ShowNotice(Cat2.L("被动卡片「") .. block.step.name .. Cat2.L("」在同一配置中只能放置一张。"))
                        return
                    end
                    existingIndex = existingIndex + 1
                end
            end
            local newStep = editor.CreateFlowStep(block.step)
            table.insert(editor.selectedSteps, insertIndex, newStep)
            Cat2.SetFlowStepEnabled(editor.selectedSteps, newStep, 1)
        end
        editor.RedrawFlow()
    end)
    block:SetScript("OnEnter", function()
        if block.step.isMissing then
            -- 缺失卡片悬停时只提高暗红色亮度，不切回普通卡片的蓝灰色。
            block:SetBackdropColor(0.3, 0.1, 0.11, 0.9)
            if block.SetOrderTextAppearance then
                block.SetOrderTextAppearance(0.92, 0.5, 0.52, 0.88)
            end
        else
            if block.step.behavior == "logic" then
                ApplyLogicAppearance(block, block.step.enabled == 0 and block.fromFlow, true)
                if block.SetOrderTextAppearance then block.SetOrderTextAppearance(0.76, 0.51, 0.28, 0.88) end
            elseif block.step.behavior == "passive" then
                block:SetBackdropColor(0.215, 0.17, 0.275, 0.98)
                block:SetBackdropBorderColor(0.48, 0.41, 0.65, 0.95)
                if block.SetOrderTextAppearance then
                    block.SetOrderTextAppearance(0.78, 0.62, 0.96, 0.88)
                end
            else
                block:SetBackdropColor(0.16, 0.2, 0.27, 0.98)
                block:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
                if block.SetOrderTextAppearance then
                    block.SetOrderTextAppearance(0.64, 0.82, 1, 0.88)
                end
            end
        end

        -- 仅右侧可用卡片槽展示详情；左侧流程槽以排序和操作为主，避免 Tooltip 干扰。
        local details = block.step.details
        if not block.fromFlow and details and details ~= "" then
            GameTooltip:SetOwner(block, "ANCHOR_LEFT")
            GameTooltip:ClearLines()

            -- 标题与正文由 name、details 组合；同时兼容旧配置中带有“卡名：”前缀的详情。
            local detailText = details
            local detailPrefix = block.step.name .. "："
            if string.sub(detailText, 1, string.len(detailPrefix)) == detailPrefix then
                detailText = string.sub(detailText, string.len(detailPrefix) + 1)
            end
            GameTooltip:AddLine(block.step.name, 1, 0.66, 0.16, false)
            GameTooltip:AddLine(detailText, 0.92, 0.94, 1, true)

            -- 显示前调整字号，让 Tooltip 按最终字体重新计算高度，避免底部出现多余留白。
            local titleLine = getglobal("GameTooltipTextLeft1")
            local detailLine = getglobal("GameTooltipTextLeft2")
            local titleFontPath = nil
            local titleFontSize = nil
            local titleFontFlags = nil
            local detailFontPath = nil
            local detailFontSize = nil
            local detailFontFlags = nil
            if titleLine then
                titleFontPath, titleFontSize, titleFontFlags = titleLine:GetFont()
            end
            if detailLine then
                detailFontPath, detailFontSize, detailFontFlags = detailLine:GetFont()
            end
            tooltipFontState = {
                titleLine = titleLine,
                titleFontPath = titleFontPath,
                titleFontSize = titleFontSize,
                titleFontFlags = titleFontFlags,
                detailLine = detailLine,
                detailFontPath = detailFontPath,
                detailFontSize = detailFontSize,
                detailFontFlags = detailFontFlags,
            }
            local function AdjustTooltipLineFont(line, sizeOffset)
                if not line then
                    return
                end
                local fontPath, fontSize, fontFlags = line:GetFont()
                if fontPath and fontSize then
                    line:SetFont(fontPath, math.max(8, fontSize + sizeOffset), fontFlags)
                end
            end
            AdjustTooltipLineFont(titleLine, -1)
            AdjustTooltipLineFont(detailLine, 1)
            GameTooltip:Show()
        end
    end)
    block:SetScript("OnLeave", function()
        RestoreCardTooltipFont()
        GameTooltip:Hide()
        if block.SetOrderTextAppearance then
            block.SetOrderTextAppearance(0.44, 0.54, 0.65, 0.38)
        end
        if block.step.isMissing then
            block:SetBackdropColor(0.22, 0.07, 0.08, 0.82)
        else
            if block.step.behavior == "logic" then
                ApplyLogicAppearance(block, block.fromFlow and block.step.enabled == 0, false)
            elseif block.step.behavior == "passive" then
                block:SetBackdropColor(0.145, 0.115, 0.195, 0.95)
                block:SetBackdropBorderColor(0.38, 0.35, 0.56, 0.9)
            else
                block:SetBackdropColor(0.1, 0.12, 0.16, 0.95)
                block:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            end
        end
    end)

    return block
end
