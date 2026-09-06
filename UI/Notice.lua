-- 可被任意功能调用的基础提示弹窗。
-- 弹窗延迟创建并在后续调用中复用，避免重复生成游戏框体。
Cat2.UI = Cat2.UI or {}
local ui = Cat2.UI
-- 弹窗框体与正文文本：首次调用 ShowNotice 时创建。
local noticeWindow = nil
local noticeText = nil
local confirmWindow = nil
local confirmText = nil
local confirmButtonText = nil
local pendingConfirm = nil
local inputWindow = nil
local inputTitle = nil
local inputBox = nil
local inputError = nil
local inputSubmitText = nil
local pendingInputSubmit = nil
local pendingInputValidator = nil
local cardOptionsWindow = nil
local cardOptionsTitle = nil
local cardOptionsError = nil
local cardOptionsRows = {}
local pendingCardOptionsSubmit = nil
local activeCardOptionsSelectMenu = nil

local function HideActiveCardOptionsSelectMenu()
    if activeCardOptionsSelectMenu then
        activeCardOptionsSelectMenu:Hide()
        activeCardOptionsSelectMenu = nil
    end
end

-- 显示一条提示；高度按消息中的换行数量自适应。
function ui.ShowNotice(message)
    if ui.CloseAllDialogs then
        ui.CloseAllDialogs()
    end
    if ui.HideSettingsWindow then
        ui.HideSettingsWindow()
    end
    if not noticeWindow then
        noticeWindow = CreateFrame("Frame", nil, UIParent)
        noticeWindow:SetWidth(340)
        noticeWindow:SetHeight(92)
        noticeWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
        -- 普通提示也必须整体高于主界面的中央鼠标拦截层，避免按钮中部被覆盖。
        noticeWindow:SetFrameStrata("FULLSCREEN_DIALOG")
        -- 必须高于配置管理窗等 FULLSCREEN_DIALOG 界面，确保容量限制等提示不会被底层窗口遮住。
        noticeWindow:SetFrameLevel(200)
        ui.ApplyFlatBackdrop(noticeWindow, 0.06, 0.08, 0.12, 0.98)

        noticeText = noticeWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noticeText:SetPoint("TOPLEFT", noticeWindow, "TOPLEFT", 14, -14)
        noticeText:SetWidth(312)
        noticeText:SetHeight(44)
        noticeText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        noticeText:SetTextColor(0.86, 0.88, 0.92)
        noticeText:SetJustifyH("CENTER")
        noticeText:SetJustifyV("TOP")
        noticeText:SetSpacing(3)

        local confirmButton = CreateFrame("Button", nil, noticeWindow)
        confirmButton:SetFrameLevel(noticeWindow:GetFrameLevel() + 20)
        confirmButton:EnableMouse(true)
        confirmButton:RegisterForClicks("LeftButtonUp")
        confirmButton:SetWidth(64)
        confirmButton:SetHeight(22)
        confirmButton:SetPoint("BOTTOM", noticeWindow, "BOTTOM", 0, 12)
        ui.ApplyFlatBackdrop(confirmButton, 0.12, 0.28, 0.45, 1)
        local confirmText = confirmButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        confirmText:SetPoint("CENTER", confirmButton, "CENTER", 0, 0)
        confirmText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        confirmText:SetTextColor(0.8, 0.9, 1)
        confirmText:SetText(Cat2.L("确定"))
        confirmButton:SetScript("OnEnter", function()
            confirmButton:SetBackdropColor(0.12, 0.4, 0.58, 1)
            confirmButton:SetBackdropBorderColor(0.45, 0.82, 1, 1)
            confirmText:SetTextColor(1, 0.84, 0.28)
        end)
        confirmButton:SetScript("OnLeave", function()
            confirmButton:SetBackdropColor(0.12, 0.28, 0.45, 1)
            confirmButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            confirmText:SetTextColor(0.8, 0.9, 1)
        end)
        confirmButton:SetScript("OnMouseDown", function()
            confirmButton:SetBackdropColor(0.05, 0.14, 0.22, 1)
            confirmText:ClearAllPoints()
            confirmText:SetPoint("CENTER", confirmButton, "CENTER", 1, -1)
        end)
        confirmButton:SetScript("OnMouseUp", function()
            confirmButton:SetBackdropColor(0.12, 0.4, 0.58, 1)
            confirmText:ClearAllPoints()
            confirmText:SetPoint("CENTER", confirmButton, "CENTER", 0, 0)
        end)
        confirmButton:SetScript("OnClick", function()
            noticeWindow:Hide()
        end)
        noticeWindow:SetScript("OnHide", function()
            ui.HideMainWindowDim()
        end)
        noticeWindow:Hide()
    end
    noticeText:SetText(message)
    local lineCount = 1
    local searchStart = 1
    while true do
        local lineEnd = string.find(message, "\n", searchStart, true)
        if not lineEnd then
            break
        end
        lineCount = lineCount + 1
        searchStart = lineEnd + 1
    end
    local textHeight = lineCount * 16 + (lineCount - 1) * 3
    if textHeight < 44 then
        textHeight = 44
    end
    noticeText:SetHeight(textHeight)
    local contentHeight = textHeight + 68
    if contentHeight < 92 then
        contentHeight = 92
    end
    noticeWindow:SetHeight(contentHeight)
    ui.ShowMainWindowDim()
    noticeWindow:Show()
end

