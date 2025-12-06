-- >> variables
local players_service = game:GetService("Players")
local local_player = players_service.LocalPlayer
local character = local_player.Character or local_player.CharacterAdded:Wait()

-- >> full animation sets
local AnimationSets = {
    ["Haydens"] = {
        idle1 = "http://www.roblox.com/asset/?id=133806214992291",
        idle2 = "http://www.roblox.com/asset/?id=94970088341563",
        walk = "http://www.roblox.com/asset/?id=2510202577",
        run = "http://www.roblox.com/asset/?id=616163682",
        jump = "http://www.roblox.com/asset/?id=656117878",
        climb = "http://www.roblox.com/asset/?id=1213044953",
        fall = "http://www.roblox.com/asset/?id=707829716"
    },
    ["Default"] = {
        idle1 = "http://www.roblox.com/asset/?id=180435571",
        idle2 = "http://www.roblox.com/asset/?id=180435792",
        walk = "http://www.roblox.com/asset/?id=180426354",
        run = "http://www.roblox.com/asset/?id=180426354",
        jump = "http://www.roblox.com/asset/?id=125750702",
        climb = "http://www.roblox.com/asset/?id=180436334",
        fall = "http://www.roblox.com/asset/?id=180436148"
    },
    ["Ninja"] = {
        idle1 = "http://www.roblox.com/asset/?id=656117400",
        idle2 = "http://www.roblox.com/asset/?id=656118341",
        walk = "http://www.roblox.com/asset/?id=656121766",
        run = "http://www.roblox.com/asset/?id=656118852",
        jump = "http://www.roblox.com/asset/?id=656117878",
        climb = "http://www.roblox.com/asset/?id=656114359",
        fall = "http://www.roblox.com/asset/?id=656115606"
    },
    ["Superhero"] = {
        idle1 = "http://www.roblox.com/asset/?id=616111295",
        idle2 = "http://www.roblox.com/asset/?id=616113536",
        walk = "http://www.roblox.com/asset/?id=616122287",
        run = "http://www.roblox.com/asset/?id=616117076",
        jump = "http://www.roblox.com/asset/?id=616115533",
        climb = "http://www.roblox.com/asset/?id=616104706",
        fall = "http://www.roblox.com/asset/?id=616108001"
    },
    ["Robot"] = {
        idle1 = "http://www.roblox.com/asset/?id=616088211",
        idle2 = "http://www.roblox.com/asset/?id=616089559",
        walk = "http://www.roblox.com/asset/?id=616095330",
        run = "http://www.roblox.com/asset/?id=616091570",
        jump = "http://www.roblox.com/asset/?id=616090535",
        climb = "http://www.roblox.com/asset/?id=616086039",
        fall = "http://www.roblox.com/asset/?id=616087089"
    },
    ["Cartoon"] = {
        idle1 = "http://www.roblox.com/asset/?id=742637544",
        idle2 = "http://www.roblox.com/asset/?id=742638445",
        walk = "http://www.roblox.com/asset/?id=742640026",
        run = "http://www.roblox.com/asset/?id=742638842",
        jump = "http://www.roblox.com/asset/?id=742637942",
        climb = "http://www.roblox.com/asset/?id=742636889",
        fall = "http://www.roblox.com/asset/?id=742637151"
    },
    ["Catwalk"] = {
        idle1 = "http://www.roblox.com/asset/?id=133806214992291",
        idle2 = "http://www.roblox.com/asset/?id=94970088341563",
        walk = "http://www.roblox.com/asset/?id=109168724482748",
        run = "http://www.roblox.com/asset/?id=81024476153754",
        jump = "http://www.roblox.com/asset/?id=116936326516985",
        climb = "http://www.roblox.com/asset/?id=119377220967554",
        fall = "http://www.roblox.com/asset/?id=92294537340807"
    },
    ["Zombie"] = {
        idle1 = "http://www.roblox.com/asset/?id=616158929",
        idle2 = "http://www.roblox.com/asset/?id=616160636",
        walk = "http://www.roblox.com/asset/?id=616168032",
        run = "http://www.roblox.com/asset/?id=616163682",
        jump = "http://www.roblox.com/asset/?id=616161997",
        climb = "http://www.roblox.com/asset/?id=616156119",
        fall = "http://www.roblox.com/asset/?id=616157476"
    },
    ["Mage"] = {
        idle1 = "http://www.roblox.com/asset/?id=707742142",
        idle2 = "http://www.roblox.com/asset/?id=707855907",
        walk = "http://www.roblox.com/asset/?id=707897309",
        run = "http://www.roblox.com/asset/?id=707861613",
        jump = "http://www.roblox.com/asset/?id=707853694",
        climb = "http://www.roblox.com/asset/?id=707826056",
        fall = "http://www.roblox.com/asset/?id=707829716"
    },
    ["Pirate"] = {
        idle1 = "http://www.roblox.com/asset/?id=750782770",
        idle2 = "http://www.roblox.com/asset/?id=750782770",
        walk = "http://www.roblox.com/asset/?id=750785693",
        run = "http://www.roblox.com/asset/?id=750782770",
        jump = "http://www.roblox.com/asset/?id=750782770",
        climb = "http://www.roblox.com/asset/?id=750782770",
        fall = "http://www.roblox.com/asset/?id=750782770"
    },
    ["Knight"] = {
        idle1 = "http://www.roblox.com/asset/?id=657595757",
        idle2 = "http://www.roblox.com/asset/?id=657568135",
        walk = "http://www.roblox.com/asset/?id=657552124",
        run = "http://www.roblox.com/asset/?id=657564596",
        jump = "http://www.roblox.com/asset/?id=657560148",
        climb = "http://www.roblox.com/asset/?id=657556206",
        fall = "http://www.roblox.com/asset/?id=657552124"
    },
    ["Vampire"] = {
        idle1 = "http://www.roblox.com/asset/?id=1083465857",
        idle2 = "http://www.roblox.com/asset/?id=1083465857",
        walk = "http://www.roblox.com/asset/?id=1083465857",
        run = "http://www.roblox.com/asset/?id=1083465857",
        jump = "http://www.roblox.com/asset/?id=1083465857",
        climb = "http://www.roblox.com/asset/?id=1083465857",
        fall = "http://www.roblox.com/asset/?id=1083465857"
    },
    ["Bubbly"] = {
        idle1 = "http://www.roblox.com/asset/?id=910004836",
        idle2 = "http://www.roblox.com/asset/?id=910009958",
        walk = "http://www.roblox.com/asset/?id=910034870",
        run = "http://www.roblox.com/asset/?id=910025107",
        jump = "http://www.roblox.com/asset/?id=910016857",
        climb = "http://www.roblox.com/asset/?id=910009958",
        fall = "http://www.roblox.com/asset/?id=910009958"
    },
    ["Elder"] = {
        idle1 = "http://www.roblox.com/asset/?id=845386501",
        idle2 = "http://www.roblox.com/asset/?id=845397899",
        walk = "http://www.roblox.com/asset/?id=845403856",
        run = "http://www.roblox.com/asset/?id=845386501",
        jump = "http://www.roblox.com/asset/?id=845386501",
        climb = "http://www.roblox.com/asset/?id=845386501",
        fall = "http://www.roblox.com/asset/?id=845386501"
    },
    ["Toy"] = {
        idle1 = "http://www.roblox.com/asset/?id=782841498",
        idle2 = "http://www.roblox.com/asset/?id=782841498",
        walk = "http://www.roblox.com/asset/?id=782841498",
        run = "http://www.roblox.com/asset/?id=782841498",
        jump = "http://www.roblox.com/asset/?id=782841498",
        climb = "http://www.roblox.com/asset/?id=782841498",
        fall = "http://www.roblox.com/asset/?id=782841498"
    },
    ["Astronaut"] = {
        idle1 = "http://www.roblox.com/asset/?id=10921034824",
        idle2 = "http://www.roblox.com/asset/?id=10921036806",
        walk = "http://www.roblox.com/asset/?id=10921046031",
        run = "http://www.roblox.com/asset/?id=10921039308",
        jump = "http://www.roblox.com/asset/?id=10921042494",
        climb = "http://www.roblox.com/asset/?id=10921032124",
        fall = "http://www.roblox.com/asset/?id=10921040576"
    },
    ["Popular"] = {
        idle1 = "http://www.roblox.com/asset/?id=118832222982049",
        idle2 = "http://www.roblox.com/asset/?id=76049494037641",
        walk = "http://www.roblox.com/asset/?id=92072849924640",
        run = "http://www.roblox.com/asset/?id=72301599441680",
        jump = "http://www.roblox.com/asset/?id=104325245285198",
        climb = "http://www.roblox.com/asset/?id=131326830509784",
        fall = "http://www.roblox.com/asset/?id=121152442762481"
    },
    ["NFL"] = {
        idle1 = "http://www.roblox.com/asset/?id=92080889861410",
        idle2 = "http://www.roblox.com/asset/?id=74451233229259",
        walk = "http://www.roblox.com/asset/?id=110358958299415",
        run = "http://www.roblox.com/asset/?id=117333533048078",
        jump = "http://www.roblox.com/asset/?id=119846112151352",
        climb = "http://www.roblox.com/asset/?id=134630013742019",
        fall = "http://www.roblox.com/asset/?id=129773241321032"
    },
    ["Bold"] = {
        idle1 = "http://www.roblox.com/asset/?id=16738333868",
        idle2 = "http://www.roblox.com/asset/?id=16738334710",
        walk = "http://www.roblox.com/asset/?id=16738340646",
        run = "http://www.roblox.com/asset/?id=16738337225",
        jump = "http://www.roblox.com/asset/?id=16738336650",
        climb = "http://www.roblox.com/asset/?id=16738332169",
        fall = "http://www.roblox.com/asset/?id=16738333171"
    },
    ["No Boundaries"] = {
        idle1 = "http://www.roblox.com/asset/?id=18747067405",
        idle2 = "http://www.roblox.com/asset/?id=18747063918",
        walk = "http://www.roblox.com/asset/?id=18747074203",
        run = "http://www.roblox.com/asset/?id=18747070484",
        jump = "http://www.roblox.com/asset/?id=18747069148",
        climb = "http://www.roblox.com/asset/?id=18747060903",
        fall = "http://www.roblox.com/asset/?id=18747062535"
    },
    ["Levitation"] = {
        idle1 = "http://www.roblox.com/asset/?id=10921132962",
        idle2 = "http://www.roblox.com/asset/?id=10921133721",
        walk = "http://www.roblox.com/asset/?id=10921140719",
        run = "http://www.roblox.com/asset/?id=10921135644",
        jump = "http://www.roblox.com/asset/?id=10921137402",
        climb = "http://www.roblox.com/asset/?id=10921132092",
        fall = "http://www.roblox.com/asset/?id=10921136539"
    },
    ["Werewolf"] = {
        idle1 = "http://www.roblox.com/asset/?id=10921330408",
        idle2 = "http://www.roblox.com/asset/?id=10921333667",
        walk = "http://www.roblox.com/asset/?id=10921342074",
        run = "http://www.roblox.com/asset/?id=10921336997",
        jump = "http://www.roblox.com/asset/?id=1083218792",
        climb = "http://www.roblox.com/asset/?id=10921329322",
        fall = "http://www.roblox.com/asset/?id=10921337907"
    },
    ["Stylish"] = {
        idle1 = "http://www.roblox.com/asset/?id=10921272275",
        idle2 = "http://www.roblox.com/asset/?id=10921273958",
        walk = "http://www.roblox.com/asset/?id=10921283326",
        run = "http://www.roblox.com/asset/?id=10921276116",
        jump = "http://www.roblox.com/asset/?id=10921279832",
        climb = "http://www.roblox.com/asset/?id=10921271391",
        fall = "http://www.roblox.com/asset/?id=10921278648"
    },
    ["OldSchool"] = {
        idle1 = "http://www.roblox.com/asset/?id=10921230744",
        idle2 = "http://www.roblox.com/asset/?id=10921232093",
        walk = "http://www.roblox.com/asset/?id=10921244891",
        run = "http://www.roblox.com/asset/?id=10921240218",
        jump = "http://www.roblox.com/asset/?id=10921242013",
        climb = "http://www.roblox.com/asset/?id=10921229866",
        fall = "http://www.roblox.com/asset/?id=10921241244"
    },
    ["Adidas"] = {
        idle1 = "http://www.roblox.com/asset/?id=18537376492",
        idle2 = "http://www.roblox.com/asset/?id=18537371272",
        walk = "http://www.roblox.com/asset/?id=18537392113",
        run = "http://www.roblox.com/asset/?id=18537384940",
        jump = "http://www.roblox.com/asset/?id=18537380791",
        climb = "http://www.roblox.com/asset/?id=18537363391",
        fall = "http://www.roblox.com/asset/?id=18537367238"
    }
}

