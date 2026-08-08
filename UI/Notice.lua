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
        confirmText:SetText("确定")
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
        confirmButtonText:SetText("确认删除")

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
        cancelButtonText:SetText("取消")

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
    confirmButtonText:SetText(confirmLabel or "确认删除")
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
        cancelText:SetText("取消")

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
                inputError:SetText(errorMessage or "输入内容无效。")
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
    inputSubmitText:SetText(submitLabel or "创建")
    inputError:SetText("")
    inputBox:SetText(initialText or "")
    ui.ShowMainWindowDim()
    inputWindow:Show()
    inputBox:SetFocus()
    inputBox:HighlightText()
end

-- 关闭所有弹窗并清除待执行操作，等同于逐个点击取消。
function ui.CloseAllDialogs()
    pendingConfirm = nil
    pendingInputSubmit = nil
    pendingInputValidator = nil
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
    if ui.HideImportExportWindow then
        ui.HideImportExportWindow()
    end
    if ui.HideRulesWindow then
        ui.HideRulesWindow()
    end
    ui.HideMainWindowDim()
end