-- 显示带确认与取消按钮的二次确认窗口；确认后才调用传入的回调。
function ui.ShowConfirm(message, onConfirm, confirmLabel)
    if ui.CloseAllDialogs then
        ui.CloseAllDialogs()
    end
    if ui.HideSettingsWindow then
        ui.HideSettingsWindow()
    end
    if not confirmWindow then
        confirmWindow = CreateFrame("Frame", nil, UIParent)
        confirmWindow:SetWidth(300)
        confirmWindow:SetHeight(104)
        confirmWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
        confirmWindow:SetFrameStrata("FULLSCREEN_DIALOG")
        confirmWindow:SetFrameLevel(210)
        confirmWindow:EnableMouse(true)
        confirmWindow:EnableKeyboard(true)
        ui.ApplyFlatBackdrop(confirmWindow, 0.07, 0.08, 0.12, 1)

        confirmText = confirmWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        confirmText:SetPoint("TOPLEFT", confirmWindow, "TOPLEFT", 16, -16)
        confirmText:SetPoint("RIGHT", confirmWindow, "RIGHT", -16, 0)
        confirmText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        confirmText:SetTextColor(0.92, 0.88, 0.82)
        confirmText:SetJustifyH("CENTER")

        local confirmButton = CreateFrame("Button", nil, confirmWindow)
        confirmButton:SetFrameLevel(confirmWindow:GetFrameLevel() + 20)
        confirmButton:EnableMouse(true)
        confirmButton:RegisterForClicks("LeftButtonUp")
        confirmButton:SetWidth(86)
        confirmButton:SetHeight(24)
        confirmButton:SetPoint("BOTTOMRIGHT", confirmWindow, "BOTTOM", -6, 12)
        ui.ApplyFlatBackdrop(confirmButton, 0.38, 0.08, 0.09, 1)
        confirmButtonText = confirmButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        confirmButtonText:SetPoint("CENTER", confirmButton, "CENTER", 0, 0)
        confirmButtonText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        confirmButtonText:SetTextColor(1, 0.7, 0.7)
        confirmButtonText:SetText(Cat2.L("确认删除"))

        local cancelButton = CreateFrame("Button", nil, confirmWindow)
        cancelButton:SetFrameLevel(confirmWindow:GetFrameLevel() + 20)
        cancelButton:EnableMouse(true)
        cancelButton:RegisterForClicks("LeftButtonUp")
        cancelButton:SetWidth(86)
        cancelButton:SetHeight(24)
        cancelButton:SetPoint("BOTTOMLEFT", confirmWindow, "BOTTOM", 6, 12)
        ui.ApplyFlatBackdrop(cancelButton, 0.08, 0.22, 0.34, 1)
        local cancelButtonText = cancelButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cancelButtonText:SetPoint("CENTER", cancelButton, "CENTER", 0, 0)
        cancelButtonText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        cancelButtonText:SetTextColor(0.72, 0.9, 1)
        cancelButtonText:SetText(Cat2.L("取消"))

        confirmButton:SetScript("OnEnter", function()
            confirmButton:SetBackdropColor(0.62, 0.1, 0.12, 1)
            confirmButton:SetBackdropBorderColor(1, 0.4, 0.42, 1)
            confirmButtonText:SetTextColor(1, 0.86, 0.86)
        end)
        confirmButton:SetScript("OnLeave", function()
            confirmButton:SetBackdropColor(0.38, 0.08, 0.09, 1)
            confirmButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            confirmButtonText:SetTextColor(1, 0.7, 0.7)
        end)
        confirmButton:SetScript("OnMouseDown", function()
            confirmButton:SetBackdropColor(0.24, 0.04, 0.05, 1)
            confirmButtonText:ClearAllPoints()
            confirmButtonText:SetPoint("CENTER", confirmButton, "CENTER", 1, -1)
        end)
        confirmButton:SetScript("OnMouseUp", function()
            confirmButton:SetBackdropColor(0.62, 0.1, 0.12, 1)
            confirmButtonText:ClearAllPoints()
            confirmButtonText:SetPoint("CENTER", confirmButton, "CENTER", 0, 0)
        end)

        cancelButton:SetScript("OnEnter", function()
            cancelButton:SetBackdropColor(0.12, 0.4, 0.58, 1)
            cancelButton:SetBackdropBorderColor(0.45, 0.82, 1, 1)
            cancelButtonText:SetTextColor(1, 0.84, 0.28)
        end)
        cancelButton:SetScript("OnLeave", function()
            cancelButton:SetBackdropColor(0.08, 0.22, 0.34, 1)
            cancelButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            cancelButtonText:SetTextColor(0.72, 0.9, 1)
        end)
        cancelButton:SetScript("OnMouseDown", function()
            cancelButton:SetBackdropColor(0.05, 0.14, 0.22, 1)
            cancelButtonText:ClearAllPoints()
            cancelButtonText:SetPoint("CENTER", cancelButton, "CENTER", 1, -1)
        end)
        cancelButton:SetScript("OnMouseUp", function()
            cancelButton:SetBackdropColor(0.12, 0.4, 0.58, 1)
            cancelButtonText:ClearAllPoints()
            cancelButtonText:SetPoint("CENTER", cancelButton, "CENTER", 0, 0)
        end)

        confirmButton:SetScript("OnClick", function()
            local callback = pendingConfirm
            pendingConfirm = nil
            confirmWindow:Hide()
            if callback then
                callback()
            end
        end)
        cancelButton:SetScript("OnClick", function()
            pendingConfirm = nil
            confirmWindow:Hide()
        end)
        confirmWindow:SetScript("OnKeyDown", function()
            if arg1 == "ESCAPE" then
                pendingConfirm = nil
                confirmWindow:Hide()
            end
        end)
        confirmWindow:SetScript("OnHide", function()
            ui.HideMainWindowDim()
        end)
        confirmWindow:Hide()
    end

    pendingConfirm = onConfirm
    confirmText:SetText(message)
    confirmButtonText:SetText(confirmLabel or Cat2.L("确认删除"))
    ui.ShowMainWindowDim()
    confirmWindow:Show()
