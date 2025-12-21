-- This will be our main file 
local KeySystem = {}
KeySystem.Config = {
    APIEndpoint = "http://198.50.250.199:3000/check-key",
    DiscordInvite = "discord.gg/fEeDkQPNjP", -- AUGMENTED 
    WebhookURL = "https://discord.com/api/webhooks/1452193525860143186/_t_frM28SlQIJ1VyacJsJX4jXBnk8jAQ3j_IRLo1kjmiW3GuN2Cb9GzQRs-y_1RpALEK", 
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local function GetHWID()
    return game:GetService("RbxAnalyticsService"):GetClientId()
end

local function SendWebhook(title, description, color)
    if KeySystem.Config.WebhookURL == "" then return end
    pcall(function()
        local data = {
            ["embeds"] = {{
                ["title"] = title,
                ["description"] = description,
                ["color"] = color,
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
            }}
        }
        request({
            Url = KeySystem.Config.WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

function KeySystem:ValidateKey(key)
    local hwid = GetHWID()
    local success, result = pcall(function()
        local response = request({
            Url = self.Config.APIEndpoint,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                key = key,
                hwid = hwid,
                username = Players.LocalPlayer.Name
            })
        })
        return HttpService:JSONDecode(response.Body)
    end)
    
    if success and result then
        return result.valid, result.message or "Unknown error"
    end
    return false, "Connection failed"
end

function KeySystem:CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local TopBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Content = Instance.new("Frame")
    local HWIDLabel = Instance.new("TextLabel")
    local KeyInput = Instance.new("TextBox")
    local SubmitBtn = Instance.new("TextButton")
    local GetKeyBtn = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    
    ScreenGui.Name = "KeyAuth"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -175, 0.5, -125)
    Main.Size = UDim2.new(0, 350, 0, 250)
    Main.ClipsDescendants = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 4)
    MainCorner.Parent = Main
    
    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 4)
    TopBarCorner.Parent = TopBar
    
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Parent = TopBar
    TopBarFix.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Position = UDim2.new(0, 0, 0.7, 0)
    TopBarFix.Size = UDim2.new(1, 0, 0.3, 0)
    
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Key System"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    
    Content.Name = "Content"
    Content.Parent = Main
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 0, 0, 35)
    Content.Size = UDim2.new(1, 0, 1, -35)
    
    HWIDLabel.Name = "HWIDLabel"
    HWIDLabel.Parent = Content
    HWIDLabel.BackgroundTransparency = 1
    HWIDLabel.Position = UDim2.new(0, 15, 0, 10)
    HWIDLabel.Size = UDim2.new(1, -30, 0, 20)
    HWIDLabel.Font = Enum.Font.Gotham
    HWIDLabel.Text = "HWID: " .. GetHWID()
    HWIDLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
    HWIDLabel.TextSize = 10
    HWIDLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    KeyInput.Name = "KeyInput"
    KeyInput.Parent = Content
    KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    KeyInput.BorderSizePixel = 0
    KeyInput.Position = UDim2.new(0, 15, 0, 40)
    KeyInput.Size = UDim2.new(1, -30, 0, 35)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Enter Key"
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 12
    KeyInput.ClearTextOnFocus = false
    
    local KeyInputCorner = Instance.new("UICorner")
    KeyInputCorner.CornerRadius = UDim.new(0, 4)
    KeyInputCorner.Parent = KeyInput
    
    local KeyInputStroke = Instance.new("UIStroke")
    KeyInputStroke.Color = Color3.fromRGB(40, 40, 45)
    KeyInputStroke.Thickness = 1
    KeyInputStroke.Parent = KeyInput
    
    SubmitBtn.Name = "SubmitBtn"
    SubmitBtn.Parent = Content
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    SubmitBtn.BorderSizePixel = 0
    SubmitBtn.Position = UDim2.new(0, 15, 0, 85)
    SubmitBtn.Size = UDim2.new(1, -30, 0, 35)
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.Text = "Submit"
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.TextSize = 12
    SubmitBtn.AutoButtonColor = false
    
    local SubmitBtnCorner = Instance.new("UICorner")
    SubmitBtnCorner.CornerRadius = UDim.new(0, 4)
    SubmitBtnCorner.Parent = SubmitBtn
    
    GetKeyBtn.Name = "GetKeyBtn"
    GetKeyBtn.Parent = Content
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Position = UDim2.new(0, 15, 0, 130)
    GetKeyBtn.Size = UDim2.new(1, -30, 0, 30)
    GetKeyBtn.Font = Enum.Font.Gotham
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    GetKeyBtn.TextSize = 11
    GetKeyBtn.AutoButtonColor = false
    
    local GetKeyBtnCorner = Instance.new("UICorner")
    GetKeyBtnCorner.CornerRadius = UDim.new(0, 4)
    GetKeyBtnCorner.Parent = GetKeyBtn
    
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = Content
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 15, 0, 170)
    StatusLabel.Size = UDim2.new(1, -30, 0, 35)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.TextSize = 10
    StatusLabel.TextWrapped = true
    
    local function ButtonHover(button, normalColor, hoverColor)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
        end)
    end
    
    ButtonHover(SubmitBtn, Color3.fromRGB(70, 130, 200), Color3.fromRGB(80, 145, 215))
    ButtonHover(GetKeyBtn, Color3.fromRGB(50, 50, 60), Color3.fromRGB(60, 60, 70))
    
    GetKeyBtn.MouseButton1Click:Connect(function()
        setclipboard(self.Config.DiscordInvite)
        StatusLabel.Text = "Discord invite copied to clipboard"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
    end)
    
    SubmitBtn.MouseButton1Click:Connect(function()
        local key = KeyInput.Text:gsub("%s+", "")
        
        if key == "" then
            StatusLabel.Text = "Please enter a key"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        StatusLabel.Text = "Validating..."
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
        SubmitBtn.Text = "Checking..."
        
        local valid, message = self:ValidateKey(key)
        
        if valid then
            StatusLabel.Text = "Key validated"
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            SendWebhook(
                "Key Activated",
                "User: " .. Players.LocalPlayer.Name ..
                "\nHWID: " .. GetHWID() ..
                "\nKey: " .. key,
                65280
            )
            
            task.wait(0.5)
            TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.wait(0.3)
            ScreenGui:Destroy()
            return true
        else
            StatusLabel.Text = message
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            SubmitBtn.Text = "Submit"
            
            SendWebhook(
                "Failed Key Attempt",
                "User: " .. Players.LocalPlayer.Name ..
                "\nHWID: " .. GetHWID() ..
                "\nKey: " .. key ..
                "\nReason: " .. message,
                16711680
            )
            
            return false
        end
    end)
    
    Main.Position = UDim2.new(0.5, -175, 0.5, -150)
    Main.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 350, 0, 250),
        Position = UDim2.new(0.5, -175, 0.5, -125)
    }):Play()
    
    return ScreenGui
