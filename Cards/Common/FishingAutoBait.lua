-- 钓鱼（自动上饵）通用卡片骨架；具体执行逻辑由后续补充。
local card = {
    id = "common_fishing_auto_bait",
    name = "钓鱼（自动上饵）",
    description = "使用|cff6bc7e0{baitItemName}|r自动为鱼竿补充鱼饵并开始甩杆",
    details = "开始钓鱼；鱼竿没有鱼饵效果时，尝试使用参数中填写的鱼饵物品，默认明亮的小珠。鱼饵名称为空或背包中不存在该物品时跳过上饵。",
    -- 紧随“远程（射击/魔杖/投掷）”。
    sort = 13,
    category = "common",
    icons = {
        "Interface\\Icons\\Trade_Fishing",
    },
    optionSchema = {
        {
            key = "baitItemName",
            type = "string",
            label = "鱼饵名称",
            shortLabel = "饵",
            default = "明亮的小珠",
        },
    },
}

local FishPole = false

function card.RefreshRuntimeData()
    FishPole = false
    if Cat2.GetMainHandType()=="鱼竿" then
        FishPole = true
    end
end

local FishPoleTip = CreateFrame("GameTooltip", "Cat2FishPoleTip", nil, "GameTooltipTemplate")

local function GetBait()

	FishPoleTip:SetOwner(UIParent, "ANCHOR_NONE")
    FishPoleTip:ClearLines()
    FishPoleTip:SetInventoryItem("player", 16)
    -- 扫描 Tooltip 文本
    for i = 2, FishPoleTip:NumLines() do
        local line = _G["Cat2FishPoleTipTextLeft"..i]
        if line then
            local text = line:GetText() or ""
            local Value = string.find(text, "鱼饵")
            if Value then
                return true
            end

        end
    end

	return false
end

function card.Execute(context, step)

    local baitItemName = context:GetStepOption(step, "baitItemName")

    -- 是否装备了鱼竿
    if not FishPole then
        return false
    end

    -- 是否有鱼饵
    if not GetBait() then
        -- 参数为空或背包中不存在该物品时，只跳过上饵，仍可继续甩杆。
        if type(baitItemName) == "string" and baitItemName ~= "" and
            Cat2.GetItemByNameID(baitItemName) ~= 0 then
            -- 只有鱼饵成功进入鼠标后才尝试应用到主手鱼竿。
            if Cat2.UseItemByName(baitItemName) then
                PickupInventoryItem(16)
                Cat2.ClickReplace()
                ClearCursor()
            end
        end
    end

    Cat2.Cast("钓鱼")
    return true
end

Cat2.RegisterCard(card)