end

-- 显示带输入框的通用弹窗；验证通过后才提交输入内容。
function ui.ShowTextInput(titleText, initialText, validator, onSubmit, submitLabel)
    if ui.CloseAllDialogs then
        ui.CloseAllDialogs()
    end
    if ui.HideSettingsWindow then
        ui.HideSettingsWindow()
    end
    if not inputWindow then
        inputWindow = CreateFrame("Frame", nil, UIParent)
        inputWindow:SetWidth(340)
        inputWindow:SetHeight(154)
        inputWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
        inputWindow:SetFrameStrata("FULLSCREEN_DIALOG")
        inputWindow:SetFrameLevel(220)
        inputWindow:EnableMouse(true)
        ui.ApplyFlatBackdrop(inputWindow, 0.07, 0.08, 0.12, 1)

        inputTitle = inputWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        inputTitle:SetPoint("TOP", inputWindow, "TOP", 0, -16)
        inputTitle:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        inputTitle:SetTextColor(1, 0.82, 0.2)

        inputBox = CreateFrame("EditBox", nil, inputWindow)
        inputBox:SetFrameLevel(inputWindow:GetFrameLevel() + 10)
        inputBox:SetWidth(292)
        inputBox:SetHeight(28)
        inputBox:SetPoint("TOP", inputWindow, "TOP", 0, -42)
        inputBox:SetAutoFocus(false)
        inputBox:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        inputBox:SetTextColor(0.88, 0.92, 1)
        inputBox:SetTextInsets(7, 7, 0, 0)
        inputBox:SetMaxLetters(48)
        ui.ApplyFlatBackdrop(inputBox, 0.03, 0.05, 0.08, 1)

        inputError = inputWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        inputError:SetPoint("TOP", inputBox, "BOTTOM", 0, -7)
        inputError:SetWidth(300)
        inputError:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        inputError:SetTextColor(1, 0.42, 0.42)
        inputError:SetJustifyH("CENTER")

        local submitButton = CreateFrame("Button", nil, inputWindow)
        submitButton:SetFrameLevel(inputWindow:GetFrameLevel() + 20)
        submitButton:EnableMouse(true)
        submitButton:RegisterForClicks("LeftButtonUp")
        submitButton:SetWidth(86)
        submitButton:SetHeight(24)
        submitButton:SetPoint("BOTTOMRIGHT", inputWindow, "BOTTOM", -6, 12)
        ui.ApplyFlatBackdrop(submitButton, 0.08, 0.28, 0.18, 1)
        inputSubmitText = submitButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        inputSubmitText:SetPoint("CENTER", submitButton, "CENTER", 0, 0)
        inputSubmitText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        inputSubmitText:SetTextColor(0.68, 1, 0.76)

        local cancelButton = CreateFrame("Button", nil, inputWindow)
        cancelButton:SetFrameLevel(inputWindow:GetFrameLevel() + 20)
        cancelButton:EnableMouse(true)
        cancelButton:RegisterForClicks("LeftButtonUp")
        cancelButton:SetWidth(86)
        cancelButton:SetHeight(24)
        cancelButton:SetPoint("BOTTOMLEFT", inputWindow, "BOTTOM", 6, 12)
        ui.ApplyFlatBackdrop(cancelButton, 0.08, 0.22, 0.34, 1)
        local cancelText = cancelButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cancelText:SetPoint("CENTER", cancelButton, "CENTER", 0, 0)
        cancelText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        cancelText:SetTextColor(0.72, 0.9, 1)
        cancelText:SetText(Cat2.L("取消"))

        submitButton:SetScript("OnEnter", function()
            submitButton:SetBackdropColor(0.1, 0.46, 0.24, 1)
            inputSubmitText:SetTextColor(0.82, 1, 0.86)
        end)
        submitButton:SetScript("OnLeave", function()
            submitButton:SetBackdropColor(0.08, 0.28, 0.18, 1)
            inputSubmitText:SetTextColor(0.68, 1, 0.76)
        end)
        submitButton:SetScript("OnMouseDown", function()
            submitButton:SetBackdropColor(0.04, 0.18, 0.1, 1)
            inputSubmitText:ClearAllPoints()
            inputSubmitText:SetPoint("CENTER", submitButton, "CENTER", 1, -1)
        end)
        submitButton:SetScript("OnMouseUp", function()
            submitButton:SetBackdropColor(0.1, 0.46, 0.24, 1)
            inputSubmitText:ClearAllPoints()
            inputSubmitText:SetPoint("CENTER", submitButton, "CENTER", 0, 0)
        end)

        cancelButton:SetScript("OnEnter", function()
            cancelButton:SetBackdropColor(0.12, 0.4, 0.58, 1)
            cancelText:SetTextColor(1, 0.84, 0.28)
        end)
        cancelButton:SetScript("OnLeave", function()
            cancelButton:SetBackdropColor(0.08, 0.22, 0.34, 1)
            cancelText:SetTextColor(0.72, 0.9, 1)
        end)
        cancelButton:SetScript("OnMouseDown", function()
            cancelButton:SetBackdropColor(0.05, 0.14, 0.22, 1)
            cancelText:ClearAllPoints()
            cancelText:SetPoint("CENTER", cancelButton, "CENTER", 1, -1)
        end)
        cancelButton:SetScript("OnMouseUp", function()
            cancelButton:SetBackdropColor(0.12, 0.4, 0.58, 1)
            cancelText:ClearAllPoints()
            cancelText:SetPoint("CENTER", cancelButton, "CENTER", 0, 0)
        end)

        local function SubmitInput()
            local value = inputBox:GetText() or ""
            local valid = true
            local errorMessage = nil
            if pendingInputValidator then
                valid, errorMessage = pendingInputValidator(value)
            end
            if not valid then
                inputError:SetText(errorMessage or Cat2.L("输入内容无效。"))
                return
            end
            local callback = pendingInputSubmit
            pendingInputSubmit = nil
            pendingInputValidator = nil
            inputWindow:Hide()
            if callback then
                callback(value)
            end
        end

        submitButton:SetScript("OnClick", SubmitInput)
        inputBox:SetScript("OnEnterPressed", SubmitInput)
        inputBox:SetScript("OnEscapePressed", function()
            pendingInputSubmit = nil
            pendingInputValidator = nil
            inputWindow:Hide()
        end)
        inputBox:SetScript("OnTextChanged", function()
            inputError:SetText("")
        end)
        cancelButton:SetScript("OnClick", function()
            pendingInputSubmit = nil
            pendingInputValidator = nil
            inputWindow:Hide()
        end)
        inputWindow:SetScript("OnHide", function()
            ui.HideMainWindowDim()
        end)
        inputWindow:Hide()
    end

    pendingInputValidator = validator
    pendingInputSubmit = onSubmit
    inputTitle:SetText(titleText)
    inputSubmitText:SetText(submitLabel or Cat2.L("创建"))
    inputError:SetText("")
    inputBox:SetText(initialText or "")
    ui.ShowMainWindowDim()
    inputWindow:Show()
    inputBox:SetFocus()
    inputBox:HighlightText()
