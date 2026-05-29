-- Project Delta Executor Script
-- Best Practices: Executor-Exclusive functions & cloneref

local function safeGetService(serviceName)
	local service = game:GetService(serviceName)
	return cloneref(service)
end

local Players = safeGetService("Players")
local Workspace = safeGetService("Workspace")
local RunService = safeGetService("RunService")
local ReplicatedStorage = safeGetService("ReplicatedStorage")
local CoreGui = safeGetService("CoreGui")
local UserInputService = safeGetService("UserInputService")

local LocalPlayer = cloneref(Players.LocalPlayer)
local Camera = cloneref(Workspace.CurrentCamera)

-- ==========================================
-- Configuration (Single Source of Truth)
-- ==========================================
getgenv().Config = getgenv().Config
	or {
		ESP = {
			Enabled = false,
			TextColor = Color3.fromRGB(255, 255, 255),
			OutlineColor = Color3.fromRGB(0, 0, 0),
			TextSize = 13,
			Font = 2, -- Drawing.Fonts.Plex
			ShowDistance = true,
			ShowKDR = true,
			ChamsEnabled = false,
			ChamsFillColor = Color3.fromRGB(255, 0, 0),
			ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
			VisibleCheck = false,
			VisibleColor = Color3.fromRGB(0, 255, 0),
			CorpseESPEnabled = false,
			CorpseTextColor = Color3.fromRGB(169, 169, 169),
			CorpseOutlineColor = Color3.fromRGB(0, 0, 0),
			ExitESPEnabled = false,
			ExitTextColor = Color3.fromRGB(255, 165, 0),
			ExitOutlineColor = Color3.fromRGB(0, 0, 0),
			InventoryViewer = false,
		},
		SilentAim = {
			Enabled = false,
			FOVRadius = 150,
			TargetPart = "Head", -- "Head", "Torso", "Random"
			ShowFOV = false,
			ShowSnapline = false,
			VisibleCheck = false,
			VisibleColor = Color3.fromRGB(0, 255, 0),
			BulletTracers = false,
			TracerColor = Color3.fromRGB(255, 255, 255),
			TracerTransparency = 0.5,
		},
		Combat = {
			NoRecoil = false,
			RapidFire = false,
			RapidFireValue = 5,
			InstantHit = false,
		},
		Mods = {
			Fullbright = false,
			NoFog = false,
			Hitsound = false,
			HitsoundType = "Rust",
			HitsoundVolume = 1.0,
			HitsoundCustomId = "",
		},
	}

-- ==========================================
-- WindUI Initialization
-- ==========================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "Skibidi Hub |  Project Delta",
	Icon = "solar:ghost-bold",
	Folder = "Skibidi Hub",
	HideSearchBar = true,
	Topbar = {
		Height = 44,
		ButtonsType = "Mac",
	},
})

local VisualsTab = Window:Tab({
	Title = "Visuals",
	Icon = "solar:eye-bold",
})

local CombatTab = Window:Tab({
	Title = "Combat",
	Icon = "solar:target-bold",
})

local ModsTab = Window:Tab({
	Title = "Mods",
	Icon = "solar:box-bold",
})

local ESPSettingsSection = VisualsTab:Section({
	Title = "ESP",
})

ESPSettingsSection:Toggle({
	Title = "Enable ESP",
	Flag = "EnableESP",
	Value = getgenv().Config.ESP.Enabled,
	Callback = function(state)
		getgenv().Config.ESP.Enabled = state
	end,
})

ESPSettingsSection:Space()

ESPSettingsSection:Colorpicker({
	Title = "Text Color",
	Flag = "TextColor",
	Default = getgenv().Config.ESP.TextColor,
	Callback = function(color)
		getgenv().Config.ESP.TextColor = color
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "Outline Color",
	Flag = "OutlineColor",
	Default = getgenv().Config.ESP.OutlineColor,
	Callback = function(color)
		getgenv().Config.ESP.OutlineColor = color
	end,
})

ESPSettingsSection:Slider({
	Title = "Text Size",
	Flag = "TextSize",
	Step = 1,
	Value = {
		Min = 8,
		Max = 32,
		Default = getgenv().Config.ESP.TextSize,
	},
	Callback = function(value)
		getgenv().Config.ESP.TextSize = value
	end,
})

ESPSettingsSection:Space()

ESPSettingsSection:Dropdown({
	Title = "ESP Font",
	Flag = "ESPFont",
	Values = {
		"UI",
		"System",
		"Plex",
		"Monospace",
	},
	Value = "Plex",
	Callback = function(option)
		local fontMap = {
			["UI"] = 0,
			["System"] = 1,
			["Plex"] = 2,
			["Monospace"] = 3,
		}
		getgenv().Config.ESP.Font = fontMap[option] or 2
	end,
})

ESPSettingsSection:Space()

ESPSettingsSection:Toggle({
	Title = "Enable Chams",
	Flag = "EnableChams",
	Value = getgenv().Config.ESP.ChamsEnabled,
	Callback = function(state)
		getgenv().Config.ESP.ChamsEnabled = state
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "Chams Fill Color",
	Flag = "ChamsFillColor",
	Default = getgenv().Config.ESP.ChamsFillColor,
	Callback = function(color)
		getgenv().Config.ESP.ChamsFillColor = color
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "Chams Outline Color",
	Flag = "ChamsOutlineColor",
	Default = getgenv().Config.ESP.ChamsOutlineColor,
	Callback = function(color)
		getgenv().Config.ESP.ChamsOutlineColor = color
	end,
})

ESPSettingsSection:Space()

ESPSettingsSection:Toggle({
	Title = "Visible Check",
	Flag = "VisibleCheck",
	Value = getgenv().Config.ESP.VisibleCheck,
	Callback = function(state)
		getgenv().Config.ESP.VisibleCheck = state
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "Visible Color",
	Flag = "VisibleColor",
	Default = getgenv().Config.ESP.VisibleColor,
	Callback = function(color)
		getgenv().Config.ESP.VisibleColor = color
	end,
})

ESPSettingsSection:Space()

ESPSettingsSection:Toggle({
	Title = "Enable Corpse ESP",
	Flag = "EnableCorpseESP",
	Value = getgenv().Config.ESP.CorpseESPEnabled,
	Callback = function(state)
		getgenv().Config.ESP.CorpseESPEnabled = state
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "Corpse Text Color",
	Flag = "CorpseTextColor",
	Default = getgenv().Config.ESP.CorpseTextColor,
	Callback = function(color)
		getgenv().Config.ESP.CorpseTextColor = color
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "Corpse Outline Color",
	Flag = "CorpseOutlineColor",
	Default = getgenv().Config.ESP.CorpseOutlineColor,
	Callback = function(color)
		getgenv().Config.ESP.CorpseOutlineColor = color
	end,
})

ESPSettingsSection:Space()

ESPSettingsSection:Toggle({
	Title = "Enable Exit ESP",
	Flag = "EnableExitESP",
	Value = getgenv().Config.ESP.ExitESPEnabled,
	Callback = function(state)
		getgenv().Config.ESP.ExitESPEnabled = state
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "Exit Text Color",
	Flag = "ExitTextColor",
	Default = getgenv().Config.ESP.ExitTextColor,
	Callback = function(color)
		getgenv().Config.ESP.ExitTextColor = color
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "Exit Outline Color",
	Flag = "ExitOutlineColor",
	Default = getgenv().Config.ESP.ExitOutlineColor,
	Callback = function(color)
		getgenv().Config.ESP.ExitOutlineColor = color
	end,
})

local BulletTracersSection = VisualsTab:Section({
	Title = "Bullet Tracers",
})

BulletTracersSection:Toggle({
	Title = "Enable Bullet Tracers",
	Flag = "EnableBulletTracers",
	Value = getgenv().Config.SilentAim.BulletTracers,
	Callback = function(state)
		getgenv().Config.SilentAim.BulletTracers = state
	end,
})

BulletTracersSection:Colorpicker({
	Title = "Tracer Color",
	Flag = "TracerColor",
	Default = getgenv().Config.SilentAim.TracerColor,
	Callback = function(color)
		getgenv().Config.SilentAim.TracerColor = color
	end,
})

