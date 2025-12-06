-- unnamed enchancements addon
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local api = getfenv().api or {}

local MainEvent = ReplicatedStorage:WaitForChild("MainEvent")

-- Addon UI (use pre-defined 'api' from UE)
local tab = api:GetTab("ragebot")
local groupbox = tab:AddRightGroupbox("Anti-FakePos")

local resolverEnabled = false
local debugEnabled = false
local viewRealEnabled = false

-- Config (defaults)
local FAKEPOS_STUD_THRESHOLD = 25
local FAKEPOS_CLEAR_TIMEOUT = 5 -- seconds
local forgiveness = 10 -- studs of extra leeway
local refreshTime = 1 -- seconds used for prediction lead
local PING_STUDS_PER_MS = 0.08 -- how many studs added per ms of ping
local predictionMode = "averaged" -- "none", "last-2", "averaged", "extrapolated-spline"

-- UI Controls
groupbox:AddToggle("fakepos_resolver_tog", {
    Text = "Enable Fakepos Resolver", Default = false,
    Callback = function(val) resolverEnabled = val end
})

groupbox:AddToggle("fakepos_debug_tog", {
    Text = "Draw Resolved Positions", Default = false,
    Callback = function(val) debugEnabled = val end
})

groupbox:AddSlider("fakepos_threshold", {
    Text = 'Threshold',
    Min = 20,
    Max = 1000,
    Rounding = 1,
    Default = 25,
    Callback = function(val) FAKEPOS_STUD_THRESHOLD = val end
})

groupbox:AddSlider("fakepos_refresh_slider", {
    Text = "refresh time (s)",
    Default = refreshTime, Min = 1, Max = 10, Rounding = 2,
    Callback = function(val) refreshTime = val end
})

groupbox:AddSlider("fakepos_forgiveness_slider", {
    Text = "forgiveness (studs)",
    Default = forgiveness, Min = 0, Max = 50, Rounding = 0,
    Tooltip = "Lower = more precise, but harder to find position",
    Callback = function(val) forgiveness = val end
})

groupbox:AddDropdown("fakepos_prediction_mode", {
    Values = {"none", "last-2", "averaged", "extrapolated-spline"},
    Default = 3, -- "averaged"
    Text = "Prediction Mode",
    Tooltip = "none = raw origin, last-2 = simple velocity, averaged = smoothed velocity, extrapolated-spline = advanced prediction",
    Callback = function(val)
        predictionMode = val
    end
})

groupbox:AddToggle("fakepos_viewreal_tog", {
    Text = "View real Position", Default = false,
    Tooltip = "Bind camera Subject to resolved position when detected",
    Callback = function(val) viewRealEnabled = val end
})

-- Cache structures
local FakeposResolvedByModel = {}
local FakeposResolvedByPlayer = {}

-- Track forced overrides to guarantee reliable restoration
local ForcedRestores = {} -- [Model] = { hrp = Part, original = CFrame, expireAt = t }
local FORCE_TIMEOUT = 0.08 -- seconds allowed before we restore (auto-extends while forcing)

local function scheduleRestore(model, hrp)
    local now = tick()
    local rec = ForcedRestores[model]
    if not rec then
        rec = { hrp = hrp, original = hrp.CFrame, expireAt = now + FORCE_TIMEOUT }
        ForcedRestores[model] = rec
    else
        rec.hrp = hrp
        rec.expireAt = now + FORCE_TIMEOUT
    end
end

local function restoreNow(model)
    local rec = ForcedRestores[model]
    if rec and rec.hrp then
        pcall(function()
            rec.hrp.CFrame = rec.original
        end)
    end
    ForcedRestores[model] = nil
end

local function restoreAll()
    for model, _ in pairs(ForcedRestores) do
        restoreNow(model)
    end
end

-- Utility: Get HumanoidRootPart, safely
local function getRoot(model)
    return (model and model:FindFirstChild("HumanoidRootPart")) or nil
end

