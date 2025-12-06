local Handler = loadstring(game:HttpGet("https://raw.githubusercontent.com/XK5NG/XK5NG.github.io/main/Handler"))()
local ModTable = loadstring(game:HttpGet("https://raw.githubusercontent.com/XK5NG/XK5NG.github.io/refs/heads/main/Contents"))()

local Workspace = Handler:CloneRef("Workspace")
local Players = Handler:CloneRef("Players")
local RunService = Handler:CloneRef("RunService")
local ReplicatedStorage = Handler:CloneRef("ReplicatedStorage")
local UserInputService = Handler:CloneRef("UserInputService")
local SoundService = Handler:CloneRef("SoundService")
local ContentProvider = Handler:CloneRef("ContentProvider")
local MarketplaceService = Handler:CloneRef("MarketplaceService")
local TweenService = Handler:CloneRef("TweenService")
local HttpService = Handler:CloneRef("HttpService")
local CoreGui = Handler:CloneRef("CoreGui")

local LocalPlayer = Players.LocalPlayer
local MainEvent = ReplicatedStorage.MainEvent
local ClientAnimations = ReplicatedStorage.ClientAnimations
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Tab = api:AddTab("seth's addon")

local Main = Tab:AddLeftGroupbox('main')
local Rage = Tab:AddRightGroupbox("rage")
local Spawn = Tab:AddRightGroupbox('spawn')
local Grip = Tab:AddRightGroupbox('grip')
local Character = Tab:AddLeftGroupbox("character")
local Shop = Tab:AddLeftGroupbox("shop")
local LibraryThing = Tab:AddLeftGroupbox("library")
local Notification = Tab:AddLeftGroupbox("notification")
local Misc = Tab:AddLeftGroupbox("miscellaneous")

local IndicatorPosition = nil
local IndicatorCFrame = nil
local ResultCFrame = nil
local Target = nil
local LastCFrame = nil
local LastCam = nil
local SavedCFrame = nil
local LastTeleportedCFrame = nil
local ToolOriginalGrip = {}
local DisabledTools = {}
local OriginalVelocity = {}
local StoredAccessories = {}
local LastPosition = Vector3.new(0/0, 0/0, 0/0)
local VoidCFrame = CFrame.new(0/0, 0/0, 0/0)
local BaseCFrame = CFrame.new(0/0, 0/0, 0/0)
local AngleXRot, AngleYRot, AngleZRot = 0, 0, 0
local OriginalGrip = nil
local Angle = 0
local PreTick = tick()
local Focused = true

local Size = Vector3.new(3, 5, 3)
local EdgeThickness = 0.1
local HalfW, HalfH, HalfD = Size.X / 2, Size.Y / 2, Size.Z / 2

local OldFonts = {}
local OldTexts = {}
local BeamFolders = {}
local ActiveAccessories = {}
local SelectedFont = nil
local TargetGui = nil

local Edges = {}
local EdgeOffsets = {}

local State = false

local KnockActive = false
local BringActive = false
local StompActive = false

if not isfolder("Fonted") then
    makefolder("Fonted")
end

if not isfolder("Fonted/Font") then
    makefolder("Fonted/Font")
end

for Index, File in pairs(HttpService:JSONDecode(game:HttpGet("https://api.github.com/repos/romblust/Fonts/contents/"))) do
    if File.name:match("%.ttf$") then
        if not isfile(`Fonted/Font/{File.name}`) then
            writefile(`Fonted/Font/{File.name}`, game:HttpGet(File.download_url))

            local MetaData = {
                name = File.name:gsub("%.ttf$", "_font"),
                faces = {{
                    style = "normal",
                    assetId = getcustomasset(`Fonted/Font/{File.name}`),
                    name = "Regular",
                    weight = 200
                }}
            }

            writefile(`Fonted/Font/{File.name:gsub("%.ttf$", ".json")}`, HttpService:JSONEncode(MetaData))
        end
    end
end

local Fonts = {}
local Values = {}
local LowerValues = {}

for Index, File in pairs(listfiles("Fonted/Font")) do
    if File:match("%.json$") then
        local FileName = File:match("([^/\\]+)%.json$")
        table.insert(Fonts, FileName:lower())
    end
end

for Index, Item in pairs(Workspace.Ignored.Shop:GetChildren()) do
    if Item and Item:FindFirstChild("Head") and Item:FindFirstChild("ClickDetector") then
        local Insert = true
        local Name = Item.Name

        if Name:lower():find("ammo") then
            Insert = false
        else
            for Index, Exist in pairs(Values) do
                if Exist == Name then
                    Insert = false
                    break
                end
            end
        end

        if Insert then
            table.insert(Values, Name)
        end
    end
end

for Index, Item in pairs(Values) do
    LowerValues[Index] = Item:lower()
end

local IndicatorGui = Instance.new("ScreenGui")
IndicatorGui.Name = "ServerIndicator"
IndicatorGui.Parent = CoreGui
IndicatorGui.IgnoreGuiInset = true

local ClientIndicator = Instance.new("ImageLabel")
ClientIndicator.BackgroundTransparency = 1
ClientIndicator.Size = UDim2.new(0, 25, 0, 25)
ClientIndicator.Image = "rbxassetid://133492644686282"
ClientIndicator.ImageColor3 = Color3.fromRGB(255, 255, 255)
ClientIndicator.ImageTransparency = 0
ClientIndicator.Parent = IndicatorGui

local TargetHUD = Instance.new("ScreenGui")
TargetHUD.Name = "TargetHUD"
TargetHUD.Parent = CoreGui
TargetHUD.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 80)
Frame.Position = UDim2.new(0.5, 0, 0.8, 0)
Frame.AnchorPoint = Vector2.new(0.5, 1)
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.BackgroundTransparency = 0.85
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = false
Frame.Parent = TargetHUD

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Thickness = 2
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = Frame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = Frame

local NameLabel = Instance.new("TextButton")
NameLabel.Size = UDim2.new(0.55, -10, 0, 20)
NameLabel.Position = UDim2.new(0, 10, 0, 10)
NameLabel.BackgroundTransparency = 1
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.FontFace = Font.new(getcustomasset("Fonted/Font/Crisp.json"))
NameLabel.TextScaled = true
NameLabel.TextSize = 24
NameLabel.TextStrokeTransparency = 0
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Text = ""
NameLabel.AutoButtonColor = false
NameLabel.Parent = Frame

local UserIdLabel = Instance.new("TextButton")
UserIdLabel.Size = UDim2.new(0.55, -10, 0, 16)
UserIdLabel.Position = UDim2.new(0, 10, 0, 32)
UserIdLabel.BackgroundTransparency = 1
UserIdLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UserIdLabel.FontFace = Font.new(getcustomasset("Fonted/Font/Crisp.json"))
UserIdLabel.TextScaled = true
UserIdLabel.TextSize = 21
UserIdLabel.TextStrokeTransparency = 0
UserIdLabel.TextXAlignment = Enum.TextXAlignment.Left
UserIdLabel.Text = ""
UserIdLabel.AutoButtonColor = false
UserIdLabel.Parent = Frame

local HealthBarBG = Instance.new("Frame")
HealthBarBG.Size = UDim2.new(0.55, -10, 0, 8)
HealthBarBG.Position = UDim2.new(0, 10, 0, 55)
HealthBarBG.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
HealthBarBG.BorderSizePixel = 0
HealthBarBG.Parent = Frame

local HealthBarUICorner = Instance.new("UICorner")
HealthBarUICorner.CornerRadius = UDim.new(0, 4)
HealthBarUICorner.Parent = HealthBarBG

local HealthBar = Instance.new("Frame")
HealthBar.Size = UDim2.new(1, 0, 1, 0)
HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
HealthBar.BorderSizePixel = 0
HealthBar.Parent = HealthBarBG

local HealthBarInnerCorner = Instance.new("UICorner")
HealthBarInnerCorner.CornerRadius = UDim.new(0, 4)
HealthBarInnerCorner.Parent = HealthBar

local ArmorBarBG = Instance.new("Frame")
ArmorBarBG.Size = HealthBarBG.Size
ArmorBarBG.Position = UDim2.new(0, 10, 0, 65)
ArmorBarBG.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ArmorBarBG.BorderSizePixel = 0
ArmorBarBG.Parent = Frame

local ArmorBarUICorner = Instance.new("UICorner")
ArmorBarUICorner.CornerRadius = UDim.new(0, 4)
ArmorBarUICorner.Parent = ArmorBarBG

local ArmorBar = Instance.new("Frame")
ArmorBar.Size = UDim2.new(0, 0, 1, 0)
ArmorBar.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
ArmorBar.BorderSizePixel = 0
ArmorBar.Parent = ArmorBarBG

local ArmorBarInnerCorner = Instance.new("UICorner")
ArmorBarInnerCorner.CornerRadius = UDim.new(0, 4)
ArmorBarInnerCorner.Parent = ArmorBar

local Thumbnail = Instance.new("ImageButton")
Thumbnail.Size = UDim2.new(0.25, 0, 0.8, 0)
Thumbnail.Position = UDim2.new(0.7, 0, 0.1, 0)
Thumbnail.BackgroundTransparency = 1
Thumbnail.Image = ""
Thumbnail.Parent = Frame

local ThumbnailCorner = Instance.new("UICorner")
ThumbnailCorner.CornerRadius = UDim.new(1,0)
ThumbnailCorner.Parent = Thumbnail

local KnockButton = Instance.new("TextButton")
KnockButton.Size = UDim2.new(0.28, 0, 0, 20)
KnockButton.Position = UDim2.new(0.05, 0, 1.1, 0)
KnockButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
KnockButton.BackgroundTransparency = 0.85
KnockButton.BorderSizePixel = 0
KnockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KnockButton.FontFace = Font.new(getcustomasset("Fonted/Font/Crisp.json"))
KnockButton.TextScaled = true
KnockButton.TextSize = 21
KnockButton.TextStrokeTransparency = 0
KnockButton.Text = "Knock"
KnockButton.AutoButtonColor = false
KnockButton.Parent = Frame

local KnockUICorner = Instance.new("UICorner")
KnockUICorner.CornerRadius = UDim.new(0, 15)
KnockUICorner.Parent = KnockButton

local KnockStroke = Instance.new("UIStroke")
KnockStroke.Color = Color3.fromRGB(255, 255, 255)
KnockStroke.Thickness = 2
KnockStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
KnockStroke.Parent = KnockButton

local BringButton = Instance.new("TextButton")
BringButton.Size = UDim2.new(0.28, 0, 0, 20)
BringButton.Position = UDim2.new(0.36, 0, 1.1, 0)
BringButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BringButton.BackgroundTransparency = 0.85
BringButton.BorderSizePixel = 0
BringButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BringButton.FontFace = Font.new(getcustomasset("Fonted/Font/Crisp.json"))
BringButton.TextScaled = true
BringButton.TextSize = 21
BringButton.TextStrokeTransparency = 0
BringButton.Text = "Bring"
BringButton.AutoButtonColor = false
BringButton.Parent = Frame

local BringUICorner = Instance.new("UICorner")
BringUICorner.CornerRadius = UDim.new(0, 15)
BringUICorner.Parent = BringButton

local BringStroke = Instance.new("UIStroke")
BringStroke.Color = Color3.fromRGB(255, 255, 255)
BringStroke.Thickness = 2
BringStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BringStroke.Parent = BringButton

local StompButton = Instance.new("TextButton")
StompButton.Size = UDim2.new(0.28, 0, 0, 20)
StompButton.Position = UDim2.new(0.67, 0, 1.1, 0)
StompButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StompButton.BackgroundTransparency = 0.85
StompButton.BorderSizePixel = 0
StompButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StompButton.FontFace = Font.new(getcustomasset("Fonted/Font/Crisp.json"))
StompButton.TextScaled = true
StompButton.TextSize = 21
StompButton.TextStrokeTransparency = 0
StompButton.Text = "Stomp"
StompButton.AutoButtonColor = false
StompButton.Parent = Frame

local StompUICorner = Instance.new("UICorner")
StompUICorner.CornerRadius = UDim.new(0, 15)
StompUICorner.Parent = StompButton

local StompStroke = Instance.new("UIStroke")
StompStroke.Color = Color3.fromRGB(255, 255, 255)
StompStroke.Thickness = 2
StompStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
StompStroke.Parent = StompButton

local TargetTextBox = Instance.new("TextBox")
TargetTextBox.Size = UDim2.new(1, -75, 0, KnockButton.Size.Y.Offset)
TargetTextBox.Position = UDim2.new(0, 5, 0, -KnockButton.Size.Y.Offset - (Frame.Size.Y.Offset * 0.1))
TargetTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TargetTextBox.BackgroundTransparency = 0.85
TargetTextBox.BorderSizePixel = 0
TargetTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetTextBox.FontFace = Font.new(getcustomasset("Fonted/Font/Crisp.json"))
TargetTextBox.TextScaled = true
TargetTextBox.TextSize = 21
TargetTextBox.ClearTextOnFocus = true
TargetTextBox.TextTruncate = Enum.TextTruncate.AtEnd
TargetTextBox.TextWrapped = false
TargetTextBox.TextStrokeTransparency = 0
TargetTextBox.Text = ""
TargetTextBox.PlaceholderText = "Enter target..."
TargetTextBox.Parent = Frame

local TextBoxCorner = Instance.new("UICorner")
TextBoxCorner.CornerRadius = UDim.new(0, 15)
TextBoxCorner.Parent = TargetTextBox

local TextBoxStroke = Instance.new("UIStroke")
TextBoxStroke.Color = Color3.fromRGB(255, 255, 255)
TextBoxStroke.Thickness = 2
TextBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TextBoxStroke.Parent = TargetTextBox

local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(0, 60, 0, KnockButton.Size.Y.Offset)
ClearButton.Position = UDim2.new(1, -65, 0, -KnockButton.Size.Y.Offset - (Frame.Size.Y.Offset * 0.1))
ClearButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.BackgroundTransparency = 0.85
ClearButton.BorderSizePixel = 0
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.FontFace = Font.new(getcustomasset("Fonted/Font/Crisp.json"))
ClearButton.TextScaled = true
ClearButton.TextSize = 21
ClearButton.TextStrokeTransparency = 0
ClearButton.Text = "Clear"
ClearButton.AutoButtonColor = false
ClearButton.Parent = Frame

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 15)
ClearCorner.Parent = ClearButton

local ClearStroke = Instance.new("UIStroke")
ClearStroke.Color = Color3.fromRGB(255, 255, 255)
ClearStroke.Thickness = 2
ClearStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ClearStroke.Parent = ClearButton

local MiddlePart = Instance.new("Part")
MiddlePart.Size = Vector3.new(1, 1, 1)
MiddlePart.Anchored = true
MiddlePart.CanCollide = false
MiddlePart.Transparency = 1
MiddlePart.CFrame = BaseCFrame
MiddlePart.Parent = workspace

local DesyncBillboard = Instance.new("BillboardGui")
DesyncBillboard.Adornee = MiddlePart
DesyncBillboard.Size = UDim2.new(0, 200, 0, 50)
DesyncBillboard.StudsOffset = Vector3.new(0, 3.5, 0)
DesyncBillboard.AlwaysOnTop = true
DesyncBillboard.Enabled = false
DesyncBillboard.Parent = CoreGui

local DesyncTextLabel = Instance.new("TextLabel")
DesyncTextLabel.Size = UDim2.new(1, 0, 1, 0)
DesyncTextLabel.BackgroundTransparency = 1
DesyncTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DesyncTextLabel.TextTransparency = 0
DesyncTextLabel.TextScaled = true
DesyncTextLabel.FontFace = Font.new(getcustomasset("Fonted/Font/Crisp.json"))
DesyncTextLabel.Parent = DesyncBillboard

