-- // VARIABLES
_G.Config = {
	["Aimbot"] = {
		["Enabled"] = true,
		["Keybind"] = Enum.KeyCode["Q"],
		["Search_Mode"] = "2D", -- "2D", "3D"
		["FOV"] = 500,
		["Sticky_Aim"] = true,
		["Smoothing"] = {
			["Enabled"] = false,
			["Method"] = "lerp", -- "Tween", "Lerp"
			["Tween_Time"] = 9, -- 1-10
			["Lerp_Amount"] = 8 -- percentage each frame
		},
		["Prediction"] = {
			["Enabled"] = false,
			["Type"] = "MoveDirection", -- "Velocity", "MoveDirection"
			["Amount"] = {
				["X"] = 5,
				["Y"] = 5,
				["Z"] = 5
			}
		},
		["Flags"] = {
			["Wall"] = {
				["Enabled"] = false,
				["Ignore_Object_Keybind"] = Enum.KeyCode["V"],
				["Ignored"] = {}, -- dont touch this
				["Start_Raycast_From"] = "Camera", -- "Camera", "Character"
				["Constant"] = {
					["Enabled"] = false,
					["Toggle_Off"] = false
				},
			},
			["KO"] = {
				["Enabled"] = false,
				["Constant"] = {
					["Enabled"] = true,
					["Toggle_Off"] = true
				}
			},
			["Crew"] = {
				["Enabled"] = false,
				["Constant"] = {
					["Enabled"] = true,
					["Toggle_Off"] = true
				}
			},
			["Distance"] = {
				["Enabled"] = false,
				["Amount"] = 1000,
				["Constant"] = {
					["Enabled"] = false,
					["Toggle_Off"] = false
				}
			},
            ["Whitelist"] = {
                ["Enabled"] = false,
                ["Inverted"] = false,
                ["Whitelisted"] = {}, -- ignore
				["Keybind"] = Enum.KeyCode["Z"],
				["Clear_Keybind"] = Enum.KeyCode["P"],
				["Constant"] = {
					["Enabled"] = false,
					["Toggle_Off"] = false
				}
            }
		}
	},
	["Triggerbot"] = {
		["Enabled"] = true,
		["Keybind"] = Enum.KeyCode["Q"],
		["FOV"] = 30,
		["Delay"] = 20, -- milliseconds
		["Search_Mode"] = "raycast",
		["Flags"] = {
			["Wall"] = {
				["Enabled"] = true,
				["Ignore_Object_Keybind"] = "V",
				["Clear_Keybind"] = Enum.KeyCode["P"],
				["Ignored"] = {},
				["Start_Raycast_From"] = "Camera", -- "Camera", "Character"
			},
			["KO"] = {
				["Enabled"] = true
			},
			["Crew"] = {
				["Enabled"] = true
			},
			["Distance"] = {
				["Enabled"] = true,
				["Amount"] = 300
			},
            ["Whitelist"] = {
                ["Enabled"] = false,
                ["Inverted"] = false,
                ["Whitelisted"] = {}, -- ignore
				["Keybind"] = Enum.KeyCode["Z"],
				["Clear_Keybind"] = Enum.KeyCode["P"],
				["Constant"] = {
					["Enabled"] = false,
					["Toggle_Off"] = false
				}
            }
		}
	},
	["Panic"] = {
		["Enabled"] = true,
		["Keybind"] = Enum.KeyCode["M"]
	}
};

_G.Variables = {};
_G.Variables.Players = game:GetService("Players")
_G.Variables.User_Input_Service = game:GetService("UserInputService");
_G.Variables.Run_Service = game:GetService("RunService");
_G.Variables.Tween_Service = game:GetService("TweenService");

_G.Variables.Player = _G.Variables.Players.LocalPlayer;
_G.Variables.Character = _G.Variables.Player.Character or _G.Variables.Player.CharacterAdded:Wait();
_G.Variables.Camera = workspace.CurrentCamera;
_G.Variables.Mouse = _G.Variables.Player:GetMouse();

