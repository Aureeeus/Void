if getgenv()._DeltaScriptCleanup then
	pcall(getgenv()._DeltaScriptCleanup)
end

local ConnectionList = {}
local ThreadList = {}

getgenv()._DeltaScriptCleanup = function()
	for _, connection in pairs(ConnectionList) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	if getgenv()._clearInventoryConnections then
		pcall(getgenv()._clearInventoryConnections)
	end
	for _, thread in pairs(ThreadList) do
		pcall(function()
			task.cancel(thread)
		end)
	end
	if getgenv().CombatManager then
		pcall(function()
			if getgenv().CombatManager.FOVCircle then
				getgenv().CombatManager.FOVCircle:Remove()
			end
			if getgenv().CombatManager.Snapline then
				getgenv().CombatManager.Snapline:Remove()
			end
		end)
	end

	if getgenv().ESPManager and getgenv().ESPManager.Cache then
		for _, cacheData in pairs(getgenv().ESPManager.Cache) do
			pcall(function()
				if type(cacheData) == "table" then
					cacheData.Text:Remove()
					if cacheData.DistanceText then
						cacheData.DistanceText:Remove()
					end
					if cacheData.Bg then
						cacheData.Bg:Remove()
					end
					if cacheData.Bar then
						cacheData.Bar:Remove()
					end
				else
					cacheData:Remove()
				end
			end)
		end
	end

	if getgenv().InventoryViewer and getgenv().InventoryViewer.TextCache then
		for _, textDrawing in pairs(getgenv().InventoryViewer.TextCache) do
			pcall(function()
				textDrawing:Remove()
			end)
		end
		if getgenv().InventoryViewer.Background then
			pcall(function()
				getgenv().InventoryViewer.Background:Remove()
			end)
		end
		if getgenv().InventoryViewer.Border then
			pcall(function()
				getgenv().InventoryViewer.Border:Remove()
			end)
		end
		if getgenv().InventoryViewer.TitleText then
			pcall(function()
				getgenv().InventoryViewer.TitleText:Remove()
			end)
		end
		if getgenv().InventoryViewer.DividerText then
			pcall(function()
				getgenv().InventoryViewer.DividerText:Remove()
			end)
		end
	end

	if getgenv().WindUI_Window then
		pcall(function()
			getgenv().WindUI_Window:Destroy()
		end)
	end

	if getgenv().DeltaChamsCache then
		for _, highlight in pairs(getgenv().DeltaChamsCache) do
			pcall(function()
				highlight:Destroy()
			end)
		end
	end
	getgenv().DeltaChamsCache = {}

	if getgenv().DeltaTracersCache then
		for _, tracer in pairs(getgenv().DeltaTracersCache) do
			pcall(function()
				if tracer.Beam then
					tracer.Beam:Destroy()
				end
				if tracer.A0 then
					tracer.A0:Destroy()
				end
				if tracer.A1 then
					tracer.A1:Destroy()
				end
				if tracer.Beams then
					for _, b in pairs(tracer.Beams) do
						b.Beam:Destroy()
						b.A0:Destroy()
						b.A1:Destroy()
					end
				end
			end)
		end
	end
	getgenv().DeltaTracersCache = {}

	-- Reset InstantHit state so arg dump fires fresh and stale shot info doesn't persist
	getgenv().DeltaInflictDumped = nil
	getgenv().DeltaLastShotInfo = nil

	print("[Delta Cleanup] --- Starting Memory Wipe ---")
	print("[Delta Cleanup] Disconnected loops:", #ConnectionList)
	print("[Delta Cleanup] Config present before wipe:", getgenv().Config ~= nil)

	getgenv().Config = nil

	print("[Delta Cleanup] Config present after wipe:", getgenv().Config ~= nil)
	print("[Delta Cleanup] --- Wipe Complete. Initializing Fresh UI ---")
end

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
			ShowHealthBar = false,
			TextColor = Color3.fromRGB(255, 255, 255),
			OutlineColor = Color3.fromRGB(0, 0, 0),
			TextSize = 13,
			Font = 2, -- Drawing.Fonts.Plex
			ShowDistance = true,
			ShowKDR = true,
			ChamsEnabled = false,
			ChamsFillColor = Color3.fromRGB(255, 0, 0),
			NPCChamsFillColor = Color3.fromRGB(255, 0, 0),
			ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
			VisibleCheck = false,
			VisibleColor = Color3.fromRGB(0, 255, 0),
			NPCESPEnabled = false,
			NPCTextColor = Color3.fromRGB(255, 255, 255),
			NPCOutlineColor = Color3.fromRGB(0, 0, 0),
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
			TargetType = "Players",
			FOVRadius = 150,
			TargetPart = "Head",
			ShowFOV = false,
			ShowSnapline = false,
			VisibleCheck = false,
			VisibleColor = Color3.fromRGB(0, 255, 0),
			BulletTracers = false,
			TracerType = "Default",
			TracerColor = Color3.fromRGB(255, 255, 255),
			TracerTransparency = 0.5,
			TracerGlowEffect = false,
		},
		Combat = {
			NoRecoil = false,
			NoSpread = false,
			InstantHit = false,
			InstantADS = false,
			ADSZoomMultiplier = 1.0,
			HideViewmodelOnADS = false,
			RapidFire = false,
			RapidFireValue = 3,
			FlyKeybind = "Y",
		},
		Mods = {
			FOV = 70,
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
getgenv().WindUI_Window = Window

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

ESPSettingsSection:Toggle({
	Title = "Show Health Bar",
	Flag = "ShowHealthBar",
	Value = getgenv().Config.ESP.ShowHealthBar,
	Callback = function(state)
		getgenv().Config.ESP.ShowHealthBar = state
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
	Title = "Player Chams Fill Color",
	Flag = "ChamsFillColor",
	Default = getgenv().Config.ESP.ChamsFillColor,
	Callback = function(color)
		getgenv().Config.ESP.ChamsFillColor = color
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "NPC Chams Fill Color",
	Flag = "NPCChamsFillColor",
	Default = getgenv().Config.ESP.NPCChamsFillColor,
	Callback = function(color)
		getgenv().Config.ESP.NPCChamsFillColor = color
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
	Title = "Enable NPC ESP",
	Flag = "EnableNPCESP",
	Value = getgenv().Config.ESP.NPCESPEnabled,
	Callback = function(state)
		getgenv().Config.ESP.NPCESPEnabled = state
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "NPC Text Color",
	Flag = "NPCTextColor",
	Default = getgenv().Config.ESP.NPCTextColor,
	Callback = function(color)
		getgenv().Config.ESP.NPCTextColor = color
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "NPC Outline Color",
	Flag = "NPCOutlineColor",
	Default = getgenv().Config.ESP.NPCOutlineColor,
	Callback = function(color)
		getgenv().Config.ESP.NPCOutlineColor = color
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

BulletTracersSection:Toggle({
	Title = "Glow Effect",
	Flag = "TracerGlowEffect",
	Value = getgenv().Config.SilentAim.TracerGlowEffect,
	Callback = function(state)
		getgenv().Config.SilentAim.TracerGlowEffect = state
	end,
})

BulletTracersSection:Dropdown({
	Title = "Tracer Type",
	Flag = "TracerType",
	Values = { "Default", "Lightning", "Heartbeat" },
	Value = getgenv().Config.SilentAim.TracerType,
	Callback = function(option)
		getgenv().Config.SilentAim.TracerType = option
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
	Title = "Instant ADS",
	Flag = "InstantADS",
	Value = getgenv().Config.Combat.InstantADS,
	Callback = function(state)
		getgenv().Config.Combat.InstantADS = state
	end,
})

CombatSection:Slider({
	Title = "ADS Zoom Multiplier",
	Flag = "ADSZoomMultiplier",
	Step = 0.1,
	Value = {
		Min = 1,
		Max = 20,
		Default = getgenv().Config.Combat.ADSZoomMultiplier,
	},
	Callback = function(value)
		getgenv().Config.Combat.ADSZoomMultiplier = value
	end,
})

CombatSection:Toggle({
	Title = "Hide Viewmodel on ADS",
	Flag = "HideViewmodelOnADS",
	Value = getgenv().Config.Combat.HideViewmodelOnADS,
	Callback = function(state)
		getgenv().Config.Combat.HideViewmodelOnADS = state
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

SilentAimSection:Dropdown({
	Title = "Target Type",
	Flag = "SilentAimTargetType",
	Values = { "Players", "NPC", "Both" },
	Value = getgenv().Config.SilentAim.TargetType or "Players",
	Callback = function(option)
		getgenv().Config.SilentAim.TargetType = option
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
	Title = "No Recoil",
	Flag = "NoRecoil",
	Value = getgenv().Config.Combat.NoRecoil,
	Callback = function(state)
		getgenv().Config.Combat.NoRecoil = state
	end,
})

ModsSection:Toggle({
	Title = "No Spread",
	Flag = "NoSpread",
	Value = getgenv().Config.Combat.NoSpread,
	Callback = function(state)
		getgenv().Config.Combat.NoSpread = state
	end,
})

ModsSection:Toggle({
	Title = "Rapid Fire",
	Flag = "RapidFire",
	Value = getgenv().Config.Combat.RapidFire,
	Callback = function(state)
		getgenv().Config.Combat.RapidFire = state
	end,
})

-- Fly Feature UI
local FlySection = CombatTab:Section({
	Title = "Fly",
})
FlySection:Keybind({
	Title = "Fly Keybind",
	Flag = "FlyKeybind",
	Desc = "Press to toggle fly",
	Value = getgenv().Config.Combat.FlyKeybind or "Y",
	Callback = function(keyName)
		getgenv().Config.Combat.FlyKeybind = keyName
	end,
})

ModsSection:Slider({
	Title = "Rapid Fire Multiplier",
	Flag = "RapidFireMultiplier",
	Step = 1,
	Value = {
		Min = 1,
		Max = 50,
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

WorldModsSection:Slider({
	Title = "FOV",
	Flag = "FOV",
	Step = 1,
	Value = {
		Min = 70,
		Max = 120,
		Default = getgenv().Config.Mods.FOV or 70,
	},
	Callback = function(value)
		getgenv().Config.Mods.FOV = value
	end,
})

local HitsoundSection = ModsTab:Section({
	Title = "Hitsound",
})

local originalHitsoundVolumes = {}

local function UpdateDefaultHitsounds(mute)
	local RS = game:GetService("ReplicatedStorage")
	local paths = {
		{ "SFX", "Hits", "MeleeHits", "Blood", "Hit" },
		{ "SFX", "Hits", "ProjectileHits", "Blood", "Hit" },
		{ "SFX", "Hits", "ProjectileHits", "Default", "Hit" },
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

local DebugSection = SettingsTab:Section({
	Title = "Debug & Logging",
})

DebugSection:Button({
	Title = "Copy Debug Logs",
	Description = "Copies the last 500 lines of debug logs to your clipboard.",
	Callback = function()
		if setclipboard then
			setclipboard(table.concat(getgenv().DebugLogBuffer or {}, "\n"))
			Window:Notify({
				Title = "Logs Copied",
				Description = "Successfully copied debug logs to clipboard.",
				Time = 3,
			})
		end
	end,
})

DebugSection:Button({
	Title = "Clear Debug Logs",
	Callback = function()
		table.clear(getgenv().DebugLogBuffer or {})
		Window:Notify({
			Title = "Logs Cleared",
			Description = "Debug log buffer has been cleared.",
			Time = 3,
		})
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
			pcall(function()
				task.wait(0.1)
				local data = readfile("WindUI/Skibidi Hub/config/" .. currentConfigName .. ".json")
				local decoded = game:GetService("HttpService"):JSONDecode(data)
				for flag, val in pairs(decoded) do
					if type(val) == "string" then
						local s, r = pcall(function() return Color3.fromHex((val:gsub("#", ""))) end)
						if s and r then
							if getgenv().Config.ESP[flag] ~= nil then getgenv().Config.ESP[flag] = r end
							if getgenv().Config.SilentAim[flag] ~= nil then getgenv().Config.SilentAim[flag] = r end
						end
					end
				end
			end)
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
CharacterManager.ActiveNPCs = {}
CharacterManager.ActiveCorpses = {}
CharacterManager.ActiveExits = {}

local corpseModelsCache = {}
local droppedItems = Workspace:FindFirstChild("DroppedItems")
if droppedItems then
	for _, child in ipairs(droppedItems:GetChildren()) do
		if child:IsA("Model") and child:FindFirstChild("Humanoid") then
			table.insert(corpseModelsCache, child)
		end
	end
	table.insert(ConnectionList, droppedItems.ChildAdded:Connect(function(child)
		if child:IsA("Model") then
			task.wait(0.1)
			if child:FindFirstChild("Humanoid") then
				table.insert(corpseModelsCache, child)
			end
		end
	end))
end

table.insert(
	ThreadList,
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

						local maxHealth = rootPart:GetAttribute("MaxHealth")
						if maxHealth == nil then
							maxHealth = humanoid.MaxHealth
						end

						if health > 0 then
							newEnemies[characterModel] = {
								Player = player,
								Head = head,
								RootPart = rootPart,
								Health = health,
								MaxHealth = maxHealth,
							}
						end
					end
				end
			end
			CharacterManager.ActiveEnemies = newEnemies

			-- Update NPCs Cache
			local newNPCs = {}
			local aiZones = Workspace:FindFirstChild("AiZones")
			if aiZones then
				for _, zone in ipairs(aiZones:GetChildren()) do
					for _, child in ipairs(zone:GetChildren()) do
						if child:IsA("Model") then
							local humanoid = child:FindFirstChild("Humanoid")
							local head = child:FindFirstChild("Head")
							local rootPart = child.PrimaryPart or child:FindFirstChild("HumanoidRootPart")
							if humanoid and head and rootPart then
								local health = rootPart:GetAttribute("Health")
								if health == nil then
									health = humanoid.Health
								end
								local maxHealth = rootPart:GetAttribute("MaxHealth")
								if maxHealth == nil then
									maxHealth = humanoid.MaxHealth
								end
								if health > 0 then
									newNPCs[child] = {
										Head = head,
										RootPart = rootPart,
										Name = child.Name,
										IsNPC = true,
										Health = health,
										MaxHealth = maxHealth,
									}
								end
							end
						end
					end
				end
			end
			CharacterManager.ActiveNPCs = newNPCs

			-- Update Corpses Cache
			local newCorpses = {}
			for i = #corpseModelsCache, 1, -1 do
				local child = corpseModelsCache[i]
				if not child.Parent then
					table.remove(corpseModelsCache, i)
					continue
				end
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
				else
					table.remove(corpseModelsCache, i)
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
)

function CharacterManager.GetActiveCharacters()
	return CharacterManager.ActiveEnemies
end

function CharacterManager.GetNPCs()
	return CharacterManager.ActiveNPCs
end

function CharacterManager.GetCorpses()
	return CharacterManager.ActiveCorpses
end

function CharacterManager.GetExits()
	return CharacterManager.ActiveExits
end

CharacterManager.VisibilityCache = {}
CharacterManager.LastVisCheck = {}

function CharacterManager.IsVisible(targetHead, characterModel)
	if not LocalPlayer.Character then
		return false
	end

	-- Rate limit raycasts to 10 times per second to save FPS
	local now = os.clock()
	local lastCheck = CharacterManager.LastVisCheck[targetHead] or 0
	if now - lastCheck < 0.1 then
		return CharacterManager.VisibilityCache[targetHead] or false
	end

	local origin = Camera.CFrame.Position
	local direction = targetHead.Position - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { LocalPlayer.Character, characterModel }
	params.IgnoreWater = true
	local result = Workspace:Raycast(origin, direction, params)

	local isVis = (result == nil)
	CharacterManager.VisibilityCache[targetHead] = isVis
	CharacterManager.LastVisCheck[targetHead] = now
	return isVis
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
	local targetType = config.TargetType or "Players"

	local mouseLocation = UserInputService:GetMouseLocation()
	local shortestDistance = config.FOVRadius
	local closestTarget = nil

	local function processCharacters(characters)
		for character, playerData in pairs(characters) do
			local head = playerData.Head
			if not head then
				continue
			end

			local screenPosition, isVisibleOnScreen = Camera:WorldToViewportPoint(head.Position)
			if isVisibleOnScreen and screenPosition.Z > 0 then
				local targetVector = Vector2.new(screenPosition.X, screenPosition.Y)
				local distanceToMouse = (targetVector - mouseLocation).Magnitude

				if distanceToMouse <= shortestDistance then
					shortestDistance = distanceToMouse
					closestTarget = playerData
				end
			end
		end
	end

	if targetType == "Players" or targetType == "Both" then
		processCharacters(CharacterManager.GetActiveCharacters())
	end

	if targetType == "NPC" or targetType == "Both" then
		processCharacters(CharacterManager.GetNPCs())
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
getgenv().CombatManager = CombatManager

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

		if isVisible and screenPosition.Z > 0 then
			local isVisible3D = config.VisibleCheck
				and CharacterManager.IsVisible(
					TargetManager.CurrentTarget.Head,
					TargetManager.CurrentTarget.Player and TargetManager.CurrentTarget.Player.Character
						or TargetManager.CurrentTarget.Head.Parent
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
	CorpseCache = {},
	ExitCache = {},
}
getgenv().ESPManager = ESPManager

getgenv().DeltaChamsCache = getgenv().DeltaChamsCache or {}
getgenv().PosDeltaTracker = getgenv().PosDeltaTracker or {}
getgenv().NPCDeltaTracker = getgenv().NPCDeltaTracker or {}

getgenv().DebugLogBuffer = getgenv().DebugLogBuffer or {}

if not getgenv().AutoCopyLogsHooked then
	getgenv().AutoCopyLogsHooked = true
	table.insert(ConnectionList, game:GetService("GuiService").ErrorMessageChanged:Connect(function(msg)
		if msg and msg ~= "" and setclipboard then
			setclipboard(table.concat(getgenv().DebugLogBuffer, "\n"))
		end
	end))
end

local function LogLine(msg)
	table.insert(getgenv().DebugLogBuffer, os.date("[%H:%M:%S] ") .. msg)
	if #getgenv().DebugLogBuffer > 500 then
		table.remove(getgenv().DebugLogBuffer, 1)
	end
end

function ESPManager.CreateTextDrawing()
	local textDrawing = Drawing.new("Text")
	textDrawing.Center = true
	textDrawing.Outline = true
	return textDrawing
end

function ESPManager.FormatPlayerText(playerData)
	local config = getgenv().Config.ESP
	local textLines = { playerData.Name or (playerData.Player and playerData.Player.Name) or "Unknown" }

	if config.ShowKDR and not playerData.IsCorpse and not playerData.IsExit and not playerData.IsNPC then
		local kills, deaths = StatsManager.GetPlayerKDR(playerData.Player.Name)
		local ratio = (deaths > 0) and (kills / deaths) or kills
		table.insert(textLines, string.format("KDR: %.2f", ratio))
	end

	return table.concat(textLines, "\n")
end

function ESPManager.Update()
	local config = getgenv().Config.ESP
	local anyActive = config.Enabled
		or config.ChamsEnabled
		or config.CorpseESPEnabled
		or config.ExitESPEnabled
		or config.NPCESPEnabled

	if not anyActive then
		for _, cacheData in pairs(ESPManager.Cache) do
			if type(cacheData) == "table" then
				cacheData.Text:Remove()
				if cacheData.DistanceText then
					cacheData.DistanceText:Remove()
				end
				if cacheData.Bg then
					cacheData.Bg:Remove()
				end
				if cacheData.Bar then
					cacheData.Bar:Remove()
				end
			else
				cacheData:Remove()
			end
		end
		table.clear(ESPManager.Cache)
		if not config.ChamsEnabled then
			for _, highlight in pairs(getgenv().DeltaChamsCache) do
				highlight:Destroy()
			end
			table.clear(getgenv().DeltaChamsCache)
		end
		return
	end

	local activeCharacters = (config.Enabled or config.ChamsEnabled) and CharacterManager.GetActiveCharacters() or {}
	local activeNPCs = (config.NPCESPEnabled or config.ChamsEnabled) and CharacterManager.GetNPCs() or {}
	local activeCorpses = config.CorpseESPEnabled and CharacterManager.GetCorpses() or {}
	local activeExits = config.ExitESPEnabled and CharacterManager.GetExits() or {}

	-- Text ESP Cleanup
	for cachedCharacter, cacheData in pairs(ESPManager.Cache) do
		if
			not activeCharacters[cachedCharacter]
			and not activeNPCs[cachedCharacter]
			and not activeCorpses[cachedCharacter]
			and not activeExits[cachedCharacter]
		then
			if type(cacheData) == "table" then
				cacheData.Text:Remove()
				if cacheData.DistanceText then
					cacheData.DistanceText:Remove()
				end
				if cacheData.Bg then
					cacheData.Bg:Remove()
				end
				if cacheData.Bar then
					cacheData.Bar:Remove()
				end
			else
				cacheData:Remove()
			end
			ESPManager.Cache[cachedCharacter] = nil
		end
	end

	-- Chams ESP Cleanup
	for cachedCharacter, highlight in pairs(getgenv().DeltaChamsCache) do
		local isNPC = activeNPCs[cachedCharacter] ~= nil
		local isStale = not activeCharacters[cachedCharacter] and not activeNPCs[cachedCharacter]
		local shouldRemove = isStale or not config.ChamsEnabled or (isNPC and not config.NPCESPEnabled)

		if shouldRemove then
			highlight:Destroy()
			getgenv().DeltaChamsCache[cachedCharacter] = nil
		end
	end

	local function DrawEntity(character, data)
		local isVisible3D = false
		if
			config.VisibleCheck
			and not data.IsCorpse
			and not data.IsExit
			and (config.Enabled or config.ChamsEnabled or config.NPCESPEnabled)
		then
			isVisible3D = CharacterManager.IsVisible(data.Head, character)
		end

		-- Handle Text ESP
		if
			(config.Enabled and not data.IsCorpse and not data.IsExit and not data.IsNPC)
			or (config.NPCESPEnabled and data.IsNPC)
			or (config.CorpseESPEnabled and data.IsCorpse)
			or (config.ExitESPEnabled and data.IsExit)
		then
			local cacheData = ESPManager.Cache[character]
			if not cacheData then
				cacheData = {
					Text = ESPManager.CreateTextDrawing(),
					DistanceText = ESPManager.CreateTextDrawing(),
					Bg = Drawing.new("Square"),
					Bar = Drawing.new("Square"),
				}
				cacheData.Bg.Filled = true
				cacheData.Bg.Color = Color3.fromRGB(0, 0, 0)
				cacheData.Bg.Thickness = 1
				cacheData.Bar.Filled = true
				cacheData.Bar.Color = Color3.fromRGB(0, 255, 0)
				cacheData.Bar.Thickness = 1
				ESPManager.Cache[character] = cacheData
			end
			local textDrawing = type(cacheData) == "table" and cacheData.Text or cacheData

			local screenPosition, isVisibleOnScreen =
				Camera:WorldToViewportPoint(data.Head.Position + Vector3.new(0, 0.5, 0))

			if isVisibleOnScreen and screenPosition.Z > 0 then
				local distanceInMeters = math.floor((Camera.CFrame.Position - data.Head.Position).Magnitude * 0.28)

				textDrawing.Text = ESPManager.FormatPlayerText(data)
				if (data.IsCorpse or data.IsExit) and config.ShowDistance then
					textDrawing.Text = textDrawing.Text .. string.format("\n(%d m)", distanceInMeters)
				end

				if data.IsCorpse or data.IsExit then
					textDrawing.Position = Vector2.new(screenPosition.X, screenPosition.Y)
				else
					textDrawing.Position = Vector2.new(screenPosition.X, screenPosition.Y - 15)
				end

				local color, outlineColor
				if data.IsCorpse then
					color = config.CorpseTextColor
					outlineColor = config.CorpseOutlineColor
				elseif data.IsExit then
					color = config.ExitTextColor
					outlineColor = config.ExitOutlineColor
				elseif data.IsNPC then
					color = isVisible3D and config.VisibleColor or config.NPCTextColor
					outlineColor = config.NPCOutlineColor
				else
					color = isVisible3D and config.VisibleColor or config.TextColor
					outlineColor = config.OutlineColor
				end

				textDrawing.Color = color
				textDrawing.OutlineColor = outlineColor
				textDrawing.Size = config.TextSize
				textDrawing.Font = config.Font
				textDrawing.Visible = true

				local screenLegs
				if data.RootPart then
					screenLegs = Camera:WorldToViewportPoint(data.RootPart.Position - Vector3.new(0, 3, 0))
				else
					screenLegs = Vector3.new(screenPosition.X, screenPosition.Y + 30, 0)
				end

				if type(cacheData) == "table" and cacheData.DistanceText then
					if config.ShowDistance and not data.IsCorpse and not data.IsExit then
						cacheData.DistanceText.Text = string.format("(%d m)", distanceInMeters)
						cacheData.DistanceText.Position = Vector2.new(screenLegs.X, screenLegs.Y + 5)
						cacheData.DistanceText.Color = color
						cacheData.DistanceText.OutlineColor = outlineColor
						cacheData.DistanceText.Size = config.TextSize
						cacheData.DistanceText.Font = config.Font
						cacheData.DistanceText.Visible = true
					else
						cacheData.DistanceText.Visible = false
					end
				end

				local showBar = config.ShowHealthBar
					and ((config.Enabled and not data.IsCorpse and not data.IsExit and not data.IsNPC) or (config.NPCESPEnabled and data.IsNPC))
					and data.Health
					and data.MaxHealth
				if showBar and data.RootPart and type(cacheData) == "table" then
					local height = math.clamp(screenLegs.Y - screenPosition.Y, 5, 1000)
					local barWidth = 3
					local offsetX = (height / 3.5) + 5 -- Place right next to the 3D bounding box edge dynamically
					local bgPos = Vector2.new(screenPosition.X + offsetX, screenPosition.Y)

					cacheData.Bg.Size = Vector2.new(barWidth + 2, height + 2)
					cacheData.Bg.Position = Vector2.new(bgPos.X - 1, bgPos.Y - 1)
					cacheData.Bg.Visible = true

					local healthPercent = math.clamp(data.Health / data.MaxHealth, 0, 1)
					local barHeight = height * healthPercent
					cacheData.Bar.Size = Vector2.new(barWidth, barHeight)
					cacheData.Bar.Position = Vector2.new(bgPos.X, bgPos.Y + (height - barHeight))
					cacheData.Bar.Visible = true
				elseif type(cacheData) == "table" then
					cacheData.Bg.Visible = false
					cacheData.Bar.Visible = false
				end
			else
				textDrawing.Visible = false
				if type(cacheData) == "table" then
					if cacheData.DistanceText then
						cacheData.DistanceText.Visible = false
					end
					cacheData.Bg.Visible = false
					cacheData.Bar.Visible = false
				end
			end
		end

		-- Handle Chams (Highlight)
		if config.ChamsEnabled and not data.IsCorpse and not data.IsExit then
			if data.IsNPC and not config.NPCESPEnabled then
				-- Skip rendering chams for NPCs when NPC ESP is disabled
			else
				local highlight = getgenv().DeltaChamsCache[character]
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Parent = CoreGui
					highlight.Adornee = character
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					getgenv().DeltaChamsCache[character] = highlight
				end

				local fillCol = data.IsNPC and config.NPCChamsFillColor or config.ChamsFillColor
				highlight.FillColor = isVisible3D and config.VisibleColor or fillCol
				highlight.OutlineColor = config.ChamsOutlineColor
			end
		end
	end

	for character, data in pairs(activeCharacters) do
		DrawEntity(character, data)
	end
	for character, data in pairs(activeNPCs) do
		DrawEntity(character, data)
	end
	for character, data in pairs(activeCorpses) do
		DrawEntity(character, data)
	end
	for character, data in pairs(activeExits) do
		DrawEntity(character, data)
	end
end

-- ==========================================
-- BulletTracerManager
-- ==========================================
local BulletTracerManager = {
	Tracers = getgenv().DeltaTracersCache or {},
	LastFlicker = 0,
}
getgenv().DeltaTracersCache = BulletTracerManager.Tracers

function BulletTracerManager.ParseColor(cColor)
	if typeof(cColor) == "Color3" then return cColor end
	if type(cColor) == "string" then
		local s, r = pcall(function() return Color3.fromHex(cColor) end)
		if s then return r end
	end
	if type(cColor) == "table" then
		local s, r = pcall(function()
			if cColor.R and cColor.G and cColor.B then return Color3.new(cColor.R, cColor.G, cColor.B) end
			if cColor[1] and cColor[2] and cColor[3] then return Color3.new(cColor[1], cColor[2], cColor[3]) end
			return Color3.fromRGB(255, 255, 255)
		end)
		if s then return r end
	end
	return Color3.fromRGB(255, 255, 255)
end

function BulletTracerManager.CreateLightning(origin, hitPos, config)
	local distance = (hitPos - origin).Magnitude
	local numSegments = math.clamp(math.floor(distance / 5), 3, 15)
	local direction = (hitPos - origin).Unit
	local right = Vector3.new(0, 1, 0):Cross(direction)
	if right.Magnitude < 0.1 then
		right = Vector3.new(1, 0, 0):Cross(direction)
	end
	right = right.Unit
	local up = direction:Cross(right).Unit

	local now = os.clock()

	local strandInfo = {
		Beams = {},
		CreationTime = now,
		ExpireTime = now + 1.5,
		IsLightning = true,
	}

	local points = { origin }
	for i = 1, numSegments - 1 do
		local offset = direction * (distance * (i / numSegments))
		local randOffset = (right * (math.random() - 0.5) + up * (math.random() - 0.5)) * (distance * 0.1)
		table.insert(points, origin + offset + randOffset)
	end
	table.insert(points, hitPos)

	for i = 1, #points - 1 do
		local a0 = Instance.new("Attachment")
		a0.WorldPosition = points[i]
		a0.Parent = Workspace.Terrain

		local a1 = Instance.new("Attachment")
		a1.WorldPosition = points[i + 1]
		a1.Parent = Workspace.Terrain

		local beam = Instance.new("Beam")
		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.FaceCamera = true
		local cColor = BulletTracerManager.ParseColor(config.TracerColor)
		beam.Color = ColorSequence.new(cColor)
		beam.Transparency = NumberSequence.new(0)
		beam.Width0 = 0.1
		beam.Width1 = 0.1
		beam.LightEmission = 1
		beam.Parent = Workspace.Terrain

		table.insert(strandInfo.Beams, { Beam = beam, A0 = a0, A1 = a1 })

		if config.TracerGlowEffect then
			local glowBeam = Instance.new("Beam")
			glowBeam.Attachment0 = a0
			glowBeam.Attachment1 = a1
			glowBeam.FaceCamera = true
			glowBeam.Color = beam.Color
			glowBeam.Transparency = NumberSequence.new(0.8)
			glowBeam.Width0 = 0.3
			glowBeam.Width1 = 0.3
			glowBeam.LightEmission = 1
			glowBeam.Parent = Workspace.Terrain
			table.insert(strandInfo.Beams, { Beam = glowBeam, A0 = a0, A1 = a1 })
		end
	end

	table.insert(BulletTracerManager.Tracers, strandInfo)
end

function BulletTracerManager.CreateHeartbeat(origin, hitPos, config)
	local distance = (hitPos - origin).Magnitude
	local numSegments = math.clamp(math.floor(distance / 5), 3, 15)
	local direction = (hitPos - origin).Unit
	local right = Vector3.new(0, 1, 0):Cross(direction)
	if right.Magnitude < 0.1 then
		right = Vector3.new(1, 0, 0):Cross(direction)
	end
	right = right.Unit
	local up = direction:Cross(right).Unit

	local now = os.clock()

	local strandInfo = {
		Beams = {},
		CreationTime = now,
		ExpireTime = now + 1.5,
		IsHeartbeat = true,
	}

	local points = { origin }
	for i = 1, numSegments - 1 do
		local offset = direction * (distance * (i / numSegments))
		local sign = (i % 2 == 0) and 1 or -1
		local spikeOffset = up * 1.5 * sign
		table.insert(points, origin + offset + spikeOffset)
	end
	table.insert(points, hitPos)

	for i = 1, #points - 1 do
		local a0 = Instance.new("Attachment")
		a0.WorldPosition = points[i]
		a0.Parent = Workspace.Terrain

		local a1 = Instance.new("Attachment")
		a1.WorldPosition = points[i + 1]
		a1.Parent = Workspace.Terrain

		local beam = Instance.new("Beam")
		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.FaceCamera = true

		local cColor = BulletTracerManager.ParseColor(config.TracerColor)
		beam.Color = ColorSequence.new(cColor)

		beam.Transparency = NumberSequence.new(0)
		beam.Width0 = 0.1
		beam.Width1 = 0.1
		beam.LightEmission = 1
		beam.Parent = Workspace.Terrain

		table.insert(strandInfo.Beams, { Beam = beam, A0 = a0, A1 = a1 })

		if config.TracerGlowEffect then
			local glowBeam = Instance.new("Beam")
			glowBeam.Attachment0 = a0
			glowBeam.Attachment1 = a1
			glowBeam.FaceCamera = true
			glowBeam.Color = beam.Color
			glowBeam.Transparency = NumberSequence.new(0.8)
			glowBeam.Width0 = 0.3
			glowBeam.Width1 = 0.3
			glowBeam.LightEmission = 1
			glowBeam.Parent = Workspace.Terrain
			table.insert(strandInfo.Beams, { Beam = glowBeam, A0 = a0, A1 = a1 })
		end
	end

	table.insert(BulletTracerManager.Tracers, strandInfo)
end

function BulletTracerManager.AddTracer(origin, hitPos)
	local config = getgenv().Config.SilentAim
	if not config.BulletTracers then
		return
	end

	if config.TracerType == "Lightning" then
		BulletTracerManager.CreateLightning(origin, hitPos, config)
	elseif config.TracerType == "Heartbeat" then
		BulletTracerManager.CreateHeartbeat(origin, hitPos, config)
	else
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
		local cColor = BulletTracerManager.ParseColor(config.TracerColor)
		beam.Color = ColorSequence.new(cColor)
		beam.Transparency = NumberSequence.new(config.TracerTransparency)
		beam.Width0 = 0.05
		beam.Width1 = 0.05
		beam.Parent = Workspace.Terrain

		local glowBeam = nil
		if config.TracerGlowEffect then
			glowBeam = Instance.new("Beam")
			glowBeam.Attachment0 = attachment0
			glowBeam.Attachment1 = attachment1
			glowBeam.FaceCamera = true
			glowBeam.Color = beam.Color
			glowBeam.Transparency = NumberSequence.new(math.clamp(config.TracerTransparency + 0.3, 0, 1))
			glowBeam.Width0 = 0.15
			glowBeam.Width1 = 0.15
			glowBeam.LightEmission = 1
			glowBeam.Parent = Workspace.Terrain
		end

		table.insert(BulletTracerManager.Tracers, {
			Beam = beam,
			GlowBeam = glowBeam,
			A0 = attachment0,
			A1 = attachment1,
			ExpireTime = os.clock() + 2,
		})
	end
end

function BulletTracerManager.Update()
	local config = getgenv().Config.SilentAim
	local now = os.clock()

	local shouldFlicker = false
	if not BulletTracerManager.LastFlicker or (now - BulletTracerManager.LastFlicker) > 0.05 then
		shouldFlicker = true
		BulletTracerManager.LastFlicker = now
	end

	local cColor = BulletTracerManager.ParseColor(config.TracerColor)
	local cTrans = config.TracerTransparency
	if type(cTrans) ~= "number" then
		cTrans = 0.5
	end
	local cachedColor = ColorSequence.new(cColor)
	local cachedTransparency = NumberSequence.new(cTrans)

	for i = #BulletTracerManager.Tracers, 1, -1 do
		local tracer = BulletTracerManager.Tracers[i]
		if now > tracer.ExpireTime or not config.BulletTracers then
			if tracer.Beam then
				tracer.Beam:Destroy()
			end
			if tracer.GlowBeam then
				tracer.GlowBeam:Destroy()
			end
			if tracer.A0 then
				tracer.A0:Destroy()
			end
			if tracer.A1 then
				tracer.A1:Destroy()
			end
			if tracer.Beams then
				for _, b in pairs(tracer.Beams) do
					b.Beam:Destroy()
					b.A0:Destroy()
					b.A1:Destroy()
				end
			end
			table.remove(BulletTracerManager.Tracers, i)
		else
			if tracer.Beam and not tracer.IsLightning then
				tracer.Beam.Color = cachedColor
				tracer.Beam.Transparency = cachedTransparency
			end
			if tracer.GlowBeam then
				tracer.GlowBeam.Color = cachedColor
				tracer.GlowBeam.Transparency = NumberSequence.new(math.clamp(cTrans + 0.3, 0, 1))
			end
			if tracer.IsLightning and tracer.Beams and shouldFlicker then
				local flicker = math.random() * 0.3
				local flickerTransparency = NumberSequence.new(math.clamp(flicker, 0, 1))
				for _, b in pairs(tracer.Beams) do
					b.Beam.Color = cachedColor
					b.Beam.Transparency = flickerTransparency
				end
			end
		end
	end
end

-- ==========================================
-- Bullet Prediction Hook (CreateBullet)
-- ==========================================
if not getgenv().DeltaTimeTracker then
	getgenv().DeltaTimeTracker = {
		dt = 0.016666,
		connection = game:GetService("RunService").RenderStepped:Connect(function(step)
			-- EMA to smooth out frame spikes for more accurate future dt prediction
			getgenv().DeltaTimeTracker.dt = getgenv().DeltaTimeTracker.dt * 0.9 + step * 0.1
		end),
	}
	table.insert(ConnectionList, getgenv().DeltaTimeTracker.connection)
end

local BulletMod = ReplicatedStorage:WaitForChild("Modules", 10)
if BulletMod then
	local FPS = BulletMod:WaitForChild("FPS", 10)
	if FPS then
		local BulletScript = FPS:WaitForChild("Bullet", 10)
		if BulletScript then
			local Bullet = require(BulletScript)
			if not getgenv().OriginalCreateBullet then
				getgenv().OriginalCreateBullet = Bullet.CreateBullet
			end
			local oldCreateBullet = getgenv().OriginalCreateBullet

			Bullet.CreateBullet = newcclosure(function(...)
				local args = table.pack(...)
				if getgenv().Config.SilentAim.Enabled and TargetManager.CurrentTarget then
					local target = TargetManager.CurrentTarget
					local targetAimPart = target.Head
					local targetRoot = target.RootPart

					local ammoName = type(args[7]) == "string" and args[7] or ""
					local muzzleVelocity = (getgenv().DeltaVelocityCache and getgenv().DeltaVelocityCache[ammoName])
						or 3000

					local origin = Camera.CFrame.Position
					pcall(function()
						local FunctionLibraryExtension = require(
							ReplicatedStorage:WaitForChild("Modules", 2):WaitForChild("FunctionLibraryExtension", 2)
						)
						if FunctionLibraryExtension then
							origin = FunctionLibraryExtension:GetEstimatedCameraPosition(LocalPlayer)
						end
					end)

					local targetVelocity = targetRoot.AssemblyLinearVelocity
					local v = muzzleVelocity
					local G = 70

					-- Exact quadratic formula solver for projectile motion
					local timeToHit = (targetAimPart.Position - origin).Magnitude / v
					for i = 1, 3 do
						local targetPos = targetAimPart.Position + targetVelocity * timeToHit
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

					local finalPredictedPos = targetAimPart.Position + targetVelocity * timeToHit
					local finalDrop = 0.5 * G * (timeToHit ^ 2)
					local aimPos = finalPredictedPos + Vector3.new(0, finalDrop, 0)

					TargetManager.PredictedPosition = finalPredictedPos

					args[5] = {
						["CFrame"] = CFrame.lookAt(origin, aimPos),
					}

					if getgenv().Config.SilentAim.BulletTracers then
						BulletTracerManager.AddTracer(origin, TargetManager.PredictedPosition)
					end
				else
					if getgenv().Config.Combat.NoRecoil then
						local origin = workspace.CurrentCamera.CFrame.Position
						local lookVector = workspace.CurrentCamera.CFrame.LookVector
						args[5] = {
							CFrame = CFrame.lookAt(origin, origin + lookVector * 1000),
						}
					elseif getgenv().Config.Combat.NoSpread then
						-- Removing the failed CreateBullet CFrame override bypass method
					end
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
			end)
		end
	end
end

-- ==========================================
-- Instant Hit: MuzzleVelocity Cache (Solution 3)
-- ==========================================
-- Pre-reads the REAL (server-trusted) MuzzleVelocity for every AmmoType at startup
-- using OriginalNamecall so our own GetAttribute spoof hook never touches these values.
-- This gives us an O(1) table lookup per shot with zero WaitForChild cost.
getgenv().DeltaVelocityCache = getgenv().DeltaVelocityCache or {}

table.insert(
	ThreadList,
	task.spawn(function()
		local ammoTypes = ReplicatedStorage:WaitForChild("AmmoTypes", 10)
		if not ammoTypes then
			print("[InstantHit Cache] ERROR: AmmoTypes not found in ReplicatedStorage")
			return
		end

		local function cacheAmmoType(ammoType)
			-- Must use getgenv().OriginalNamecall so our GetAttribute hook doesn't intercept this read.
			-- At this point OriginalNamecall may not be set yet, so we fall back to a direct pcall.
			local v
			if getgenv().OriginalNamecall then
				local ok
				ok, v = pcall(getgenv().OriginalNamecall, ammoType, "MuzzleVelocity")
				if not ok then
					v = nil
				end
			else
				local ok
				ok, v = pcall(function()
					return ammoType:GetAttribute("MuzzleVelocity")
				end)
				if not ok then
					v = nil
				end
			end
			if type(v) == "number" and v > 0 then
				getgenv().DeltaVelocityCache[ammoType.Name] = v
				print(string.format("[InstantHit Cache] %s → %.0f sv", ammoType.Name, v))
			end
		end

		-- Cache all existing ammo types
		for _, ammoType in ipairs(ammoTypes:GetChildren()) do
			cacheAmmoType(ammoType)
		end

		-- Watch for new ammo types added later (weapon pickups etc.)
		table.insert(ConnectionList, ammoTypes.ChildAdded:Connect(function(child)
			task.wait(0.2)
			cacheAmmoType(child)
		end))
	end)
)
-- ==========================================
-- Unified Firearm Detection
-- ==========================================
getgenv().DeltaIsGun = function(wName)
	if type(wName) ~= "string" or wName == "" or wName == "unknown" then return false end
	local lower = string.lower(wName)
	local isMeleeOrConsumable = string.find(lower, "scythe") or string.find(lower, "ninjato") 
		or string.find(lower, "dv2") or string.find(lower, "dagger") 
		or string.find(lower, "m9xr7") or string.find(lower, "karambit") 
		or string.find(lower, "sword") or string.find(lower, "kukri") 
		or string.find(lower, "tomahawk") or string.find(lower, "cutlass") 
		or string.find(lower, "axe") or string.find(lower, "dressing")
		or string.find(lower, "bandage") or string.find(lower, "rags")
		or string.find(lower, "ai2") or string.find(lower, "ai4")
		or string.find(lower, "milk") or string.find(lower, "ifak")
		or string.find(lower, "bottle") or string.find(lower, "beans")
		or string.find(lower, "kola") or string.find(lower, "cola")
		or string.find(lower, "soda") or string.find(lower, "serum")
		or string.find(lower, "key") or string.find(lower, "f1")
		or string.find(lower, "rgo") or string.find(lower, "rgd")
		or string.find(lower, "m84") or string.find(lower, "flare")
		or string.find(lower, "spsh") or string.find(lower, "lighter")
		
	return not isMeleeOrConsumable
end

-- ==========================================
-- SpringV2 Hook (NoRecoil Viewmodel Fix)
-- ==========================================
table.insert(
	ThreadList,
	task.spawn(function()
		local springHooked = false
		local fpsHooked = false
		while task.wait(3.5) do
			pcall(function()
				for _, v in pairs(getgc(true)) do
					if type(v) == "table" then
						-- 1. Hook SpringV2 Prototype (Camera Recoil)
						if not springHooked and type(rawget(v, "create")) == "function" then
							local keys = 0
							for _, _ in pairs(v) do
								keys = keys + 1
							end
							if keys == 1 then
								local success, testSpring = pcall(function()
									return v.create()
								end)
								if
									success
									and type(testSpring) == "table"
									and type(rawget(testSpring, "shove")) == "function"
								then
									if not getgenv().OldSpringCreate then
										getgenv().OldSpringCreate = v.create
										v.create = function(...)
											local newSpring = getgenv().OldSpringCreate(...)
											-- Removed SpringV2 shove intercept to preserve ADS physics
											return newSpring
										end
									end
									springHooked = true
									if LogLine then
										LogLine("[SpringV2] Hooked prototype successfully!")
									end
								end
							end
						end

						-- 2. Hook FPS Prototype (Gun Kickback & Bobbing)
						if
							not fpsHooked
							and type(rawget(v, "equip")) == "function"
							and type(rawget(v, "changeLean")) == "function"
							and type(rawget(v, "changeStance")) == "function"
						then
							if not getgenv().OldFPSEquip then
								getgenv().OldFPSEquip = v.equip
								v.equip = function(self, ...)
									local ret = getgenv().OldFPSEquip(self, ...)
									
									if type(self) == "table" and rawget(self, "weapon") and typeof(self.weapon) == "Instance" then
										local wName = string.lower(self.weapon.Name)
										
										if type(rawget(self, "settings")) == "table" then
											-- Cache original recoil upon equip
											if self.settings.MaximumKickBack and self.settings.MaximumKickBack ~= 0 and not rawget(self.settings, "OrigKick") then
												self.settings.OrigKick = self.settings.MaximumKickBack
												self.settings.OrigRecoil = self.settings.MaxRecoil
											end
										end
										
										if getgenv().Config.Combat.NoRecoil then
											getgenv().TemporaryNoRecoil = getgenv().DeltaIsGun(wName)
										else
											getgenv().TemporaryNoRecoil = false
										end
										
										-- Apply or Restore
										if type(rawget(self, "settings")) == "table" then
											if getgenv().TemporaryNoRecoil then
												self.settings.MaximumKickBack = 0
												self.settings.MaxRecoil = 0
											else
												if rawget(self, "OrigKick") then
													self.settings.MaximumKickBack = self.settings.OrigKick
													self.settings.MaxRecoil = self.settings.OrigRecoil
												end
											end
										end
										
										-- TARGETED SPRING SILENCER (Camera Recoil Only)
										if type(rawget(self, "springs")) == "table" then
											for springName, springObj in pairs(self.springs) do
												if type(springName) == "string" then
													local lName = string.lower(springName)
													if string.find(lName, "recoil") or string.find(lName, "kick") then
														if type(springObj) == "table" and type(rawget(springObj, "shove")) == "function" then
															if not rawget(springObj, "__recoilHooked") then
																local oldShove = springObj.shove
																springObj.shove = function(selfObj, force, ...)
																	if getgenv().TemporaryNoRecoil then
																		return oldShove(selfObj, Vector3.new(0, 0, 0), ...)
																	end
																	return oldShove(selfObj, force, ...)
																end
																rawset(springObj, "__recoilHooked", true)
															end
														end
													end
												end
											end
										end
									end
									
									return ret
								end
								fpsHooked = true
								if LogLine then
									LogLine("[FPS] Hooked prototype successfully!")
								end
							end
						end

						-- Fix any already existing springs (if user equipped gun before prototype loaded)
						if type(rawget(v, "shove")) == "function" and type(rawget(v, "update")) == "function" then
							if not rawget(v, "__isHooked") then
								-- Removed SpringV2 shove intercept to preserve ADS physics
								rawset(v, "__isHooked", true)
								if LogLine then
									LogLine("[SpringV2] Hooked existing instance!")
								end
							end
						end

						-- Fix any already existing FPS controllers
						if type(rawget(v, "settings")) == "table" and type(rawget(v, "springs")) == "table" then
							local isActive = false
							if type(rawget(v, "isEquipped")) == "boolean" then
								isActive = v.isEquipped
							elseif
								rawget(v, "weapon")
								and typeof(v.weapon) == "Instance"
								and v.weapon.Parent
								and v.weapon.Parent:IsA("Model")
								and v.weapon.Parent.Name == "Camera"
							then
								isActive = true
							end

							if isActive then
								if rawget(v, "weapon") and typeof(v.weapon) == "Instance" then
									local wName = string.lower(v.weapon.Name)
									if getgenv().Config.Combat.NoRecoil then
										getgenv().TemporaryNoRecoil = getgenv().DeltaIsGun(wName)
									else
										getgenv().TemporaryNoRecoil = false
									end
								end
							end

							if type(rawget(v, "settings")) == "table" then
								if v.settings.MaximumKickBack and v.settings.MaximumKickBack ~= 0 and not rawget(v.settings, "OrigKick") then
									v.settings.OrigKick = v.settings.MaximumKickBack
									v.settings.OrigRecoil = v.settings.MaxRecoil
								end
								
								if getgenv().TemporaryNoRecoil then
									v.settings.MaximumKickBack = 0
									v.settings.MaxRecoil = 0
								else
									if rawget(v.settings, "OrigKick") then
										v.settings.MaximumKickBack = v.settings.OrigKick
										v.settings.MaxRecoil = v.settings.OrigRecoil
									end
								end
							end
							
							-- TARGETED SPRING SILENCER (Camera Recoil Only)
							if type(rawget(v, "springs")) == "table" then
								for springName, springObj in pairs(v.springs) do
									if type(springName) == "string" then
										local lName = string.lower(springName)
										if string.find(lName, "recoil") or string.find(lName, "kick") then
											if type(springObj) == "table" and type(rawget(springObj, "shove")) == "function" then
												if not rawget(springObj, "__recoilHooked") then
													local oldShove = springObj.shove
													springObj.shove = function(selfObj, force, ...)
														if getgenv().TemporaryNoRecoil then
															return oldShove(selfObj, Vector3.new(0, 0, 0), ...)
														end
														return oldShove(selfObj, force, ...)
													end
													rawset(springObj, "__recoilHooked", true)
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end)
		end
	end)
)

-- ==========================================
-- Anti-Cheat Metamethod Hook (__namecall)
-- ==========================================
if not getgenv().OriginalNamecall then
	getgenv().OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		if getgenv().DeltaNamecallHook then
			return getgenv().DeltaNamecallHook(self, ...)
		end
		return getgenv().OriginalNamecall(self, ...)
	end)
end

getgenv().DeltaNamecallHook = newcclosure(function(self, ...)
	local oldNamecall = getgenv().OriginalNamecall
	local method = getnamecallmethod()
	local args = { ... }

	if method == "FireServer" then
		local selfName = typeof(self) == "Instance" and self.Name or ""
		if selfName == "ProjectileInflict" or selfName == "MeleeInflict" or selfName == "MeleeInfIict" then
			if getgenv().HitsoundManager and getgenv().HitsoundManager.Play then
				pcall(getgenv().HitsoundManager.Play)
			end
		end
	end



	if method == "Play" then
		if typeof(self) == "Instance" and self:IsA("AnimationTrack") then
			local name = self.Name

			if getgenv().TemporaryNoRecoil then
				if string.match(name, "UseAiming$") or string.match(name, "Use$") or string.match(name, "UseAlt$") then
					
					-- Flag that a gunshot is happening to allow the SpringV2 hook to swallow the recoil shove
					getgenv().IsFiring = true
					task.delay(0.15, function()
						getgenv().IsFiring = false
					end)
					
					local track = oldNamecall(self, ...)
					task.spawn(function()
						pcall(function()
							self:AdjustWeight(0.001)
						end)
					end)
					return track
				end
			end
		end
	end

	if method == "GetAttribute" then
		local attrName = args[1]
		local lowerAttr = type(attrName) == "string" and string.lower(attrName) or ""

		local callingScript = getcallingscript()
		if callingScript then
			local sName = string.lower(callingScript.Name)
			-- Bypass Local Anti-Cheat: If UAC checks attributes, return the real ones so we don't get flagged!
			if string.find(sName, "anticheat") or string.find(sName, "uac") or string.find(sName, "ultimate") then
				return oldNamecall(self, ...)
			end
		end

		if getgenv().TemporaryNoRecoil then
			if string.find(lowerAttr, "recoil") then
				return 0
			end
		end

		if getgenv().Config.Combat.NoSpread then
			if string.find(lowerAttr, "spread") or string.find(lowerAttr, "accuracydeviation") then
				if LogLine then
					LogLine("[NoSpread] Spoofing GetAttribute: " .. tostring(attrName))
				end
				-- Return a negligible amount of spread instead of 0 to bypass server checks
				return 0.001
			end
		end

		if getgenv().Config.Combat.InstantHit then
			if string.find(lowerAttr, "muzzlevelocity") then
				return 3299
			elseif
				string.find(lowerAttr, "projectiledrop")
				or string.find(lowerAttr, "gravity")
				or string.find(lowerAttr, "drag")
			then
				return 0
			end
		end
	elseif method == "GetAttributes" then
		local attrs = oldNamecall(self, ...)
		if
			type(attrs) == "table"
			and (
				getgenv().Config.Combat.NoRecoil
				or getgenv().Config.Combat.NoSpread
				or getgenv().Config.Combat.InstantHit
				or getgenv().Config.SilentAim.Enabled
			)
		then
			local callingScript = getcallingscript()
			if callingScript then
				local sName = string.lower(callingScript.Name)
				if string.find(sName, "anticheat") or string.find(sName, "uac") or string.find(sName, "ultimate") then
					return attrs -- Return original un-spoofed table to AC
				end
			end
			local spoofed = false
			local newAttrs = {}
			for k, v in pairs(attrs) do
				local lk = string.lower(k)
				if string.find(lk, "recoil") and getgenv().TemporaryNoRecoil then
					newAttrs[k] = 0
					spoofed = true
				elseif
					(string.find(lk, "spread") or string.find(lk, "accuracydeviation"))
					and getgenv().Config.Combat.NoSpread
				then
					if LogLine then
						LogLine("[NoSpread] Spoofing GetAttributes table key: " .. tostring(k))
					end
					newAttrs[k] = type(v) == "number" and 0.001 or v
					spoofed = true
				elseif
					getgenv().Config.Combat.InstantHit
					and (
						string.find(lk, "muzzlevelocity")
						or string.find(lk, "projectiledrop")
						or string.find(lk, "gravity")
						or string.find(lk, "drag")
					)
				then
					if string.find(lk, "muzzlevelocity") then
						newAttrs[k] = 3299
					else
						newAttrs[k] = 0
					end
					spoofed = true
				else
					newAttrs[k] = v
				end
			end
			if spoofed then
				return newAttrs
			end
		end
	elseif method == "Create" and tostring(self) == "TweenService" then
		local info = args[2]
		local props = args[3]
		if props and type(props) == "table" and props.FieldOfView then
			if getgenv().Config.Combat.InstantADS and typeof(info) == "TweenInfo" then
				args[2] = TweenInfo.new(
					0,
					info.EasingStyle,
					info.EasingDirection,
					info.RepeatCount,
					info.Reverses,
					info.DelayTime
				)
			end
			local baseFOV = 70
			pcall(function()
				local lp = game:GetService("Players").LocalPlayer
				local pf = game:GetService("ReplicatedStorage"):FindFirstChild("Players")
				local myF = pf and pf:FindFirstChild(lp.Name)
				local setF = myF and myF:FindFirstChild("Settings")
				local gp = setF and setF:FindFirstChild("GameplaySettings")
				if gp then
					baseFOV = gp:GetAttribute("DefaultFOV") or 70
				end
			end)

			local isZooming = props.FieldOfView < (baseFOV - 5)
			getgenv().DeltaIsZooming = isZooming

			local newFOV = props.FieldOfView
			if isZooming then
				if getgenv().Config.Mods.FOV and getgenv().Config.Mods.FOV ~= 70 then
					local ratio = props.FieldOfView / baseFOV
					newFOV = getgenv().Config.Mods.FOV * ratio
				end
				if getgenv().Config.Combat.ADSZoomMultiplier and getgenv().Config.Combat.ADSZoomMultiplier ~= 1.0 then
					newFOV = newFOV / getgenv().Config.Combat.ADSZoomMultiplier
				end
			else
				if getgenv().Config.Mods.FOV and getgenv().Config.Mods.FOV ~= 70 then
					newFOV = getgenv().Config.Mods.FOV
				end
			end

			local newProps = {}
			for k, v in pairs(props) do
				newProps[k] = v
			end
			newProps.FieldOfView = newFOV
			args[3] = newProps
			setnamecallmethod(method)
			return oldNamecall(self, table.unpack(args))
		end
	end

	if
		not checkcaller()
		and (getgenv().Config.Combat.InstantHit or getgenv().Config.Combat.NoRecoil or getgenv().Config.Combat.NoSpread)
	then
		if (method == "FireServer" or method == "InvokeServer") and getgenv().Config.Combat.NoSpread then
			local lowerName = string.lower(self.Name)
			if string.match(lowerName, "projectile") then
				if LogLine then
					LogLine("[NoSpread Spy] Intercepted Remote: " .. self.Name .. " (" .. method .. ")")
					LogLine("[NoSpread Spy] Args: " .. tostring(#args))
					for i, v in ipairs(args) do
						local t = typeof(v)
						local display
						if t == "Vector3" then
							display = string.format("Vec3(%.2f, %.2f, %.2f)", v.X, v.Y, v.Z)
						elseif t == "CFrame" then
							local p = v.Position
							local lv = v.LookVector
							display = string.format(
								"CFrame(pos=%.2f,%.2f,%.2f, look=%.2f,%.2f,%.2f)",
								p.X,
								p.Y,
								p.Z,
								lv.X,
								lv.Y,
								lv.Z
							)
						elseif t == "number" then
							display = string.format("num(%.6f)", v)
						elseif t == "Instance" then
							display = string.format("Inst[%s]=%s", v.ClassName, v.Name)
						elseif t == "table" then
							local inner = "{"
							for k2, v2 in pairs(v) do
								inner = inner .. tostring(k2) .. "=" .. typeof(v2) .. " "
							end
							display = inner .. "}"
						else
							display = tostring(v)
						end
						LogLine(string.format("  [%d] %s", i, display))
					end
					LogLine("[NoSpread Spy] ===================================")
				end
			end
		end

		-- -----------------------------------------------
		-- Instant Hit: Desync Teleporting (Method 2)
		-- -----------------------------------------------
		-- We spoof MuzzleVelocity to 3299 so the bullet physically hits instantly on the client.
		-- Instead of backdating the remote or mature pool, we intercept ProjectileInflict
		-- and use latency desync to temporarily teleport our character to the hit point,
		-- making Distance = 0 and ExpectedTravelTime = 0.

		if
			method == "InvokeServer"
			and string.lower(self.Name) == "fireprojectile"
			and getgenv().Config.Combat.InstantHit
		then
			local bulletID = args[2]

			if LogLine then
				LogLine("[InstantHit Spy] Intercepted FireProjectile. ID: " .. tostring(bulletID))
			end

			setnamecallmethod(method)
			return oldNamecall(self, table.unpack(args))
		end

		if
			method == "InvokeServer"
			and string.match(string.lower(self.Name), "projectile")
			and getgenv().Config.Combat.NoRecoil
		then
			local rs = game:GetService("ReplicatedStorage")
			local updateTiltRemote = rs and rs:FindFirstChild("UpdateTilt", true)
			if updateTiltRemote and updateTiltRemote:IsA("RemoteEvent") then
				local fakePitch = -0.05 - (math.random() * 0.04)
				updateTiltRemote:FireServer(fakePitch, 0, nil, nil)
			end
		end
	end

	setnamecallmethod(method)
	return oldNamecall(self, ...)
end)

-- ==========================================
-- RNG Hooks (No Spread Bypass)
-- ==========================================
-- The server validates bullet trajectories based on the weapon's spread and the random seed.
-- If we lock math.random to a deterministic value for the bullet calculations,
-- We can force the bullet to fire perfectly straight while the server thinks it's a "lucky" shot.

local oldRandom
oldRandom = hookfunction(
	math.random,
	newcclosure(function(...)
		local args = { ... }
		local min, max = args[1], args[2]

		if getgenv().Config.Combat.NoSpread then
			local callingScript = getcallingscript()
			if callingScript and string.find(string.lower(callingScript.Name), "bullet") then
				if type(min) == "number" and type(max) == "number" then
					if LogLine then
						LogLine("[NoSpread] Centering math.random call from " .. callingScript.Name)
					end
					-- FIX: Using math.floor((min+max)/2) safely centers both spread calculations
					-- (e.g. -50 to 50 returns 0) and array lookups (e.g. 1 to #Sound returns valid index).
					return math.floor((min + max) / 2)
				elseif type(min) == "number" and not max then
					return min
				else
					return 0.5
				end
			end
		end
		return oldRandom(...)
	end)
)

-- Hook Random.new()
local oldRandomNew
oldRandomNew = hookfunction(
	Random.new,
	newcclosure(function(seed)
		local rng = oldRandomNew(seed)
		if getgenv().Config.Combat.NoSpread then
			local callingScript = getcallingscript()
			if callingScript and string.find(string.lower(callingScript.Name), "bullet") then
				-- We inject a proxy object that intercepts :NextNumber() and :NextInteger()
				local proxy = {}
				setmetatable(proxy, {
					__index = function(self, key)
						if key == "NextNumber" then
							return function(_, min, max)
								if LogLine then
									LogLine("[NoSpread] Centering Random:NextNumber from " .. callingScript.Name)
								end
								min = min or 0
								max = max or 1
								return (min + max) / 2 -- Always perfectly centered
							end
						elseif key == "NextInteger" then
							return function(_, min, max)
								if LogLine then
									LogLine("[NoSpread] Centering Random:NextInteger from " .. callingScript.Name)
								end
								return math.floor((min + max) / 2) -- Always perfectly centered
							end
						else
							local val = rng[key]
							if type(val) == "function" then
								return function(_, ...)
									return val(rng, ...)
								end
							end
							return val
						end
					end,
				})
				return proxy
			end
		end
		return rng
	end)
)

-- ==========================================
-- RapidFire Manager
-- ==========================================
local originalFireRates = {}
local originalFireModes = {}
local originalCurrentFireMode = {}

table.insert(
	ThreadList,
	task.spawn(function()
		while task.wait(1) do
			local ItemsList = ReplicatedStorage:FindFirstChild("Itemslist")
				or ReplicatedStorage:FindFirstChild("ItemsList")

			if ItemsList then
				for _, desc in ipairs(ItemsList:GetDescendants()) do
					if desc:IsA("ModuleScript") and desc.Name == "SettingsModule" and desc.Parent then
						local itemName = desc.Parent.Name
						local success, stats = pcall(require, desc)

						if success and type(stats) == "table" and stats.FireRate then
							if not originalFireRates[itemName] then
								originalFireRates[itemName] = stats.FireRate
							end
							if stats.FireModes and not originalFireModes[itemName] then
								originalFireModes[itemName] = table.clone(stats.FireModes)
							end
							if stats.FireMode and not originalCurrentFireMode[itemName] then
								originalCurrentFireMode[itemName] = stats.FireMode
							end

							if getgenv().Config.Combat.RapidFire then
								local multiplier = getgenv().Config.Combat.RapidFireValue or 3
								local newRate = originalFireRates[itemName] / multiplier

								if stats.FireRate ~= newRate then
									stats.FireRate = newRate
								end

								-- Deep Enforce "Auto" Mode
								if stats.FireModes then
									table.clear(stats.FireModes)
									table.insert(stats.FireModes, "Auto")
								end
								if stats.FireMode then
									stats.FireMode = "Auto"
								end

								-- Remove Bolt Action / Pump delays that block automatic fire loops
								if stats.CycleTiming then
									stats.CycleTiming = { 0, 0 }
								end
								if stats.EjectionDelay then
									stats.EjectionDelay = 0
								end
							else
								if stats.FireRate ~= originalFireRates[itemName] then
									stats.FireRate = originalFireRates[itemName]
								end

								if originalFireModes[itemName] and stats.FireModes then
									table.clear(stats.FireModes)
									for _, mode in ipairs(originalFireModes[itemName]) do
										table.insert(stats.FireModes, mode)
									end
								end
								if originalCurrentFireMode[itemName] and stats.FireMode then
									stats.FireMode = originalCurrentFireMode[itemName]
								end
							end
						end
					end
				end
			end
		end
	end)
)

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
		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
		if atmosphere then
			atmosphere.Density = 0
		end
	end

	if getgenv().Config.Mods.FOV and getgenv().Config.Mods.FOV ~= 70 then
		if not getgenv().DeltaIsZooming then
			Camera.FieldOfView = getgenv().Config.Mods.FOV
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
getgenv().HitsoundManager = HitsoundManager


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
		local success = pcall(function()
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
	DividerText = nil,
	TextCache = {},
	CurrentTarget = nil,
	LastViewportSize = nil,
	IsDragging = false,
	DragOffset = Vector2.new(0, 0),
	UserPosition = nil,
	Width = 240,
}
getgenv().InventoryViewer = InventoryViewer

local inventoryConnections = {}

local function clearInventoryConnections()
	for _, conn in ipairs(inventoryConnections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(inventoryConnections)
end
getgenv()._clearInventoryConnections = clearInventoryConnections

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
				if isVisibleOnScreen and screenPosition.Z > 0 then
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

	for corpseInstance, corpseData in pairs(CharacterManager.ActiveCorpses) do
		local head = corpseData.Head
		if head then
			local screenPosition, isVisibleOnScreen = Camera:WorldToViewportPoint(head.Position)
			if isVisibleOnScreen and screenPosition.Z > 0 then
				local distanceToMouse = (Vector2.new(screenPosition.X, screenPosition.Y) - mouseLocation).Magnitude
				if distanceToMouse < shortestDistance then
					shortestDistance = distanceToMouse
					local name = corpseData.Name
					closestTarget = {
						Type = "Corpse",
						Name = name,
						TargetInstance = corpseInstance,
						ParentFolder = corpseInstance,
					}
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
		if InventoryViewer.DividerText then
			InventoryViewer.DividerText.Visible = false
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
	local titleHeight = 40
	local itemSpacing = 18
	local padding = 12
	local totalHeight = padding * 2 + titleHeight + (#uniqueOrder * itemSpacing)
	local width = InventoryViewer.Width

	if not InventoryViewer.UserPosition then
		InventoryViewer.UserPosition = Vector2.new(viewportSize.X - width - 100, (viewportSize.Y - totalHeight) / 2)
	end

	local x = InventoryViewer.UserPosition.X
	local y = InventoryViewer.UserPosition.Y

	x = math.clamp(x, 0, math.max(0, viewportSize.X - width))
	y = math.clamp(y, 0, math.max(0, viewportSize.Y - totalHeight))
	InventoryViewer.UserPosition = Vector2.new(x, y)

	-- Position containers
	InventoryViewer.Background.Position = Vector2.new(x, y)
	InventoryViewer.Background.Size = Vector2.new(width, totalHeight)
	InventoryViewer.Background.Visible = true

	InventoryViewer.Border.Position = Vector2.new(x, y)
	InventoryViewer.Border.Size = Vector2.new(width, totalHeight)
	InventoryViewer.Border.Visible = true

	local targetName = targetInfo.Name or (targetInfo.Player and targetInfo.Player.Name) or "Unknown"
	InventoryViewer.TitleText.Text = string.format("%s's Inventory", targetName)
	InventoryViewer.TitleText.Position = Vector2.new(x + width / 2, y + padding)
	InventoryViewer.TitleText.Visible = true

	if InventoryViewer.DividerText then
		InventoryViewer.DividerText.Position = Vector2.new(x + width / 2, y + padding + 15)
		InventoryViewer.DividerText.Visible = true
	end

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

	local dividerText = Drawing.new("Text")
	dividerText.Text = "---------------------------------------------------"
	dividerText.Size = 13
	dividerText.Center = true
	dividerText.Outline = true
	dividerText.Color = Color3.fromRGB(255, 255, 255)
	dividerText.Visible = false
	InventoryViewer.DividerText = dividerText

	table.insert(
		ConnectionList,
		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local mousePos = UserInputService:GetMouseLocation()
				if InventoryViewer.Background and InventoryViewer.Background.Visible then
					local bgPos = InventoryViewer.Background.Position
					local bgSize = InventoryViewer.Background.Size
					if
						mousePos.X >= bgPos.X
						and mousePos.X <= bgPos.X + bgSize.X
						and mousePos.Y >= bgPos.Y
						and mousePos.Y <= bgPos.Y + bgSize.Y
					then
						InventoryViewer.IsDragging = true
						InventoryViewer.DragOffset = mousePos - bgPos
					end
				end
			end
		end)
	)

	table.insert(
		ConnectionList,
		UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement and InventoryViewer.IsDragging then
				local mousePos = UserInputService:GetMouseLocation()
				InventoryViewer.UserPosition = mousePos - InventoryViewer.DragOffset
				InventoryViewer.Draw()
			end
		end)
	)

	table.insert(
		ConnectionList,
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				InventoryViewer.IsDragging = false
			end
		end)
	)
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
		if InventoryViewer.DividerText then
			InventoryViewer.DividerText.Visible = false
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
			if InventoryViewer.DividerText then
				InventoryViewer.DividerText.Visible = false
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
table.insert(
	ThreadList,
	task.spawn(function()
		while true do
			pcall(InventoryViewer.CheckTarget)
			task.wait(0.25)
		end
	end)
)

-- ==========================================
-- Main Loop
-- ==========================================
local function UpdateViewmodelTransparency()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local isADS = false
	if getgenv().Config.Combat.HideViewmodelOnADS then
		isADS = getgenv().DeltaIsZooming == true
	end

	for _, child in ipairs(camera:GetChildren()) do
		if child:IsA("Model") then
			local parts = getgenv().DeltaCachedViewmodelParts
			if not parts or getgenv().DeltaCachedViewmodelParent ~= child then
				parts = {}
				for _, desc in ipairs(child:GetDescendants()) do
					if desc:IsA("BasePart") then
						table.insert(parts, desc)
					end
				end
				getgenv().DeltaCachedViewmodelParts = parts
				getgenv().DeltaCachedViewmodelParent = child
			end
			for _, desc in ipairs(parts) do
				desc.LocalTransparencyModifier = isADS and 1 or 0
			end
		end
	end
end

local renderConnection = RunService.RenderStepped:Connect(function()
	WorldModsManager.Update()
	ESPManager.Update()
	CombatManager.Update()
	BulletTracerManager.Update()
	UpdateViewmodelTransparency()
end)
table.insert(ConnectionList, renderConnection)

table.insert(
	ConnectionList,
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		local combatConfig = getgenv().Config.Combat
		if combatConfig.FlyKeybind and input.KeyCode.Name == combatConfig.FlyKeybind then
			local character = Workspace:FindFirstChild(LocalPlayer.Name)
			if not character then
				return
			end
			local hrp = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
			if not hrp then
				return
			end

			local TweenService = game:GetService("TweenService")
			local startCFrame = hrp.CFrame
			local targetCFrame = startCFrame + Vector3.new(0, 12, 0)

			-- Fly up smoothly
			local tweenUp = TweenService:Create(
				hrp,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ CFrame = targetCFrame }
			)

			tweenUp:Play()
			tweenUp.Completed:Connect(function()
				-- Teleport directly back to the origin
				hrp.CFrame = startCFrame
			end)
		end
	end)
)

Window:SelectTab(1)
