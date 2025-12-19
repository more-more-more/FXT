-- @author @more-more-more & @sparetheliving
-- me and threats on top cuck fuck

-- // VARIABLES \\

_G.Config = {
    	["Camlock"] = {
		["Enabled"] = true,
		["Keybind"] = Enum.KeyCode.Q,
		["Search_Mode"] = "2D",
		["FOV"] = 500,
		["Sticky_Aim"] = true,
		["Smoothing"] = {
			["Enabled"] = false,
			["Method"] = "Lerp",
			["Tween_Time"] = 9,
			["Lerp_Amount"] = 8
		},
		["Prediction"] = {
			["Enabled"] = false,
			["Type"] = "MoveDirection",
			["Amount"] = {X = 5, Y = 5, Z = 5}
		},
		["Flags"] = {
			["Wall"] = {
				["Enabled"] = false,
				["Constant"] = {["Enabled"] = false, ["Toggle_Off"] = false}
			},
			["KO"] = {
				["Enabled"] = false,
				["Constant"] = {["Enabled"] = true, ["Toggle_Off"] = true}
			},
			["Crew"] = {
				["Enabled"] = false,
				["Constant"] = {["Enabled"] = true, ["Toggle_Off"] = true}
			},
			["Distance"] = {
				["Enabled"] = false,
				["Amount"] = 1000,
				["Constant"] = {["Enabled"] = false, ["Toggle_Off"] = false}
			},
			["Whitelist"] = {
				["Enabled"] = false,
				["Inverted"] = false,
				["Whitelisted"] = {},
				["Keybind"] = Enum.KeyCode.Z,
				["Constant"] = {["Enabled"] = false, ["Toggle_Off"] = false}
			}
		}
	},
	["Triggerbot"] = {
		["Enabled"] = true,
		["Keybind"] = Enum.KeyCode.T,
		["FOV"] = 30,
		["Delay"] = 20,
		["Search_Mode"] = "raycast",
		["Flags"] = {
			["Wall"] = {["Enabled"] = true},
			["KO"] = {["Enabled"] = true},
			["Crew"] = {["Enabled"] = true},
			["Distance"] = {["Enabled"] = true, ["Amount"] = 300},
			["Whitelist"] = {["Enabled"] = false, ["Inverted"] = false, ["Whitelisted"] = {}}
		};
	};
};

_G.Variables = {
	Players = game:GetService("Players"),
	User_Input_Service = game:GetService("UserInputService"),
	Run_Service = game:GetService("RunService"),
	Tween_Service = game:GetService("TweenService"),
	Player = nil,
	Character = nil,
	Camera = workspace.CurrentCamera,
	Mouse = nil,
	Crew_Path = nil,
	KO_Path = nil,
	Camlock_Toggled = false,
	Camlock_Target = nil,
	Previous_Tween = nil,
	Triggerbot_Toggled = false,
	Last_Shot = nil
};

_G.Variables.Player = _G.Variables.Players.LocalPlayer
_G.Variables.Character = _G.Variables.Player.Character or _G.Variables.Player.CharacterAdded:Wait()
_G.Variables.Mouse = _G.Variables.Player:GetMouse()

local Stop = false

-- // FUNCTIONS \\
_G.Functions = {}

function _G.Functions.Get_Path(Interchangeable, Names)
	local Found_Object = nil
	for _, Object in Interchangeable:GetDescendants() do
		if Object:IsA("BoolValue") or Object:IsA("IntValue") or Object:IsA("StringValue") then
			for _, Name in Names do
				if string.find(string.lower(Object.Name), string.lower(Name)) then
					Found_Object = Object
					break
				end
			end
			if Found_Object then break end
		end
	end
	if not Found_Object then return nil end
	
	local Path_Parts = {}
	local Current = Found_Object
	while Current and Current ~= game do
		if Current == Interchangeable then
			table.insert(Path_Parts, 1, "[Interchangeable]")
		else
			table.insert(Path_Parts, 1, Current.Name)
		end
		Current = Current.Parent
	end
	if Current == game then
		table.insert(Path_Parts, 1, "game")
	end
	return table.concat(Path_Parts, "__")
end

function _G.Functions.Use_Path(Path, Name)
	if not Path or Path == "" then return nil end
	local Path_Parts = {}
	for Part in string.gmatch(Path, "[^__]+") do
		table.insert(Path_Parts, Part)
	end
	local Current = game
	for _, Object in ipairs(Path_Parts) do
		if Object == "game" then
			Current = game
		elseif Object == "[Interchangeable]" then
			Current = Current:FindFirstChild(Name)
		elseif Current then
			Current = Current:FindFirstChild(Object)
			if not Current then return nil end
		end
	end
	return Current
end

function _G.Functions.Wall_Check(Target, Flags)
	if not Flags.Wall.Enabled then return true end
	local Ignored = {}
	for _, Player in _G.Variables.Players:GetChildren() do
		if Player.Character then
			table.insert(Ignored, Player.Character)
		end
	end
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = Ignored
	Params.RespectCanCollide = false
	
	local Start_Position = _G.Variables.Camera.CFrame.Position
	local End_Position = Target.HumanoidRootPart.Position
	local Raycast = workspace:Raycast(Start_Position, End_Position - Start_Position, Params)
	if Raycast then return false end
	return true
end

function _G.Functions.KO_Check(Target, Flags)
	if not Flags.KO.Enabled then return true end
	if _G.Variables.KO_Path then
		local KO_Object = _G.Functions.Use_Path(_G.Variables.KO_Path, Target.Name)
		if KO_Object then
			return not KO_Object.Value
		end
	end
	return true
end