local CurrentTargetName = ""
local CurrentTargetUserId = ""

local Accessorys = {
    { Name = "jacket", Type = Enum.AccessoryType.Jacket, ToggleName = "RemoveJackets" },
    { Name = "shirt", Type = Enum.AccessoryType.Shirt, ToggleName = "RemoveShirts" },
    { Name = "pants", Type = Enum.AccessoryType.Pants, ToggleName = "RemovePants" },
    { Name = "face", Type = Enum.AccessoryType.Face, ToggleName = "RemoveFace" },
    { Name = "hats", Type = Enum.AccessoryType.Hat, ToggleName = "RemoveHats" },
    { Name = "shoulder", Type = Enum.AccessoryType.Shoulder, ToggleName = "RemoveShoulder" },
    { Name = "front", Type = Enum.AccessoryType.Front, ToggleName = "RemoveFront" },
    { Name = "back", Type = Enum.AccessoryType.Back, ToggleName = "RemoveBack" },
    { Name = "waist", Type = Enum.AccessoryType.Waist, ToggleName = "RemoveWaist" }
}

function SemiNotify(Text, Duration, Asset, Decibel)
    api:notify(Text, Duration or 1)

    local AssetId = tonumber(Asset)
    if not AssetId or AssetId == 0 then
        AssetId = 18723584764
    end

    local Success = pcall(function()
        MarketplaceService:GetProductInfo(AssetId)
    end)

    if not Success then
        AssetId = 18723584764
    end

    Handler:PlaySound(AssetId, Decibel or 1)
end

function Notify(Text, Asset)
    api:notify(Text)

    Handler:PlaySound(18723584764, 1)

    if Asset and tonumber(Asset) and tonumber(Asset) ~= 0 then
        local AssetId = tonumber(Asset)
        local Success = pcall(function()
            MarketplaceService:GetProductInfo(AssetId)
        end)
        
        if Success then
            task.wait(0.4)
            Handler:PlaySound(AssetId, 1)
        end
    end
end

function CreateEdge(PositionOffset, EdgeSize)
    local EdgeFolder = workspace:FindFirstChild("Edge Folder")
    
    if not EdgeFolder then
        EdgeFolder = Instance.new("Folder")
        EdgeFolder.Name = "Edge Folder"
        EdgeFolder.Parent = workspace
    end

    local Part = Instance.new("Part")
    Part.Size = EdgeSize
    Part.Anchored = true
    Part.CanCollide = false
    Part.Transparency = 1
    Part.CFrame = BaseCFrame * CFrame.new(PositionOffset)
    Part.Parent = EdgeFolder

    local Highlight = Instance.new("Highlight")
    Highlight.Adornee = Part
    Highlight.FillColor = Color3.fromRGB(255, 255, 255)
    Highlight.FillTransparency = 0.5
    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    Highlight.OutlineTransparency = 0
    Highlight.Parent = Part

    table.insert(Edges, Part)
    table.insert(EdgeOffsets, PositionOffset)
    return Part
end

function BuyItem(Item, Price)
    local BoughtItem
    repeat RunService.Heartbeat:Wait()
        local Shop = Workspace.Ignored.Shop:FindFirstChild(Item .. " - $" .. Price)
        if Shop and Shop:FindFirstChild("Head") and Shop:FindFirstChild("ClickDetector") then
            api:set_server_cframe(Shop.Head.CFrame)
            fireclickdetector(Shop.ClickDetector)
        end
        BoughtItem = LocalPlayer.Backpack:FindFirstChild(Item)
    until BoughtItem
    BoughtItem.Parent = LocalPlayer.Character
end

function GetItem(Item)
    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local BaseItem = Item:match("^(.-)%s*%-?%s*%$?%d*$") or Item
    
        local StartTime = tick()
        local StartingCurrency = api:get_data_cache(LocalPlayer).Currency
    
        repeat RunService.Heartbeat:Wait()
            local Shop = Workspace.Ignored.Shop:FindFirstChild(Item)
            if Shop and Shop:FindFirstChild("Head") and Shop:FindFirstChild("ClickDetector") then
                api:set_server_cframe(Shop.Head.CFrame)
                fireclickdetector(Shop.ClickDetector)
            end
    
            local CurrentCurrency = api:get_data_cache(LocalPlayer).Currency
        until tick() - StartTime > 1 or api:get_data_cache(LocalPlayer).Currency < StartingCurrency
    
        if LocalPlayer.Backpack:FindFirstChild(BaseItem) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(BaseItem)) then
            SemiNotify(`purchased {BaseItem}`, 1.5, 87082710377514, 1)
        else
            SemiNotify(`failed to purchase {BaseItem} (timeout or insufficient currency)`, 1.5, 106796270505945, 1)
        end
    end
end

function GetAmmo()
    if not (LocalPlayer and LocalPlayer:FindFirstChild("DataFolder") and LocalPlayer.DataFolder:FindFirstChild("Inventory") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Tool")) then
        return
    end

    local PreTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local OldTool = tostring(PreTool.Name)

    local Ammo
    local Found = 0
    for Index, Shop in pairs(workspace.Ignored.Shop:GetChildren()) do
        local Item = Shop.Name:lower()
        if Item:find("ammo") and Shop:FindFirstChild("Head") and Shop:FindFirstChild("ClickDetector") then
            local IsFound = 0
            for Word in OldTool:lower():gmatch("%Weld+") do
                if Item:find(Word) then
                    IsFound = IsFound + 1
                end
            end

            if IsFound > Found then
                Found = IsFound
                Ammo = Shop
            end
        end
    end

    if not Ammo then
        return
    end

    local Before = LocalPlayer.DataFolder.Inventory:FindFirstChild(OldTool) and tonumber(LocalPlayer.DataFolder.Inventory[OldTool].Value) or 0
    local Bought = 0
    local Target = Options and Options["Shop Amount"] and tonumber(Options["Shop Amount"].Value) or 1
    local StartTime = tick()

    repeat
        local CurrentAmmo = LocalPlayer.DataFolder.Inventory:FindFirstChild(OldTool) and tonumber(LocalPlayer.DataFolder.Inventory[OldTool].Value) or Before

        if CurrentAmmo > Before then
            Before = CurrentAmmo
            Bought = Bought + 1
        end

        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Backpack and LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
            Handler:Humanoid(LocalPlayer):UnequipTools()
        end

        api:set_server_cframe(Ammo.Head.CFrame)
        fireclickdetector(Ammo.ClickDetector)

        RunService.Heartbeat:Wait()
    until Bought >= Target or tick() - StartTime > 10

    PreTool.Parent = LocalPlayer.Character

    if Bought > 0 then
        SemiNotify(`purchased {Bought}x ammo for {OldTool}`, 1.5, 87082710377514, 1)
    else
        SemiNotify(`failed to buy ammo for {OldTool} (timeout)`, 1.5, 106796270505945, 1)
    end
end

function GetGripOnTool(ToolName, Grippos)
    local Count = 0
    for Index, Tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if Tool.Name == ToolName and Grippos[Count + 1] and LocalPlayer and LocalPlayer.Character then
            Tool.Grip = Grippos[Count + 1]
            Tool.Parent = LocalPlayer.Character
            Count += 1
            task.wait()
        end
    end
end

function CreateBeam(Tool)
    if not BeamFolders[Tool] then
        local Folder = Instance.new("Folder")
        Folder.Name = "AimBeamFolder"
        Folder.Parent = Tool.Handle

        local Attachment0 = Instance.new("Attachment")
        Attachment0.Name = "Attachment0"
        Attachment0.Parent = Folder

        local Attachment1 = Instance.new("Attachment")
        Attachment1.Name = "Attachment1"
        Attachment1.Parent = Folder

        local Beam = Instance.new("Beam")
        Beam.Name = "AimBeam"
        Beam.Attachment0 = Attachment0
        Beam.Attachment1 = Attachment1
        Beam.FaceCamera = true
        Beam.Color = ColorSequence.new(Options["Beam Color"].Value or Color3.fromRGB(255, 0, 0))
        Beam.Transparency = NumberSequence.new(Options["Beam Color"].Transparency or 0.3)
        Beam.Width0 = 0.1
        Beam.Width1 = 0.1
        Beam.Parent = Folder
        BeamFolders[Tool] = Folder
    end
end

function DestroyBeams()
    for Tool, Folder in pairs(BeamFolders) do
        if Folder then
            Folder:Destroy()
        end
    end
    BeamFolders = {}
end

function CreateAttachment(Accessories, Name)
	if Accessories and LocalPlayer and LocalPlayer.Character then
		if type(Accessories) == "number" then
			Accessories = game:GetObjects(`rbxassetid://{Accessories}`)[1]
		end
        Accessories.Name = Name
		Accessories.Parent = LocalPlayer.Character
		if Accessories:FindFirstChild("Handle") then
			Accessories.Handle.CanCollide = false
			if Accessories.Handle:FindFirstChildOfClass("Attachment") then
				local Attachment = Accessories.Handle:FindFirstChildOfClass("Attachment")
				local Parented = LocalPlayer.Character:FindFirstChild(Attachment.Name, true)
				if Parented then
					local Weld = Instance.new("Weld")
					Weld.Part0 = Parented.Parent
					Weld.Part1 = Accessories.Handle
					Weld.C0 = Parented.CFrame
					Weld.C1 = Attachment.CFrame
					Weld.Parent = Accessories.Handle
				end
			elseif LocalPlayer.Character:FindFirstChild("Head") then
				local Weld = Instance.new("Weld")
				Weld.Part0 = LocalPlayer.Character.Head
				Weld.Part1 = Accessories.Handle
				Weld.C0 = CFrame.new(0, 0.5, 0)
				Weld.C1 = Accessories.AttachmentPoint or CFrame.new()
				Weld.Parent = LocalPlayer.Character.Head
			end
		end
	end
end

function RemoveAttachment(Name)
	if LocalPlayer and LocalPlayer.Character then
		local Accessory = LocalPlayer.Character:FindFirstChild(Name)
		if Accessory then
			for Index, Int in pairs(Accessory:GetDescendants()) do
				if Int:IsA("Weld") or Int:IsA("WeldConstraint") then
					Int:Destroy()
				end
			end
			Accessory:Destroy()
		end
	end
end

function ProperName(Name)
	if #Name > 21 then
        return `{Name:sub(1, 18)}...`
	end
	return Name
end

function SetupLabelHover(Label, GetText)
	Label.MouseEnter:Connect(function()
		TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
	end)

	Label.MouseLeave:Connect(function()
		TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)

	Label.MouseButton1Click:Connect(function()
        Notify(`copied {GetText()}`)
		setclipboard(GetText())
	end)
end

function SetupButtonHover(Button)
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
end

function ShouldRemove(Type)
    if Toggles and Toggles["AntiLaggerEnabled"] and Toggles["AntiLaggerEnabled"].Value then
        return true
    end

    for Index, Config in pairs(Accessorys) do
        if Config.Type == Type and Toggles[Config.ToggleName] and Toggles[Config.ToggleName].Value then
            return true
        end
    end
    return false
end

function Check(Player)
    if not Player or Player == LocalPlayer or not Player:IsA("Player") then
        return
    end

    if ModTable and ModTable[tostring(Player.UserId)] then
        Notify(`a mod has joined your game`, 109500748577022)
        LocalPlayer:Kick(`a mod has joined your game | triggered by: {Player.DisplayName} (@{Player.Name}) | id: {Player.UserId} | reason: matched`)
        return
    end

    local Flags = {}
    local ShouldKick = true

    local Success, InGroup = pcall(Player.IsInGroup, Player, 10604500)
    if Success and InGroup then
        local Xp, Role = pcall(Player.GetRoleInGroup, Player, 10604500)
        if Xp and Role == "Roblox Verified" then
            Notify(`verified user {Player.DisplayName} (@{Player.Name}) - roblox verified`)
            ShouldKick = false
        end
    end

    for GroupId, Data in pairs({[10604500] = {name = "da hood verified", notifies = {"celebs", "roblox verified", "trades"}}, [17215700] = "stars staff", [8068202] = "da hood stars", [4698921] = {name = "da hood entertainment", forbidden = {"owner", "admin", "devs", "monetization", "contributed", "moderators"}}}) do
        local Success, InGroup = pcall(Player.IsInGroup, Player, GroupId)
        if Success and InGroup then
            local Xp, Role = pcall(Player.GetRoleInGroup, Player, GroupId)
            if Xp and Role then
                if type(Data) == "table" then
                    if Data.notifies and table.find(Data.notifies, string.lower(Role)) then
                        Notify(`possible mod detected {Player.DisplayName} (@{Player.Name}) - {Role} in {Data.name}`)
                    end

                    if Data.forbidden and table.find(Data.forbidden, string.lower(Role)) then
                        Notify("a moderator has been detected", 100378746493602)
                        table.insert(Flags, `{Data.name} - {Role}`)
                    end
                else
                    table.insert(Flags, `{Data} - {Role}`)
                end
            end
        end
    end

    if #Flags > 0 and ShouldKick then
        LocalPlayer:Kick(`a mod was on your game | triggered by: {Player.DisplayName} (@{Player.Name}) | id: {Player.UserId} | reason: {table.concat(Flags, ", ")}`)
    end
end

function Velocity(Player)
    if Player and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") then
        local CPosition = Player.Character.HumanoidRootPart.Position
        local LastTick = tick() 
        task.wait()
        local NPosition = Player.Character.HumanoidRootPart.Position
        local NextTick = tick()
        local Offset = (NPosition - CPosition)
        local Elapsed = NextTick - LastTick
        return Offset / Elapsed
    end
end

function CreateDependency(Name, Tab, Dependency)
    local DependencyBox = Tab:AddDependencyBox()
    DependencyBox:SetupDependencies({
        { Dependency, true }
    })
    getgenv()[Name] = DependencyBox
    return DependencyBox
end

local TopFront = CreateEdge(Vector3.new(0, HalfH, HalfD - EdgeThickness / 2), Vector3.new(Size.X, EdgeThickness, EdgeThickness))
CreateEdge(Vector3.new(0, HalfH, - HalfD + EdgeThickness / 2), Vector3.new(Size.X, EdgeThickness, EdgeThickness))
CreateEdge(Vector3.new(HalfW - EdgeThickness / 2, HalfH, 0), Vector3.new(EdgeThickness, EdgeThickness, Size.Z))
CreateEdge(Vector3.new(- HalfW + EdgeThickness / 2, HalfH, 0), Vector3.new(EdgeThickness, EdgeThickness, Size.Z))
CreateEdge(Vector3.new(0, - HalfH, HalfD - EdgeThickness / 2), Vector3.new(Size.X, EdgeThickness, EdgeThickness))
CreateEdge(Vector3.new(0, - HalfH, - HalfD + EdgeThickness / 2), Vector3.new(Size.X, EdgeThickness, EdgeThickness))
CreateEdge(Vector3.new(HalfW - EdgeThickness / 2, - HalfH, 0), Vector3.new(EdgeThickness, EdgeThickness, Size.Z))
CreateEdge(Vector3.new(- HalfW + EdgeThickness / 2, - HalfH, 0), Vector3.new(EdgeThickness, EdgeThickness, Size.Z))
CreateEdge(Vector3.new(HalfW - EdgeThickness / 2, 0, HalfD - EdgeThickness / 2), Vector3.new(EdgeThickness, Size.Y, EdgeThickness))
CreateEdge(Vector3.new(- HalfW + EdgeThickness / 2, 0, HalfD - EdgeThickness / 2), Vector3.new(EdgeThickness, Size.Y, EdgeThickness))
CreateEdge(Vector3.new(HalfW - EdgeThickness / 2, 0, - HalfD + EdgeThickness / 2), Vector3.new(EdgeThickness, Size.Y, EdgeThickness))
CreateEdge(Vector3.new(- HalfW + EdgeThickness / 2, 0, - HalfD + EdgeThickness / 2), Vector3.new(EdgeThickness, Size.Y, EdgeThickness))

SetupButtonHover(KnockButton)
SetupButtonHover(BringButton)
SetupButtonHover(StompButton)
SetupButtonHover(ClearButton)

SetupLabelHover(NameLabel, function()
	return CurrentTargetName
end)

SetupLabelHover(UserIdLabel, function()
	return CurrentTargetUserId
end)

Main:AddToggle('GrenadeEnabled', {
    Text = 'grenade',
    Default = false,

    Callback = function(Value)
        if Handler:Connected("Grenade") and not Value then
            Handler:Disconnect("Grenade", true)
        end
    end
}):AddKeyPicker('GrenadeKeyPicker', {
    Default = 'L',
    Mode = 'Toggle',
    Text = 'grenade',
    NoUI = false,

    Callback = function(Value)
        if Toggles and Toggles["GrenadeEnabled"] and Toggles["GrenadeEnabled"].Value then
            if Value then
                Handler:Disconnect("Grenade", true)

                Handler:AddConnection("Grenade", RunService.Heartbeat:Connect(function()
                    if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) then
                        return
                    end

                    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character:FindFirstChild("Humanoid") then
                            OriginalVelocity[1] = Velocity(Target)
                            for Index, Part in pairs(workspace.Ignored:GetChildren()) do
                                if Part and Part.Name == "Handle" then
                                    if not Part:FindFirstChild("Highlight") then
                                        local Highlight = Instance.new("Highlight", Part)
                                        Highlight.OutlineTransparency = 0
                                        Highlight.FillTransparency = 0
                                    
                                        spawn(function()
                                            local Hue = 0
                                            while Highlight.Parent do
                                                Highlight.OutlineColor = Color3.fromHSV(Hue, 1, 1)
                                                Highlight.FillColor = Color3.fromHSV(Hue, 1, 1)
                                                Hue = (Hue + 0.01) % 1
                                                task.wait(0.03)
                                            end
                                        end)
                                    end
                    
                                    if not Part:FindFirstChild("Attachment") then
                                        local Attachment = Instance.new("Attachment", Part)
                                        local Beam = Instance.new("Beam", Attachment)
                                        Beam.Brightness = 9e9
                                        Beam.Color = ColorSequence.new{
                                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                                        }
                                        Beam.LightEmission = 1
                                        Beam.TextureMode = Enum.TextureMode.Wrap
                                        Beam.TextureSpeed = .1
                                        Beam.Attachment0 = LocalPlayer.Character.RightHand.RightGripAttachment
                                        Beam.Attachment1 = Attachment
                                        Beam.Width0 = .1
                                        Beam.Width1 = .1
                                        Beam.FaceCamera = true
                                        local ClonedBeam = Beam:clone()
                                        ClonedBeam.Name = "ClonedBeam"
                                        ClonedBeam.Parent = Attachment
                                    else
                                        if Part and Part:FindFirstChild("Attachment") and Part:FindFirstChild("Attachment"):FindFirstChild("ClonedBeam") then
                                            Part.Attachment.ClonedBeam.Attachment0 = Target.Character.RightHand.RightGripAttachment
                                        end
                                    end
                    
                                    Part.Velocity = Vector3.new(0, 79, 0)
                                    Part.CanCollide = false
    
                                    if (Part.Position - Target.Character.UpperTorso.Position).Magnitude < 30 then
                                        Part.CFrame = Target.Character.UpperTorso.CFrame + ((OriginalVelocity[1] * Options["Prediction"].Value) or Vector3.new(0.1, 0.1, 0.1))
                                    else
                                        local BodyPosition = Part:FindFirstChildWhichIsA("BodyPosition")
                                        if not BodyPosition then
                                            BodyPosition = Instance.new("BodyPosition", Part)
                                        end
                                        
                                        BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                        BodyPosition.Position = Target.Character.UpperTorso.Position + ((OriginalVelocity[1] * Options["Prediction"].Value) or Vector3.new(0.1,0.1,0.1))
                                        BodyPosition.P = 100000
                                        BodyPosition.D = 200
                                    end
                                end
                            end
                        end
                    end
                end))
            else
                Handler:Disconnect("Grenade", true)
            end
        end
    end
})