-- >> helper
local function replace_animate_script(character, anims)
    local animate = character:FindFirstChild("Animate")
    if not animate then return end

    animate.Archivable = true
    local new_animate = animate:Clone()
    animate:Destroy()

    local function set_anim(path, id)
        local ok, target = pcall(function()
            return path and path:IsA("Animation") and path
        end)
        if ok and target then
            target.AnimationId = id
        end
    end

    set_anim(new_animate:FindFirstChild("idle") and new_animate.idle:FindFirstChild("Animation1"), anims.idle1)
    set_anim(new_animate:FindFirstChild("idle") and new_animate.idle:FindFirstChild("Animation2"), anims.idle2)
    set_anim(new_animate:FindFirstChild("walk") and new_animate.walk:FindFirstChild("WalkAnim"), anims.walk)
    set_anim(new_animate:FindFirstChild("run") and new_animate.run:FindFirstChild("RunAnim"), anims.run)
    set_anim(new_animate:FindFirstChild("jump") and new_animate.jump:FindFirstChild("JumpAnim"), anims.jump)
    set_anim(new_animate:FindFirstChild("climb") and new_animate.climb:FindFirstChild("ClimbAnim"), anims.climb)
    set_anim(new_animate:FindFirstChild("fall") and new_animate.fall:FindFirstChild("FallAnim"), anims.fall)

    new_animate.Parent = character
    new_animate.Disabled = true
    new_animate.Disabled = false
