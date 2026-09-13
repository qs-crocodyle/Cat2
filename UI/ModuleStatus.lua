-- 模组状态只用于提示，不改写现有能力标记或施法行为。
Cat2.UI = Cat2.UI or {}
local ui = Cat2.UI
local cachedStatus = nil
local colors = {
    green = { 0.35, 0.85, 0.48 },
    yellow = { 1, 0.76, 0.25 },
    red = { 1, 0.32, 0.32 },
}

local function Result(name, state, label, version, reason, requirement)
    return { name = name, state = state, label = label, version = version,
        reason = reason, requirement = requirement }
end

local function ParseVersion(value)
    if type(value) ~= "string" and type(value) ~= "number" then return nil end
    local _, _, major, minor, patch = string.find(tostring(value), "^v?(%d+)%.(%d+)%.?(%d*)$")
    if not major then return nil end
    return tonumber(major), tonumber(minor), tonumber(patch) or 0
end

local function DetectSuperWoW()
    local requirement = Cat2.L("当前检测基线：1.5及以上，并可读取单位GUID和技能信息。旧版本标为待确认，并非认定不能使用。")
    if not SUPERWOW_STRING and not SUPERWOW_VERSION then
        return Result("SuperWoW", "red", Cat2.L("未检测到"), Cat2.L("未读取到"), Cat2.L("对象扫描、GUID选敌等功能会受限。请确认模组已随客户端加载。"), requirement)
    end
    local version = tostring(SUPERWOW_VERSION or Cat2.L("未知"))
    local major, minor = ParseVersion(SUPERWOW_VERSION)
    if not major then
        return Result("SuperWoW", "yellow", Cat2.L("版本未知"), version, Cat2.L("已检测到模组，但无法确认版本支持情况。"), requirement)
    end
    local ok, exists, guid = pcall(UnitExists, "player")
    if not ok or not exists or not guid or type(SpellInfo) ~= "function" then
        return Result("SuperWoW", "yellow", Cat2.L("接口受限"), version, Cat2.L("未能确认单位GUID或技能信息接口，部分卡片可能受限。"), requirement)
    end
    if major < 1 or (major == 1 and minor < 5) then
        return Result("SuperWoW", "yellow", Cat2.L("旧版待确认"), version, Cat2.L("版本低于当前检测基线，建议更新后使用。"), requirement)
    end
    return Result("SuperWoW", "green", Cat2.L("支持"), version, Cat2.L("版本满足检测基线，单位GUID与技能信息接口可用。"), requirement)
end

local function DetectUnitXP()
    -- 与 AutoTargetOutside8 的成串选敌门槛保持一致。
    local requirement = Cat2.L("成串锁敌版本门槛：2026-07-20（编译时间戳1784505600）。自动扫描选敌还需要SuperWoW。")
    -- 原生客户端也有同名经验值函数，必须用扩展探测区分。
    if type(UnitXP) ~= "function" or not pcall(UnitXP, "nop", "nop") then
        return Result("UnitXP", "red", Cat2.L("未检测到"), Cat2.L("未读取到"), Cat2.L("精确距离、方位判断及成串锁敌受限。请确认模组已加载。"), requirement)
    end
    local ok, stamp = pcall(UnitXP, "version", "coffTimeDateStamp")
    if not ok or type(stamp) ~= "number" or stamp <= 0 or stamp ~= stamp or stamp == math.huge then
        return Result("UnitXP", "yellow", Cat2.L("版本未知"), Cat2.L("未知"), Cat2.L("接口存在，但无法读取有效编译版本，不能确认成串锁敌支持。"), requirement)
    end
    local version = Cat2.L("编译时间戳 ") .. tostring(stamp)
    if type(date) == "function" then
        local dateOK, formatted = pcall(date, "!%Y-%m-%d", stamp)
        if dateOK and type(formatted) == "string" then version = formatted .. " / " .. tostring(stamp) end
    end
    local distanceOK, distance = pcall(UnitXP, "distanceBetween", "player", "player")
    -- behind对相同单位按接口约定返回nil，不能用玩家自身做布尔值自检。
    -- 方位能力依据版本识别，不依赖登录时是否存在另一个可用目标。
    local sightOK, sight = pcall(UnitXP, "inSight", "player", "player")
    if not distanceOK or type(distance) ~= "number"
        or not sightOK or type(sight) ~= "boolean" then
        return Result("UnitXP", "yellow", Cat2.L("接口受限"), version, Cat2.L("距离或视野接口未通过只读检测。"), requirement)
    end
    if stamp < 1784505600 then
        return Result("UnitXP", "yellow", Cat2.L("部分支持"), version, Cat2.L("测距与视野接口可用；8码成串锁敌会降级为普通8码外锁敌。"), requirement)
    end
    return Result("UnitXP", "green", Cat2.L("支持"), version, Cat2.L("测距与视野接口可用，编译版本满足成串锁敌门槛；方位能力按版本识别。"), requirement)
end