_G.Variables.Crew_Path = nil;
_G.Variables.KO_Path = nil;

_G.Variables.Aimbot_Toggled = false;
_G.Variables.Aimbot_Target = nil;
_G.Variables.Previous_Tween = nil;

_G.Variables.Triggerbot_Toggled = false;
_G.Variables.Last_Shot = nil;

_G.Variables.Silent_Aim_Toggled = false;

local Stop = false;

_G.Variables.Signals = {
	["Character_Added"] = _G.Variables.Player.CharacterAdded:Connect(function(Character)
		_G.Variables.Character = Character;
	end),
};

-- // FUNCTIONS
_G.Functions = {};

function _G.Functions.Get_Path(Interchangeable : Instance, Names : {string}) : string
	local Found_Object = nil;

	for _, Object in Interchangeable:GetDescendants() do
		if Object:IsA("BoolValue") or Object:IsA("IntValue") or Object:IsA("StringValue") then
			for _, Name in Names do
				if string.find(string.lower(Object.Name), string.lower(Name)) then
					Found_Object = Object;
					break;
				end;
			end;
			if Found_Object then
				break;
			end;
		end;
	end;

	if not Found_Object then
		return nil;
	end;

	local Path_Parts = {};
	local Current = Found_Object;

	while Current and Current ~= game do
		if Current == Interchangeable then
			table.insert(Path_Parts, 1, "[Interchangeable]");
		else
			table.insert(Path_Parts, 1, Current.Name);
		end;
		Current = Current.Parent;
	end;

	if Current == game then
		table.insert(Path_Parts, 1, "game");
	end;

	return table.concat(Path_Parts, "__");
end;

function _G.Functions.Use_Path(Path : string, Name : string) : Instance
	if not Path or Path == "" then
		return nil;
	end;

	local Path_Parts = {};
	for Part in string.gmatch(Path, "[^__]+") do
		table.insert(Path_Parts, Part);
	end;

	local Current = game;

	for _, Object in ipairs(Path_Parts) do
		if Object == "game" then
			Current = game;
		elseif Object == "[Interchangeable]" then
			Current = Current:FindFirstChild(Name);
        elseif Current then
			Current = Current:FindFirstChild(Object)
			if not Current then
				return nil;
			end;
		end;
	end;

	return Current;
end;

function _G.Functions.Ignore_Part(Flag : {})
	local Ignored = {};

	for _, Player in _G.Variables.Players:GetChildren() do
		if Player.Character then
			table.insert(Ignored, Player.Character);
		end;
	end;

	for _, Part in Flag.Ignored do
		table.insert(Ignored, Part);
	end;

	local Params = RaycastParams.new();
	Params.FilterDescendantsInstances = Ignored;
	Params.FilterType = Enum.RaycastFilterType.Exclude;
	Params.RespectCanCollide = false;

	local Distance = (_G.Variables.Camera.CFrame.Position - _G.Variables.Mouse.Hit.Position).Magnitude;

	local End = CFrame.lookAt(_G.Variables.Camera.CFrame.Position, _G.Variables.Mouse.Hit.Position) * CFrame.new(0, 0, -Distance - 5);

	local Raycast = workspace:Raycast(_G.Variables.Camera.CFrame.Position, End.Position - _G.Variables.Camera.CFrame.Position, Params);
	if Raycast and Raycast.Instance then
		table.insert(Flag.Ignored, Raycast.Instance);
	end;
end;