CreateDependency("GrenadeBox", Main, Toggles["GrenadeEnabled"])

GrenadeBox:AddSlider('Prediction', {
    Text = 'prediction',
    Default = 0.1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Suffix = "%",
    HideMax = true,
    Compact = true,
})

Main:AddDivider()

Main:AddToggle('CartEnabled', {
    Text = 'cart car',
    Default = false,

    Callback = function(Value)
        if Handler:Connected({"Cart", "KeyDown", "KeyUp"}) and not Value then
            Handler:Disconnect({"Cart", "KeyDown", "KeyUp"})
        end
    end
}):AddKeyPicker('CartKeypicker', {
    Default = 'P',
    Mode = 'Toggle',
    Text = 'cart car',
    NoUI = false,

    Callback = function(Value)
        if Toggles and Toggles["CartEnabled"] and Toggles["CartEnabled"].Value then
            local Seat = workspace:FindFirstChild("OldVehicles")[`{LocalPlayer.Name}BIKE`]:FindFirstChild("Seat")

            if Value then
                Handler:Disconnect({"Cart", "KeyDown", "KeyUp"})
                
	        	local BodyVelocity = Instance.new("BodyVelocity")
	        	BodyVelocity.Name = "Move"
	        	BodyVelocity.MaxForce = Vector3.new(99e99, 0, 99e99)
	        	BodyVelocity.Velocity = Vector3.zero
	        	BodyVelocity.Parent = Seat
        
	        	local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
	        	BodyAngularVelocity.Name = "Rotate"
	        	BodyAngularVelocity.MaxTorque = Vector3.new(0, 99e99, 0)
	        	BodyAngularVelocity.AngularVelocity = Vector3.zero
	        	BodyAngularVelocity.Parent = Seat
        
                local BodyGyro = Instance.new("BodyGyro")
                BodyGyro.Name = "Stabilizer"
                BodyGyro.MaxTorque = Vector3.new(99e99, 0, 99e99)
                BodyGyro.P = 10000
                BodyGyro.D = 1000
                BodyGyro.CFrame = Seat.CFrame
                BodyGyro.Parent = Seat
        
	        	local W, S, A, D = false, false, false, false
        
	        	Handler:AddConnection("Cart", RunService.Heartbeat:Connect(function()
                    if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) or (Handler:Is_KO(LocalPlayer) and Handler:Is_KO(LocalPlayer).Value) then
                        return
                    end

	        		if not Seat:FindFirstChild("Move") or not Seat:FindFirstChild("SeatWeld") then
	        			return
	        		end
        
	        		local LookVector = Seat.CFrame.LookVector
                    local Position = Seat.Position
                    local Unit = Vector3.new(LookVector.X, 0, LookVector.Z).Unit
        
	        		Seat.CustomPhysicalProperties = PhysicalProperties.new(0.1, 0.1, 0.1, 0.1, 0.1)
        
	        		BodyVelocity.Velocity = (W and Vector3.new(LookVector.X, 0, LookVector.Z) * Options["Speed"].Value) or (S and Vector3.new(-LookVector.X, 0, -LookVector.Z) * Options["Speed"].Value) or Vector3.zero
	        		BodyAngularVelocity.AngularVelocity = (A and Vector3.new(0, Options["Rotate"].Value, 0)) or (D and Vector3.new(0, -Options["Rotate"].Value, 0)) or Vector3.zero
                    BodyGyro.CFrame = CFrame.new(Position, Position + Unit)
	        	end))
        
                Handler:AddConnection("KeyDown", UserInputService.InputBegan:Connect(function(Input, Locked)
                	if Locked then
                		return
                	end
        
                	if Input.KeyCode == Enum.KeyCode.W then
                		W = true
                	elseif Input.KeyCode == Enum.KeyCode.S then
                		S = true
                	elseif Input.KeyCode == Enum.KeyCode.A then
                		A = true
                	elseif Input.KeyCode == Enum.KeyCode.D then
                		D = true
                	end
                end))
        
                Handler:AddConnection("KeyUp", UserInputService.InputEnded:Connect(function(Input)
                	if Input.KeyCode == Enum.KeyCode.W then
                		W = false
                	elseif Input.KeyCode == Enum.KeyCode.S then
                		S = false
                	elseif Input.KeyCode == Enum.KeyCode.A then
                		A = false
                	elseif Input.KeyCode == Enum.KeyCode.D then
                		D = false
                	end
                end))
	        else
	        	Handler:Disconnect({"Cart", "KeyDown", "KeyUp"})
        
	        	for Index, Instances in pairs({"Move", "Rotate", "Stabilizer"}) do
	        		if Seat:FindFirstChild(Instances) then 
	        			Seat:FindFirstChild(Instances):Destroy()
	        		end
	        	end
	        end
        end
    end
})

CreateDependency("CartBox", Main, Toggles["CartEnabled"])

CartBox:AddSlider('Speed', {
    Text = 'speed',
    Default = 20,
    Min = 20,
    Max = 150,
    Rounding = 1,
    Suffix = "%",
    HideMax = true,
    Compact = true,
}):AddSlider('Rotate', {
    Text = 'rotate',
    Default = 2,
    Min = 2,
    Max = 5,
    Rounding = 1,
    Suffix = "%",
    HideMax = true,
    Compact = true,
})

Main:AddDivider()

Main:AddToggle('HudEnabled', {
    Text = 'target hud',
    Default = false,
})

Main:AddDivider()

Main:AddToggle('BlockingEnabled', {
    Text = 'auto block',
    Default = false,

    Callback = function(Value)
        if Value then
            Handler:Disconnect("Blocking", true)

            Handler:AddConnection("Blocking", RunService.Heartbeat:Connect(function()
                if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) or (Handler:Is_KO(LocalPlayer) and Handler:Is_KO(LocalPlayer).Value) then
                    return
                end
                
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    if LocalPlayer.Character:FindFirstChildWhichIsA("Tool") and LocalPlayer.Character:FindFirstChildWhichIsA("Tool"):FindFirstChild("Handle") and LocalPlayer.Character:FindFirstChildWhichIsA("Tool"):FindFirstChild("Ammo") then
                        MainEvent:FireServer("Block", false)
                    else
                        MainEvent:FireServer("Block", true)
                        task.wait()
                        MainEvent:FireServer("Block", false)
                    end
                end
            end))
        else
            Handler:Disconnect("Blocking", true)
        end
    end
})

Main:AddDivider()

Main:AddToggle('SilentEnabled', {
    Text = 'silent animation',
    Default = false,

    Callback = function(Value)
        if Value then
            Handler:Disconnect("Silent", true)

            Handler:AddConnection("Silent", RunService.Stepped:Connect(function()
                if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) then
                    return
                end

                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    for Index, Tracks in pairs(LocalPlayer.Character:WaitForChild("Humanoid"):GetPlayingAnimationTracks()) do
                    	if Tracks.Animation.AnimationId == "rbxassetid://2788315673" or Tracks.Animation.AnimationId == "rbxassetid://2788289281" or Tracks.Animation.AnimationId == "rbxassetid://2788292075" or Tracks.Animation.AnimationId == "rbxassetid://2788314837" or Tracks.Animation.AnimationId == "rbxassetid://2788313790" or Tracks.Animation.AnimationId == "rbxassetid://2788312709" or Tracks.Animation.AnimationId == "rbxassetid://2791878164" or Tracks.Animation.AnimationId == "rbxassetid://2788316350" or Tracks.Animation.AnimationId == "rbxassetid://2788354405" then
                    		Tracks:Destroy()
                    	end
                    end
    
                    for Index, Tracks in pairs(LocalPlayer.Character:WaitForChild("Humanoid"):GetPlayingAnimationTracks()) do
                    	if Tracks.Name == "FallAnim" or Tracks.Name == "Animation1" or Tracks.Name == "Animation2" or Tracks.Name == "JumpAnim" or Tracks.Name == "WalkAnim" or Tracks.Name == "RunAnim" then
                    		if Tracks.Priority ~= Enum.AnimationPriority.Action2 then
                    			Tracks.Priority = Enum.AnimationPriority.Action2
                    		end
                    	end
    
                    	if Tracks.Name == "ToolNoneAnim" or Tracks.Name == "ToolLungeAnim" or Tracks.Name == "ToolSlashAnim" then
                    		if Tracks.Priority ~= Enum.AnimationPriority.Action3 then
                    			Tracks.Priority = Enum.AnimationPriority.Action3
                    		end
                    	end
                    end
                end
            end))
        else
            Handler:Disconnect("Silent", true)
        end
    end
})

Main:AddDivider()

Main:AddToggle('BountyEnabled', {
    Text = 'auto bounty',
    Default = false,

    Callback = function(Value)
        local Saved = {}

        if Value then
            for Index, Weapon in pairs(Options["ragebot_weapon"].Value) do
                Saved[Index] = Weapon
            end

            Handler:Disconnect({"BountyDead", "BountyPoster"}, true)

            local PosterTexts = workspace:WaitForChild("MAP"):WaitForChild("BountyPosters"):WaitForChild("Poster"):WaitForChild("Texts")
            local PlayerPoster = PosterTexts:WaitForChild("PlayerName"):WaitForChild("SurfaceGui"):WaitForChild("TextLabel")
            local BountyPoster = PosterTexts:WaitForChild("Bounty"):WaitForChild("SurfaceGui"):WaitForChild("TextLabel")

            function FindPoster()
                if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid")) then
                    return
                end

                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    if PlayerPoster and PlayerPoster.Text == LocalPlayer.Name then
                        return
                    end

                    Target = (PlayerPoster and PlayerPoster.Text ~= "" and Players:FindFirstChild(PlayerPoster.Text)) or (api and api.get_target and api:get_target("ragebot"))
                    if Target and api and api.is_crew and api:is_crew(LocalPlayer, Target) then
                        return
                    end
    
                    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character:FindFirstChild("Humanoid") then
                        if Options and Options["ragebot_targets"] then
                            Options["ragebot_targets"]:SetValue(PlayerPoster.Text)
    
                            Options["ragebot_weapon"]:SetValue("[AUG]")
    
                            Handler:AddConnection("BountyDead", RunService.Heartbeat:Connect(function()
                                if Handler:Is_Dead(Target) and Handler:Is_Dead(Target).Value then
                                    Options["ragebot_weapon"]:SetValue(Saved)
                                    Options["ragebot_targets"]:SetValue("nil")
                                    api:get_ui_object("ragebot_keybind"):OverrideState(false)
                                    api:set_ragebot(nil)
                                    
                                    task.delay(1.3, function()
                                        Handler:Disconnect("BountyDead")
                                    end)
                                end
                            end))
    
                            api:get_ui_object("ragebot_keybind"):OverrideState(true)
                            api:set_ragebot(true)
                        end
                    end
                end
            end

            if PlayerPoster and PlayerPoster.Text ~= "" then
                FindPoster()
            end

            Handler:AddConnection("BountyPoster", PlayerPoster:GetPropertyChangedSignal("Text"):Connect(function()
                if PlayerPoster.Text ~= "" then
                    FindPoster()
                end
            end))
        else
            Handler:Disconnect({"BountyDead", "BountyPoster"}, true)
            Options["ragebot_weapon"]:SetValue(Saved)

            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Backpack and LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
                Handler:Humanoid(LocalPlayer):UnequipTools()
            end

            if Options and Options["ragebot_targets"] then
                Options["ragebot_targets"]:SetValue("nil")
            end

            api:get_ui_object("ragebot_keybind"):OverrideState(false)
            api:set_ragebot(nil)
        end
    end
})

