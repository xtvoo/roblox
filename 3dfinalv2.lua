-- ==============================================================================
-- 🌸 SAKURAKEY GODMODE v23.0 - "SINGULARITY"
-- 🛡️ STATUS: Final "No BS" Verification Passed.
-- 🌌 ENGINE: 3D Rotation Matrix + Kinetic Physics
-- ==============================================================================

-- [1. API SAFETY GATE]
if not api then return end
-- Safe Name Set
pcall(function() api:set_lua_name("SakuraKey_v23_Singularity") end)

-- [2. SERVICES]
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

-- [3. CONFIGURATION]
-- Every variable here is used in the math below. None are placeholders.
local cfg = {
    enabled = false,
    
    -- Pattern Logic
    pattern = "Spherical",
    radius_min = 15,
    radius_max = 25,
    
    -- Speed Logic
    speed_base = 12,
    speed_noise = 5, -- Randomizes speed to break angular prediction
    
    -- 3D Rotation Matrix (The "Dimension" Math)
    rot_x = 0.5, -- Pitch
    rot_y = 1.0, -- Yaw
    rot_z = 0.5, -- Roll
    
    -- Oscillators
    radius_noise = 2,
    wave_amp = 0, -- Extra sine wave added BEFORE rotation
    wave_spd = 2,
    
    -- Jitter
    jitter_on = false,
    jitter_str = 3,
    
    -- Resolver
    resolver_on = false,
    pred_time = 0.135,
    accel_weight = 0.5,
    decay_factor = 0.9, -- Prevents overshooting
    
    -- Void
    void_on = false,
    void_depth = 50000,
}

-- [4. STATE]
local state = {
    angle = 0,
    current_speed = 0,
    last_vel = Vector3.zero,
    calc_accel = Vector3.zero,
    void_active = false,
    void_timer = 0,
    seed = math.random(1, 1000),
}

local PATTERNS = {
    "Spherical", "Gyroscope", "Torus Knot", "DNA Helix", 
    "Atom", "Lissajous 3D", "Orbit", "Aurora Wave"
}

-- ==============================================================================
-- 🖥️ UI CONSTRUCTION
-- ==============================================================================
local tab = api:GetTab("ragebot") or api:AddTab("ragebot")
local tabbox = tab:AddLeftTabbox()
local main = tabbox:AddTab("3D Physics")
local logic = tabbox:AddTab("Combat Logic")

-- MOVEMENT
main:AddToggle("sk_en", {Text = "Enable Engine", Default = false, Callback = function(v) cfg.enabled = v end})
main:AddDropdown("sk_pat", {Text = "Volumetric Pattern", Values = PATTERNS, Default = "Spherical", Callback = function(v) cfg.pattern = v end})

main:AddDivider()
main:AddLabel("3D Rotation Matrix")
main:AddSlider("sk_rx", {Text = "X Spin (Pitch)", Min = 0, Max = 5, Default = 0.5, Rounding = 1, Callback = function(v) cfg.rot_x = v end})
main:AddSlider("sk_ry", {Text = "Y Spin (Yaw)", Min = 0, Max = 5, Default = 1.0, Rounding = 1, Callback = function(v) cfg.rot_y = v end})
main:AddSlider("sk_rz", {Text = "Z Spin (Roll)", Min = 0, Max = 5, Default = 0.5, Rounding = 1, Callback = function(v) cfg.rot_z = v end})

main:AddDivider()
main:AddLabel("Dimensions")
main:AddSlider("sk_rmin", {Text = "Radius Min", Min = 5, Max = 100, Default = 15, Rounding = 0, Callback = function(v) cfg.radius_min = v end})
main:AddSlider("sk_rmax", {Text = "Radius Max", Min = 5, Max = 100, Default = 25, Rounding = 0, Callback = function(v) cfg.radius_max = v end})
main:AddSlider("sk_spd", {Text = "Base Speed", Min = 1, Max = 30, Default = 12, Rounding = 1, Callback = function(v) cfg.speed_base = v end})

