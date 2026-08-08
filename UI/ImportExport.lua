-- Cat2 配置导入／导出窗口。
-- 导出文本包含职业、配置名、卡片顺序及快捷窗排列参数；导入时完成解码、校验和及职业检查。
Cat2.UI = Cat2.UI or {}
local ui = Cat2.UI
local transferBlocker = nil
local transferWindow = nil
local transferTitle = nil
local transferHint = nil
local transferTextPanel = nil
local transferScrollFrame = nil
local transferEditBox = nil
local primaryButton = nil
local primaryText = nil
local transferMode = nil
local protectedExportText = ""
local updatingText = false

-- 旧客户端的多行 EditBox 自动全选有时会漏掉最后一行，必须明确指定字符范围。
local function SelectCompleteExportText()
    transferEditBox:SetFocus()
    transferEditBox:HighlightText(0, string.len(protectedExportText))
end

local function FinishImport(importedProfile, overwriteProfileId)
    local success, errorMessage = ui.ApplyImportedConfiguration(importedProfile, overwriteProfileId)
    if not success then
        ui.ShowNotice("导入失败：" .. (errorMessage or "未知错误") .. "。")
        return
    end
    if overwriteProfileId then
        ui.ShowNotice("配置「" .. importedProfile.name .. "」已覆盖，并已切换为当前配置。")
    else
        ui.ShowNotice("配置「" .. importedProfile.name .. "」导入成功，并已切换为当前配置。")
    end
end

local function ImportPastedText(text)
    local importedProfile, errorMessage = Cat2.ImportConfigurationText(text)
    if not importedProfile then
        ui.ShowNotice("导入失败：" .. (errorMessage or "无法识别配置文本") .. "。")
        return
    end

    local localizedClass, currentClassFile = UnitClass("player")
    if importedProfile.classFile ~= currentClassFile then
        ui.ShowNotice(
            "职业不匹配，不能导入。\n配置职业：" .. importedProfile.classFile ..
            "\n当前职业：" .. (currentClassFile or localizedClass or "未知")
        )
        return
    end

    local conflictingProfileId = ui.FindConfigurationByName(importedProfile.name)
    if conflictingProfileId then
        ui.ShowConfirm(
            "已经存在同名配置「" .. importedProfile.name .. "」。\n" ..
            "覆盖后，原配置的卡片及顺序将被替换。",
            function()
                FinishImport(importedProfile, conflictingProfileId)
            end,
            "覆盖"
        )
        return
    end
    FinishImport(importedProfile, nil)
end

