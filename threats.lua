_G.GUI = {};
_G.GUI.Repo = "/";
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
		["Camlock"] = _G.GUI.Window:AddTab("Camlock"),
		["Triggerbot"] = _G.GUI.Window:AddTab("Triggerbot"),
		["Visuals"] = _G.GUI.Window:AddTab("Visuals"),
		["Movement"] = _G.GUI.Window:AddTab("Movement"),
		["Misc"] = _G.GUI.Window:AddTab("Misc"),
		["Settings"] = _G.GUI.Window:AddTab("Settings"),
		["Updates"] = _G.GUI.Window:AddTab("Updates"),
		["Credits"] = _G.GUI.Window:AddTab("Credits"),
	};

	_G.GUI.LeftTabBoxes = {
		["Camlock_Activation"] = _G.GUI.Tabs.Camlock:AddLeftGroupbox("Activation"),
		["Camlock_Smoothing"] = _G.GUI.Tabs.Camlock:AddLeftGroupbox("Smoothing"),
		["Camlock_Prediction"] = _G.GUI.Tabs.Camlock:AddLeftGroupbox("Prediction"),

		["Triggerbot_Activation"] = _G.GUI.Tabs.Triggerbot:AddLeftGroupbox("Activation")
	};
	_G.GUI.RightTabBoxes = {
		["Camlock_Wall_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Wall Flag"),
		["Camlock_Knock_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Knock Flag"),
		["Camlock_Crew_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Crew Flag"),
		["Camlock_Distance_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Distance Flag"),
		["Camlock_Whitelist_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Whitelist Flag"),

		["Triggerbot_Wall_Flag"] = _G.GUI.Tabs.Triggerbot:AddRightGroupbox("Wall Flag"),
		["Triggerbot_Knock_Flag"] = _G.GUI.Tabs.Triggerbot:AddRightGroupbox("Knock Flag"),
		["Triggerbot_Crew_Flag"] = _G.GUI.Tabs.Triggerbot:AddRightGroupbox("Crew Flag"),
		["Triggerbot_Distance_Flag"] = _G.GUI.Tabs.Triggerbot:AddRightGroupbox("Distance Flag"),
		["Triggerbot_Whitelist_Flag"] = _G.GUI.Tabs.Triggerbot:AddRightGroupbox("Whitelist Flag")
	};

	_G.GUI.LeftTabBoxes.Camlock_Activation:AddToggle("Camlock_Enabled", {
		Text = "Camlock",
		Tooltip = "Enables camlock",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Enabled = Value
		end;
	});
	_G.GUI.LeftTabBoxes.Camlock_Activation:AddToggle("Camlock_Sticky_Aim", {
		Text = "Sticky Aim",
		Tooltip = "Stops from constantly searching for new targets",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Sticky_Aim,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		_G.Config.Aimbot.Sticky_Aim = Value
		end;
	});
	_G.GUI.LeftTabBoxes.Camlock_Activation:AddLabel("Keybind"):AddKeyPicker("Camlock_Keybind", {
		Default = _G.Variables.User_Input_Service:GetStringForKeyCode(_G.Config.Aimbot.Keybind),
		SyncToggleState = false,
		Mode = "Toggle",
		Text = "Keybind for camlock",
		NoUI = false,
		Callback = function() -- dont need
		end,
		ChangedCallback = function(Keybind)
			_G.Config.Aimbot.Keybind = Keybind
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
			_G.Config.Aimbot.FOV = Value;
		end,
		Tooltip = "Field of View",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Camlock_Activation:AddDropdown("Camlock_Search_Mode", {
		Values = {"2D", "3D"},
		Default = string.upper(table.find({"2D", "3D"}, _G.Config.Aimbot.Search_Mode)),
		Multi = false,
		Text = "Search_Mode",
		Tooltip = "Method of finding targets",
		DisabledTooltip = "",
		Searchable = false,
		Callback = function(Value)
			_G.Config.Aimbot.Search_Mode = Value;
		end,
		Disabled = false,
		Visible = true,
	});

	_G.GUI.LeftTabBoxes.Camlock_Smoothing:AddToggle("Camlock_Smoothing_Enabled", {
		Text = "Enabled",
		Tooltip = "Enable camera smoothing",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Smoothing.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Smoothing.Enabled = Value;
		end
	});
	_G.GUI.LeftTabBoxes.Camlock_Smoothing:AddDropdown("Camlock_Smoothing_Method", {
		Values = {"Lerp", "Tween"},
		Default = table.find({"Lerp", "Tween"}, _G.Config.Aimbot.Smoothing.Method),
		Multi = false,
		Text = "Method",
		Tooltip = "Smoothing method",
		DisabledTooltip = "",
		Searchable = false,
		Callback = function(Value)
			_G.Config.Aimbot.Smoothing.Method = Value;
		end,
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Camlock_Smoothing:AddSlider("Camlock_Lerp_Amount", {
		Text = "Lerp Amount",
		Default = _G.Config.Aimbot.Smoothing.Lerp_Amount,
		Min = 1,
		Max = 50,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
			_G.Config.Aimbot.Smoothing.Lerp_Amount = Value;
		end,
		Tooltip = "Percentage gained each frame",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Camlock_Smoothing:AddSlider("Camlock_Tween_Time", {
		Text = "Tween Time",
		Default = _G.Config.Aimbot.Smoothing.Tween_Time,
		Min = 1,
		Max = 20,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
			_G.Config.Aimbot.Smoothing.Tween_Time = Value;
		end,
		Tooltip = "Time taken to tween the camera (centiseconds)",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});

	_G.GUI.LeftTabBoxes.Camlock_Smoothing:AddToggle("Camlock_Prediction_Enabled", {
		Text = "Enabled",
		Tooltip = "Enable prediction",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Predction.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Predction.Enabled = Value;
		end
	});
	_G.GUI.LeftTabBoxes.Camlock_Prediction:AddDropdown("Camlock_Prediction_Method", {
		Values = {"MoveDirection", "Velocity"},
		Default = table.find({"MoveDirection", "Velocity"}, _G.Config.Aimbot.Prediction.Method),
		Multi = false,
		Text = "Type",
		Tooltip = "Prediction type (MoveDirection works against antilock)",
		DisabledTooltip = "",
		Searchable = false,
		Callback = function(Value)
			_G.Config.Aimbot.Prediction.Method = Value;
		end,
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Camlock_Prediction:AddSlider("Camlock_Prediction_X", {
		Text = "X",
		Default = _G.Config.Aimbot.Prediction.Amount.X,
		Min = 0,
		Max = 20,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
			_G.Config.Aimbot.Prediction.Amount.X = Value;
		end,
		Tooltip = "",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Camlock_Prediction:AddSlider("Camlock_Prediction_Y", {
		Text = "Y",
		Default = _G.Config.Aimbot.Prediction.Amount.Y,
		Min = 0,
		Max = 20,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
			_G.Config.Aimbot.Prediction.Amount.Y = Value;
		end,
		Tooltip = "	",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Camlock_Prediction:AddSlider("Camlock_Prediction_Z", {
		Text = "Z",
		Default = _G.Config.Aimbot.Prediction.Amount.Z,
		Min = 0,
		Max = 20,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
			_G.Config.Aimbot.Prediction.Amount.Z = Value;
		end,
		Tooltip = "",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});

	_G.GUI.RightTabBoxes.Camlock_Wall_Flag:AddToggle("Camlock_Wall_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks for walls while searching for targets",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Wall.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Wall.Enabled = Value;
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Wall_Flag:AddLabel("Ignore Wall"):AddKeyPicker("Camlock_Wall_Ignore_Keybind", {
		Default = _G.Variables.User_Input_Service:GetStringForKeyCode(_G.Config.Aimbot.Flags.Wall.Ignore_Object_Key),
		SyncToggleState = false,
		Mode = "Press",
		Text = "Permanently ignores the wall/part mouse is over",
		NoUI = false,
		Callback = function()
		end,
		ChangedCallback = function(Keybind)
			_G.Config.Aimbot.Flags.Wall.Ignore_Object_Key = Keybind;
		end, 
	});
	_G.GUI.RightTabBoxes.Camlock_Wall_Flag:AddDropdown("Camlock_Wall_Start", {
		Values = {"Camera", "Character"},
		Default = table.find({"Camera", "Character"}, _G.Config.Aimbot.Flags.Wall.Start_Raycast_From),
		Multi = false,
		Text = "Start Ray From",
		Tooltip = "Chooses where to start the raycast from",
		DisabledTooltip = "",
		Searchable = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Wall.Start_Raycast_From = Value;
		end,
		Disabled = false,
		Visible = true,
	});
	_G.GUI.RightTabBoxes.Camlock_Wall_Flag:AddToggle("Camlock_Wall_Constant_Enabled", {
		Text = "Constant Check",
		Tooltip = "Checks even while locked onto the target",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Wall.Constant.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Wall.Constant.Enabled = Value;
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Wall_Flag:AddToggle("Camlock_Wall_Constant_Toggle", {
		Text = "Toggle Off",
		Tooltip = "Toggles camlock if a wall is detected while locked on",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Wall.Constant.Toggle_Off,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Wall.Constant.Toggle_Off = Value;
		end
	});

	_G.GUI.RightTabBoxes.Camlock_Knock_Flag:AddToggle("Camlock_Knock_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks if player is knocked while searching for targets",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.KO.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.KO.Enabled = Value;
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Knock_Flag:AddToggle("Camlock_Knock_Constant_Enabled", {
		Text = "Constant Check",
		Tooltip = "Checks even while locked onto the target",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Wall.Constant.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Wall.Constant.Enabled = Value;
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Knock_Flag:AddToggle("Camlock_Knock_Constant_Toggle", {
		Text = "Toggle Off",
		Tooltip = "Toggles camlock if target becomes knocked (Constant must be on)",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Wall.Constant.Toggle_Off,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Wall.Constant.Toggle_Off = Value;
		end
	});

	_G.GUI.RightTabBoxes.Camlock_Crew_Flag:AddToggle("Camlock_Crew_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks if player is in your crew while searching for targets",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Crew.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Crew.Enabled = Value;
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Crew_Flag:AddToggle("Camlock_Crew_Constant_Enabled", {
		Text = "Constant Check",
		Tooltip = "Checks even while locked onto the target",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Crew.Constant.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Crew.Constant.Enabled = Value;
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Crew_Flag:AddToggle("Camlock_Crew_Constant_Toggle", {
		Text = "Toggle Off",
		Tooltip = "Toggles camlock if target joins your crew (Constant must be on)",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Crew.Constant.Toggle_Off,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Crew.Constant.Toggle_Off = Value;
		end
	});

	_G.GUI.RightTabBoxes.Camlock_Distance_Flag:AddToggle("Camlock_Distance_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks if player is out of distance while searching for targets",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Distance.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Distance.Enabled = Value;
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Distance_Flag:AddSlider("Camlock_Distance_Value", {
		Text = "Distance",
		Default = math.clamp(_G.Config.Aimbot.Flags.Distance.Amount, 10, 2000),
		Min = 10,
		Max = 2000,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Distance.Amount = Value;
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
		Default = _G.Config.Aimbot.Flags.Distance.Constant.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Distance.Constant.Enabled = Value;
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Distance_Flag:AddToggle("Camlock_Distance_Constant_Toggle", {
		Text = "Toggle Off",
		Tooltip = "Toggles camlock if target becomes is out of range",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Distance.Constant.Toggle_Off,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Distance.Constant.Toggle_Off = Value;
		end
	});

	_G.GUI.RightTabBoxes.Camlock_Whitelist_Flag:AddToggle("Camlock_Whtelist_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks if player is in your whitelist",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Whitelist.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Whitelist_Flag:AddLabel("Whitelist Keybind"):AddKeyPicker("Camlock_Whitelist_Keybind", {
		Default = _G.Variables.User_Input_Service:GetStringForKeyCode(_G.Config.Aimbot.Flags.Whitelist.Keybind),
		SyncToggleState = false,
		Mode = "Press",
		Text = "Adds/removes a player from whitelist",
		NoUI = false,
		Callback = function()
		end,
		ChangedCallback = function(Keybind)
			_G.Config.Aimbot.Flags.Whitelist.Keybind = Keybind;
		end, 
	});
	_G.GUI.RightTabBoxes.Camlock_Whitelist_Flag:AddLabel("Clear Keybind"):AddKeyPicker("Camlock_Whitelist_Keybind", {
		Default = _G.Variables.User_Input_Service:GetStringForKeyCode(_G.Config.Aimbot.Flags.Whitelist.Clear_Keybind),
		SyncToggleState = false,
		Mode = "Press",
		Text = "Removes everyone from whitelist",
		NoUI = false,
		Callback = function()
		end,
		ChangedCallback = function(Keybind)
			_G.Config.Aimbot.Flags.Whitelist.Clear_Keybind = Keybind
		end, 
	});
	_G.GUI.RightTabBoxes.Camlock_Whitelist_Flag:AddToggle("Camlock_Whitelist_Constant_Enabled", {
		Text = "Constant Check",
		Tooltip = "Checks even while locked onto the target",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Whitelist.Constant.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false, 
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Whitelist.Constant.Enabled = Value;
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Whitelist_Flag:AddToggle("Camlock_Whitelist_Constant_Toggle", {
		Text = "Toggle Off",
		Tooltip = "Toggles camlock if you remove target from whitelist (Constant must be on)",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Whitelist.Constant.Toggle_Off,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Whitelist.Constant.Toggle_Off = Value;
		end
	});
	_G.GUI.RightTabBoxes.Camlock_Whitelist_Flag:AddToggle("Camlock_Whtelist_Inverted", {
		Text = "Inverted",
		Tooltip = "Uses whitelist as a blacklist",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Flags.Whitelist.Inverted,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Flags.Whitelist.Inverted = Value;
		end
	});

	_G.GUI.LeftTabBoxes.Triggerbot_Activation:AddToggle("Triggerbot_Enabled", {
		Text = "Triggerbot",
		Tooltip = "Enables triggerbot",
		DisabledTooltip = "", 
		Default = _G.Config.Triggerbot.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Triggerbot.Enabled = Value;
		end
	});
	_G.GUI.LeftTabBoxes.Triggerbot_Activation:AddLabel("Keybind"):AddKeyPicker("Triggerbot_Keybind", {
		Default = _G.Variables.User_Input_Service:GetStringForKeyCode(_G.Config.Triggerbot.Keybind),
		SyncToggleState = false,
		Mode = "Toggle",
		Text = "Keybind for triggerbot",
		NoUI = false,
		Callback = function(Value)
		end,
		ChangedCallback = function(Keybind)
			_G.Config.Triggerbot.Keybind = Keybind;
		end, 
	});
	_G.GUI.LeftTabBoxes.Triggerbot_Activation:AddDropdown("Triggerbot_Search_Mode", {
		Values = {"Raycast", "2D"},
		Default = table.find({"Raycast", "2D"}, _G.Config.Triggerbot.Search_Mode),
		Multi = false,
		Text = "Search_Mode",
		Tooltip = "Method of finding targets",
		DisabledTooltip = "I am disabled!",
		Searchable = false,
		Callback = function(Value)
			_G.Config.Triggerbot.Search_Mode = Value;
		end,
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Triggerbot_Activation:AddSlider("Triggerbot_Delay", {
		Text = "Delay",
		Default = math.clamp(_G.Config.Triggerbot.Delay, 0, 200),
		Min = 0,
		Max = 200,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
			_G.Config.Triggerbot.Delay = Value;
		end,
		Tooltip = "Milliseconds between each shot",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});
	_G.GUI.LeftTabBoxes.Triggerbot_Activation:AddSlider("Triggerbot_FOV", {
		Text = "FOV",
		Default = math.clamp(_G.Config.Triggerbot.FOV),
		Min = 0,
		Max = 1000,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
			_G.Config.Triggerbot.FOV = Value;
		end,
		Tooltip = "Field of View",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});

	_G.GUI.RightTabBoxes.Triggerbot_Wall_Flag:AddToggle("Triggerbot_Wall_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks for walls while searching for targets",
		DisabledTooltip = "", 
		Default = _G.Config.Triggerbot.Flags.Wall.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Triggerbot.Flags.Wall.Enabled = Value;
		end
	});
	_G.GUI.RightTabBoxes.Triggerbot_Wall_Flag:AddLabel("Ignore Wall"):AddKeyPicker("Triggerbot_Wall_Ignore_Keybind", {
		Default = _G.Variables.User_Input_Service:GetStringForKeyCode(_G.Config.Triggerbot.Flags.Wall.Ignore_Object_Key),
		SyncToggleState = false,
		Mode = "Press",
		Text = "Permanently ignores the wall/part mouse is over",
		NoUI = false,
		Callback = function()
		end,
		ChangedCallback = function(Keybind)
			_G.Config.Triggerbot.Flags.Wall.Ignore_Object_Key = Keybind;
		end, 
	});
	_G.GUI.RightTabBoxes.Triggerbot_Wall_Flag:AddDropdown("Triggerbot_Wall_Start", {
		Values = {"Camera", "Character"},
		Default = table.find({"Camera", "Character"}, _G.Config.Triggerbot.Flags.Wall.Start_Raycast_From),
		Multi = false,
		Text = "Start Ray From",
		Tooltip = "Chooses where to start the raycast from",
		DisabledTooltip = "",
		Searchable = false,
		Callback = function(Value)
			_G.Config.Triggerbot.Flags.Wall.Start_Raycast_From = Value;
		end,
		Disabled = false,
		Visible = true,
	});

	_G.GUI.RightTabBoxes.Triggerbot_Knock_Flag:AddToggle("Triggerbot_Knock_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks if player is knocked while searching for targets",
		DisabledTooltip = "", 
		Default = _G.Config.Triggerbot.Flags.KO.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Triggerbot.Flags.KO.Enabled = Value;
		end
	});

	_G.GUI.RightTabBoxes.Triggerbot_Crew_Flag:AddToggle("Triggerbot_Crew_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks if player is in your crew while searching for targets",
		DisabledTooltip = "", 
		Default = _G.Config.Triggerbot.Flags.Crew.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Triggerbot.Flags.Crew.Enabled = Value;
		end
	});

	_G.GUI.RightTabBoxes.Triggerbot_Distance_Flag:AddToggle("Triggerbot_Distance_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks if player is out of distance while searching for targets",
		DisabledTooltip = "", 
		Default = _G.Config.Triggerbot.Flags.Distance.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Triggerbot.Flags.Distance.Enabled = Value;
		end
	});
	_G.GUI.RightTabBoxes.Triggerbot_Distance_Flag:AddSlider("Triggerbot_Distance_Value", {
		Text = "Distance",
		Default = math.clamp(_G.Config.Triggerbot.Flags.Distance.Amount, 10, 2000),
		Min = 10,
		Max = 2000,
		Rounding = 1,
		Compact = false,
		Callback = function(Value)
			_G.Config.Triggerbot.Flags.Distance.Amount = Value;
		end,
		Tooltip = "Players farther than this will be ignored",
		DisabledTooltip = "",
		Disabled = false,
		Visible = true,
	});

	_G.GUI.RightTabBoxes.Triggerbot_Whitelist_Flag:AddToggle("Triggerbot_Whtelist_Enabled", {
		Text = "Enabled",
		Tooltip = "Checks if player is in your whitelist",
		DisabledTooltip = "", 
		Default = _G.Config.Triggerbot.Flags.Whitelist.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Triggerbot.Flags.Whitelist.Enabled = Value;
		end
	});
	_G.GUI.RightTabBoxes.Triggerbot_Whitelist_Flag:AddLabel("Whitelist Keybind"):AddKeyPicker("Triggerbot_Whitelist_Keybind", {
		Default = _G.Variables.User_Input_Service:GetStringForKeyCode(_G.Config.Triggerbot.Flags.Whitelist.Keybind),
		SyncToggleState = false,
		Mode = "Press",
		Text = "Adds/removes a player from whitelist",
		NoUI = false,
		Callback = function()
		end,
		ChangedCallback = function(Keybind)
			_G.Config.Triggerbot.Flags.Whitelist.Keybind = Keybind;
		end, 
	});
	G.GUI.RightTabBoxes.Triggerbot_Whitelist_Flag:AddLabel("Clear Whitelist Keybind"):AddKeyPicker("Triggerbot_Whitelist_Keybind", {
		Default = _G.Variables.User_Input_Service:GetStringForKeyCode(_G.Config.Triggerbot.Flags.Whitelist.Clear_Keybind),
		SyncToggleState = false,
		Mode = "Press",
		Text = "Adds/removes a player from whitelist",
		NoUI = false,
		Callback = function()
		end,
		ChangedCallback = function(Keybind)
			_G.Config.Triggerbot.Flags.Whitelist.Clear_Keybind = Keybind;
		end, 
	});
	_G.GUI.RightTabBoxes.Triggerbot_Whitelist_Flag:AddToggle("Triggerbot_Whtelist_Inverted", {
		Text = "Inverted",
		Tooltip = "Uses whitelist as a blacklist",
		DisabledTooltip = "", 
		Default = _G.Config.Triggerbot.Flags.Whitelist.Inverted,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Triggerbot.Flags.Whitelist.Inverted = Value;
		end
	});
end);

if not _G.GUI.Success then
	print(_G.GUI.Error);
	_G.GUI.Library:Unload();
else
	game:GetService("UserInputService").InputBegan:Connect(function(Input, Processed)
		if not Processed and Input.KeyCode == Enum.KeyCode.M then
			_G.GUI.Library:Unload();
		end;
	end);
end;