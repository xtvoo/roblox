-- Texture / Buy Pad Customizer for Unamed
api:set_lua_name("WorldTextureChanger")

local RunService = game:GetService("RunService")

---------------------------------------------------------------------
-- CONFIG
---------------------------------------------------------------------

local materials = {
    "Plastic", "Wood", "WoodPlanks", "Marble", "Slate", "Concrete",
    "Brick", "Granite", "Pebble", "Cobblestone", "CorrodedMetal",
    "DiamondPlate", "Foil", "Metal", "Grass", "Sand", "Fabric",
    "SmoothPlastic", "Neon", "Glass", "ForceField", "Ice", "Glacier"
}

-- Use these; you already confirmed 518030064 and 8406538985 work
local texturePresets = {
    "None",
    "518030064",   -- Test 5
    "8406538985"   -- Test 6
}

---------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------

local worldEnabled = false
local worldMaterial = "Neon"

local padsEnabled = false           -- material / color / glow / rainbow
local padsTexturesEnabled = false   -- textures
local padsMaterial = "Neon"
local padsColor = Color3.fromRGB(0, 255, 0)
local padsRainbow = false
local padsGlow = true

local padsTextureId = ""            -- current selected / custom id
local padsAllFaces = false

local changedWorldParts = {}
local originalPadProps = {}
local hue = 0

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------

local function isPlayerPart(part)
    local character = part:FindFirstAncestorOfClass("Model")
    if character and character:FindFirstChildOfClass("Humanoid") then
        return true
    end
    return false
end

local function getShop()
    return workspace.Ignored and workspace.Ignored:FindFirstChild("Shop")
end

local function getAllBuyPads()
    local pads = {}
    local shop = getShop()
    if not shop then return pads end

    for _, item in pairs(shop:GetChildren()) do
        if item:IsA("Model") then
            local head = item:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                table.insert(pads, item)
            end
        end
    end

    return pads
end

local function formatAssetId(id)
    if not id or id == "" then return "" end
    id = id:gsub("%s+", "")

    if id:match("^rbxassetid://") then
        return id
    end
    if id:match("^http") then
        return id
    end

    local num = id:match("%d+")
    if num then
        return "rbxassetid://" .. num
    end

    return ""
end

---------------------------------------------------------------------
-- WORLD TEXTURES
---------------------------------------------------------------------

local function applyWorld()
    local mat = Enum.Material[worldMaterial]
    if not mat then return end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not changedWorldParts[obj] then
            if not (isPlayerPart(obj) or obj:FindFirstAncestorOfClass("Tool")) then
                changedWorldParts[obj] = obj.Material
                obj.Material = mat
            end
        end
    end
end

local function restoreWorld()
    for part, mat in pairs(changedWorldParts) do
        if part and part.Parent then
            part.Material = mat
        end
    end
    changedWorldParts = {}
end

---------------------------------------------------------------------
-- BUY PAD EFFECTS (MATERIAL / COLOR / GLOW / RAINBOW)
---------------------------------------------------------------------

local function applyPadEffects()
    local pads = getAllBuyPads()

    for _, pad in pairs(pads) do
        local head = pad:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            if not originalPadProps[head] then
                originalPadProps[head] = {
                    Material = head.Material,
                    Color = head.Color,
                    Transparency = head.Transparency
                }
            end

            local mat = Enum.Material[padsMaterial]
            if mat then
                head.Material = mat
            end

            if not padsRainbow then
                head.Color = padsColor
            end

            if padsGlow then
                local light = head:FindFirstChild("CustomBuyPadLight")
                if not light then
                    light = Instance.new("PointLight")
                    light.Name = "CustomBuyPadLight"
                    light.Parent = head
                end
                light.Brightness = 2
                light.Range = 20
                light.Color = head.Color
            else
                local light = head:FindFirstChild("CustomBuyPadLight")
                if light then
                    light:Destroy()
                end
            end
        end
    end
end

local function restorePads()
    for head, data in pairs(originalPadProps) do
        if head and head.Parent then
            head.Material = data.Material
            head.Color = data.Color
            head.Transparency = data.Transparency

            local light = head:FindFirstChild("CustomBuyPadLight")
            if light then
                light:Destroy()
            end
        end
    end
    originalPadProps = {}
end

local function updatePadRainbow()
    if not padsEnabled or not padsRainbow then return end

    local pads = getAllBuyPads()
    hue = (hue + 0.005) % 1
    local col = Color3.fromHSV(hue, 1, 1)

    for _, pad in pairs(pads) do
        local head = pad:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            head.Color = col
            local light = head:FindFirstChild("CustomBuyPadLight")
            if light then
                light.Color = col
            end
        end
    end
end

---------------------------------------------------------------------
-- BUY PAD TEXTURES
---------------------------------------------------------------------

local function clearCustomTextures(head)
    for _, child in pairs(head:GetChildren()) do
        if (child:IsA("Texture") or child:IsA("Decal")) and child.Name:match("^CustomBuyPad") then
            child:Destroy()
        end
    end
end

local function addTextureToFace(head, face, id)
    local texId = formatAssetId(id)
    if texId == "" then return end

    clearCustomTextures(head)

    local tex = Instance.new("Texture")
    tex.Name = "CustomBuyPadTexture"
    tex.Texture = texId
    tex.Face = face
    tex.StudsPerTileU = 4
    tex.StudsPerTileV = 4
    tex.Parent = head
end