function _G.Functions.Wall_Check(Target : Model, Flags : {}) : boolean
	if not Flags.Wall.Enabled then return true end;

	local Ignored = {};

	for _, Player in _G.Variables.Players:GetChildren() do
		if Player.Character then
			table.insert(Ignored, Player.Character);
		end;
	end;

	for _, Wall in Flags.Wall.Ignored do
		table.insert(Ignored, Wall);
	end;

	local Params = RaycastParams.new();
	Params.FilterType = Enum.RaycastFilterType.Exclude;
	Params.FilterDescendantsInstances = Ignored;
	Params.RespectCanCollide = false;

	local Start_Position = _G.Variables.Camera.CFrame.Position;
	if string.lower(Flags.Wall.Start_Raycast_From) == "character" then
		Start_Position = _G.Variables.Character.HumanoidRootPart.Position
	end;

	local End_Position = Target.HumanoidRootPart.Position;

	local Raycast = workspace:Raycast(Start_Position, End_Position - Start_Position, Params);
	if Raycast then
		return false;
	end;
	return true;
end;

function _G.Functions.KO_Check(Target : Model, Flags : {}) : boolean
	if not Flags.KO.Enabled then return true end;

	if _G.Variables.KO_Path then
		local KO_Object = _G.Functions.Use_Path(_G.Variables.KO_Path, Target.Name);
		if KO_Object then
			return not KO_Object.Value;
		end;
	end;
	return true;
end;

function _G.Functions.Crew_Check(Target : Model, Flags : {}) : boolean
	if not Flags.Crew.Enabled then return true end;

	if _G.Variables.Crew_Path then
		local Target_Crew = _G.Functions.Use_Path(_G.Variables.Crew_Path, Target.Name);
		local Locker_Crew = _G.Functions.Use_Path(_G.Variables.Crew_Path, _G.Variables.Player.Name);
		if Locker_Crew and Target_Crew then
			return Locker_Crew.Value ~= Target_Crew.Value;
		end;
	end;
	return true;
end;

function _G.Functions.Distance_Check(Target : Model, Flags : {}) : boolean
	if not Flags.Distance.Enabled then return true end;
	
	if (_G.Variables.Character.HumanoidRootPart.Position - Target.HumanoidRootPart.Position).Magnitude <= Flags.Distance.Amount then
		return true;
	else
		return false;
	end;
end;

function _G.Functions.Whitelist_Check(Target : Model, Flags : {}) : boolean
	if not Flags.Whitelist.Enabled then return true end;
	
	if table.find(_G.Variables.Whitelisted, Target.Name) then
        if Flags.Whitelist.Inverted then return false end;
        return true;
    else 
        return false;
    end;

    Flags.Whitelist.Enabled = false;
    _G.Variables.Triggerbot_Toggle_5.setToggled(false, true);
    return true;
end;

function _G.Functions.Whitelist(Flags : {})
	local Target = nil;
	local Closest = 900;

	for _, Player in _G.Variables.Players:GetChildren() do
		if Player == _G.Variables.Player then continue end;
		if not Player.Character then continue end;
		Player = Player.Character;

		if not _G.Functions.Wall_Check(Player, Flags) then continue end;
		if not _G.Functions.Crew_Check(Player, Flags) then continue end;
		if not _G.Functions.Distance_Check(Player, Flags) then continue end;

		local Distance = nil;
		
		local Screen_Position, On_Screen = _G.Variables.Camera:WorldToScreenPoint(Player.HumanoidRootPart.Position);
		if not On_Screen then continue end;

		local Player_2D = Vector2.new(Screen_Position.X, Screen_Position.Y);
		local Mouse_2D = Vector2.new(_G.Variables.Mouse.X, _G.Variables.Mouse.Y);

		Distance = (Player_2D - Mouse_2D).Magnitude;
		
		if Distance <= Closest then
			Closest = Distance;
			Target = Player;
		end;
	end;

	if Target then
		if table.find(Flags.Whitelist.Whitelisted, Target.Name) then
			for Index, Name in Flags.Whitelist.Whitelisted do
				if Name == Target.Name then
					table.remove(Flags.Whitelist.Whitelisted, Index)
					return;
				end;
			end;
		else
			table.insert(Flags.Whitelist.Whitelisted, Target.Name);
		end;
	end;
end;