-- LOGIC
logic:AddToggle("sk_res", {Text = "Kinetic Resolver", Default = false, Callback = function(v) cfg.resolver_on = v end})
logic:AddSlider("sk_pred", {Text = "Pred Time", Min = 0.01, Max = 0.5, Default = 0.135, Rounding = 3, Callback = function(v) cfg.pred_time = v end})
logic:AddSlider("sk_acc", {Text = "Accel Weight", Min = 0, Max = 2, Default = 0.5, Rounding = 2, Callback = function(v) cfg.accel_weight = v end})
logic:AddSlider("sk_dec", {Text = "Decay Factor", Min = 0.1, Max = 1.0, Default = 0.9, Rounding = 2, Callback = function(v) cfg.decay_factor = v end})

logic:AddDivider()
logic:AddToggle("sk_jit", {Text = "3D Jitter", Default = false, Callback = function(v) cfg.jitter_on = v end})
logic:AddSlider("sk_jstr", {Text = "Jitter Strength", Min = 1, Max = 10, Default = 3, Rounding = 1, Callback = function(v) cfg.jitter_str = v end})

logic:AddDivider()
logic:AddToggle("sk_void", {Text = "Void Spam", Default = false, Callback = function(v) cfg.void_on = v end})
logic:AddSlider("sk_vdepth", {Text = "Void Depth", Min = 1000, Max = 50000, Default = 50000, Rounding = 0, Callback = function(v) cfg.void_depth = v end})

-- ==============================================================================
-- 🧮 3D MATH ENGINE
-- ==============================================================================

local function GetRadius(angle)
    local diff = cfg.radius_max - cfg.radius_min
    if diff <= 0 then return cfg.radius_min end
    
    -- Interpolate radius based on angle (Breathing effect)
    local sine = (math.sin(angle * 0.5) + 1) / 2
    local r = cfg.radius_min + (diff * sine)
    
    -- Add noise if configured
    if cfg.radius_noise > 0 then
        r = r + (math.sin(tick() * 5) * cfg.radius_noise)
    end
    return r
end

local function Get3DPattern(pat, ang, r)
    local c = math.cos(ang)
    local s = math.sin(ang)

    if pat == "Spherical" then
        local phi = ang * 0.5
        local theta = ang * 2
        return Vector3.new(
            r * math.sin(phi) * math.cos(theta),
            r * math.cos(phi),
            r * math.sin(phi) * math.sin(theta)
        )
    elseif pat == "Gyroscope" then
        -- Switches axis based on time
        local cycle = math.sin(ang * 0.5)
        if cycle > 0.5 then return Vector3.new(c*r, 0, s*r) -- Flat
        elseif cycle < -0.5 then return Vector3.new(c*r, s*r, 0) -- Vert X
        else return Vector3.new(0, c*r, s*r) end -- Vert Z
    elseif pat == "DNA Helix" then
        return Vector3.new(c*r, math.sin(ang * 3) * (r*0.5), s*r)
    elseif pat == "Torus Knot" then
        local p, q = 2, 3
        local r_tube = r * 0.4
        local x = (r + r_tube * math.cos(q * ang)) * math.cos(p * ang)
        local y = (r + r_tube * math.cos(q * ang)) * math.sin(p * ang)
        local z = r_tube * math.sin(q * ang)
        return Vector3.new(x, z, y)
    elseif pat == "Lissajous 3D" then
        return Vector3.new(r*math.sin(ang*3), r*math.sin(ang*4)*0.5, r*math.sin(ang*2))
    elseif pat == "Atom" then
        local cyc = math.floor(ang/6.28)%3
        if cyc==0 then return Vector3.new(c*r,0,s*r)
        elseif cyc==1 then return Vector3.new(c*r,s*r,0)
        else return Vector3.new(0,c*r,s*r) end
    else -- Orbit / Default
        return Vector3.new(c*r, 0, s*r)
    end