BulletTracersSection:Slider({
	Title = "Tracer Transparency",
	Flag = "TracerTransparency",
	Step = 0.05,
	Value = {
		Min = 0,
		Max = 1,
		Default = getgenv().Config.SilentAim.TracerTransparency,
	},
	Callback = function(value)
		getgenv().Config.SilentAim.TracerTransparency = value
	end,
})

local InventoryViewerSection = VisualsTab:Section({
	Title = "Inventory Viewer",
})

InventoryViewerSection:Toggle({
	Title = "Enable Inventory Viewer",
	Flag = "EnableInventoryViewer",
	Value = getgenv().Config.ESP.InventoryViewer,
	Callback = function(state)
		getgenv().Config.ESP.InventoryViewer = state
	end,
})

-- ==========================================
-- UI Combat Tab
-- ==========================================
local CombatSection = CombatTab:Section({
	Title = "Combat Modifications",
})

CombatSection:Toggle({
	Title = "Instant Hit",
	Flag = "InstantHit",
	Value = getgenv().Config.Combat.InstantHit,
	Callback = function(state)
		getgenv().Config.Combat.InstantHit = state
	end,
})

CombatSection:Toggle({
	Title = "No Recoil & Spread",
	Flag = "NoRecoilSpread",
	Value = getgenv().Config.Combat.NoRecoil,
	Callback = function(state)
		getgenv().Config.Combat.NoRecoil = state
	end,
})

local SilentAimSection = CombatTab:Section({
	Title = "Silent Aim",
})

SilentAimSection:Toggle({
	Title = "Enable Silent Aim",
	Flag = "EnableSilentAim",
	Value = getgenv().Config.SilentAim.Enabled,
	Callback = function(state)
		getgenv().Config.SilentAim.Enabled = state
	end,
})

SilentAimSection:Space()

SilentAimSection:Toggle({
	Title = "Show FOV Circle",
	Flag = "ShowFOVCircle",
	Value = getgenv().Config.SilentAim.ShowFOV,
	Callback = function(state)
		getgenv().Config.SilentAim.ShowFOV = state
	end,
})

SilentAimSection:Toggle({
	Title = "Show Snapline",
	Flag = "ShowSnapline",
	Value = getgenv().Config.SilentAim.ShowSnapline,
	Callback = function(state)
		getgenv().Config.SilentAim.ShowSnapline = state
	end,
})

SilentAimSection:Space()

SilentAimSection:Slider({
	Title = "FOV Radius",
	Flag = "FOVRadius",
	Step = 1,
	Value = {
		Min = 10,
		Max = 800,
		Default = getgenv().Config.SilentAim.FOVRadius,
	},
	Callback = function(value)
		getgenv().Config.SilentAim.FOVRadius = value
	end,
})

SilentAimSection:Space()

SilentAimSection:Toggle({
	Title = "Visible Check (Snapline)",
	Flag = "VisibleCheckSnapline",
	Value = getgenv().Config.SilentAim.VisibleCheck,
	Callback = function(state)
		getgenv().Config.SilentAim.VisibleCheck = state
	end,
})

SilentAimSection:Colorpicker({
	Title = "Snapline Color",
	Flag = "SnaplineColor",
	Default = getgenv().Config.SilentAim.VisibleColor,
	Callback = function(color)
		getgenv().Config.SilentAim.VisibleColor = color
	end,
})

-- ==========================================
-- Mods Configuration UI
-- ==========================================
local ModsSection = ModsTab:Section({
	Title = "Gun Mods",
})

ModsSection:Toggle({
	Title = "Rapid Fire",
	Flag = "RapidFire",
	Value = getgenv().Config.Combat.RapidFire,
	Callback = function(state)
		getgenv().Config.Combat.RapidFire = state
	end,
})

ModsSection:Slider({
	Title = "Rapid Fire Multiplier",
	Flag = "RapidFireMultiplier",
	Step = 1,
	Value = {
		Min = 1,
		Max = 20,
		Default = getgenv().Config.Combat.RapidFireValue,
	},
	Callback = function(value)
		getgenv().Config.Combat.RapidFireValue = value
	end,
})

local WorldModsSection = ModsTab:Section({
	Title = "World",
})

WorldModsSection:Toggle({
	Title = "Fullbright",
	Flag = "Fullbright",
	Value = getgenv().Config.Mods.Fullbright,
	Callback = function(state)
		getgenv().Config.Mods.Fullbright = state
	end,
})

WorldModsSection:Toggle({
	Title = "No Fog",
	Flag = "NoFog",
	Value = getgenv().Config.Mods.NoFog,
	Callback = function(state)
		getgenv().Config.Mods.NoFog = state
	end,
})

local HitsoundSection = ModsTab:Section({
	Title = "Hitsound",
})

local originalHitsoundVolumes = {}

local function UpdateDefaultHitsounds(mute)
	local RS = game:GetService("ReplicatedStorage")
	local paths = {
		{"SFX", "Hits", "MeleeHits", "Blood", "Hit"},
		{"SFX", "Hits", "ProjectileHits", "Blood", "Hit"},
		{"SFX", "Hits", "ProjectileHits", "Default", "Hit"}
	}
	
	for _, path in ipairs(paths) do
		local current = RS
		for _, name in ipairs(path) do
			if current then
				current = current:FindFirstChild(name)
			end
		end
		
		if current and current:IsA("Sound") then
			if not originalHitsoundVolumes[current] then
				originalHitsoundVolumes[current] = current.Volume
			end
			current.Volume = mute and 0 or originalHitsoundVolumes[current]
		end
	end
end

HitsoundSection:Toggle({
	Title = "Enable Hitsound",
	Flag = "EnableHitsound",
	Value = getgenv().Config.Mods.Hitsound,
	Callback = function(state)
		getgenv().Config.Mods.Hitsound = state
		UpdateDefaultHitsounds(state)
	end,
})

-- Sync initial state
UpdateDefaultHitsounds(getgenv().Config.Mods.Hitsound)

HitsoundSection:Dropdown({
	Title = "Hitsound Type",
	Flag = "HitsoundType",
	Values = { "Rust", "Minecraft", "Custom" },
	Value = getgenv().Config.Mods.HitsoundType,
	Callback = function(option)
		getgenv().Config.Mods.HitsoundType = option
	end,
})

HitsoundSection:Input({
	Title = "Custom Sound (Asset ID or Local File)",
	Flag = "CustomSoundAssetIDorLocalFile",
	Placeholder = "e.g. 160432334 or hit.mp3",
	Value = getgenv().Config.Mods.HitsoundCustomId,
	Callback = function(value)
		getgenv().Config.Mods.HitsoundCustomId = value
	end,
})

HitsoundSection:Slider({
	Title = "Hitsound Volume",
	Flag = "HitsoundVolume",
	Step = 0.1,
	Value = {
		Min = 0.1,
		Max = 2.0,
		Default = getgenv().Config.Mods.HitsoundVolume,
	},
	Callback = function(value)
		getgenv().Config.Mods.HitsoundVolume = value
	end,
})

-- ==========================================

-- ==========================================
-- UI Settings Tab
-- ==========================================
local SettingsTab = Window:Tab({
	Title = "Settings",
	Icon = "solar:settings-bold",
})

local UISection = SettingsTab:Section({
	Title = "UI",
})

UISection:Keybind({
	Title = "Toggle Menu Key",
	Flag = "ToggleMenuKey",
	Desc = "Change the keybind to hide/show the interface",
	Value = "RightControl",
	Callback = function(keyName)
		pcall(function()
			Window:SetToggleKey(Enum.KeyCode[keyName])
		end)
	end,
})

local ConfigSection = SettingsTab:Section({
	Title = "Config",
})

local ConfigManager = Window.ConfigManager
local currentConfigName = "Default"
local MyConfig = ConfigManager:CreateConfig(currentConfigName)

local function GetConfigs()
	local configs = ConfigManager:AllConfigs()
	if type(configs) == "table" and #configs > 0 then
		return configs
	end
	return { "Default" }
end

