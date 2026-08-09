-- PlayerInformation 调试小窗：按分组、字段、值三列展示运行时数据。
Cat2.UI = Cat2.UI or {}
local ui = Cat2.UI
local ApplyFlatBackdrop = ui.ApplyFlatBackdrop
local debugWindow = nil
local rowPool = {}
local refreshElapsed = 0

local basicFields = {
    "name", "guid", "realm", "localizedClass", "classFile",
    "localizedRace", "raceFile", "faction", "sex", "level"
}

local temporaryFields = {
    "initialized", "inCombat", "health", "maximumHealth", "percentHealth",
    "power", "maximumPower", "powerType", "mana", "maxMana", "percentMana",
    "gcd", "behind", "targetExists", "targetName", "targetLevel",
    "targetClassification", "targetCreatureType", "targetCanAttack",
    "targetIsDead", "targetInCombat", "targetCombo", "targetBleed",
    "targetHealth", "lastRefreshTime", "buff", "targetBuff"
}

local function CreateActionButton(parent, textValue, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(height)
    ApplyFlatBackdrop(button, 0.08, 0.18, 0.27, 0.98)
    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER", button, "CENTER", 0, 0)
    text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    text:SetTextColor(0.78, 0.9, 1)
    text:SetText(textValue)
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
    return button
end

local function FormatValue(value)
    local valueType = type(value)
    if valueType == "nil" then
        return "|cff687486nil|r"
    end
    if valueType == "boolean" then
        if value then
            return "|cff72d990true|r"
        end
        return "|cffdd7777false|r"
    end
    if valueType == "number" then
        local rounded = math.floor(value * 100 + 0.5) / 100
        return "|cffffd34e" .. tostring(rounded) .. "|r"
    end
    if valueType == "string" then
        if value == "" then
            return "|cff687486" .. Cat2.L("空字符串") .. "|r"
        end
        return value
    end
    return "|cffb58ad9" .. valueType .. "|r"
end

local function AddRow(rows, section, key, value)
    table.insert(rows, {
        section = section,
        key = key,
        value = value
    })
end

local function AppendValue(rows, section, key, value, visited)
    if type(value) ~= "table" then
        AddRow(rows, section, key, FormatValue(value))
        return
    end
    if visited[value] then
        AddRow(rows, section, key, "|cffff7777" .. Cat2.L("循环引用") .. "|r")
        return
    end
    visited[value] = true
    local keys = {}
    for childKey in pairs(value) do
        table.insert(keys, childKey)
    end
    table.sort(keys, function(left, right)
        return tostring(left) < tostring(right)
    end)
    local total = table.getn(keys)
    if total == 0 then
        AddRow(rows, section, key, "|cff687486" .. Cat2.L("空表") .. "|r")
    else
        local index = 1
        while index <= total do
            local childKey = keys[index]
            AppendValue(rows, section, key .. "." .. tostring(childKey), value[childKey], visited)
            index = index + 1
        end
    end
    visited[value] = nil
end

local function AppendSection(rows, sectionName, source, orderedFields)
    local known = {}
    local index = 1
    local total = table.getn(orderedFields)
    while index <= total do
        local key = orderedFields[index]
        known[key] = true
        local value = nil
        if source then
            value = source[key]
        end
        AppendValue(rows, sectionName, key, value, {})
        index = index + 1
    end
    local extraKeys = {}
    if source then
        for key in pairs(source) do
            if not known[key] then
                table.insert(extraKeys, key)
            end
        end
    end
    table.sort(extraKeys, function(left, right)
        return tostring(left) < tostring(right)
    end)
    index = 1
    total = table.getn(extraKeys)
    while index <= total do
        local key = extraKeys[index]
        AppendValue(rows, sectionName, tostring(key), source[key], {})
        index = index + 1
    end
end

local function CreateDataRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:SetWidth(500)
    row:SetHeight(19)

    local background = row:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(row)
    background:SetTexture("Interface\\Buttons\\WHITE8X8")
    if math.floor(index / 2) * 2 == index then
        background:SetVertexColor(0.08, 0.11, 0.16, 0.7)
    else
        background:SetVertexColor(0.05, 0.075, 0.11, 0.55)
    end

    local section = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    section:SetPoint("LEFT", row, "LEFT", 7, 0)
    section:SetWidth(62)
    section:SetJustifyH("LEFT")
    section:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    section:SetTextColor(0.48, 0.8, 1)

    local key = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    key:SetPoint("LEFT", row, "LEFT", 76, 0)
    key:SetWidth(236)
    key:SetJustifyH("LEFT")
    key:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    key:SetTextColor(0.78, 0.84, 0.92)

    local value = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    value:SetPoint("LEFT", row, "LEFT", 320, 0)
    value:SetWidth(173)
    value:SetJustifyH("LEFT")
    value:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    value:SetTextColor(0.92, 0.94, 0.98)

    row.sectionText = section
    row.keyText = key
    row.valueText = value
    return row
end

local function RefreshRows()
    if not debugWindow or not debugWindow:IsVisible() then
        return
    end
    if Cat2.RefreshPlayerTemporaryInformation then
        pcall(Cat2.RefreshPlayerTemporaryInformation)
    end
    local information = Cat2.PlayerInformation or {}
    local rows = {}
    AppendSection(rows, Cat2.L("基础"), information.basic or {}, basicFields)
    AppendSection(rows, Cat2.L("临时"), information.temporary or {}, temporaryFields)

    local index = 1
    local total = table.getn(rows)
    while index <= total do
        local row = rowPool[index]
        if not row then
            row = CreateDataRow(debugWindow.content, index)
            rowPool[index] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", debugWindow.content, "TOPLEFT", 0, -((index - 1) * 19))
        row.sectionText:SetText(rows[index].section)
        row.keyText:SetText(rows[index].key)
        row.valueText:SetText(rows[index].value)
        row:Show()
        index = index + 1
    end
    local poolTotal = table.getn(rowPool)
    while index <= poolTotal do
        rowPool[index]:Hide()
        index = index + 1
    end
    local contentHeight = total * 19
    if contentHeight < debugWindow.scroll:GetHeight() then
        contentHeight = debugWindow.scroll:GetHeight()
    end
    debugWindow.content:SetHeight(contentHeight)
    debugWindow.scroll:UpdateScrollChildRect()
    local maximum = contentHeight - debugWindow.scroll:GetHeight()
    if maximum < 0 then
        maximum = 0
    end
    debugWindow.slider:SetMinMaxValues(0, maximum)
    if debugWindow.slider:GetValue() > maximum then
        debugWindow.slider:SetValue(maximum)
    end
    debugWindow.countText:SetText(Cat2.L("字段：") .. total)
end

local function CreateDebugWindow()
    if debugWindow then
        return
    end
    debugWindow = CreateFrame("Frame", "Cat2PlayerDebugWindow", UIParent)
    debugWindow:SetWidth(550)
    debugWindow:SetHeight(555)
    debugWindow:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
    -- 调试窗需要完整显示在主编辑器之上，但仍低于确认和输入类弹窗。
    debugWindow:SetFrameStrata("FULLSCREEN_DIALOG")
    debugWindow:SetFrameLevel(90)
    debugWindow:SetMovable(true)
    debugWindow:SetClampedToScreen(true)
    debugWindow:EnableMouse(true)
    debugWindow:RegisterForDrag("LeftButton")
    ApplyFlatBackdrop(debugWindow, 0.035, 0.05, 0.075, 0.98)
    debugWindow:SetScript("OnDragStart", function()
        debugWindow:StartMoving()
    end)
    debugWindow:SetScript("OnDragStop", function()
        debugWindow:StopMovingOrSizing()
    end)
    debugWindow:SetScript("OnUpdate", function()
        refreshElapsed = refreshElapsed + arg1
        if refreshElapsed >= 0.25 then
            refreshElapsed = 0
            RefreshRows()
        end
    end)
    debugWindow:SetScript("OnShow", function()
        refreshElapsed = 0
        RefreshRows()
        if ui.RefreshPlayerDebugSetting then
            ui.RefreshPlayerDebugSetting()
        end
    end)
    debugWindow:SetScript("OnHide", function()
        if ui.RefreshPlayerDebugSetting then
            ui.RefreshPlayerDebugSetting()
        end
    end)

    local title = debugWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", debugWindow, "TOPLEFT", 16, -14)
    title:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
    title:SetTextColor(1, 0.78, 0.16)
    title:SetText(Cat2.L("PlayerInformation 调试"))

    local countText = debugWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    countText:SetPoint("TOPRIGHT", debugWindow, "TOPRIGHT", -54, -18)
    countText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    countText:SetTextColor(0.55, 0.65, 0.76)
    debugWindow.countText = countText

    local close = CreateActionButton(debugWindow, "X", 26, 24)
    close:SetPoint("TOPRIGHT", debugWindow, "TOPRIGHT", -12, -10)
    close:SetScript("OnClick", function()
        debugWindow:Hide()
    end)

    local header = CreateFrame("Frame", nil, debugWindow)
    header:SetWidth(500)
    header:SetHeight(22)
    header:SetPoint("TOPLEFT", debugWindow, "TOPLEFT", 18, -46)
    ApplyFlatBackdrop(header, 0.08, 0.15, 0.22, 1)
    local labels = { Cat2.L("分组"), Cat2.L("字段"), Cat2.L("值") }
    local offsets = { 7, 76, 320 }
    local widths = { 62, 236, 173 }
    local labelIndex = 1
    while labelIndex <= 3 do
        local label = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", header, "LEFT", offsets[labelIndex], 0)
        label:SetWidth(widths[labelIndex])
        label:SetJustifyH("LEFT")
        label:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        label:SetTextColor(0.64, 0.86, 1)
        label:SetText(labels[labelIndex])
        labelIndex = labelIndex + 1
    end

    local scroll = CreateFrame("ScrollFrame", nil, debugWindow)
    scroll:SetWidth(500)
    scroll:SetHeight(458)
    scroll:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
    scroll:EnableMouseWheel(true)
    debugWindow.scroll = scroll

    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(500)
    content:SetHeight(458)
    scroll:SetScrollChild(content)
    debugWindow.content = content

    local slider = CreateFrame("Slider", nil, debugWindow)
    slider:SetOrientation("VERTICAL")
    slider:SetWidth(18)
    slider:SetHeight(458)
    slider:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 4, 0)
    slider:SetMinMaxValues(0, 0)
    slider:SetValueStep(19)
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetTexture("Interface\\Buttons\\WHITE8X8")
    track:SetPoint("TOP", slider, "TOP", 0, 0)
    track:SetPoint("BOTTOM", slider, "BOTTOM", 0, 0)
    track:SetWidth(5)
    track:SetVertexColor(0.12, 0.2, 0.3, 1)
    slider:SetScript("OnValueChanged", function()
        scroll:SetVerticalScroll(arg1)
    end)
    debugWindow.slider = slider

    scroll:SetScript("OnMouseWheel", function()
        local value = slider:GetValue() - arg1 * 57
        local minimum, maximum = slider:GetMinMaxValues()
        if value < minimum then
            value = minimum
        end
        if value > maximum then
            value = maximum
        end
        slider:SetValue(value)
    end)
    debugWindow:Hide()
end

function ui.TogglePlayerDebugWindow()
    CreateDebugWindow()
    if debugWindow:IsVisible() then
        debugWindow:Hide()
    else
        debugWindow:Show()
    end
end

function ui.IsPlayerDebugWindowVisible()
    return debugWindow and debugWindow:IsVisible() and true or false
end

function ui.HidePlayerDebugWindow()
    if debugWindow then
        debugWindow:Hide()
    end
end