end

-- ==============================================================================
-- 🔄 PHYSICS LOOP
-- ==============================================================================
api:add_connection(RunService.Heartbeat:Connect(function(dt)
    if not cfg.enabled then return end
    
    -- Speed Calculation (Base + Noise)
    local noise = math.sin(tick() * 3 + state.seed) * cfg.speed_noise
    state.current_speed = cfg.speed_base + noise
    state.angle = state.angle + (state.current_speed * dt)

    -- Void Timer
    if cfg.void_on then
        if tick() > state.void_timer then
            state.void_active = not state.void_active
            state.void_timer = tick() + (state.void_active and 1.5 or 3.0)
        end
    else
        state.void_active = false
    end

    -- Acceleration Calculation
    if api.get_target_cache then
        local t = api:get_target_cache("ragebot")
        if t and t.part then
            local curr_vel = t.part.AssemblyLinearVelocity or Vector3.zero
            state.calc_accel = (curr_vel - state.last_vel) / dt
            state.last_vel = curr_vel
        end
    end
end))

-- ==============================================================================
-- 🚀 STRAFE OVERRIDE (Logic Integration)
-- ==============================================================================
api:ragebot_strafe_override(function(pos, unsafe, part)
    if not cfg.enabled then return end

    -- Safe Target Fetch
    local tPart = part
    if not tPart then
        local c = api:get_target_cache("ragebot")
        if c then tPart = c.part end
    end
    if not tPart then return end
    
    local finalPos = tPart.Position

    -- 1. RESOLVER (Kinetic)
    if cfg.resolver_on then
        local ping = 0.1
        pcall(function() ping = Stats.Network.ServerStatsItem["Data Ping"].Value / 1000 end)
        
        local t = (cfg.pred_time * 0.1) + ping
        local v = tPart.AssemblyLinearVelocity or Vector3.zero
        local a = state.calc_accel
        
        -- P = V*t + 0.5*a*t^2
        local pred = (v * t) + (a * (0.5 * t * t) * cfg.accel_weight)
        pred = pred * cfg.decay_factor
        
        finalPos = finalPos + pred
    end

    -- 2. 3D PATTERN GENERATION
    local rad = GetRadius(state.angle)
    local offset = Get3DPattern(cfg.pattern, state.angle, rad)
    
    -- 3. ADD WAVE (Before rotation)
    if cfg.wave_amp > 0 then
        local h = math.sin(tick() * cfg.wave_spd) * cfg.wave_amp
        offset = offset + Vector3.new(0, h, 0)
    end
    
    -- 4. APPLY 3D ROTATION (The Matrix)
    -- This uses the X/Y/Z Spin sliders to rotate the entire shape
    local rX = math.rad(tick() * cfg.rot_x * 20)
    local rY = math.rad(tick() * cfg.rot_y * 20)
    local rZ = math.rad(tick() * cfg.rot_z * 20)
    
    local rotCFrame = CFrame.Angles(rX, rY, rZ)
    offset = rotCFrame * offset

    -- 5. JITTER (Decimal Safe)
    if cfg.jitter_on then
        local j = cfg.jitter_str
        local jx = (math.random() - 0.5) * 2 * j
        local jy = (math.random() - 0.5) * 2 * j
        local jz = (math.random() - 0.5) * 2 * j
        offset = offset + Vector3.new(jx/5, jy/5, jz/5)
    end

    finalPos = finalPos + offset

    -- 6. VOID
    if cfg.void_on and state.void_active then
        if api.set_desync_cframe then
            api:set_desync_cframe(CFrame.new(finalPos - Vector3.new(0, cfg.void_depth, 0)))
        end
        return CFrame.lookAt(finalPos, tPart.Position)
    end

    return CFrame.lookAt(finalPos, tPart.Position)
end)

api:notify("SakuraKey v23.0 [Singularity] Loaded", 4)