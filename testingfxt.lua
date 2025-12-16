--//Rayfield Lib Loader\\--
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Threats made the lock below

-- // CONFIG \\ --
_G.Config = {
    ["Aimbot"] = {
        ["Enabled"] = false,
        ["Keybind"] = "Q",
        ["FOV"] = 80
    },
    ["Panic"] = {
        ["Enabled"] = true,
        ["Keybind"] = "M"
    }
};

-- // VARIABLES \\ --
_G.Variables = {
    ["Players"] = game:GetService("Players"),
    ["Run_Service"] = game:GetService("RunService"),
    ["User_Input_Service"] = game:GetService("UserInputService"),

    ["Player"] = game:GetService("Players").LocalPlayer,

    ["Mouse"] = game:GetService("Players").LocalPlayer:GetMouse(),
    ["Camera"] = workspace.CurrentCamera,

    ["Aimbot_Toggled"] = false,
    ["Aimbot_Target"] = nil
};

_G.Signals = {}

-- // FUNCTIONS \\ --
_G.Functions = {}

function _G.Functions.FOV_Search()
    local Target
    local Distance = _G.Config.Aimbot.FOV

    for _, Player in _G.Variables.Players:GetPlayers() do
        if Player == _G.Variables.Player then continue end
        if not Player.Character then continue end
        if not Player.Character:FindFirstChild("HumanoidRootPart") then continue end

        local Player_Position, On_Screen = _G.Variables.Camera:WorldToScreenPoint(Player.Character.HumanoidRootPart.Position)
        Player_Position = Vector2.new(Player_Position.X, Player_Position.Y)
        local Mouse_Position = Vector2.new(_G.Variables.Mouse.X, _G.Variables.Mouse.Y)

        if On_Screen and (Player_Position - Mouse_Position).Magnitude <= Distance then
            Distance = (Player_Position - Mouse_Position).Magnitude
            Target = Player.Character
        end
    end

    return Target
end

function _G.Functions.Toggle.Aimbot()
    _G.Variables.Aimbot_Toggled = not _G.Variables.Aimbot_Toggled
    _G.Variables.Aimbot_Target = nil

    Rayfield:Notify({
        Title = "Camlock",
        Content = _G.Variables.Aimbot_Toggled and "Enabled" or "Disabled",
        Duration = 2,
        Image = 4483362458
    })
end

function _G.Functions.Aimbot_Main()
    if not _G.Config.Aimbot.Enabled then return end
    if not _G.Variables.Aimbot_Toggled then return end

    if not _G.Variables.Aimbot_Target or not _G.Variables.Aimbot_Target:FindFirstChild("HumanoidRootPart") then
        _G.Variables.Aimbot_Target = _G.Functions.FOV_Search()
    end

    if _G.Variables.Aimbot_Target and _G.Variables.Aimbot_Target:FindFirstChild("HumanoidRootPart") then
        _G.Variables.Camera.CFrame = CFrame.lookAt(_G.Variables.Camera.CFrame.Position, _G.Variables.Aimbot_Target.HumanoidRootPart.Position)
    end
end

function _G.Functions.Panic()
    Rayfield:Notify({
        Title = "Panic Mode",
        Content = "Terminating now...",
        Duration = 2,
        Image = 4483362458
    })
    
    task.defer(function()
        for _, Signal in _G.Signals do
            Signal:Disconnect()
        end

        _G.Signals = nil
        _G.Config = nil
        _G.Functions = nil
        _G.Variables = nil
        
        task.wait(0.5)
        Rayfield:Destroy()
    end)
end

