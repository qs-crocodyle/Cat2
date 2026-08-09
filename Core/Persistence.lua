-- Cat2 角色专属持久化数据。
-- 这里只保存可序列化的稳定字段；卡片函数在登录时根据卡片 ID 从注册中心重新绑定。
Cat2 = Cat2 or {}

local schemaVersion = 1

-- 已发布卡片的旧 ID 映射。重命名卡片时保留这里的映射，
-- 让旧流程在下次载入后自动绑定到新卡片，并在保存时写回新 ID。
local legacyCardIds = {
    druid_faerie_fire2 = "druid_faerie_fire_feral",
    -- “随机治疗团队”规范化命名后的兼容迁移。
    shared_healing_raid = "shared_random_healing_team",
    -- “优先血量最高”改为团队治疗的优先坦克策略。
    shared_healing_highest_health = "shared_healing_team_priority_tank"
}

local function CreateDefaultRepository()
    return {
        schemaVersion = schemaVersion,
        activeProfileId = 1,
        nextProfileId = 2,
        profileOrder = { 1 },
        profiles = {
            [1] = {
                id = 1,
                name = "Profile1",
                steps = {}
            }
        }
    }
end

local function EnsureDatabase()
    if type(Cat2CharacterDB) ~= "table" then
        Cat2CharacterDB = {}
    end
    Cat2CharacterDB.schemaVersion = schemaVersion
    if type(Cat2CharacterDB.ui) ~= "table" then
        Cat2CharacterDB.ui = {}
    end
    return Cat2CharacterDB
end

local function FindCard(cardId)
    local registry = Cat2.CardRegistry
    if not registry or type(registry.Cards) ~= "table" then
        return nil
    end
    local index = 1
    local total = table.getn(registry.Cards)
    while index <= total do
        local card = registry.Cards[index]
        if card and card.id == cardId then
            return card
        end
        index = index + 1
    end
    return nil
end

local function RestoreStep(savedStep)
    if type(savedStep) ~= "table" or type(savedStep.id) ~= "string" then
        return nil
    end
    local cardId = legacyCardIds[savedStep.id] or savedStep.id
    local card = FindCard(cardId)
    if not card then
        -- 卡片暂时未注册时保留原 ID 与流程位置，避免一次加载就永久破坏用户配置。
        -- 占位卡强制暂停并从最小化栏隐藏；卡片恢复注册后，下次登录会自动还原。
        return {
            id = cardId,
            name = Cat2.L("未识别卡片"),
            description = "ID：" .. cardId,
            icons = { "Interface\\Icons\\INV_Misc_QuestionMark" },
            enabled = 0,
            minimizedVisible = 0,
            isMissing = true
        }
    end
    if Cat2.ResolveCardIcon then
        Cat2.ResolveCardIcon(card)
    end
    local step = {
        enabled = savedStep.enabled == 0 and 0 or 1,
        minimizedVisible = savedStep.minimizedVisible == 0 and 0 or 1
    }
    setmetatable(step, {
        __index = card
    })
    return step
end

-- 导入配置与登录恢复共用同一套卡片还原规则，未知 ID 也会保留原位置。
Cat2.RestoreConfigurationStep = RestoreStep

