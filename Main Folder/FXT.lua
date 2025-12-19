-- This will be our main file 

--[[
######## ##       ######## ##     ##      ####       ######## ##     ## ########  ########    ###    ########  ######  
##       ##       ##        ##   ##      ##  ##         ##    ##     ## ##     ## ##         ## ##      ##    ##    ## 
##       ##       ##         ## ##        ####          ##    ##     ## ##     ## ##        ##   ##     ##    ##       
######   ##       ######      ###        ####           ##    ######### ########  ######   ##     ##    ##     ######  
##       ##       ##         ## ##      ##  ## ##       ##    ##     ## ##   ##   ##       #########    ##          ## 
##       ##       ##        ##   ##     ##   ##         ##    ##     ## ##    ##  ##       ##     ##    ##    ##    ## 
##       ######## ######## ##     ##     ####  ##       ##    ##     ## ##     ## ######## ##     ##    ##     ###### 
]]

-- // Configuration
local CONFIG = {
    Decimals = 4,
    ValueText = "Value Is Now :",
    Window = {
        CheatName = "FXT Enhancements",
        Size = UDim2.new(0, 510, 0, 600)
    }
}

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
        _G.RadarInfo.Scale = value / 500
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
    Camlock_Activation:AddToggle({text="Camlock",tooltip="Enables camlock",flag="Camlock_Enabled",state=false,risky=false,callback=function()end})
    :AddBind({text="Keybind",tooltip="Keybind for camlock",bind=Enum.KeyCode.Q,mode="toggle",flag="Camlock_Keybind",callback=function()end})
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

    -- Wall / Knock / Crew / Distance / Whitelist
    Camlock_Wall_Flag:AddToggle({text="Enabled",tooltip="Wall check",flag="Camlock_Wall_Enabled",state=false,risky=false,callback=function()end})
    Camlock_Wall_Flag:AddBind({text="Ignore Wall",bind=Enum.KeyCode.V,mode="toggle",flag="Camlock_Wall_Ignore_Keybind",callback=function()end})
    Camlock_Wall_Flag:AddList({text="Start Ray From",flag="Camlock_Wall_Start",values={"Camera","Character"},callback=function()end})

    Camlock_Knock_Flag:AddToggle({text="Enabled",flag="Camlock_Knock_Enabled",state=false,risky=false,callback=function()end})
    Camlock_Crew_Flag:AddToggle({text="Enabled",flag="Camlock_Crew_Enabled",state=false,risky=false,callback=function()end})

    Camlock_Distance_Flag:AddToggle({text="Enabled",flag="Camlock_Distance_Enabled",state=false,risky=false,callback=function()end})
    Camlock_Distance_Flag:AddSlider({text="Distance",flag="Camlock_Distance_Value",min=10,max=2000,increment=1,value=100,callback=function()end})

    Camlock_Whitelist_Flag:AddToggle({text="Enabled",flag="Camlock_Whitelist_Enabled",state=false,risky=false,callback=function()end})
    Camlock_Whitelist_Flag:AddBind({text="Add/Remove Whitelist",bind=Enum.KeyCode.Z,mode="toggle",flag="Camlock_Whitelist_Keybind",callback=function()end})

    -- Visuals Sections
    Visuals_Arrows = Visuals:AddSection("Arrows",1)
    Visuals_ESP = Visuals:AddSection("ESP",1)
    Visuals_Radar = Visuals:AddSection("Radar",1)
    Visuals_Corners = Visuals:AddSection("Corners",2)
    Visuals_Chams = Visuals:AddSection("Chams",2)
    Visuals_Skeletons = Visuals:AddSection("Skeletons",2)
    Visuals_ViewTracer = Visuals:AddSection("View Tracer",2)

    -- Arrows
    Visuals_Arrows:AddToggle({text = "Enabled", tooltip = "Shows arrows pointing to offscreen players", flag = "Visuals_Arrows_Enabled", state = false, risky = false, callback = function(v) end})
    :AddBind({text = "Keybind", tooltip = "Toggles arrows", bind = Enum.KeyCode.H, mode = "toggle", flag = "Visuals_Arrows_Keybind", callback = function(v) end})
    Visuals_Arrows:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for arrows", flag = "Visuals_Arrows_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_Arrows:AddSlider({text = "Arrow Size", tooltip = "Size of the offscreen arrows", flag = "Visuals_Arrow_Size", min = 5, max = 30, increment = 1, value = 15, callback = function(v) end})
    Visuals_Arrows:AddSlider({text = "Radius", tooltip = "Distance from screen center", flag = "Visuals_Arrow_Radius", min = 20, max = 300, increment = 1, value = 150, callback = function(v) end})

    -- ESP
    Visuals_ESP:AddToggle({text = "Enabled", tooltip = "Shows ESP on players", flag = "Visuals_ESP_Enabled", state = false, risky = false, callback = function(v) end})
    :AddBind({text = "Keybind", tooltip = "Toggles ESP", bind = Enum.KeyCode.J, mode = "toggle", flag = "Visuals_ESP_Keybind", callback = function(v) end})
    Visuals_ESP:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for ESP", flag = "Visuals_ESP_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_ESP:AddToggle({text = "Names", tooltip = "Displays player names", flag = "Visuals_ESP_Names", state = false, risky = false, callback = function(v) end})
    Visuals_ESP:AddToggle({text = "Boxes", tooltip = "Draws a box around each player", flag = "Visuals_ESP_Boxes", state = false, risky = false, callback = function(v) end})
    Visuals_ESP:AddToggle({text = "Health Bar", tooltip = "Displays player's health", flag = "Visuals_ESP_HealthBar", state = false, risky = false, callback = function(v) end})

    -- Radar
    Visuals_Radar:AddToggle({text = "Enabled", tooltip = "Displays a radar UI", flag = "Visuals_Radar_Enabled", state = false, risky = false, callback = function(v) if v then RadarModule:Enable() else RadarModule:Disable() end end})
    :AddBind({text = "Keybind", tooltip = "Toggles radar", bind = Enum.KeyCode.K, mode = "toggle", flag = "Visuals_Radar_Keybind", callback = function(v) if v then RadarModule:Enable() else RadarModule:Disable() end end})
    Visuals_Radar:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for radar", flag = "Visuals_Radar_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_Radar:AddSlider({text = "Size", tooltip = "Size of the radar", flag = "Visuals_Radar_Size", min = 50, max = 300, increment = 1, value = 100, callback = function(v) RadarModule:SetSize(v) end})
    Visuals_Radar:AddSlider({text = "Range", tooltip = "Radar detection range", flag = "Visuals_Radar_Range", min = 100, max = 2000, increment = 50, value = 500, callback = function(v) RadarModule:SetRange(v) end})

    -- Corners
    Visuals_Corners:AddToggle({text = "Enabled", tooltip = "Draws corner-style ESP boxes", flag = "Visuals_Corners_Enabled", state = false, risky = false, callback = function(v) end})
    :AddBind({text = "Keybind", tooltip = "Toggles corners", bind = Enum.KeyCode.L, mode = "toggle", flag = "Visuals_Corners_Keybind", callback = function(v) end})
    Visuals_Corners:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for corners", flag = "Visuals_Corners_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_Corners:AddSlider({text = "Length", tooltip = "Corner line length", flag = "Visuals_Corner_Length", min = 1, max = 20, increment = 1, value = 8, callback = function(v) end})
    Visuals_Corners:AddSlider({text = "Thickness", tooltip = "Corner line thickness", flag = "Visuals_Corner_Thickness", min = 1, max = 5, increment = 1, value = 2, callback = function(v) end})

    -- Chams
    Visuals_Chams:AddToggle({text = "Enabled", tooltip = "Highlights player models", flag = "Visuals_Chams_Enabled", state = false, risky = false, callback = function(v) end})
    :AddBind({text = "Keybind", tooltip = "Toggles chams", bind = Enum.KeyCode.M, mode = "toggle", flag = "Visuals_Chams_Keybind", callback = function(v) end})
    Visuals_Chams:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for chams", flag = "Visuals_Chams_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_Chams:AddToggle({text = "Team Check", tooltip = "Hides chams on teammates", flag = "Visuals_Chams_TeamCheck", state = false, risky = false, callback = function(v) end})
    Visuals_Chams:AddList({text = "Render Mode", tooltip = "Cham rendering method", flag = "Visuals_Chams_Render", values = {"Highlight", "Adornment"}, callback = function(v) end})

    -- Skeletons
    Visuals_Skeletons:AddToggle({text = "Enabled", tooltip = "Draws skeletons on players", flag = "Visuals_Skeletons_Enabled", state = false, risky = false, callback = function(v) end})
    :AddBind({text = "Keybind", tooltip = "Toggles skeletons", bind = Enum.KeyCode.N, mode = "toggle", flag = "Visuals_Skeletons_Keybind", callback = function(v) end})
    Visuals_Skeletons:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for skeletons", flag = "Visuals_Skeletons_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_Skeletons:AddToggle({text = "Team Check", tooltip = "Hides skeletons on teammates", flag = "Visuals_Skeletons_TeamCheck", state = false, risky = false, callback = function(v) end})
    Visuals_Skeletons:AddSlider({text = "Thickness", tooltip = "Skeleton line thickness", flag = "Visuals_Skeletons_Thickness", min = 1, max = 5, increment = 1, value = 2, callback = function(v) end})

    -- View Tracer
    Visuals_ViewTracer:AddToggle({text = "Enabled", tooltip = "Draws lines indicating view direction", flag = "Visuals_ViewTracer_Enabled", state = false, risky = false, callback = function(v) end})
    :AddBind({text = "Keybind", tooltip = "Toggles view tracer", bind = Enum.KeyCode.B, mode = "toggle", flag = "Visuals_ViewTracer_Keybind", callback = function(v) end})
    Visuals_ViewTracer:AddList({text = "Toggle Mode", tooltip = "Toggle behavior for view tracer", flag = "Visuals_ViewTracer_Mode", values = {"Toggle", "Hold", "Always"}, callback = function(v) end})
    Visuals_ViewTracer:AddToggle({text = "Team Check", tooltip = "Hides tracers on teammates", flag = "Visuals_ViewTracer_TeamCheck", state = false, risky = false, callback = function(v) end})
    Visuals_ViewTracer:AddSlider({text = "Length", tooltip = "View tracer length", flag = "Visuals_ViewTracer_Length", min = 50, max = 1000, increment = 10, value = 300, callback = function(v) end})

    -- // Movement Sections

    -- // Misc Sections

    -- // layout issue

    -- To Fix the bunching together after loading
        pcall(function()
        task.wait(0.1)
        Main:Select()
    end)
end) -- this ends the giant pcall

if not ok then warn("FXT somewhere, Locate it here:", err) end

    -- // Load Time Notification
    pcall(function()
        local LoadTime = string.format("%." .. CONFIG.Decimals .. "f", os.clock() - Clock)
        _G.GUI.Library:SendNotification("Loaded In " .. LoadTime, 6)
    end)

    -- Begin cleanup 
    -- // Cleanup on GUI close
    pcall(function()
        if _G.GUI and _G.GUI.Library then
            local oldUnload = _G.GUI.Library.Unload
            _G.GUI.Library.Unload = function(...)
                RadarModule:Cleanup()
                if oldUnload then oldUnload(...) end
            end
        end
    end)