-- // Window
local window = Rayfield:CreateWindow({
    Name = "FXT", -- Flex x Threats 
    LoadingTitle = "Initializing Framework",
    LoadingSubtitle = "GUI made by @more-more-more",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FXT Framework",
        FileName = "Configuration"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        Remember = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Key System",
        Subtitle = "Enter your key here",
        Note = "Get your own key at _________",
        FileName = "KeyPlace",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"FuckThreatsNigga123"}
    },
     
    -- Main Colors
    Theme = {
        TextColor = Color3.fromRGB(255, 255, 255,),
        Background = Color3.fromRGB(15, 3, 3),
        Topbar = Color3.fromRGB(25, 8, 8),
        Shadow = Color3.fromRGB(0, 0, 0),

        -- Notifications
        NotificationBackground = Color3.fromRGB(40, 40, 40),
        NotificationActionBackground = Color3.fromRGB(50, 50, 50),

        -- Tabs
        TabBackground = Color3.fromRGB(30, 10, 10)
        TabStroke Color3.fromRGB(80, 20, 20),
        TabBackgroundSelected = Color3.fromRGB(120, 25, 25),
        TabTextColor = Color3.fromRGB(200, 150, 150),
        SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

        --  Elements 
        ElementBackground = Color3.fromRGB(30, 10, 10),
        ElementBackgroundHover = Color3.fromRGB(50, 15, 15),
        SecondaryElementBackground = Color3.fromRGB(20, 8, 8),
        ElementStroke = Color3.fromRGB(100, 25, 25),
        SecondaryElementBackground = Color3.fromRGB(80, 20, 20),

        -- Sliders
        SliderBackground = Color3.fromRGB(20, 8, 8),
        SliderProgress = Color3.fromRGB(200, 40, 40),
        SliderStroke = Color3.fromRGB(100, 25, 25),
        
        -- Togglables
        ToggleBackground = Color3.fromRGB(25, 10, 10),
        ToggleEnabled = Color3.fromRGB(220, 40, 40),
        ToggleDisabled = Color3.fromRGB(40, 15, 15),
        ToggleEnabledStroke = Color3.fromRGB(255, 60, 60),
        ToggleDisabledStroke = Color3.fromRGB(60, 20, 20),
        ToggleEnabledOutterStroke = Color3.fromRGB(255, 80, 80),
        ToggleDisabledOuterStroke = Color3.fromRGB(80, 25, 25),

        -- Dropdowns
        DropdownSelected = Color3.fromRGB(180, 35, 35),
        DropdownUnselected = Color3.fromRGB(30, 12, 12),

        -- Input Fields
        InputBackground = Color3.fromRGB(20, 8, 8),
        InputStroke = Color3.fromRGB(100, 25, 25),
        InputText = Color3.fromRGB(255, 255, 255)
    }
})

--// Beginning of Tabs \\--

-- Tab 1: Main

local MainTab = Window:CreateTab("Main", 4483362458)

local MainSection = MainTab:CreateSection("Features")

-- Button 1: Camlock

local Button = MainTab:CreateButton({
    Name = "Camlock",
    CurrentValue = _G.Config.Aimbot.Enabled,
    Flag = "CamlockEnabled,
    Callback = function(Value)
        _G.Config.Aimbot.Enabled = Value
        Rayfield:Notify({
            Title = "Camlock",
            Content = Value and "Enabled" or "Disabled",
            Duration = 2,
            Image = 4483362458
        })
    end
})

-- Slider 1: Fov Size
local FOVSlider = MainTab:CreateSlider({
    Name = "FOV Size",
    Range = {20, 600},
    Increment = 5,
    Suffix = " px",
    CurrentValue = _G.Config.Aimbot.FOV,
    Flag = "CamlockFOV",
    Callback = function(Value)
        _G.Config.Aimbot.Fov = Value
    end
})


-- Keybind: Camlock Toggle
local CamlockKeybind = MainTab:CreateKeybind({
    Name = "Toggle Key",
    CurrentKeybind = _G.Config.Aimbot.Keybind,
    HoldToInteract = false,
    Flag = "CamlockKeybind",
    Callback = function(Keybind)
        _G.Config.Aimbot.Keybind = Keybind
    end
})

-- Button: Manual Toggle
local ManualToggleButton = MainTab:CreateButton({
    Name = "Manual Toggle",
    Callback = function()
        _G.Functions.Toggle_Aimbot()
    end
})

-- Section 1: Panic Settings
local PanicSection = MainTab:CreateSection("Panic Mode")

-- keybind: panic key
local PanicKey = MainTab:CreateKeybind({
    Name = "Panic Key",
    CurrentKeybind = _G.Config.Panic.Keybind,
    HoldToInteract = false,
    Flag = "PanicKey",
    Callback = function(Keybind)
        _G.Config.Panic.Keybind = Keybind
    end
})

-- Button: Manual Panic
local PanicButton = MainTab:CreateButton({
    Name = "Panic (Destroy GUI)"
    Callback = function()
        _G.Functions.Panic()
    end
})

-- Section: Info
local InfoSection = MainTab:CreateSection("Information")

MainTab:CreateLabel("Press Keybind to Toggle Camlock")
MainTab:CreateLabel("FOV")
MainTab:CreateLabel("Panic destroys GUI")

-- // RUN TIME \\ --
_G.Signals.Render_Stepped = _G.Variables.Run_Service.RenderStepped:Connect(function()
    task.spawn(_G.Functions.Aimbot_Main)
end)

_G.Signals.Input_Began = _G.Variables.User_Input_Service.InputBegan:Connect(function(Input, Processed)
    if Processed then return end
    if not _G.Config then return end

    if _G.Config.Aimbot.Enabled and Input.KeyCode == Enum.KeyCode[string.upper(_G.Config.Aimbot.Keybind)] then
        _G.Functions.Toggle_Aimbot()
        return
    end

    if _G.Config.Panic.Enabled and Input.KeyCode == Enum.KeyCode[string.upper(_G.Config.Panic.Keybind)] then
        _G.Functions.Panic()
        return
    end
end)

-- Success Notify

Rayfield:Notify({
    Title = "FXT Initalized!",
    Content = "Test system has loaded.",
    Duration = 5,
    Image = 4483362458
})

-- Load configuration

Rayfield:LoadConfiguration()