local function NotifyWithSound(title, content)
	task.spawn(function()
		pcall(function()
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://98797174600699"
			sound.Volume = 1
			sound.PlayOnRemove = true
			sound.Parent = safeGetService("SoundService")
			sound:Play()
			sound:Destroy()
		end)
	end)
	WindUI:Notify({
		Title = title,
		Content = content,
		Duration = 3,
	})
end

local ConfigDropdown
ConfigDropdown = ConfigSection:Dropdown({
	Title = "Select Config",
	Values = GetConfigs(),
	Value = currentConfigName,
	Callback = function(option)
		currentConfigName = option
		MyConfig = ConfigManager:CreateConfig(currentConfigName)
	end,
})

ConfigSection:Input({
	Title = "New Config Name",
	Placeholder = "Enter name...",
	Callback = function(value)
		if value and value ~= "" then
			currentConfigName = value
			MyConfig = ConfigManager:CreateConfig(currentConfigName)
			ConfigDropdown:Refresh(GetConfigs())
			ConfigDropdown:Select(value)
		end
	end,
})

ConfigSection:Button({
	Title = "Save / Overwrite Configuration",
	Callback = function()
		if MyConfig then
			MyConfig:Save()
			ConfigDropdown:Refresh(GetConfigs())
			NotifyWithSound("Config Saved", "Saved configuration: " .. currentConfigName)
		end
	end,
})

ConfigSection:Button({
	Title = "Load Configuration",
	Callback = function()
		if MyConfig then
			MyConfig:Load()
			NotifyWithSound("Config Loaded", "Loaded configuration: " .. currentConfigName)
		end
	end,
})

ConfigSection:Button({
	Title = "Delete Configuration",
	Callback = function()
		if MyConfig then
			MyConfig:Delete()
			ConfigDropdown:Refresh(GetConfigs())
			NotifyWithSound("Config Deleted", "Deleted configuration: " .. currentConfigName)
		end
	end,
})

ConfigSection:Button({
	Title = "Refresh Config List",
	Callback = function()
		ConfigDropdown:Refresh(GetConfigs())
		NotifyWithSound("Config List Refreshed", "The configuration list has been updated.")
	end,
})

-- ==========================================
-- StatsManager
-- ==========================================
local StatsManager = {
	Cache = {},
}

function StatsManager.GetPlayerKDR(playerName)
	local now = os.clock()
	local cached = StatsManager.Cache[playerName]

	if cached and (now - cached.LastUpdate < 2) then
		return cached.Kills, cached.Deaths
	end

	local kills, deaths = 0, 0
	local replicatedPlayers = ReplicatedStorage:FindFirstChild("Players")
	if replicatedPlayers then
		local playerFolder = replicatedPlayers:FindFirstChild(playerName)
		if playerFolder then
			local status = playerFolder:FindFirstChild("Status")
			local journey = status and status:FindFirstChild("Journey")
			local statistics = journey and journey:FindFirstChild("Statistics")

			if statistics then
				kills = statistics:GetAttribute("Kills") or 0
				deaths = statistics:GetAttribute("Deaths") or 0
			end
		end
	end

	StatsManager.Cache[playerName] = {
		Kills = kills,
		Deaths = deaths,
		LastUpdate = now,
	}

	return kills, deaths
end

-- ==========================================
-- CharacterManager
-- ==========================================
local CharacterManager = {}

CharacterManager.ActiveEnemies = {}
CharacterManager.ActiveCorpses = {}
CharacterManager.ActiveExits = {}

task.spawn(function()
	while task.wait(0.25) do
		-- Update Enemies Cache
		local newEnemies = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if not LocalPlayer or player.UserId == LocalPlayer.UserId then
				continue
			end

			local characterModel = Workspace:FindFirstChild(player.Name)
			if characterModel and characterModel:IsA("Model") then
				local humanoid = characterModel:FindFirstChild("Humanoid")
				local rootPart = characterModel.PrimaryPart or characterModel:FindFirstChild("HumanoidRootPart")
				local head = characterModel:FindFirstChild("Head")

				if humanoid and rootPart and head then
					local health = rootPart:GetAttribute("Health")
					if health == nil then
						health = humanoid.Health
					end

					if health > 0 then
						newEnemies[characterModel] = {
							Player = player,
							Head = head,
							RootPart = rootPart,
						}
					end
				end
			end
		end
		CharacterManager.ActiveEnemies = newEnemies

		-- Update Corpses Cache
		local newCorpses = {}
		local droppedItems = Workspace:FindFirstChild("DroppedItems")
		if droppedItems then
			for _, child in ipairs(droppedItems:GetChildren()) do
				if child:IsA("Model") then
					local humanoid = child:FindFirstChild("Humanoid")
					local head = child:FindFirstChild("Head")
					if humanoid and head then
						local health = child:GetAttribute("Health")
						if health == nil then
							health = humanoid.Health
						end
						if health <= 0 then
							newCorpses[child] = {
								Head = head,
								Name = child.Name .. "'s Corpse",
								IsCorpse = true,
							}
						end
					end
				end
			end
		end
		CharacterManager.ActiveCorpses = newCorpses

		-- Update Exits Cache
		local newExits = {}
		local noCollision = Workspace:FindFirstChild("NoCollision")
		if noCollision then
			local exitLocations = noCollision:FindFirstChild("ExitLocations")
			if exitLocations then
				for _, child in ipairs(exitLocations:GetChildren()) do
					if child.Name == "Exit" and (child:IsA("Model") or child:IsA("BasePart")) then
						local part = child:IsA("Model")
								and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart"))
							or child
						if part then
							newExits[child] = {
								Head = part,
								Name = "Exit",
								IsExit = true,
							}
						end
					end
				end
			end
		end
		CharacterManager.ActiveExits = newExits
	end
end)

function CharacterManager.GetActiveCharacters()
	return CharacterManager.ActiveEnemies
end

function CharacterManager.GetCorpses()
	return CharacterManager.ActiveCorpses
end

function CharacterManager.GetExits()
	return CharacterManager.ActiveExits
end

function CharacterManager.IsVisible(targetHead, characterModel)
	if not LocalPlayer.Character then
		return false
	end
	local origin = Camera.CFrame.Position
	local direction = targetHead.Position - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { LocalPlayer.Character, characterModel }
	params.IgnoreWater = true
	local result = Workspace:Raycast(origin, direction, params)
	return result == nil
end

-- ==========================================
-- TargetManager (Silent Aim Engine)
-- ==========================================
local TargetManager = {
	CurrentTarget = nil,
	PredictedPosition = nil,
}

function TargetManager.GetClosestTargetToMouse()
	local config = getgenv().Config.SilentAim

	local activeCharacters = CharacterManager.GetActiveCharacters()
	local mouseLocation = UserInputService:GetMouseLocation()

	local shortestDistance = config.FOVRadius
	local closestTarget = nil

	for character, playerData in pairs(activeCharacters) do
		local head = playerData.Head
		if not head then
			continue
		end

		local screenPosition, isVisibleOnScreen = Camera:WorldToViewportPoint(head.Position)
		if isVisibleOnScreen then
			local targetVector = Vector2.new(screenPosition.X, screenPosition.Y)
			local distanceToMouse = (targetVector - mouseLocation).Magnitude

			if distanceToMouse <= shortestDistance then
				shortestDistance = distanceToMouse
				closestTarget = playerData
			end
		end
	end

	return closestTarget
end

-- ==========================================
-- CombatManager (FOV & Snapline Graphics)
-- ==========================================
local CombatManager = {
	FOVCircle = Drawing.new("Circle"),
	Snapline = Drawing.new("Line"),
}

-- Initialize Drawings
CombatManager.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
CombatManager.FOVCircle.Thickness = 1
CombatManager.FOVCircle.Filled = false
CombatManager.FOVCircle.Transparency = 1

CombatManager.Snapline.Color = Color3.fromRGB(255, 0, 0)
CombatManager.Snapline.Thickness = 1
CombatManager.Snapline.Transparency = 1

