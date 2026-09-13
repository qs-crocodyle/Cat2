-- 配置动作条图标：一个专用原生宏作载体，配置 ID 与动作槽映射按角色保存。
-- 仅维护本插件专用载体，不编辑其他用户宏；无有效映射时只提示。
local ui = Cat2.UI
local legacyCarrierBody = "/run if Cat2 and Cat2.ProfileMacroUnbound then Cat2.ProfileMacroUnbound() end"
local carrierBody = "/run -- Cat2自动生成，请勿删除。\n/run -- 配置图标的技能条载体，所有配置共用。\n" .. legacyCarrierBody
local fallbackIcon = "Interface\\Icons\\INV_Misc_QuestionMark"
local cursorProfile = nil
local cursorPreview = nil
-- 1.12 没有 GetCursorInfo / CursorHasMacro 时，跟踪自己的拖拽事务。
local legacyCursorPresent = false
local initialized = false
local worldReady = false
local refreshPending = false
local original = {}
local eventFrame = CreateFrame("Frame")
local nativeButtons = {}
local nativeButtonsByFrame = {}

-- Lua 5.0 的 arg.n 保留包括 nil 在内的全部返回值；后置显示处理不改变原调用契约。
local function AfterCall(callback, ...)
    local results = arg
    callback()
    return unpack(results, 1, results.n)
end

local function Database()
    Cat2.EnsureConfigurationDataLoaded()
    Cat2CharacterDB.ui = Cat2CharacterDB.ui or {}
    local data = Cat2CharacterDB.ui.profileMacroIcons
    if type(data) ~= "table" then
        data = { slots = {} }
        Cat2CharacterDB.ui.profileMacroIcons = data
    end
    if type(data.slots) ~= "table" then data.slots = {} end
    return data
end