function _G.Functions.Crew_Check(Target, Flags)
	if not Flags.Crew.Enabled then return true end
	if _G.Variables.Crew_Path then
		local Target_Crew = _G.Functions.Use_Path(_G.Variables.Crew_Path, Target.Name)
		local Player_Crew = _G.Functions.Use_Path(_G.Variables.Crew_Path, _G.Variables.Player.Name)
		if Player_Crew and Target_Crew then
			return Player_Crew.Value ~= Target_Crew.Value
		end
	end
	return true
end

function _G.Functions.Distance_Check(Target, Flags)
	if not Flags.Distance.Enabled then return true end
	if (_G.Variables.Character.HumanoidRootPart.Position - Target.HumanoidRootPart.Position).Magnitude <= Flags.Distance.Amount then
		return true
	else
		return false
	end
end

function _G.Functions.Whitelist_Check(Target, Flags)
	if not Flags.Whitelist.Enabled then return true end
	if table.find(Flags.Whitelist.Whitelisted, Target.Name) then
		if Flags.Whitelist.Inverted then return false end
		return true
	else
		return false
	end
end

function _G.Functions.Find_Target(Flags, Search_Mode, FOV)
	local Closest = FOV
	local Target = nil
	for _, Player in _G.Variables.Players:GetChildren() do
		if Player == _G.Variables.Player then continue end
		if not Player.Character then continue end
		Player = Player.Character
		
		if not _G.Functions.Wall_Check(Player, Flags) then continue end
		if not _G.Functions.KO_Check(Player, Flags) then continue end
		if not _G.Functions.Crew_Check(Player, Flags) then continue end
		if not _G.Functions.Distance_Check(Player, Flags) then continue end
		if not _G.Functions.Whitelist_Check(Player, Flags) then continue end
		
		local Distance = nil
		if string.lower(Search_Mode) == "3d" then
			local Player_3D = Player.HumanoidRootPart.Position
			local Mouse_3D = _G.Variables.Mouse.Hit.Position
			Distance = (Player_3D - Mouse_3D).Magnitude
		else
			local Screen_Position, On_Screen = _G.Variables.Camera:WorldToScreenPoint(Player.HumanoidRootPart.Position)
			if not On_Screen then continue end
			local Player_2D = Vector2.new(Screen_Position.X, Screen_Position.Y)
			local Mouse_2D = Vector2.new(_G.Variables.Mouse.X, _G.Variables.Mouse.Y)
			Distance = (Player_2D - Mouse_2D).Magnitude
		end
		
		if Distance <= Closest then
			Closest = Distance
			Target = Player
		end
	end
	return Target
end

function _G.Functions.Predict_Target(Target, Prediction_Config)
	if Prediction_Config.Enabled then
		local Prediction_Amount = Vector3.new(0, 0, 0)
		if Prediction_Config.Type == "Velocity" then
			Prediction_Amount = Target.HumanoidRootPart.Velocity * Vector3.new(Prediction_Config.Amount.X, Prediction_Config.Amount.Y, Prediction_Config.Amount.Z)
		else
			Prediction_Amount = Target.Humanoid.MoveDirection
			Prediction_Amount *= Vector3.new(Prediction_Config.Amount.X, Prediction_Config.Amount.Y, Prediction_Config.Amount.Z)
		end
		return Prediction_Amount
	end
	return Vector3.new(0, 0, 0)
end

function _G.Functions.Toggle_Camlock()
	_G.Variables.Camlock_Toggled = not _G.Variables.Camlock_Toggled
	_G.Variables.Camlock_Target = nil
	if _G.Variables.Previous_Tween then
		_G.Variables.Previous_Tween:Cancel()
		_G.Variables.Previous_Tween = nil
	end
end

function _G.Functions.Toggle_Triggerbot()
	_G.Variables.Triggerbot_Toggled = not _G.Variables.Triggerbot_Toggled
end

function _G.Functions.Update_Camera(Position)
	if _G.Config.Camlock.Smoothing.Enabled then
		if string.lower(_G.Config.Camlock.Smoothing.Method) == "tween" then
			_G.Variables.Previous_Tween = _G.Variables.Tween_Service:Create(_G.Variables.Camera, TweenInfo.new(math.clamp(_G.Config.Camlock.Smoothing.Tween_Time / 100, 0.01, 0.2)), {CFrame = CFrame.lookAt(_G.Variables.Camera.CFrame.Position, Position)})
			_G.Variables.Previous_Tween:Play()
		else
			_G.Variables.Camera.CFrame = _G.Variables.Camera.CFrame:Lerp(CFrame.lookAt(_G.Variables.Camera.CFrame.Position, Position), math.clamp(_G.Config.Camlock.Smoothing.Lerp_Amount / 100, 0.01, 1))
		end
	else
		_G.Variables.Camera.CFrame = CFrame.lookAt(_G.Variables.Camera.CFrame.Position, Position)
	end
end

function _G.Functions.Camlock_Main(Flags)
	if not _G.Config.Camlock.Enabled then return end
	if _G.Variables.Previous_Tween then
		_G.Variables.Previous_Tween:Cancel()
		_G.Variables.Previous_Tween = nil
	end
	if not _G.Variables.Camlock_Toggled then return end
	
	if not _G.Variables.Camlock_Target or not _G.Config.Camlock.Sticky_Aim then
		_G.Variables.Camlock_Target = _G.Functions.Find_Target(Flags, _G.Config.Camlock.Search_Mode, _G.Config.Camlock.FOV)
	end
	
	if _G.Variables.Camlock_Target then
		local Flagged = false
		for Key, Flag in Flags do
			if Flag.Constant and Flag.Constant.Enabled and Flags[Key].Enabled then
				if not _G.Functions[Key .. "_Check"](_G.Variables.Camlock_Target, Flags) then
					Flagged = true
					if Flag.Constant.Toggle_Off then
						_G.Functions.Toggle_Camlock()
						break
					end
				end
			end
		end
		if not Flagged then
			_G.Functions.Update_Camera(_G.Variables.Camlock_Target.HumanoidRootPart.Position + _G.Functions.Predict_Target(_G.Variables.Camlock_Target, _G.Config.Camlock.Prediction))
		end
	end