-- 从当前角色的 SavedVariables 恢复配置；损坏或过旧的数据自动回退到“配置1”。
function Cat2.LoadConfigurationData()
    local database = EnsureDatabase()
    local saved = database.configurations
    if type(saved) ~= "table" or type(saved.profileOrder) ~= "table" or type(saved.profiles) ~= "table" then
        return CreateDefaultRepository()
    end

    local repository = {
        schemaVersion = schemaVersion,
        activeProfileId = saved.activeProfileId,
        nextProfileId = tonumber(saved.nextProfileId) or 1,
        profileOrder = {},
        profiles = {}
    }
    local largestId = 0
    local orderIndex = 1
    local orderTotal = table.getn(saved.profileOrder)
    while orderIndex <= orderTotal do
        local profileId = tonumber(saved.profileOrder[orderIndex])
        local savedProfile = profileId and saved.profiles[profileId]
        if profileId and type(savedProfile) == "table" and type(savedProfile.name) == "string" then
            local profile = { id = profileId, name = savedProfile.name, steps = {} }
            local savedSteps = savedProfile.steps
            if type(savedSteps) == "table" then
                local stepIndex = 1
                local stepTotal = table.getn(savedSteps)
                while stepIndex <= stepTotal do
                    local step = RestoreStep(savedSteps[stepIndex])
                    if step then
                        table.insert(profile.steps, step)
                    end
                    stepIndex = stepIndex + 1
                end
            end
            Cat2.NormalizeExclusiveFlowSteps(profile.steps)
            repository.profiles[profileId] = profile
            table.insert(repository.profileOrder, profileId)
            if profileId > largestId then
                largestId = profileId
            end
        end
        orderIndex = orderIndex + 1
    end

    if table.getn(repository.profileOrder) == 0 then
        return CreateDefaultRepository()
    end
    if not repository.profiles[repository.activeProfileId] then
        repository.activeProfileId = repository.profileOrder[1]
    end
    if repository.nextProfileId <= largestId then
        repository.nextProfileId = largestId + 1
    end
    return repository
end

-- 将运行时配置压缩成纯数据，避免 SavedVariables 写入函数和重复的卡片描述。
function Cat2.SaveConfigurationData(repository)
    if type(repository) ~= "table" then
        return
    end
    local database = EnsureDatabase()
    local saved = {
        schemaVersion = schemaVersion,
        activeProfileId = repository.activeProfileId,
        nextProfileId = repository.nextProfileId,
        profileOrder = {},
        profiles = {}
    }
    local orderIndex = 1
    local orderTotal = table.getn(repository.profileOrder)
    while orderIndex <= orderTotal do
        local profileId = repository.profileOrder[orderIndex]
        local profile = repository.profiles[profileId]
        if profile then
            local savedProfile = { id = profileId, name = profile.name, steps = {} }
            local stepIndex = 1
            local stepTotal = table.getn(profile.steps)
            while stepIndex <= stepTotal do
                local step = profile.steps[stepIndex]
                if step and step.id then
                    table.insert(savedProfile.steps, {
                        id = step.id,
                        enabled = step.enabled == 0 and 0 or 1,
                        minimizedVisible = step.minimizedVisible == 0 and 0 or 1
                    })
                end
                stepIndex = stepIndex + 1
            end
            saved.profiles[profileId] = savedProfile
            table.insert(saved.profileOrder, profileId)
        end
        orderIndex = orderIndex + 1
    end
    database.configurations = saved
end

function Cat2.GetMinimapAngle()
    local database = EnsureDatabase()
    return tonumber(database.ui.minimapAngle) or 2.35619449
end

function Cat2.SaveMinimapAngle(angle)
    local database = EnsureDatabase()
    database.ui.minimapAngle = angle
end

function Cat2.GetMinimizedPosition()
    local database = EnsureDatabase()
    local position = database.ui.minimizedPosition
    if type(position) ~= "table" then
        return nil, nil
    end
    return tonumber(position.left), tonumber(position.top)
end

function Cat2.SaveMinimizedPosition(left, top)
    if not left or not top then
        return
    end
    local database = EnsureDatabase()
    database.ui.minimizedPosition = { left = left, top = top }
end

-- 记录退出游戏时独立流程快捷小窗是否仍处于显示状态。
function Cat2.ShouldRestoreMinimizedWindow()
    local database = EnsureDatabase()
    return database.ui.minimizedWindowVisible == 1
end

function Cat2.SaveMinimizedWindowVisible(visible)
    local database = EnsureDatabase()
    database.ui.minimizedWindowVisible = visible and 1 or 0
end