local function Notice(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc33Cat2：" .. message .. "|r")
end

function Cat2.ProfileMacroUnbound()
    Notice(Cat2.L("此图标未绑定有效配置，请从Cat2配置旁重新拖入动作条。"))
end

local function Profile(id)
    local repository = Cat2.RuntimeConfigurations
    return repository and repository.profiles[id]
end

local function ProfileIcon(profile)
    if profile then
        local icons = Database().icons
        local selected = type(icons) == "table" and icons[profile.id]
        if type(selected) == "string" and selected ~= "" then return selected end
        for _, step in ipairs(profile.steps or {}) do
            if step.enabled ~= 0 and step.behavior ~= "passive" then
                return Cat2.GetCardPrimaryIcon(step) or fallbackIcon
            end
        end
    end
    return fallbackIcon
end

local function MacroScanLimit()
    local account, character = GetNumMacros()
    return math.max(54, (MAX_ACCOUNT_MACROS or MAX_MACROS or 36) + (character or 0), (account or 0) + (character or 0))
end

local function ReadMacro(index)
    local ok, name, icon, body = pcall(GetMacroInfo, index)
    if ok then return name, icon, body end
end

local function IsCarrierBody(body)
    if type(body) ~= "string" then return false end
    -- 客户端/宏编辑器可能补入末尾换行；这不代表占位宏被用户改写。
    body = string.gsub(body, "\r\n", "\n")
    body = string.gsub(body, "^%s+", "")
    body = string.gsub(body, "%s+$", "")
    return body == carrierBody or body == legacyCarrierBody
end

local function UpgradeCarrierComment(index)
    local _, _, body = ReadMacro(index)
    if type(body) ~= "string" or not IsCarrierBody(body) then return end
    local normalized = string.gsub(string.gsub(body, "^%s+", ""), "%s+$", "")
    if normalized == legacyCarrierBody and type(EditMacro) == "function" then
        local ok, message = pcall(EditMacro, index, nil, nil, carrierBody)
        if not ok then Notice(Cat2.L("无法更新功能宏说明：") .. tostring(message)) end
    end
end

local function FindCarrier(requestedName)
    local data = Database()
    local ownedName = requestedName or data.carrierName
    if not ownedName then return nil end
    local namedIndex
    if type(GetMacroIndexByName) == "function" then
        local ok, index = pcall(GetMacroIndexByName, ownedName)
        if ok and type(index) == "number" and index > 0 then namedIndex = index end
    end
    for _, index in ipairs({ namedIndex or 0, data.carrierIndex or 0 }) do
        if index > 0 then
            local name, _, body = ReadMacro(index)
            if name == ownedName and IsCarrierBody(body) then return index, name end
        end
    end
    for index = 1, MacroScanLimit() do
        local name, _, body = ReadMacro(index)
        if name == ownedName and IsCarrierBody(body) then return index, name end
    end
end

local creationUnconfirmed = false
local function EnsureCarrier()
    local data = Database()
    local index, name = FindCarrier()
    if index then
        data.carrierIndex = index
        creationUnconfirmed = false
        UpgradeCarrierComment(index)
        return index, name
    end
    local used = {}
    local recoveredIndex, recoveredName
    for i = 1, MacroScanLimit() do
        local existing, _, body = ReadMacro(i)
        if existing then used[existing] = true end
        if existing and string.find(existing, "^Cat2Icon%d*$") and IsCarrierBody(body) and not recoveredIndex then
            recoveredIndex, recoveredName = i, existing
        end
    end
    -- 兼容上一版留下的占位宏，不再因为记录丢失或索引变化创建新的副本。
    if recoveredIndex then
        data.carrierName, data.carrierIndex = recoveredName, recoveredIndex
        creationUnconfirmed = false
        UpgradeCarrierComment(recoveredIndex)
        return recoveredIndex, recoveredName
    end
    if creationUnconfirmed or (data.carrierName and used[data.carrierName]) then
        Notice(Cat2.L("已存在专用占位宏，但暂时无法确认其内容；已停止重复创建，请检查宏内容后重试。"))
        return nil
    end
    name = "Cat2Icon"
    local suffix = 1
    while used[name] do
        name = "Cat2Icon" .. suffix
        suffix = suffix + 1
    end
    -- 旧客户端第4参为 isLocal，第5参才是角色专用开关。
    local ok, result = pcall(CreateMacro, name, 1, carrierBody, nil, true)
    if not ok then
        Notice(Cat2.L("无法创建专用占位宏，请预留一个角色宏位置后重试。"))
        return nil
    end
    data.carrierName = name
    data.carrierIndex = tonumber(result)
    creationUnconfirmed = true
    local foundIndex, foundName = FindCarrier()
    if foundIndex then creationUnconfirmed = false end
    if not foundIndex then Notice(Cat2.L("占位宏已创建，暂时无法确认读取结果；不会继续新增，请 /reload 后重试。")) end
    return foundIndex, foundName
end

local function Binding(slot)
    if slot == nil then return nil end
    local saved = Database().slots[slot]
    if type(saved) ~= "table" then return nil end
    if original.GetActionText(slot) ~= saved.carrier then return nil end
    local _, name = FindCarrier(saved.carrier)
    if name ~= saved.carrier then return nil end
    return saved
end

local function CursorStillPresent()
    if type(GetCursorInfo) == "function" then
        local kind = GetCursorInfo()
        return kind == "macro"
    end
    if type(CursorHasMacro) == "function" then return CursorHasMacro() end
    return legacyCursorPresent
end

local function HasCursorAction()
    if type(GetCursorInfo) == "function" then
        return GetCursorInfo() ~= nil
    end
    return (type(CursorHasMacro) == "function" and CursorHasMacro())
        or (type(CursorHasSpell) == "function" and CursorHasSpell())
        or (type(CursorHasItem) == "function" and CursorHasItem())
end

-- 独立于原生宏游标的视觉预览；不接收鼠标，避免挡住动作条落位。
local function UpdateCursorPreview()
    if not cursorProfile or not CursorStillPresent() then
        if cursorPreview then
            cursorPreview:Hide()
            cursorPreview.profileId = nil
        end
        return
    end
    if not cursorPreview then
        cursorPreview = CreateFrame("Frame", nil, UIParent)
        cursorPreview:SetWidth(32)
        cursorPreview:SetHeight(32)
        cursorPreview:SetFrameStrata("TOOLTIP")
        cursorPreview:SetFrameLevel(100)
        cursorPreview:EnableMouse(false)
        cursorPreview.icon = cursorPreview:CreateTexture(nil, "OVERLAY")
        cursorPreview.icon:SetAllPoints(cursorPreview)
    end
    if cursorPreview.profileId ~= cursorProfile.profileId then
        cursorPreview.profileId = cursorProfile.profileId
        cursorPreview.icon:SetTexture(ProfileIcon(Profile(cursorProfile.profileId)))
    end
    local scale = UIParent:GetEffectiveScale()
    local x, y = GetCursorPosition()
    cursorPreview:ClearAllPoints()
    cursorPreview:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
    cursorPreview:Show()
end

local function QueueRefresh()
    refreshPending = true
    UpdateCursorPreview()
end

-- 配置名称只写入原生按钮文字，不改变其他插件通过 GetActionText 读取的宏身份。
-- 不调用 ActionButton_Update，不改冷却、数量、快捷键、颜色或按钮状态。
local function RefreshNativeButton(entry)
    local button = entry.button
    -- 原生变形条动画期间会延迟外观更新，遵循同一门禁。
    if button.isBonus and button.inTransition then return end
    local slot = ActionButton_GetPagedID(button)
    local saved = Binding(slot)
    if saved then
        local profile = Profile(saved.profileId)
        local name = profile and profile.name or Cat2.L("配置已删除")
        local texture = ProfileIcon(profile)
        if entry.label and entry.label:GetText() ~= name then entry.label:SetText(name) end
        if entry.icon and entry.icon:GetTexture() ~= texture then entry.icon:SetTexture(texture) end
        if button.isBonus then button.texture = texture end
        entry.name, entry.texture = name, texture
        entry.owned = true
    elseif entry.owned then
        -- 换页或替换后只撤销仍属于 Cat2 的显示；其他插件已写入的内容保留。
        if entry.label and entry.label:GetText() == entry.name then
            entry.label:SetText(GetActionText(slot) or "")
        end
        if entry.icon and entry.icon:GetTexture() == entry.texture then
            entry.icon:SetTexture(GetActionTexture(slot))
        end
        if button.isBonus and button.texture == entry.texture then button.texture = GetActionTexture(slot) end
        entry.owned, entry.name, entry.texture = nil, nil, nil
    end
end

local function DiscoverNativeButtons()
    if type(ActionButton_GetPagedID) ~= "function" then return end
    for _, prefix in ipairs({ "ActionButton", "BonusActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarLeftButton", "MultiBarRightButton" }) do
        for index = 1, 12 do
            local name = prefix .. index
            local button = getglobal(name)
            if button and not nativeButtonsByFrame[button] then
                local entry = { button = button, label = getglobal(name .. "Name"), icon = getglobal(name .. "Icon") }
                nativeButtonsByFrame[button] = entry
                table.insert(nativeButtons, entry)
            end
        end
    end
end

function ui.RefreshProfileMacroIcon()
    local editor = ui.FlowEditor
    local button = editor and editor.mainWindow and editor.mainWindow.profileMacroIcon
    if button then
        local id = Cat2.RuntimeConfigurations.activeProfileId
        button.profileId = id
        button.icon:SetTexture(ProfileIcon(Profile(id)))
        if ui.ProfileIconPicker and ui.ProfileIconPicker.profileId ~= id then
            ui.ProfileIconPicker:Hide()
        end
    end
    QueueRefresh()
end

function ui.GetProfileMacroIcon(profileId)
    return ProfileIcon(Profile(profileId))
end

function ui.SetProfileMacroIcon(profileId, texture)
    if not Profile(profileId) then return false end
    if texture ~= nil and (type(texture) ~= "string" or texture == "") then return false end
    local data = Database()
    if type(data.icons) ~= "table" then data.icons = {} end
    data.icons[profileId] = texture
    if cursorPreview then cursorPreview.profileId = nil end
    ui.RefreshProfileMacroIcon()
    return true
end

local function ExecuteBinding(saved)
    local profile = Profile(saved.profileId)
    if not profile then
        Cat2.ProfileMacroUnbound()
        return
    end
    -- 在执行时解析当前名称，不改变编辑器所选配置。
    local ok, found, count, failures = pcall(Cat2.ExecuteConfiguration, profile.name)
    if not ok then
        Notice(Cat2.L("配置「") .. profile.name .. Cat2.L("」执行异常：") .. tostring(found))
    elseif not found then
        Cat2.ProfileMacroUnbound()
    elseif failures and failures > 0 then
        Notice(Cat2.L("配置「") .. profile.name .. Cat2.L("」执行完成，失败卡片 ") .. failures .. Cat2.L(" 张。"))
    end
end

local function InstallHooks()
    if initialized then return end
    initialized = true
    original.GetActionText = GetActionText
    original.GetActionTexture = GetActionTexture
    original.UseAction = UseAction
    original.PickupAction = PickupAction
    original.PlaceAction = PlaceAction
    original.PickupMacro = PickupMacro

    -- 仅配置槽位继续提供图标，兼容通过标准接口绘制按钮的第三方动作条。
    -- GetActionText 保持原函数，避免宏插件把配置名当成另一个宏名。
    GetActionTexture = function(slot)
        local saved = Binding(slot)
        if saved then return ProfileIcon(Profile(saved.profileId)) end
        return original.GetActionTexture(slot)
    end
    UseAction = function(slot, checkCursor, onSelf)
        local saved = Binding(slot)
        if checkCursor and checkCursor ~= 0 then
            if (cursorProfile and CursorStillPresent()) or (saved and HasCursorAction()) then
                PlaceAction(slot)
                return
            end
        end
        if saved then
            ExecuteBinding(saved)
            return
        end
        return original.UseAction(slot, checkCursor, onSelf)
    end
    PickupAction = function(slot)
        local saved = Binding(slot)
        cursorProfile = nil
        legacyCursorPresent = false
        UpdateCursorPreview()
        if not saved then return original.PickupAction(slot) end
        return AfterCall(function()
            -- 拾取失败（例如动作条锁定）时保留原绑定。
            if original.GetActionText(slot) ~= saved.carrier then
                Database().slots[slot] = nil
                legacyCursorPresent = true
                if CursorStillPresent() then cursorProfile = saved end
            end
            QueueRefresh()
        end, original.PickupAction(slot))
    end
    PlaceAction = function(slot)
        if not cursorProfile and not HasCursorAction() then
            return original.PlaceAction(slot)
        end
        local incoming = cursorProfile
        if incoming and not CursorStillPresent() then incoming = nil end
        local outgoing = Binding(slot)
        -- 配置换出的普通动作仍属于这次拖拽；继续落位后更新旧客户端游标状态。
        local hadAction = original.GetActionTexture(slot) ~= nil
        if not incoming and not outgoing then
            if not legacyCursorPresent then return original.PlaceAction(slot) end
            return AfterCall(function()
                legacyCursorPresent = hadAction
            end, original.PlaceAction(slot))
        end
        return AfterCall(function()
            local slots = Database().slots
            local placedName = original.GetActionText(slot)
            if incoming then
                -- 放置失败时原槽位和配置游标均保持，不误认成一次成功移动。
                if placedName ~= incoming.carrier then return end
                slots[slot] = incoming
            elseif outgoing and placedName == outgoing.carrier then
                -- 普通动作未能替换原配置槽位，不能丢失其绑定。
                return
            else
                slots[slot] = nil
            end
            legacyCursorPresent = hadAction
            cursorProfile = outgoing
            if cursorProfile and not CursorStillPresent() then cursorProfile = nil end
            QueueRefresh()
        end, original.PlaceAction(slot))
    end

    -- 用户拾取其他类型内容或取消拖拽时，丢弃未落位的配置游标。
    local function WrapPickup(name)
        local previous = _G[name]
        if type(previous) ~= "function" then return end
        _G[name] = function(...)
            if cursorProfile or legacyCursorPresent then
                cursorProfile = nil
                legacyCursorPresent = false
                UpdateCursorPreview()
            end
            return previous(unpack(arg, 1, arg.n))
        end
    end
    WrapPickup("PickupMacro")
    WrapPickup("PickupSpell")
    WrapPickup("PickupContainerItem")
    WrapPickup("PickupInventoryItem")
    WrapPickup("ClearCursor")

    -- 旧客户端在场景中取消宏游标时，可能既不调用 Lua ClearCursor，
    -- 也不再次发送 HIDEGRID。交换出的配置预览因此会残留，需同步结束事务。
    local function HookBackgroundCancel(frame)
        if not frame or type(frame.GetScript) ~= "function" or type(frame.SetScript) ~= "function" then return end
        local previous = frame:GetScript("OnMouseDown")
        frame:SetScript("OnMouseDown", function(...)
            local button = arg[1] or arg1
            if (button == "LeftButton" or button == "RightButton")
                and (cursorProfile or legacyCursorPresent) then
                ClearCursor()
            end
            if previous then return previous(unpack(arg, 1, arg.n)) end
        end)
    end
    HookBackgroundCancel(WorldFrame)
    HookBackgroundCancel(UIParent)

    -- 原生按钮的点击落位必须先于 UseAction，否则会误执行被覆盖的配置。
    if type(ActionButton_OnClick) == "function" then
        local previous = ActionButton_OnClick
        ActionButton_OnClick = function(button, ignoreShift)
            if nativeButtonsByFrame[this] and button == "RightButton" then
                local hasProfileCursor = cursorProfile and CursorStillPresent()
                local hasSwapCursor = legacyCursorPresent
                if type(GetCursorInfo) == "function" then
                    hasSwapCursor = hasSwapCursor and HasCursorAction()
                end
                if hasProfileCursor or hasSwapCursor
                    or (Binding(ActionButton_GetPagedID(this)) and HasCursorAction()) then
                    -- 右键必须在原按钮调用 UseAction 前取消，避免把换出的动作再次放回。
                    ClearCursor()
                    return
                end
            end
            if nativeButtonsByFrame[this] and cursorProfile and CursorStillPresent() and button ~= "RightButton" then
                PlaceAction(ActionButton_GetPagedID(this))
                return
            end
            return previous(button, ignoreShift)
        end
    end
    if GameTooltip and GameTooltip.SetAction then
        local previous = GameTooltip.SetAction
        GameTooltip.SetAction = function(self, slot)
            local saved = Binding(slot)
            -- 扫描用 Tooltip 完全透传；可见提示先让原接口和已有插件生成全部信息。
            if self ~= GameTooltip or not saved then return previous(self, slot) end
            return AfterCall(function()
                local profile = Profile(saved.profileId)
                self:AddLine(Cat2.L("Cat2：") .. (profile and profile.name or Cat2.L("配置已删除")), 0.78, 0.86, 0.96)
                self:AddLine(profile and Cat2.L("点击或按动作条快捷键执行此Cat2配置。") or Cat2.L("请从Cat2重新拖入有效配置。"), 0.78, 0.86, 0.96)
                self:Show()
            end, previous(self, slot))
        end
    end
    DiscoverNativeButtons()
    if type(ActionButton_Update) == "function" then
        local previous = ActionButton_Update
        ActionButton_Update = function(...)
            local entry = nativeButtonsByFrame[this]
            if not entry then return previous(unpack(arg, 1, arg.n)) end
            -- 原生或其他插件正常刷新结束后，仅补充绑定配置的外观。
            return AfterCall(function() RefreshNativeButton(entry) end, previous(unpack(arg, 1, arg.n)))
        end
    end
end

function ui.PickupProfileMacroIcon(profileId)
    Database()
    InstallHooks()
    if not Profile(profileId) then Cat2.ProfileMacroUnbound(); return end
    local index, name = EnsureCarrier()
    if not index then return end
    -- 鼠标预览已有独立纹理，不再反复 EditMacro 触发其他插件的宏重解析。
    ClearCursor()
    original.PickupMacro(index)
    legacyCursorPresent = true
    cursorProfile = { profileId = profileId, carrier = name }
    if GameTooltip then GameTooltip:Hide() end
    UpdateCursorPreview()
end

function ui.CreateProfileMacroIcon(parent, anchor)
    -- 共用外框，内部仍保留图标拖拽和箭头选择两个独立点击区域。
    local container = CreateFrame("Frame", nil, parent)
    container:SetWidth(46)
    container:SetHeight(28)
    container:SetPoint("LEFT", anchor, "RIGHT", 4, 0)
    ui.ApplyFlatBackdrop(container, 0.07, 0.12, 0.18, 1)
    local button = CreateFrame("Button", nil, container)
    parent.profileMacroIcon = button
    button:SetWidth(28)
    button:SetHeight(28)
    button:SetPoint("LEFT", container, "LEFT", 2, 0)
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
    button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function()
        button.draggedAt = GetTime()
        ui.PickupProfileMacroIcon(button.profileId)
    end)
    button:SetScript("OnClick", function()
        if button.draggedAt and GetTime() - button.draggedAt < 0.2 then return end
        ui.PickupProfileMacroIcon(button.profileId)
    end)
    button:SetScript("OnEnter", function()
        local profile = Profile(button.profileId)
        GameTooltip:SetOwner(button, "ANCHOR_TOP")
        GameTooltip:SetText(profile and profile.name or Cat2.L("配置图标"))
        GameTooltip:AddLine(Cat2.L("拖动到技能条"), 0.78, 0.86, 0.96)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    -- 图标保持拖拽入口；选择图标使用独立箭头，避免误触拖拽。
    local arrow = CreateFrame("Button", nil, container)
    parent.profileMacroIconArrow = arrow
    arrow:SetWidth(14)
    arrow:SetHeight(28)
    arrow:SetPoint("LEFT", button, "RIGHT", 0, 0)
    local glyph = arrow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    glyph:SetPoint("CENTER", arrow, "CENTER", 0, 0)
    glyph:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    glyph:SetText("▲")
    glyph:SetTextColor(0.5, 0.75, 0.95)
    arrow:SetScript("OnClick", function()
        ui.ToggleProfileIconPicker(parent, arrow, button.profileId)
    end)
    arrow:SetScript("OnEnter", function()
        glyph:SetTextColor(1, 0.82, 0.2)
        GameTooltip:SetOwner(arrow, "ANCHOR_TOP")
        GameTooltip:SetText(Cat2.L("选择配置图标"))
        GameTooltip:Show()
    end)
    arrow:SetScript("OnLeave", function()
        glyph:SetTextColor(0.5, 0.75, 0.95)
        GameTooltip:Hide()
    end)
    return button
end

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
eventFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
eventFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
eventFrame:RegisterEvent("UPDATE_MACROS")
eventFrame:RegisterEvent("ACTIONBAR_HIDEGRID")
eventFrame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        InstallHooks()
        local index = FindCarrier()
        if index then UpgradeCarrierComment(index) end
    end
    if event == "PLAYER_ENTERING_WORLD" then
        worldReady = true
        DiscoverNativeButtons()
    end
    -- 原生右键取消可能不经过 Lua ClearCursor，但会结束动作条拖拽网格。
    if event == "ACTIONBAR_HIDEGRID" then
        legacyCursorPresent = false
        cursorProfile = nil
    end
    QueueRefresh()
end)
eventFrame:SetScript("OnUpdate", function()
    if not initialized then return end
    if cursorProfile and not CursorStillPresent() then cursorProfile = nil end
    UpdateCursorPreview()
    if not refreshPending then return end
    refreshPending = false
    local slots = Database().slots
    if worldReady then
        for slot in pairs(slots) do
            if not Binding(slot) then slots[slot] = nil end
        end
    end
    for _, entry in ipairs(nativeButtons) do
        RefreshNativeButton(entry)
    end
end)