end

function KeySystem:Initialize()
    local gui = self:CreateUI()
    
    repeat task.wait(0.1) until not gui or not gui.Parent
    
    return true
end

if not KeySystem:Initialize() then
    return warn("Key system cancelled")
end

-- This is our main script below, above is key system. 

-- // Configuration
local CONFIG = {
    Decimals = 4,
    ValueText = "Value Is Now :",
    Window = {
        CheatName = "Augmented",
        Size = UDim2.new(0, 510, 0, 600)
    }
}

pcall(function()
    for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do
        v:Disable()
    end
end)

-- // Initialize Table
_G.GUI = _G.GUI or {}

-- // Load Library
local Clock = os.clock()
local success, result = pcall(function()
    local GameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/more-more-more/cred/refs/heads/main/tokyo.lua"))({
        cheatname = CONFIG.Window.CheatName,
        gamename = GameInfo.Name .. " - " .. game.PlaceId
    })
end)

if not success or not result then
    warn("Failed to load Tokyo library:", result)
    return
end

_G.GUI.Library = result
if not pcall(function() _G.GUI.Library:init() end) then return warn("Failed to initialize library") end

local windowSuccess, Window1 = pcall(function()
    local GameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    return _G.GUI.Library.NewWindow({
        title = CONFIG.Window.CheatName .. " | " .. GameInfo.Name,
        size = CONFIG.Window.Size
    })
end)

if not windowSuccess then return warn("Failed to create window") end
_G.GUI.Window1 = Window1