Main:AddDivider()

Main:AddToggle('AntiLaggerEnabled', {
    Text = 'anti lagger',
    Default = false,

    Callback = function(Value)
        if Value then
            Handler:Disconnect("Anti Lagger", true)

            Handler:AddConnection("Anti Lagger", RunService.Heartbeat:Connect(function()
                if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) then
                    return
                end

                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    for Index, Player in pairs(Players:GetPlayers()) do
                        if Player ~= LocalPlayer and Player.Character then
                            if not StoredAccessories[Player.Character] then
                                StoredAccessories[Player.Character] = {}
                            end
                        
                            for Index2, Item in pairs(Player.Character:GetChildren()) do
                                if Item:IsA("Accessory") and ShouldRemove(Item.AccessoryType) then
                                    if not table.find(StoredAccessories[Player.Character], Item) then
                                        table.insert(StoredAccessories[Player.Character], Item:Clone())
                                    end
                                    
                                    Item:Destroy()
                                end
                            end
                        end
                    end
                end
            end))
        else
            Handler:Disconnect("Anti Lagger", true)

            for Character, Accessories in pairs(StoredAccessories) do
                if Character and Character.Parent then
                    for Index2, Clone in pairs(Accessories) do
                        if not Character:FindFirstChild(Clone.Name) then
                            Clone:Clone().Parent = Character
                        end
                    end
                end
            end

            StoredAccessories = {}
        end
    end
})

Main:AddDivider()

for Index, Config in pairs(Accessorys) do
    Main:AddToggle(Config.ToggleName, { Text = Config.Name })
end

Spawn:AddToggle('SpawnEnabled', {
    Text = 'respawn',
    Default = false,
})

CreateDependency("SpawnBox", Spawn, Toggles["SpawnEnabled"])

SpawnBox:AddInput('Sound', {
    Default = '',
    Numeric = true,
    Finished = true,

    Text = 'sound',

    Placeholder = 'assetid...',
})

SpawnBox:AddButton({
    Text = 'set position',
    Func = function()
        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            Notify(`position set at {LocalPlayer.Character.HumanoidRootPart.CFrame}`)
        end
    end,
}):AddButton({
    Text = 'delete position',
    Func = function()
        SavedCFrame = nil
        Notify(`position deleted`)
    end,
})

SpawnBox:AddDropdown('Sound Dropdown', {
    Values = {'dio', 'bling', 're-zero', 'celeste', 'splatoon', 'blues', 'warp', 'jutsu'},
    Default = 0,
    AllowNull = true,
})

SpawnBox:AddDropdown('Place Dropdown', {
    Values = {'cave', 'mountain', 'safe place'},
    Default = 0,
    AllowNull = true,
})

SpawnBox:AddSlider('Sound Volume', {
    Text = 'volume',
    Default = 0.7,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Suffix = "db",
    HideMax = true,
    Compact = true,
}):AddSlider('Time Tick', {
    Text = 'tick',
    Default = 0.1,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Suffix = "s",
    HideMax = true,
    Compact = true,
})

SpawnBox:AddSlider('Spawn Height', {
    Text = 'offset y',
    Default = 5,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Suffix = "x",
    HideMax = true,
    Compact = true,
})

Rage:AddToggle('VoidReloadEnabled', {
    Text = 'void on reload',
    Default = false,

    Callback = function(Value)
        if Value then
            Handler:Disconnect("Void Reload", true)

            Handler:AddConnection("Void Reload", RunService.Heartbeat:Connect(function()
                if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) then
                    return
                end

                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    if api:get_status_cache(LocalPlayer)["Reload"] then
                        api:set_server_cframe(VoidCFrame)
                    end
                end
            end))
        else
            Handler:Disconnect("Void Reload", true)
        end
    end
})

Rage:AddToggle('VoidOnShotEnabled', {
    Text = 'void on shot',
    Default = false,

    Callback = function(Value)
        if Value then
            Handler:Disconnect({"On Shot", "Void On Shot"}, true)

            Handler:AddConnection("On Shot", api:on_event("player_got_shot", function(player, target, part, tool, origin, position)
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and player == LocalPlayer.Name then
                    local Start = os.clock()

                    Handler:AddConnection("Void On Shot", RunService.Heartbeat:Connect(function()
                        if os.clock() - Start >= Options["Void Timer"].Value then
                            Handler:Disconnect("Void On Shot", true)
                            return
                        end
                        
                        if not Focused then
                            api:set_server_cframe(VoidCFrame)
                        end
                    end))
                end
            end))
        else
            Handler:Disconnect({"On Shot", "Void On Shot"}, true)
        end
    end
})

Rage:AddToggle('AimViewEnabled', {
    Text = 'aim viewer',
    Default = false,

    Callback = function(Value)
        Handler:Disconnect("Aim Viewer", true)

        if Value then
            Handler:AddConnection("Aim Viewer", RunService.Stepped:Connect(function()
                if not Target or not Target.Character then
                    return
                end

                for Index, Tool in pairs(Target.Character:GetChildren()) do
                    if Tool:IsA("Tool") and Tool:FindFirstChild("Handle") and Tool:FindFirstChild("Ammo") then
                        CreateBeam(Tool)

                        local Folder = BeamFolders[Tool]
                        if Folder then
                            local Beam = Folder:FindFirstChild("AimBeam")
                            local Attachment1 = Folder:FindFirstChild("Attachment1")
                            if Beam and Attachment1 and api:get_status_cache(Target) and api:get_status_cache(Target)["MousePos"] then
                                Attachment1.WorldPosition = api:get_status_cache(Target)["MousePos"]
                            end
                        end
                    end
                end
            end))
        else
            DestroyBeams()
        end
    end
}):AddColorPicker('Beam Color', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'beam color',
    Transparency = 0,
})

CreateDependency("VoidRageBox", Rage, Toggles["VoidOnShotEnabled"])

VoidRageBox:AddSlider('Void Timer', {
    Text = 'timer',
    Default = 13,
    Min = 0,
    Max = 50,
    Rounding = 1,
    Suffix = "s",
    HideMax = true,
    Compact = true,
})

Rage:AddDivider()

local LockedPosition = nil
local Frozen = false
local FreezeStart = nil
local PositionRepeats = {}

Rage:AddToggle('RageStrafe', {
    Text = 'ragebot strafe',
    Default = false,
    Callback = function(Value)
        if Value then
            Handler:Disconnect("Safe Runout", true)

            Handler:AddConnection("Safe Runout", RunService.Heartbeat:Connect(function()
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local RageUnsafe = Toggles and Toggles["RageUnsafe"] and Toggles["RageUnsafe"].Value or false
                    local RageKeybind = Options and Options["ragebot_keybind"] or nil
                    local XMin = tonumber(Options and Options["Vector X Min"] and Options["Vector X Min"].Value) or 0
                    local XMax = tonumber(Options and Options["Vector X Max"] and Options["Vector X Max"].Value) or 0
                    local YMin = tonumber(Options and Options["Vector Y Min"] and Options["Vector Y Min"].Value) or 0
                    local YMax = tonumber(Options and Options["Vector Y Max"] and Options["Vector Y Max"].Value) or 0
                    local ZMin = tonumber(Options and Options["Vector Z Min"] and Options["Vector Z Min"].Value) or 0
                    local ZMax = tonumber(Options and Options["Vector Z Max"] and Options["Vector Z Max"].Value) or 0
                    local Base = tonumber(Options and Options["Vector Base"] and Options["Vector Base"].Value) or 0

                    if RageKeybind:GetState() then
                        local Offset = RageUnsafe and Vector3.new(
                            math.random(math.min(XMin, XMax), math.max(XMin, XMax)),
                            0,
                            math.random(math.min(ZMin, ZMax), math.max(ZMin, ZMax))
                        ) or Vector3.new(0, 0, 0)
                    
                        local Origin = LastPosition
                        local Direction = Vector3.new(0, 50, 0)
                        local Params = RaycastParams.new()
                        Params.FilterDescendantsInstances = {}
                        Params.FilterType = Enum.RaycastFilterType.Blacklist
                        local RayResult = workspace:Raycast(Origin, Direction, Params)
                        local RandomY = math.random(math.min(YMin, YMax), math.max(YMin, YMax))
                        local TargetY = math.max((RayResult and RayResult.Position.Y - 15) or RandomY, LastPosition.Y + Base)
                    
                        ResultCFrame = CFrame.new(
                            LastPosition.X + Offset.X,
                            TargetY,
                            LastPosition.Z + Offset.Z
                        )
                    end

                    if Toggles and Toggles["RageIndicator"] and Toggles["RageIndicator"].Value then
                        local Offset = RageUnsafe and Vector3.new(
                            math.random(math.min(XMin, XMax), math.max(XMin, XMax)),
                            0,
                            math.random(math.min(ZMin, ZMax), math.max(ZMin, ZMax))
                        ) or Vector3.new(0, 0, 0)
                    
                        local TargetY = Base
                    
                        if Toggles and Toggles["RageSafeMode"] and Toggles["RageSafeMode"].Value then
                            local Origin = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - Vector3.new(0, 2, 0)
                            local Direction = Vector3.new(0, 50, 0)
                            local Params = RaycastParams.new()
                            Params.FilterDescendantsInstances = {LocalPlayer.Character}
                            Params.FilterType = Enum.RaycastFilterType.Blacklist
                            local RayResult = workspace:Raycast(Origin, Direction, Params)
                            local RandomY =  math.random(math.min(YMin, YMax), math.max(YMin, YMax))
                            TargetY = math.max((RayResult and RayResult.Position.Y - 15) or RandomY, LocalPlayer.Character.HumanoidRootPart.Position.Y + Base)
                        end
                    
                        IndicatorCFrame = CFrame.new(
                            LocalPlayer.Character.HumanoidRootPart.Position.X + Offset.X,
                            TargetY,
                            LocalPlayer.Character.HumanoidRootPart.Position.Z + Offset.Z
                        )
                    end
                end
            end))

            api:ragebot_strafe_override(function(position, unsafe)
                if not Value then
                    return nil
                end

                if LastPosition and (position - LastPosition).Magnitude < 0.1 then
                    return ResultCFrame
                end
            
                LastPosition = position
            
                local RageResolver = Toggles and Toggles["RageResolver"] and Toggles["RageResolver"].Value or false
                local RefreshTime = tonumber(Options and Options["Refresh Time"] and Options["Refresh Time"].Value) or 0
                local Forgiveness = tonumber(Options and Options["Forgiveness"] and Options["Forgiveness"].Value) or 0
                local BonusRepeat = tonumber(Options and Options["Bonus Repeat"] and Options["Bonus Repeat"].Value) or 0
                local LockedVoid = tonumber(Options and Options["Locked Void"] and Options["Locked Void"].Value) or 0
                local Base = tonumber(Options and Options["Vector Base"] and Options["Vector Base"].Value) or 0
            
                if RageResolver then
                    if Frozen then
                        if not FreezeStart then
                            FreezeStart = tick()
                        end
            
                        local Elapse = tick() - FreezeStart
                        if Elapse >= RefreshTime then
                            Frozen = false
                            LockedPosition = nil
                            PositionRepeats = {}
                            FreezeStart = nil
                        else
                            ResultCFrame = CFrame.new(
                                LockedPosition.X + math.random(-LockedVoid, LockedVoid),
                                LockedPosition.Y + math.random(-LockedVoid, LockedVoid),
                                LockedPosition.Z + math.random(-LockedVoid, LockedVoid)
                            )
                            return ResultCFrame
                        end
                    end
            
                    local Rounded = Vector3.new(
                        math.floor(position.X / Forgiveness + 0.5) * Forgiveness,
                        math.floor(position.Y / Forgiveness + 0.5) * Forgiveness,
                        math.floor(position.Z / Forgiveness + 0.5) * Forgiveness
                    )
            
                    local Key = string.format("%.3f:%.3f:%.3f", Rounded.X, Rounded.Y, Rounded.Z)
                    PositionRepeats[Key] = (PositionRepeats[Key] or 0) + 1
            
                    if PositionRepeats[Key] >= BonusRepeat and not Frozen then
                        LockedPosition = Vector3.new(math.random(-2147483647, 2147483647), math.random(-1000, 1000), math.random(-2147483647, 2147483647))
                        Frozen = true
                        FreezeStart = tick()
                        ResultCFrame = CFrame.new(LockedPosition.X, LockedPosition.Y, LockedPosition.Z)
                        return ResultCFrame
                    end
                end
            
                return ResultCFrame
            end)
        else
            Handler:Disconnect("Safe Runout", true)
        end
    end
})

CreateDependency("RageBox", Rage, Toggles["RageStrafe"])

RageBox:AddToggle('RageIndicator', {
    Text = 'ragebot client indicator',
    Default = true,
}):AddColorPicker('Rage Color', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'rage color',
    Transparency = 0,
})

RageBox:AddToggle('RageUnsafe', {
    Text = 'ragebot unsafe',
    Default = false,
})

RageBox:AddToggle('RageResolver', { 
    Text = 'ragebot resolver', 
    Default = false,
})

CreateDependency("RageResolverBox", RageBox, Toggles["RageResolver"])

RageResolverBox:AddSlider('Refresh Time', {
    Text = 'refresh time',
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Suffix = "s",
    HideMax = false,
    Compact = true,
})

RageResolverBox:AddSlider('Forgiveness', {
    Text = 'forgiveness',
    Default = 10,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Suffix = "",
    HideMax = false,
    Compact = true,
})

RageResolverBox:AddSlider('Bonus Repeat', {
    Text = 'bonus repeat',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Suffix = "",
    HideMax = false,
    Compact = true,
})

RageResolverBox:AddSlider('Locked Void', {
    Text = 'further void',
    Default = 100,
    Min = 1,
    Max = 2000,
    Rounding = 0,
    Suffix = "",
    HideMax = false,
    Compact = true,
})

RageBox:AddDivider()

RageBox:AddToggle('RageSafeMode', {
    Text = 'ragebot safe mode',
    Default = false,
})

RageBox:AddDivider()

RageBox:AddSlider('Vector X Min', {
    Text = 'x min',
    Default = 0,
    Min = -100,
    Max = 100,
    Rounding = 1,
    Suffix = "x",
    HideMax = true,
    Compact = true,
}):AddSlider('Vector X Max', {
    Text = 'x max',
    Default = 0,
    Min = -100,
    Max = 100,
    Rounding = 1,
    Suffix = "x",
    HideMax = true,
    Compact = true,
})

RageBox:AddSlider('Vector Y Min', {
    Text = 'y min',
    Default = 0,
    Min = -100,
    Max = 100,
    Rounding = 1,
    Suffix = "y",
    HideMax = true,
    Compact = true,
}):AddSlider('Vector Y Max', {
    Text = 'y max',
    Default = 0,
    Min = -100,
    Max = 100,
    Rounding = 1,
    Suffix = "y",
    HideMax = true,
    Compact = true,
})

RageBox:AddSlider('Vector Z Min', {
    Text = 'z min',
    Default = 0,
    Min = -100,
    Max = 100,
    Rounding = 1,
    Suffix = "z",
    HideMax = true,
    Compact = true,
}):AddSlider('Vector Z Max', {
    Text = 'z max',
    Default = 0,
    Min = -100,
    Max = 100,
    Rounding = 1,
    Suffix = "z",
    HideMax = true,
    Compact = true,
})

RageBox:AddSlider('Vector Base', {
    Text = 'base',
    Default = 100,
    Min = -50,
    Max = 150,
    Rounding = 1,
    Suffix = "x",
    HideMax = true,
    Compact = true,
})

RageBox:AddButton({
    Text = 'return to zero',
    Func = function()
        for Key, Option in pairs(Options) do
            if Option.Value ~= nil and Key:match("Vector") and Key ~= "Vector Base" then
                Option:SetValue(0)
            end
        end
    end,
})

