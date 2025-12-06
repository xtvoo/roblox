-- ===== SETUP =====
local api = getfenv().api or {}

if not api or type(api.notify) ~= "function" then
    warn("Addon: Unnamed API not available")
    return
end

-- Set the addon name (use underscores, no special chars)
api:set_lua_name("math_vfx_hit_effects")

-- ===== CONFIGURATION =====
local Config = {
    Enabled = true,
    SpawnCount = 20,
    SpawnInterval = 0.01,
    MathMode = true,
    SymbolSize = 40,
    AnimationSpeed = 2,
    RandomColor = true,
    SymbolLifetime = 3,
    SpawnRadius = 50,
    MovementScale = 1,
    RotationSpeed = 1,
    StrokeTransparency = 0.3,
    TextScaleMode = true,
    UseOutline = true,
    OutlineColor = Color3.fromRGB(0, 0, 0),
    ParticleUpwardBias = 0,
    FollowTarget = true,
}

local mathSymbols = {
    "π", "√", "Σ", "∞", "Δ", "∫", "≈", "≠", "×", "÷",
    "θ", "α", "β", "cos(x)", "sin(x)", "tan(x)",
    "x²", "y = mx + b", "a² + b² = c²"
}

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local VFXFolder = nil
local activeEffects = {}
local lastTargetPos = nil

-- ===== DEFINE ALL FUNCTIONS FIRST =====

local function getTargetPosition()
    -- Try ragebot first
    local target = api:get_target("ragebot")
    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            lastTargetPos = hrp.Position
            return hrp.Position
        end
    end
    
    -- Try aimbot if ragebot fails
    target = api:get_target("aimbot")
    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            lastTargetPos = hrp.Position
            return hrp.Position
        end
    end
    
    -- Try silent aim if both fail
    target = api:get_target("silent")
    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            lastTargetPos = hrp.Position
            return hrp.Position
        end
    end
    
    -- Fallback to last known position if all fail
    return lastTargetPos
end

local function randomPos()
    local targetPos = getTargetPosition()
    
    -- Only spawn if we have a valid target
    if not targetPos then
        return nil
    end
    
    -- Spawn around target in a sphere
    local angle = math.rad(math.random(0, 360))
    local elevation = math.rad(math.random(-90, 90))
    
    local x = math.cos(elevation) * math.cos(angle) * Config.SpawnRadius
    local y = math.sin(elevation) * Config.SpawnRadius
    local z = math.cos(elevation) * math.sin(angle) * Config.SpawnRadius
    
    return targetPos + Vector3.new(x, y, z)
end