end

function ui.ShowCardOptionEditor(step, onSubmit)
    if type(step) ~= "table" or type(step.optionSchema) ~= "table" or table.getn(step.optionSchema) == 0 then
        return
    end
    if ui.CloseAllDialogs then
        ui.CloseAllDialogs()
    end
    if ui.HideSettingsWindow then
        ui.HideSettingsWindow()
    end

    if not cardOptionsWindow then
        cardOptionsWindow = CreateFrame("Frame", nil, UIParent)
        cardOptionsWindow:SetWidth(420)
        cardOptionsWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
        cardOptionsWindow:SetFrameStrata("FULLSCREEN_DIALOG")
        cardOptionsWindow:SetFrameLevel(220)
        cardOptionsWindow:EnableMouse(true)
        ui.ApplyFlatBackdrop(cardOptionsWindow, 0.07, 0.08, 0.12, 1)

        cardOptionsTitle = cardOptionsWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cardOptionsTitle:SetPoint("TOP", cardOptionsWindow, "TOP", 0, -15)
        cardOptionsTitle:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        cardOptionsTitle:SetTextColor(1, 0.82, 0.2)

        local instruction = cardOptionsWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        instruction:SetPoint("TOP", cardOptionsWindow, "TOP", 0, -36)
        instruction:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
        instruction:SetTextColor(0.58, 0.66, 0.76)
        instruction:SetText(Cat2.L("未设置过的参数会显示卡片默认值；输入项留空或下拉选择默认值可取消独立设置。"))

        cardOptionsError = cardOptionsWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cardOptionsError:SetPoint("BOTTOM", cardOptionsWindow, "BOTTOM", 0, 48)
        cardOptionsError:SetWidth(390)
        cardOptionsError:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        cardOptionsError:SetTextColor(1, 0.42, 0.42)
        cardOptionsError:SetJustifyH("CENTER")

        local saveButton = CreateFrame("Button", nil, cardOptionsWindow)
        saveButton:SetFrameLevel(cardOptionsWindow:GetFrameLevel() + 20)
        saveButton:RegisterForClicks("LeftButtonUp")
        saveButton:SetWidth(92)
        saveButton:SetHeight(24)
        saveButton:SetPoint("BOTTOMRIGHT", cardOptionsWindow, "BOTTOM", -6, 13)
        ui.ApplyFlatBackdrop(saveButton, 0.08, 0.28, 0.18, 1)
        local saveText = saveButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        saveText:SetPoint("CENTER", saveButton, "CENTER", 0, 0)
        saveText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        saveText:SetTextColor(0.68, 1, 0.76)
        saveText:SetText(Cat2.L("保存"))

        local cancelButton = CreateFrame("Button", nil, cardOptionsWindow)
        cancelButton:SetFrameLevel(cardOptionsWindow:GetFrameLevel() + 20)
        cancelButton:RegisterForClicks("LeftButtonUp")
        cancelButton:SetWidth(92)
        cancelButton:SetHeight(24)
        cancelButton:SetPoint("BOTTOMLEFT", cardOptionsWindow, "BOTTOM", 6, 13)
        ui.ApplyFlatBackdrop(cancelButton, 0.08, 0.22, 0.34, 1)
        local cancelText = cancelButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cancelText:SetPoint("CENTER", cancelButton, "CENTER", 0, 0)
        cancelText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        cancelText:SetTextColor(0.72, 0.9, 1)
        cancelText:SetText(Cat2.L("取消"))

        saveButton:SetScript("OnEnter", function()
            saveButton:SetBackdropColor(0.1, 0.46, 0.24, 1)
            saveText:SetTextColor(0.82, 1, 0.86)
        end)
        saveButton:SetScript("OnLeave", function()
            saveButton:SetBackdropColor(0.08, 0.28, 0.18, 1)
            saveText:SetTextColor(0.68, 1, 0.76)
        end)
        saveButton:SetScript("OnMouseDown", function()
            saveButton:SetBackdropColor(0.04, 0.18, 0.1, 1)
            saveText:ClearAllPoints()
            saveText:SetPoint("CENTER", saveButton, "CENTER", 1, -1)
        end)
        saveButton:SetScript("OnMouseUp", function()
            saveText:ClearAllPoints()
            saveText:SetPoint("CENTER", saveButton, "CENTER", 0, 0)
        end)
        cancelButton:SetScript("OnEnter", function()
            cancelButton:SetBackdropColor(0.12, 0.4, 0.58, 1)
            cancelText:SetTextColor(1, 0.84, 0.28)
        end)
        cancelButton:SetScript("OnLeave", function()
            cancelButton:SetBackdropColor(0.08, 0.22, 0.34, 1)
            cancelText:SetTextColor(0.72, 0.9, 1)
        end)
        cancelButton:SetScript("OnMouseDown", function()
            cancelButton:SetBackdropColor(0.05, 0.14, 0.22, 1)
            cancelText:ClearAllPoints()
            cancelText:SetPoint("CENTER", cancelButton, "CENTER", 1, -1)
        end)
        cancelButton:SetScript("OnMouseUp", function()
            cancelText:ClearAllPoints()
            cancelText:SetPoint("CENTER", cancelButton, "CENTER", 0, 0)
        end)

        local function SubmitCardOptions()
            local optionValues = {}
            local currentStep = cardOptionsWindow.currentStep
            local rowIndex = 1
            local rowTotal = table.getn(cardOptionsRows)
            while rowIndex <= rowTotal do
                local row = cardOptionsRows[rowIndex]
                if row.frame:IsVisible() then
                    local definition = row.definition
                    if definition.control == "select" then
                        -- “使用默认值”不写入 optionValues；其余选项只保存稳定 value。
                        if not row.selectUsesDefault then
                            local normalized = Cat2.NormalizeCardOptionValue(definition, row.selectValue, currentStep)
                            if normalized == nil then
                                cardOptionsError:SetText(Cat2.L("「") .. Cat2.L(definition.label or definition.key) .. Cat2.L("」请选择有效选项。"))
                                return
                            end
                            optionValues[definition.key] = normalized
                        end
                    else
                        local value = row.input:GetText() or ""
                        -- 字符串参数允许把空文本作为显式覆写值保存；例如鱼饵名称清空后
                        -- 应表示“不使用鱼饵”，而不是删除覆写并重新继承默认值。
                        if value ~= "" or definition.type == "string" then
                            if definition.type == "number" then
                                local numericValue = tonumber(value)
                                local minimum = Cat2.ResolveCardOptionDefinitionValue(definition, "minimum", currentStep)
                                local maximum = Cat2.ResolveCardOptionDefinitionValue(definition, "maximum", currentStep)
                                if not numericValue or (minimum and numericValue < minimum) or
                                    (maximum and numericValue > maximum) then
                                    local rangeText = tostring(minimum or "-") .. Cat2.L(" 到 ") .. tostring(maximum or "+")
                                    cardOptionsError:SetText(Cat2.L("「") .. Cat2.L(definition.label or definition.key) .. Cat2.L("」请输入 ") .. rangeText .. Cat2.L(" 之间的数字。"))
                                    row.input:SetFocus()
                                    row.input:HighlightText()
                                    return
                                end
                                optionValues[definition.key] = Cat2.NormalizeCardOptionValue(definition, numericValue, currentStep)
                            elseif definition.type == "boolean" then
                                local lowered = string.lower(value)
                                if value == "开启" or value == Cat2.L("开启") or lowered == "true" or value == "1" then
                                    optionValues[definition.key] = true
                                elseif value == "关闭" or value == Cat2.L("关闭") or lowered == "false" or value == "0" then
                                    optionValues[definition.key] = false
                                else
                                    cardOptionsError:SetText(Cat2.L("「") .. Cat2.L(definition.label or definition.key) .. Cat2.L("」请输入开启或关闭。"))
                                    row.input:SetFocus()
                                    row.input:HighlightText()
                                    return
                                end
                            else
                                optionValues[definition.key] = Cat2.NormalizeCardOptionValue(definition, value, currentStep)
                            end
                        end
                    end
                end
                rowIndex = rowIndex + 1
            end
            local callback = pendingCardOptionsSubmit
            pendingCardOptionsSubmit = nil
            cardOptionsWindow:Hide()
            if callback then
                callback(optionValues)
            end
        end

        saveButton:SetScript("OnClick", SubmitCardOptions)
        cancelButton:SetScript("OnClick", function()
            pendingCardOptionsSubmit = nil
            cardOptionsWindow:Hide()
        end)
        cardOptionsWindow.submit = SubmitCardOptions
        cardOptionsWindow:SetScript("OnHide", function()
            HideActiveCardOptionsSelectMenu()
            ui.HideMainWindowDim()
        end)
        cardOptionsWindow:SetScript("OnMouseDown", function()
            HideActiveCardOptionsSelectMenu()
        end)
        cardOptionsWindow:Hide()
    end

    local schemaTotal = table.getn(step.optionSchema)
    cardOptionsWindow:SetHeight(126 + schemaTotal * 38)
    cardOptionsTitle:SetText(Cat2.L("卡片参数：") .. (step.name or Cat2.L("未命名卡片")))
    cardOptionsError:SetText("")
    pendingCardOptionsSubmit = onSubmit
    cardOptionsWindow.currentStep = step
    HideActiveCardOptionsSelectMenu()

    local rowIndex = 1
    while rowIndex <= schemaTotal do
        local definition = step.optionSchema[rowIndex]
        local row = cardOptionsRows[rowIndex]
        if not row then
            local rowFrame = CreateFrame("Frame", nil, cardOptionsWindow)
            rowFrame:SetWidth(380)
            rowFrame:SetHeight(28)
            local label = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            label:SetWidth(112)
            label:SetPoint("LEFT", rowFrame, "LEFT", 0, 0)
            label:SetJustifyH("RIGHT")
            label:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
            label:SetTextColor(0.82, 0.88, 0.96)
            local input = CreateFrame("EditBox", nil, rowFrame)
            input:SetFrameLevel(cardOptionsWindow:GetFrameLevel() + 10)
            input:SetWidth(150)
            input:SetHeight(26)
            input:SetPoint("LEFT", label, "RIGHT", 10, 0)
            input:SetAutoFocus(false)
            input:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
            input:SetTextColor(0.88, 0.92, 1)
            input:SetTextInsets(7, 7, 0, 0)
            input:SetMaxLetters(48)
            ui.ApplyFlatBackdrop(input, 0.03, 0.05, 0.08, 1)
            local unit = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            unit:SetPoint("LEFT", input, "RIGHT", 7, 0)
            unit:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
            unit:SetTextColor(0.62, 0.7, 0.8)

            -- 自绘下拉框；允许自定义值时，输入框与独立箭头按钮组合成可编辑下拉框。
            local selectButton = CreateFrame("Button", nil, rowFrame)
            selectButton:SetFrameLevel(cardOptionsWindow:GetFrameLevel() + 10)
            selectButton:SetWidth(150)
            selectButton:SetHeight(26)
            selectButton:SetPoint("LEFT", label, "RIGHT", 10, 0)
            selectButton:RegisterForClicks("LeftButtonUp")
            ui.ApplyFlatBackdrop(selectButton, 0.03, 0.05, 0.08, 1)
            local selectText = selectButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            selectText:SetPoint("LEFT", selectButton, "LEFT", 7, 0)
            selectText:SetWidth(116)
            selectText:SetJustifyH("LEFT")
            selectText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
            selectText:SetTextColor(0.88, 0.92, 1)
            local selectArrow = selectButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            selectArrow:SetPoint("RIGHT", selectButton, "RIGHT", -7, 1)
            selectArrow:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
            selectArrow:SetTextColor(0.5, 0.8, 1)
            selectArrow:SetText("▼")
            selectButton:Hide()

            local selectArrowButton = CreateFrame("Button", nil, rowFrame)
            selectArrowButton:SetFrameLevel(cardOptionsWindow:GetFrameLevel() + 10)
            selectArrowButton:SetWidth(24)
            selectArrowButton:SetHeight(26)
            selectArrowButton:RegisterForClicks("LeftButtonUp")
            ui.ApplyFlatBackdrop(selectArrowButton, 0.03, 0.05, 0.08, 1)
            local selectArrowButtonText = selectArrowButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            selectArrowButtonText:SetPoint("CENTER", selectArrowButton, "CENTER", 0, 1)
            selectArrowButtonText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
            selectArrowButtonText:SetTextColor(0.5, 0.8, 1)
            selectArrowButtonText:SetText("▼")
            selectArrowButton:Hide()

            local selectMenu = CreateFrame("Frame", nil, cardOptionsWindow)
            selectMenu:SetWidth(172)
            selectMenu:SetFrameLevel(cardOptionsWindow:GetFrameLevel() + 60)
            ui.ApplyFlatBackdrop(selectMenu, 0.035, 0.055, 0.09, 1)
            selectMenu:Hide()

            row = {
                frame = rowFrame,
                label = label,
                input = input,
                unit = unit,
                selectButton = selectButton,
                selectText = selectText,
                selectArrow = selectArrow,
                selectArrowButton = selectArrowButton,
                selectMenu = selectMenu,
                selectEntries = {},
                selectUsesDefault = true,
                selectValue = nil,
                updatingSelectInput = false,
            }
            table.insert(cardOptionsRows, row)

            row.RefreshSelectText = function()
                local value = row.selectValue
                if row.selectUsesDefault then
                    value = Cat2.ResolveCardOptionDefinitionValue(row.definition, "default", row.step)
                    value = Cat2.NormalizeCardOptionValue(row.definition, value, row.step)
                end
                local displayText = Cat2.GetCardOptionDisplayValue(row.definition, value, row.step)
                if not displayText then
                    displayText = Cat2.L("未选择")
                end
                if row.definition.allowCustom == true then
                    -- 可编辑下拉框必须把稳定 value 写进输入框，不能写带颜色码的 label。
                    -- 旧客户端可能在 SetText 后延迟触发 OnTextChanged；若显示 label，事件会把
                    -- “|c...裂雷图腾|r”反写成自定义参数，导致按物品纯名称搜索失败。
                    local inputText = value ~= nil and tostring(value) or ""
                    row.updatingSelectInput = true
                    row.input:SetText(inputText)
                    row.updatingSelectInput = false
                    if row.selectUsesDefault then
                        row.input:SetTextColor(0.64, 0.76, 0.88)
                    else
                        row.input:SetTextColor(1, 0.82, 0.2)
                    end
                    return
                end
                if row.selectUsesDefault then
                    displayText = displayText .. Cat2.L("（默认）")
                    row.selectText:SetTextColor(0.64, 0.76, 0.88)
                else
                    row.selectText:SetTextColor(1, 0.82, 0.2)
                end
                row.selectText:SetText(displayText)
            end

            row.RebuildSelectMenu = function()
                local choices = Cat2.GetCardOptionChoices(row.definition, row.step)
                local defaultValue = Cat2.ResolveCardOptionDefinitionValue(row.definition, "default", row.step)
                defaultValue = Cat2.NormalizeCardOptionValue(row.definition, defaultValue, row.step)
                local defaultLabel = Cat2.GetCardOptionDisplayValue(row.definition, defaultValue, row.step) or Cat2.L("未设置")
                local menuItems = {}
                -- 个别下拉框会把“默认值”本身作为明确选项展示，此时不再重复生成“使用默认值”。
                if row.definition.hideDefaultChoice ~= true then
                    table.insert(menuItems, {
                        useDefault = true,
                        value = nil,
                        label = Cat2.L("使用默认值（") .. defaultLabel .. Cat2.L("）"),
                    })
                end
                local choiceIndex = 1
                local choiceTotal = table.getn(choices)
                while choiceIndex <= choiceTotal do
                    local choice = choices[choiceIndex]
                    if type(choice) == "table" and choice.value ~= nil then
                        table.insert(menuItems, {
                            useDefault = false,
                            value = choice.value,
                            label = tostring(choice.label ~= nil and choice.label or choice.value),
                        })
                    end
                    choiceIndex = choiceIndex + 1
                end

                local oldIndex = 1
                while oldIndex <= table.getn(row.selectEntries) do
                    row.selectEntries[oldIndex]:Hide()
                    oldIndex = oldIndex + 1
                end

                local itemIndex = 1
                local itemTotal = table.getn(menuItems)
                while itemIndex <= itemTotal do
                    local item = menuItems[itemIndex]
                    local entry = row.selectEntries[itemIndex]
                    if not entry then
                        entry = CreateFrame("Button", nil, row.selectMenu)
                        entry:SetWidth(166)
                        entry:SetHeight(24)
                        local highlight = entry:CreateTexture(nil, "BACKGROUND")
                        highlight:SetAllPoints(entry)
                        highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
                        highlight:SetVertexColor(0.12, 0.28, 0.42, 0.65)
                        highlight:Hide()
                        local entryText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        entryText:SetPoint("LEFT", entry, "LEFT", 7, 0)
                        entryText:SetWidth(152)
                        entryText:SetJustifyH("LEFT")
                        entryText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
                        entry.entryText = entryText
                        entry.highlight = highlight
                        entry:SetScript("OnEnter", function()
                            entry.highlight:Show()
                        end)
                        entry:SetScript("OnLeave", function()
                            entry.highlight:Hide()
                        end)
                        row.selectEntries[itemIndex] = entry
                    end
                    entry:ClearAllPoints()
                    entry:SetPoint("TOPLEFT", row.selectMenu, "TOPLEFT", 3, -2 - (itemIndex - 1) * 24)
                    entry.entryText:SetText(Cat2.L(item.label))
                    if (item.useDefault and row.selectUsesDefault) or
                       (not item.useDefault and not row.selectUsesDefault and row.selectValue == item.value) or
                       (not item.useDefault and row.definition.hideDefaultChoice == true and
                        row.selectUsesDefault and defaultValue == item.value) then
                        entry.entryText:SetTextColor(1, 0.82, 0.2)
                    else
                        entry.entryText:SetTextColor(0.78, 0.86, 0.94)
                    end
                    local selectedUseDefault = item.useDefault
                    local selectedValue = item.value
                    entry:SetScript("OnClick", function()
                        row.selectUsesDefault = selectedUseDefault
                        row.selectValue = selectedValue
                        row.RefreshSelectText()
                        row.selectMenu:Hide()
                        activeCardOptionsSelectMenu = nil
                        cardOptionsError:SetText("")
                    end)
                    entry:Show()
                    itemIndex = itemIndex + 1
                end
                row.selectMenu:SetHeight(itemTotal * 24 + 4)
                row.selectMenu:ClearAllPoints()
                if row.definition.allowCustom == true then
                    row.selectMenu:SetPoint("TOPLEFT", row.selectArrowButton, "TOPRIGHT", 5, 0)
                else
                    row.selectMenu:SetPoint("TOPLEFT", row.selectButton, "TOPRIGHT", 5, 0)
                end
            end

            row.ToggleSelectMenu = function()
                if row.selectMenu:IsVisible() then
                    HideActiveCardOptionsSelectMenu()
                    return
                end
                HideActiveCardOptionsSelectMenu()
                row.RebuildSelectMenu()
                activeCardOptionsSelectMenu = row.selectMenu
                row.selectMenu:Show()
            end

            selectButton:SetScript("OnEnter", function()
                selectButton:SetBackdropColor(0.08, 0.2, 0.28, 1)
                selectButton:SetBackdropBorderColor(0.4, 0.68, 0.9, 1)
            end)
            selectButton:SetScript("OnLeave", function()
                selectButton:SetBackdropColor(0.03, 0.05, 0.08, 1)
                selectButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            end)
            selectButton:SetScript("OnClick", function()
                row.ToggleSelectMenu()
            end)
            selectArrowButton:SetScript("OnEnter", function()
                selectArrowButton:SetBackdropColor(0.08, 0.2, 0.28, 1)
                selectArrowButton:SetBackdropBorderColor(0.4, 0.68, 0.9, 1)
            end)
            selectArrowButton:SetScript("OnLeave", function()
                selectArrowButton:SetBackdropColor(0.03, 0.05, 0.08, 1)
                selectArrowButton:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
            end)
            selectArrowButton:SetScript("OnClick", function()
                row.ToggleSelectMenu()
            end)
            input:SetScript("OnEnterPressed", function()
                cardOptionsWindow.submit()
            end)
            input:SetScript("OnEscapePressed", function()
                pendingCardOptionsSubmit = nil
                cardOptionsWindow:Hide()
            end)
            input:SetScript("OnTextChanged", function()
                cardOptionsError:SetText("")
                if row.definition and row.definition.control == "select" and
                   row.definition.allowCustom == true and not row.updatingSelectInput then
                    local value = row.input:GetText() or ""
                    if value == "" then
                        row.selectUsesDefault = true
                        row.selectValue = nil
                    else
                        row.selectUsesDefault = false
                        row.selectValue = value
                    end
                    row.input:SetTextColor(1, 0.82, 0.2)
                end
            end)
            input:SetScript("OnEditFocusGained", function()
                HideActiveCardOptionsSelectMenu()
            end)
            input:SetScript("OnEditFocusLost", function()
                if row.definition and row.definition.control == "select" and
                   row.definition.allowCustom == true and (row.input:GetText() or "") == "" then
                    row.RefreshSelectText()
                end
            end)
        end
        row.definition = definition
        row.frame:ClearAllPoints()
        row.frame:SetPoint("TOP", cardOptionsWindow, "TOP", 0, -55 - (rowIndex - 1) * 38)
        row.label:SetText(Cat2.L(definition.label or definition.key) .. Cat2.L("："))
        row.unit:SetText(definition.unit and Cat2.L(definition.unit) or "")
        row.step = step
        local savedValue = nil
        if type(step.optionValues) == "table" then
            savedValue = step.optionValues[definition.key]
        end
        -- 没有独立覆写时，编辑器直接展示卡片定义的默认值，方便用户按默认方案微调。
        -- 用户仍可清空输入框并保存，以恢复被动继承值或卡片默认值。
        local displayValue = savedValue
        if displayValue == nil then
            displayValue = Cat2.ResolveCardOptionDefinitionValue(definition, "default", step)
        end
        displayValue = Cat2.NormalizeCardOptionValue(definition, displayValue, step)
        if definition.control == "select" then
            local normalizedSavedValue = Cat2.NormalizeCardOptionValue(definition, savedValue, step)
            if savedValue ~= nil and normalizedSavedValue ~= nil then
                row.selectUsesDefault = false
                row.selectValue = normalizedSavedValue
            else
                row.selectUsesDefault = true
                row.selectValue = nil
            end
            row.unit:ClearAllPoints()
            if definition.allowCustom == true then
                row.input:SetWidth(124)
                row.input:Show()
                row.selectButton:Hide()
                row.selectArrowButton:ClearAllPoints()
                row.selectArrowButton:SetPoint("LEFT", row.input, "RIGHT", 2, 0)
                row.selectArrowButton:Show()
                row.unit:SetPoint("LEFT", row.selectArrowButton, "RIGHT", 7, 0)
            else
                row.input:Hide()
                row.selectButton:Show()
                row.selectArrowButton:Hide()
                row.unit:SetPoint("LEFT", row.selectButton, "RIGHT", 7, 0)
            end
            row.RefreshSelectText()
        else
            row.input:SetWidth(150)
            row.selectButton:Hide()
            row.selectArrowButton:Hide()
            row.selectMenu:Hide()
            row.input:Show()
            row.unit:ClearAllPoints()
            row.unit:SetPoint("LEFT", row.input, "RIGHT", 7, 0)
            row.input:SetTextColor(0.88, 0.92, 1)
            if definition.type == "boolean" and displayValue ~= nil then
                row.input:SetText(displayValue and Cat2.L("开启") or Cat2.L("关闭"))
            else
                row.input:SetText(displayValue ~= nil and tostring(displayValue) or "")
            end
        end
        row.frame:Show()
        rowIndex = rowIndex + 1
    end
    while rowIndex <= table.getn(cardOptionsRows) do
        cardOptionsRows[rowIndex].frame:Hide()
        rowIndex = rowIndex + 1
    end

    ui.ShowMainWindowDim()
    cardOptionsWindow:Show()
    local focusIndex = 1
    while focusIndex <= schemaTotal do
        local focusRow = cardOptionsRows[focusIndex]
        if focusRow and focusRow.definition and
           (focusRow.definition.control ~= "select" or focusRow.definition.allowCustom == true) then
            focusRow.input:SetFocus()
            focusRow.input:HighlightText()
            break
        end
        focusIndex = focusIndex + 1
    end
end

-- 关闭所有弹窗并清除待执行操作，等同于逐个点击取消。
function ui.CloseAllDialogs()
    pendingConfirm = nil
    pendingInputSubmit = nil
    pendingInputValidator = nil
    pendingCardOptionsSubmit = nil
    if noticeWindow then
        noticeWindow:Hide()
    end
    if confirmWindow then
        confirmWindow:Hide()
    end
    if inputWindow then
        inputWindow:Hide()
    end
    if inputBox then
        inputBox:ClearFocus()
    end
    if cardOptionsWindow then
        cardOptionsWindow:Hide()
    end
    if ui.HideImportExportWindow then
        ui.HideImportExportWindow()
    end
    if ui.HideRulesWindow then
        ui.HideRulesWindow()
    end
    ui.HideMainWindowDim()
end