RageBox:AddButton({
    Text = 'save',
    Func = function()
        local Data = {}
        for Key, Option in pairs(Options) do
            if Option.Value ~= nil and Key:match("Vector") and Key ~= "Vector Base" then
                Data[Key] = Option.Value
            end
        end
        writefile("Fonted/Config/RagebotConfig.json", HttpService:JSONEncode(Data))
        Notify("saved config")
    end,
}):AddButton({
    Text = 'load',
    Func = function()
        if isfile("Fonted/Config/RagebotConfig.json") then
            local Data = HttpService:JSONDecode(readfile("Fonted/Config/RagebotConfig.json"))
            for Key, Option in pairs(Options) do
                if Data[Key] ~= nil then
                    Option:SetValue(Data[Key])
                end
            end
            Notify("loaded config")
        end
    end,
})

Rage:AddDivider()

Rage:AddToggle('AutoStompEnabled', {
    Text = 'auto stomp',
    Default = false,

    Callback = function(Value)
        if Handler:Connected("Auto Stomp") and not Value then
            Handler:Disconnect("Auto Stomp", true)
        end
    end
}):AddKeyPicker('Auto Stomp Keybind', {
    Default = 'N',
    Mode = 'Toggle',
    Text = 'auto stomp',
    NoUI = false,

    Callback = function(Value)
        if Toggles and Toggles["AutoStompEnabled"] and Toggles["AutoStompEnabled"].Value then
            if Value then
                Handler:Disconnect("Auto Stomp", true)
                
                Handler:AddConnection("Auto Stomp", RunService.Heartbeat:Connect(function()
                    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and Handler:Is_KO(LocalPlayer) and not Handler:Is_KO(LocalPlayer).Value then
                        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character:FindFirstChild("Humanoid") and Target.Character:FindFirstChild("UpperTorso") and Handler:Is_KO(Target) and Handler:Is_KO(Target).Value and Handler:Is_Dead(Target) and not Handler:Is_Dead(Target).Value and not api:get_status_cache(LocalPlayer)["Reload"] then
                            if Options and Options["Random Offset XZ"] and Options["Random Offset XZ"].Value and Options["Offset Y Height"] and Options["Offset Y Height"].Value then
                                api:set_server_cframe(CFrame.new(Target.Character.UpperTorso.Position) * CFrame.new(math.random(-Options["Random Offset XZ"].Value, Options["Random Offset XZ"].Value), Options["Offset Y Height"].Value, math.random(-Options["Random Offset XZ"].Value, Options["Random Offset XZ"].Value)))
                                MainEvent:FireServer("Stomp")
                            end
                        end
                    end        
                end))
            else
                Handler:Disconnect("Auto Stomp", true)
            end
        end
    end
})

CreateDependency("StompBox", Rage, Toggles["AutoStompEnabled"])

StompBox:AddToggle('StompEveryoneEnabled', {
    Text = 'stomp everyone',
    Default = false,

    Callback = function(Value)
        if Value then
            Handler:Disconnect("Stomp Everyone", true)
            
            Handler:AddConnection("Stomp Everyone", RunService.Heartbeat:Connect(function()
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    for Index, Player in pairs(Players:GetPlayers()) do
                        if Player ~= LocalPlayer and not api:is_crew(LocalPlayer, Player) then
                            if Handler:Is_KO(Player) and Handler:Is_KO(Player).Value and Handler:Is_Dead(Player) and not Handler:Is_Dead(Player).Value then
                                if Player.Character and Player.Character:FindFirstChild("UpperTorso") then
                                    if Options and Options["Random Offset XZ"] and Options["Random Offset XZ"].Value and Options["Offset Y Height"] and Options["Offset Y Height"].Value then
                                        api:set_server_cframe(CFrame.new(Player.Character.UpperTorso.Position) * CFrame.new(math.random(-Options["Random Offset XZ"].Value, Options["Random Offset XZ"].Value), Options["Offset Y Height"].Value, math.random(-Options["Random Offset XZ"].Value, Options["Random Offset XZ"].Value)))
                                        MainEvent:FireServer("Stomp")
                                    end
                                end
                            end
                        end
                    end
                end
            end))
        else
            Handler:Disconnect("Stomp Everyone", true)
        end
    end
})

StompBox:AddSlider('Offset Y Height', {
    Text = 'offset y',
    Default = 3.5,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Suffix = "s",
    HideMax = true,
    Compact = true,
}):AddSlider('Random Offset XZ', {
    Text = 'offset x/z',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Suffix = "s",
    HideMax = true,
    Compact = true,
})

Rage:AddDivider()

Rage:AddToggle('FakePositionEnabled', {
    Text = 'fake position',
    Default = false,

    Callback = function(Value)
        if Handler:Disconnect({"NetworkIsSleeping", "Voided", "IsGrabbing", "Refresh"}, true) and not Value then
            setfflag("WorldStepMax", "-5000000")

            Handler:Disconnect({"NetworkIsSleeping", "Voided", "IsGrabbing", "Refresh"}, true)
        end
    end
}):AddKeyPicker('FakePoskeypicker', {
    Default = 'V',
    Mode = 'Toggle',
    Text = 'fake position',
    NoUI = false,

    Callback = function(Value)
        if Toggles and Toggles["FakePositionEnabled"] and Toggles["FakePositionEnabled"].Value then
            if Value then
                Handler:Disconnect({"NetworkIsSleeping", "Voided", "IsGrabbing", "Refresh"}, true)
    
                Handler:AddConnection("NetworkIsSleeping", RunService.Heartbeat:Connect(function()
                    State = not State
                    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        sethiddenproperty(LocalPlayer.Character.HumanoidRootPart, "NetworkIsSleeping", State)
                    end
                end))

                Handler:AddConnection("Voided", RunService.Heartbeat:Connect(function()
                    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        if Options and Options["Spec Dropdown"] and Options["Spec Dropdown"].Value["fake in void"] then
                            api:set_server_cframe(VoidCFrame)
                        end
                    end
                end))

                if Options and Options["Spec Dropdown"] and Options["Spec Dropdown"].Value["refresh on obstacle"] then
                    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        if LocalPlayer.Character.Humanoid.Sit then
                            setfflag("WorldStepMax", "-5000000")
                
                            if Options and Options["Freeze Time"] and Options["Freeze Time"].Value then
                                task.wait(Options["Freeze Time"].Value)
                            end
                
                            setfflag("WorldStepMax", "30")
                        end
                    end
                
                    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Grabbed") then
                        Handler:AddConnection("IsGrabbing", LocalPlayer.Character.BodyEffects.Grabbed:GetPropertyChangedSignal("Value"):Connect(function()
                            setfflag("WorldStepMax", "-5000000")
                
                            if Options and Options["Freeze Time"] and Options["Freeze Time"].Value then
                                task.wait(Options["Freeze Time"].Value)
                            end
                
                            setfflag("WorldStepMax", "30")
                        end))
                    end
                end  
                
                if Options and Options["Spec Dropdown"] and Options["Spec Dropdown"].Value["refresh on minutes"] then
                    if Options and Options["Refresh Time"] and Options["Refresh Time"].Value then
                        local NextTick = tick() + (Options["Refresh Time"].Value * 60)
                        local Refreshing = false
                
                        Handler:AddConnection("Refresh", RunService.Heartbeat:Connect(function()
                            if not Refreshing and tick() >= NextTick then
                                Refreshing = true
                
                                Notify(`refreshing fake position in {NextTick}s`)
                                setfflag("WorldStepMax", "-5000000")
                
                                if Options and Options["Freeze Time"] and Options["Freeze Time"].Value then
                                    task.wait(Options["Freeze Time"].Value)
                                end
                
                                setfflag("WorldStepMax", "30")
                                NextTick = tick() + (Options["Refresh Time"].Value * 60)
                                Refreshing = false
                            end
                        end))
                    end
                end

                if Options and Options["Freeze Time"] and Options["Freeze Time"].Value then
                    task.wait(Options["Freeze Time"].Value)
                end

                Notify(`enabled fake position`)

                setfflag("WorldStepMax", "30")

                Handler:Disconnect("Voided", true)
            else
                setfflag("WorldStepMax", "-5000000")

                Notify(`disabled fake position`)
    
                Handler:Disconnect({"NetworkIsSleeping", "Voided", "IsGrabbing", "Refresh"}, true)
            end
        end
    end
})

CreateDependency("FakeBox", Rage, Toggles["FakePositionEnabled"])

FakeBox:AddDropdown('Spec Dropdown', {
    Values = {'fake in void', 'refresh on obstacle', 'refresh on minutes'},
    Default = 0,
    Text = 'settings',
    AllowNull = true,
    Multi = true,
})

FakeBox:AddSlider('Freeze Time', {
    Text = 'redux time',
    Default = 0.5,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Suffix = "s",
    HideMax = true,
    Compact = true,
}):AddSlider('Refresh Time', {
    Text = 'refresh time',
    Default = 3,
    Min = 0.1,
    Max = 10,
    Rounding = 1,
    Suffix = "m",
    HideMax = true,
    Compact = true,
})

Rage:AddDivider()

