-- 本地使用稳定配置 ID；跨角色分享只携带名称。未绑定名称使用 name: 前缀保留。
local cardId = "logic_call_configuration"

local function GetProfile(value)
    local repository = Cat2.RuntimeConfigurations
    local id = type(value) == "string" and tonumber(value) or nil
    return repository and repository.profiles and id and repository.profiles[id] or nil
end

local function MissingLabel(value)
    if type(value) == "string" and string.sub(value, 1, 5) == "name:" then
        return Cat2.L("待绑定：") .. string.sub(value, 6)
    end
    return Cat2.L("目标配置已删除，请重新选择")
end

local function Choices(step)
    local choices = { { value = "", label = Cat2.L("请选择配置") } }
    local repository = Cat2.RuntimeConfigurations
    local saved = step and step.optionValues and step.optionValues.targetProfile
    local found = saved == nil or saved == ""
    if repository and repository.profileOrder and repository.profiles then
        for _, id in ipairs(repository.profileOrder) do
            local profile = repository.profiles[id]
            if profile then
                local value = tostring(id)
                table.insert(choices, { value = value, label = profile.name })
                if saved == value then found = true end
            end
        end
    end
    if not found then
        table.insert(choices, { value = saved, label = MissingLabel(saved) })
    end
    return choices
end

-- 编码器使用独立副本，不修改正在运行的本地绑定，也不导出角色内的 ID。
function Cat2.ExportCallConfigurationOptions(step)
    local values = Cat2.CopyRawCardOptionValues(step.optionValues)
    if step.id ~= cardId then return values end
    local value = values.targetProfile
    local profile = GetProfile(value)
    if profile then
        values.configurationName = profile.name
    elseif type(value) == "string" and string.sub(value, 1, 5) == "name:" then
        values.configurationName = string.sub(value, 6)
    elseif value ~= nil and value ~= "" then
        return nil, Cat2.L("调用配置的目标已删除，请重新选择后导出")
    else
        values.configurationName = ""
    end
    values.targetProfile = nil
    return values
end

function Cat2.ImportCallConfigurationOptions(id, values)
    if id ~= cardId then return values end
    local name = values.configurationName
    -- 不信任导入数据里的本地 ID，避免跨角色误绑定。
    return { targetProfile = type(name) == "string" and name ~= "" and ("name:" .. name) or "" }
end

-- 在导入配置正式加入仓库后绑定，支持覆盖导入和自引用检测；不随按键重复扫描名称。
function Cat2.BindImportedConfigurationCalls(profile)
    local messages = {}
    for _, step in ipairs(profile.steps) do
        local values = step.optionValues
        local value = values and values.targetProfile
        if step.id == cardId and type(value) == "string" and string.sub(value, 1, 5) == "name:" then
            local name = string.sub(value, 6)
            local match = nil
            local duplicate = false
            local repository = Cat2.RuntimeConfigurations
            for _, id in ipairs(repository.profileOrder) do
                local candidate = repository.profiles[id]
                if candidate and candidate.name == name then
                    if match then duplicate = true end
                    match = candidate
                end
            end
            if match and not duplicate then
                values.targetProfile = tostring(match.id)
                table.insert(messages, Cat2.L("已关联本地配置：") .. name)
            else
                table.insert(messages, Cat2.L("调用配置待绑定：") .. name)
            end
        end
    end
    return messages
end

local card = {
    id = cardId,
    name = "调用配置",
    description = "调用|cff6bc7e0{targetProfile}|r，正常结束后继续当前流程",
    details = "选择另一套配置执行，使用该配置自己的被动规则。子流程正常走完后返回下一张卡；子流程主动终止时整轮结束。禁止递归调用，整轮共享60步预算，调用卡也计一步。目标未绑定或已删除时提示并终止。导入导出仅携带目标名称，不包含子配置内容。",
    category = "logic",
    behavior = "logic",
    canStopSequence = true,
    sort = 67,
    icons = { "Interface\\Icons\\INV_Misc_Book_09" },
    optionSchema = {
        {
            key = "targetProfile",
            label = "调用配置",
            type = "string",
            control = "select",
            default = "",
            -- 登录恢复时仓库尚未建立，也必须保留稳定 ID；用户仍只能从下拉框选择。
            preserveUnknownValue = true,
            choicesResolver = Choices,
        },
    },
}

function card.Execute(context, step)
    local value = context:GetStepOption(step, "targetProfile")
    local profile = GetProfile(value)
    if not profile then
        context:FailConfigurationCall(value == "" and Cat2.L("请先选择要调用的配置") or MissingLabel(value))
        return true
    end
    return context:CallConfiguration(profile.id)
end

Cat2.RegisterCard(card)