local function getPingMs()
    local item = Stats and Stats.Network and Stats.Network.ServerStatsItem and Stats.Network.ServerStatsItem["Data Ping"]
    if not item then return 0 end
    local ok, value = pcall(function()
        return item:GetValue()
    end)
    if ok and typeof(value) == "number" then return value end
    local ok2, v2 = pcall(function()
        return item.Value
    end)
    if ok2 and typeof(v2) == "number" then return v2 end
    return 0
end

local function getEffectiveThreshold()
    return FAKEPOS_STUD_THRESHOLD + forgiveness + (getPingMs() * PING_STUDS_PER_MS)
end

-- Create or update cache entry for a shooter model
local function upsertEntryForModel(model, forcedorigin)
    local player = Players:GetPlayerFromCharacter(model)
    local keyModel = model
    local entry = FakeposResolvedByModel[keyModel]
    if not entry then
        entry = { history = {}, player = player, model = model }
        FakeposResolvedByModel[keyModel] = entry
        if player then FakeposResolvedByPlayer[player] = entry end
    end
    entry.pos = forcedorigin
    entry.lastUpdate = tick()
    entry.userId = (player and player.UserId) or model:GetAttribute("UserId") or model.Name
    table.insert(entry.history, { t = entry.lastUpdate, p = forcedorigin })
    if #entry.history > 20 then
        table.remove(entry.history, 1)
    end
    if player and player.Character and player.Character ~= entry.model then
        FakeposResolvedByModel[entry.model] = nil
        entry.model = player.Character
        FakeposResolvedByModel[entry.model] = entry
    end
    return entry
end

-- Normalize ragebot target into a Character Model if possible
local function resolveTargetModel(tgt)
    if typeof(tgt) == "Instance" then
        if tgt:IsA("Player") then return tgt.Character end
        if tgt:IsA("Model") then return tgt end
        local p = tgt
        while p and not p:IsA("Model") do p = p.Parent end
        return p
    elseif type(tgt) == "table" then
        local char = rawget(tgt, "character") or rawget(tgt, "Character") or rawget(tgt, "model") or rawget(tgt, "Model")
        if typeof(char) == "Instance" then
            if char:IsA("Player") then return char.Character end
            if char:IsA("Model") then return char end
        end
        local plr = rawget(tgt, "player") or rawget(tgt, "Player")
        if typeof(plr) == "Instance" and plr:IsA("Player") then
            return plr.Character
        end
    end
    return nil
end

-- Retrieve entry by model or its owning player
local function getEntryForModel(model)
    local entry = FakeposResolvedByModel[model]
    if entry then return entry end
    local player = Players:GetPlayerFromCharacter(model)
    if player then return FakeposResolvedByPlayer[player] end
    return nil
end

-- Listen for bullet traces to detect fakepos and cache real positions
local bulletConn = api:add_connection(MainEvent.OnClientEvent:Connect(function(mode, ...)
    if mode == "ClientBullet" then
        local shooter, _, forcedorigin = ...
        if not shooter or not shooter:IsA("Model") then return end
        local hrp = getRoot(shooter)
        if hrp then
            local distance = (hrp.Position - forcedorigin).Magnitude
            if distance > getEffectiveThreshold() then
                api:Notify(`omg this nga ({shooter.Name}) is in fakepos (may be false positive)`)
                upsertEntryForModel(shooter, forcedorigin)
            end
        end
    end
end))

-- Compute averaged velocity from last N samples to handle rapid multi-gun shots
local function getAverageVelocity(entry, window)
    local h = entry.history
    local n = #h
    if n < 2 then return Vector3.zero end
    window = math.clamp(window or 5, 2, math.min(10, n))
    local sum = Vector3.zero
    local count = 0
    for i = n - window + 1, n - 1 do
        local a = h[i]
        local b = h[i + 1]
        local dt = math.max(1e-3, b.t - a.t)
        sum += (b.p - a.p) / dt
        count += 1
    end
    return count > 0 and (sum / count) or Vector3.zero
end