end

local function try_apply_anim_set(anim_name)
    local anims = AnimationSets[anim_name]
    if anims then
        replace_animate_script(local_player.Character, anims)
        api:notify("Applied " .. anim_name .. " animation set")
    end
end

-- >> get animation names
local function get_animation_names()
    local keys = {}
    for k in pairs(AnimationSets) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

-- >> custom animations storage
local custom_anims = {
    idle1 = "",
    idle2 = "",
    walk = "",
    run = "",
    jump = "",
    climb = "",
    fall = ""
}

local function apply_custom_animations()
    -- check if all fields are filled
    local all_filled = true
    for _, id in pairs(custom_anims) do
        if id == "" then
            all_filled = false
            break
        end
    end
    
    if not all_filled then
        api:notify("Fill all animation IDs first!", 3)
        return
    end
    
    replace_animate_script(local_player.Character, custom_anims)
    api:notify("Applied custom animations")
end

-- >> UI setup
local tab = api:AddTab("Animations")
local groupbox = tab:AddLeftGroupbox("Animation Changer")

groupbox:AddDropdown("animation_style", {
    Text = "Animation Style",
    Default = 1,
    Values = get_animation_names(),
    Callback = function(value)
        try_apply_anim_set(value)
    end
})

-- >> custom animations UI
local custom_groupbox = tab:AddRightGroupbox("Custom Animations")