function CombatManager.Update()
	local config = getgenv().Config.SilentAim
	local mouseLocation = UserInputService:GetMouseLocation()

	-- Update FOV Circle
	if config.ShowFOV then
		CombatManager.FOVCircle.Position = mouseLocation
		CombatManager.FOVCircle.Radius = config.FOVRadius
		CombatManager.FOVCircle.Visible = true
	else
		CombatManager.FOVCircle.Visible = false
	end

	-- Update Snapline
	TargetManager.CurrentTarget = TargetManager.GetClosestTargetToMouse()

	if config.ShowSnapline and TargetManager.CurrentTarget then
		local headPosition = TargetManager.CurrentTarget.Head.Position
		local screenPosition, isVisible = Camera:WorldToViewportPoint(headPosition)

		if isVisible then
			local isVisible3D = config.VisibleCheck
				and CharacterManager.IsVisible(
					TargetManager.CurrentTarget.Head,
					TargetManager.CurrentTarget.Player.Character
				)
			CombatManager.Snapline.From = mouseLocation
			CombatManager.Snapline.To = Vector2.new(screenPosition.X, screenPosition.Y)
			CombatManager.Snapline.Color = isVisible3D and config.VisibleColor or Color3.fromRGB(255, 0, 0)
			CombatManager.Snapline.Visible = true
		else
			CombatManager.Snapline.Visible = false
		end
	else
		CombatManager.Snapline.Visible = false
	end
end

-- ==========================================
-- ESPManager
-- ==========================================
local ESPManager = {
	Cache = {},
	ChamsCache = {},
}

function ESPManager.CreateTextDrawing()
	local textDrawing = Drawing.new("Text")
	textDrawing.Center = true
	textDrawing.Outline = true
	return textDrawing
end

function ESPManager.FormatPlayerText(playerData, distanceInMeters)
	local config = getgenv().Config.ESP
	local textLines = { playerData.Name or (playerData.Player and playerData.Player.Name) or "Unknown" }

	if config.ShowKDR and not playerData.IsCorpse and not playerData.IsExit then
		local kills, deaths = StatsManager.GetPlayerKDR(playerData.Player.Name)
		local ratio = (deaths > 0) and (kills / deaths) or kills
		table.insert(textLines, string.format("KDR: %.2f", ratio))
	end

	if config.ShowDistance then
		table.insert(textLines, string.format("(%d m)", distanceInMeters))
	end

	return table.concat(textLines, "\n")
end

function ESPManager.Update()
	local config = getgenv().Config.ESP
	local anyActive = config.Enabled or config.ChamsEnabled or config.CorpseESPEnabled or config.ExitESPEnabled

	if not anyActive then
		for _, textDrawing in pairs(ESPManager.Cache) do
			textDrawing:Remove()
		end
		table.clear(ESPManager.Cache)
		for _, highlight in pairs(ESPManager.ChamsCache) do
			highlight:Destroy()
		end
		table.clear(ESPManager.ChamsCache)
		return
	end

	local activeCharacters = (config.Enabled or config.ChamsEnabled) and CharacterManager.GetActiveCharacters() or {}
	local activeCorpses = config.CorpseESPEnabled and CharacterManager.GetCorpses() or {}
	local activeExits = config.ExitESPEnabled and CharacterManager.GetExits() or {}

	local entitiesToDraw = {}
	for k, v in pairs(activeCharacters) do
		entitiesToDraw[k] = v
	end
	for k, v in pairs(activeCorpses) do
		entitiesToDraw[k] = v
	end
	for k, v in pairs(activeExits) do
		entitiesToDraw[k] = v
	end

	-- Text ESP Cleanup
	for cachedCharacter, textDrawing in pairs(ESPManager.Cache) do
		if not entitiesToDraw[cachedCharacter] then
			textDrawing:Remove()
			ESPManager.Cache[cachedCharacter] = nil
		end
	end

	-- Chams ESP Cleanup
	for cachedCharacter, highlight in pairs(ESPManager.ChamsCache) do
		if not activeCharacters[cachedCharacter] or not config.ChamsEnabled then
			highlight:Destroy()
			ESPManager.ChamsCache[cachedCharacter] = nil
		end
	end

	for character, data in pairs(entitiesToDraw) do
		local isVisible3D = false
		if
			config.VisibleCheck
			and not data.IsCorpse
			and not data.IsExit
			and (config.Enabled or config.ChamsEnabled)
		then
			isVisible3D = CharacterManager.IsVisible(data.Head, character)
		end

		-- Handle Text ESP
		if
			(config.Enabled and not data.IsCorpse and not data.IsExit)
			or (config.CorpseESPEnabled and data.IsCorpse)
			or (config.ExitESPEnabled and data.IsExit)
		then
			local textDrawing = ESPManager.Cache[character]
			if not textDrawing then
				textDrawing = ESPManager.CreateTextDrawing()
				ESPManager.Cache[character] = textDrawing
			end

			local screenPosition, isVisibleOnScreen =
				Camera:WorldToViewportPoint(data.Head.Position + Vector3.new(0, 1.5, 0))

			if isVisibleOnScreen then
				local distanceInMeters = math.floor((Camera.CFrame.Position - data.Head.Position).Magnitude * 0.28)

				textDrawing.Text = ESPManager.FormatPlayerText(data, distanceInMeters)
				textDrawing.Position = Vector2.new(screenPosition.X, screenPosition.Y)

				if data.IsCorpse then
					textDrawing.Color = config.CorpseTextColor
					textDrawing.OutlineColor = config.CorpseOutlineColor
				elseif data.IsExit then
					textDrawing.Color = config.ExitTextColor
					textDrawing.OutlineColor = config.ExitOutlineColor
				else
					textDrawing.Color = isVisible3D and config.VisibleColor or config.TextColor
					textDrawing.OutlineColor = config.OutlineColor
				end

				textDrawing.Size = config.TextSize
				textDrawing.Font = config.Font
				textDrawing.Visible = true
			else
				textDrawing.Visible = false
			end
		end

		-- Handle Chams (Highlight)
		if config.ChamsEnabled and not data.IsCorpse and not data.IsExit then
			local highlight = ESPManager.ChamsCache[character]
			if not highlight then
				highlight = Instance.new("Highlight")
				highlight.Parent = CoreGui
				highlight.Adornee = character
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				ESPManager.ChamsCache[character] = highlight
			end

			highlight.FillColor = isVisible3D and config.VisibleColor or config.ChamsFillColor
			highlight.OutlineColor = config.ChamsOutlineColor
		end
	end
end

-- ==========================================
-- BulletTracerManager
-- ==========================================
local BulletTracerManager = {
	Tracers = {},
}

function BulletTracerManager.AddTracer(origin, hitPos)
	local config = getgenv().Config.SilentAim
	if not config.BulletTracers then
		return
	end

	local attachment0 = Instance.new("Attachment")
	attachment0.WorldPosition = origin
	attachment0.Parent = Workspace.Terrain

	local attachment1 = Instance.new("Attachment")
	attachment1.WorldPosition = hitPos
	attachment1.Parent = Workspace.Terrain

	local beam = Instance.new("Beam")
	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.FaceCamera = true
	beam.Color = ColorSequence.new(config.TracerColor)
	beam.Transparency = NumberSequence.new(config.TracerTransparency)
	beam.Width0 = 0.05
	beam.Width1 = 0.05
	beam.Parent = Workspace.Terrain

	table.insert(BulletTracerManager.Tracers, {
		Beam = beam,
		A0 = attachment0,
		A1 = attachment1,
		ExpireTime = os.clock() + 2,
	})
end

function BulletTracerManager.Update()
	local config = getgenv().Config.SilentAim
	local now = os.clock()

	for i = #BulletTracerManager.Tracers, 1, -1 do
		local tracer = BulletTracerManager.Tracers[i]
		if now > tracer.ExpireTime or not config.BulletTracers then
			if tracer.Beam then tracer.Beam:Destroy() end
			if tracer.A0 then tracer.A0:Destroy() end
			if tracer.A1 then tracer.A1:Destroy() end
			table.remove(BulletTracerManager.Tracers, i)
		else
			if tracer.Beam then
				tracer.Beam.Color = ColorSequence.new(config.TracerColor)
				tracer.Beam.Transparency = NumberSequence.new(config.TracerTransparency)
			end
		end
	end
end