local function getSymbol()
    if Config.MathMode then
        return mathSymbols[math.random(1, #mathSymbols)]
    else
        return mathSymbols[math.random(1, #mathSymbols)]
    end
end

local function spawnSymbol()
    if not VFXFolder or not VFXFolder.Parent then
        return
    end
    
    local pos = randomPos()
    if not pos then
        return
    end
    
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(1, 1, 1)
    part.Transparency = 1
    part.Position = pos
    part.Parent = VFXFolder
    
    local billboard = Instance.new("BillboardGui", part)
    billboard.Size = UDim2.new(0, Config.SymbolSize, 0, Config.SymbolSize)
    billboard.AlwaysOnTop = true
    
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = Config.TextScaleMode
    label.Text = getSymbol()
    
    if Config.RandomColor then
        label.TextColor3 = Color3.fromHSV(tick() % 1, 1, 1)
    else
        label.TextColor3 = Color3.fromHSV(math.random() % 1, 1, 1)
    end
    
    if Config.UseOutline then
        label.TextStrokeTransparency = Config.StrokeTransparency
        label.TextStrokeColor3 = Config.OutlineColor
    else
        label.TextStrokeTransparency = 1
    end
    
    local rotate = Instance.new("BodyAngularVelocity")
    rotate.AngularVelocity = Vector3.new(math.random(), math.random(), math.random()) * 2 * Config.RotationSpeed
    rotate.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    rotate.Parent = part
    
    local tween = TweenService:Create(
        label,
        TweenInfo.new(
            Config.AnimationSpeed,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut,
            -1,
            true
        ),
        { TextColor3 = Color3.fromHSV((tick() * 0.1) % 1, 1, 1) }
    )
    tween:Play()
    
    -- Spawn animation task
    task.spawn(function()
        local startTime = tick()
        local offsetFromTarget = pos - getTargetPosition()
        
        while part and part.Parent do
            local elapsed = tick() - startTime
            
            -- Move symbol with customizable scale
            part.Position = part.Position + Vector3.new(
                math.sin(tick() * 2) / 40 * Config.MovementScale,
                (math.cos(tick() * 3) / 40 * Config.MovementScale) + (Config.ParticleUpwardBias / 100),
                math.sin(tick() * 1.5) / 40 * Config.MovementScale
            )
            
            -- Follow target if enabled
            if Config.FollowTarget then
                local currentTargetPos = getTargetPosition()
                if currentTargetPos then
                    -- Keep the offset from target constant
                    part.Position = currentTargetPos + offsetFromTarget
                end
            end
            
            -- Fade out near end of life
            if elapsed > Config.SymbolLifetime * 0.7 then
                local fadeProgress = (elapsed - Config.SymbolLifetime * 0.7) / (Config.SymbolLifetime * 0.3)
                label.TextTransparency = math.min(fadeProgress, 1)
            end
            
            -- Despawn after lifetime
            if elapsed >= Config.SymbolLifetime then
                if part then
                    part:Destroy()
                end
                break
            end
            
            task.wait()
        end
    end)
    
    table.insert(activeEffects, part)
end

local function SpawnMathVFX()
    if not Config.Enabled then return end
    
    -- Only spawn if we have a target
    if not getTargetPosition() then
        api:notify("No target!", 1)
        return
    end
    
    -- Create folder if needed
    if not VFXFolder or not VFXFolder.Parent then
        VFXFolder = Instance.new("Folder", workspace)
        VFXFolder.Name = "MathsWorldVFX"
        activeEffects = {}
    end
    
    -- Spawn symbols
    for i = 1, Config.SpawnCount do
        spawnSymbol()
        task.wait(Config.SpawnInterval)
    end
    
    api:notify("Spawned " .. Config.SpawnCount .. " math symbols on target!", 2)
end

local function UpdateCameraFacing()
    if not VFXFolder or not VFXFolder.Parent then return end
    
    for _, v in pairs(VFXFolder:GetChildren()) do
        if v:IsA("Part") then
            local camera = workspace.CurrentCamera
            v.CFrame = CFrame.new(v.Position, camera.CFrame.Position)
        end
    end
end

-- ===== NOW SETUP UI =====
local tab = api:GetTab("visuals") or api:AddTab("visuals")
local leftBox = tab:AddLeftGroupbox("Math VFX Hit Effects")
local rightBox = tab:AddRightGroupbox("Settings")

-- ===== LEFT BOX CONTROLS =====
leftBox:AddToggle("math_vfx_enabled", {
    Text = "Enable Math VFX",
    Default = true,
    Callback = function(val)
        Config.Enabled = val
        api:notify(val and "Math VFX Enabled" or "Math VFX Disabled", 2)
    end
})

leftBox:AddToggle("math_vfx_random_color", {
    Text = "Rainbow Colors",
    Default = true,
    Callback = function(val)
        Config.RandomColor = val
        api:notify(val and "Rainbow ON" or "Rainbow OFF", 1)
    end
})

leftBox:AddToggle("math_vfx_outline", {
    Text = "Text Outline",
    Default = true,
    Callback = function(val)
        Config.UseOutline = val
        api:notify(val and "Outline ON" or "Outline OFF", 1)
    end
})

leftBox:AddToggle("math_vfx_follow_target", {
    Text = "Follow Target",
    Default = true,
    Callback = function(val)
        Config.FollowTarget = val
        api:notify(val and "Follow ON" or "Follow OFF", 1)
    end
})

leftBox:AddButton({
    Text = "Spawn VFX Now",
    Func = function()
        if Config.Enabled then
            SpawnMathVFX()
        else
            api:notify("VFX disabled", 1)
        end
    end
})

leftBox:AddButton({
    Text = "Clear VFX",
    Func = function()
        if VFXFolder then
            VFXFolder:Destroy()
            VFXFolder = nil
            activeEffects = {}
            api:notify("VFX cleared", 1)
        end
    end
})

-- ===== RIGHT BOX SETTINGS - SPAWNING =====
rightBox:AddLabel("━━ SPAWNING ━━", true)

rightBox:AddSlider("math_vfx_count", {
    Text = "Spawn Count",
    Default = 20,
    Min = 5,
    Max = 100,
    Rounding = 5,
    Callback = function(val)
        Config.SpawnCount = val
    end
})

rightBox:AddSlider("math_vfx_interval", {
    Text = "Spawn Interval",
    Default = 0.01,
    Min = 0.001,
    Max = 0.05,
    Rounding = 0.001,
    Callback = function(val)
        Config.SpawnInterval = val
    end
})

rightBox:AddSlider("math_vfx_radius", {
    Text = "Spawn Radius",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 5,
    Callback = function(val)
        Config.SpawnRadius = val
    end
})

-- ===== RIGHT BOX SETTINGS - VISUALS =====
rightBox:AddLabel("━━ VISUALS ━━", true)

rightBox:AddSlider("math_vfx_size", {
    Text = "Symbol Size",
    Default = 40,
    Min = 20,
    Max = 150,
    Rounding = 5,
    Callback = function(val)
        Config.SymbolSize = val
    end
})

rightBox:AddSlider("math_vfx_stroke", {
    Text = "Outline Thickness",
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 0.1,
    Callback = function(val)
        Config.StrokeTransparency = val
    end
})

-- ===== RIGHT BOX SETTINGS - ANIMATION =====
rightBox:AddLabel("━━ ANIMATION ━━", true)

rightBox:AddSlider("math_vfx_lifetime", {
    Text = "Symbol Lifetime",
    Default = 3,
    Min = 0.5,
    Max = 10,
    Rounding = 0.5,
    Callback = function(val)
        Config.SymbolLifetime = val
    end
})

rightBox:AddSlider("math_vfx_speed", {
    Text = "Color Speed",
    Default = 2,
    Min = 0.5,
    Max = 5,
    Rounding = 0.5,
    Callback = function(val)
        Config.AnimationSpeed = val
    end
})

rightBox:AddSlider("math_vfx_movement", {
    Text = "Movement Scale",
    Default = 1,
    Min = 0.1,
    Max = 3,
    Rounding = 0.1,
    Callback = function(val)
        Config.MovementScale = val
    end
})

rightBox:AddSlider("math_vfx_rotation", {
    Text = "Rotation Speed",
    Default = 1,
    Min = 0.1,
    Max = 3,
    Rounding = 0.1,
    Callback = function(val)
        Config.RotationSpeed = val
    end
})

rightBox:AddSlider("math_vfx_upward", {
    Text = "Upward Bias",
    Default = 0,
    Min = -50,
    Max = 50,
    Rounding = 1,
    Callback = function(val)
        Config.ParticleUpwardBias = val
    end
})

rightBox:AddDropdown("math_vfx_mode", {
    Text = "Symbol Mode",
    Values = {"Math", "Random"},
    Default = "Math",
    Callback = function(val)
        Config.MathMode = (val == "Math")
        api:notify("Mode: " .. val, 1)
    end
})

-- ===== HIT EVENT LISTENER =====
api:on_event("localplayer_hit_player", function(targetPlayer, partHit, damageDealt, weaponUsed, bulletOrigin, bulletPosition)
    if Config.Enabled then
        task.spawn(function()
            SpawnMathVFX()
        end)
    end
end)

-- ===== MAIN LOOPS =====

-- Update camera facing every frame
local heartbeatConn = RunService.Heartbeat:Connect(function()
    pcall(function()
        UpdateCameraFacing()
    end)
end)

api:add_connection(heartbeatConn)

-- ===== COMMAND SYSTEM =====
api:on_command("!mathvfx", function(player, cmd)
    if cmd == "on" then
        Config.Enabled = true
        api:notify("Math VFX ON", 2)
    elseif cmd == "off" then
        Config.Enabled = false
        api:notify("Math VFX OFF", 2)
    elseif cmd == "spawn" then
        SpawnMathVFX()
    elseif cmd == "clear" then
        if VFXFolder then
            VFXFolder:Destroy()
            VFXFolder = nil
            activeEffects = {}
            api:notify("VFX cleared", 1)
        end
    else
        api:chat("!mathvfx [on|off|spawn|clear]")
    end
end)

-- ===== CLEANUP =====
api:on_event("unload", function()
    if VFXFolder and VFXFolder.Parent then
        VFXFolder:Destroy()
    end
    VFXFolder = nil
    activeEffects = {}
    api:notify("Math VFX addon unloaded", 2)
end)

-- ===== STARTUP =====
api:notify("Math VFX Addon Loaded! Hit enemies to spawn effects.", 3)
print("Math VFX Hit Effects addon loaded successfully!")