local function CreateActionButton(parent, labelText, width)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(26)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")
    ui.ApplyFlatBackdrop(button, 0.08, 0.18, 0.27, 1)

    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER", button, "CENTER", 0, 0)
    text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    text:SetTextColor(0.78, 0.9, 1)
    text:SetText(labelText)
    button.text = text

    button:SetScript("OnEnter", function()
        button:SetBackdropColor(0.12, 0.4, 0.58, 1)
        button:SetBackdropBorderColor(0.45, 0.82, 1, 1)
        text:SetTextColor(1, 0.84, 0.28)
    end)
    button:SetScript("OnLeave", function()
        button:SetBackdropColor(0.08, 0.18, 0.27, 1)
        button:SetBackdropBorderColor(0.3, 0.4, 0.52, 0.9)
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

local function HideTransferWindow()
    if transferEditBox then
        transferEditBox:ClearFocus()
    end
    if transferWindow then
        transferWindow:Hide()
    end
    if transferBlocker then
        transferBlocker:Hide()
    end
    if ui.HideMainWindowDim then
        ui.HideMainWindowDim()
    end
end

local function CreateTransferWindow()
    if transferWindow then
        return
    end

    -- 全屏透明拦截层保证导入导出期间不能操作下方主界面。
    transferBlocker = CreateFrame("Frame", nil, UIParent)
    transferBlocker:SetAllPoints(UIParent)
    transferBlocker:SetFrameStrata("FULLSCREEN_DIALOG")
    transferBlocker:SetFrameLevel(110)
    transferBlocker:EnableMouse(true)
    local blockerTexture = transferBlocker:CreateTexture(nil, "BACKGROUND")
    blockerTexture:SetAllPoints(transferBlocker)
    blockerTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
    blockerTexture:SetVertexColor(0, 0, 0, 0.01)
    transferBlocker:SetScript("OnMouseDown", function()
    end)
    transferBlocker:SetScript("OnMouseUp", function()
    end)

    transferWindow = CreateFrame("Frame", "Cat2ImportExportWindow", UIParent)
    transferWindow:SetWidth(470)
    transferWindow:SetHeight(368)
    transferWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 12)
    transferWindow:SetFrameStrata("FULLSCREEN_DIALOG")
    transferWindow:SetFrameLevel(120)
    transferWindow:SetMovable(true)
    transferWindow:SetClampedToScreen(true)
    transferWindow:EnableMouse(true)
    transferWindow:RegisterForDrag("LeftButton")
    ui.ApplyFlatBackdrop(transferWindow, 0.04, 0.05, 0.08, 0.99)
    transferWindow:SetScript("OnDragStart", function()
        transferWindow:StartMoving()
    end)
    transferWindow:SetScript("OnDragStop", function()
        transferWindow:StopMovingOrSizing()
    end)

    transferTitle = transferWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    transferTitle:SetPoint("TOPLEFT", transferWindow, "TOPLEFT", 18, -16)
    transferTitle:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    transferTitle:SetTextColor(1, 0.78, 0.16)

    local closeButton = CreateActionButton(transferWindow, "X", 28)
    closeButton:SetPoint("TOPRIGHT", transferWindow, "TOPRIGHT", -12, -11)
    closeButton:SetScript("OnClick", HideTransferWindow)

    transferHint = transferWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    transferHint:SetPoint("TOPLEFT", transferWindow, "TOPLEFT", 14, -42)
    transferHint:SetWidth(442)
    transferHint:SetJustifyH("LEFT")
    transferHint:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    transferHint:SetTextColor(0.58, 0.66, 0.76)

    -- ScrollFrame 会裁剪旧客户端中越过 EditBox 边界的全选高亮，同时承载长文本滚动。
    transferTextPanel = CreateFrame("Frame", nil, transferWindow)
    transferTextPanel:SetWidth(442)
    transferTextPanel:SetHeight(260)
    transferTextPanel:SetPoint("TOP", transferWindow, "TOP", 0, -62)
    transferTextPanel:SetFrameLevel(transferWindow:GetFrameLevel() + 5)
    transferTextPanel:EnableMouse(true)
    ui.ApplyFlatBackdrop(transferTextPanel, 0.025, 0.035, 0.055, 1)

    transferScrollFrame = CreateFrame("ScrollFrame", nil, transferTextPanel)
    transferScrollFrame:SetFrameLevel(transferWindow:GetFrameLevel() + 8)
    transferScrollFrame:SetWidth(422)
    transferScrollFrame:SetHeight(242)
    transferScrollFrame:SetPoint("TOPLEFT", transferTextPanel, "TOPLEFT", 10, -8)
    transferScrollFrame:EnableMouse(true)
    transferScrollFrame:EnableMouseWheel(true)

    transferEditBox = CreateFrame("EditBox", nil, transferScrollFrame)
    transferEditBox:SetFrameLevel(transferWindow:GetFrameLevel() + 10)
    transferEditBox:SetWidth(422)
    transferEditBox:SetHeight(242)
    transferEditBox:SetPoint("TOPLEFT", transferScrollFrame, "TOPLEFT", 0, 0)
    transferEditBox:SetAutoFocus(false)
    transferEditBox:SetMultiLine(true)
    transferEditBox:SetMaxLetters(12000)
    transferEditBox:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    transferEditBox:SetTextColor(0.82, 0.88, 0.96)
    transferEditBox:SetTextInsets(0, 0, 0, 0)
    transferEditBox:SetJustifyH("LEFT")
    transferScrollFrame:SetScrollChild(transferEditBox)

    transferScrollFrame:SetScript("OnMouseDown", function()
        if transferMode == "export" then
            SelectCompleteExportText()
        else
            transferEditBox:SetFocus()
        end
    end)
    transferScrollFrame:SetScript("OnMouseWheel", function()
        local current = transferScrollFrame:GetVerticalScroll()
        local maximum = transferScrollFrame:GetVerticalScrollRange()
        local nextPosition = current - arg1 * 28
        if nextPosition < 0 then
            nextPosition = 0
        elseif nextPosition > maximum then
            nextPosition = maximum
        end
        transferScrollFrame:SetVerticalScroll(nextPosition)
    end)

    transferTextPanel:SetScript("OnMouseDown", function()
        if transferMode == "export" then
            SelectCompleteExportText()
        else
            transferEditBox:SetFocus()
        end
    end)

    transferEditBox:SetScript("OnEscapePressed", HideTransferWindow)
    transferEditBox:SetScript("OnTextChanged", function()
        if transferMode == "export" and not updatingText and transferEditBox:GetText() ~= protectedExportText then
            updatingText = true
            transferEditBox:SetText(protectedExportText)
            SelectCompleteExportText()
            updatingText = false
        end
        transferScrollFrame:UpdateScrollChildRect()
    end)

    primaryButton = CreateActionButton(transferWindow, "全选", 92)
    primaryButton:SetPoint("BOTTOMRIGHT", transferWindow, "BOTTOM", -7, 12)
    primaryText = primaryButton.text
    primaryButton:SetScript("OnClick", function()
        if transferMode == "export" then
            SelectCompleteExportText()
            return
        end
        local pastedText = transferEditBox:GetText()
        if pastedText == "" then
            ui.ShowNotice("请先粘贴需要导入的配置文本。")
        else
            ImportPastedText(pastedText)
        end
    end)

    local cancelButton = CreateActionButton(transferWindow, "关闭", 92)
    cancelButton:SetPoint("BOTTOMLEFT", transferWindow, "BOTTOM", 7, 12)
    cancelButton:SetScript("OnClick", HideTransferWindow)
    transferWindow.cancelButton = cancelButton
    transferWindow:Hide()
    transferBlocker:Hide()