-- ==========================================
-- Bullet Prediction Hook (CreateBullet)
-- ==========================================
local BulletMod = ReplicatedStorage:WaitForChild("Modules", 10)
if BulletMod then
	local FPS = BulletMod:WaitForChild("FPS", 10)
	if FPS then
		local BulletScript = FPS:WaitForChild("Bullet", 10)
		if BulletScript then
			local Bullet = require(BulletScript)
			local oldCreateBullet = Bullet.CreateBullet

			Bullet.CreateBullet = function(...)
				local args = table.pack(...)
				if getgenv().Config.SilentAim.Enabled and TargetManager.CurrentTarget then
					local target = TargetManager.CurrentTarget
					local targetHead = target.Head
					local targetRoot = target.RootPart

					local ammoName = args[7]
					local ammoType = ammoName
						and ReplicatedStorage:WaitForChild("AmmoTypes", 2):FindFirstChild(ammoName)
					local muzzleVelocity = ammoType and ammoType:GetAttribute("MuzzleVelocity") or 3000

					local FunctionLibraryExtension = require(
						ReplicatedStorage:WaitForChild("Modules", 10):WaitForChild("FunctionLibraryExtension", 10)
					)
					local origin = FunctionLibraryExtension
							and FunctionLibraryExtension:GetEstimatedCameraPosition(LocalPlayer)
						or Camera.CFrame.Position

					local targetVelocity = targetRoot.AssemblyLinearVelocity
					local v = muzzleVelocity
					local G = 70

					-- Exact quadratic formula solver for projectile motion
					local timeToHit = (targetHead.Position - origin).Magnitude / v
					for i = 1, 3 do
						local targetPos = targetHead.Position + targetVelocity * timeToHit
						local A = targetPos - origin
						local a = 0.25 * G * G
						local b = A.Y * G - v * v
						local c = A.Magnitude * A.Magnitude
						local discriminant = b * b - 4 * a * c

						if discriminant >= 0 then
							local u1 = (-b - math.sqrt(discriminant)) / (2 * a)
							local u2 = (-b + math.sqrt(discriminant)) / (2 * a)
							local u = u1
							if u < 0 then
								u = u2
							end
							if u > 0 then
								timeToHit = math.sqrt(u)
							end
						end
					end

					local finalPredictedPos = targetHead.Position + targetVelocity * timeToHit
					local finalDrop = 0.5 * G * (timeToHit ^ 2)
					local aimPos = finalPredictedPos + Vector3.new(0, finalDrop, 0)

					TargetManager.PredictedPosition = finalPredictedPos

					args[5] = {
						CFrame = CFrame.lookAt(origin, aimPos),
					}

					if getgenv().Config.SilentAim.BulletTracers then
						BulletTracerManager.AddTracer(origin, TargetManager.PredictedPosition)
					end
				else
					if getgenv().Config.SilentAim.BulletTracers then
						local FunctionLibraryExtension = require(
							ReplicatedStorage:WaitForChild("Modules", 10):WaitForChild("FunctionLibraryExtension", 10)
						)
						local origin = FunctionLibraryExtension
								and FunctionLibraryExtension:GetEstimatedCameraPosition(LocalPlayer)
							or Camera.CFrame.Position
						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Exclude
						params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
						local result = Workspace:Raycast(origin, Camera.CFrame.LookVector * 5000, params)
						local hitPos = result and result.Position or (origin + Camera.CFrame.LookVector * 5000)
						BulletTracerManager.AddTracer(origin, hitPos)
					end
				end
				return oldCreateBullet(table.unpack(args, 1, args.n))
			end
		end
	end
end

-- ==========================================
-- Anti-Cheat Metamethod Hook (__namecall)
-- ==========================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	local args = { ... }

	if method == "GetAttribute" then
		local attrName = args[1]

		if getgenv().Config.Combat.NoRecoil then
			if
				attrName == "RecoilStrength"
				or attrName == "AccuracyDeviation"
				or attrName == "Recoil"
				or attrName == "HRecoilMod"
				or attrName == "VRecoilMod"
			then
				return 0
			end
		end

		if getgenv().Config.Combat.InstantHit then
			if attrName == "MuzzleVelocity" then
				print("[Hitscan Debug] Spoofed MuzzleVelocity to 12000")
				return 12000 -- Believable high velocity (approx 4-5x normal)
			elseif attrName == "ProjectileDrop" then
				print("[Hitscan Debug] Spoofed ProjectileDrop to 0.05")
				return 0.05 -- Tiny amount of drop to bypass anti-cheat zero-drop checks
			end
		end
	end

	if not checkcaller() and getgenv().Config.Combat.InstantHit then
		if method == "FireServer" or method == "InvokeServer" then
			local lowerName = string.lower(self.Name)
			if
				string.match(lowerName, "projectile")
				or string.match(lowerName, "hit")
				or string.match(lowerName, "damage")
				or string.match(lowerName, "inflict")
				or string.match(lowerName, "shoot")
				or string.match(lowerName, "fire")
				or string.match(lowerName, "bullet")
				or string.match(lowerName, "reject")
				or string.match(lowerName, "verify")
			then
				print("[Hitscan Outgoing] ->", method, "called on:", self.Name)
				for i, v in ipairs(args) do
					print(
						string.format(
							"   Arg[%d] (%s): %s",
							i,
							typeof(v),
							typeof(v) == "Instance" and v:GetFullName() or tostring(v)
						)
					)
				end
			end
		end
	end

	return oldNamecall(self, ...)
end)

-- ==========================================
-- Incoming Server Response Spy
-- ==========================================
task.spawn(function()
	local function hookRemote(remote)
		if remote:IsA("RemoteEvent") then
			local lowerName = string.lower(remote.Name)
			if
				string.match(lowerName, "reject")
				or string.match(lowerName, "hit")
				or string.match(lowerName, "damage")
				or string.match(lowerName, "inflict")
				or string.match(lowerName, "verify")
				or string.match(lowerName, "bullet")
			then
				remote.OnClientEvent:Connect(function(...)
					if getgenv().Config.Combat.InstantHit then
						print("[Hitscan Incoming] Server replied via ->", remote.Name)
						local args = { ... }
						for i, v in ipairs(args) do
							print(
								string.format(
									"   Arg[%d] (%s): %s",
									i,
									typeof(v),
									typeof(v) == "Instance" and v:GetFullName() or tostring(v)
								)
							)
						end
					end
				end)
			end
		end
	end

	for _, v in ipairs(game:GetDescendants()) do
		hookRemote(v)
	end

	game.DescendantAdded:Connect(hookRemote)
end)

-- ==========================================
-- RapidFire Manager
-- ==========================================
local originalFireRates = {}
local warnedItemsList = false

task.spawn(function()
	while task.wait(1) do
		local ItemsList = ReplicatedStorage:FindFirstChild("ItemsList")

		if ItemsList then
			for _, item in ipairs(ItemsList:GetChildren()) do
				local settingsMod = item:FindFirstChild("SettingsModule")
				if settingsMod and settingsMod:IsA("ModuleScript") then
					local success, stats = pcall(require, settingsMod)
					if success and type(stats) == "table" and stats.FireRate then
						if not originalFireRates[item.Name] then
							originalFireRates[item.Name] = stats.FireRate
						end

						if getgenv().Config.Combat.RapidFire then
							local newRate = originalFireRates[item.Name] / getgenv().Config.Combat.RapidFireValue
							if stats.FireRate ~= newRate then
								stats.FireRate = newRate
								print(
									"[RapidFire Debug] Modified",
									item.Name,
									"FireRate to:",
									newRate,
									"| Original:",
									originalFireRates[item.Name]
								)
							end
						else
							if stats.FireRate ~= originalFireRates[item.Name] then
								stats.FireRate = originalFireRates[item.Name]
								print(
									"[RapidFire Debug] Restored",
									item.Name,
									"FireRate to:",
									originalFireRates[item.Name]
								)
							end
						end
					elseif not success then
						print(
							"[RapidFire Debug] ERROR: Failed to require SettingsModule for",
							item.Name,
							"| Error:",
							tostring(stats)
						)
					end
				end
			end
		else
			if not warnedItemsList then
				print("[RapidFire Debug] ERROR: Could not find ReplicatedStorage.ItemsList!")
				warnedItemsList = true
			end
		end
	end
end)

-- ==========================================
-- WorldMods Manager
-- ==========================================
local WorldModsManager = {}