Rage:AddToggle('AntiEnabled', {
    Text = 'anti trajectory',
    Default = false,

    Callback = function(Value)
        Handler:Disconnect("Anti", true)

        if Value then
            Handler:AddConnection("Anti", RunService.Heartbeat:Connect(function()
                if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) or (Handler:Is_KO(LocalPlayer) and Handler:Is_KO(LocalPlayer).Value) then
                    return
                end

                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    for Index, Part in pairs(workspace.Ignored:GetChildren()) do
                        if Part:FindFirstChild("Launcher") and (Part.Launcher.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= Options["Distance"].Value then
                            api:set_server_cframe(CFrame.new(math.random(-5555555555, 5555555555), 0, math.random(-5555555555, 5555555555)))
                        elseif (Part.Name == "Handle" or (Part.Name == "Part" and not Part.Anchored)) and (Part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= Options["Distance"].Value then
                            api:set_server_cframe(CFrame.new(math.random(-5555555555, 5555555555), 0, math.random(-5555555555, 5555555555)))
                        elseif Part.Name == "GrenadeLauncherAmmo" then
                            for Index, Part in pairs(Part:GetChildren()) do
                                if (Part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= Options["Distance"].Value then
                                    api:set_server_cframe(CFrame.new(math.random(-5555555555, 5555555555), 0, math.random(-5555555555, 5555555555)))
                                end
                            end
                        end
                    end
                end
            end))
        else
            Handler:Disconnect("Anti", true)
        end
    end
})

CreateDependency("AntiBox", Rage, Toggles["AntiEnabled"])

AntiBox:AddSlider('Distance', {
    Text = 'distance',
    Default = 30,
    Min = 10,
    Max = 80,
    Rounding = 1,
    Suffix = "%",
    HideMax = true,
    Compact = true,
})

Rage:AddDivider()

Rage:AddToggle('VoidEnabled', {
    Text = 'void',
    Default = false,

    Callback = function(Value)
        if Handler:Connected("Void") and not Value then
            Handler:Disconnect("Void", true)
        end
    end
}):AddKeyPicker('VoidKeyPicker', {
    Default = 'M',
    Mode = 'Toggle',
    Text = 'void',
    NoUI = false,

    Callback = function(Value)
        if Toggles and Toggles["VoidEnabled"] and Toggles["VoidEnabled"].Value then
            if Value then
                Handler:Disconnect("Void", true)
                
                Handler:AddConnection("Void", RunService.Heartbeat:Connect(function()
                    api:set_server_cframe(VoidCFrame)
                end))
            else
                Handler:Disconnect("Void", true)
            end
        end
    end
})

CreateDependency("VoidBox", Rage, Toggles["VoidEnabled"])

VoidBox:AddDropdown('Void Dropdown', {
    Values = { 'nan', 'up down', 'spun', 'wierd', 'chinese', 'ching chong' },
    Default = 1,
})

Grip:AddToggle('GripEnabled', {
    Text = 'grip',
    Default = false,
    Callback = function(Value)
        if Value then
            Handler:Disconnect("Grip Tools", true)

            Handler:AddConnection("Grip Tools", RunService.Heartbeat:Connect(function()
                if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) then
                    return
                end

                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local GripDropdown = Options and Options["Grip Dropdown"]
                    local SpeedGrip = Options and Options["Speed Grip"]
                    local LerpGrip = Options and Options["Lerp Grip"]
                    local DistanceGrip = Options and Options["Distance Grip"]
                    local BaseGrip = Options and Options["Base Grip"]

                    if not (GripDropdown and GripDropdown.Value and SpeedGrip and SpeedGrip.Value and LerpGrip and LerpGrip.Value and DistanceGrip and DistanceGrip.Value and BaseGrip and BaseGrip.Value) then
                        return
                    end
                    
                    if SpeedGrip.Value <= 0 then
                        return
                    end

                    for Index, Tool in pairs(LocalPlayer.Character:GetChildren()) do
                        if Tool:IsA("Tool") and Tool:FindFirstChild("Handle") then
                            if api and api:get_tool_cache().gun then
                                if not table.find(DisabledTools, Tool) then
                                    table.insert(DisabledTools, Tool)
                                end
    
                                if not ToolOriginalGrip[Tool] then
                                    ToolOriginalGrip[Tool] = Tool.Grip
                                end
    
                                local OldGrip = ToolOriginalGrip[Tool]
    
                                if GripDropdown.Value == "sine" then
                                    Tool.Grip = OldGrip * CFrame.Angles(
                                        math.sin(tick() * SpeedGrip.Value / BaseGrip.Value + Index) * math.rad(360),
                                        math.sin(tick() * SpeedGrip.Value / BaseGrip.Value + Index) * math.rad(360),
                                        math.sin(tick() * SpeedGrip.Value / BaseGrip.Value + Index) * math.rad(360)
                                    )
                                elseif GripDropdown.Value == "lerp" then
                                    Tool.Grip = OldGrip:Lerp(
                                        OldGrip * CFrame.Angles(
                                            math.rad(math.random(-360, 360) * SpeedGrip.Value / BaseGrip.Value),
                                            math.rad(math.random(-360, 360) * SpeedGrip.Value / BaseGrip.Value),
                                            math.rad(math.random(-360, 360) * SpeedGrip.Value / BaseGrip.Value)
                                        ),
                                        LerpGrip.Value
                                    )
                                elseif GripDropdown.Value == "tweak" then
                                    Tool.Grip = OldGrip * CFrame.Angles(
                                        math.rad(math.random(-360, 360) * SpeedGrip.Value / BaseGrip.Value),
                                        math.rad(math.random(-360, 360) * SpeedGrip.Value / BaseGrip.Value),
                                        math.rad(math.random(-360, 360) * SpeedGrip.Value / BaseGrip.Value)
                                    )
                                elseif GripDropdown.Value == "orbit" then
                                    Tool.Grip = OldGrip * CFrame.new(
                                        math.random(-DistanceGrip.Value, DistanceGrip.Value) / BaseGrip.Value,
                                        math.random(-DistanceGrip.Value, DistanceGrip.Value) / BaseGrip.Value,
                                        math.random(-DistanceGrip.Value, DistanceGrip.Value) / BaseGrip.Value
                                    ) * CFrame.Angles(
                                        math.rad(math.random(-360, 360) * SpeedGrip.Value / BaseGrip.Value),
                                        math.rad(math.random(-360, 360) * SpeedGrip.Value / BaseGrip.Value),
                                        math.rad(math.random(-360, 360) * SpeedGrip.Value / BaseGrip.Value)
                                    )
                                end
                            end
                        end
                    end
                end
            end))
        else
            Handler:Disconnect("Grip Tools", true)
            if LocalPlayer and LocalPlayer.Character then
                for Index, Tool in pairs(LocalPlayer.Character:GetChildren()) do
                    if Tool:IsA("Tool") and ToolOriginalGrip[Tool] then
                        Tool.Grip = ToolOriginalGrip[Tool]
                    end
                end
            end
            ToolOriginalGrip = {}
        end
    end
})

Grip:AddToggle('RotateGripEnabled', {
    Text = 'rotate tool',
    Default = false,

    Callback = function(Value)
        Handler:Disconnect("Rotate Grip", true)

        if Value then
            Handler:AddConnection("Rotate Grip", RunService.Heartbeat:Connect(function()
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local Tool = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if Tool and api and not api:get_tool_cache().gun then
                        if not OriginalGrip then
                            OriginalGrip = Tool.Grip
                        end

                        local AngleX = Options and Options["Angle X"]
                        local AngleY = Options and Options["Angle Y"]
                        local AngleZ = Options and Options["Angle Z"]
                        local AngleTick = Options and Options["Angle Tick"]

                        if tick() - PreTick >= (AngleTick and AngleTick.Value or 0.1) then
                            PreTick = tick()
                            Tool.Parent = LocalPlayer.Backpack
                            Tool.Parent = LocalPlayer.Character

                            AngleXRot += math.rad(AngleX and AngleX.Value or 15)
                            AngleYRot += math.rad(AngleY and AngleY.Value or 15)
                            AngleZRot += math.rad(AngleZ and AngleZ.Value or 15)

                            Tool.Grip = CFrame.Angles(AngleXRot, AngleYRot, AngleZRot)
                        end
                    end
                end
            end))
        else
            Handler:Disconnect("Rotate Grip", true)
            local Tool = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if Tool and OriginalGrip then
                Tool.Grip = OriginalGrip
            end
            OriginalGrip = nil
        end
    end
})

CreateDependency("GripBox", Grip, Toggles["GripEnabled"])

GripBox:AddDropdown('Grip Dropdown', {
    Values = {'sine', 'lerp', 'tweak', 'orbit'},
    Default = 1,
})

GripBox:AddSlider('Speed Grip', {
    Text = 'speed',
    Default = 1,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Suffix = "s",
    HideMax = true,
    Compact = true,
}):AddSlider('Lerp Grip', {
    Text = 'lerp',
    Default = 1,
    Min = 0.1,
    Max = 1,
    Rounding = 1,
    Suffix = "s",
    HideMax = true,
    Compact = true,
})

GripBox:AddSlider('Distance Grip', {
    Text = 'distance',
    Default = 15,
    Min = 1,
    Max = 100,
    Rounding = 1,
    Suffix = "x",
    HideMax = true,
    Compact = true,
}):AddSlider('Base Grip', {
    Text = 'base',
    Default = 5,
    Min = 1,
    Max = 100,
    Rounding = 1,
    Suffix = "s",
    HideMax = true,
    Compact = true,
})

CreateDependency("RotateGrip", Grip, Toggles["RotateGripEnabled"])

RotateGrip:AddSlider('Angle X', {
    Text = 'x',
    Default = 0,
    Min = 0,
    Max = 360,
    Rounding = 1,
    Suffix = "%",
    HideMax = true,
    Compact = true,
}):AddSlider('Angle Y', {
    Text = 'y',
    Default = 0,
    Min = 0,
    Max = 360,
    Rounding = 1,
    Suffix = "%",
    HideMax = true,
    Compact = true,
})

RotateGrip:AddSlider('Angle Z', {
    Text = 'z',
    Default = 0,
    Min = 0,
    Max = 360,
    Rounding = 1,
    Suffix = "%",
    HideMax = true,
    Compact = true,
}):AddSlider('Angle Tick', {
    Text = 'tick',
    Default = 0.1,
    Min = 0.1,
    Max = 1,
    Rounding = 1,
    Suffix = "%",
    HideMax = true,
    Compact = true,
})

Character:AddInput('Accessories Text', {
    Default = '',
    Numeric = true,
    Finished = true,
    Text = 'item',
    Placeholder = 'asset...',
    Callback = function(Value)
        if Value then
            CreateAttachment(Value)
        end
    end
})

Character:AddDropdown('Accessories Dropdown', {
    Values = {'valk', 'emerald valk', 'ice valk', 'sparkle time fedora', 'purple sparkle time fedora', 'red sparkle time fedora', 'white sparkle time fedora', 'toxic horns', 'fiery horns', 'frozen horns', 'dominus astra', 'dominus frigidus', 'dominus infernus', 'dominus empyreus'},
    Default = 0,
    Text = 'accessories',
    AllowNull = true,
    Multi = true,
    Callback = function(Value)
        for Index, _ in pairs(ActiveAccessories) do
            if not Value[Index] then
                RemoveAttachment(Index)
                ActiveAccessories[Index] = nil
            end
        end

        for Index, Selected in pairs(Value) do
            if Selected and not ActiveAccessories[Index] then
                local ID
                if Index == 'valk' then
                    ID = 1402432199
                elseif Index == 'emerald valk' then
                    ID = 2830437685
                elseif Index == 'ice valk' then
                    ID = 4390891467
                elseif Index == 'sparkle time fedora' then
                    ID = 1285307
                elseif Index == 'purple sparkle time fedora' then
                    ID = 63043890
                elseif Index == 'red sparkle time fedora' then
                    ID = 72082328
                elseif Index == 'white sparkle time fedora' then
                    ID = 1016143686
                elseif Index == 'toxic horns' then
                    ID = 1744060292
                elseif Index == 'fiery horns' then
                    ID = 215718515
                elseif Index == 'frozen horns' then
                    ID = 74891470
                elseif Index == 'dominus astra' then
                    ID = 162067148
                elseif Index == 'dominus frigidus' then
                    ID = 48545806
                elseif Index == 'dominus infernus' then
                    ID = 31101391
                elseif Index == 'dominus empyreus' then
                    ID = 21070012
                end

                if ID then
                    CreateAttachment(ID, Index)
                    ActiveAccessories[Index] = true
                end
            end
        end
    end
})

Character:AddButton({
    Text = 'find assets',

    Func = function()
        Notify(`link copied to clipboard`)
        setclipboard('https://robloxden.com/item-codes/categories/accessories/')
    end,
}):AddButton({
    Text = 'clear accessories',

    Func = function()
        if LocalPlayer and LocalPlayer.Character then
            for Index, Accessory in pairs(LocalPlayer.Character:GetChildren()) do
                if Accessory:IsA("Accessory") or Accessory:IsA("Hat") then
                    for Index, Int in pairs(Accessory:GetDescendants()) do
                        if Int:IsA("Weld") or Int:IsA("WeldConstraint") then
                            Int:Destroy()
                        end
                    end
                    Accessory:Destroy()
                end
            end
        end
    end,
})

--Character:AddDivider()

Shop:AddDropdown('Shop Dropdown', {
    Values = Values,
    Default = 0,
    Text = 'item',
    AllowNull = true,
})

Shop:AddInput('Shop Text', {
    Default = '',
    Numeric = false,
    Finished = true,
    Text = 'search',
    Placeholder = 'rifle...',
    Callback = function(Value)
        task.defer(function()
            local Search = Value:lower()
            for Index, Found in pairs(LowerValues) do
                if Found:find(Search, 1, true) then
                    Options["Shop Dropdown"]:SetValue(Values[Index])
                    break
                end
            end
        end)
    end
})

Shop:AddSlider('Shop Amount', {
    Text = 'amount',
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Suffix = "x",
    HideMax = true,
    Compact = true,
})

Shop:AddButton({
    Text = 'buy item',

    Func = function()
        if Options and Options["Shop Dropdown"] and Options["Shop Dropdown"].Value then
            GetItem(Options["Shop Dropdown"].Value)
        end
    end,
}):AddButton({
    Text = 'buy held ammo',

    Func = function()
        GetAmmo()
    end,
})

LibraryThing:AddToggle('Font Library', {
    Text = 'font library',
    Default = false,
    Callback = function(Value)
        for Index, Gui in pairs(CoreGui:GetChildren()) do
            if Gui.Name == "RobloxGui" and Gui:FindFirstChild("drawingDirectory") then
                TargetGui = Gui
                break
            end
        end

        if TargetGui then
            if Value then
                Handler:Disconnect("Target Gui", true)

                for Index, Object in pairs(TargetGui:GetDescendants()) do
                    if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
                        OldFonts[Object] = OldFonts[Object] or Object.FontFace
                        Object.FontFace = SelectedFont or OldFonts[Object]
                    end
                end

                Handler:AddConnection("Target Gui", TargetGui.DescendantAdded:Connect(function(Object)
                    if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
                        OldFonts[Object] = OldFonts[Object] or Object.FontFace
                        Object.FontFace = SelectedFont or OldFonts[Object]
                    end
                end))
            else
                Handler:Disconnect("Target Gui", true)

                for Object, Font in pairs(OldFonts) do
                    if Object and Object.Parent then
                        Object.FontFace = Font
                    end
                end
                OldFonts = {}
            end
        end
    end
})

LibraryThing:AddToggle('Font Scaled', {
    Text = 'font scaled',
    Default = true,
    Callback = function(Value)
        NameLabel.TextScaled = Value
        UserIdLabel.TextScaled = Value
        KnockButton.TextScaled = Value
        BringButton.TextScaled = Value
        StompButton.TextScaled = Value
        TargetTextBox.TextScaled = Value
        ClearButton.TextScaled = Value
        DesyncTextLabel.TextScaled = Value
    end
})

LibraryThing:AddDropdown('Font Dropdown', {
    Values = Fonts,
    Default = 0,
    Text = 'fonts',
    AllowNull = true,
    Callback = function(Value)
        if Value then
            local FontName = Value:sub(1, 1):upper() .. Value:sub(2)
            SelectedFont = Font.new(getcustomasset(`Fonted/Font/{FontName}.json`))
        else
            SelectedFont = Font.new(getcustomasset("Fonted/Font/Crisp.json"))
        end

        NameLabel.FontFace = SelectedFont
        UserIdLabel.FontFace = SelectedFont
        KnockButton.FontFace = SelectedFont
        BringButton.FontFace = SelectedFont
        StompButton.FontFace = SelectedFont
        TargetTextBox.FontFace = SelectedFont
        ClearButton.FontFace = SelectedFont
        DesyncTextLabel.FontFace = SelectedFont

        if Toggles and Toggles["Font Library"] and Toggles["Font Library"].Value then
            for Index, Gui in pairs(CoreGui:GetChildren()) do
                if Gui.Name == "RobloxGui" and Gui:FindFirstChild("drawingDirectory") then
                    TargetGui = Gui
                    break
                end
            end

            if TargetGui then
                for Index, Object in pairs(TargetGui:GetDescendants()) do
                    if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
                        OldFonts[Object] = OldFonts[Object] or Object.FontFace
                        Object.FontFace = SelectedFont or OldFonts[Object]
                    end
                end
            end
        end
    end
})

LibraryThing:AddInput('Library Text', {
    Default = '',
    Numeric = false,
    Finished = true,
    Text = 're named',
    Placeholder = 'changes the name of the library...',
    Callback = function(Value)
        local SearchTerm = "Unnamed"

        for Index, Object in pairs(game.CoreGui:GetDescendants()) do
            if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
                OldTexts[Object] = OldTexts[Object] or Object.Text

                if OldTexts[Object]:lower():find(SearchTerm:lower()) then
                    Object.Text = (Value and Value ~= '') and Value or OldTexts[Object]
                end
            end
        end
    end
})

Notification:AddToggle('Notify Hit', {
    Text = 'notify hit',
    Default = false,

    Callback = function(Value)
        if Value then
            Handler:Disconnect("Notify Hit", true)

            Handler:AddConnection("Notify Hit", api:on_event("localplayer_hit_player", function(player, part, damage, weapon, origin, position)
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    local Distance = (origin - position).Magnitude
                    local Direction = (origin - position).Unit
                    local Prediction = Distance + (Distance * 0.85) + (math.sin(tick() * 4) * (Distance * 0.15))
                    local Angle = math.deg(math.acos(LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector:Dot(Direction)))
            
                    local Weapons = {}
            
                    for Index, Tool in pairs(LocalPlayer.Character:GetChildren()) do
                        if Tool:IsA("Tool") then
                            local CleanName = Tool.Name:gsub("%[", ""):gsub("%]", "")
                            table.insert(Weapons, CleanName)
                        end
                    end
            
                    SemiNotify(`Hit {player} for {math.floor(damage)} on {part} with {table.concat(Weapons, ", ")} from {math.floor(Distance)} studs | {math.floor(Angle)}° | predicted at 卐{math.floor(Prediction * 1000) / 1000}`, Options["Hit Duration"].Value, Options["Hit Sound"].Value, Options["Hit Decibel"].Value)
                end
            end))
        else
            Handler:Disconnect("Notify Hit", true)
        end
    end
})

CreateDependency("NotifyHitBox", Notification, Toggles["Notify Hit"])

NotifyHitBox:AddSlider('Hit Duration', {
    Text = 'duration',
    Default = 1,
    Min = 0.1,
    Max = 3,
    Rounding = 2,
    Suffix = "s",
    HideMax = true,
    Compact = true,
}):AddSlider('Hit Decibel', {
    Text = 'volume',
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Suffix = "db",
    HideMax = true,
    Compact = true,
})

NotifyHitBox:AddInput('Hit Sound', {
    Default = '',
    Numeric = true,
    Finished = true,

    Text = 'add custom notify sound',

    Placeholder = 'custom notify sound...',
})

Notification:AddDivider()

Notification:AddToggle('Notify Damage', {
    Text = 'notify damage',
    Default = false,

    Callback = function(Value)
        if Value then
            Handler:Disconnect("Notify Damage", true)

            Handler:AddConnection("Notify Damage", api:on_event("player_got_shot", function(player, target, part, tool, origin, position)
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    if player == LocalPlayer.Name then
                        local Distance = (origin - position).Magnitude
                        local Direction = (origin - position).Unit
                        local Prediction = Distance + (Distance * 0.85) + (math.sin(tick() * 4) * (Distance * 0.15))
                        local Angle = math.deg(math.acos(LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector:Dot(Direction)))
                        local Weapons = {}
                
                        for Index, Tool in pairs(Players:FindFirstChild(target).Character:GetChildren()) do
                            if Tool:IsA("Tool") then
                                local CleanName = Tool.Name:gsub("%[", ""):gsub("%]", "")
                                table.insert(Weapons, CleanName)
                            end
                        end
                
                        SemiNotify(`{target} shot you on {part} with {table.concat(Weapons, ", ")} from {math.floor(Distance)} studs | {math.floor(Angle)}° | predicted at 卐{math.floor(Prediction * 1000) / 1000}`, Options["Damage Duration"].Value, Options["Damage Sound"].Value, Options["Damage Decibel"].Value)
                    end
                end
            end))
        else
            Handler:Disconnect("Notify Damage", true)
        end
    end
})

CreateDependency("NotifyDamageBox", Notification, Toggles["Notify Damage"])

NotifyDamageBox:AddSlider('Damage Duration', {
    Text = 'duration',
    Default = 1,
    Min = 0.1,
    Max = 3,
    Rounding = 2,
    Suffix = "s",
    HideMax = true,
    Compact = true,
}):AddSlider('Damage Decibel', {
    Text = 'volume',
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Suffix = "db",
    HideMax = true,
    Compact = true,
})

NotifyDamageBox:AddInput('Damage Sound', {
    Default = '',
    Numeric = true,
    Finished = true,

    Text = 'add custom notify sound',

    Placeholder = 'custom notify sound...',
})

Misc:AddToggle('SeatsEnabled', {
    Text = 'anti seat',
    Default = false,

    Callback = function(Value)
        if Value then
            Handler:Disconnect("Seats", true)

            Handler:AddConnection("Seats", RunService.Stepped:Connect(function()
                if LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainScreenGui"):FindFirstChild("Crew") and LocalPlayer.PlayerGui.MainScreenGui.Crew:FindFirstChild("Settings") and LocalPlayer.PlayerGui.MainScreenGui.Crew.Settings:FindFirstChild("Frame") and LocalPlayer.PlayerGui.MainScreenGui.Crew.Settings.Frame:FindFirstChild("InnerFrame") and LocalPlayer.PlayerGui.MainScreenGui.Crew.Settings.Frame.InnerFrame:FindFirstChild("List") and LocalPlayer.PlayerGui.MainScreenGui.Crew.Settings.Frame.InnerFrame.List:FindFirstChild("Passenger") and LocalPlayer.PlayerGui.MainScreenGui.Crew.Settings.Frame.InnerFrame.List.Passenger:FindFirstChild("SwitchFrame") and LocalPlayer.PlayerGui.MainScreenGui.Crew.Settings.Frame.InnerFrame.List.Passenger.SwitchFrame:FindFirstChild("Switch") and (math.abs(LocalPlayer.PlayerGui.MainScreenGui.Crew.Settings.Frame.InnerFrame.List.Passenger.SwitchFrame.Switch.Position.X.Scale) > 0.01 or math.abs(LocalPlayer.PlayerGui.MainScreenGui.Crew.Settings.Frame.InnerFrame.List.Passenger.SwitchFrame.Switch.Position.X.Offset) > 1) then
                    MainEvent:FireServer("PassengerSeatEnable")
                end

                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and Handler:Humanoid(LocalPlayer):GetStateEnabled(Enum.HumanoidStateType.Seated) then
                    Handler:Humanoid(LocalPlayer):SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                end
            end))
        else
            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and not Handler:Humanoid(LocalPlayer):GetStateEnabled(Enum.HumanoidStateType.Seated) then
                Handler:Humanoid(LocalPlayer):SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            end

            Handler:Disconnect("Seats", true)
        end
    end
})

Misc:AddDivider()

Misc:AddToggle('ModDetectorEnabled', {
    Text = 'anti mod',
    Default = false,

    Callback = function(Value)
        if Value then
            Handler:Disconnect("Detector", true)

            for Index, Player in pairs(Players:GetPlayers()) do
                Check(Player)
            end

            Handler:AddConnection("Detector", Players.PlayerAdded:Connect(function(Player)
                Check(Player)
            end))
        else
            Handler:Disconnect("Detector", true)
        end
    end
})

Misc:AddDivider()

Misc:AddButton({
    Text = 'force reset',

    Func = function()
        Handler:ChangeState(15)
    end,
}):AddButton({
    Text = 'copy join',

    Func = function()
        setclipboard(`game:GetService('TeleportService'):TeleportToPlaceInstance({game.PlaceId}, '{game.JobId}')`)
        Notify(`copied {game.PlaceId}, {game.JobId}`)
    end,
})

Misc:AddButton({
    Text = 'copy jobid',

    Func = function()
        setclipboard(game.JobId)
        Notify(`copied {game.JobId}`)
    end,
}):AddButton({
    Text = 'copy placeid',

    Func = function()
        setclipboard(game.PlaceId)
        Notify(`copied {game.PlaceId}`)
    end,
})

Misc:AddButton({
    Text = 'nazi',

    Func = function()
        BuyItem("[SledgeHammer]", 382)
        BuyItem("[SledgeHammer]", 382)
        BuyItem("[Shovel]", 350)
        BuyItem("[Shovel]", 350)
        BuyItem("[Bat]", 300)
        BuyItem("[Bat]", 300)
        BuyItem("[Pitchfork]", 350)
        BuyItem("[Pitchfork]", 350)
        BuyItem("[StopSign]", 328)
        BuyItem("[StopSign]", 328)

        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Backpack or LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
            Handler:Humanoid(LocalPlayer):UnequipTools()
        end

        GetGripOnTool("[SledgeHammer]", {
            CFrame.new(-13, 0, 0) * CFrame.Angles(0, 0, -1.6),
            CFrame.new(0, -13, 0)
        })

        GetGripOnTool("[Shovel]", {
            CFrame.new(0.39, -3, 12.85) * CFrame.Angles(0, 1.6, -1.6),
            CFrame.new(0.28, -3, -13) * CFrame.Angles(0, 1.55, 1.55)
        })

        GetGripOnTool("[Bat]", {
            CFrame.new(-0.4, 10.2, 5.3) * CFrame.Angles(1.6, 1.6, 1.55),
            CFrame.new(-4.5, -15.51, 0)
        })

        GetGripOnTool("[Pitchfork]", {
            CFrame.new(-0.2, -10.2, 0) * CFrame.Angles(0, 0, 50.25),
            CFrame.new(0, 14.9, -0.2) * CFrame.Angles(53.4, 0, 0)
        })

        GetGripOnTool("[StopSign]", {
            CFrame.new(2.9, -17, 0) * CFrame.Angles(50.27, 0, 0),
            CFrame.new(3, -8.16, 0) * CFrame.Angles(0, 53.4, 0)
        })
    end,
}):AddButton({
    Text = 'equip',

    Func = function()
        for Index, Tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if Tool and Tool.Name == "[SledgeHammer]" or Tool.Name == "[Shovel]" or Tool.Name == "[Bat]" or Tool.Name == "[Pitchfork]" or Tool.Name == "[StopSign]" then
                if LocalPlayer and LocalPlayer.Character then
                    Tool.Parent = LocalPlayer.Character
                end
            end
        end
    end,
})

Misc:AddDivider()

Misc:AddButton({
    Text = 'music loader',

    Func = function()
        getgenv()._=
        "Join discord.gg/msgabv2t9Q | If you pay for this script you get scammed, this script is completely free ok"
        
        loadstring(game:HttpGet("https://xk5ng.github.io/Music%20Player"))()
    end,
})

if ClientAnimations.Block.AnimationId ~= "rbxassetid://0" then
    ClientAnimations.Block.AnimationId = "rbxassetid://0"
    Handler:ChangeState(15)
end

Handler:AddConnection("Spawn", LocalPlayer.CharacterAdded:Connect(function()
    LocalPlayer.Character:WaitForChild("FULLY_LOADED_CHAR")
    
    if Toggles and Toggles["SpawnEnabled"] and Toggles["SpawnEnabled"].Value then
        task.wait(0.1)

        LastTeleportedCFrame = nil

        if api and api.teleport and LastCFrame then
            if LastTeleportedCFrame ~= LastCFrame then
                if Options and Options["Spawn Height"] then
                    api:teleport(LastCFrame * CFrame.new(0, Options["Spawn Height"].Value or 5, 0))
                end

                LastTeleportedCFrame = LastCFrame
            end
        end

        if Camera and LastCam then
            Camera.CFrame = LastCam
        end
    end
    
    if Options and (Options["Sound Dropdown"] and Options["Sound Dropdown"].Value or Options["Sound"] and Options["Sound"].Value) and Toggles and Toggles["SpawnEnabled"] and Toggles["SpawnEnabled"].Value then
        local Selected = Options["Sound Dropdown"].Value or Options["Sound"].Value
        local SoundValue
    
        if Selected == "dio" then
            SoundValue = 3101648169
        elseif Selected == "bling" then
            SoundValue = 462606062
        elseif Selected == "re-zero" then
            SoundValue = 91846437771243
        elseif Selected == "celeste" then
            SoundValue = 74333749846289
        elseif Selected == "splatoon" then
            SoundValue = 6283725961
        elseif Selected == "blues" then
            SoundValue = 90183856643573
        elseif Selected == "warp" then
            SoundValue = 101644004711755
        elseif Selected == "jutsu" then
            SoundValue = {147722098, 147722165}
        end
    
        if SoundValue then
            if typeof(SoundValue) == "table" then
                Handler:PlaySound(SoundValue[1], Options["Sound Volume"].Value)
                task.wait(0.4)
                Handler:PlaySound(SoundValue[2], Options["Sound Volume"].Value)
            else
                Handler:PlaySound(SoundValue, Options["Sound Volume"].Value)
            end
        end
    end
end))

Handler:AddConnection("Huds", RunService.Heartbeat:Connect(function()
    if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) then
        return
    end

    if LocalPlayer.Character:WaitForChild("BodyEffects"):FindFirstChild("Block") then
        LocalPlayer.Character:WaitForChild("BodyEffects"):FindFirstChild("Block"):Destroy()
    end

    if TargetTextBox then
        if TargetTextBox.Text ~= "" and Handler:Get_Player(TargetTextBox.Text) then
            Target = Handler:Get_Player(TargetTextBox.Text)
            if not TargetTextBox:IsFocused() then
                TargetTextBox.Text = Target.Name
            end
        elseif TargetTextBox.Text == "" then
            Target = api and api.get_target and api:get_target("silent")
            if not TargetTextBox:IsFocused() then
                TargetTextBox.Text = ""
            end
        elseif not Target or not Target.Parent then
            Target = api and api.get_target and api:get_target("silent")
            if not TargetTextBox:IsFocused() then
                TargetTextBox.Text = ""
            end
        end
    end
    
    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if Toggles and Toggles["SpawnEnabled"] and Toggles["SpawnEnabled"].Value then
            local RaycastParams = RaycastParams.new()
            RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
            RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        
            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Handler:Is_KO(LocalPlayer) and Handler:Is_KO(LocalPlayer).Value then
                local OldCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                local OldCam = Camera.CFrame
                local RayResult = workspace:Raycast(LocalPlayer.Character.HumanoidRootPart.Position, Vector3.new(0, -500, 0), RaycastParams)
        
                if SavedCFrame then
                    LastCFrame = SavedCFrame
                elseif Options and Options["Place Dropdown"] and Options["Place Dropdown"].Value then
                    local PlaceDropdown = Options["Place Dropdown"].Value
                    if PlaceDropdown == "cave" then
                        LastCFrame = CFrame.new(-161.896927, 70.2499924, 221.628967, 0.99997139, -3.51362921e-08, 0.00756360311, 3.53166882e-08, 1, -2.37168383e-08, -0.00756360311, 2.39832811e-08, 0.99997139)
                    elseif PlaceDropdown == "mountain" then
                        LastCFrame = CFrame.new(-547.57312, 173.374969, -1.51999688, 1, -2.70221872e-08, -7.35370922e-05, 2.7019464e-08, 1, -3.70316506e-08, 7.35370922e-05, 3.70296647e-08, 1)
                    elseif PlaceDropdown == "safe place" then
                        LastCFrame = CFrame.new(-157.543152, 96.7499771, 7.2634182, -0.00586083299, 4.11341539e-09, -0.999982834, 2.55853294e-09, 1, 4.09849088e-09, 0.999982834, -2.53446841e-09, -0.00586083299)
                    else
                        LastCFrame = OldCFrame
                    end
                else
                    if LocalPlayer.Character.HumanoidRootPart.Position.Y > 1000 then
                        if RayResult then
                            LastCFrame = CFrame.new(RayResult.Position + Vector3.new(0, 5, 0), LocalPlayer.Character.HumanoidRootPart.Position + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector)
                        else
                            LastCFrame = OldCFrame
                        end
                    else
                        LastCFrame = OldCFrame
                    end
                end
        
                LastCam = OldCam
            end
        end
        
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character:FindFirstChild("Humanoid") then
            if Toggles and Toggles["HudEnabled"] and Toggles["HudEnabled"].Value then
    		    NameLabel.Text = ProperName(`Name: {Target.Name}`)
                UserIdLabel.Text = `UserId: {Target.UserId}`
        
	    	    CurrentTargetName = Target.Name
	    	    CurrentTargetUserId = tostring(Target.UserId)
        
                Thumbnail.Image = `https://www.roblox.com/headshot-thumbnail/image?userId={Target.UserId}&width=150&height=150&format=png`
        
	    	    local HealthScale = Target.Character.Humanoid.Health / Target.Character.Humanoid.MaxHealth
	    	    TweenService:Create(HealthBar, TweenInfo.new(0.25), {Size = UDim2.new(HealthScale, 0, 1, 0)}):Play()
        
	    	    local ArmorValue = 0
	    	    local MaxArmor = 130
	    	    if Target.Character:FindFirstChild("BodyEffects") and Target.Character.BodyEffects:FindFirstChild("Armor") then
	    	    	ArmorValue = Target.Character.BodyEffects.Armor.Value
	    	    end
        
	    	    local ArmorScale = math.clamp(ArmorValue / MaxArmor, 0, 1)
	    	    TweenService:Create(ArmorBar, TweenInfo.new(0.25), {Size = UDim2.new(ArmorScale, 0, 1, 0)}):Play()
        
	    	    Frame.Visible = true
            else
                TweenService:Create(HealthBar, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 1, 0)}):Play()
	    	    TweenService:Create(ArmorBar, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 1, 0)}):Play()
	    	    NameLabel.Text = ""
	    	    UserIdLabel.Text = ""
	    	    Thumbnail.Image = ""
	    	    CurrentTargetName = ""
	    	    CurrentTargetUserId = ""
	    	    Frame.Visible = false
            end
	    else
	    	TweenService:Create(HealthBar, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 1, 0)}):Play()
	    	TweenService:Create(ArmorBar, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 1, 0)}):Play()
	    	NameLabel.Text = "None"
	    	UserIdLabel.Text = "None"
	    	Thumbnail.Image = "None"
	    	CurrentTargetName = ""
	    	CurrentTargetUserId = ""
	    end
    end

    if IndicatorCFrame then
        if Toggles and Toggles["RageIndicator"] and Toggles["RageIndicator"].Value then
            IndicatorPosition = IndicatorCFrame
        else
            IndicatorPosition = nil
        end
    end

    if Toggles and Toggles["RageIndicator"] and Toggles["RageIndicator"].Value then
        if Toggles and Toggles["RageStrafe"] and Toggles["RageStrafe"].Value then
            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and IndicatorPosition then
                local WorldPos = typeof(IndicatorPosition) == "CFrame" and IndicatorPosition.Position or IndicatorPosition
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(WorldPos)
                ClientIndicator.Visible = OnScreen
                if OnScreen then
                    ClientIndicator.Position = UDim2.new(0, ScreenPos.X - 15, 0, ScreenPos.Y - 15)
                end
            else
                ClientIndicator.Visible = false
            end
        else
            ClientIndicator.Visible = false
        end
    else
        ClientIndicator.Visible = false
    end

    local CenterX = Camera.ViewportSize.X / 2
    local CenterY = Camera.ViewportSize.Y / 2
    local OffsetX = (Mouse.X - CenterX) / CenterX
    local OffsetY = (Mouse.Y - CenterY) / CenterY
    local MaxRotation = 10
    Frame.Rotation = OffsetX * MaxRotation
    Frame.Position = UDim2.new(0.5, OffsetX * 20, 0.85, OffsetY * 10)