-- Get velocity from last 2 samples (simple velocity)
local function getLast2Velocity(entry)
    local h = entry.history
    local n = #h
    if n < 2 then return Vector3.zero end
    local a = h[n - 1]
    local b = h[n]
    local dt = math.max(1e-3, b.t - a.t)
    return (b.p - a.p) / dt
end

-- Extrapolated spline prediction (catmull-rom like interpolation)
local function getSplinePrediction(entry)
    local h = entry.history
    local n = #h
    if n < 2 then return nil end
    if n == 2 then
        local v = getLast2Velocity(entry)
        return entry.pos + v * refreshTime
    end
    -- Use last 3-4 points for spline-like extrapolation
    local p0 = n >= 4 and h[n - 3].p or h[math.max(1, n - 2)].p
    local p1 = h[n - 1].p
    local p2 = h[n].p
    -- Catmull-Rom extrapolation: extend the curve
    local t = refreshTime / math.max(0.1, h[n].t - h[n - 1].t)
    local v1 = (p2 - p0) * 0.5
    local v2 = (p2 - p1)
    -- Extrapolate forward
    return p2 + (v2 + (v2 - v1) * 0.5) * t
end

-- Predict future position based on selected prediction mode
local function getPredictedPosition(entry)
    if not entry or not entry.pos then return nil end
    
    -- "none" mode: just use raw origin (no prediction)
    if predictionMode == "none" then
        return entry.pos
    end
    
    local lead = refreshTime + (forgiveness * 0.01)
    
    if predictionMode == "last-2" then
        local v = getLast2Velocity(entry)
        return entry.pos + v * lead
    elseif predictionMode == "averaged" then
        local v = getAverageVelocity(entry, 6)
        return entry.pos + v * lead
    elseif predictionMode == "extrapolated-spline" then
        local splinePos = getSplinePrediction(entry)
        return splinePos or (entry.pos + getAverageVelocity(entry, 6) * lead)
    end
    
    -- Fallback to averaged if mode not recognized
    local v = getAverageVelocity(entry, 6)
    return entry.pos + v * lead
end

-- Core function: move suspected fakepos user to resolved/predicted pos for a brief window
local function forceFakeposToResolved(target)
    local entry = getEntryForModel(target)
    if not entry or not resolverEnabled then return end
    local hrp = getRoot(target)
    if not hrp then return end
    local predicted = getPredictedPosition(entry) or entry.pos
    scheduleRestore(target, hrp)
    hrp.CFrame = CFrame.new(predicted)
end

-- Debug: draw a marker at the resolved position for each detected fakepos user
local adornments = {}
local function clearAdorns()
    for _, adorn in ipairs(adornments) do
        if adorn and adorn.Parent then pcall(function() adorn:Destroy() end) end
    end
    table.clear(adornments)
end

-- Heartbeat restore manager ensures any forced targets are reset reliably
local restoreConnection = api:add_connection(RunService.Heartbeat:Connect(function()
    local now = tick()
    for model, rec in pairs(ForcedRestores) do
        if now >= rec.expireAt then
            restoreNow(model)
        end
    end
end))

