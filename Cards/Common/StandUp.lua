-- 从坐姿起立，继续执行后续卡片。
local card = {
    id = "common_stand_up",
    name = "起立",
    description = "从坐着的状态站起来",
    details = "执行 DoEmote(\"STAND\") 让角色站起来，无需目标。已安装且支持姿态查询的 Nampower 版本下，站立时不重复执行；未安装、接口不支持或查询失败时保留直接起立行为。执行后继续后续卡片。",
    sort = 50.5,
    category = "common",
    icons = {
        "Interface\\Icons\\INV_Misc_Foot_Kodo",
    },
}

function card.RefreshRuntimeData()
end

function card.Execute(context)
    -- 按接口及字段是否实际可用兼容 Nampower 版本，旧版本可能不支持 bytes1。
    if Cat2.Nampower and type(GetUnitField) == "function" then
        local ok, value = pcall(GetUnitField, "player", "bytes1")
        if ok and type(value) == "number" and value >= 0 and value <= 4294967295
            and value == math.floor(value) and math.mod(value, 256) == 0 then
            return false
        end
    end
    DoEmote("STAND")
    return false
end

Cat2.RegisterCard(card)