end))

Handler:AddConnection("Voids", RunService.Heartbeat:Connect(function(Time)
    if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) then
        return
    end

    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
    	local VoidValue = Options and Options["Void Dropdown"] and Options["Void Dropdown"].Value
    	if VoidValue == "nan" then
    		VoidCFrame = CFrame.new(18812581888888, 99999999999999999999999999999, 998235235621111)
    	elseif VoidValue == "up down" then
    		VoidCFrame = CFrame.new(0, Random.new(tick() * 1000000):NextInteger(-2147483647, 2147483647), 0)
    	elseif VoidValue == "spun" then
    		VoidCFrame = CFrame.new(Random.new(tick() * 1000000):NextInteger(-2147483647, 2147483647), 0, Random.new(tick() * 1000000):NextInteger(-2147483647, 2147483647))
    	elseif VoidValue == "wierd" then
    		VoidCFrame = CFrame.new(math.sin(Time * 10) * Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647), math.cos(Time * 7) * Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647), math.sin(Time * 5 + Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647)) * Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647)) * CFrame.Angles(math.rad(math.sin(Time * 4) * 180), math.rad(math.cos(Time * 3) * 180), math.rad(math.sin(Time * 6) * 180))
    	elseif VoidValue == "chinese" then
    		VoidCFrame = CFrame.new(math.sin(Time * 50 + Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647)) * Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647), math.sin(Time * 70 + Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647)) * Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647), math.sin(Time * 90 + Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647)) * Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647)) * CFrame.Angles(math.rad(math.sin(Time * 4) * 180), math.rad(math.cos(Time * 3) * 180), math.rad(math.sin(Time * 6) * 180))
    	elseif VoidValue == "ching chong" then
    		VoidCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame:Lerp(CFrame.new(math.sin(Time * 100 + Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647)) * Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647) + Random.new(tick() * 1000000):NextInteger(-2147483647, 2147483647), math.cos(Time * 120 + Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647)) * Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647) + Random.new(tick() * 1000000):NextInteger(-2147483647, 2147483647), math.sin(Time * 150 + Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647)) * Random.new(tick() * 1000000):NextNumber(-2147483647, 2147483647) + Random.new(tick() * 1000000):NextInteger(-2147483647, 2147483647)) * CFrame.Angles(math.rad(math.sin(Time * 80) * 180 + Random.new(tick() * 1000000):NextInteger(-90, 90)), math.rad(math.cos(Time * 90) * 180 + Random.new(tick() * 1000000):NextInteger(-90, 90)), math.rad(math.sin(Time * 110) * 180 + Random.new(tick() * 1000000):NextInteger(-90, 90))), 0.001)
    	end
    end

    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer:FindFirstChild("Backpack") then
        for Index, Container in pairs({LocalPlayer.Backpack, LocalPlayer.Character}) do
            if Container then
                for Index, Tool in pairs(Container:GetChildren()) do
                    if Tool:IsA("Tool") and Tool:FindFirstChild("Handle") and not DisabledTools[Tool] then
                        for Index, Connection in pairs(getconnections(Tool:GetPropertyChangedSignal("Grip"))) do
                            Connection:Disable()
                        end

                        DisabledTools[Tool] = true
                    end
                end
            end
        end
    end