custom_groupbox:AddInput("custom_idle1", {
    Text = "Idle 1 ID",
    Default = "",
    Placeholder = "Enter animation ID",
    Callback = function(value)
        custom_anims.idle1 = "http://www.roblox.com/asset/?id=" .. value
    end
})

custom_groupbox:AddInput("custom_idle2", {
    Text = "Idle 2 ID",
    Default = "",
    Placeholder = "Enter animation ID",
    Callback = function(value)
        custom_anims.idle2 = "http://www.roblox.com/asset/?id=" .. value
    end
})

custom_groupbox:AddInput("custom_walk", {
    Text = "Walk ID",
    Default = "",
    Placeholder = "Enter animation ID",
    Callback = function(value)
        custom_anims.walk = "http://www.roblox.com/asset/?id=" .. value
    end
})

custom_groupbox:AddInput("custom_run", {
    Text = "Run ID",
    Default = "",
    Placeholder = "Enter animation ID",
    Callback = function(value)
        custom_anims.run = "http://www.roblox.com/asset/?id=" .. value
    end
})

custom_groupbox:AddInput("custom_jump", {
    Text = "Jump ID",
    Default = "",
    Placeholder = "Enter animation ID",
    Callback = function(value)
        custom_anims.jump = "http://www.roblox.com/asset/?id=" .. value
    end
})

custom_groupbox:AddInput("custom_climb", {
    Text = "Climb ID",
    Default = "",
    Placeholder = "Enter animation ID",
    Callback = function(value)
        custom_anims.climb = "http://www.roblox.com/asset/?id=" .. value
    end
})

custom_groupbox:AddInput("custom_fall", {
    Text = "Fall ID",
    Default = "",
    Placeholder = "Enter animation ID",
    Callback = function(value)
        custom_anims.fall = "http://www.roblox.com/asset/?id=" .. value
    end
})

custom_groupbox:AddButton("Apply Custom Animations", function()
    apply_custom_animations()
end)

-- >> handle respawn
api:on_event("localplayer_spawned", function(char)
    character = char
    local dropdown = api:get_ui_object("animation_style")
    if dropdown then
        local current_value = dropdown.Value
        if current_value then
            task.wait(0.5) -- wait for character to fully load
            try_apply_anim_set(current_value)
        end
    end
end)

-- >> initial apply
local dropdown = api:get_ui_object("animation_style")
if dropdown and dropdown.Value then
    try_apply_anim_set(dropdown.Value)
end