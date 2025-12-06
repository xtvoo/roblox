-- set lua name (important for configs)
api:set_lua_name("fake_cosmetics")

---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------

local tab = api:AddTab("Cosmetics")
local group = tab:AddLeftGroupbox("Fake Cosmetics")

group:AddToggle("fake_korblox_toggle", {
    Text = "Fake Korblox",
    Default = false
})

group:AddToggle("fake_headless_toggle", {
    Text = "Fake Headless",
    Default = false
})

---------------------------------------------------------------------
-- FUNCTIONS
---------------------------------------------------------------------

local function apply_korblox(character, enabled)
    if not character then return end

    local rf = character:FindFirstChild("RightFoot")
    local rll = character:FindFirstChild("RightLowerLeg")
    local rul = character:FindFirstChild("RightUpperLeg")

    if not (rf and rll and rul) then return end

    if enabled then
        rf.MeshId = "http://www.roblox.com/asset/?id=902942089"
        rf.Transparency = 1

        rll.MeshId = "http://www.roblox.com/asset/?id=902942093"
        rll.Transparency = 1

        rul.MeshId = "http://www.roblox.com/asset/?id=902942096"
        rul.TextureID = "http://roblox.com/asset/?id=902843398"
    else
        rf.MeshId = ""
        rf.Transparency = 0

        rll.MeshId = ""
        rll.Transparency = 0

        rul.MeshId = ""
        rul.TextureID = ""
    end
end


local function apply_headless(character, enabled)
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    if enabled then
        head.Transparency = 1
        local face = head:FindFirstChild("face")
        if face then face:Destroy() end
    else
        head.Transparency = 0
        if not head:FindFirstChild("face") then
            local new_face = Instance.new("Decal")
            new_face.Name = "face"
            new_face.Texture = "rbxasset://textures/face.png"
            new_face.Face = Enum.NormalId.Front
            new_face.Parent = head
        end
    end
end

---------------------------------------------------------------------
-- TOGGLE CHANGERS
---------------------------------------------------------------------

api:get_ui_object("fake_korblox_toggle"):OnChanged(function(val)
    local char = game:GetService("Players").LocalPlayer.Character
    apply_korblox(char, val)
end)

api:get_ui_object("fake_headless_toggle"):OnChanged(function(val)
    local char = game:GetService("Players").LocalPlayer.Character
    apply_headless(char, val)
end)

---------------------------------------------------------------------
-- RESPAWN HANDLER
---------------------------------------------------------------------

api:on_event("localplayer_spawned", function(character)
    task.wait(0.25)

    local kor = api:get_ui_object("fake_korblox_toggle"):GetValue()
    local head = api:get_ui_object("fake_headless_toggle"):GetValue()

    apply_korblox(character, kor)
    apply_headless(character, head)
end)

---------------------------------------------------------------------
-- CLEANUP ON UNLOAD
---------------------------------------------------------------------

api:on_event("unload", function()
    local char = game:GetService("Players").LocalPlayer.Character
    apply_korblox(char, false)
    apply_headless(char, false)
end)