function WorldModsManager.Update()
	local Lighting = safeGetService("Lighting")

	if getgenv().Config.Mods.Fullbright then
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
	end

	if getgenv().Config.Mods.NoFog then
		Lighting.FogEnd = 100000
		for _, child in ipairs(Lighting:GetChildren()) do
			if child:IsA("Atmosphere") then
				child.Density = 0
			end
		end
	end
end

-- ==========================================
-- Hitsound Manager
-- ==========================================
local HitsoundManager = {
	Initialized = false,
	Remotes = {},
	Sounds = {
		Rust = "rbxassetid://4764109000",
		Minecraft = "rbxassetid://88387457337661",
	},
}

function HitsoundManager.Play()
	local config = getgenv().Config.Mods
	if not config.Hitsound then
		return
	end

	local soundId = nil
	local selected = config.HitsoundType or "Rust"
	if selected == "Custom" then
		local customId = config.HitsoundCustomId or ""
		if customId ~= "" then
			if string.match(customId, "^%d+$") then
				soundId = "rbxassetid://" .. customId
			elseif string.sub(customId, 1, 13) == "rbxassetid://" then
				soundId = customId
			elseif getcustomasset then
				soundId = getcustomasset(customId)
			elseif getsynasset then
				soundId = getsynasset(customId)
			else
				soundId = customId
			end
		else
		end
	else
		soundId = HitsoundManager.Sounds[selected]
	end

	if not soundId or soundId == "" then
		return
	end

	task.spawn(function()
		local success, err = pcall(function()
			local sound = Instance.new("Sound")
			sound.SoundId = soundId
			sound.Volume = config.HitsoundVolume or 1
			sound.PlayOnRemove = true
			sound.Parent = safeGetService("SoundService")
			sound:Play()
			sound:Destroy()
		end)
		if success then
		else
		end
	end)
end

function HitsoundManager.Initialize()
	if HitsoundManager.Initialized then
		return
	end

	local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
	if not Remotes then
		return
	end

	local ProjectileInflict = Remotes:WaitForChild("ProjectileInflict", 2)
	local MeleeInflict = Remotes:WaitForChild("MeleeInflict", 2)
	local MeleeInfIict = Remotes:FindFirstChild("MeleeInfIict")

	local hooked = false

	-- Method 1: hookmetamethod (preferred for namecall)
	if hookmetamethod and newcclosure then
		local success, err = pcall(function()
			local oldNamecall
			oldNamecall = hookmetamethod(
				game,
				"__namecall",
				newcclosure(function(self, ...)
					local method = getnamecallmethod()
					if
						method == "FireServer"
						and (
							self == ProjectileInflict
							or self == MeleeInflict
							or (MeleeInfIict and self == MeleeInfIict)
						)
					then
						pcall(HitsoundManager.Play)
					end
					return oldNamecall(self, ...)
				end)
			)
		end)
		if success then
			hooked = true
		else
		end
	end

	-- Method 2: getrawmetatable (fallback for namecall)
	if not hooked and getrawmetatable and setreadonly and newcclosure then
		local success, err = pcall(function()
			local gameMeta = getrawmetatable(game)
			local oldNamecall = gameMeta.__namecall
			setreadonly(gameMeta, false)
			gameMeta.__namecall = newcclosure(function(self, ...)
				local method = getnamecallmethod()
				if
					method == "FireServer"
					and (self == ProjectileInflict or self == MeleeInflict or (MeleeInfIict and self == MeleeInfIict))
				then
					pcall(HitsoundManager.Play)
				end
				return oldNamecall(self, ...)
			end)
			setreadonly(gameMeta, true)
		end)
		if success then
			hooked = true
		else
		end
	end

	-- Method 3: hookfunction on RemoteEvent.FireServer (covers index method calls like remote.FireServer(remote, ...))
	if hookfunction and newcclosure then
		local success, err = pcall(function()
			local oldFireServer
			oldFireServer = hookfunction(
				Instance.new("RemoteEvent").FireServer,
				newcclosure(function(self, ...)
					if self == ProjectileInflict or self == MeleeInflict or (MeleeInfIict and self == MeleeInfIict) then
						pcall(HitsoundManager.Play)
					end
					return oldFireServer(self, ...)
				end)
			)
		end)
		if success then
			hooked = true
		else
		end
	end

	if not hooked then
		return
	end

	HitsoundManager.Initialized = true
end

-- ==========================================
-- InventoryViewer Manager
-- ==========================================
local verifiedGuns = {
	ADAR15 = true,
	AKM = true,
	AKMN = true,
	AsVal = true,
	FAL = true,
	GoldenMakarov = true,
	IZh12 = true,
	IZh81 = true,
	M4 = true,
	MK23 = true,
	MP443 = true,
	MP5SD = true,
	Makarov = true,
	Mosin = true,
	PKM = true,
	PPSH41 = true,
	R700 = true,
	RPG7 = true,
	SKS = true,
	SVD = true,
	Saiga12 = true,
	TFZ0 = true,
	TFZ98S = true,
	TOZ106 = true,
	TT33 = true,
	VZ61 = true,
}

local verifiedBullets = {
	["338AP"] = true,
	["338T"] = true,
	["45AP"] = true,
	["45Tracer"] = true,
	["12gaAP"] = true,
	["12gaBuckshot"] = true,
	["12gaFlechette"] = true,
	["12gaSlug"] = true,
	["556x45AP"] = true,
	["556x45Tracer"] = true,
	["762x25AP"] = true,
	["762x25Tracer"] = true,
	["762x39AP"] = true,
	["762x39Tracer"] = true,
	["762x51AP"] = true,
	["762x51Tracer"] = true,
	["762x54AP"] = true,
	["762x54Tracer"] = true,
	["9x18AP"] = true,
	["9x18Z"] = true,
	["9x18Tracer"] = true,
	["9x19AP"] = true,
	["9x19Tracer"] = true,
	["9x39AP"] = true,
	["9x39Z"] = true,
	["PG7"] = true,
}

local verifiedMags = {
	["20Rnd556"] = true,
	["20rndFAL"] = true,
	["30rndFAL"] = true,
	["762x25MAG"] = true,
	["762x25Rnd71Mag"] = true,
	["762x25TTMAG"] = true,
	["762x39ImprMAG"] = true,
	["762x39MAG"] = true,
	["762x39Rnd75Mag"] = true,
	["762x54Rnd10Mag"] = true,
	["762x54Rnd20Mag"] = true,
	["9x18MakarovDrumMag"] = true,
	["9x18MakarovMAG"] = true,
	["9x18vzDrumMag"] = true,
	["9x18vzMag"] = true,
	["9x19MP443MAG"] = true,
	["9x19MP5DrumMAG"] = true,
	["9x19MP5MAG"] = true,
	["9x39Mag"] = true,
	["9x39Rnd30Mag"] = true,
	["AmmoBoxPKM100rnd"] = true,
	["MK23ExtMag"] = true,
	["Mag556"] = true,
	["Mag556Rnd100"] = true,
	["MagR700"] = true,
	["MagTFZ98"] = true,
	["MagTOZ106"] = true,
	["PMAG10rnd"] = true,
	["SaigaMag20rnd"] = true,
	["SaigaMag5rnd"] = true,
}

local InventoryViewer = {
	Background = nil,
	Border = nil,
	TitleText = nil,
	TextCache = {},
	CurrentTarget = nil,
	LastViewportSize = nil,
	IsDragging = false,
	DragOffset = Vector2.new(0, 0),
	UserPosition = nil,
	Width = 240,
}

local inventoryConnections = {}