function Cat2.GetMinimizedLayout()
    local database = EnsureDatabase()
    local layout = database.ui.minimizedLayout
    if type(layout) ~= "table" then
        return 1, "horizontal"
    end
    local direction = layout.direction
    if direction ~= "vertical" then
        direction = "horizontal"
    end
    return tonumber(layout.iconLimit) or tonumber(layout.columns) or 1, direction
end

function Cat2.SaveMinimizedLayout(iconLimit, direction)
    local database = EnsureDatabase()
    database.ui.minimizedLayout = { iconLimit = iconLimit, direction = direction }
end

-- 每个配置拥有独立的快捷窗状态。旧版单窗口数据会在首次访问当前配置时迁移。
local function GetProfileShortcutWindowTable(profileId)
    local database = EnsureDatabase()
    if type(database.ui.shortcutWindows) ~= "table" then
        database.ui.shortcutWindows = {}
    end
    local settings = database.ui.shortcutWindows[profileId]
    if type(settings) ~= "table" then
        settings = {
            visible = 0,
            iconLimit = 1,
            direction = "vertical",
            scale = 1
        }
        local activeProfileId = database.configurations and database.configurations.activeProfileId
        if profileId == activeProfileId and database.ui.minimizedWindowVisible == 1 then
            local legacyLayout = database.ui.minimizedLayout or {}
            local legacyPosition = database.ui.minimizedPosition or {}
            settings.visible = 1
            settings.iconLimit = tonumber(legacyLayout.iconLimit) or tonumber(legacyLayout.columns) or 1
            settings.direction = legacyLayout.direction == "vertical" and "vertical" or "horizontal"
            settings.left = tonumber(legacyPosition.left)
            settings.top = tonumber(legacyPosition.top)
        end
        database.ui.shortcutWindows[profileId] = settings
    end
    return settings
end

function Cat2.GetProfileShortcutWindowSettings(profileId)
    local settings = GetProfileShortcutWindowTable(profileId)
    local iconLimit = math.floor(tonumber(settings.iconLimit) or 1)
    if iconLimit < 1 then
        iconLimit = 1
    end
    if iconLimit > 10 then
        iconLimit = 10
    end
    local direction = settings.direction == "vertical" and "vertical" or "horizontal"
    local scale = tonumber(settings.scale) or 1
    if scale < 0.5 then
        scale = 0.5
    end
    if scale > 1.8 then
        scale = 1.8
    end
    return settings.visible == 1, iconLimit, direction, tonumber(settings.left), tonumber(settings.top), scale
end

function Cat2.SaveProfileShortcutWindowSettings(profileId, visible, iconLimit, direction, left, top, scale)
    local settings = GetProfileShortcutWindowTable(profileId)
    settings.visible = visible and 1 or 0
    settings.iconLimit = math.floor(tonumber(iconLimit) or 1)
    if settings.iconLimit < 1 then
        settings.iconLimit = 1
    end
    if settings.iconLimit > 10 then
        settings.iconLimit = 10
    end
    settings.direction = direction == "vertical" and "vertical" or "horizontal"
    if left and top then
        settings.left = left
        settings.top = top
    end
    if scale then
        settings.scale = tonumber(scale) or 1
        if settings.scale < 0.5 then
            settings.scale = 0.5
        end
        if settings.scale > 1.8 then
            settings.scale = 1.8
        end
    end
end

function Cat2.RemoveProfileShortcutWindowSettings(profileId)
    local database = EnsureDatabase()
    if type(database.ui.shortcutWindows) == "table" then
        database.ui.shortcutWindows[profileId] = nil
    end
end

function Cat2.ResetProfileShortcutWindowPosition(profileId)
    local settings = GetProfileShortcutWindowTable(profileId)
    settings.left = nil
    settings.top = nil
end

function Cat2.ResetMinimizedPositionData()
    local database = EnsureDatabase()
    database.ui.minimizedPosition = nil
end