end

function ui.ShowExportWindow()
    CreateTransferWindow()
    ui.CloseAllDialogs()
    if ui.HideSettingsWindow then
        ui.HideSettingsWindow()
    end
    transferMode = "export"
    local profileName = "当前配置"
    local activeProfile = nil
    local repository = Cat2.RuntimeConfigurations
    if repository and repository.profiles and repository.profiles[repository.activeProfileId] then
        activeProfile = repository.profiles[repository.activeProfileId]
        profileName = activeProfile.name
    end
    local localizedClass, classFile = UnitClass("player")
    local exportText, errorMessage = Cat2.ExportConfigurationText(activeProfile, classFile)
    if not exportText then
        ui.ShowNotice("无法导出配置：「" .. (errorMessage or "未知错误") .. "」。")
        return
    end
    protectedExportText = exportText
    updatingText = true
    transferEditBox:SetText(protectedExportText)
    updatingText = false
    transferTitle:SetText("配置导出")
    transferHint:SetText("正在导出「" .. profileName .. "」。文本已压缩转档，点击“全选”后按 Ctrl+C 复制。")
    primaryText:SetText("全选")
    transferWindow.cancelButton.text:SetText("关闭")
    transferBlocker:Show()
    ui.ShowMainWindowDim()
    transferWindow:Show()
    SelectCompleteExportText()
end

function ui.ShowImportWindow()
    CreateTransferWindow()
    ui.CloseAllDialogs()
    if ui.HideSettingsWindow then
        ui.HideSettingsWindow()
    end
    transferMode = "import"
    protectedExportText = ""
    updatingText = true
    transferEditBox:SetText("")
    updatingText = false
    transferTitle:SetText("配置导入")
    transferHint:SetText("将其他用户提供的完整配置文本粘贴到下方，然后点击“导入”。")
    primaryText:SetText("导入")
    transferWindow.cancelButton.text:SetText("取消")
    transferBlocker:Show()
    ui.ShowMainWindowDim()
    transferWindow:Show()
    transferEditBox:SetFocus()
end

function ui.HideImportExportWindow()
    HideTransferWindow()
end