local function clearInventoryConnections()
	for _, conn in ipairs(inventoryConnections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(inventoryConnections)
end

local function getClosestInventoryTargetToMouse()
	local mouseLocation = UserInputService:GetMouseLocation()
	local shortestDistance = math.huge
	local closestTarget = nil

	for _, player in ipairs(Players:GetPlayers()) do
		if player == Players.LocalPlayer then
			continue
		end

		local character = player.Character or Workspace:FindFirstChild(player.Name)
		if character then
			local head = character:FindFirstChild("Head") or character.PrimaryPart
			if head then
				local screenPosition, isVisibleOnScreen = Camera:WorldToViewportPoint(head.Position)
				if isVisibleOnScreen then
					local distanceToMouse = (Vector2.new(screenPosition.X, screenPosition.Y) - mouseLocation).Magnitude
					if distanceToMouse < shortestDistance then
						local replicatedPlayers = ReplicatedStorage:FindFirstChild("Players")
						local playerFolder = replicatedPlayers and replicatedPlayers:FindFirstChild(player.Name)
						if playerFolder then
							shortestDistance = distanceToMouse
							closestTarget = {
								Type = "Player",
								Name = player.Name,
								TargetInstance = player,
								ParentFolder = playerFolder,
							}
						end
					end
				end
			end
		end
	end

	local droppedItems = Workspace:FindFirstChild("DroppedItems")
	if droppedItems then
		for _, child in ipairs(droppedItems:GetChildren()) do
			if child:IsA("Model") then
				local humanoid = child:FindFirstChild("Humanoid")
				local head = child:FindFirstChild("Head")
				if humanoid and head then
					local health = child:GetAttribute("Health")
					if health == nil then
						health = humanoid.Health
					end
					if health <= 0 then
						local screenPosition, isVisibleOnScreen = Camera:WorldToViewportPoint(head.Position)
						if isVisibleOnScreen then
							local distanceToMouse = (Vector2.new(screenPosition.X, screenPosition.Y) - mouseLocation).Magnitude
							if distanceToMouse < shortestDistance then
								shortestDistance = distanceToMouse
								local name = child.Name
								if name:sub(-9) == "'s Corpse" then
									name = name:sub(1, -10)
								end
								closestTarget = {
									Type = "Corpse",
									Name = name,
									TargetInstance = child,
									ParentFolder = child,
								}
							end
						end
					end
				end
			end
		end
	end

	return closestTarget
end

function InventoryViewer.Draw()
	local config = getgenv().Config.ESP
	local enabled = config.InventoryViewer

	if not enabled or not InventoryViewer.CurrentTarget then
		if InventoryViewer.Background then
			InventoryViewer.Background.Visible = false
		end
		if InventoryViewer.Border then
			InventoryViewer.Border.Visible = false
		end
		if InventoryViewer.TitleText then
			InventoryViewer.TitleText.Visible = false
		end
		for _, textDrawing in pairs(InventoryViewer.TextCache) do
			textDrawing:Remove()
		end
		table.clear(InventoryViewer.TextCache)
		return
	end

	local targetInfo = InventoryViewer.CurrentTarget
	local parentFolder = targetInfo.ParentFolder
	local inventoryFolder = parentFolder and parentFolder:FindFirstChild("Inventory")

	local itemsToDraw = {}
	if inventoryFolder then
		for _, child in ipairs(inventoryFolder:GetDescendants()) do
			if not child:FindFirstChild("Inventory") and child:IsA("ObjectValue") then
				table.insert(itemsToDraw, child)
			end
		end

		-- Categorize and sort: Gun (1), Mag (2), Bullet (3), Other (4)
		local function getItemCategory(item)
			local durability = item:GetAttribute("Durability") or item:GetAttribute("durability")
			local maxDurability = item:GetAttribute("MaxDurability") or item:GetAttribute("maxDurability")
			local loadedAmmo = item:GetAttribute("LoadedAmmo") or item:GetAttribute("loadedAmmo")

			local isMag = verifiedMags[item.Name]
			local isGun = (
				verifiedGuns[item.Name]
				or (durability ~= nil and maxDurability ~= nil)
				or (loadedAmmo ~= nil)
			) and not isMag
			if isGun then
				return 1
			end

			if isMag then
				return 2
			end

			if verifiedBullets[item.Name] then
				return 3
			end
			local ammoTypes = ReplicatedStorage:FindFirstChild("AmmoTypes")
			local isBullet = false
			if ammoTypes and ammoTypes:FindFirstChild(item.Name) then
				isBullet = true
			else
				local name = item.Name
				local lower = string.lower(name)
				if
					string.find(lower, "tracer")
					or string.find(lower, "ap")
					or string.find(lower, "slug")
					or string.find(lower, "buckshot")
					or string.find(lower, "flechette")
					or string.find(lower, "12ga")
					or string.find(lower, "pg7")
					or string.find(lower, "s8ko")
				then
					isBullet = true
				elseif
					string.match(name, "^%d+x")
					or string.match(name, "^%d+ga")
					or name == "45AP"
					or name == "338T"
				then
					isBullet = true
				end
			end

			if isBullet then
				return 3
			end

			return 4
		end

		table.sort(itemsToDraw, function(a, b)
			local catA = getItemCategory(a)
			local catB = getItemCategory(b)

			if catA ~= catB then
				return catA < catB
			else
				return a.Name < b.Name
			end
		end)
	end

	local uniqueOrder = {}
	local groupData = {}

	for _, item in ipairs(itemsToDraw) do
		local durability = item:GetAttribute("Durability") or item:GetAttribute("durability")
		local maxDurability = item:GetAttribute("MaxDurability") or item:GetAttribute("maxDurability")
		local loadedAmmo = item:GetAttribute("LoadedAmmo") or item:GetAttribute("loadedAmmo")
		local amount = item:GetAttribute("Amount") or item:GetAttribute("amount")

		local isMag = verifiedMags[item.Name]
		local isGun = (verifiedGuns[item.Name] or (durability ~= nil and maxDurability ~= nil) or (loadedAmmo ~= nil))
			and not isMag

		local ammoTypes = ReplicatedStorage:FindFirstChild("AmmoTypes")
		local isBullet = false
		if verifiedBullets[item.Name] then
			isBullet = true
		elseif ammoTypes and ammoTypes:FindFirstChild(item.Name) then
			isBullet = true
		else
			local name = item.Name
			local lower = string.lower(name)
			if
				string.find(lower, "tracer")
				or string.find(lower, "ap")
				or string.find(lower, "slug")
				or string.find(lower, "buckshot")
				or string.find(lower, "flechette")
				or string.find(lower, "12ga")
				or string.find(lower, "pg7")
				or string.find(lower, "s8ko")
			then
				isBullet = true
			elseif string.match(name, "^%d+x") or string.match(name, "^%d+ga") or name == "45AP" or name == "338T" then
				isBullet = true
			end
		end

		local isValuable = isGun or isMag or isBullet

		local displayName = item.Name
		if isBullet and amount then
			if not groupData[item.Name] then
				groupData[item.Name] = {
					count = 1,
					isValuable = isValuable,
					amount = amount,
					isBullet = true,
				}
				table.insert(uniqueOrder, item.Name)
			else
				groupData[item.Name].amount = (groupData[item.Name].amount or 0) + amount
				groupData[item.Name].count = groupData[item.Name].count + 1
			end
		else
			if isGun then
				if loadedAmmo then
					displayName = string.format("%s [%d]", item.Name, loadedAmmo)
				else
					displayName = item.Name
				end
			elseif isMag then
				if loadedAmmo then
					displayName = string.format("%s [%d]", item.Name, loadedAmmo)
				else
					displayName = item.Name
				end
			elseif amount then
				displayName = string.format("%s x%d", item.Name, amount)
			end

			if not groupData[displayName] then
				groupData[displayName] = {
					count = 1,
					isValuable = isValuable,
					isBullet = false,
				}
				table.insert(uniqueOrder, displayName)
			else
				groupData[displayName].count = groupData[displayName].count + 1
			end
		end
	end

	local viewportSize = Camera.ViewportSize
	local titleHeight = 25
	local itemSpacing = 18
	local padding = 12
	local totalHeight = padding * 2 + titleHeight + (#uniqueOrder * itemSpacing)
	local width = InventoryViewer.Width

	if not InventoryViewer.UserPosition then
		InventoryViewer.UserPosition = Vector2.new(viewportSize.X - width - 100, (viewportSize.Y - totalHeight) / 2)
	end

	local x = InventoryViewer.UserPosition.X
	local y = InventoryViewer.UserPosition.Y

	x = math.clamp(x, 0, viewportSize.X - width)
	y = math.clamp(y, 0, viewportSize.Y - totalHeight)
	InventoryViewer.UserPosition = Vector2.new(x, y)

	-- Position containers
	InventoryViewer.Background.Position = Vector2.new(x, y)
	InventoryViewer.Background.Size = Vector2.new(width, totalHeight)
	InventoryViewer.Background.Visible = true

	InventoryViewer.Border.Position = Vector2.new(x, y)
	InventoryViewer.Border.Size = Vector2.new(width, totalHeight)
	InventoryViewer.Border.Visible = true

	InventoryViewer.TitleText.Position = Vector2.new(x + width / 2, y + padding)
	InventoryViewer.TitleText.Visible = true

	local currentFrameItems = {}

	for index, baseDisplayName in ipairs(uniqueOrder) do
		local data = groupData[baseDisplayName]

		local finalDisplayName = baseDisplayName
		if data.isBullet then
			finalDisplayName = string.format("%s [%d]", baseDisplayName, data.amount)
		elseif data.count > 1 then
			finalDisplayName = string.format("%s x%d", baseDisplayName, data.count)
		end

		local cacheKey = baseDisplayName
		currentFrameItems[cacheKey] = true

		local textDrawing = InventoryViewer.TextCache[cacheKey]
		if not textDrawing then
			textDrawing = Drawing.new("Text")
			textDrawing.Center = false
			textDrawing.Outline = true
			textDrawing.Size = 13
			textDrawing.Font = config.Font or 2
			InventoryViewer.TextCache[cacheKey] = textDrawing
		end

		if data.isValuable then
			textDrawing.Color = Color3.fromRGB(255, 215, 0) -- Gold
		else
			textDrawing.Color = Color3.fromRGB(255, 255, 255) -- White
		end

		local itemY = y + padding + titleHeight + (index - 1) * itemSpacing
		textDrawing.Position = Vector2.new(x + 15, itemY)
		textDrawing.Text = finalDisplayName
		textDrawing.Font = config.Font or 2
		textDrawing.Visible = true
	end

	for key, textDrawing in pairs(InventoryViewer.TextCache) do
		if not currentFrameItems[key] then
			textDrawing:Remove()
			InventoryViewer.TextCache[key] = nil
		end
	end
end

local function setupInventoryListeners(inventoryFolder)
	clearInventoryConnections()
	if not inventoryFolder then
		return
	end

	local function onInventoryChanged()
		InventoryViewer.Draw()
	end

	table.insert(inventoryConnections, inventoryFolder.DescendantAdded:Connect(onInventoryChanged))
	table.insert(inventoryConnections, inventoryFolder.DescendantRemoving:Connect(onInventoryChanged))

	local function connectItemAttributes(item)
		table.insert(
			inventoryConnections,
			item.AttributeChanged:Connect(function(attr)
				if
					attr == "Durability"
					or attr == "durability"
					or attr == "MaxDurability"
					or attr == "maxDurability"
					or attr == "LoadedAmmo"
					or attr == "loadedAmmo"
					or attr == "Amount"
					or attr == "amount"
				then
					InventoryViewer.Draw()
				end
			end)
		)
	end

	for _, child in ipairs(inventoryFolder:GetDescendants()) do
		connectItemAttributes(child)
	end

	table.insert(inventoryConnections, inventoryFolder.DescendantAdded:Connect(connectItemAttributes))
end

function InventoryViewer.Initialize()
	-- Create background
	local background = Drawing.new("Square")
	background.Filled = true
	background.Color = Color3.fromRGB(15, 15, 15)
	background.Transparency = 0.7
	background.Visible = false
	InventoryViewer.Background = background

	-- Create border
	local border = Drawing.new("Square")
	border.Filled = false
	border.Thickness = 1.5
	border.Color = Color3.fromRGB(80, 80, 80)
	border.Transparency = 0.8
	border.Visible = false
	InventoryViewer.Border = border

	-- Create title
	local titleText = Drawing.new("Text")
	titleText.Text = "Inventory Viewer"
	titleText.Size = 14
	titleText.Center = true
	titleText.Outline = true
	titleText.Color = Color3.fromRGB(255, 215, 0) -- Gold title
	titleText.Visible = false
	InventoryViewer.TitleText = titleText

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mousePos = UserInputService:GetMouseLocation()
			if InventoryViewer.Background and InventoryViewer.Background.Visible then
				local bgPos = InventoryViewer.Background.Position
				local bgSize = InventoryViewer.Background.Size
				if mousePos.X >= bgPos.X and mousePos.X <= bgPos.X + bgSize.X and mousePos.Y >= bgPos.Y and mousePos.Y <= bgPos.Y + bgSize.Y then
					InventoryViewer.IsDragging = true
					InventoryViewer.DragOffset = mousePos - bgPos
				end
			end
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and InventoryViewer.IsDragging then
			local mousePos = UserInputService:GetMouseLocation()
			InventoryViewer.UserPosition = mousePos - InventoryViewer.DragOffset
			InventoryViewer.Draw()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			InventoryViewer.IsDragging = false
		end
	end)
end

function InventoryViewer.CheckTarget()
	local config = getgenv().Config.ESP
	local enabled = config.InventoryViewer

	if not enabled then
		if InventoryViewer.Background then
			InventoryViewer.Background.Visible = false
		end
		if InventoryViewer.Border then
			InventoryViewer.Border.Visible = false
		end
		if InventoryViewer.TitleText then
			InventoryViewer.TitleText.Visible = false
		end
		for _, textDrawing in pairs(InventoryViewer.TextCache) do
			textDrawing:Remove()
		end
		table.clear(InventoryViewer.TextCache)
		clearInventoryConnections()
		InventoryViewer.CurrentTarget = nil
		return
	end

	-- Check viewport size changes
	local viewportSize = Camera.ViewportSize
	if not InventoryViewer.LastViewportSize or InventoryViewer.LastViewportSize ~= viewportSize then
		InventoryViewer.LastViewportSize = viewportSize
		InventoryViewer.Draw()
	end

	-- Check closest target to mouse
	local closestTarget = getClosestInventoryTargetToMouse()
	local targetInstance = closestTarget and closestTarget.TargetInstance

	local currentTargetInstance = InventoryViewer.CurrentTarget and InventoryViewer.CurrentTarget.TargetInstance

	if targetInstance ~= currentTargetInstance then
		clearInventoryConnections()
		InventoryViewer.CurrentTarget = closestTarget

		if closestTarget then
			local parentFolder = closestTarget.ParentFolder

			if parentFolder then
				local inventoryFolder = parentFolder:FindFirstChild("Inventory")
				if inventoryFolder then
					setupInventoryListeners(inventoryFolder)
				else
					table.insert(
						inventoryConnections,
						parentFolder.ChildAdded:Connect(function(child)
							if child.Name == "Inventory" and child:IsA("Folder") then
								setupInventoryListeners(child)
								InventoryViewer.Draw()
							end
						end)
					)
				end
			end

			-- Listen to viewport size changes while we have a target
			table.insert(
				inventoryConnections,
				Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
					InventoryViewer.Draw()
				end)
			)

			InventoryViewer.TitleText.Text = string.format("%s's Inventory", closestTarget.Name)
			InventoryViewer.Draw()
		else
			if InventoryViewer.Background then
				InventoryViewer.Background.Visible = false
			end
			if InventoryViewer.Border then
				InventoryViewer.Border.Visible = false
			end
			if InventoryViewer.TitleText then
				InventoryViewer.TitleText.Visible = false
			end
			for _, textDrawing in pairs(InventoryViewer.TextCache) do
				textDrawing:Remove()
			end
			table.clear(InventoryViewer.TextCache)
		end
	end
end

-- Initialize InventoryViewer drawings
InventoryViewer.Initialize()

-- Initialize Hitsounds
pcall(HitsoundManager.Initialize)

-- Spawn target check loop (4 times per second for high performance)
task.spawn(function()
	while true do
		pcall(InventoryViewer.CheckTarget)
		task.wait(0.25)
	end
end)

-- ==========================================
-- Main Loop
-- ==========================================
RunService.RenderStepped:Connect(function()
	ESPManager.Update()
	CombatManager.Update()
	BulletTracerManager.Update()
	WorldModsManager.Update()
end)

Window:SelectTab(1)