-- Load Arrows Module
local ArrowsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/more-more-more/cred/refs/heads/main/arrows.lua"))()

-- // Load Radar Module
local RadarModule = {}

function RadarModule:Enable()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/more-more-more/FXT/refs/heads/main/exploits/radar.lua"))()
    end)
end

function RadarModule:Disable()
    if _G.RadarConnections then
        for _, conn in pairs(_G.RadarConnections) do
            pcall(function() conn:Disconnect() end)
        end
    end
    if _G.RadarDrawings then
        for _, drawing in pairs(_G.RadarDrawings) do
            pcall(function() drawing:Remove() end)
        end
    end
    _G.RadarConnections = {}
    _G.RadarDrawings = {}
end

function RadarModule:SetSize(value)
    if _G.RadarInfo then
        _G.RadarInfo.Radius = value
    end
end

function RadarModule:SetRange(value)
    if _G.RadarInfo then
        _G.RadarInfo.Scale = 500 / value
    end
end

-- // Main GUI

local ok, err = pcall(function()
    -- Tabs
    Main = Window1:AddTab("  Main  ")
    Visuals = Window1:AddTab("  Visuals  ")
    Movement = Window1:AddTab("  Movement  ")
    Misc = Window1:AddTab("  Misc  ")
    SettingsTab = _G.GUI.Library:CreateSettingsTab(Window1)

    -- Main Sections
    Camlock_Activation = Main:AddSection("Activation",1)
    Camlock_Smoothing = Main:AddSection("Smoothing",1)
    Camlock_Prediction = Main:AddSection("Prediction",1)
    Camlock_Wall_Flag = Main:AddSection("Wall Check",2)
    Camlock_Knock_Flag = Main:AddSection("Knock Check",2)
    Camlock_Crew_Flag = Main:AddSection("Crew Check",2)
    Camlock_Distance_Flag = Main:AddSection("Distance Check",2)
    Camlock_Whitelist_Flag = Main:AddSection("Whitelist",2)

    -- Activation
    Camlock_Activation:AddToggle({text="Camlock",tooltip="Enables camlock",flag="Camlock_Enabled",state=false,risky=false,callback=function(v) end}):AddBind({text="Camlock",tooltip="Keybind for camlock",bind=Enum.KeyCode.Q,mode="toggle",flag="Camlock_Keybind",callback=function(v) _G.GUI.Library.options.Camlock_Enabled:SetState(v) end})
    Camlock_Activation:AddList({text="Mode",tooltip="Camlock activation mode",flag="Camlock_Mode",values={"Toggle","Always","Hold"},callback=function()end})
    Camlock_Activation:AddToggle({text="Sticky Aim",tooltip="Stops from constantly searching for new targets",flag="Camlock_Sticky_Aim",state=false,risky=false,callback=function()end})
    Camlock_Activation:AddSlider({text="FOV",tooltip="Field of View",flag="Camlock_FOV",min=30,max=1000,increment=1,value=80,callback=function()end})
    Camlock_Activation:AddList({text="Search Mode",tooltip="Method of finding targets",flag="Camlock_Search_Mode",values={"2D","3D"},callback=function()end})

    -- Smoothing
    Camlock_Smoothing:AddToggle({text="Enabled",tooltip="Enable camera smoothing",flag="Camlock_Smoothing_Enabled",state=false,risky=false,callback=function()end})
    Camlock_Smoothing:AddList({text="Method",tooltip="Smoothing method",flag="Camlock_Smoothing_Method",values={"Lerp","Tween"},callback=function()end})
    Camlock_Smoothing:AddSlider({text="Lerp Amount",tooltip="Percentage gained each frame",flag="Camlock_Lerp_Amount",min=1,max=50,increment=1,value=5,callback=function()end})
    Camlock_Smoothing:AddSlider({text="Tween Time",tooltip="Time taken to tween the camera (centiseconds)",flag="Camlock_Tween_Time",min=1,max=20,increment=1,value=7,callback=function()end})

    -- Prediction
    Camlock_Prediction:AddList({text="Type",tooltip="Prediction type",flag="Camlock_Prediction_Method",values={"MoveDirection","Velocity"},callback=function()end})
    Camlock_Prediction:AddSlider({text="X",flag="Camlock_Prediction_X",min=0,max=20,increment=1,value=0,callback=function()end})
    Camlock_Prediction:AddSlider({text="Y",flag="Camlock_Prediction_Y",min=0,max=20,increment=1,value=0,callback=function()end})
    Camlock_Prediction:AddSlider({text="Z",flag="Camlock_Prediction_Z",min=0,max=20,increment=1,value=0,callback=function()end})

    -- Wall, Knock, Crew, Distance, Whitelist
    Camlock_Wall_Flag:AddToggle({text="Enabled",tooltip="Wall check",flag="Camlock_Wall_Enabled",state=false,risky=false,callback=function()end})
    Camlock_Wall_Flag:AddBind({text="Ignore Wall",bind=Enum.KeyCode.V,mode="toggle",flag="Camlock_Wall_Ignore_Keybind",callback=function(v) _G.GUI.Library.options.Camlock_Wall_Enabled:SetState(v) end})
    Camlock_Wall_Flag:AddList({text="Start Ray From",flag="Camlock_Wall_Start",values={"Camera","Character"},callback=function()end})

    Camlock_Knock_Flag:AddToggle({text="Enabled",flag="Camlock_Knock_Enabled",state=false,risky=false,callback=function()end})
    Camlock_Crew_Flag:AddToggle({text="Enabled",flag="Camlock_Crew_Enabled",state=false,risky=false,callback=function()end})

    Camlock_Distance_Flag:AddToggle({text="Enabled",flag="Camlock_Distance_Enabled",state=false,risky=false,callback=function()end})
    Camlock_Distance_Flag:AddSlider({text="Distance",flag="Camlock_Distance_Value",min=10,max=2000,increment=1,value=100,callback=function()end})

    Camlock_Whitelist_Flag:AddToggle({text="Enabled",flag="Camlock_Whitelist_Enabled",state=false,risky=false,callback=function()end})
    Camlock_Whitelist_Flag:AddBind({text="Add/Remove Whitelist",bind=Enum.KeyCode.Z,mode="toggle",flag="Camlock_Whitelist_Keybind",callback=function(v) end})

    -- Visuals Sections
    Visuals_Arrows = Visuals:AddSection("Arrows",1)
    Visuals_ESP = Visuals:AddSection("ESP",1)
    Visuals_Radar = Visuals:AddSection("Radar",1)
    Visuals_Corners = Visuals:AddSection("Corners",2)
    Visuals_Chams = Visuals:AddSection("Chams",2)
    Visuals_Skeletons = Visuals:AddSection("Skeletons",2)
    Visuals_ViewTracer = Visuals:AddSection("View Tracer",2)

    -- Arrows
    Visuals_Arrows:AddToggle({text = "Enabled", tooltip = "Shows arrows pointing to offscreen players", flag = "Visuals_Arrows_Enabled", state = false, risky = false, callback = function(v) if v then ArrowsModule:Enable() else ArrowsModule:Disable() end end }):AddBind({text = "Arrows", tooltip = "Toggles arrows", bind = Enum.KeyCode.H, mode = "toggle", flag = "Visuals_Arrows_Keybind", callback = function(v) _G.GUI.Library.options.Visuals_Arrows_Enabled:SetState(v) end})
    Visuals_Arrows:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for arrows", flag = "Visuals_Arrows_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_Arrows:AddSlider({text = "Arrow Size", tooltip = "Size of the offscreen arrows", flag = "Visuals_Arrow_Size", min = 5, max = 30, increment = 1, value = 15, callback = function(v) end})
    Visuals_Arrows:AddSlider({text = "Radius", tooltip = "Distance from screen center", flag = "Visuals_Arrow_Radius", min = 20, max = 300, increment = 1, value = 150, callback = function(v) end})

    -- ESP
    Visuals_ESP:AddToggle({text = "Enabled", tooltip = "Shows ESP on players", flag = "Visuals_ESP_Enabled", state = false, risky = false, callback = function(v) end}):AddBind({text = "ESP", tooltip = "Toggles ESP", bind = Enum.KeyCode.J, mode = "toggle", flag = "Visuals_ESP_Keybind", callback = function(v) _G.GUI.Library.options.Visuals_ESP_Enabled:SetState(v) end})
    Visuals_ESP:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for ESP", flag = "Visuals_ESP_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_ESP:AddToggle({text = "Names", tooltip = "Displays player names", flag = "Visuals_ESP_Names", state = false, risky = false, callback = function(v) end})
    Visuals_ESP:AddToggle({text = "Boxes", tooltip = "Draws a box around each player", flag = "Visuals_ESP_Boxes", state = false, risky = false, callback = function(v) end})
    Visuals_ESP:AddToggle({text = "Health Bar", tooltip = "Displays player's health", flag = "Visuals_ESP_HealthBar", state = false, risky = false, callback = function(v) end})

    -- Radar
    Visuals_Radar:AddToggle({text = "Enabled", tooltip = "Displays a radar UI", flag = "Visuals_Radar_Enabled", state = false, risky = false, callback = function(v) if v then RadarModule:Enable() else RadarModule:Disable() end end}):AddBind({text = "Radar", tooltip = "Toggles radar", bind = Enum.KeyCode.K, mode = "toggle", flag = "Visuals_Radar_Keybind", callback = function(v) _G.GUI.Library.options.Visuals_Radar_Enabled:SetState(v) end})
    Visuals_Radar:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for radar", flag = "Visuals_Radar_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_Radar:AddSlider({text = "Size", tooltip = "Size of the radar", flag = "Visuals_Radar_Size", min = 50, max = 300, increment = 1, value = 100, callback = function(v) RadarModule:SetSize(v) end})
    Visuals_Radar:AddSlider({text = "Range", tooltip = "Radar detection range", flag = "Visuals_Radar_Range", min = 100, max = 2000, increment = 50, value = 500, callback = function(v) RadarModule:SetRange(v) end})

    -- Corners
    Visuals_Corners:AddToggle({text = "Enabled", tooltip = "Draws corner-style ESP boxes", flag = "Visuals_Corners_Enabled", state = false, risky = false, callback = function(v) end}):AddBind({text = "Corners", tooltip = "Toggles corners", bind = Enum.KeyCode.L, mode = "toggle", flag = "Visuals_Corners_Keybind", callback = function(v) _G.GUI.Library.options.Visuals_Corners_Enabled:SetState(v) end})
    Visuals_Corners:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for corners", flag = "Visuals_Corners_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_Corners:AddSlider({text = "Length", tooltip = "Corner line length", flag = "Visuals_Corner_Length", min = 1, max = 20, increment = 1, value = 8, callback = function(v) end})
    Visuals_Corners:AddSlider({text = "Thickness", tooltip = "Corner line thickness", flag = "Visuals_Corner_Thickness", min = 1, max = 5, increment = 1, value = 2, callback = function(v) end})

    -- Chams
    Visuals_Chams:AddToggle({text = "Enabled", tooltip = "Highlights player models", flag = "Visuals_Chams_Enabled", state = false, risky = false, callback = function(v) end}):AddBind({text = "Chams", tooltip = "Toggles chams", bind = Enum.KeyCode.M, mode = "toggle", flag = "Visuals_Chams_Keybind", callback = function(v) _G.GUI.Library.options.Visuals_Chams_Enabled:SetState(v) end})
    Visuals_Chams:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for chams", flag = "Visuals_Chams_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_Chams:AddToggle({text = "Team Check", tooltip = "Hides chams on teammates", flag = "Visuals_Chams_TeamCheck", state = false, risky = false, callback = function(v) end})
    Visuals_Chams:AddList({text = "Render Mode", tooltip = "Cham rendering method", flag = "Visuals_Chams_Render", values = {"Highlight", "Adornment"}, callback = function(v) end})

    -- Skeletons
    Visuals_Skeletons:AddToggle({text = "Enabled", tooltip = "Draws skeletons on players", flag = "Visuals_Skeletons_Enabled", state = false, risky = false, callback = function(v) end}):AddBind({text = "Skeletons", tooltip = "Toggles skeletons", bind = Enum.KeyCode.N, mode = "toggle", flag = "Visuals_Skeletons_Keybind", callback = function(v) _G.GUI.Library.options.Visuals_Skeletons_Enabled:SetState(v) end})
    Visuals_Skeletons:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for skeletons", flag = "Visuals_Skeletons_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_Skeletons:AddToggle({text = "Team Check", tooltip = "Hides skeletons on teammates", flag = "Visuals_Skeletons_TeamCheck", state = false, risky = false, callback = function(v) end})
    Visuals_Skeletons:AddSlider({text = "Thickness", tooltip = "Skeleton line thickness", flag = "Visuals_Skeletons_Thickness", min = 1, max = 5, increment = 1, value = 2, callback = function(v) end})

    -- View Tracer
    Visuals_ViewTracer:AddToggle({text = "Enabled", tooltip = "Draws lines indicating view direction", flag = "Visuals_ViewTracer_Enabled", state = false, risky = false, callback = function(v) end}):AddBind({text = "View Tracer", tooltip = "Toggles view tracer", bind = Enum.KeyCode.B, mode = "toggle", flag = "Visuals_ViewTracer_Keybind", callback = function(v) _G.GUI.Library.options.Visuals_ViewTracer_Enabled:SetState(v) end})
    Visuals_ViewTracer:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for view tracer", flag = "Visuals_ViewTracer_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_ViewTracer:AddToggle({text = "Team Check", tooltip = "Hides tracers on teammates", flag = "Visuals_ViewTracer_TeamCheck", state = false, risky = false, callback = function(v) end})
    Visuals_ViewTracer:AddSlider({text = "Length", tooltip = "View tracer length", flag = "Visuals_ViewTracer_Length", min = 50, max = 1000, increment = 10, value = 300, callback = function(v) end})

    -- Movement sections
    Movement_Flight = Movement:AddSection("Flight",1)
    Movement_Spin = Movement:AddSection("Spin",1)
    Movement_Teleport = Movement:AddSection("Teleport",1)
    Movement_Cframe = Movement:AddSection("Cframe",2)
    Movement_Orbit = Movement:AddSection("Orbit",2)
    Movement_Noclip = Movement:AddSection("Noclip",2)

    -- Flight
    Movement_Flight:AddToggle({text = "Enabled", tooltip = "Toggle flight", flag = "Movement_Flight_Enabled", state = false, risky = false, callback = function(v) end}):AddBind({text = "Flight", tooltip = "Toggles Flight", bind = Enum.KeyCode.F, mode = "toggle", flag = "Movement_Flight_Keybind", callback = function(v) if _G.GUI and _G.GUI.Library and _G.GUI.Library.options and _G.GUI.Library.options.Movement_Flight_Enabled then _G.GUI.Library.options.Movement_Flight_Enabled:SetState(v) end end})
    Movement_Flight:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for flight", flag = "Movement_Flight_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Movement_Flight:AddSlider({text = "Speed", tooltip = "Flight speed", flag = "Movement_Flight_Speed", min = 10, max = 300, increment = 5, value = 50, callback = function(v) end})

    -- Spin
    Movement_Spin:AddToggle({text = "Enabled", tooltip = "Spin your character", flag = "Movement_Spin_Enabled", state = false, risky = false, callback = function(v) end}):AddBind({text = "Spin", bind = Enum.KeyCode.G, mode = "toggle", flag = "Movement_Spin_Keybind", callback = function(v) if _G.GUI and _G.GUI.Library and _G.GUI.Library.options and _G.GUI.Library.options.Movement_Spin_Enabled then _G.GUI.Library.options.Movement_Spin_Enabled:SetState(v) end end})
    Movement_Spin:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for spin", flag = "Movement_Spin_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Movement_Spin:AddSlider({text = "Speed", tooltip = "Spin speed", flag = "Movement_Spin_Speed", min = 1, max = 50, increment = 1, value = 10, callback = function(v) end})

    -- Teleport
    Movement_Teleport:AddList({text = "Target Player", tooltip = "Select player to teleport to", flag = "Movement_Teleport_Player", values = {"None"}, callback = function(v) end})
    Movement_Teleport:AddButton({text = "Teleport to Player", tooltip = "Teleport to selected player", callback = function() if not _G.GUI or not _G.GUI.Library or not _G.GUI.Library.options or not _G.GUI.Library.options.Movement_Teleport_Player then return end local targetName = _G.GUI.Library.options.Movement_Teleport_Player.selected if not targetName or targetName == "" or targetName == "None" then return end local Player = game:GetService("Players").LocalPlayer local Target = game:GetService("Players"):FindFirstChild(targetName) if Target and Target.Character then local Character = Player.Character if Character then local HRP = Character:FindFirstChild("HumanoidRootPart") local TargetHRP = Target.Character:FindFirstChild("HumanoidRootPart") if HRP and TargetHRP then HRP.CFrame = TargetHRP.CFrame * CFrame.new(0, 0, 3) end end end end})
    
    -- Cframe Speed
    Movement_Cframe:AddToggle({text = "Enabled", tooltip = "Move using CFrame", flag = "Movement_Cframe_Enabled", state = false, risky = false, callback = function(v) end}):AddBind({text = "CFrame Speed", bind = Enum.KeyCode.C, mode = "toggle", flag = "Movement_Cframe_Keybind", callback = function(v) if _G.GUI and _G.GUI.Library and _G.GUI.Library.options and _G.GUI.Library.options.Movement_Cframe_Enabled then _G.GUI.Library.options.Movement_Cframe_Enabled:SetState(v) end end})
    Movement_Cframe:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for cframe", flag = "Movement_Cframe_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Movement_Cframe:AddSlider({text = "Speed", tooltip = "CFrame speed", flag = "Movement_Cframe_Speed", min = 0.1, max = 5, increment = 0.1, value = 0.5, callback = function(v) end})

    -- Orbit
    Movement_Orbit:AddToggle({text = "Enabled", tooltip = "Orbit around players", flag = "Movement_Orbit_Enabled", state = false, risky = false, callback = function(v) end}):AddBind({text = "Orbit", bind = Enum.KeyCode.O, mode = "toggle", flag = "Movement_Orbit_Keybind", callback = function(v) if _G.GUI and _G.GUI.Library and _G.GUI.Library.options and _G.GUI.Library.options.Movement_Orbit_Enabled then _G.GUI.Library.options.Movement_Orbit_Enabled:SetState(v) end end})
    Movement_Orbit:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for orbit", flag = "Movement_Orbit_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Movement_Orbit:AddList({text = "Target Player", tooltip = "Select player to orbit", flag = "Movement_Orbit_Player", values = {"None"}, callback = function(v) end})
    Movement_Orbit:AddButton({text = "Refresh Players", tooltip = "Refresh player list", callback = function() local players = {"None"} for _, plr in pairs(game:GetService("Players"):GetPlayers()) do if plr ~= game:GetService("Players").LocalPlayer then table.insert(players, plr.Name) end end if _G.GUI and _G.GUI.Library and _G.GUI.Library.options and _G.GUI.Library.options.Movement_Orbit_Player then _G.GUI.Library.options.Movement_Orbit_Player.values = players if #players > 0 then _G.GUI.Library.options.Movement_Orbit_Player:Select(players[1]) end end end})    Movement_Orbit:AddSlider({text = "Radius", tooltip = "Orbit radius", flag = "Movement_Orbit_Radius", min = 5, max = 50, increment = 1, value = 10, callback = function(v) end})
    Movement_Orbit:AddSlider({text = "Speed", tooltip = "Orbit speed", flag = "Movement_Orbit_Speed", min = 1, max = 20, increment = 1, value = 5, callback = function(v) end})

    -- Noclip
    Movement_Noclip:AddToggle({text = "Enabled", tooltip = "Walk through walls", flag = "Movement_Noclip_Enabled", state = false, risky = false, callback = function(v) end}):AddBind({text = "Noclip", bind = Enum.KeyCode.X, mode = "toggle", flag = "Movement_Noclip_Keybind", callback = function(v) if _G.GUI and _G.GUI.Library and _G.GUI.Library.options and _G.GUI.Library.options.Movement_Noclip_Enabled then _G.GUI.Library.options.Movement_Noclip_Enabled:SetState(v) end end})

    pcall(function() task.wait(0.1) Main:Select() end)
end)
    if not ok then warn("FXT somewhere, Locate it here:", err) end

    task.spawn(function()
        task.wait(1)
        if _G.GUI and _G.GUI.Library and _G.GUI.Library.options then
            if _G.GUI.Library.options.Movement_Teleport_Player then
                local players = {"None"}
                for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                    if plr ~= game:GetService("Players").LocalPlayer then
                        table.insert(players, plr.Name)
                    end
                end
                _G.GUI.Library.options.Movement_Teleport_Player.values = players
                if #players > 0 then
                    _G.GUI.Library.options.Movement_Teleport_Player:Select(players[1])
                end
            end
            if _G.GUI.Library.options.Movement_Orbit_Player then
                local players = {"None"}
                for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                    if plr ~= game:GetService("Players").LocalPlayer then
                        table.insert(players, plr.Name)
                    end
                end
                _G.GUI.Library.options.Movement_Orbit_Player.values = players
                if #players > 0 then
                    _G.GUI.Library.options.Movement_Orbit_Player:Select(players[1])
                end
            end
        end
    end)

    task.wait(1)
    local FlightBV = nil
    game:GetService("RunService").Heartbeat:Connect(function()
        pcall(function()
            if not _G.GUI or not _G.GUI.Library or not _G.GUI.Library.options then return end
            local Player = game:GetService("Players").LocalPlayer
            if not Player then return end
            local Character = Player.Character
            if not Character then return end
            local HRP = Character:FindFirstChild("HumanoidRootPart")
            if not HRP then return end
            local opts = _G.GUI.Library.options
            if opts.Movement_Flight_Enabled and opts.Movement_Flight_Enabled.state then if not FlightBV then FlightBV = Instance.new("BodyVelocity") FlightBV.MaxForce = Vector3.new(9e9, 9e9, 9e9) FlightBV.Parent = HRP end local Speed = opts.Movement_Flight_Speed and opts.Movement_Flight_Speed.value or 50 local Camera = workspace.CurrentCamera local MoveVector = Vector3.new(0, 0, 0) local UIS = game:GetService("UserInputService") if UIS:IsKeyDown(Enum.KeyCode.W) then MoveVector = MoveVector + (Camera.CFrame.LookVector * Speed) end if UIS:IsKeyDown(Enum.KeyCode.S) then MoveVector = MoveVector - (Camera.CFrame.LookVector * Speed) end if UIS:IsKeyDown(Enum.KeyCode.D) then MoveVector = MoveVector + (Camera.CFrame.RightVector * Speed) end if UIS:IsKeyDown(Enum.KeyCode.A) then MoveVector = MoveVector - (Camera.CFrame.RightVector * Speed) end if UIS:IsKeyDown(Enum.KeyCode.Space) then MoveVector = MoveVector + Vector3.new(0, Speed, 0) end if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then MoveVector = MoveVector - Vector3.new(0, Speed, 0) end FlightBV.Velocity = MoveVector else if FlightBV then FlightBV:Destroy() FlightBV = nil end end
            if opts.Movement_Spin_Enabled and opts.Movement_Spin_Enabled.state then local Speed = opts.Movement_Spin_Speed and opts.Movement_Spin_Speed.value or 10 HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(Speed), 0) end
            if opts.Movement_Cframe_Enabled and opts.Movement_Cframe_Enabled.state then local Humanoid = Character:FindFirstChildOfClass("Humanoid") if Humanoid and Humanoid.MoveDirection.Magnitude > 0 then local Speed = opts.Movement_Cframe_Speed and opts.Movement_Cframe_Speed.value or 0.5 HRP.CFrame = HRP.CFrame + (Humanoid.MoveDirection * Speed) end end
            if opts.Movement_Orbit_Enabled and opts.Movement_Orbit_Enabled.state and opts.Movement_Orbit_Player then local targetName = opts.Movement_Orbit_Player.value if targetName and targetName ~= "" and targetName ~= "None" then local Target = game:GetService("Players"):FindFirstChild(targetName) if Target and Target.Character then local TargetHRP = Target.Character:FindFirstChild("HumanoidRootPart") if TargetHRP then _G.OrbitAngle = (_G.OrbitAngle or 0) + math.rad(opts.Movement_Orbit_Speed and opts.Movement_Orbit_Speed.value or 5) local Radius = opts.Movement_Orbit_Radius and opts.Movement_Orbit_Radius.value or 10 local x = math.cos(_G.OrbitAngle) * Radius local z = math.sin(_G.OrbitAngle) * Radius HRP.CFrame = CFrame.new(TargetHRP.Position + Vector3.new(x, 0, z)) end end end end
            if opts.Movement_Noclip_Enabled and opts.Movement_Noclip_Enabled.state then for _, part in pairs(Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
        end)
    end)