-- Ragebot auto-resolver + debug drawing (shared step)
local renderConnection = api:add_connection(RunService.PostSimulation:Connect(function()
    -- Auto-resolve for ragebot via UE API
    local status, data  = api:get_ragebot_status()
    if resolverEnabled and status == "killing"  then
        local targets = {}
        if type(api.get_target_cache) == "function" then
            targets = api:get_target_cache("ragebot") or {}
        end
        for _, tgt in pairs(targets) do
            local model = resolveTargetModel(tgt)
            if model then
                -- Refresh entry mapping if character swapped
                local entry = getEntryForModel(model)
                if entry and entry.model ~= model then
                    FakeposResolvedByModel[entry.model] = nil
                    entry.model = model
                    FakeposResolvedByModel[model] = entry
                end
                if entry then forceFakeposToResolved(model) end
            end
        end
    end
    -- Debug drawing
    clearAdorns()
    if not debugEnabled then return end
    local now = tick()
    for _, entry in pairs(FakeposResolvedByModel) do
        local char = entry.model
        if char and typeof(entry.pos) == "Vector3" and (now - entry.lastUpdate) < FAKEPOS_CLEAR_TIMEOUT and getRoot(char) then
            local drawPos = getPredictedPosition(entry) or entry.pos
            local part = Instance.new("Part")
            part.Size = Vector3.new(2,2,2)
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0.5
            part.BrickColor = BrickColor.new("Bright red")
            part.Position = drawPos
            part.Parent = workspace
            table.insert(adornments, part)
        end
    end
    -- Auto-clear expired cache
    for key, entry in pairs(FakeposResolvedByModel) do
        if (now - entry.lastUpdate) > FAKEPOS_CLEAR_TIMEOUT then
            if entry.player then FakeposResolvedByPlayer[entry.player] = nil end
            FakeposResolvedByModel[key] = nil
        end
    end
end))

-- View Real Position: use CameraSubject bound to an invisible part
local CAMERA_BIND_NAME = "AFakepos_View"
local camSubjectPart
local previousSubject
local function ensureCamSubjectPart()
    if camSubjectPart and camSubjectPart.Parent then return camSubjectPart end
    camSubjectPart = Instance.new("Part")
    camSubjectPart.Name = "AFakepos_CameraSubject"
    camSubjectPart.Size = Vector3.new(1,1,1)
    camSubjectPart.Anchored = true
    camSubjectPart.CanCollide = false
    camSubjectPart.CanQuery = false
    camSubjectPart.Transparency = 1
    camSubjectPart.Parent = workspace
    return camSubjectPart
end

local function bindView()
    RunService:UnbindFromRenderStep(CAMERA_BIND_NAME)
    if not viewRealEnabled then
        local cam = workspace.CurrentCamera
        if cam and previousSubject then
            cam.CameraSubject = previousSubject
            previousSubject = nil
        end
        if camSubjectPart then camSubjectPart:Destroy() camSubjectPart = nil end
        return
    end
    RunService:BindToRenderStep(CAMERA_BIND_NAME, 100, function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local targets = type(api.get_target_cache) == "function" and api:get_target_cache("ragebot") or {}
        local bestModel
        for _, tgt in pairs(targets) do
            local m = resolveTargetModel(tgt)
            if m then bestModel = m break end
        end
        if bestModel then
            local entry = getEntryForModel(bestModel)
            if entry and entry.pos then
                local lookPos = getPredictedPosition(entry) or entry.pos
                local part = ensureCamSubjectPart()
                part.CFrame = CFrame.new(lookPos)
                if cam.CameraSubject ~= part then
                    previousSubject = previousSubject or cam.CameraSubject
                    cam.CameraSubject = part
                end
            end
        else
            if previousSubject and cam.CameraSubject ~= previousSubject then
                cam.CameraSubject = previousSubject
            end
        end
    end)
end

-- Re-bind when toggle changes
Toggles.fakepos_viewreal_tog:OnChanged(function()
    bindView()
end)

-- Initial bind (in case default is true)
bindView()

-- Clean up connections on unload!
api:on_event("unload", function()
    if renderConnection and renderConnection.Disconnect then
        renderConnection:Disconnect()
    end
    if restoreConnection and restoreConnection.Disconnect then
        restoreConnection:Disconnect()
    end
    if bulletConn and bulletConn.Disconnect then
        bulletConn:Disconnect()
    end
    restoreAll()
    RunService:UnbindFromRenderStep(CAMERA_BIND_NAME)
    local cam = workspace.CurrentCamera
    if cam and previousSubject then
        cam.CameraSubject = previousSubject
        previousSubject = nil
    end
    if camSubjectPart then camSubjectPart:Destroy() camSubjectPart = nil end
    clearAdorns()
end)

_G.FakeposResolverEnabled = function(val)
    resolverEnabled = val ~= false
end