end

function _G.Functions.Triggerbot_Main(Flags)
	if not _G.Variables.Triggerbot_Toggled then return end
	if _G.Variables.Last_Shot and os.clock() - _G.Variables.Last_Shot < _G.Config.Triggerbot.Delay / 1000 then return end
	
	local Tool = _G.Variables.Character:FindFirstChildWhichIsA("Tool")
	if Tool then
		local Ammo = Tool:FindFirstChild("AmmoClient") or Tool:FindFirstChild("Ammo")
		if Ammo then
			if Ammo.Value <= 0 then return end
			if _G.Functions.Find_Target(Flags, "2d", _G.Config.Triggerbot.FOV) then
				Tool:Activate()
				_G.Variables.Last_Shot = os.clock()
			end
		end
	end
end

_G.GUI = {};
_G.GUI.Repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/";
_G.GUI.ThemeManager = loadstring(game:HttpGet(_G.GUI.Repo .. "addons/ThemeManager.lua"))();
_G.GUI.SaveManager = loadstring(game:HttpGet(_G.GUI.Repo .. "addons/SaveManager.lua"))();
_G.GUI.Library = loadstring(game:HttpGet(_G.GUI.Repo .. "Library.lua"))();

_G.GUI.Success, _G.GUI.Error = pcall(function() 
	_G.GUI.Options = _G.GUI.Library.Options;
	_G.GUI.Toggles = _G.GUI.Library.Toggles;
	_G.GUI.Window = _G.GUI.Library:CreateWindow({
		Title = "FXT Framework",
		Footer = "version: 1.0",
		Center = true,
		AutoShow = true,
		TabPadding = 8,
		MenuFadeTime = .2,
		ShowCustomCursor = false
	});

	_G.GUI.Tabs = {
		["Camlock"] = _G.GUI.Window:AddTab("Main"),
		["Visuals"] = _G.GUI.Window:AddTab("Visuals"),
		["Movement"] = _G.GUI.Window:AddTab("Movement"),
		["Misc"] = _G.GUI.Window:AddTab("Misc"),
		["Settings"] = _G.GUI.Window:AddTab("Settings"),
		["Updates"] = _G.GUI.Window:AddTab("Updates"),
		["Credits"] = _G.GUI.Window:AddTab("Credits"),
	};

    -- // CAMLOCK aka MAIN TAB\\
	_G.GUI.LeftTabBoxes = {
		["Camlock_Activation"] = _G.GUI.Tabs.Camlock:AddLeftGroupbox("Activation"),
		["Camlock_Smoothing"] = _G.GUI.Tabs.Camlock:AddLeftGroupbox("Smoothing"),
		["Camlock_Prediction"] = _G.GUI.Tabs.Camlock:AddLeftGroupbox("Prediction")
	};
	_G.GUI.RightTabBoxes = {
		["Camlock_Wall_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Wall Flag"),
		["Camlock_Knock_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Knock Flag"),
		["Camlock_Crew_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Crew Flag"),
		["Camlock_Distance_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Distance Flag"),
		["Camlock_Whitelist_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Whitelist Flag")
	};

    -- Left Tab Boxes for Camlock
	_G.GUI.LeftTabBoxes.Camlock_Activation:AddToggle("Camlock_Enabled", {
		Text = "Camlock",
		Tooltip = "Enables camlock",
		DisabledTooltip = "", 
		Default = False,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.LeftTabBoxes.Camlock_Activation:AddToggle("Camlock_Sticky_Aim", {
		Text = "Sticky Aim",
		Tooltip = "Stops from constantly searching for new targets",
		DisabledTooltip = "", 
		Default = False,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.LeftTabBoxes.Camlock_Activation:AddLabel("Keybind"):AddKeyPicker("Camlock_Keybind", {
		Default = "Q",
		SyncToggleState = false,
		Mode = "Toggle",
		Text = "Keybind for camlock",
		NoUI = false,
		Callback = function(Value)
		end,
		ChangedCallback = function(NewKey, NewModifiers)
			
		end, 
	});
	_G.GUI.LeftTabBoxes.Camlock_Activation:AddSlider("Camlock_FOV", {
		Text = "FOV",
		Default = 80,
		Min = 30,
		Max = 1000,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
		end,
		Tooltip = "Field of View",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Camlock_Activation:AddDropdown("Camlock_Search_Mode", {
		Values = {"2D", "3D"},
		Default = 1,
		Multi = false,
		Text = "Search_Mode",
		Tooltip = "Method of finding targets",
		DisabledTooltip = "I am disabled!",
		Searchable = false,
		Callback = function(Value)
		end,
		Disabled = false,
		Visible = true,
	});

	_G.GUI.LeftTabBoxes.Camlock_Smoothing:AddToggle("Camlock_Smoothing_Enabled", {
		Text = "Enabled",
		Tooltip = "Enable camera smoothing",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.LeftTabBoxes.Camlock_Smoothing:AddDropdown("Camlock_Smoothing_Method", {
		Values = {"Lerp", "Tween"},
		Default = 1,
		Multi = false,
		Text = "Method",
		Tooltip = "Smoothing method",
		DisabledTooltip = "",
		Searchable = false,
		Callback = function(Value)
		end,
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Camlock_Smoothing:AddSlider("Camlock_Lerp_Amount", {
		Text = "Lerp Amount",
		Default = 5,
		Min = 1,
		Max = 50,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
		end,
		Tooltip = "Percentage gained each frame",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Camlock_Smoothing:AddSlider("Camlock_Tween_Time", {
		Text = "Tween Time",
		Default = 7,
		Min = 1,
		Max = 20,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
		end,
		Tooltip = "Time taken to tween the camera (centiseconds)",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});

	_G.GUI.LeftTabBoxes.Camlock_Prediction:AddDropdown("Camlock_Prediction_Method", {
		Values = {"MoveDirection", "Velocity"},
		Default = 1,
		Multi = false,
		Text = "Type",
		Tooltip = "Prediction type (MoveDirection works against antilock)",
		DisabledTooltip = "",
		Searchable = false,
		Callback = function(Value)
		end,
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Camlock_Prediction:AddSlider("Camlock_Prediction_X", {
		Text = "X",
		Default = 0,
		Min = 0,
		Max = 20,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
		end,
		Tooltip = "",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Camlock_Prediction:AddSlider("Camlock_Prediction_Y", {
		Text = "Y",
		Default = 0,
		Min = 0,
		Max = 20,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
		end,
		Tooltip = "	",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Camlock_Prediction:AddSlider("Camlock_Prediction_Z", {
		Text = "Z",
		Default = 0,
		Min = 0,
		Max = 20,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
		end,
		Tooltip = "",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});

    -- wall check
	_G.GUI.RightTabBoxes.Camlock_Wall_Flag:AddToggle("Camlock_Wall_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks for walls while searching for targets",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Wall_Flag:AddLabel("Ignore Wall"):AddKeyPicker("Camlock_Wall_Ignore_Keybind", {
		Default = "V",
		SyncToggleState = false,
		Mode = "Press",
		Text = "Permanently ignores the wall/part mouse is over",
		NoUI = false,
		Callback = function(Value)
		end,
		ChangedCallback = function(NewKey, NewModifiers)
			
		end, 
	});
	_G.GUI.RightTabBoxes.Camlock_Wall_Flag:AddDropdown("Camlock_Wall_Start", {
		Values = {"Camera", "Character"},
		Default = 1,
		Multi = false,
		Text = "Start Ray From",
		Tooltip = "Chooses where to start the raycast from",
		DisabledTooltip = "",
		Searchable = false,
		Callback = function(Value)
		end,
		Disabled = false,
		Visible = true,
	});
	_G.GUI.RightTabBoxes.Camlock_Wall_Flag:AddToggle("Camlock_Wall_Constant_Enabled", {
		Text = "Constant Check",
		Tooltip = "Checks even while locked onto the target",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Wall_Flag:AddToggle("Camlock_Wall_Constant_Toggle", {
		Text = "Toggle Off",
		Tooltip = "Toggles camlock if a wall is detected while locked on",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.Camlock_Knock_Flag:AddToggle("Camlock_Knock_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks if player is knocked while searching for targets",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Knock_Flag:AddToggle("Camlock_Knock_Constant_Enabled", {
		Text = "Constant Check",
		Tooltip = "Checks even while locked onto the target",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Knock_Flag:AddToggle("Camlock_Knock_Constant_Toggle", {
		Text = "Toggle Off",
		Tooltip = "Toggles camlock if target becomes knocked (Constant must be on)",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.Camlock_Crew_Flag:AddToggle("Camlock_Crew_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks if player is in your crew while searching for targets",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Crew_Flag:AddToggle("Camlock_Crew_Constant_Enabled", {
		Text = "Constant Check",
		Tooltip = "Checks even while locked onto the target",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Crew_Flag:AddToggle("Camlock_Crew_Constant_Toggle", {
		Text = "Toggle Off",
		Tooltip = "Toggles camlock if target joins your crew (Constant must be on)",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.Camlock_Distance_Flag:AddToggle("Camlock_Distance_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks if player is out of distance while searching for targets",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Distance_Flag:AddSlider("Camlock_Distance_Value", {
		Text = "Distance",
		Default = 100,
		Min = 10,
		Max = 2000,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
		end,
		Tooltip = "Players farther than this will be ignored",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});
	_G.GUI.RightTabBoxes.Camlock_Distance_Flag:AddToggle("Camlock_Distance_Constant_Enabled", {
		Text = "Constant Check",
		Tooltip = "Checks even while locked onto the target",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Distance_Flag:AddToggle("Camlock_Distance_Constant_Toggle", {
		Text = "Toggle Off",
		Tooltip = "Toggles camlock if target becomes is out of range",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.Camlock_Whitelist_Flag:AddToggle("Camlock_Whtelist_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks if player is in your whitelist",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Whitelist_Flag:AddLabel("Whitelist Keybind"):AddKeyPicker("Camlock_Whitelist_Keybind", {
		Default = "Z",
		SyncToggleState = false,
		Mode = "Press",
		Text = "Adds/removes a player from whitelist",
		NoUI = false,
		Callback = function(Value)
		end,
		ChangedCallback = function(NewKey, NewModifiers)
			
		end, 
	});
	_G.GUI.RightTabBoxes.Camlock_Whitelist_Flag:AddToggle("Camlock_Whitelist_Constant_Enabled", {
		Text = "Constant Check",
		Tooltip = "Checks even while locked onto the target",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false, 
		Callback = function(Value)
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Whitelist_Flag:AddToggle("Camlock_Whitelist_Constant_Toggle", {
		Text = "Toggle Off",
		Tooltip = "Toggles camlock if you remove target from whitelist (Constant must be on)",
		DisabledTooltip = "", 
		Default = false,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});

    -- // VISUALS TAB \\ 
    
    _G.GUI.LeftTabBoxes.Skeleton_ESP = _G.GUI.Tabs.Visuals:AddLeftGroupbox("Skeleton ESP")
    _G.GUI.LeftTabBoxes.Look_Direction = _G.GUI.Tabs.Visuals:AddLeftGroupbox("Look Direction")
	_G.GUI.RightTabBoxes.ESP = _G.GUI.Tabs.Visuals:AddRightGroupbox("ESP")

    -- // Left Tab Boxes

    -- Skeletons
    _G.GUI.LeftTabBoxes.Skeleton_ESP:AddToggle("Skeleton_Player_Enabled", {
	Text = "Player Skeletons",
	Default = false,
	Tooltip = "Draws player skeletons",
	Callback = function(Value)
	end
    }):AddColorPicker("Skeleton_Player_Color", {
		Default = Color3.fromRGB(255, 255, 255),
		Title = "Player Skeleton Color",
		Transparency = 0,
		Callback = function(Value)
		end
	}):AddKeyPicker("Skeletons_Player_Keybind", {
		Default = "None",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = "Player skeleton",
		NoUI = false,
		Callback = function(Value)
		end
	});

    _G.GUI.LeftTabBoxes.Skeleton_ESP:AddSlider("Skeleton_Player_Thickness", {
        Text = "Thickness",
        Default = 2,
        Min = 1,
        Max = 5,
        Rounding = 1,
        Compact = false,
        Callback = function(Value)
        end,
        Tooltip = "Player skeleton thickness"
    });

    _G.GUI.LeftTabBoxes.Skeleton_ESP:AddDivider()

    -- Skeleton for tools
    _G.GUI.LeftTabBoxes.Skeleton_ESP:AddToggle("Skeleton_Tool_Enabled", {
        Text = "Tool Skeletons",
        Default = false,
        Tooltip = "Draw skeleton for tools",
        Callback = function(Value)
        end
    }):AddColorPicker("Skeleton_Tool_Color", {
		Default = Color3.fromRGB(255, 255, 255),
		Title = "Tool Skeleton Color",
		Transparency = 0,
		Callback = function(Value)
		end
	}):AddKeyPicker("Skeleton_Tool_Keybind", {
		Default = "None",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = "Tool skeleton",
		NoUI = false,
		Callback = function(Value)
		end
	});

    _G.GUI.LeftTabBoxes.Skeleton_ESP:AddDivider()

    -- Look Direction ESP UI

_G.GUI.LeftTabBoxes.Look_Direction:AddToggle("LookDirection_Enabled", {
	Text = "Look Direction",
	Default = false,
	Tooltip = "Show arrow above head showing where player is looking",
	Callback = function(Value)
	end
}):AddColorPicker("LookDirection_Color", {
	Default = Color3.fromRGB(100, 255, 100),
	Title = "Look Direction Color",
	Transparency = 0,
	Callback = function(Value)
	end
}):AddKeyPicker("LookDirection_Keybind", {
	Default = "None",
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "Look Direction",
	NoUI = false,
	Callback = function(Value)
	end
});

_G.GUI.LeftTabBoxes.Look_Direction:AddSlider("LookDirection_Size", {
	Text = "Arrow Size",
	Default = 20,
	Min = 10,
	Max = 50,
	Rounding = 1,
	Compact = false,
	Callback = function(Value)
	end,
	Tooltip = "Size of the direction arrow"
});

_G.GUI.LeftTabBoxes.Look_Direction:AddSlider("LookDirection_Distance", {
	Text = "Distance from Head",
	Default = 3,
	Min = 1,
	Max = 10,
	Rounding = 1,
	Compact = false,
	Callback = function(Value)
	end,
	Tooltip = "How far above the head to show the arrow"
});

    -- // Right Tab Boxes

	_G.GUI.RightTabBoxes.ESP:AddToggle("ESP_Box_Enabled", {
		Text = "Box",
		Default = false,
		Tooltip = "Draw boxes around players",
		Callback = function(Value)
		end
	}):AddColorPicker("ESP_Box_Color", {
		Default = Color3.fromRGB(255, 255, 255),
		Title = "Box Color",
		Transparency = 0,
		Callback = function(Value)
		end
	}):AddKeyPicker("ESP_Box_Keybind", {
		Default = "None",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = "Box",
		NoUI = false,
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.ESP:AddDropdown("ESP_Box_Mode", {
		Text = "Mode",
		Values = {"2D", "3D"},
		Default = 1,
		Tooltip = "Box rendering mode",
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.ESP:AddToggle("ESP_Box_Filled", {
		Text = "Filled",
		Default = false,
		Tooltip = "Fill the box with color",
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.ESP:AddDivider()

	_G.GUI.RightTabBoxes.ESP:AddToggle("ESP_Distance_Enabled", {
		Text = "Distance",
		Default = false,
		Tooltip = "Show distance below player",
		Callback = function(Value)
		end
	}):AddColorPicker("ESP_Distance_Color", {
		Default = Color3.fromRGB(255, 255, 255),
		Title = "Distance Color",
		Transparency = 0,
		Callback = function(Value)
		end
	}):AddKeyPicker("ESP_Distance_Keybind", {
		Default = "None",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = "Distance",
		NoUI = false,
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.ESP:AddDivider()

	_G.GUI.RightTabBoxes.ESP:AddToggle("ESP_Name_Enabled", {
		Text = "Name",
		Default = false,
		Tooltip = "Show player name above head",
		Callback = function(Value)
		end
	}):AddColorPicker("ESP_Name_Color", {
		Default = Color3.fromRGB(255, 255, 255),
		Title = "Name Color",
		Transparency = 0,
		Callback = function(Value)
		end
	}):AddKeyPicker("ESP_Name_Keybind", {
		Default = "None",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = "Name",
		NoUI = false,
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.ESP:AddDivider()

	_G.GUI.RightTabBoxes.ESP:AddLabel("ESP Health")

	_G.GUI.RightTabBoxes.ESP:AddToggle("ESP_Health_Enabled", {
		Text = "Enabled",
		Default = false,
		Tooltip = "Show green health bar under name",
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.ESP:AddDivider()

	_G.GUI.RightTabBoxes.ESP:AddToggle("ESP_Snapline_Enabled", {
		Text = "Snapline",
		Default = false,
		Tooltip = "Draw line from top right to player torso",
		Callback = function(Value)
		end
	}):AddColorPicker("ESP_Snapline_Color", {
		Default = Color3.fromRGB(255, 255, 255),
		Title = "Snapline Color",
		Transparency = 0,
		Callback = function(Value)
		end
	}):AddKeyPicker("ESP_Snapline_Keybind", {
		Default = "None",
		SyncToggleState = true,
		Mode = "Toggle",
		Text = "Snapline",
		NoUI = false,
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.ESP:AddDivider()

	_G.GUI.RightTabBoxes.ESP:AddToggle("ESP_TeamCheck", {
		Text = "Team Check",
		Default = false,
		Tooltip = "Don't show ESP for teammates",
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.ESP:AddToggle("ESP_KnockCheck", {
		Text = "Knock Check",
		Default = false,
		Tooltip = "Don't show ESP for knocked players",
		Callback = function(Value)
		end
	});

	task.wait(0.1)
	
-- // ESP Systems
_G.GUI.ESP = {
    Connections = {},
    Objects = {},
    Skeletons = {},
    LookDir = {},
    Initialized = false
}

local ESP_Success, ESP_Error = pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    
    local SkeletonBones = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
    }

    local function IsAlive(player)
        if not player or not player.Character then return false end
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        return humanoid and humanoid.Health > 0
    end

    local function IsKnocked(player)
        if not player or not player.Character then return false end
        local bodyEffects = player.Character:FindFirstChild("BodyEffects")
        if bodyEffects then
            local knocked = bodyEffects:FindFirstChild("K.O")
            if knocked and knocked.Value == true then
                return true
            end
        end
        return false
    end

    local function IsTeammate(player)
        if not player or not LocalPlayer then return false end
        return player.Team == LocalPlayer.Team
    end

    local function GetDistance(player)
        if not player or not player.Character then return 0 end
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart and localRoot then
            return math.floor((rootPart.Position - localRoot.Position).Magnitude)
        end
        return 0
    end

    local function WorldToScreen(position)
        local screenPos, onScreen = Camera:WorldToViewportPoint(position)
        return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
    end

    local function CreateSkeleton(player)
        if not _G.GUI.ESP.Skeletons[player] then
            local lines = {}
            for i = 1, #SkeletonBones do
                local line = Drawing.new("Line")
                line.Thickness = 2
                line.Transparency = 1
                line.Visible = false
                lines[i] = line
            end
            _G.GUI.ESP.Skeletons[player] = lines
        end
    end

    local function RemoveSkeleton(player)
        local skel = _G.GUI.ESP.Skeletons[player]
        if skel then
            for _, line in ipairs(skel) do
                line:Remove()
            end
            _G.GUI.ESP.Skeletons[player] = nil
        end
    end

    local function CreateLookArrow(player)
        if not _G.GUI.ESP.LookDir[player] then
            local arrow = Drawing.new("Line")
            arrow.Thickness = 2
            arrow.Transparency = 1
            arrow.Visible = false
            _G.GUI.ESP.LookDir[player] = arrow
        end
    end
    
    local function RemoveLookArrow(player)
        local arrow = _G.GUI.ESP.LookDir[player]
        if arrow then
            arrow:Remove()
            _G.GUI.ESP.LookDir[player] = nil
        end
    end

    local function CreateESP(player)
        pcall(function()
            if player == LocalPlayer then return end
            if _G.GUI.ESP.Objects[player] then return end
            
            local box = Drawing.new("Square")
            box.Visible = false
            box.Thickness = 3
            box.Filled = false
            box.Transparency = 1
            
            local boxFill = Drawing.new("Square")
            boxFill.Visible = false
            boxFill.Thickness = 1
            boxFill.Filled = true
            boxFill.Transparency = 0.2
            
            local nameText = Drawing.new("Text")
            nameText.Visible = false
            nameText.Center = true
            nameText.Outline = true
            nameText.Size = 18
            nameText.Text = player.Name
            
            local distanceText = Drawing.new("Text")
            distanceText.Visible = false
            distanceText.Center = true
            distanceText.Outline = true
            distanceText.Size = 16
            distanceText.Text = "[ 0 m ]"
            
            local healthBarOutline = Drawing.new("Square")
            healthBarOutline.Visible = false
            healthBarOutline.Thickness = 1
            healthBarOutline.Filled = false
            healthBarOutline.Color = Color3.fromRGB(0, 0, 0)
            healthBarOutline.Transparency = 1
            
            local healthBar = Drawing.new("Square")
            healthBar.Visible = false
            healthBar.Thickness = 1
            healthBar.Filled = true
            healthBar.Color = Color3.fromRGB(0, 255, 0)
            healthBar.Transparency = 1
            
            local snapline = Drawing.new("Line")
            snapline.Visible = false
            snapline.Thickness = 2
            snapline.Transparency = 1
            
            _G.GUI.ESP.Objects[player] = {
                Box = box,
                BoxFill = boxFill,
                Name = nameText,
                Distance = distanceText,
                HealthBarOutline = healthBarOutline,
                HealthBar = healthBar,
                Snapline = snapline
            }
        end)
    end

    local function RemoveESP(player)
        pcall(function()
            if not _G.GUI.ESP.Objects[player] then return end
            local esp = _G.GUI.ESP.Objects[player]
            esp.Box:Remove()
            esp.BoxFill:Remove()
            esp.Name:Remove()
            esp.Distance:Remove()
            esp.HealthBarOutline:Remove()
            esp.HealthBar:Remove()
            esp.Snapline:Remove()
            _G.GUI.ESP.Objects[player] = nil
            
            RemoveSkeleton(player)
            RemoveLookArrow(player)
        end)
    end

    local function UpdateESP()
        pcall(function()
            for player, esp in pairs(_G.GUI.ESP.Objects) do
                if not player or not player.Parent then
                    RemoveESP(player)
                    continue
                end
                
                local shouldShow = true
                
                local teamToggle = _G.GUI.Toggles["ESP_TeamCheck"]
                if teamToggle and teamToggle.Value and IsTeammate(player) then
                    shouldShow = false
                end
                
                local knockToggle = _G.GUI.Toggles["ESP_KnockCheck"]
                if knockToggle and knockToggle.Value and IsKnocked(player) then
                    shouldShow = false
                end
                
                if not IsAlive(player) then
                    shouldShow = false
                end
                
                if not shouldShow then
                    esp.Box.Visible = false
                    esp.BoxFill.Visible = false
                    esp.Name.Visible = false
                    esp.Distance.Visible = false
                    esp.HealthBarOutline.Visible = false
                    esp.HealthBar.Visible = false
                    esp.Snapline.Visible = false
                    continue
                end
                
                local character = player.Character
                if not character then continue end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local head = character:FindFirstChild("Head")
                
                if not rootPart or not humanoid or not head then continue end
                
                local rootPos = rootPart.Position
                local headPos = head.Position + Vector3.new(0, 0.5, 0)
                
                local screenPos, onScreen = WorldToScreen(rootPos)
                local headScreenPos, headOnScreen = WorldToScreen(headPos)
                
                if not onScreen or not headOnScreen then
                    esp.Box.Visible = false
                    esp.BoxFill.Visible = false
                    esp.Name.Visible = false
                    esp.Distance.Visible = false
                    esp.HealthBarOutline.Visible = false
                    esp.HealthBar.Visible = false
                    esp.Snapline.Visible = false
                    continue
                end
                
                local boxHeight = math.abs(headScreenPos.Y - screenPos.Y) * 2.5
                local boxWidth = boxHeight * 0.6
                
                local boxToggle = _G.GUI.Toggles["ESP_Box_Enabled"]
                if boxToggle and boxToggle.Value then
                    esp.Box.Visible = true
                    esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    esp.Box.Position = Vector2.new(screenPos.X - boxWidth / 2, headScreenPos.Y - boxHeight * 0.1)
                    esp.Box.Color = _G.GUI.Options["ESP_Box_Color"].Value
                    
                    local fillToggle = _G.GUI.Toggles["ESP_Box_Filled"]
                    if fillToggle and fillToggle.Value then
                        esp.BoxFill.Visible = true
                        esp.BoxFill.Size = esp.Box.Size
                        esp.BoxFill.Position = esp.Box.Position
                        esp.BoxFill.Color = _G.GUI.Options["ESP_Box_Color"].Value
                    else
                        esp.BoxFill.Visible = false
                    end
                else
                    esp.Box.Visible = false
                    esp.BoxFill.Visible = false
                end
                
                local nameToggle = _G.GUI.Toggles["ESP_Name_Enabled"]
                if nameToggle and nameToggle.Value then
                    esp.Name.Visible = true
                    esp.Name.Position = Vector2.new(screenPos.X, headScreenPos.Y - boxHeight * 0.15)
                    esp.Name.Text = player.Name
                    esp.Name.Color = _G.GUI.Options["ESP_Name_Color"].Value
                else
                    esp.Name.Visible = false
                end
                
                local healthToggle = _G.GUI.Toggles["ESP_Health_Enabled"]
                if healthToggle and healthToggle.Value then
                    local healthPercentage = humanoid.Health / humanoid.MaxHealth
                    local barWidth = boxWidth
                    local barHeight = 4
                    local barX = screenPos.X - barWidth / 2
                    local barY = headScreenPos.Y - boxHeight * 0.15 + 20
                    
                    esp.HealthBarOutline.Visible = true
                    esp.HealthBarOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
                    esp.HealthBarOutline.Position = Vector2.new(barX - 1, barY - 1)
                    
                    esp.HealthBar.Visible = true
                    esp.HealthBar.Size = Vector2.new(barWidth * healthPercentage, barHeight)
                    esp.HealthBar.Position = Vector2.new(barX, barY)
                    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
                else
                    esp.HealthBarOutline.Visible = false
                    esp.HealthBar.Visible = false
                end
                
                local distToggle = _G.GUI.Toggles["ESP_Distance_Enabled"]
                if distToggle and distToggle.Value then
                    local dist = GetDistance(player)
                    esp.Distance.Visible = true
                    esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + boxHeight * 0.4)
                    esp.Distance.Text = "[ " .. tostring(dist) .. " m ]"
                    esp.Distance.Color = _G.GUI.Options["ESP_Distance_Color"].Value
                else
                    esp.Distance.Visible = false
                end
                
                local snapToggle = _G.GUI.Toggles["ESP_Snapline_Enabled"]
                if snapToggle and snapToggle.Value then
                    esp.Snapline.Visible = true
                    esp.Snapline.From = Vector2.new(Camera.ViewportSize.X, 0)
                    esp.Snapline.To = Vector2.new(screenPos.X, screenPos.Y)
                    esp.Snapline.Color = _G.GUI.Options["ESP_Snapline_Color"].Value
                else
                    esp.Snapline.Visible = false
                end
                
                -- Skeleton ESP
                local skelToggle = _G.GUI.Toggles["Skeleton_Player_Enabled"]
                if skelToggle and skelToggle.Value then
                    CreateSkeleton(player)
                    local skele = _G.GUI.ESP.Skeletons[player]
                    local color = _G.GUI.Options["Skeleton_Player_Color"].Value
                    local thickness = _G.GUI.Options["Skeleton_Player_Thickness"].Value

                    for i, bones in ipairs(SkeletonBones) do
                        local p0 = character:FindFirstChild(bones[1])
                        local p1 = character:FindFirstChild(bones[2])
                        local line = skele[i]

                        if p0 and p1 then
                            local s0, o0 = WorldToScreen(p0.Position)
                            local s1, o1 = WorldToScreen(p1.Position)

                            if o0 and o1 then
                                line.Visible = true
                                line.From = s0
                                line.To = s1
                                line.Color = color
                                line.Thickness = thickness
                            else
                                line.Visible = false
                            end
                        else
                            line.Visible = false
                        end
                    end
                else
                    RemoveSkeleton(player)
                end
                
                -- Look Direction
                local lookToggle = _G.GUI.Toggles["LookDirection_Enabled"]
                if lookToggle and lookToggle.Value then
                    CreateLookArrow(player)
                    local arrow = _G.GUI.ESP.LookDir[player]
                    if head then
                        local dist = _G.GUI.Options["LookDirection_Distance"].Value
                        local size = _G.GUI.Options["LookDirection_Size"].Value
                        local dir = head.CFrame.LookVector
                        local from3D = head.Position + Vector3.new(0, dist, 0)
                        local to3D = from3D + dir * (size / 5)

                        local f2d, fo = WorldToScreen(from3D)
                        local t2d, to = WorldToScreen(to3D)
                        if fo and to then
                            arrow.Visible = true
                            arrow.From = f2d
                            arrow.To = t2d
                            arrow.Color = _G.GUI.Options["LookDirection_Color"].Value
                        else
                            arrow.Visible = false
                        end
                    end
                else
                    RemoveLookArrow(player)
                end
            end
        end)
    end

    _G.GUI.ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(CreateESP)
    _G.GUI.ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(RemoveESP)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end

    _G.GUI.ESP.Connections.RenderStepped = RunService.RenderStepped:Connect(UpdateESP)
    _G.GUI.ESP.Initialized = true
end)

if not ESP_Success then
    warn("ESP initialization failed: " .. tostring(ESP_Error))
end
end);

-- // cleanup time
if not _G.GUI.Success then
	print(_G.GUI.Error);
	_G.GUI.Library:Unload();
else
	game:GetService("UserInputService").InputBegan:Connect(function(Input, Processed)
		if not Processed and Input.KeyCode == Enum.KeyCode.M then


			-- // ESP Cleanup
			if _G.GUI.Toggles["ESP_Box_Enabled"] then
				_G.GUI.Toggles["ESP_Box_Enabled"]:SetValue(false)
			end
			if _G.GUI.Toggles["ESP_Name_Enabled"] then
				_G.GUI.Toggles["ESP_Name_Enabled"]:SetValue(false)
			end
			if _G.GUI.Toggles["ESP_Distance_Enabled"] then
				_G.GUI.Toggles["ESP_Distance_Enabled"]:SetValue(false)
			end
			if _G.GUI.Toggles["ESP_Health_Enabled"] then
				_G.GUI.Toggles["ESP_Health_Enabled"]:SetValue(false)
			end
			if _G.GUI.Toggles["ESP_Snapline_Enabled"] then
				_G.GUI.Toggles["ESP_Snapline_Enabled"]:SetValue(false)
			end
			
			task.wait(0.1)
			
			-- Making sure
			if _G.GUI.ESP and _G.GUI.ESP.Initialized then
				
				for _, connection in pairs(_G.GUI.ESP.Connections) do
					if connection then
						connection:Disconnect()
					end
				end
				
				-- Remove all Drawing objects
				for player, esp in pairs(_G.GUI.ESP.Objects) do
					if esp.Box then esp.Box:Remove() end
					if esp.BoxFill then esp.BoxFill:Remove() end
					if esp.Name then esp.Name:Remove() end
					if esp.Distance then esp.Distance:Remove() end
					if esp.HealthBarOutline then esp.HealthBarOutline:Remove() end
					if esp.HealthBar then esp.HealthBar:Remove() end
					if esp.Snapline then esp.Snapline:Remove() end
				end
				
				_G.GUI.ESP.Connections = {}
				_G.GUI.ESP.Objects = {}
				_G.GUI.ESP.Initialized = false
			end
			
			_G.GUI.Library:Unload()
		end
	end)
end

-- // RUNTIME CAMLOCK
if _G.GUI.Success then
	task.spawn(function()
		_G.Variables.KO_Path = _G.Functions.Get_Path(_G.Variables.Character, {"k.o", "ko"})
		_G.Variables.Crew_Path = _G.Functions.Get_Path(_G.Variables.Player, {"crew"})
	end)
	
	_G.Variables.Run_Service.RenderStepped:Connect(function()
		if Stop then return end
		pcall(function()
			_G.Functions.Camlock_Main(_G.Config.Camlock.Flags)
		end)
		pcall(function()
			_G.Functions.Triggerbot_Main(_G.Config.Triggerbot.Flags)
		end)
	end)
	
	_G.Variables.User_Input_Service.InputBegan:Connect(function(Input, Processed)
		if Processed then return end
		if _G.Config.Camlock.Enabled then
			if _G.Config.Camlock.Keybind == Input.KeyCode then
				_G.Functions.Toggle_Camlock()
			end
		end
		if _G.Config.Triggerbot.Enabled then
			if _G.Config.Triggerbot.Keybind == Input.KeyCode then
				_G.Functions.Toggle_Triggerbot()
			end
		end
	end)
end

-- comments below here
--[[


]]--