function _G.Functions.Find_Target(Flags : {}, Search_Mode : string, FOV : number) : Model
	local Closest = FOV;
	local Target = nil;

	for _, Player in _G.Variables.Players:GetChildren() do
		if Player == _G.Variables.Player then continue end;
		if not Player.Character then continue end;
		Player = Player.Character;

		if not _G.Functions.Wall_Check(Player, Flags) then continue end;
		if not _G.Functions.KO_Check(Player, Flags) then continue end;
		if not _G.Functions.Crew_Check(Player, Flags) then continue end;
		if not _G.Functions.Distance_Check(Player, Flags) then continue end;
        if not _G.Functions.Whitelist_Check(Player, Flags) then continue end;

		local Distance = nil;
		
		if string.lower(Search_Mode) == "3d" then
			local Player_3D = Player.HumanoidRootPart.Position;
			local Mouse_3D = _G.Variables.Mouse.Hit.Position;

			Distance = (Player_3D - Mouse_3D).Magnitude;
		else
			local Screen_Position, On_Screen = _G.Variables.Camera:WorldToScreenPoint(Player.HumanoidRootPart.Position);
			if not On_Screen then continue end;

			local Player_2D = Vector2.new(Screen_Position.X, Screen_Position.Y);
			local Mouse_2D = Vector2.new(_G.Variables.Mouse.X, _G.Variables.Mouse.Y);

			Distance = (Player_2D - Mouse_2D).Magnitude;
		end;
		
		if Distance <= Closest then
			Closest = Distance;
			Target = Player;
		end;
	end;

	return Target;
end;

function _G.Functions.Predict_Target(Target : Model, Prediction_Config : {}) : Vector3
	if Prediction_Config.Enabled then
		local Prediction_Amount = Vector3.new(0, 0, 0);
		
		if Prediction_Config.Type == "velocity" then
			Prediction_Amount = Target.HumanoidRootPart.Velocity * Vector3.new(Prediction_Config.Amount.X, Prediction_Config.Amount.Y, Prediction_Config.Amount.Z);
		else
			Prediction_Amount = Target.Humanoid.MoveDirection;
			
			Prediction_Amount *= Vector3.new(Prediction_Config.Amount.X, Prediction_Config.Amount.Y, Prediction_Config.Amount.Z);
		end;
		return Prediction_Amount;
	end;
	return Vector3.new(0, 0, 0);
end;

function _G.Functions.Toggle_Aimbot()
	_G.Variables.Aimbot_Toggled = not _G.Variables.Aimbot_Toggled;
	_G.Variables.Aimbot_Target = nil;
	
	if _G.Variables.Previous_Tween then
		_G.Variables.Previous_Tween:Cancel();
		_G.Variables.Previous_Tween = nil;
	end;
end;

function _G.Functions.Toggle_Triggerbot()
	_G.Variables.Triggerbot_Toggled = not _G.Variables.Triggerbot_Toggled;
	print("toggled")
end;

function _G.Functions.Update_Camera(Position : Vector3)
	if _G.Config.Aimbot.Smoothing.Enabled then
		if string.lower(_G.Config.Aimbot.Smoothing.Method) == "tween" then
			_G.Variables.Previous_Tween = _G.Variables.Tween_Service:Create(_G.Variables.Camera, TweenInfo.new(math.clamp(_G.Config.Aimbot.Smoothing.Tween_Time / 100, 0.01, 0.2)), {CFrame = CFrame.lookAt(_G.Variables.Camera.CFrame.Position, Position)});
			_G.Variables.Previous_Tween:Play();
		else
			_G.Variables.Camera.CFrame = _G.Variables.Camera.CFrame:Lerp(CFrame.lookAt(_G.Variables.Camera.CFrame.Position, Position), math.clamp(_G.Config.Aimbot.Smoothing.Lerp_Amount / 100, 0.01, 1));
		end;
	else
		_G.Variables.Camera.CFrame = CFrame.lookAt(_G.Variables.Camera.CFrame.Position, Position);
	end;