local function DetectNampower()
    local requirement = Cat2.L("当前检测基线：4.0.0及以上，并具备施法状态、移动状态及施法队列配置接口。旧版按部分支持显示。")
    if type(GetNampowerVersion) ~= "function" then
        return Result("Nampower", "red", Cat2.L("未检测到"), Cat2.L("未读取到"), Cat2.L("施法队列控制和部分战斗事件功能受限。请确认模组已加载。"), requirement)
    end
    -- Nampower 的注入函数不能放进 pcall：其原生实现会改用客户端主 Lua state，
    -- 在受保护调用中可能破坏返回值栈。这里与 CatEvent 的登录检测保持一致，确认存在后直接调用。
    local major, minor, patch = GetNampowerVersion()
    if type(major) ~= "number" or type(minor) ~= "number" or type(patch) ~= "number"
        or major < 0 or minor < 0 or patch < 0
        or major ~= math.floor(major) or minor ~= math.floor(minor) or patch ~= math.floor(patch)
        or major == math.huge or minor == math.huge or patch == math.huge then
        return Result("Nampower", "yellow", Cat2.L("版本未知"), Cat2.L("未知"), Cat2.L("接口存在，但版本读取失败或格式无法识别。"), requirement)
    end
    local version = major .. "." .. minor .. "." .. patch
    if major < 4 then
        return Result("Nampower", "yellow", Cat2.L("部分支持"), version, Cat2.L("旧版可使用兼容路径，部分施法状态与战斗事件能力受限。"), requirement)
    end
    if type(GetCastInfo) ~= "function" or type(PlayerIsMoving) ~= "function" then
        return Result("Nampower", "yellow", Cat2.L("接口受限"), version, Cat2.L("版本满足基线，但缺少施法状态或移动状态接口。"), requirement)
    end
    local cvars = { "NP_QueueCastTimeSpells", "NP_QueueInstantSpells", "NP_QueueChannelingSpells" }
    for i = 1, table.getn(cvars) do
        local readOK, value = pcall(GetCVar, cvars[i])
        if not readOK or value == nil or value == "" then
            return Result("Nampower", "yellow", Cat2.L("接口受限"), version, Cat2.L("施法队列配置未能完整读取。"), requirement)
        end
    end
    return Result("Nampower", "green", Cat2.L("支持"), version, Cat2.L("版本满足检测基线，施法状态、移动与队列配置接口可用。"), requirement)
end

function Cat2.GetModuleStatus(refresh)
    if refresh or not cachedStatus then
        cachedStatus = { DetectSuperWoW(), DetectUnitXP(), DetectNampower() }
    end
    return cachedStatus
end

local function EnableWindowDrag(region, window)
    local dragging = false
    region:EnableMouse(true)
    region:RegisterForDrag("LeftButton")
    region:SetScript("OnDragStart", function()
        GameTooltip:Hide()
        dragging = true
        window:StartMoving()
    end)
    local function StopDragging()
        if dragging then window:StopMovingOrSizing(); dragging = false end
    end
    region:SetScript("OnDragStop", StopDragging)
    region:SetScript("OnHide", function()
        StopDragging()
        if GameTooltip:IsOwned(region) then GameTooltip:Hide() end
    end)
end

local function CreateStatusItem(parent, index, offset, width)
    local item = CreateFrame("Frame", nil, parent)
    item:SetWidth(width)
    item:SetHeight(24)
    item:SetPoint("LEFT", parent, "LEFT", offset, 0)
    item:EnableMouse(true)
    EnableWindowDrag(item, parent:GetParent())
    local dot = item:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dot:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    dot:SetPoint("LEFT", item, "LEFT", 0, 0)
    dot:SetText("●")
    local label = item:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    label:SetPoint("LEFT", item, "LEFT", 11, 0)
    label:SetTextColor(0.76, 0.82, 0.9)
    item.dot, item.label, item.statusIndex = dot, label, index
    item:SetScript("OnEnter", function()
        local status = Cat2.GetModuleStatus()[index]
        local color = colors[status.state]
        GameTooltip:SetOwner(item, "ANCHOR_BOTTOMLEFT")
        GameTooltip:SetText(status.name .. " · " .. status.label, color[1], color[2], color[3])
        GameTooltip:AddLine(Cat2.L("检测版本：") .. status.version, 0.85, 0.87, 0.9, true)
        GameTooltip:AddLine(status.reason, 0.85, 0.87, 0.9, true)
        GameTooltip:AddLine(status.requirement, 0.65, 0.72, 0.82, true)
        GameTooltip:AddLine(Cat2.L("颜色表示Cat2检测基线与接口状态，不代表是否为最新版本。"), 0.65, 0.72, 0.82, true)
        GameTooltip:Show()
    end)
    item:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return item
end

function ui.CreateModuleStatusBar(parent)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetWidth(224)
    bar:SetHeight(24)
    bar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -152, -12)
    bar:SetFrameLevel(parent:GetFrameLevel() + 20)
    EnableWindowDrag(bar, parent)
    local items = {
        CreateStatusItem(bar, 1, 0, 76),
        CreateStatusItem(bar, 2, 80, 62),
        CreateStatusItem(bar, 3, 146, 78),
    }
    local function RefreshDisplay()
        local statuses = Cat2.GetModuleStatus()
        for i = 1, table.getn(items) do
            local color = colors[statuses[i].state]
            items[i].dot:SetTextColor(color[1], color[2], color[3])
            items[i].label:SetText(statuses[i].name)
        end
    end
    bar:RegisterEvent("PLAYER_LOGIN")
    bar:SetScript("OnEvent", function()
        Cat2.GetModuleStatus(true)
        RefreshDisplay()
    end)
    -- 不在主界面构造链中同步探测外部模组。首次真正显示时再刷新；即使外部接口异常，
    -- 也不会阻止主窗口其余控件完成创建。
    bar:SetScript("OnShow", RefreshDisplay)
    parent.moduleStatusBar = bar
end
