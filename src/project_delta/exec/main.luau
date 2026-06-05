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

	pcall(function()
		game:GetService("RunService"):UnbindFromRenderStep("UndergroundDesync_Restore")
	end)

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

	if getgenv().LinoriaLibrary then
		pcall(function()
			getgenv().LinoriaLibrary:Unload()
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

	getgenv().DeltaInflictDumped = nil

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
local GuiService = safeGetService("GuiService")
local HttpService = safeGetService("HttpService")
local TweenService = safeGetService("TweenService")
local SoundService = safeGetService("SoundService")
local Lighting = safeGetService("Lighting")

local LocalPlayer = cloneref(Players.LocalPlayer)
local Camera = cloneref(Workspace.CurrentCamera)

-- ==========================================
-- Configuration (Single Source of Truth)
-- ==========================================
getgenv().Config = getgenv().Config
	or {
		ESP = {
			Enabled = false,
			MaxDistance = 1500,
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
			FOVType = "Default",
			FOVColor = Color3.fromRGB(255, 255, 255),
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
			InstantADS = false,
			ADSZoomMultiplier = 1.0,
			HideViewmodelOnADS = false,
			RapidFire = false,
			RapidFireValue = 3,
			UndergroundDesync = false,
			UndergroundDesyncKeybind = "U",
			FlyKeybind = "T",
			SpiderClimbKeybind = "Y",
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
		Utilities = {
			ModDetector = false,
		},
	}

-- ==========================================
-- LinoriaLib Initialization
-- ==========================================
local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library = assert(loadstring((game :: any):HttpGet(repo .. "Library.lua")))()

local Window = Library:CreateWindow({
	Title = "Cipher | Project Delta",
	Center = true,
	AutoShow = true,
	TabPadding = 8,
	MenuFadeTime = 0.2,
})
getgenv().LinoriaLibrary = Library

-- Tabs
local VisualsTab = Window:AddTab("Visuals")
local CombatTab = Window:AddTab("Combat")
local ModsTab = Window:AddTab("Mods")
local UtilitiesTab = Window:AddTab("Utilities")
local SettingsTab = Window:AddTab("Settings")

-- ==========================================
-- Visuals Tab
-- ==========================================
local ESPSection = VisualsTab:AddLeftGroupbox("ESP")

ESPSection:AddToggle("EnableESP", {
	Text = "Enable ESP",
	Default = getgenv().Config.ESP.Enabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.Enabled = value
end)

ESPSection:AddSlider("ESPMaxDistance", {
	Text = "Max Render Distance",
	Default = getgenv().Config.ESP.MaxDistance or 1500,
	Min = 1,
	Max = 2000,
	Rounding = 0,
	Compact = false,
}):OnChanged(function(value)
	getgenv().Config.ESP.MaxDistance = value
end)

ESPSection:AddToggle("ShowHealthBar", {
	Text = "Show Health Bar",
	Default = getgenv().Config.ESP.ShowHealthBar,
}):OnChanged(function(value)
	getgenv().Config.ESP.ShowHealthBar = value
end)

ESPSection:AddLabel("Text Color"):AddColorPicker("TextColor", {
	Default = getgenv().Config.ESP.TextColor,
	Title = "Text Color",
})
getgenv().Options.TextColor:OnChanged(function(value)
	getgenv().Config.ESP.TextColor = value
end)

ESPSection:AddLabel("Outline Color"):AddColorPicker("OutlineColor", {
	Default = getgenv().Config.ESP.OutlineColor,
	Title = "Outline Color",
})
getgenv().Options.OutlineColor:OnChanged(function(value)
	getgenv().Config.ESP.OutlineColor = value
end)

ESPSection:AddSlider("TextSize", {
	Text = "Text Size",
	Default = getgenv().Config.ESP.TextSize,
	Min = 8,
	Max = 32,
	Rounding = 0,
	Compact = false,
})
getgenv().Options.TextSize:OnChanged(function(value)
	getgenv().Config.ESP.TextSize = value
end)

ESPSection:AddDropdown("ESPFont", {
	Values = { "UI", "System", "Plex", "Monospace" },
	Default = 3, -- 3 represents 'Plex'
	Multi = false,
	Text = "ESP Font",
})
getgenv().Options.ESPFont:OnChanged(function(value)
	local fontMap = { ["UI"] = 0, ["System"] = 1, ["Plex"] = 2, ["Monospace"] = 3 }
	getgenv().Config.ESP.Font = fontMap[value] or 2
end)

ESPSection:AddDivider()

ESPSection:AddToggle("EnableChams", {
	Text = "Enable Chams",
	Default = getgenv().Config.ESP.ChamsEnabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.ChamsEnabled = value
end)

ESPSection:AddLabel("Player Chams Fill Color"):AddColorPicker("ChamsFillColor", {
	Default = getgenv().Config.ESP.ChamsFillColor,
	Title = "Player Chams Fill",
})
getgenv().Options.ChamsFillColor:OnChanged(function(value)
	getgenv().Config.ESP.ChamsFillColor = value
end)

ESPSection:AddLabel("NPC Chams Fill Color"):AddColorPicker("NPCChamsFillColor", {
	Default = getgenv().Config.ESP.NPCChamsFillColor,
	Title = "NPC Chams Fill",
})
getgenv().Options.NPCChamsFillColor:OnChanged(function(value)
	getgenv().Config.ESP.NPCChamsFillColor = value
end)

ESPSection:AddLabel("Chams Outline Color"):AddColorPicker("ChamsOutlineColor", {
	Default = getgenv().Config.ESP.ChamsOutlineColor,
	Title = "Chams Outline",
})
getgenv().Options.ChamsOutlineColor:OnChanged(function(value)
	getgenv().Config.ESP.ChamsOutlineColor = value
end)

ESPSection:AddDivider()

ESPSection:AddToggle("VisibleCheck", {
	Text = "Visible Check",
	Default = getgenv().Config.ESP.VisibleCheck,
}):OnChanged(function(value)
	getgenv().Config.ESP.VisibleCheck = value
end)

ESPSection:AddLabel("Visible Color"):AddColorPicker("VisibleColor", {
	Default = getgenv().Config.ESP.VisibleColor,
	Title = "Visible Color",
})
getgenv().Options.VisibleColor:OnChanged(function(value)
	getgenv().Config.ESP.VisibleColor = value
end)

ESPSection:AddDivider()

ESPSection:AddToggle("EnableNPCESP", {
	Text = "Enable NPC ESP",
	Default = getgenv().Config.ESP.NPCESPEnabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.NPCESPEnabled = value
end)

ESPSection:AddLabel("NPC Text Color"):AddColorPicker("NPCTextColor", {
	Default = getgenv().Config.ESP.NPCTextColor,
	Title = "NPC Text Color",
})
getgenv().Options.NPCTextColor:OnChanged(function(value)
	getgenv().Config.ESP.NPCTextColor = value
end)

ESPSection:AddLabel("NPC Outline Color"):AddColorPicker("NPCOutlineColor", {
	Default = getgenv().Config.ESP.NPCOutlineColor,
	Title = "NPC Outline Color",
})
getgenv().Options.NPCOutlineColor:OnChanged(function(value)
	getgenv().Config.ESP.NPCOutlineColor = value
end)

ESPSection:AddDivider()

ESPSection:AddToggle("EnableCorpseESP", {
	Text = "Enable Corpse ESP",
	Default = getgenv().Config.ESP.CorpseESPEnabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.CorpseESPEnabled = value
end)

ESPSection:AddLabel("Corpse Text Color"):AddColorPicker("CorpseTextColor", {
	Default = getgenv().Config.ESP.CorpseTextColor,
	Title = "Corpse Text Color",
})
getgenv().Options.CorpseTextColor:OnChanged(function(value)
	getgenv().Config.ESP.CorpseTextColor = value
end)

ESPSection:AddLabel("Corpse Outline Color"):AddColorPicker("CorpseOutlineColor", {
	Default = getgenv().Config.ESP.CorpseOutlineColor,
	Title = "Corpse Outline Color",
})
getgenv().Options.CorpseOutlineColor:OnChanged(function(value)
	getgenv().Config.ESP.CorpseOutlineColor = value
end)

ESPSection:AddDivider()

ESPSection:AddToggle("EnableExitESP", {
	Text = "Enable Exit ESP",
	Default = getgenv().Config.ESP.ExitESPEnabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.ExitESPEnabled = value
end)

ESPSection:AddLabel("Exit Text Color"):AddColorPicker("ExitTextColor", {
	Default = getgenv().Config.ESP.ExitTextColor,
	Title = "Exit Text Color",
})
getgenv().Options.ExitTextColor:OnChanged(function(value)
	getgenv().Config.ESP.ExitTextColor = value
end)

ESPSection:AddLabel("Exit Outline Color"):AddColorPicker("ExitOutlineColor", {
	Default = getgenv().Config.ESP.ExitOutlineColor,
	Title = "Exit Outline Color",
})
getgenv().Options.ExitOutlineColor:OnChanged(function(value)
	getgenv().Config.ESP.ExitOutlineColor = value
end)

local BulletTracersSection = VisualsTab:AddRightGroupbox("Bullet Tracers")

BulletTracersSection:AddToggle("EnableBulletTracers", {
	Text = "Enable Bullet Tracers",
	Default = getgenv().Config.SilentAim.BulletTracers,
}):OnChanged(function(value)
	getgenv().Config.SilentAim.BulletTracers = value
end)

BulletTracersSection:AddToggle("TracerGlowEffect", {
	Text = "Glow Effect",
	Default = getgenv().Config.SilentAim.TracerGlowEffect,
}):OnChanged(function(value)
	getgenv().Config.SilentAim.TracerGlowEffect = value
end)

BulletTracersSection:AddDropdown("TracerType", {
	Values = { "Default", "Lightning", "Heartbeat" },
	Default = 1,
	Multi = false,
	Text = "Tracer Type",
})
getgenv().Options.TracerType:OnChanged(function(value)
	getgenv().Config.SilentAim.TracerType = value
end)

BulletTracersSection:AddLabel("Tracer Color"):AddColorPicker("TracerColor", {
	Default = getgenv().Config.SilentAim.TracerColor,
	Title = "Tracer Color",
})
getgenv().Options.TracerColor:OnChanged(function(value)
	getgenv().Config.SilentAim.TracerColor = value
end)

BulletTracersSection:AddSlider("TracerTransparency", {
	Text = "Tracer Transparency",
	Default = getgenv().Config.SilentAim.TracerTransparency,
	Min = 0,
	Max = 1,
	Rounding = 2,
	Compact = false,
})
getgenv().Options.TracerTransparency:OnChanged(function(value)
	getgenv().Config.SilentAim.TracerTransparency = value
end)

local InventoryViewerSection = VisualsTab:AddRightGroupbox("Inventory Viewer")

InventoryViewerSection:AddToggle("EnableInventoryViewer", {
	Text = "Enable Inventory Viewer",
	Default = getgenv().Config.ESP.InventoryViewer,
}):OnChanged(function(value)
	getgenv().Config.ESP.InventoryViewer = value
end)

-- ==========================================
-- Combat Tab
-- ==========================================
local CombatSection = CombatTab:AddLeftGroupbox("Combat Modifications")

CombatSection:AddToggle("InstantADS", {
	Text = "Instant ADS",
	Default = getgenv().Config.Combat.InstantADS,
}):OnChanged(function(value)
	getgenv().Config.Combat.InstantADS = value
end)

CombatSection:AddSlider("ADSZoomMultiplier", {
	Text = "ADS Zoom Multiplier",
	Default = getgenv().Config.Combat.ADSZoomMultiplier,
	Min = 1,
	Max = 20,
	Rounding = 1,
	Compact = false,
})
getgenv().Options.ADSZoomMultiplier:OnChanged(function(value)
	getgenv().Config.Combat.ADSZoomMultiplier = value
end)

CombatSection:AddToggle("HideViewmodelOnADS", {
	Text = "Hide Viewmodel on ADS",
	Default = getgenv().Config.Combat.HideViewmodelOnADS,
}):OnChanged(function(value)
	getgenv().Config.Combat.HideViewmodelOnADS = value
end)

local MovementSection = CombatTab:AddLeftGroupbox("Movement")

MovementSection:AddToggle("UndergroundDesync", {
	Text = "Underground Desync",
	Default = false,
}):AddKeyPicker("UndergroundDesyncKeybind", {
	Default = getgenv().Config.Combat.UndergroundDesyncKeybind or "U",
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "Underground Desync",
	NoUI = false,
})

getgenv().Toggles.UndergroundDesync:OnChanged(function(value)
	getgenv().Config.Combat.UndergroundDesync = value
	if getgenv().LinoriaLibrary then
		if value then
			getgenv().LinoriaLibrary:Notify("Enabled Underground Desync", 3)
		else
			getgenv().LinoriaLibrary:Notify("Disabled Underground Desync", 3)
		end
	end
end)

getgenv().Options.UndergroundDesyncKeybind:OnChanged(function()
	getgenv().Config.Combat.UndergroundDesyncKeybind = getgenv().Options.UndergroundDesyncKeybind.Value
end)

MovementSection:AddLabel("Fly"):AddKeyPicker("FlyKeybind", {
	Default = getgenv().Config.Combat.FlyKeybind,
	SyncToggleState = false,
	Mode = "Toggle",
	Text = "Fly",
	NoUI = false,
})
getgenv().Options.FlyKeybind:OnClick(function()
	getgenv().Config.Combat.FlyKeybind = getgenv().Options.FlyKeybind.Value
end)

MovementSection:AddLabel("Spider Climb"):AddKeyPicker("SpiderClimbKeybind", {
	Default = getgenv().Config.Combat.SpiderClimbKeybind,
	SyncToggleState = false,
	Mode = "Hold",
	Text = "Spider Climb",
	NoUI = false,
})
getgenv().Options.SpiderClimbKeybind:OnClick(function()
	getgenv().Config.Combat.SpiderClimbKeybind = getgenv().Options.SpiderClimbKeybind.Value
end)

local SilentAimSection = CombatTab:AddRightGroupbox("Silent Aim")

SilentAimSection:AddToggle("EnableSilentAim", {
	Text = "Enable Silent Aim",
	Default = getgenv().Config.SilentAim.Enabled,
}):OnChanged(function(value)
	getgenv().Config.SilentAim.Enabled = value
end)

SilentAimSection:AddDropdown("SilentAimTargetType", {
	Values = { "Players", "NPC", "Both" },
	Default = 1,
	Multi = false,
	Text = "Target Type",
})
getgenv().Options.SilentAimTargetType:OnChanged(function(value)
	getgenv().Config.SilentAim.TargetType = value
end)

SilentAimSection:AddDropdown("SilentAimTargetPart", {
	Values = { "Head", "HeadTopHitBox", "UpperTorso" },
	Default = 1,
	Multi = false,
	Text = "Target Part",
})
getgenv().Options.SilentAimTargetPart:OnChanged(function(value)
	getgenv().Config.SilentAim.TargetPart = value
end)

SilentAimSection:AddDivider()

SilentAimSection:AddToggle("ShowFOVCircle", {
	Text = "Show FOV Circle",
	Default = getgenv().Config.SilentAim.ShowFOV,
}):OnChanged(function(value)
	getgenv().Config.SilentAim.ShowFOV = value
end)

SilentAimSection:AddSlider("FOVRadius", {
	Text = "FOV Radius",
	Default = getgenv().Config.SilentAim.FOVRadius,
	Min = 10,
	Max = 800,
	Rounding = 0,
	Compact = false,
})
getgenv().Options.FOVRadius:OnChanged(function(value)
	getgenv().Config.SilentAim.FOVRadius = value
end)

SilentAimSection:AddDropdown("FOVType", {
	Values = { "Default", "Sparkle" },
	Default = 1,
	Multi = false,
	Text = "FOV Type",
})
getgenv().Options.FOVType:OnChanged(function(value)
	getgenv().Config.SilentAim.FOVType = value
end)

SilentAimSection:AddLabel("FOV Color"):AddColorPicker("FOVColor", {
	Default = getgenv().Config.SilentAim.FOVColor,
	Title = "FOV Color",
})
getgenv().Options.FOVColor:OnChanged(function(value)
	getgenv().Config.SilentAim.FOVColor = value
end)

SilentAimSection:AddDivider()

SilentAimSection:AddToggle("ShowSnapline", {
	Text = "Show Snapline",
	Default = getgenv().Config.SilentAim.ShowSnapline,
}):OnChanged(function(value)
	getgenv().Config.SilentAim.ShowSnapline = value
end)

SilentAimSection:AddToggle("VisibleCheckSnapline", {
	Text = "Visible Check (Snapline)",
	Default = getgenv().Config.SilentAim.VisibleCheck,
}):OnChanged(function(value)
	getgenv().Config.SilentAim.VisibleCheck = value
end)

SilentAimSection:AddLabel("Snapline Color"):AddColorPicker("SnaplineColor", {
	Default = getgenv().Config.SilentAim.VisibleColor,
	Title = "Snapline Color",
})
getgenv().Options.SnaplineColor:OnChanged(function(value)
	getgenv().Config.SilentAim.VisibleColor = value
end)

-- ==========================================
-- Mods Tab
-- ==========================================
local ModsSection = ModsTab:AddLeftGroupbox("Gun Mods")

ModsSection:AddToggle("NoRecoil", {
	Text = "No Recoil",
	Default = getgenv().Config.Combat.NoRecoil,
}):OnChanged(function(value)
	getgenv().Config.Combat.NoRecoil = value
end)

ModsSection:AddToggle("NoSpread", {
	Text = "No Spread",
	Default = getgenv().Config.Combat.NoSpread,
}):OnChanged(function(value)
	getgenv().Config.Combat.NoSpread = value
end)

ModsSection:AddToggle("RapidFire", {
	Text = "Rapid Fire",
	Default = getgenv().Config.Combat.RapidFire,
}):OnChanged(function(value)
	getgenv().Config.Combat.RapidFire = value
end)

ModsSection:AddSlider("RapidFireMultiplier", {
	Text = "Rapid Fire Multiplier",
	Default = getgenv().Config.Combat.RapidFireValue,
	Min = 1,
	Max = 50,
	Rounding = 0,
	Compact = false,
})
getgenv().Options.RapidFireMultiplier:OnChanged(function(value)
	getgenv().Config.Combat.RapidFireValue = value
end)

local originalHitsoundVolumes = {}

local function UpdateDefaultHitsounds(mute)
	local RS = ReplicatedStorage
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

local HitsoundSection = ModsTab:AddLeftGroupbox("Hitsound")

HitsoundSection:AddToggle("EnableHitsound", {
	Text = "Enable Hitsound",
	Default = getgenv().Config.Mods.Hitsound,
}):OnChanged(function(value)
	getgenv().Config.Mods.Hitsound = value
	if UpdateDefaultHitsounds then
		UpdateDefaultHitsounds(value)
	end
end)

HitsoundSection:AddDropdown("HitsoundType", {
	Values = { "Rust", "Minecraft", "Bell", "Custom" },
	Default = 1,
	Multi = false,
	Text = "Hitsound Type",
})
getgenv().Options.HitsoundType:OnChanged(function(value)
	getgenv().Config.Mods.HitsoundType = value
end)

HitsoundSection:AddInput("CustomSoundAssetIDorLocalFile", {
	Default = getgenv().Config.Mods.HitsoundCustomId,
	Numeric = false,
	Finished = true,
	Text = "Custom Sound ID/File",
	Tooltip = "e.g. 160432334",
	Placeholder = "Asset ID",
})
getgenv().Options.CustomSoundAssetIDorLocalFile:OnChanged(function(value)
	getgenv().Config.Mods.HitsoundCustomId = value
end)

HitsoundSection:AddSlider("HitsoundVolume", {
	Text = "Hitsound Volume",
	Default = getgenv().Config.Mods.HitsoundVolume,
	Min = 0.1,
	Max = 2.0,
	Rounding = 1,
	Compact = false,
})
getgenv().Options.HitsoundVolume:OnChanged(function(value)
	getgenv().Config.Mods.HitsoundVolume = value
end)

local WorldModsSection = ModsTab:AddRightGroupbox("World")

WorldModsSection:AddToggle("Fullbright", {
	Text = "Fullbright",
	Default = getgenv().Config.Mods.Fullbright,
}):OnChanged(function(value)
	getgenv().Config.Mods.Fullbright = value
end)

WorldModsSection:AddToggle("NoFog", {
	Text = "No Fog",
	Default = getgenv().Config.Mods.NoFog,
}):OnChanged(function(value)
	getgenv().Config.Mods.NoFog = value
end)

WorldModsSection:AddSlider("FOV", {
	Text = "FOV",
	Default = getgenv().Config.Mods.FOV or 70,
	Min = 70,
	Max = 120,
	Rounding = 0,
	Compact = false,
})
getgenv().Options.FOV:OnChanged(function(value)
	getgenv().Config.Mods.FOV = value
end)

-- ==========================================
-- Environment Setup
-- ==========================================
local getgenv = getfenv().getgenv or function()
	return _G
end

getgenv().DebugLogs = {}
getgenv().AddLog = function(msg)
	local timestamp = os.date("%H:%M:%S")
	table.insert(getgenv().DebugLogs, 1, "[" .. timestamp .. "] " .. tostring(msg))
	if #getgenv().DebugLogs > 500 then
		table.remove(getgenv().DebugLogs, 501)
	end
end

-- ==========================================
-- Utilities Tab
-- ==========================================
local ModDetectorSection = UtilitiesTab:AddLeftGroupbox("Mod Detector")

local function CheckMod(player)
	task.spawn(function()
		local isMod = false
		if game.CreatorType == Enum.CreatorType.Group then
			local success, roleName = pcall(function()
				return player:GetRoleInGroup(game.CreatorId)
			end)

			if success and roleName then
				local lowerRole = string.lower(roleName)
				if
					string.find(lowerRole, "mod")
					or string.find(lowerRole, "admin")
					or string.find(lowerRole, "dev")
					or string.find(lowerRole, "owner")
				then
					isMod = true
				end
			end
		elseif game.CreatorType == Enum.CreatorType.User then
			if player.UserId == game.CreatorId then
				isMod = true
			end
		end

		if isMod then
			getgenv().LinoriaLibrary:Notify("A mod has joined: " .. player.Name, 10)
		end
	end)
end

local ModDetectorConnection = nil

ModDetectorSection:AddToggle("ModDetector", {
	Text = "Enable Mod Detector",
	Default = getgenv().Config.Utilities.ModDetector,
}):OnChanged(function(value)
	getgenv().Config.Utilities.ModDetector = value

	if value then
		if not ModDetectorConnection then
			ModDetectorConnection = Players.PlayerAdded:Connect(function(player)
				CheckMod(player)
			end)
			table.insert(ConnectionList, ModDetectorConnection)
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				CheckMod(player)
			end
		end
	else
		if ModDetectorConnection then
			ModDetectorConnection:Disconnect()
			for i, conn in ipairs(ConnectionList) do
				if conn == ModDetectorConnection then
					table.remove(ConnectionList, i)
					break
				end
			end
			ModDetectorConnection = nil
		end
	end
end)

-- ==========================================
-- Main Loop (RenderStepped & Heartbeat)
-- ==========================================
local undergroundDesyncOffset = CFrame.new(0, -3.8, 0) * CFrame.Angles(math.rad(-90), 0, 0)

local function getTargetCharacter()
	local char = Workspace:FindFirstChild(LocalPlayer.Name)
	if char and char:FindFirstChild("HumanoidRootPart") then
		return char
	end
	return nil
end

RunService:BindToRenderStep("UndergroundDesync_Restore", -100, function()
	if getgenv().Config.Combat.UndergroundDesync then
		local Character = getTargetCharacter()
		if Character and getgenv()._StoredRealCFrame then
			Character.HumanoidRootPart.CFrame = getgenv()._StoredRealCFrame
		end
	else
		getgenv()._StoredRealCFrame = nil
	end
end)

local desyncTick = 0
local heartbeatConnection = RunService.Heartbeat:Connect(function()
	if getgenv().Config.Combat.UndergroundDesync then
		local Character = getTargetCharacter()
		if Character then
			local HRP = Character.HumanoidRootPart
			getgenv()._StoredRealCFrame = HRP.CFrame

			local velocity = HRP.AssemblyLinearVelocity
			local rotVelocity = HRP.AssemblyAngularVelocity

			HRP.CFrame = getgenv()._StoredRealCFrame * undergroundDesyncOffset

			desyncTick = desyncTick + 1
			if desyncTick >= 60 and getgenv().AddLog then
				desyncTick = 0
				getgenv().AddLog("Desync Active: Server CFrame updated")
			end

			HRP.AssemblyLinearVelocity = velocity
			HRP.AssemblyAngularVelocity = rotVelocity
		end
	end
end)
table.insert(ConnectionList, heartbeatConnection)

local errorConnection = (GuiService :: any).ErrorMessageChanged:Connect(function(errMessage)
	if setclipboard and getgenv().DebugLogs and #getgenv().DebugLogs > 0 then
		local logString = table.concat(getgenv().DebugLogs, "\n")
		setclipboard("--- PROJECT DELTA CRASH/KICK LOGS ---\nError: " .. tostring(errMessage) .. "\n\n" .. logString)
	end
end)
table.insert(ConnectionList, errorConnection)

if not getgenv().DesyncHooked then
	getgenv().DesyncHooked = true
	local spoofTick = 0
	local oldIndex
	oldIndex = hookmetamethod(
		game,
		"__index",
		newcclosure(function(self, key)
			if not checkcaller() and getgenv().Config.Combat.UndergroundDesync and getgenv()._StoredRealCFrame then
				if key == "CFrame" or key == "Position" then
					local char = getTargetCharacter()
					if char and self == char:FindFirstChild("HumanoidRootPart") then
						spoofTick = spoofTick + 1
						if spoofTick >= 60 and getgenv().AddLog then
							spoofTick = 0
							getgenv().AddLog("Spoofed __index read for " .. tostring(self.Name) .. "." .. key)
						end
						return key == "CFrame" and getgenv()._StoredRealCFrame or getgenv()._StoredRealCFrame.Position
					end
				end
			end
			return oldIndex(self, key)
		end)
	)

	local oldNamecall
	oldNamecall = hookmetamethod(
		game,
		"__namecall",
		newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if not checkcaller() then
				if method == "FireServer" or method == "InvokeServer" then
					if getgenv().AddLog then
						local args = { ... }
						local argStr = ""
						for i, v in ipairs(args) do
							argStr = argStr .. tostring(v) .. (i < #args and ", " or "")
						end
						getgenv().AddLog("Remote Spy: " .. tostring(self.Name) .. ":" .. method .. "(" .. argStr .. ")")
					end
				end
			end
			return oldNamecall(self, ...)
		end)
	)
end

-- ==========================================
-- Settings Tab
-- ==========================================
local UISection = SettingsTab:AddLeftGroupbox("UI")

UISection:AddButton("Unload", function() end)

UISection:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
	Default = "RightControl",
	NoUI = true,
	Text = "Menu Keybind",
})
Library.ToggleKeybind = getgenv().Options.MenuKeybind

local DebugSection = SettingsTab:AddLeftGroupbox("Debugging")

DebugSection:AddButton({
	Text = "Copy Debug Logs",
	Func = function()
		if setclipboard then
			setclipboard(table.concat(getgenv().DebugLogBuffer or {}, "\n"))
			Library:Notify("Successfully copied debug logs to clipboard.")
		end
	end,
	DoubleClick = false,
})

DebugSection:AddButton({
	Text = "Clear Debug Logs",
	Func = function()
		table.clear(getgenv().DebugLogBuffer or {})
		Library:Notify("Debug log buffer has been cleared.")
	end,
	DoubleClick = false,
})
local ThemeDropdown

-- Custom Config Manager

local ConfigFolder = "Cipher/config"
if not isfolder("Cipher") then
	makefolder("Cipher")
end
if not isfolder(ConfigFolder) then
	makefolder(ConfigFolder)
end

local function GetConfigs()
	local configs = {}
	if isfolder(ConfigFolder) then
		local success, files = pcall(listfiles, ConfigFolder)
		if success and type(files) == "table" then
			for _, file in ipairs(files) do
				if file:sub(-5) == ".json" then
					local name = file:match("([^/\\]+)%.json$")
					if name then
						table.insert(configs, name)
					end
				end
			end
		end
	end
	if #configs == 0 then
		return { "Default" }
	end
	return configs
end

local ConfigSection = SettingsTab:AddRightGroupbox("Config")
local currentConfigName = "Default"

ConfigSection:AddInput("ConfigName", {
	Default = "",
	Text = "New Config Name",
	Numeric = false,
	Finished = true,
	Placeholder = "Enter name...",
}):OnChanged(function(value)
	if value and value ~= "" then
		currentConfigName = value
	end
end)

local ConfigDropdown = ConfigSection:AddDropdown("ConfigList", {
	Values = GetConfigs(),
	Default = 1,
	Multi = false,
	Text = "Select Config",
})
ConfigDropdown:OnChanged(function(value)
	currentConfigName = value
end)

local function encodeConfig(config)
	local encoded = {}
	for k, v in pairs(config) do
		if type(v) == "table" then
			encoded[k] = encodeConfig(v)
		elseif typeof(v) == "Color3" then
			encoded[k] = { isColor = true, r = v.R, g = v.G, b = v.B }
		else
			encoded[k] = v
		end
	end
	return encoded
end

local function applyLoadedConfig(data)
	local Toggles = getgenv().Toggles
	local Options = getgenv().Options

	local function safeSetToggle(name, val)
		if Toggles and Toggles[name] and val ~= nil then
			pcall(function()
				Toggles[name]:SetValue(val)
			end)
		end
	end

	local function safeSetOption(name, val)
		if Options and Options[name] and val ~= nil then
			pcall(function()
				Options[name]:SetValue(val)
			end)
		end
	end

	local function parseColor(v)
		if type(v) == "table" and v.isColor then
			return Color3.new(v.r, v.g, v.b)
		elseif typeof(v) == "Color3" then
			return v
		end
		return nil
	end

	if data.ESP then
		safeSetToggle("EnableESP", data.ESP.Enabled)
		safeSetOption("ESPMaxDistance", data.ESP.MaxDistance)
		safeSetToggle("ShowHealthBar", data.ESP.ShowHealthBar)
		safeSetOption("TextColor", parseColor(data.ESP.TextColor))
		safeSetOption("OutlineColor", parseColor(data.ESP.OutlineColor))
		safeSetOption("TextSize", data.ESP.TextSize)

		if data.ESP.Font ~= nil then
			local fontMapReverse = { [0] = "UI", [1] = "System", [2] = "Plex", [3] = "Monospace" }
			safeSetOption("ESPFont", fontMapReverse[data.ESP.Font] or "Plex")
		end

		safeSetToggle("EnableChams", data.ESP.ChamsEnabled)
		safeSetOption("ChamsFillColor", parseColor(data.ESP.ChamsFillColor))
		safeSetOption("NPCChamsFillColor", parseColor(data.ESP.NPCChamsFillColor))
		safeSetOption("ChamsOutlineColor", parseColor(data.ESP.ChamsOutlineColor))
		safeSetToggle("VisibleCheck", data.ESP.VisibleCheck)
		safeSetOption("VisibleColor", parseColor(data.ESP.VisibleColor))

		safeSetToggle("EnableNPCESP", data.ESP.NPCESPEnabled)
		safeSetOption("NPCTextColor", parseColor(data.ESP.NPCTextColor))
		safeSetOption("NPCOutlineColor", parseColor(data.ESP.NPCOutlineColor))

		safeSetToggle("EnableCorpseESP", data.ESP.CorpseESPEnabled)
		safeSetOption("CorpseTextColor", parseColor(data.ESP.CorpseTextColor))
		safeSetOption("CorpseOutlineColor", parseColor(data.ESP.CorpseOutlineColor))

		safeSetToggle("EnableExitESP", data.ESP.ExitESPEnabled)
		safeSetOption("ExitTextColor", parseColor(data.ESP.ExitTextColor))
		safeSetOption("ExitOutlineColor", parseColor(data.ESP.ExitOutlineColor))

		safeSetToggle("EnableInventoryViewer", data.ESP.InventoryViewer)
	end

	if data.SilentAim then
		safeSetToggle("EnableBulletTracers", data.SilentAim.BulletTracers)
		safeSetToggle("TracerGlowEffect", data.SilentAim.TracerGlowEffect)
		safeSetOption("TracerType", data.SilentAim.TracerType)
		safeSetOption("TracerColor", parseColor(data.SilentAim.TracerColor))
		safeSetOption("TracerTransparency", data.SilentAim.TracerTransparency)

		safeSetToggle("EnableSilentAim", data.SilentAim.Enabled)
		safeSetOption("SilentAimTargetType", data.SilentAim.TargetType)
		safeSetOption("SilentAimTargetPart", data.SilentAim.TargetPart)
		safeSetToggle("ShowFOVCircle", data.SilentAim.ShowFOV)
		safeSetOption("FOVType", data.SilentAim.FOVType)
		safeSetOption("FOVColor", parseColor(data.SilentAim.FOVColor))
		safeSetOption("FOVRadius", data.SilentAim.FOVRadius)
		safeSetToggle("ShowSnapline", data.SilentAim.ShowSnapline)
		safeSetToggle("VisibleCheckSnapline", data.SilentAim.VisibleCheck)
		safeSetOption("SnaplineColor", parseColor(data.SilentAim.VisibleColor))
	end

	if data.Combat then
		safeSetToggle("UndergroundDesync", false)
		safeSetOption("UndergroundDesyncKeybind", data.Combat.UndergroundDesyncKeybind)
		safeSetToggle("InstantADS", data.Combat.InstantADS)
		safeSetOption("ADSZoomMultiplier", data.Combat.ADSZoomMultiplier)
		safeSetToggle("HideViewmodelOnADS", data.Combat.HideViewmodelOnADS)
		safeSetOption("FlyKeybind", data.Combat.FlyKeybind)
		safeSetOption("SpiderClimbKeybind", data.Combat.SpiderClimbKeybind)

		safeSetToggle("NoRecoil", data.Combat.NoRecoil)
		safeSetToggle("NoSpread", data.Combat.NoSpread)
		safeSetToggle("RapidFire", data.Combat.RapidFire)
		safeSetOption("RapidFireMultiplier", data.Combat.RapidFireValue)
	end

	if data.Mods then
		safeSetToggle("EnableHitsound", data.Mods.Hitsound)
		safeSetOption("HitsoundType", data.Mods.HitsoundType)
		safeSetOption("CustomSoundAssetIDorLocalFile", data.Mods.HitsoundCustomId)
		safeSetOption("HitsoundVolume", data.Mods.HitsoundVolume)

		safeSetToggle("Fullbright", data.Mods.Fullbright)
		safeSetToggle("NoFog", data.Mods.NoFog)
		safeSetOption("FOV", data.Mods.FOV)
	end

	if data.Utilities then
		safeSetToggle("ModDetector", data.Utilities.ModDetector)
	end

	if data.Theme and ThemeDropdown then
		ThemeDropdown:SetValue(data.Theme)
	end
end

ConfigSection:AddButton({
	Text = "Save / Overwrite",
	Func = function()
		if currentConfigName and currentConfigName ~= "" then
			local success, json = pcall(function()
				return HttpService:JSONEncode(encodeConfig(getgenv().Config))
			end)
			if success then
				pcall(writefile, ConfigFolder .. "/" .. currentConfigName .. ".json", json)
				ConfigDropdown:SetValues(GetConfigs())
				Library:Notify("Saved configuration: " .. currentConfigName)
			else
				Library:Notify("Failed to encode configuration.")
			end
		end
	end,
})

ConfigSection:AddButton({
	Text = "Load Configuration",
	Func = function()
		local path = ConfigFolder .. "/" .. currentConfigName .. ".json"
		if isfile(path) then
			local success, json = pcall(readfile, path)
			if success then
				local success2, data = pcall(HttpService.JSONDecode, HttpService, json)
				if success2 and type(data) == "table" then
					applyLoadedConfig(data)
					Library:Notify("Loaded configuration: " .. currentConfigName)
				else
					Library:Notify("Failed to decode configuration.")
				end
			end
		else
			Library:Notify("Config not found!")
		end
	end,
})

ConfigSection:AddButton({
	Text = "Delete Configuration",
	Func = function()
		local path = ConfigFolder .. "/" .. currentConfigName .. ".json"
		if isfile(path) then
			pcall(delfile, path)
			ConfigDropdown:SetValues(GetConfigs())
			Library:Notify("Deleted configuration: " .. currentConfigName)
		end
	end,
})

ConfigSection:AddButton({
	Text = "Refresh List",
	Func = function()
		ConfigDropdown:SetValues(GetConfigs())
		Library:Notify("Config list refreshed.")
	end,
})

-- Custom Theme Manager
local ThemeSection = SettingsTab:AddRightGroupbox("Themes")

local BuiltInThemes = {
	["Default"] = {
		FontColor = "ffffff",
		MainColor = "1c1c1c",
		AccentColor = "0055ff",
		BackgroundColor = "141414",
		OutlineColor = "323232",
	},
	["BBot"] = {
		FontColor = "ffffff",
		MainColor = "1e1e1e",
		AccentColor = "7e48a3",
		BackgroundColor = "232323",
		OutlineColor = "141414",
	},
	["Fatality"] = {
		FontColor = "ffffff",
		MainColor = "1e1842",
		AccentColor = "c50754",
		BackgroundColor = "191335",
		OutlineColor = "3c355d",
	},
	["Jester"] = {
		FontColor = "ffffff",
		MainColor = "242424",
		AccentColor = "db4467",
		BackgroundColor = "1c1c1c",
		OutlineColor = "373737",
	},
	["Mint"] = {
		FontColor = "ffffff",
		MainColor = "242424",
		AccentColor = "3db488",
		BackgroundColor = "1c1c1c",
		OutlineColor = "373737",
	},
	["Tokyo Night"] = {
		FontColor = "ffffff",
		MainColor = "191925",
		AccentColor = "6759b3",
		BackgroundColor = "16161f",
		OutlineColor = "323232",
	},
	["Ubuntu"] = {
		FontColor = "ffffff",
		MainColor = "3e3e3e",
		AccentColor = "e2581e",
		BackgroundColor = "323232",
		OutlineColor = "191919",
	},
	["Quartz"] = {
		FontColor = "ffffff",
		MainColor = "232330",
		AccentColor = "426e87",
		BackgroundColor = "1d1b26",
		OutlineColor = "27232f",
	},
}

ThemeDropdown = ThemeSection:AddDropdown("ThemeList", {
	Values = { "Default", "BBot", "Fatality", "Jester", "Mint", "Quartz", "Tokyo Night", "Ubuntu" },
	Default = 1,
	Multi = false,
	Text = "Select Theme",
})
ThemeDropdown:OnChanged(function(themeName)
	getgenv().Config.Theme = themeName
	local theme = BuiltInThemes[themeName]
	if theme then
		for idx, hex in pairs(theme) do
			Library[idx] = Color3.fromHex(hex)
		end
		if Library.GetDarkerColor then
			Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
		end
		if Library.UpdateColorsUsingRegistry then
			Library:UpdateColorsUsingRegistry()
		end
	end
end)

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
	table.insert(
		ConnectionList,
		droppedItems.ChildAdded:Connect(function(child)
			if child:IsA("Model") then
				task.wait(0.1)
				if child:FindFirstChild("Humanoid") then
					table.insert(corpseModelsCache, child)
				end
			end
		end)
	)
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
								Character = characterModel,
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
										Character = child,
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
			local targetPartName = config.TargetPart or "Head"
			local aimPart = (playerData.Character and playerData.Character:FindFirstChild(targetPartName))
				or playerData.Head
			if not aimPart then
				continue
			end

			local screenPosition, isVisibleOnScreen = Camera:WorldToViewportPoint(aimPart.Position)
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
	SparkleHead = Drawing.new("Circle"),
	Sparkles = {},
	SparklesPool = {},
}
getgenv().CombatManager = CombatManager

-- Initialize Drawings
CombatManager.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
CombatManager.FOVCircle.Thickness = 1
CombatManager.FOVCircle.Filled = false
CombatManager.FOVCircle.Transparency = 1

CombatManager.SparkleHead.Color = Color3.fromRGB(255, 255, 255)
CombatManager.SparkleHead.Radius = 4
CombatManager.SparkleHead.Thickness = 1
CombatManager.SparkleHead.Filled = true
CombatManager.SparkleHead.Transparency = 1
CombatManager.SparkleHead.Visible = false

CombatManager.Snapline.Color = Color3.fromRGB(255, 0, 0)
CombatManager.Snapline.Thickness = 1
CombatManager.Snapline.Transparency = 1

local math_cos = math.cos
local math_sin = math.sin
local math_random = math.random
local os_clock = os.clock
local Vector2_new = Vector2.new
local Color3_fromRGB = Color3.fromRGB

function CombatManager.Update()
	local config = getgenv().Config.SilentAim
	local mouseLocation = UserInputService:GetMouseLocation()

	-- Update FOV Circle
	if config.ShowFOV then
		CombatManager.FOVCircle.Position = mouseLocation
		CombatManager.FOVCircle.Radius = config.FOVRadius
		CombatManager.FOVCircle.Color = config.FOVColor or Color3_fromRGB(255, 255, 255)
		CombatManager.FOVCircle.Visible = true

		if config.FOVType == "Sparkle" then
			local time = os_clock() * 3
			local radius = config.FOVRadius
			local px = mouseLocation.X + math_cos(time) * radius
			local py = mouseLocation.Y + math_sin(time) * radius

			CombatManager.SparkleHead.Position = Vector2_new(px, py)
			CombatManager.SparkleHead.Color = Color3_fromRGB(255, 255, 255)
			CombatManager.SparkleHead.Visible = true

			if math_random() > 0.3 then
				local particle
				if #CombatManager.SparklesPool > 0 then
					particle = table.remove(CombatManager.SparklesPool)
				else
					particle = Drawing.new("Circle")
				end
				particle.Position = Vector2_new(px, py)
				particle.Radius = math_random(1, 3)
				particle.Color = Color3_fromRGB(255, 255, 255)
				particle.Filled = true
				particle.Transparency = 1
				particle.Visible = true
				table.insert(CombatManager.Sparkles, {
					Drawing = particle,
					Life = 0.5 + math_random() * 0.5,
					MaxLife = 1,
					Velocity = Vector2_new((math_random() - 0.5) * 60, (math_random() - 0.5) * 60),
				})
			end
		else
			CombatManager.SparkleHead.Visible = false
		end
	else
		CombatManager.FOVCircle.Visible = false
		CombatManager.SparkleHead.Visible = false
	end

	local dt = 0.016
	for i = #CombatManager.Sparkles, 1, -1 do
		local p = CombatManager.Sparkles[i]
		p.Life = p.Life - dt
		if p.Life <= 0 or not config.ShowFOV or config.FOVType ~= "Sparkle" then
			p.Drawing.Visible = false
			table.insert(CombatManager.SparklesPool, p.Drawing)
			table.remove(CombatManager.Sparkles, i)
		else
			p.Drawing.Position = p.Drawing.Position + p.Velocity * dt
			p.Drawing.Transparency = p.Life / p.MaxLife
		end
	end

	-- Update Snapline
	TargetManager.CurrentTarget = TargetManager.GetClosestTargetToMouse()

	if config.ShowSnapline and TargetManager.CurrentTarget then
		local targetPartName = config.TargetPart or "Head"
		local aimPart = (
			TargetManager.CurrentTarget.Character
			and TargetManager.CurrentTarget.Character:FindFirstChild(targetPartName)
		) or TargetManager.CurrentTarget.Head
		local headPosition = aimPart.Position
		local screenPosition, isVisible = Camera:WorldToViewportPoint(headPosition)

		if isVisible and screenPosition.Z > 0 then
			local isVisible3D = config.VisibleCheck
				and CharacterManager.IsVisible(
					aimPart,
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
	table.insert(
		ConnectionList,
		(GuiService :: any).ErrorMessageChanged:Connect(function(msg)
			if msg and msg ~= "" and setclipboard then
				setclipboard(table.concat(getgenv().DebugLogBuffer, "\n"))
			end
		end)
	)
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

function ESPManager.RemoveDrawing(character)
	local cacheData = ESPManager.Cache[character]
	if cacheData then
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
		ESPManager.Cache[character] = nil
	end
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
			ESPManager.RemoveDrawing(cachedCharacter)
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
		local distStuds = (Camera.CFrame.Position - data.Head.Position).Magnitude
		local distMeters = math.floor(distStuds * 0.28)
		if distMeters > (config.MaxDistance or 1500) then
			ESPManager.RemoveDrawing(character)
			return
		end

		local isVisible3D = false
		if
			config.VisibleCheck
			and not data.IsCorpse
			and not data.IsExit
			and (config.Enabled or config.ChamsEnabled or config.NPCESPEnabled)
		then
			local targetPartName = getgenv().Config.SilentAim.TargetPart or "Head"
			local aimPart = (character and character:FindFirstChild(targetPartName)) or data.Head
			isVisible3D = CharacterManager.IsVisible(aimPart, character)
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
	if typeof(cColor) == "Color3" then
		return cColor
	end
	if type(cColor) == "string" then
		local s, r = pcall(function()
			return Color3.fromHex(cColor)
		end)
		if s then
			return r
		end
	end
	if type(cColor) == "table" then
		local s, r = pcall(function()
			if cColor.R and cColor.G and cColor.B then
				return Color3.new(cColor.R, cColor.G, cColor.B)
			end
			if cColor[1] and cColor[2] and cColor[3] then
				return Color3.new(cColor[1], cColor[2], cColor[3])
			end
			return Color3.fromRGB(255, 255, 255)
		end)
		if s then
			return r
		end
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

if not getgenv().DeltaTimeTracker then
	getgenv().DeltaTimeTracker = {
		dt = 0.016666,
		connection = RunService.RenderStepped:Connect(function(step)
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
					local targetPartName = getgenv().Config.SilentAim.TargetPart or "Head"
					local targetAimPart = (target.Character and target.Character:FindFirstChild(targetPartName))
						or target.Head
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

		for _, ammoType in ipairs(ammoTypes:GetChildren()) do
			cacheAmmoType(ammoType)
		end

		table.insert(
			ConnectionList,
			ammoTypes.ChildAdded:Connect(function(child)
				task.wait(0.2)
				cacheAmmoType(child)
			end)
		)
	end)
)
getgenv().DeltaIsGun = function(wName)
	if type(wName) ~= "string" or wName == "" or wName == "unknown" then
		return false
	end
	local lower = string.lower(wName)
	local isMeleeOrConsumable = string.find(lower, "scythe")
		or string.find(lower, "ninjato")
		or string.find(lower, "dv2")
		or string.find(lower, "dagger")
		or string.find(lower, "m9xr7")
		or string.find(lower, "karambit")
		or string.find(lower, "sword")
		or string.find(lower, "kukri")
		or string.find(lower, "tomahawk")
		or string.find(lower, "cutlass")
		or string.find(lower, "axe")
		or string.find(lower, "dressing")
		or string.find(lower, "bandage")
		or string.find(lower, "rags")
		or string.find(lower, "ai2")
		or string.find(lower, "ai4")
		or string.find(lower, "milk")
		or string.find(lower, "ifak")
		or string.find(lower, "bottle")
		or string.find(lower, "beans")
		or string.find(lower, "kola")
		or string.find(lower, "cola")
		or string.find(lower, "soda")
		or string.find(lower, "serum")
		or string.find(lower, "key")
		or string.find(lower, "f1")
		or string.find(lower, "rgo")
		or string.find(lower, "rgd")
		or string.find(lower, "m84")
		or string.find(lower, "flare")
		or string.find(lower, "spsh")
		or string.find(lower, "lighter")

	return not isMeleeOrConsumable
end

table.insert(
	ThreadList,
	task.spawn(function()
		local springHooked = false
		local fpsHooked = false
		while task.wait(3.5) do
			pcall(function()
				for _, v in pairs(getgc(true)) do
					if type(v) == "table" then
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
											return newSpring
										end
									end
									springHooked = true
								end
							end
						end

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

									if
										type(self) == "table"
										and rawget(self, "weapon")
										and typeof(self.weapon) == "Instance"
									then
										local wName = string.lower(self.weapon.Name)

										if type(rawget(self, "settings")) == "table" then
											if
												self.settings.MaximumKickBack
												and self.settings.MaximumKickBack ~= 0
												and not rawget(self.settings, "OrigKick")
											then
												self.settings.OrigKick = self.settings.MaximumKickBack
												self.settings.OrigRecoil = self.settings.MaxRecoil
											end
										end

										if getgenv().Config.Combat.NoRecoil then
											getgenv().TemporaryNoRecoil = getgenv().DeltaIsGun(wName)
										else
											getgenv().TemporaryNoRecoil = false
										end

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

										if type(rawget(self, "springs")) == "table" then
											for springName, springObj in pairs(self.springs) do
												if type(springName) == "string" then
													local lName = string.lower(springName)
													if string.find(lName, "recoil") or string.find(lName, "kick") then
														if
															type(springObj) == "table"
															and type(rawget(springObj, "shove")) == "function"
														then
															if not rawget(springObj, "__recoilHooked") then
																local oldShove = springObj.shove
																springObj.shove = function(selfObj, force, ...)
																	if getgenv().TemporaryNoRecoil then
																		return oldShove(
																			selfObj,
																			Vector3.new(0, 0, 0),
																			...
																		)
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
							end
						end

						if type(rawget(v, "shove")) == "function" and type(rawget(v, "update")) == "function" then
							if not rawget(v, "__isHooked") then
								rawset(v, "__isHooked", true)
							end
						end

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
								if
									v.settings.MaximumKickBack
									and v.settings.MaximumKickBack ~= 0
									and not rawget(v.settings, "OrigKick")
								then
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

							if type(rawget(v, "springs")) == "table" then
								for springName, springObj in pairs(v.springs) do
									if type(springName) == "string" then
										local lName = string.lower(springName)
										if string.find(lName, "recoil") or string.find(lName, "kick") then
											if
												type(springObj) == "table"
												and type(rawget(springObj, "shove")) == "function"
											then
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

if not getgenv().OriginalNamecall then
	getgenv().OriginalNamecall = hookmetamethod(
		game,
		"__namecall",
		newcclosure(function(self, ...)
			if getgenv().DeltaNamecallHook then
				return getgenv().DeltaNamecallHook(self, ...)
			end
			return getgenv().OriginalNamecall(self, ...)
		end)
	)
end

getgenv().DeltaNamecallHook = newcclosure(function(self, ...)
	local oldNamecall = getgenv().OriginalNamecall
	local method = getnamecallmethod()
	local args = { ... }

	if method == "FireServer" then
		local selfName = typeof(self) == "Instance" and self.Name or ""
		if selfName == "ProjectileInflict" or selfName == "MeleeInflict" or selfName == "MeleeInfIict" then
			if getgenv().HitsoundManager and getgenv().HitsoundManager.Play then
				getgenv().HitsoundManager.Play()
			end
		end
	end

	if method == "Play" then
		if typeof(self) == "Instance" and self:IsA("AnimationTrack") then
			local name = self.Name

			if getgenv().TemporaryNoRecoil then
				if string.match(name, "UseAiming$") or string.match(name, "Use$") or string.match(name, "UseAlt$") then
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
				return 0.001
			end
		end
	elseif method == "GetAttributes" then
		local attrs = oldNamecall(self, ...)
		if
			type(attrs) == "table"
			and (
				getgenv().Config.Combat.NoRecoil
				or getgenv().Config.Combat.NoSpread
				or getgenv().Config.SilentAim.Enabled
			)
		then
			local callingScript = getcallingscript()
			if callingScript then
				local sName = string.lower(callingScript.Name)
				if string.find(sName, "anticheat") or string.find(sName, "uac") or string.find(sName, "ultimate") then
					return attrs
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
					newAttrs[k] = type(v) == "number" and 0.001 or v
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
				local lp = LocalPlayer
				local pf = ReplicatedStorage:FindFirstChild("Players")
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

	if not checkcaller() and getgenv().Config.Combat.NoRecoil then
		if
			method == "InvokeServer"
			and string.match(string.lower(self.Name), "projectile")
			and getgenv().Config.Combat.NoRecoil
		then
			local rs = ReplicatedStorage
			local updateTiltRemote = rs and rs:FindFirstChild("UpdateTilt", true)
			if updateTiltRemote and updateTiltRemote:IsA("RemoteEvent") then
				local fakePitch = -0.05 - (math.random() * 0.04)
				updateTiltRemote:FireServer(fakePitch, 0, nil, nil)
			end
		end
	end

	setnamecallmethod(method)
	-- Deep Enforce 'Auto' Mode
	return oldNamecall(self, ...)
end)

local oldRandom
oldRandom = hookfunction(
	math.random,
	newcclosure(function(...)
		-- Remove Bolt Action / Pump delays that block automatic fire loops
		local args = { ... }
		local min, max = args[1], args[2]

		if getgenv().Config.Combat.NoSpread then
			local callingScript = getcallingscript()
			if callingScript and string.find(string.lower(callingScript.Name), "bullet") then
				if type(min) == "number" and type(max) == "number" then
					if LogLine then
						LogLine("[NoSpread] Centering math.random call from " .. callingScript.Name)
					end
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

local oldRandomNew
oldRandomNew = hookfunction(
	Random.new,
	newcclosure(function(seed)
		local rng = oldRandomNew(seed)
		if getgenv().Config.Combat.NoSpread then
			local callingScript = getcallingscript()
			-- ==========================================
			-- WorldMods Manager
			-- ==========================================
			if callingScript and string.find(string.lower(callingScript.Name), "bullet") then
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
							-- ==========================================
							-- Hitsound Manager
							-- ==========================================
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

								if stats.FireModes then
									table.clear(stats.FireModes)
									table.insert(stats.FireModes, "Auto")
								end
								if stats.FireMode then
									stats.FireMode = "Auto"
								end

								if stats.CycleTiming then
									stats.CycleTiming = { 0, 0 }
								end
								if stats.EjectionDelay then
									stats.EjectionDelay = 0
								end
							else
								if stats.FireRate ~= originalFireRates[itemName] then
									stats.FireRate = originalFireRates[itemName]
									-- ==========================================
									-- InventoryViewer Manager
									-- ==========================================
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

local WorldModsManager = {}

function WorldModsManager.Update()
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

local HitsoundManager = {
	Initialized = false,
	Remotes = {},
	Sounds = {
		Rust = "rbxassetid://4764109000",
		Minecraft = "rbxassetid://88387457337661",
		Bell = "rbxassetid://138901307926331",
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
		pcall(function()
			local sound = Instance.new("Sound")
			sound.SoundId = soundId
			sound.Volume = config.HitsoundVolume or 1
			sound.Parent = SoundService
			sound:Play()

			sound.Ended:Connect(function()
				sound:Destroy()
			end)

			task.delay(5, function()
				if sound and sound.Parent then
					sound:Destroy()
				end
			end)
		end)
	end)
end

function HitsoundManager.Initialize()
	if HitsoundManager.Initialized then
		return
	end

	HitsoundManager.Initialized = true
end

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
	-- Categorize and sort: Gun (1), Mag (2), Bullet (3), Other (4)
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
			-- Position containers

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
	-- Create background
	local y = InventoryViewer.UserPosition.Y

	x = math.clamp(x, 0, math.max(0, viewportSize.X - width))
	y = math.clamp(y, 0, math.max(0, viewportSize.Y - totalHeight))
	InventoryViewer.UserPosition = Vector2.new(x, y)

	InventoryViewer.Background.Position = Vector2.new(x, y)
	-- Create border
	InventoryViewer.Background.Size = Vector2.new(width, totalHeight)
	InventoryViewer.Background.Visible = true

	InventoryViewer.Border.Position = Vector2.new(x, y)
	InventoryViewer.Border.Size = Vector2.new(width, totalHeight)
	InventoryViewer.Border.Visible = true

	local targetName = targetInfo.Name or (targetInfo.Player and targetInfo.Player.Name) or "Unknown"
	-- Create title
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
	-- Check viewport size changes

	for _, child in ipairs(inventoryFolder:GetDescendants()) do
		connectItemAttributes(child)
	end

	table.insert(inventoryConnections, inventoryFolder.DescendantAdded:Connect(connectItemAttributes))
	-- Check closest target to mouse
end

function InventoryViewer.Initialize()
	local background = Drawing.new("Square")
	background.Filled = true
	background.Color = Color3.fromRGB(15, 15, 15)
	background.Transparency = 0.7
	background.Visible = false
	InventoryViewer.Background = background

	local border = Drawing.new("Square")
	border.Filled = false
	border.Thickness = 1.5
	border.Color = Color3.fromRGB(80, 80, 80)
	border.Transparency = 0.8
	border.Visible = false
	InventoryViewer.Border = border

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
	-- Listen to viewport size changes while we have a target
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
		-- Initialize InventoryViewer drawings
		ConnectionList,
		UserInputService.InputChanged:Connect(function(input)
			-- Initialize Hitsounds
			if input.UserInputType == Enum.UserInputType.MouseMovement and InventoryViewer.IsDragging then
				local mousePos = UserInputService:GetMouseLocation()
				-- Spawn target check loop (4 times per second for high performance)
				InventoryViewer.UserPosition = mousePos - InventoryViewer.DragOffset
				InventoryViewer.Draw()
			end
		end)
	)

	table.insert(
		ConnectionList,
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				-- ==========================================
				-- Main Loop
				-- ==========================================
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

	local viewportSize = Camera.ViewportSize
	if not InventoryViewer.LastViewportSize or InventoryViewer.LastViewportSize ~= viewportSize then
		InventoryViewer.LastViewportSize = viewportSize
		InventoryViewer.Draw()
	end

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
							-- Fly up smoothly
						end)
					)
				end
			end

			table.insert(
				inventoryConnections,
				Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
					-- Teleport directly back to the origin
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

InventoryViewer.Initialize()

pcall(HitsoundManager.Initialize)

table.insert(
	ThreadList,
	task.spawn(function()
		while true do
			pcall(InventoryViewer.CheckTarget)
			task.wait(0.25)
		end
	end)
)

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
	pcall(UpdateViewmodelTransparency)
	WorldModsManager.Update()
	ESPManager.Update()
	CombatManager.Update()
	BulletTracerManager.Update()
end)
table.insert(ConnectionList, renderConnection)

local currentSpiderTween = nil

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

			local startCFrame = hrp.CFrame
			local targetCFrame = startCFrame + Vector3.new(0, 12, 0)

			local tweenUp = TweenService:Create(
				hrp,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ CFrame = targetCFrame }
			)

			tweenUp:Play()
			tweenUp.Completed:Connect(function()
				hrp.CFrame = startCFrame
			end)
		end

		if combatConfig.SpiderClimbKeybind and input.KeyCode.Name == combatConfig.SpiderClimbKeybind then
			local character = Workspace:FindFirstChild(LocalPlayer.Name)
			if not character then
				return
			end
			local hrp = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
			if not hrp then
				return
			end

			if currentSpiderTween then
				currentSpiderTween:Cancel()
			end

			local distance = 1000
			local speed = 18 -- 18 studs per second
			local targetCFrame = hrp.CFrame + Vector3.new(0, distance, 0)

			currentSpiderTween = TweenService:Create(
				hrp,
				TweenInfo.new(distance / speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
				{ CFrame = targetCFrame }
			)
			currentSpiderTween:Play()
		end
	end)
)

table.insert(
	ConnectionList,
	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		local combatConfig = getgenv().Config.Combat

		if combatConfig.SpiderClimbKeybind and input.KeyCode.Name == combatConfig.SpiderClimbKeybind then
			if currentSpiderTween then
				currentSpiderTween:Cancel()
				currentSpiderTween = nil
			end
		end
	end)
)