end;

function _G.Functions.Aimbot_Main(Flags : {})
	if not _G.Config.Aimbot.Enabled then return end;
	
	if _G.Variables.Previous_Tween then
		_G.Variables.Previous_Tween:Cancel();
		_G.Variables.Previous_Tween = nil;
	end;
	
	if not _G.Variables.Aimbot_Toggled then return end;

	if not _G.Variables.Aimbot_Target or not _G.Config.Aimbot.Sticky_Aim then
		_G.Variables.Aimbot_Target = _G.Functions.Find_Target(Flags, _G.Config.Aimbot.Search_Mode, _G.Config.Aimbot.FOV);
	end;

	if _G.Variables.Aimbot_Target then
		local Flagged = false;

		for Key, Flag in Flags do
			if Flag.Constant and Flag.Constant.Enabled and Flags[Key].Enabled then
				if not _G.Functions[Key .. "_Check"](_G.Variables.Aimbot_Target, Flags) then
					Flagged = true;
					if Flag.Constant.Toggle_Off then
						_G.Functions.Toggle_Aimbot();
						break;
					end;
				end;
			end;
		end;

		if not Flagged then
			_G.Functions.Update_Camera(_G.Variables.Aimbot_Target.HumanoidRootPart.Position + _G.Functions.Predict_Target(_G.Variables.Aimbot_Target, _G.Config.Aimbot.Prediction));
		end;
	end;
end;

function _G.Functions.Triggerbot_Main(Flags : {})
	if not _G.Variables.Triggerbot_Toggled then return end;
	if _G.Variables.Last_Shot and _G.Variables.Last_Shot - os.clock() > _G.Config.Triggerbot.Delay then return end;
	
	local Tool = _G.Variables.Character:FindFirstChildWhichIsA("Tool");
	if Tool then
		local Ammo = Tool:FindFirstChild("AmmoClient") or Tool:FindFirstChild("Ammo");
		if Ammo then
			if Ammo.Value <= 0 then return end;
            
			if _G.Functions.Find_Target(Flags, "2d", _G.Config.Triggerbot.FOV) then
				Tool:Activate();
				_G.Variables.Last_Shot = os.clock();
			end;
		end;
	end;
end;

function _G.Functions.Panic()
	Stop = true;
	for _, Signal in _G.Variables.Signals do
		Signal:Disconnect();
	end;
	_G.GUI.Library:Unload();
	task.defer(function()
		_G.Variables = nil;
		_G.Functions = nil;
		_G.Config = nil;
	end);
end;

