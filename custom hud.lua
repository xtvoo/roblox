local env = getfenv()
local api = env.api
if not api then return end

api:set_lua_name("hud_changer_hex")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local defaultTextHP     = " Health "
local defaultTextArmor  = "                   Armor"
local defaultTextEnergy = "Dark Energy              "

local defaultColorHP     = Color3.fromRGB(240, 8, 209)
local defaultColorArmor  = Color3.fromRGB(96, 8, 238)
local defaultColorEnergy = Color3.fromRGB(196, 10, 243)

local function safe_get_flag(name, default)
    local obj = api:get_ui_object(name)
    if not obj then return default end
    local ok, v = pcall(function() return obj.Value end)
    return ok and v or default
end

local function parse_hex(str, fallback)
    if type(str) ~= "string" then return fallback end
    str = str:gsub("#","")
    if #str ~= 6 then return fallback end
    local r = tonumber(str:sub(1,2), 16)
    local g = tonumber(str:sub(3,4), 16)
    local b = tonumber(str:sub(5,6), 16)
    if not r or not g or not b then return fallback end
    return Color3.fromRGB(r,g,b)
end

local function update_hud()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local msg = pg:FindFirstChild("MainScreenGui")
    if not msg then return end
    local bar = msg:FindFirstChild("Bar")
    if not bar then return end

    -- HEALTH
    local useHP   = safe_get_flag("hud_hp_toggle", false)
    local hpText  = safe_get_flag("hud_hp_text", defaultTextHP)
    local hpHex   = safe_get_flag("hud_hp_hex", "#F008D1")
    local hpColor = parse_hex(hpHex, defaultColorHP)

    local hp = bar:FindFirstChild("HP")
    if hp then
        local label = hp:FindFirstChild("TextLabel")
        local fill  = hp:FindFirstChild("bar")
        if label then label.Text = useHP and hpText or defaultTextHP end
        if fill  then fill.BackgroundColor3 = useHP and hpColor or defaultColorHP end
    end

    -- ARMOR
    local useArmor   = safe_get_flag("hud_armor_toggle", false)
    local armorText  = safe_get_flag("hud_armor_text", defaultTextArmor)
    local armorHex   = safe_get_flag("hud_armor_hex", "#6008EE")
    local armorColor = parse_hex(armorHex, defaultColorArmor)

    local armor = bar:FindFirstChild("Armor")
    if armor then
        local label = armor:FindFirstChild("TextLabel")
        local fill  = armor:FindFirstChild("bar")
        if label then label.Text = useArmor and armorText or defaultTextArmor end
        if fill  then fill.BackgroundColor3 = useArmor and armorColor or defaultColorArmor end
    end

    -- ENERGY
    local useEnergy   = safe_get_flag("hud_energy_toggle", false)
    local energyText  = safe_get_flag("hud_energy_text", defaultTextEnergy)
    local energyHex   = safe_get_flag("hud_energy_hex", "#C40AF3")
    local energyColor = parse_hex(energyHex, defaultColorEnergy)

    local energy = bar:FindFirstChild("Energy")
    if energy then
        local label = energy:FindFirstChild("TextLabel")
        local fill  = energy:FindFirstChild("bar")
        if label then label.Text = useEnergy and energyText or defaultTextEnergy end
        if fill  then fill.BackgroundColor3 = useEnergy and energyColor or defaultColorEnergy end
    end
end

-- UI
local tab = api:get_tab("visuals") or api:add_tab("visuals")
local box = tab:add_left_groupbox("Hud Changer (Hex)")

-- Health
box:add_toggle("hud_hp_toggle", {
    Text = "Custom Health",
    Default = false,
    Callback = function() update_hud() end,
})

box:add_input("hud_hp_text", {
    Text = "Health Text",
    Default = defaultTextHP,
    Finished = true,
    Callback = function() update_hud() end,
})

box:add_input("hud_hp_hex", {
    Text = "Health Hex (#RRGGBB)",
    Default = "#F008D1",
    Finished = true,
    Callback = function() update_hud() end,
})

-- Armor
box:add_toggle("hud_armor_toggle", {
    Text = "Custom Armor",
    Default = false,
    Callback = function() update_hud() end,
})

box:add_input("hud_armor_text", {
    Text = "Armor Text",
    Default = defaultTextArmor,
    Finished = true,
    Callback = function() update_hud() end,
})

box:add_input("hud_armor_hex", {
    Text = "Armor Hex (#RRGGBB)",
    Default = "#6008EE",
    Finished = true,
    Callback = function() update_hud() end,
})

-- Energy
box:add_toggle("hud_energy_toggle", {
    Text = "Custom Energy",
    Default = false,
    Callback = function() update_hud() end,
})

box:add_input("hud_energy_text", {
    Text = "Energy Text",
    Default = defaultTextEnergy,
    Finished = true,
    Callback = function() update_hud() end,
})

box:add_input("hud_energy_hex", {
    Text = "Energy Hex (#RRGGBB)",
    Default = "#C40AF3",
    Finished = true,
    Callback = function() update_hud() end,
})

-- Respawn + unload
api:add_connection(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    update_hud()
end))

task.spawn(function()
    task.wait(1)
    update_hud()
end)

api:on_event("unload", function()
    api:notify("HUD hex addon unloaded", 2)
end)