local function applyPadTextures()
    local pads = getAllBuyPads()
    local id = padsTextureId
    if not padsTexturesEnabled or id == "" then
        -- if disabled, just clear our textures
        for _, pad in pairs(pads) do
            local head = pad:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                clearCustomTextures(head)
            end
        end
        return
    end

    for _, pad in pairs(pads) do
        local head = pad:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            clearCustomTextures(head)

            if padsAllFaces then
                addTextureToFace(head, Enum.NormalId.Top,    id)
                addTextureToFace(head, Enum.NormalId.Bottom, id)
                addTextureToFace(head, Enum.NormalId.Front,  id)
                addTextureToFace(head, Enum.NormalId.Back,   id)
                addTextureToFace(head, Enum.NormalId.Left,   id)
                addTextureToFace(head, Enum.NormalId.Right,  id)
            else
                addTextureToFace(head, Enum.NormalId.Top, id)
            end
        end
    end
end

---------------------------------------------------------------------
-- CONNECTIONS
---------------------------------------------------------------------

api:add_connection(
    workspace.DescendantAdded:Connect(function(obj)
        if worldEnabled and obj:IsA("BasePart") and not changedWorldParts[obj] then
            task.wait(0.1)
            if not (isPlayerPart(obj) or obj:FindFirstAncestorOfClass("Tool")) then
                changedWorldParts[obj] = obj.Material
                obj.Material = Enum.Material[worldMaterial]
            end
        end
    end)
)

api:add_connection(
    RunService.Heartbeat:Connect(function()
        updatePadRainbow()
    end)
)

---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------

local tab = api:GetTab("world") or api:AddTab("world")

---------------------------------------------------------------------
-- World box
---------------------------------------------------------------------

local worldBox = tab:AddLeftGroupbox("World Textures")

worldBox:AddToggle("World_Enable", {
    Text = "Enable World",
    Default = false,
    Callback = function(val)
        worldEnabled = val
        if val then
            applyWorld()
            api:notify("World textures enabled", 2)
        else
            restoreWorld()
            api:notify("World textures disabled", 2)
        end
    end
})

worldBox:AddDropdown("World_Material", {
    Text = "Material",
    Values = materials,
    Default = 1,
    Callback = function(value)
        worldMaterial = value
        if worldEnabled then
            restoreWorld()
            applyWorld()
        end
    end
})

worldBox:AddButton({
    Text = "Refresh World",
    Func = function()
        if worldEnabled then
            restoreWorld()
            applyWorld()
        end
    end
})

---------------------------------------------------------------------
-- Buy pad box
---------------------------------------------------------------------

local padBox = tab:AddRightGroupbox("Buy Pads")

padBox:AddToggle("Pads_EnableEffects", {
    Text = "Enable Effects",
    Default = false,
    Callback = function(val)
        padsEnabled = val
        if val then
            applyPadEffects()
        else
            restorePads()
        end
    end
})

padBox:AddDropdown("Pads_Material", {
    Text = "Pad Material",
    Values = {"Neon", "ForceField", "Glass", "SmoothPlastic", "Metal", "Plastic"},
    Default = 1,
    Callback = function(value)
        padsMaterial = value
        if padsEnabled then
            applyPadEffects()
        end
    end
})

padBox:AddToggle("Pads_Rainbow", {
    Text = "Rainbow",
    Default = false,
    Callback = function(val)
        padsRainbow = val
        if not val and padsEnabled then
            applyPadEffects()
        end
    end
})

padBox:AddToggle("Pads_Glow", {
    Text = "Glow",
    Default = true,
    Callback = function(val)
        padsGlow = val
        if padsEnabled then
            applyPadEffects()
        end
    end
})

padBox:AddLabel("Pad Color"):AddColorPicker("Pads_Color", {
    Default = padsColor,
    Title = "Pad Color",
    Callback = function(col)
        padsColor = col
        if padsEnabled and not padsRainbow then
            applyPadEffects()
        end
    end
})

padBox:AddDivider()

---------------------------------------------------------------------
-- Texture controls
---------------------------------------------------------------------

padBox:AddToggle("Pads_TexturesEnable", {
    Text = "Enable Textures",
    Default = false,
    Callback = function(val)
        padsTexturesEnabled = val
        applyPadTextures()
    end
})

padBox:AddDropdown("Pads_TexturePreset", {
    Text = "Texture Preset",
    Values = texturePresets,
    Default = 1,
    Callback = function(value)
        if value == "None" then
            padsTextureId = ""
        else
            padsTextureId = value
        end
        if padsTexturesEnabled then
            applyPadTextures()
        end
    end
})

padBox:AddInput("Pads_CustomTexture", {
    Default = "",
    Numeric = false,
    Finished = true,
    Text = "Custom Texture ID",
    Placeholder = "e.g. 518030064",
    Callback = function(text)
        padsTextureId = text
        if padsTexturesEnabled then
            applyPadTextures()
        end
    end
})

padBox:AddToggle("Pads_AllFaces", {
    Text = "All Faces",
    Default = false,
    Callback = function(val)
        padsAllFaces = val
        if padsTexturesEnabled then
            applyPadTextures()
        end
    end
})

padBox:AddButton({
    Text = "Refresh Pads",
    Func = function()
        if padsEnabled then
            applyPadEffects()
        end
        if padsTexturesEnabled then
            applyPadTextures()
        end
    end
})

---------------------------------------------------------------------
-- Events
---------------------------------------------------------------------

api:on_event("localplayer_spawned", function()
    task.wait(0.5)
    if worldEnabled then
        applyWorld()
    end
    if padsEnabled then
        applyPadEffects()
    end
    if padsTexturesEnabled then
        applyPadTextures()
    end
end)

api:on_event("unload", function()
    worldEnabled = false
    padsEnabled = false
    padsTexturesEnabled = false
    restoreWorld()
    restorePads()
end)

api:notify("Texture / Buy Pad script loaded", 3)