-- // RUN TIME
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
			_G.Config.Aimbot.Enabled = Value;
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
			_G.Config.Aimbot.Sticky_Aim = Value;
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

	_G.GUI.LeftTabBoxes.Camlock_Prediction:AddToggle("Camlock_Prediction_Enabled", {
		Text = "Enabled",
		Tooltip = "Enable prediction",
		DisabledTooltip = "", 
		Default = _G.Config.Aimbot.Prediction.Enabled,
		Disabled = false,
		Visible = true, 
		Risky = false,
		Callback = function(Value)
			_G.Config.Aimbot.Prediction.Enabled = Value;
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
		Default = _G.Variables.User_Input_Service:GetStringForKeyCode(_G.Config.Aimbot.Flags.Wall.Ignore_Object_Keybind),
		SyncToggleState = false,
		Mode = "Press",
		Text = "Permanently ignores the wall/part mouse is over",
		NoUI = false,
		Callback = function()
		end,
		ChangedCallback = function(Keybind)
			_G.Config.Aimbot.Flags.Wall.Ignore_Object_Keybind = Keybind;
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
		Default = math.clamp(_G.Config.Triggerbot.FOV, 0, 1000),
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
		Default = _G.Variables.User_Input_Service:GetStringForKeyCode(_G.Config.Triggerbot.Flags.Wall.Ignore_Object_Keybind),
		SyncToggleState = false,
		Mode = "Press",
		Text = "Permanently ignores the wall/part mouse is over",
		NoUI = false,
		Callback = function()
		end,
		ChangedCallback = function(Keybind)
			_G.Config.Triggerbot.Flags.Wall.Ignore_Object_Keybind = Keybind;
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
	_G.GUI.RightTabBoxes.Triggerbot_Whitelist_Flag:AddLabel("Clear Whitelist Keybind"):AddKeyPicker("Triggerbot_Whitelist_Keybind", {
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
	warn(_G.GUI.Error);
	_G.GUI.Library:Unload();
else
	task.spawn(function()
        _G.Variables.KO_Path = _G.Functions.Get_Path(_G.Variables.Character, {"k.o", "ko"});
        _G.Variables.Crew_Path = _G.Functions.Get_Path(_G.Variables.Player, {"crew"});
    end);

    _G.Variables.Signals.Render_Stepped = _G.Variables.Run_Service.RenderStepped:Connect(function()
        if Stop then return end;

        local Aimbot_Success, Aimbot_Error = pcall(function()
            if _G.Functions then
                _G.Functions.Aimbot_Main(_G.Config.Aimbot.Flags);
            end;
        end);
        
        local Triggerbot_Success, Triggerbot_Error = pcall(function()
            if _G.Functions then
                _G.Functions.Triggerbot_Main(_G.Config.Triggerbot.Flags);
            end;
        end);

        if not Aimbot_Success then warn("Aimbot Errored: " .. Aimbot_Error) end;
        if not Triggerbot_Success then warn("Triggerbot Errored: " .. Triggerbot_Error) end;
    end);

    _G.Variables.Signals.User_Input_Service = _G.Variables.User_Input_Service.InputBegan:Connect(function(Input, Processed)
        if Processed then return end;
        if not _G.Config then return end;
        
        if _G.Config.Aimbot.Enabled then
            if _G.Config.Aimbot.Keybind == Input.KeyCode or _G.Config.Aimbot.Keybind == Input.UserInputType then
                _G.Functions.Toggle_Aimbot();
            end;

            if _G.Config.Aimbot.Flags.Wall.Ignore_Object_Keybind == Input.KeyCode or _G.Config.Aimbot.Flags.Wall.Ignore_Object_Keybind == Input.UserInputType then
                _G.Functions.Ignore_Part(_G.Config.Aimbot.Flags.Wall);
            end;

            if _G.Config.Aimbot.Flags.Whitelist.Keybind == Input.KeyCode or _G.Config.Aimbot.Flags.Whitelist.Keybind == Input.UserInputType then
                _G.Functions.Whitelist(_G.Config.Aimbot.Flags);
            end;
        end;
        
        if _G.Config.Triggerbot.Enabled then
            if _G.Config.Triggerbot.Keybind == Input.KeyCode or _G.Config.Triggerbot.Keybind == Input.UserInputType then 
                _G.Functions.Toggle_Triggerbot();
            end;
            
            if _G.Config.Triggerbot.Flags.Wall.Ignore_Object_Keybind == Input.KeyCode or _G.Config.Triggerbot.Flags.Wall.Ignore_Object_Keybind == Input.UserInputType then
                _G.Functions.Ignore_Part(_G.Config.Triggerbot.Flags.Wall);
            end;

            if _G.Config.Triggerbot.Flags.Whitelist.Keybind == Input.KeyCode or _G.Config.Triggerbot.Flags.Whitelist.Keybind == Input.UserInputType then
                _G.Functions.Whitelist(_G.Config.Triggerbot.Flags);
            end;
        end;

        if _G.Config.Panic.Enabled then
            if _G.Config.Panic.Keybind == Input.KeyCode or _G.Config.Panic.Keybind == Input.UserInputType then
                task.defer(_G.Functions.Panic);
            end;
        end;
    end);
end;