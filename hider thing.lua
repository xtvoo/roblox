local RunService = game:GetService("RunService")

if not api then return end
api:set_lua_name("Ragebot Hider")

local function getOptions()
    local ok, opts = pcall(function()
        return (getgenv and getgenv().Options) or _G.Options
    end)
    return ok and opts or nil
end

local Options = getOptions()
if not Options then
    warn("Ragebot Hider: Options not found")
    return
end

local tab = api:AddTab("Ragebot Hider")
local gb  = tab:AddLeftGroupbox("Hide Ragebot Tab")

local hideOn = false

gb:AddToggle("rb_hide_all", {
    Text    = "Hide ALL ragebot flags",
    Default = false,
    Callback = function(v) hideOn = v end,
})

local fake_input = gb:AddInput("rb_fake_number", {
    Text       = "Fake Number",
    Default    = "999.999",
    Numeric    = false,
    Finished   = true,
    Placeholder = "what every value shows",
})

-- keep original Display per‑option
local wrapped = {}  -- [opt] = OldDisplay

local function isRagebotFlag(flagName)
    -- everything starting with "ragebot_" (Ragebot Tab, Resolver, Bait, Spiral, Void spam, Prediction, etc.) [file:1][file:6]
    return type(flagName) == "string" and flagName:sub(1, 8) == "ragebot_"
end

local function wrapOption(flagName, opt)
    if wrapped[opt] then return end
    if type(opt) ~= "table" or type(opt.Display) ~= "function" then return end

    local OldDisplay = opt.Display

    opt.Display = function(self)
        if not hideOn then
            return OldDisplay(self)
        end

        -- parse fake number safely; if not numeric, just show it as text
        local fakeStr = (fake_input and fake_input.Value) or "999.999"
        local realVal = rawget(self, "Value")

        -- temporarily spoof only for text
        local oldVal = realVal
        local parsed = tonumber(fakeStr)

        if parsed and type(realVal) == "number" then
            self.Value = parsed
            OldDisplay(self)
            self.Value = oldVal
        else
            -- fallback for non‑numeric options: call Display then overwrite its label text if possible
            OldDisplay(self)
            local lbl = rawget(self, "TextLabel") or rawget(self, "Label")
            if typeof(lbl) == "Instance" and lbl:IsA("TextLabel") then
                lbl.Text = fakeStr
            end
        end
    end

    wrapped[opt] = OldDisplay
end

-- one‑time wrap for all ragebot_* flags
for flag, opt in pairs(Options) do
    if isRagebotFlag(flag) then
        wrapOption(flag, opt)
    end
end

-- keep re‑calling Display while hidden so the fake text sticks
RunService.RenderStepped:Connect(function()
    if not hideOn then return end

    for flag, opt in pairs(Options) do
        if isRagebotFlag(flag) and wrapped[opt] then
            pcall(function()
                opt:Display()
            end)
        end
    end
end)
