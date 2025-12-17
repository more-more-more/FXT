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
		["Camlock_Prediction"] = _G.GUI.Tabs.Camlock:AddLeftGroupbox("Prediction")
	};
	_G.GUI.RightTabBoxes = {
		["Camlock_Wall_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Wall Flag"),
		["Camlock_Knock_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Knock Flag"),
		["Camlock_Crew_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Crew Flag"),
		["Camlock_Distance_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Distance Flag"),
		["Camlock_Whitelist_Flag"] = _G.GUI.Tabs.Camlock:AddRightGroupbox("Whitelist Flag")
	};

	_G.GUI.LeftTabBoxes.Camlock_Activation:AddToggle("Camlock_Enabled", {
		Text = "Camlock",
		Tooltip = "Enables camlock",
		DisabledTooltip = "", 
		Default = true,
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
		Default = true,
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

	-- // ESP Visuals Tab
	_G.GUI.RightTabBoxes.ESP = _G.GUI.Tabs.Visuals:AddRightGroupbox("ESP")

	-- ESP Box Section
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

	-- ESP Distance Section
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

	-- ESP Name Section
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

	-- ESP Health Section
	_G.GUI.RightTabBoxes.ESP:AddLabel("ESP Health")

	_G.GUI.RightTabBoxes.ESP:AddToggle("ESP_Health_Enabled", {
		Text = "Enabled",
		Default = false,
		Tooltip = "Show green health bar under name",
		Callback = function(Value)
		end
	});

	_G.GUI.RightTabBoxes.ESP:AddDivider()

	-- ESP Snapline Section
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

	-- Team Check
	_G.GUI.RightTabBoxes.ESP:AddToggle("ESP_TeamCheck", {
		Text = "Team Check",
		Default = true,
		Tooltip = "Don't show ESP for teammates",
		Callback = function(Value)
		end
	});

	-- Knock Check
	_G.GUI.RightTabBoxes.ESP:AddToggle("ESP_KnockCheck", {
		Text = "Knock Check",
		Default = false,
		Tooltip = "Don't show ESP for knocked players",
		Callback = function(Value)
		end
	});

	-- // Actual ESP Logic
	task.wait(0.1) 
	
	local ESP_Success, ESP_Error = pcall(function()
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")
		local Camera = workspace.CurrentCamera
		local LocalPlayer = Players.LocalPlayer
		local ESPObjects = {}
		


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

		local function CreateESP(player)
			pcall(function()
				if player == LocalPlayer then return end
				if ESPObjects[player] then return end
				
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
				
				ESPObjects[player] = {
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
				if not ESPObjects[player] then return end
				local esp = ESPObjects[player]
				esp.Box:Remove()
				esp.BoxFill:Remove()
				esp.Name:Remove()
				esp.Distance:Remove()
				esp.HealthBarOutline:Remove()
				esp.HealthBar:Remove()
				esp.Snapline:Remove()
				ESPObjects[player] = nil
			end)
		end

		local function UpdateESP()
			pcall(function()
				for player, esp in pairs(ESPObjects) do
					if not player or not player.Parent then
						RemoveESP(player)
						continue
					end
					
					local shouldShow = true
					
					-- Team Check - Use Toggles table
					local teamToggle = _G.GUI.Toggles["ESP_TeamCheck"]
					if teamToggle and teamToggle.Value and IsTeammate(player) then
						shouldShow = false
					end
					
					-- Knock Check
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
					
					-- Update Box
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
					
					-- Update Name
					local nameToggle = _G.GUI.Toggles["ESP_Name_Enabled"]
					if nameToggle and nameToggle.Value then
						esp.Name.Visible = true
						esp.Name.Position = Vector2.new(screenPos.X, headScreenPos.Y - boxHeight * 0.15)
						esp.Name.Text = player.Name
						esp.Name.Color = _G.GUI.Options["ESP_Name_Color"].Value
					else
						esp.Name.Visible = false
					end
					
					-- Update Health Bar
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
					
					-- Update Distance
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
					
					-- Update Snapline
					local snapToggle = _G.GUI.Toggles["ESP_Snapline_Enabled"]
					if snapToggle and snapToggle.Value then
						esp.Snapline.Visible = true
						esp.Snapline.From = Vector2.new(Camera.ViewportSize.X, 0)
						esp.Snapline.To = Vector2.new(screenPos.X, screenPos.Y)
						esp.Snapline.Color = _G.GUI.Options["ESP_Snapline_Color"].Value
					else
						esp.Snapline.Visible = false
					end
				end
			end)
		end

		Players.PlayerAdded:Connect(CreateESP)
		Players.PlayerRemoving:Connect(RemoveESP)
		
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				CreateESP(player)
			end
		end

		RunService.RenderStepped:Connect(UpdateESP)
	end)

	if not ESP_Success then
		warn("ESP Error: " .. tostring(ESP_Error))
	end

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

--[[

Added actual ESP Code for the GUI itself
- Lines 435 to 584

Added the logic / back-end of the GUI
- Lines 586 to 876

I dont think i fucked up anything but if i did i apologize, I did wrap them both in Pcalls and i had to adjust some of your code
]]--