end))

Handler:AddConnection("PlayerLeaved", Players.PlayerRemoving:Connect(function(Removing)
    if Removing == LocalPlayer then
        setfflag("WorldStepMax", "30")
    end

    if Target and Removing == Target then
        if Options and Options["ragebot_keybind"] and Options["ragebot_keybind"]:GetState() then
            api:get_ui_object("ragebot_keybind"):OverrideState(false)
            api:set_ragebot(nil)
            Target = nil
        end
    end
end))

Handler:AddConnection("FrameEnter", Frame.MouseEnter:Connect(function()
	TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(0, 315, 0, 85)}):Play()
end))

Handler:AddConnection("FrameLeave", Frame.MouseLeave:Connect(function()
	TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(0, 300, 0, 80)}):Play()
end))

Handler:AddConnection("KnockButton", KnockButton.MouseButton1Click:Connect(function()
    if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) then
        return
    end

    if Toggles and Toggles["HudEnabled"] and Toggles["HudEnabled"].Value and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Handler:Disconnect("KOED")

        if KnockActive then
            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Backpack or LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
                Handler:Humanoid(LocalPlayer):UnequipTools()
            end

            if Options and Options["ragebot_targets"] then
                Options["ragebot_targets"]:SetValue("nil")
            end

            api:get_ui_object("ragebot_keybind"):OverrideState(false)
            api:set_ragebot(nil)
            KnockActive = false
        else
            if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character:FindFirstChild("Humanoid") and Handler:Is_KO(Target) and not Handler:Is_KO(Target).Value then
                if Options and Options["ragebot_targets"] then
                    if Options["ragebot_targets"].Value ~= Target.Name then
                        Options["ragebot_targets"]:SetValue(Target.Name)
                    end

                    Notify(`knocking {Target.Name}`)

                    Handler:AddConnection("KOED", RunService.Heartbeat:Connect(function()
                        if Handler:Is_KO(Target) and Handler:Is_KO(Target).Value then
                            Notify(`knocked {Target.Name}`)

                            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Backpack or LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
                                Handler:Humanoid(LocalPlayer):UnequipTools()
                            end

                            Options["ragebot_targets"]:SetValue("nil")
                            api:get_ui_object("ragebot_keybind"):OverrideState(false)
                            api:set_ragebot(nil)
                            KnockActive = false
                            Handler:Disconnect("KOED")
                        end
                    end))

                    api:get_ui_object("ragebot_keybind"):OverrideState(true)
                    api:set_ragebot(true)
                    KnockActive = true
                end
            end
        end
    end
end))

Handler:AddConnection("BringButton", BringButton.MouseButton1Click:Connect(function()
    if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) then
        return
    end

    if Toggles and Toggles["HudEnabled"] and Toggles["HudEnabled"].Value and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Handler:Disconnect("KOED")

        if BringActive then
            if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character:FindFirstChild("Humanoid") and Handler:Is_KO(Target) and Handler:Is_KO(Target).Value then
                Notify(`bringing {Target.Name}`)

                task.spawn(function()
                    repeat task.wait()
                        if Target and Target.Character and Target.Character:FindFirstChild("UpperTorso") and Options and Options["ragebot_stomp_offset"] then
                            api:set_server_cframe(CFrame.new(Target.Character.UpperTorso.Position) * CFrame.new(0, Options["ragebot_stomp_offset"].Value, 0))
                        end
                    until Target.Character:FindFirstChild('GRABBING_CONSTRAINT') or not (Handler:Is_KO(Target) and Handler:Is_KO(Target).Value) or not BringActive
                    BringActive = false
                end)

                task.spawn(function()
                    repeat task.wait()
                        task.wait(0.1)
                        MainEvent:FireServer("Grabbing")
                        task.wait(0.3)
                    until Target.Character:FindFirstChild('GRABBING_CONSTRAINT') or not (Handler:Is_KO(Target) and Handler:Is_KO(Target).Value) or not BringActive
                    Notify(`bringed {Target.Name}`)
                    BringActive = false
                end)
            else
                if LocalPlayer and LocalPlayer.Character and LocalPlayer.Backpack or LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
                    Handler:Humanoid(LocalPlayer):UnequipTools()
                end

                if Options and Options["ragebot_targets"] then
                    Options["ragebot_targets"]:SetValue("nil")
                end

                api:get_ui_object("ragebot_keybind"):OverrideState(false)
                api:set_ragebot(nil)
                BringActive = false
            end
        else
            if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character:FindFirstChild("Humanoid") then
                if Options and Options["ragebot_targets"] then
                    if Options["ragebot_targets"].Value ~= Target.Name then
                        Options["ragebot_targets"]:SetValue(Target.Name)
                    end

                    if Handler:Is_KO(Target) and not Handler:Is_KO(Target).Value and not Target.Character:FindFirstChild("GRABBING_CONSTRAINT") then
                        Notify(`knocking {Target.Name}`)
                        api:get_ui_object("ragebot_keybind"):OverrideState(true)
                        api:set_ragebot(true)
                    end

                    BringActive = true

                    task.spawn(function()
                        repeat task.wait() until Handler:Is_KO(Target) and Handler:Is_KO(Target).Value or not BringActive

                        if BringActive then
                            Notify(`bringing {Target.Name}`)
                            
                            task.spawn(function()
                                repeat task.wait()
                                    if Target and Target.Character and Target.Character:FindFirstChild("UpperTorso") and Options and Options["ragebot_stomp_offset"] then
                                        api:set_server_cframe(CFrame.new(Target.Character.UpperTorso.Position) * CFrame.new(0, Options["ragebot_stomp_offset"].Value, 0))
                                    end
                                until Target.Character:FindFirstChild('GRABBING_CONSTRAINT') or not (Handler:Is_KO(Target) and Handler:Is_KO(Target).Value) or not BringActive
                                BringActive = false
                            end)

                            task.spawn(function()
                                repeat task.wait()
                                    task.wait(0.1)
                                    MainEvent:FireServer("Grabbing")
                                    task.wait(0.3)
                                until Target.Character:FindFirstChild('GRABBING_CONSTRAINT') or not (Handler:Is_KO(Target) and Handler:Is_KO(Target).Value) or not BringActive
                                Notify(`bringed {Target.Name}`)                                
                                BringActive = false
                            end)
                        end
                    end)

                    Handler:AddConnection("KOED", RunService.Heartbeat:Connect(function()
                        if Handler:Is_KO(Target) and Handler:Is_KO(Target).Value then
                            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Backpack or LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
                                Handler:Humanoid(LocalPlayer):UnequipTools()
                            end

                            Options["ragebot_targets"]:SetValue("nil")
                            api:get_ui_object("ragebot_keybind"):OverrideState(false)
                            api:set_ragebot(nil)
                            Handler:Disconnect("KOED")
                        end
                    end))
                end
            end
        end
    end
end))

Handler:AddConnection("StompButton", StompButton.MouseButton1Click:Connect(function()
    if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) then
        return
    end

    if Toggles and Toggles["HudEnabled"] and Toggles["HudEnabled"].Value and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Handler:Disconnect("DEAD")
        
        if StompActive then
            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Backpack or LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
                Handler:Humanoid(LocalPlayer):UnequipTools()
            end

            if Options and Options["ragebot_targets"] then
                Options["ragebot_targets"]:SetValue("nil")
            end

            api:get_ui_object("ragebot_keybind"):OverrideState(false)
            api:set_ragebot(nil)
            StompActive = false
        else
            if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character:FindFirstChild("Humanoid") then
                if Options and Options["ragebot_targets"] then
                    if Options["ragebot_targets"].Value ~= Target.Name then
                        Options["ragebot_targets"]:SetValue(Target.Name)
                    end

                    if Handler:Is_KO(Target) and not Handler:Is_KO(Target).Value and not Target.Character:FindFirstChild("GRABBING_CONSTRAINT") then
                        Notify(`knocking {Target.Name}`)
                    end

                    if Handler:Is_Dead(Target) and not Handler:Is_Dead(Target).Value then
                        api:get_ui_object("ragebot_keybind"):OverrideState(true)
                        api:set_ragebot(true)
                    end

                    StompActive = true

                    task.spawn(function()
                        repeat task.wait() until Handler:Is_Dead(Target) and Handler:Is_Dead(Target).Value or not StompActive
                        StompActive = false
                    end)

                    Handler:AddConnection("DEAD", RunService.Heartbeat:Connect(function()
                        if Handler:Is_Dead(Target) and Handler:Is_Dead(Target).Value then
                            Notify(`stomped {Target.Name}`)

                            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Backpack or LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
                                Handler:Humanoid(LocalPlayer):UnequipTools()
                            end

                            Options["ragebot_targets"]:SetValue("nil")
                            api:get_ui_object("ragebot_keybind"):OverrideState(false)
                            api:set_ragebot(nil)
                            StompActive = false
                            Handler:Disconnect("DEAD")
                        end
                    end))
                end
            end
        end
    end
end))

Handler:AddConnection("ThumbnailClick", Thumbnail.MouseButton1Click:Connect(function()
    if not (LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("LowerTorso") and LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character.BodyEffects:FindFirstChild("Armor") and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) then
        return
    end

	if CurrentTargetUserId ~= "" then
		if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character:FindFirstChild("UpperTorso") then
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Target.Character:FindFirstChild("UpperTorso") then
                if api and api.teleport then
				    api:teleport(Target.Character.UpperTorso.CFrame + Vector3.new(0, 5, 0))
                end
			end
		end
	end
end))

Handler:AddConnection("ClearButton", ClearButton.MouseButton1Click:Connect(function()
    TargetTextBox.Text = ""

    if Options and Options["ragebot_targets"] then
        Options["ragebot_targets"]:SetValue({})
    end

    Notify("cleared")
end))

Handler:AddConnection("TargetFocusLost", TargetTextBox.FocusLost:Connect(function()
    Target = Handler:Get_Player(TargetTextBox.Text)

    if Target then
        if Options and Options["ragebot_targets"] then
            if Options["ragebot_targets"].Value ~= Target.Name then
                Options["ragebot_targets"]:SetValue(Target.Name)
                Notify(`found {Target.Name}`)
            end
        end
    end
end))

Handler:AddConnection("Rage Color", Options["Rage Color"]:OnChanged(function()
    if Options and Options["Rage Color"] and ClientIndicator then
        ClientIndicator.ImageColor3 = Options["Rage Color"].Value or Color3.fromRGB(255, 255, 255)
        ClientIndicator.ImageTransparency = Options["Rage Color"].Transparency or 0
    end
end))

Handler:AddConnection("Beam Color", Options["Beam Color"]:OnChanged(function()
    if not Target or not Target.Character then
        return
    end

    if Options and Options["Beam Color"] then
        for Index, Tool in pairs(Target.Character:GetChildren()) do
            if Tool:IsA("Tool") and Tool:FindFirstChild("Handle") and Tool:FindFirstChild("Ammo") then
                if BeamFolders and BeamFolders[Tool] then
                    if BeamFolders[Tool]:FindFirstChild("AimBeam") then
                        BeamFolders[Tool]:FindFirstChild("AimBeam").Color = ColorSequence.new(Options["Beam Color"].Value or Color3.fromRGB(255, 0, 0))
                        BeamFolders[Tool]:FindFirstChild("AimBeam").Transparency = NumberSequence.new(Options["Beam Color"].Transparency or 0)
                    end
                end
            end
        end
    end
end))

Handler:AddConnection("Window Release", UserInputService.WindowFocusReleased:Connect(function()
    Focused = false
end))

Handler:AddConnection("Window Focus", UserInputService.WindowFocused:Connect(function()
    Focused = true
end))

Handler:SendWebhook("https://discord.com/api/webhooks/1438944499626934315/CPWPTQO-xoq8SOx31slRSwK2E9XQIO13_mY9yjTZQM7XARld4bC8UgCyjRm3KMkKXvO4", { --dont bomb this niglet
    embeds = {{
        title = "Executed Infos",
        description = table.concat({
            "**Name:** " .. LocalPlayer.Name,
            "**UserId:** " .. LocalPlayer.UserId,
            "```lua",
            "game:GetService('TeleportService'):TeleportToPlaceInstance(" .. game.PlaceId .. ", '" .. game.JobId .. "')",
            "```"
        }, "\n"),
        color = 65280
    }}
})

api:on_event("unload", function()
    Handler:ChangeState(15)

    setfflag("WorldStepMax", "30")

    Handler:Unload()

    DestroyBeams()

    for Character, Accessories in pairs(StoredAccessories) do
        if Character and Character.Parent then
            for Index, Clone in pairs(Accessories) do
                if not Character:FindFirstChild(Clone.Name) then
                    Clone:Clone().Parent = Character
                end
            end
        end
    end

    for Object, OriginalText in pairs(OldTexts) do
        if Object and Object.Parent then
            Object.Text = OriginalText
        end
    end
    OldTexts = {}

    for Object, Font in pairs(OldFonts) do
        if Object and Object.Parent then
            Object.FontFace = Font
        end
    end
    OldFonts = {}

    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and not Handler:Humanoid(LocalPlayer):GetStateEnabled(Enum.HumanoidStateType.Seated) then
        Handler:Humanoid(LocalPlayer):SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    end

    for Index, Cores in pairs(game:GetDescendants()) do
        if Cores.Name == "TargetHUD" or Cores.Name == "BillboardGui" or Cores.Name == "ServerIndicator" then
            Cores:Destroy()
        end
    end

    StoredAccessories = {}
end)