local ConnectionList = {}
local ThreadList = {}
getgenv()._DeltaScriptSilentToggles = true

if getgenv().OriginalTerrainDecoration == nil then
	local s, r = pcall(function()
		return workspace.Terrain.Decoration
	end)
	if s then
		getgenv().OriginalTerrainDecoration = r
	else
		getgenv().OriginalTerrainDecoration = true
	end
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
local _TweenService = safeGetService("TweenService")
local _SoundService = safeGetService("SoundService")
local _Lighting = safeGetService("Lighting")

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
			ForceRender = false,
			ShowHealthBar = false,
			TextColor = Color3.fromRGB(255, 255, 255),
			OutlineColor = Color3.fromRGB(0, 0, 0),
			TextSize = 13,
			Font = 2, -- Drawing.Fonts.Plex
			ShowDistance = true,
			ShowKDR = true,
			ChamsEnabled = false,
			ChamsFillColor = Color3.fromHex("#7f4a83"),
			NPCChamsFillColor = Color3.fromHex("#7f4a83"),
			BoundingBox2DEnabled = false,
			BoundingBox2DStyle = "Default",
			BoundingBox2DColor = Color3.fromRGB(0, 0, 0),
			VisibleCheck = false,
			VisibleColor = Color3.fromRGB(0, 255, 0),
			NPCESPEnabled = false,
			NPCTextColor = Color3.fromRGB(255, 255, 255),
			NPCOutlineColor = Color3.fromRGB(0, 0, 0),
			HelicopterESPEnabled = false,
			HelicopterTextColor = Color3.fromRGB(204, 0, 255),
			HelicopterOutlineColor = Color3.fromRGB(0, 0, 0),
			CorpseESPEnabled = false,
			CorpseTextColor = Color3.fromRGB(169, 169, 169),
			CorpseOutlineColor = Color3.fromRGB(0, 0, 0),
			ExitESPEnabled = false,
			ExitTextColor = Color3.fromRGB(255, 165, 0),
			ExitOutlineColor = Color3.fromRGB(0, 0, 0),
			InventoryViewer = false,
			LockInventoryViewer = false,
			InventoryViewerX = nil,
			InventoryViewerY = nil,
			InventoryViewerOnlyNecessary = false,
			InventoryViewerTextSize = 13,
			TargetInfoHUD = false,
			LockTargetInfoHUD = false,
			TargetInfoHUDX = nil,
			TargetInfoHUDY = nil,
			HideArms = false,
			ViewmodelArmChams = false,
			ViewmodelArmColor = Color3.fromRGB(255, 255, 255),
			ViewmodelArmMaterial = "ForceField",
			ViewmodelGunChams = false,
			ViewmodelGunColor = Color3.fromRGB(255, 255, 255),
			ViewmodelGunMaterial = "ForceField",
			ViewmodelChamsTransparency = 0.55,
			ViewmodelOffsetX = 0,
			ViewmodelOffsetY = 0,
			ViewmodelOffsetZ = 0,
		},
		SilentAim = {
			Enabled = false,
			TargetType = "Players",
			FOVRadius = 150,
			TargetPart = "Head",
			WhitelistPlayers = {},
			HitlistPlayers = {},
			UndergroundResolverKeybind = "C",
			UndergroundDuration = 1.0,
			UndergroundDistance = 20,
			ShowFOV = false,
			FOVType = "Default",
			FOVColor = Color3.fromHex("#7f48a3"),
			ShowSnapline = false,
			SnaplineColor = Color3.fromHex("#7f48a3"),
			VisibleCheck = false,
			VisibleColor = Color3.fromRGB(0, 255, 0),
			BulletTracers = false,
			TracerType = "Default",
			TracerColor = Color3.fromHex("#7f4a83"),
			TracerTransparency = 0.5,
			TracerGlowEffect = false,
		},
		Combat = {
			ShowCrosshair = false,
			CrosshairType = "Default",
			CrosshairColor = Color3.fromHex("#7f48a3"),
			CrosshairSize = 13.6,
			CrosshairDistance = 6.8,
			CrosshairRotationSpeed = 3,
			TriggerBot = false,
			InstantHit = false,
			TPKill = false,
			TPKillKeybind = "G",
			TPKillType = "Above",
			TPKillHeight = 200,
			OriginManipulation = false,
			OriginManipulationDistance = 5,
			LiftHitboxes = false,
			LiftHitboxesHeight = 2,
			NoRecoil = false,
			NoScope = false,
			NoSway = false,
			NoBob = false,
			NoSpread = false,
			InstantADS = false,
			ADSZoomMultiplier = 1.0,
			HideViewmodelOnADS = false,
			RapidFire = false,
			RapidFireValue = 3,
			InstantEquip = false,
			UndergroundDesync = false,
			UndergroundDesyncKeybind = "U",
			AntiAim = false,
			AntiAimKeybind = "/",
			AntiAimRadius = 6,
			SkyPeekKeybind = "T",
			SkyPeekDistance = 20,
			SkyPeekDuration = 1.0,
			SpiderClimbKeybind = "Y",
			Autopilot = false,
		},
		Mods = {
			ThirdPerson = false,
			ThirdPersonKeybind = "J",
			ZoomDistance = 15,
			FOV = 70,
			WorldTime = 12,
			NoVisor = false,
			NoFallDamage = false,
			Speedhack = false,
			WalkspeedValue = 16,
			Fullbright = false,
			NoFog = false,
			Gloom = false,
			NoShadows = false,
			NoFoliage = false,
			RemoveGrass = false,
			NoLandmines = false,
			Hitsound = false,
			HitsoundType = "Rust",
			HitsoundVolume = 1.0,
			HitsoundCustomId = "",
			HitEffects = false,
			HitEffectsColor = Color3.fromHex("#7f48a3"),
			WeatherType = "None",
		},
		Utilities = {
			ClipCharacter = false,
			ClipCharacterKeybind = "F2",
			ModDetector = false,
			ModDetectorVolume = 1.0,
			LockKeybindHUD = false,
			KeybindHUDX = nil,
			KeybindHUDY = nil,
		},
	}

-- ==========================================
-- LinoriaLib Initialization
-- ==========================================
local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library = assert(loadstring((game :: any):HttpGet(repo .. "Library.lua")))()

local Window = Library:CreateWindow({
	Title = "Retro | Project Delta",
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

ESPSection:AddToggle("ESP", {
	Text = "ESP",
	Default = getgenv().Config.ESP.Enabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.Enabled = value
	if not value then
		if getgenv().ESPManager and getgenv().ESPManager.Cache then
			for character, cacheData in pairs(getgenv().ESPManager.Cache) do
				-- Players have a valid Humanoid and usually aren't an NPC/Corpse/Exit/Heli based on the existing ActiveEnemies list
				-- We can just check if CharacterManager.GetActiveCharacters() has it
				local activePlayers = nil
				if getgenv().CharacterManager and getgenv().CharacterManager.GetActiveCharacters then
					activePlayers = getgenv().CharacterManager.GetActiveCharacters()
				end
				if activePlayers and activePlayers[character] then
					if getgenv().ESPManager.RemoveDrawing then
						getgenv().ESPManager.RemoveDrawing(character)
					end
				end
			end
		end
		if getgenv().DeltaChamsCache then
			local activePlayers = nil
			if getgenv().CharacterManager and getgenv().CharacterManager.GetActiveCharacters then
				activePlayers = getgenv().CharacterManager.GetActiveCharacters()
			end
			if activePlayers then
				for character, highlight in pairs(getgenv().DeltaChamsCache) do
					if activePlayers[character] then
						highlight:Destroy()
						getgenv().DeltaChamsCache[character] = nil
					end
				end
			end
		end
	end
end)

ESPSection:AddSlider("ESPMaxDistance", {
	Text = "Max Render Distance",
	Default = getgenv().Config.ESP.MaxDistance or 1500,
	Min = 1,
	Max = 2000,
	Rounding = 0,
	Compact = true,
}):OnChanged(function(value)
	getgenv().Config.ESP.MaxDistance = value
end)

ESPSection:AddToggle("ForceRender", {
	Text = "Force Render",
	Default = getgenv().Config.ESP.ForceRender,
}):OnChanged(function(value)
	getgenv().Config.ESP.ForceRender = value
end)

ESPSection:AddToggle("HealthBar", {
	Text = "Health Bar",
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
	Compact = true,
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

ESPSection:AddToggle("Chams", {
	Text = "Chams",
	Default = getgenv().Config.ESP.ChamsEnabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.ChamsEnabled = value
	if not value then
		if getgenv().DeltaChamsCache then
			for character, highlight in pairs(getgenv().DeltaChamsCache) do
				highlight:Destroy()
			end
			table.clear(getgenv().DeltaChamsCache)
		end
	end
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
getgenv().Options.NPCChamsFillColor:OnChanged(function(value) end)

ESPSection:AddDivider()

ESPSection:AddToggle("2DBoundingBox", {
	Text = "2D Bounding Box",
	Default = getgenv().Config.ESP.BoundingBox2DEnabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.BoundingBox2DEnabled = value
end)

ESPSection:AddDropdown("BoundingBox2DStyle", {
	Values = { "Default", "Corner" },
	Default = 1,
	Multi = false,
	Text = "2D Bounding Box Style",
})
getgenv().Options.BoundingBox2DStyle:OnChanged(function(value)
	getgenv().Config.ESP.BoundingBox2DStyle = value
end)

ESPSection:AddLabel("2D Box Color"):AddColorPicker("2DBoxColor", {
	Default = getgenv().Config.ESP.BoundingBox2DColor,
	Title = "2D Box Color",
})
getgenv().Options["2DBoxColor"]:OnChanged(function(value)
	getgenv().Config.ESP.BoundingBox2DColor = value
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

ESPSection:AddToggle("NPCESP", {
	Text = "NPC ESP",
	Default = getgenv().Config.ESP.NPCESPEnabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.NPCESPEnabled = value
	if not value then
		if getgenv().ESPManager and getgenv().ESPManager.Cache then
			for character, cacheData in pairs(getgenv().ESPManager.Cache) do
				if character and character.Name and string.match(character.Name, "^NPC") then
					if getgenv().ESPManager.RemoveDrawing then
						getgenv().ESPManager.RemoveDrawing(character)
					end
				end
			end
		end
		if getgenv().DeltaChamsCache then
			local activeNPCs = nil
			if getgenv().CharacterManager and getgenv().CharacterManager.GetNPCs then
				activeNPCs = getgenv().CharacterManager.GetNPCs()
			end
			if activeNPCs then
				for character, highlight in pairs(getgenv().DeltaChamsCache) do
					if activeNPCs[character] then
						highlight:Destroy()
						getgenv().DeltaChamsCache[character] = nil
					end
				end
			end
		end
	end
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

ESPSection:AddToggle("HelicopterESP", {
	Text = "Helicopter ESP",
	Default = getgenv().Config.ESP.HelicopterESPEnabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.HelicopterESPEnabled = value
	if not value then
		if getgenv().ESPManager and getgenv().ESPManager.Cache then
			for character, cacheData in pairs(getgenv().ESPManager.Cache) do
				if character and (character.Name == "C130" or character.Name == "Littlebird") then
					if getgenv().ESPManager.RemoveDrawing then
						getgenv().ESPManager.RemoveDrawing(character)
					end
				end
			end
		end
		if getgenv().DeltaChamsCache then
			local activeHelicopters = nil
			if getgenv().CharacterManager and getgenv().CharacterManager.GetHelicopterESP then
				activeHelicopters = getgenv().CharacterManager.GetHelicopterESP()
			end
			if activeHelicopters then
				for character, highlight in pairs(getgenv().DeltaChamsCache) do
					if activeHelicopters[character] then
						highlight:Destroy()
						getgenv().DeltaChamsCache[character] = nil
					end
				end
			end
		end
	end
end)

ESPSection:AddLabel("Helicopter Text Color"):AddColorPicker("HelicopterTextColor", {
	Default = getgenv().Config.ESP.HelicopterTextColor,
	Title = "Helicopter Text Color",
})
getgenv().Options.HelicopterTextColor:OnChanged(function(value)
	getgenv().Config.ESP.HelicopterTextColor = value
end)

ESPSection:AddLabel("Helicopter Outline Color"):AddColorPicker("HelicopterOutlineColor", {
	Default = getgenv().Config.ESP.HelicopterOutlineColor,
	Title = "Helicopter Outline Color",
})
getgenv().Options.HelicopterOutlineColor:OnChanged(function(value)
	getgenv().Config.ESP.HelicopterOutlineColor = value
end)

ESPSection:AddDivider()

ESPSection:AddToggle("CorpseESP", {
	Text = "Corpse ESP",
	Default = getgenv().Config.ESP.CorpseESPEnabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.CorpseESPEnabled = value
	if not value then
		if getgenv().ESPManager and getgenv().ESPManager.Cache then
			for character, cacheData in pairs(getgenv().ESPManager.Cache) do
				if character and character:IsA("Model") and character:FindFirstChild("LootingCollider") then
					if getgenv().ESPManager.RemoveDrawing then
						getgenv().ESPManager.RemoveDrawing(character)
					end
				end
			end
		end
	end
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

ESPSection:AddToggle("ExitESP", {
	Text = "Exit ESP",
	Default = getgenv().Config.ESP.ExitESPEnabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.ExitESPEnabled = value
	if not value then
		if getgenv().ESPManager and getgenv().ESPManager.Cache then
			for character, cacheData in pairs(getgenv().ESPManager.Cache) do
				if character and character:IsA("BasePart") and character.Name == "ExfilCollider" then
					if getgenv().ESPManager.RemoveDrawing then
						getgenv().ESPManager.RemoveDrawing(character)
					end
				end
			end
		end
	end
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

BulletTracersSection:AddToggle("BulletTracers", {
	Text = "Bullet Tracers",
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
	Values = { "Default", "Lightning", "Heartbeat", "Retro Laser" },
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
	Compact = true,
})
getgenv().Options.TracerTransparency:OnChanged(function(value)
	getgenv().Config.SilentAim.TracerTransparency = value
end)

local InventoryViewerSection = VisualsTab:AddRightGroupbox("Inventory Viewer")

InventoryViewerSection:AddToggle("InventoryViewer", {
	Text = "Inventory Viewer",
	Default = getgenv().Config.ESP.InventoryViewer,
}):OnChanged(function(value)
	getgenv().Config.ESP.InventoryViewer = value
end)

InventoryViewerSection:AddToggle("LockInventoryViewer", {
	Text = "Lock Inventory Viewer",
	Default = getgenv().Config.ESP.LockInventoryViewer,
}):OnChanged(function(value)
	getgenv().Config.ESP.LockInventoryViewer = value
	if getgenv().InventoryViewer then
		getgenv().InventoryViewer.Locked = value
	end
end)

InventoryViewerSection:AddToggle("InventoryViewerOnlyNecessary", {
	Text = "Only Show Necessary",
	Default = getgenv().Config.ESP.InventoryViewerOnlyNecessary or false,
}):OnChanged(function(value)
	getgenv().Config.ESP.InventoryViewerOnlyNecessary = value
	if getgenv().InventoryViewer and getgenv().InventoryViewer.Draw then
		getgenv().InventoryViewer.Draw()
	end
end)

InventoryViewerSection:AddSlider("InventoryViewerTextSize", {
	Text = "Text Size",
	Default = getgenv().Config.ESP.InventoryViewerTextSize or 13,
	Min = 8,
	Max = 20,
	Rounding = 0,
	Compact = true,
})
getgenv().Options.InventoryViewerTextSize:OnChanged(function(value)
	getgenv().Config.ESP.InventoryViewerTextSize = value
	if getgenv().InventoryViewer and getgenv().InventoryViewer.Draw then
		getgenv().InventoryViewer.Draw()
	end
end)

local TargetInfoSection = VisualsTab:AddRightGroupbox("Target Info")

TargetInfoSection:AddToggle("TargetInfoHUD", {
	Text = "Target Info HUD",
	Default = getgenv().Config.ESP.TargetInfoHUD,
}):OnChanged(function(value)
	getgenv().Config.ESP.TargetInfoHUD = value
	if getgenv().TargetHUDManager and getgenv().TargetHUDManager.SetVisibility then
		getgenv().TargetHUDManager.SetVisibility(value)
	end
end)

TargetInfoSection:AddToggle("LockTargetInfoHUD", {
	Text = "Lock Target Info HUD",
	Default = getgenv().Config.ESP.LockTargetInfoHUD,
}):OnChanged(function(value)
	getgenv().Config.ESP.LockTargetInfoHUD = value
end)

TargetInfoSection:AddSlider("TargetInfoHUDSize", {
	Text = "HUD Size",
	Default = getgenv().Config.ESP.TargetInfoHUDSize or 0.8,
	Min = 0.5,
	Max = 2.0,
	Rounding = 2,
	Compact = true,
}):OnChanged(function(value)
	getgenv().Config.ESP.TargetInfoHUDSize = value
end)

local CharacterSection = VisualsTab:AddRightGroupbox("Viewmodel")

CharacterSection:AddToggle("HideArms", {
	Text = "Hide Arms",
	Default = getgenv().Config.ESP.HideArms,
}):OnChanged(function(value)
	getgenv().Config.ESP.HideArms = value
end)

CharacterSection:AddToggle("ArmChams", {
	Text = "Arm Chams",
	Default = getgenv().Config.ESP.ViewmodelArmChams,
}):OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelArmChams = value
end)

CharacterSection:AddLabel("Arm Color"):AddColorPicker("ArmColor", {
	Default = getgenv().Config.ESP.ViewmodelArmColor,
	Title = "Arm Color",
})
getgenv().Options.ArmColor:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelArmColor = value
end)

CharacterSection:AddDropdown("ArmMaterial", {
	Values = { "ForceField", "Neon", "SmoothPlastic", "Glass" },
	Default = getgenv().Config.ESP.ViewmodelArmMaterial,
	Multi = false,
	Text = "Arm Material",
})
getgenv().Options.ArmMaterial:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelArmMaterial = value
end)

CharacterSection:AddDivider()

CharacterSection:AddToggle("GunChams", {
	Text = "Gun Chams",
	Default = getgenv().Config.ESP.ViewmodelGunChams,
}):OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelGunChams = value
end)

CharacterSection:AddLabel("Gun Color"):AddColorPicker("GunColor", {
	Default = getgenv().Config.ESP.ViewmodelGunColor,
	Title = "Gun Color",
})
getgenv().Options.GunColor:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelGunColor = value
end)

CharacterSection:AddDropdown("GunMaterial", {
	Values = { "ForceField", "Neon", "SmoothPlastic", "Glass" },
	Default = getgenv().Config.ESP.ViewmodelGunMaterial,
	Multi = false,
	Text = "Gun Material",
})
getgenv().Options.GunMaterial:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelGunMaterial = value
end)

CharacterSection:AddDivider()

CharacterSection:AddSlider("ViewmodelChamsTransparency", {
	Text = "Chams Transparency",
	Default = getgenv().Config.ESP.ViewmodelChamsTransparency,
	Min = 0,
	Max = 1,
	Rounding = 2,
	Compact = false,
})
getgenv().Options.ViewmodelChamsTransparency:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelChamsTransparency = value
end)

CharacterSection:AddSlider("ViewmodelOffsetX", {
	Text = "Viewmodel X Offset",
	Default = getgenv().Config.ESP.ViewmodelOffsetX,
	Min = -5,
	Max = 5,
	Rounding = 1,
	Compact = true,
})
getgenv().Options.ViewmodelOffsetX:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelOffsetX = value
end)

CharacterSection:AddSlider("ViewmodelOffsetY", {
	Text = "Viewmodel Y Offset",
	Default = getgenv().Config.ESP.ViewmodelOffsetY,
	Min = -5,
	Max = 5,
	Rounding = 1,
	Compact = true,
})
getgenv().Options.ViewmodelOffsetY:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelOffsetY = value
end)

CharacterSection:AddSlider("ViewmodelOffsetZ", {
	Text = "Viewmodel Z Offset",
	Default = getgenv().Config.ESP.ViewmodelOffsetZ,
	Min = -5,
	Max = 5,
	Rounding = 1,
	Compact = true,
})
getgenv().Options.ViewmodelOffsetZ:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelOffsetZ = value
end)

-- ==========================================
-- Combat Tab
-- ==========================================
local CombatSection = CombatTab:AddLeftGroupbox("Combat Modifications")

CombatSection:AddToggle("InstantHit", {
	Text = "Instant Hit",
	Default = getgenv().Config.Combat.InstantHit,
}):OnChanged(function(value)
	getgenv().Config.Combat.InstantHit = value
end)

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
	Compact = true,
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

CombatSection:AddDivider()

CombatSection:AddToggle("TPKill", {
	Text = "TP Kill",
	Default = getgenv().Config.Combat.TPKill,
}):AddKeyPicker("TPKillKeybind", {
	Default = getgenv().Config.Combat.TPKillKeybind,
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "TP Kill Bind",
	NoUI = false,
})
getgenv().Toggles.TPKill:OnChanged(function(value)
	getgenv().Config.Combat.TPKill = value

	if value then
		-- Activate
		local target = getgenv().TargetManager and getgenv().TargetManager.CurrentTarget
		local targetPart = target and (target.Character and target.Character:FindFirstChild("HumanoidRootPart"))

		if targetPart then
			local character = Workspace:FindFirstChild(LocalPlayer.Name)
			local hrp = character and (character.PrimaryPart or character:FindFirstChild("HumanoidRootPart"))
			if hrp then
				if getgenv().AddLog then
					getgenv().AddLog(
						string.format(
							"[TPKill] Activated on target: %s",
							targetPart.Parent and targetPart.Parent.Name or "Unknown"
						)
					)
				end
				getgenv()._TPKillOriginalCFrame = hrp.CFrame
				getgenv()._TPKillActive = true
				getgenv()._TPKillTarget = targetPart
				getgenv()._TPKillStartTime = tick()
				getgenv()._TPKillLastClick = 0
				getgenv()._tpkill_ready = false
				getgenv()._tpkill_waiting = false

				-- Invisible anchored platform so the server sees the character
				-- standing (not falling). Without it the server rejects damage.
				local platform = Instance.new("Part")
				platform.Size = Vector3.new(4, 0.5, 4)
				platform.Anchored = true
				platform.CanCollide = true
				platform.CanQuery = false
				platform.CastShadow = false
				platform.Transparency = 1
				platform.Name = "DeltaTPKillPlatform"
				platform.Parent = workspace:FindFirstChild("NoCollision") or workspace.CurrentCamera
				getgenv()._TPKillPlatform = platform

				local combatConfig = getgenv().Config.Combat
				local height = combatConfig.TPKillHeight or 200
				local newPos
				if combatConfig.TPKillType == 2 or combatConfig.TPKillType == "Below" then
					local undergroundDist = math.min(80, height)
					local safeY = targetPart.Position.Y - undergroundDist
					if safeY <= -3 then
						safeY = -3 + 5
					end
					newPos = Vector3.new(targetPart.Position.X, safeY, targetPart.Position.Z)
				else
					newPos = targetPart.Position + Vector3.new(0, height, 0)
				end

				platform.Position = newPos - Vector3.new(0, 3, 0)
				hrp.CFrame = CFrame.new(newPos) * hrp.CFrame.Rotation
			end
		else
			-- No target available, immediately deactivate
			if getgenv().AddLog then
				getgenv().AddLog("[TPKill] Failed to activate: No target found")
			end
			getgenv().Toggles.TPKill:SetValue(false)
		end
	else
		-- Deactivate
		if getgenv()._TPKillActive then
			if getgenv().AddLog then
				getgenv().AddLog("[TPKill] Deactivated and restoring position")
			end
			local character = Workspace:FindFirstChild(LocalPlayer.Name)
			local hrp = character and (character.PrimaryPart or character:FindFirstChild("HumanoidRootPart"))
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if hrp and getgenv()._TPKillOriginalCFrame then
				hrp.CFrame = getgenv()._TPKillOriginalCFrame + Vector3.new(0, 2, 0)
				if getgenv().Config.Combat.UndergroundDesync or getgenv().Config.Combat.AntiAim then
					getgenv()._StoredRealCFrame = hrp.CFrame
				end

				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.Landed)
				end
				hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end

			if getgenv()._TPKillPlatform then
				getgenv()._TPKillPlatform:Destroy()
				getgenv()._TPKillPlatform = nil
			end

			getgenv()._TPKillActive = false
			getgenv()._TPKillOriginalCFrame = nil
			getgenv()._TPKillTarget = nil
			getgenv()._TPKillPos = nil
		end
	end
end)
getgenv().Options.TPKillKeybind:OnClick(function()
	getgenv().Config.Combat.TPKillKeybind = getgenv().Options.TPKillKeybind.Value
end)

CombatSection:AddDropdown("TPKillType", {
	Values = { "Above", "Below" },
	Default = 1,
	Multi = false,
	Text = "TP Kill Mode",
})
getgenv().Options.TPKillType:OnChanged(function(value)
	getgenv().Config.Combat.TPKillType = value
end)

CombatSection:AddSlider("TPKillHeight", {
	Text = "TP Kill Distance",
	Default = getgenv().Config.Combat.TPKillHeight or 200,
	Min = 5,
	Max = 300,
	Rounding = 0,
	Compact = true,
})
getgenv().Options.TPKillHeight:OnChanged(function(value)
	getgenv().Config.Combat.TPKillHeight = value
end)

CombatSection:AddToggle("OriginManipulation", {
	Text = "Origin Manipulation",
	Default = getgenv().Config.Combat.OriginManipulation,
	Tooltip = "Must have Instant Hit enabled.",
}):OnChanged(function(value)
	getgenv().Config.Combat.OriginManipulation = value
end)

CombatSection:AddSlider("OriginManipulationDistance", {
	Text = "Manipulation Distance",
	Default = getgenv().Config.Combat.OriginManipulationDistance or 5,
	Min = 1,
	Max = 15,
	Rounding = 0,
	Compact = true,
})
getgenv().Options.OriginManipulationDistance:OnChanged(function(value)
	getgenv().Config.Combat.OriginManipulationDistance = value
end)

CombatSection:AddToggle("LiftHitboxes", {
	Text = "Lift Hitboxes",
	Default = getgenv().Config.Combat.LiftHitboxes,
}):OnChanged(function(value)
	getgenv().Config.Combat.LiftHitboxes = value
end)

CombatSection:AddSlider("LiftHitboxesHeight", {
	Text = "Lift Height",
	Default = getgenv().Config.Combat.LiftHitboxesHeight or 2,
	Min = 1,
	Max = 15,
	Rounding = 1,
	Compact = true,
})
getgenv().Options.LiftHitboxesHeight:OnChanged(function(value)
	getgenv().Config.Combat.LiftHitboxesHeight = value
end)

local MovementSection = CombatTab:AddLeftGroupbox("Movement")

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

MovementSection:AddLabel("Sky Peek"):AddKeyPicker("SkyPeekKeybind", {
	Default = getgenv().Config.Combat.SkyPeekKeybind,
	SyncToggleState = false,
	Mode = "Toggle",
	Text = "Sky Peek",
	NoUI = false,
})
getgenv().Options.SkyPeekKeybind:OnClick(function()
	getgenv().Config.Combat.SkyPeekKeybind = getgenv().Options.SkyPeekKeybind.Value
end)

MovementSection:AddSlider("SkyPeekDistance", {
	Text = "Sky Peek Distance",
	Default = getgenv().Config.Combat.SkyPeekDistance,
	Min = 10,
	Max = 80,
	Rounding = 0,
	Compact = true,
})
getgenv().Options.SkyPeekDistance:OnChanged(function(value)
	getgenv().Config.Combat.SkyPeekDistance = value
end)

MovementSection:AddSlider("SkyPeekDuration", {
	Text = "Sky Peek Duration",
	Default = getgenv().Config.Combat.SkyPeekDuration,
	Min = 0.1,
	Max = 2.0,
	Rounding = 1,
	Compact = true,
})
getgenv().Options.SkyPeekDuration:OnChanged(function(value)
	getgenv().Config.Combat.SkyPeekDuration = value
end)

local AntiAimSection = CombatTab:AddLeftGroupbox("Anti-Aim")

AntiAimSection:AddToggle("UndergroundDesync", {
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

	-- Persistent crouch-hold strategy:
	-- Keep the server permanently informed of our crouching state for the
	-- entire UGR session. This eliminates per-shot timing race conditions
	-- and matches the behavior of manual crouching exactly.
	task.spawn(function()
		pcall(function()
			-- Cache the UpdateCrouch remote if not already cached
			if not getgenv().CachedUpdateCrouch then
				for _, v in ipairs(game:GetDescendants()) do
					if v:IsA("RemoteEvent") and v.Name == "UpdateCrouch" then
						getgenv().CachedUpdateCrouch = v
						break
					end
				end
			end

			local char = cloneref(game:GetService("Players").LocalPlayer.Character)
			local humanoid = char and char:FindFirstChildOfClass("Humanoid")

			if value then
				-- Enable: immediately crouch on server and hold it
				if humanoid then
					humanoid:SetAttribute("Crouch", true)
				end
				if getgenv().CachedUpdateCrouch then
					getgenv()._IsScriptCrouch = true
					getgenv().CachedUpdateCrouch:FireServer(true)
					getgenv()._IsScriptCrouch = false
				end

				-- Stop any crouch/walk/run animation tracks to hide visual effect
				local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
				if animator then
					for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
						local lowerName = string.lower(track.Name or "")
						if
							string.find(lowerName, "crouch")
							or string.find(lowerName, "walk")
							or string.find(lowerName, "run")
						then
							track:Stop(0)
						end
					end
				end
			else
				-- Disable: release the persistent crouch
				if humanoid and humanoid.Parent then
					humanoid:SetAttribute("Crouch", false)
				end
				if getgenv().CachedUpdateCrouch then
					getgenv()._IsScriptCrouch = true
					getgenv().CachedUpdateCrouch:FireServer(false)
					getgenv()._IsScriptCrouch = false
				end
			end
		end)
	end)

	if not getgenv()._DeltaScriptSilentToggles and getgenv().LinoriaLibrary then
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

AntiAimSection:AddToggle("AntiAim", {
	Text = "Anti-Aim",
	Default = false,
}):AddKeyPicker("AntiAimKeybind", {
	Default = getgenv().Config.Combat.AntiAimKeybind or "/",
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "Anti-Aim",
})
getgenv().Toggles.AntiAim:OnChanged(function(value)
	getgenv().Config.Combat.AntiAim = value
	getgenv().Config.Combat.AntiAim = value
	if not getgenv()._DeltaScriptSilentToggles and getgenv().LinoriaLibrary then
		if value then
			getgenv().LinoriaLibrary:Notify("Enabled Anti-Aim", 3)
		else
			getgenv().LinoriaLibrary:Notify("Disabled Anti-Aim", 3)
		end
	end
end)
getgenv().Options.AntiAimKeybind:OnChanged(function()
	getgenv().Config.Combat.AntiAimKeybind = getgenv().Options.AntiAimKeybind.Value
end)

AntiAimSection:AddSlider("AntiAimRadius", {
	Text = "Jitter Radius",
	Default = getgenv().Config.Combat.AntiAimRadius or 5,
	Min = 2,
	Max = 5,
	Rounding = 1,
	Compact = true,
})
getgenv().Options.AntiAimRadius:OnChanged(function(value)
	getgenv().Config.Combat.AntiAimRadius = value
end)

local AutopilotSection = CombatTab:AddLeftGroupbox("Autopilot")

-- Removed IsVisibleFrameByFrame: Autopilot now efficiently uses CharacterManager.IsVisible

AutopilotSection:AddToggle("Autopilot", {
	Text = "Autopilot",
	Tooltip = "Requires Instant Hit and Silent Aim to work.",
	Default = getgenv().Config.Combat.Autopilot or false,
}):OnChanged(function(value)
	getgenv().Config.Combat.Autopilot = value
	if not getgenv()._DeltaScriptSilentToggles and getgenv().LinoriaLibrary then
		if value then
			getgenv().LinoriaLibrary:Notify("Enabled Autopilot", 3)
		else
			getgenv().LinoriaLibrary:Notify("Disabled Autopilot", 3)
		end
	end

	if getgenv()._DeltaIsAutoHolding == nil then
		getgenv()._DeltaIsAutoHolding = false
	end
	-- Removed unused pulse tracking variables

	if value then
		if not getgenv()._AutopilotConnection then
			getgenv()._AutopilotConnection = game:GetService("RunService").RenderStepped:Connect(function()
				if
					not (
						getgenv().Config.Combat.Autopilot
						and getgenv().Config.SilentAim.Enabled
						and getgenv().Config.Combat.InstantHit
					)
				then
					if getgenv()._DeltaIsAutoHolding then
						local ctrl = getgenv()._DeltaActiveWeaponTable
						if type(ctrl) == "table" then
							rawset(ctrl, "MouseHeld", false)
							rawset(ctrl, "LeftMouseDown", false)
						end
						getgenv()._DeltaIsAutoHolding = false
					end
					getgenv()._AutopilotTargetOverride = nil
					return
				end

				local candidates = {}
				local cameraPos = game:GetService("Workspace").CurrentCamera.CFrame.Position
				local localPlayer = Players.LocalPlayer
				local whitelistPlayers = getgenv().Config.SilentAim.WhitelistPlayers or {}
				local hitlistPlayers = getgenv().Config.SilentAim.HitlistPlayers or {}
				local hasHitlist = next(hitlistPlayers) ~= nil
				local targetPartName = getgenv().Config.SilentAim.TargetPart or "Head"

				local function processCharacters(characters)
					if not characters then
						return
					end
					for characterModel, data in pairs(characters) do
						local player = data.Player
						if player == localPlayer then
							continue
						end

						if player then
							local playerName = player.Name
							if whitelistPlayers[playerName] then
								continue
							end
							if hasHitlist and not hitlistPlayers[playerName] then
								continue
							end
						end

						local char = data.Character
						if char and char:IsA("Model") then
							local targetPart = char:FindFirstChild(targetPartName) or data.Head
							if targetPart then
								local rootPart = char:FindFirstChild("HumanoidRootPart")
								local hum = char:FindFirstChildOfClass("Humanoid")
								local health = (rootPart and rootPart:GetAttribute("Health"))
									or (hum and hum.Health)
									or 0

								if health > 0 then
									table.insert(candidates, {
										Data = data,
										Char = char,
										Part = targetPart,
										RootPart = rootPart,
										Humanoid = hum,
										Dist = (targetPart.Position - cameraPos).Magnitude,
										Player = player,
									})
								end
							end
						end
					end
				end

				if getgenv().CharacterManager then
					local targetType = getgenv().Config.SilentAim.TargetType or "Players"
					if targetType == "Players" or targetType == "Both" then
						processCharacters(
							getgenv().CharacterManager.GetActiveCharacters
								and getgenv().CharacterManager.GetActiveCharacters()
						)
					end
					if targetType == "NPC" or targetType == "Both" then
						processCharacters(getgenv().CharacterManager.GetNPCs and getgenv().CharacterManager.GetNPCs())
					end
				end

				if not getgenv()._AutopilotPenaltyQueue then
					getgenv()._AutopilotPenaltyQueue = {}
				end

				table.sort(candidates, function(a, b)
					local pA = getgenv()._AutopilotPenaltyQueue[a.Char] or 0
					local pB = getgenv()._AutopilotPenaltyQueue[b.Char] or 0
					if pA ~= pB then
						return pA < pB
					end
					return a.Dist < b.Dist
				end)

				local shouldShoot = false
				local overrideData = nil

				for _, cand in ipairs(candidates) do
					local isVis = false
					if getgenv().CharacterManager and getgenv().CharacterManager.IsVisible then
						isVis = getgenv().CharacterManager.IsVisible(cand.Part, cand.Char)
					end

					if isVis then
						local health = (cand.RootPart and cand.RootPart:GetAttribute("Health"))
							or (cand.Humanoid and cand.Humanoid.Health)
							or 0

						if not getgenv()._AutopilotDamageTracker then
							getgenv()._AutopilotDamageTracker = {}
						end

						local tracker = getgenv()._AutopilotDamageTracker
						if tracker.Target ~= cand.Char then
							tracker.Target = cand.Char
							tracker.InitialHealth = health
							tracker.LastHealthTime = os.clock()
						else
							if health < tracker.InitialHealth then
								tracker.InitialHealth = health
								tracker.LastHealthTime = os.clock()
							else
								if os.clock() - tracker.LastHealthTime > 0.3 then
									getgenv()._AutopilotPenaltyQueue[cand.Char] = os.clock()
									tracker.LastHealthTime = os.clock()
									continue
								end
							end
						end

						shouldShoot = true
						overrideData = {
							Player = cand.Player,
							Character = cand.Char,
							Head = cand.Part,
							RootPart = cand.RootPart,
							Humanoid = cand.Humanoid,
							Type = cand.Player and "Player" or "NPC",
						}
						break
					end
				end

				if shouldShoot and overrideData then
					getgenv()._AutopilotTargetOverride = overrideData
					local ctrl = getgenv()._DeltaActiveWeaponTable

					if type(ctrl) == "table" then
						if not getgenv()._DeltaIsAutoHolding then
							if getgenv()._DeltaNativePress then
								getgenv()._DeltaNativePress(ctrl)
							end
							getgenv()._DeltaIsAutoHolding = true
							getgenv()._DeltaLastAutoPressTime = os.clock()
						else
							local rapidFire = getgenv().Config
								and getgenv().Config.Combat
								and getgenv().Config.Combat.RapidFire
							if not rapidFire then
								if os.clock() - (getgenv()._DeltaLastAutoPressTime or 0) > 0.05 then
									if getgenv()._DeltaNativeRelease then
										getgenv()._DeltaNativeRelease(ctrl)
									end
									getgenv()._DeltaIsAutoHolding = false
								end
							end
						end
					else
						if getgenv()._DeltaIsAutoHolding then
							getgenv()._DeltaIsAutoHolding = false
						end
					end
				else
					getgenv()._AutopilotTargetOverride = nil
					if getgenv()._DeltaIsAutoHolding then
						local ctrl = getgenv()._DeltaActiveWeaponTable
						if type(ctrl) == "table" and getgenv()._DeltaNativeRelease then
							getgenv()._DeltaNativeRelease(ctrl)
						end
						getgenv()._DeltaIsAutoHolding = false
					end
				end
			end)
			table.insert(ConnectionList, getgenv()._AutopilotConnection)
		end
	else
		if getgenv()._AutopilotConnection then
			getgenv()._AutopilotConnection:Disconnect()
			for i, conn in ipairs(ConnectionList) do
				if conn == getgenv()._AutopilotConnection then
					table.remove(ConnectionList, i)
					break
				end
			end
			getgenv()._AutopilotConnection = nil
		end

		getgenv()._AutopilotTargetOverride = nil
		if getgenv()._DeltaIsAutoHolding then
			local ctrl = getgenv()._DeltaActiveWeaponTable
			if type(ctrl) == "table" and getgenv()._DeltaNativeRelease then
				getgenv()._DeltaNativeRelease(ctrl)
			end
			getgenv()._DeltaIsAutoHolding = false
		end
	end
end)

local WhitelistSection = CombatTab:AddLeftGroupbox("Whitelist/Hitlist")

local function GetCurrentPlayerNames()
	local names = {}
	if game and game:GetService("Players") then
		for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
			if player ~= game:GetService("Players").LocalPlayer then
				table.insert(names, player.Name)
			end
		end
	end
	return names
end

WhitelistSection:AddDropdown("PlayerToWhitelist", {
	Values = GetCurrentPlayerNames(),
	Default = 1,
	Multi = false,
	Text = "Select Player",
})

WhitelistSection:AddButton({
	Text = "Refresh Player List",
	Func = function()
		getgenv().Options.PlayerToWhitelist:SetValues(GetCurrentPlayerNames())
		if getgenv().LinoriaLibrary then
			getgenv().LinoriaLibrary:Notify("Refreshed player list", 3)
		end
	end,
})

local function UpdateList(listName, isAdding)
	local player = getgenv().Options.PlayerToWhitelist.Value
	if type(player) == "string" and player ~= "" then
		local targetList = getgenv().Config.SilentAim[listName]
		local otherListName = listName == "WhitelistPlayers" and "HitlistPlayers" or "WhitelistPlayers"
		local otherList = getgenv().Config.SilentAim[otherListName]

		local listStr = listName == "WhitelistPlayers" and "whitelist" or "hitlist"

		if isAdding then
			if targetList[player] then
				if getgenv().LinoriaLibrary then
					getgenv().LinoriaLibrary:Notify(player .. " is already in the " .. listStr, 3)
				end
				return
			end

			targetList[player] = true

			if otherList[player] then
				otherList[player] = nil
			end

			if getgenv().LinoriaLibrary then
				getgenv().LinoriaLibrary:Notify("Added " .. player .. " to " .. listStr, 3)
			end
		else
			if not targetList[player] then
				if getgenv().LinoriaLibrary then
					getgenv().LinoriaLibrary:Notify(player .. " is not in the " .. listStr, 3)
				end
				return
			end

			targetList[player] = nil

			if getgenv().LinoriaLibrary then
				getgenv().LinoriaLibrary:Notify("Removed " .. player .. " from " .. listStr, 3)
			end
		end
	else
		if getgenv().LinoriaLibrary then
			local action = isAdding and "add to " or "remove from "
			local listStr = listName == "WhitelistPlayers" and "whitelist" or "hitlist"
			getgenv().LinoriaLibrary:Notify("No player selected to " .. action .. listStr, 3)
		end
	end
end

WhitelistSection:AddButton({
	Text = "Add To Whitelist",
	Func = function()
		UpdateList("WhitelistPlayers", true)
	end,
})

WhitelistSection:AddButton({
	Text = "Remove From Whitelist",
	Func = function()
		UpdateList("WhitelistPlayers", false)
	end,
})

WhitelistSection:AddDivider()

WhitelistSection:AddButton({
	Text = "Add To Hitlist",
	Func = function()
		UpdateList("HitlistPlayers", true)
	end,
})

WhitelistSection:AddButton({
	Text = "Remove From Hitlist",
	Func = function()
		UpdateList("HitlistPlayers", false)
	end,
})

WhitelistSection:AddButton({
	Text = "Clear Hitlist",
	Func = function()
		table.clear(getgenv().Config.SilentAim.HitlistPlayers)
		if getgenv().LinoriaLibrary then
			getgenv().LinoriaLibrary:Notify("Hitlist cleared", 3)
		end
	end,
})

local SilentAimSection = CombatTab:AddRightGroupbox("Aiming")

SilentAimSection:AddToggle("Crosshair", {
	Text = "Crosshair",
	Default = getgenv().Config.Combat.ShowCrosshair,
}):OnChanged(function(value)
	getgenv().Config.Combat.ShowCrosshair = value
end)

SilentAimSection:AddDropdown("CrosshairType", {
	Values = { "Default", "Rotation", "Nazi" },
	Default = 1,
	Multi = false,
	Text = "Crosshair Type",
})
getgenv().Options.CrosshairType:OnChanged(function(value)
	getgenv().Config.Combat.CrosshairType = value
end)

SilentAimSection:AddLabel("Crosshair Color"):AddColorPicker("CrosshairColor", {
	Default = getgenv().Config.Combat.CrosshairColor or Color3.fromHex("#7f48a3"),
	Title = "Crosshair Color",
})
getgenv().Options.CrosshairColor:OnChanged(function()
	getgenv().Config.Combat.CrosshairColor = getgenv().Options.CrosshairColor.Value
end)

SilentAimSection:AddSlider("CrosshairSize", {
	Text = "Crosshair Size",
	Default = getgenv().Config.Combat.CrosshairSize,
	Min = 1,
	Max = 50,
	Rounding = 1,
	Compact = true,
})
getgenv().Options.CrosshairSize:OnChanged(function(value)
	getgenv().Config.Combat.CrosshairSize = value
end)

SilentAimSection:AddSlider("CrosshairDistance", {
	Text = "Crosshair Distance",
	Default = getgenv().Config.Combat.CrosshairDistance,
	Min = 0,
	Max = 50,
	Rounding = 1,
	Compact = true,
})
getgenv().Options.CrosshairDistance:OnChanged(function(value)
	getgenv().Config.Combat.CrosshairDistance = value
end)

SilentAimSection:AddSlider("CrosshairRotationSpeed", {
	Text = "Crosshair Rotation Speed",
	Default = getgenv().Config.Combat.CrosshairRotationSpeed,
	Min = 1,
	Max = 10,
	Rounding = 1,
	Compact = true,
})
getgenv().Options.CrosshairRotationSpeed:OnChanged(function(value)
	getgenv().Config.Combat.CrosshairRotationSpeed = value
end)

SilentAimSection:AddDivider()

SilentAimSection:AddToggle("TriggerBot", {
	Text = "Trigger Bot",
	Default = getgenv().Config.Combat.TriggerBot,
}):OnChanged(function(value)
	getgenv().Config.Combat.TriggerBot = value
end)

SilentAimSection:AddToggle("SilentAim", {
	Text = "Silent Aim",
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

local ResolverSection = CombatTab:AddRightGroupbox("Resolver")

ResolverSection:AddLabel("Underground Resolver"):AddKeyPicker("UndergroundResolverKeybind", {
	Default = (getgenv().Config.SilentAim.UndergroundResolverKeybind == "" and "C")
		or getgenv().Config.SilentAim.UndergroundResolverKeybind
		or "C",
	SyncToggleState = false,
	Mode = "Toggle",
	Text = "Underground Resolver",
	NoUI = false,
})
getgenv().Options.UndergroundResolverKeybind:OnClick(function()
	getgenv().Config.SilentAim.UndergroundResolverKeybind = getgenv().Options.UndergroundResolverKeybind.Value
end)

ResolverSection:AddSlider("UndergroundDistance", {
	Text = "Underground Distance",
	Default = getgenv().Config.SilentAim.UndergroundDistance or 20,
	Min = 10,
	Max = 80,
	Rounding = 0,
	Compact = true,
})
getgenv().Options.UndergroundDistance:OnChanged(function(value)
	getgenv().Config.SilentAim.UndergroundDistance = value
end)

ResolverSection:AddSlider("UndergroundDuration", {
	Text = "Underground Duration",
	Default = getgenv().Config.SilentAim.UndergroundDuration or 1.0,
	Min = 0.1,
	Max = 2.0,
	Rounding = 1,
	Compact = true,
})
getgenv().Options.UndergroundDuration:OnChanged(function(value)
	getgenv().Config.SilentAim.UndergroundDuration = value
end)

SilentAimSection:AddDivider()

SilentAimSection:AddToggle("FOVCircle", {
	Text = "FOV Circle",
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
	Compact = true,
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

SilentAimSection:AddToggle("Snapline", {
	Text = "Snapline",
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
	Default = getgenv().Config.SilentAim.SnaplineColor,
	Title = "Snapline Color",
})
getgenv().Options.SnaplineColor:OnChanged(function(value)
	getgenv().Config.SilentAim.SnaplineColor = value
end)

SilentAimSection:AddLabel("Visible Snapline Color"):AddColorPicker("VisibleSnaplineColor", {
	Default = getgenv().Config.SilentAim.VisibleColor,
	Title = "Visible Snapline Color",
})
getgenv().Options.VisibleSnaplineColor:OnChanged(function(value)
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
	if getgenv()._DeltaActiveWeaponTable then
		local self = getgenv()._DeltaActiveWeaponTable
		local wName = string.lower((self.weapon and self.weapon.Name) or "")
		getgenv().TemporaryNoRecoil = value and getgenv().DeltaIsGun(wName) or false
		if type(rawget(self, "settings")) == "table" then
			if getgenv().TemporaryNoRecoil then
				self.settings.MaximumKickBack = 0
				self.settings.MaxRecoil = 0
			elseif rawget(self.settings, "OrigKick") then
				self.settings.MaximumKickBack = self.settings.OrigKick
				self.settings.MaxRecoil = self.settings.OrigRecoil
			end
		end
	end
end)

ModsSection:AddToggle("NoScope", {
	Text = "No Scope",
	Default = getgenv().Config.Combat.NoScope,
}):OnChanged(function(value)
	getgenv().Config.Combat.NoScope = value
end)

local function UpdateWeaponSwayAndBob()
	if getgenv()._DeltaActiveWeaponTable and type(rawget(getgenv()._DeltaActiveWeaponTable, "settings")) == "table" then
		local self = getgenv()._DeltaActiveWeaponTable
		local settings = self.settings

		if not rawget(self, "OrigSprintIdleOffset") then
			self.OrigSprintIdleOffset = self.sprintIdleOffset
		end
		if not rawget(settings, "OrigSprintOffSet") then
			settings.OrigSprintOffSet = settings.sprintOffSet
		end
		if not rawget(settings, "OrigSprintSway") then
			settings.OrigSprintSway = settings.SprintSwayModifer
		end
		if not rawget(settings, "OrigWalkSway") then
			settings.OrigWalkSway = settings.WalkSwayModifer
		end
		if not rawget(settings, "OrigIdleSway") then
			settings.OrigIdleSway = settings.IdleSwayModifier
		end
		if not rawget(settings, "OrigSwayMult") then
			settings.OrigSwayMult = settings.swayMult
		end

		if getgenv().Config.Combat.NoSway then
			settings.sprintOffSet = Vector3.zero
			self.sprintOffSet = Vector3.zero
			settings.swayMult = 0
			self.swayMult = 0
			if self.weaponOffSet then
				self.sprintIdleOffset = self.weaponOffSet
			end
		else
			if rawget(settings, "OrigSprintOffSet") then
				settings.sprintOffSet = settings.OrigSprintOffSet
				self.sprintOffSet = settings.OrigSprintOffSet
			end
			if rawget(settings, "OrigSwayMult") then
				settings.swayMult = settings.OrigSwayMult
				self.swayMult = settings.OrigSwayMult
			end
			if rawget(self, "OrigSprintIdleOffset") then
				self.sprintIdleOffset = self.OrigSprintIdleOffset
			end
		end

		if getgenv().Config.Combat.NoBob then
			settings.SprintSwayModifer = 0
			settings.WalkSwayModifer = 0
			settings.IdleSwayModifier = 0
			self.SprintSwayModifer = 0
			self.WalkSwayModifer = 0
			self.IdleSwayModifier = 0
		else
			if rawget(settings, "OrigSprintSway") then
				settings.SprintSwayModifer = settings.OrigSprintSway
				self.SprintSwayModifer = settings.OrigSprintSway
			end
			if rawget(settings, "OrigWalkSway") then
				settings.WalkSwayModifer = settings.OrigWalkSway
				self.WalkSwayModifer = settings.OrigWalkSway
			end
			if rawget(settings, "OrigIdleSway") then
				settings.IdleSwayModifier = settings.OrigIdleSway
				self.IdleSwayModifier = settings.OrigIdleSway
			end
		end

		if type(rawget(self, "springs")) == "table" then
			for springName, springObj in pairs(self.springs) do
				if
					type(springName) == "string"
					and type(springObj) == "table"
					and type(rawget(springObj, "update")) == "function"
				then
					local lName = string.lower(springName)

					if lName == "sway" or lName == "gunsway" then
						if not rawget(springObj, "__noSwayUpdateHooked") then
							local oldUpdate = springObj.update
							springObj.update = function(selfObj, ...)
								if getgenv().Config.Combat.NoSway then
									return Vector3.zero
								end
								return oldUpdate(selfObj, ...)
							end
							rawset(springObj, "__noSwayUpdateHooked", true)
						end
					end

					if
						lName == "walkcycle"
						or lName == "sprintcycle"
						or lName == "strafetilt"
						or lName == "jumptilt"
						or lName == "jumpcameratilt"
					then
						if not rawget(springObj, "__noBobUpdateHooked") then
							local oldUpdate = springObj.update
							springObj.update = function(selfObj, ...)
								if getgenv().Config.Combat.NoBob then
									return Vector3.zero
								end
								return oldUpdate(selfObj, ...)
							end
							rawset(springObj, "__noBobUpdateHooked", true)
						end
					end
				end
			end
		end
	end
end
getgenv().UpdateWeaponSwayAndBob = UpdateWeaponSwayAndBob

ModsSection:AddToggle("NoSway", {
	Text = "No Sway",
	Default = getgenv().Config.Combat.NoSway,
}):OnChanged(function(value)
	getgenv().Config.Combat.NoSway = value
	if getgenv().UpdateWeaponSwayAndBob then
		getgenv().UpdateWeaponSwayAndBob()
	end
end)

ModsSection:AddToggle("NoBob", {
	Text = "No Bob",
	Default = getgenv().Config.Combat.NoBob,
}):OnChanged(function(value)
	getgenv().Config.Combat.NoBob = value
	if getgenv().UpdateWeaponSwayAndBob then
		getgenv().UpdateWeaponSwayAndBob()
	end
end)

ModsSection:AddToggle("NoSpread", {
	Text = "No Spread",
	Default = getgenv().Config.Combat.NoSpread,
}):OnChanged(function(value)
	getgenv().Config.Combat.NoSpread = value
end)

ModsSection:AddToggle("InstantEquip", {
	Text = "Instant Equip",
	Default = getgenv().Config.Combat.InstantEquip,
}):OnChanged(function(value)
	getgenv().Config.Combat.InstantEquip = value
end)

local function applyRapidFireToGC(enabled)
	local multiplier = getgenv().Config.Combat.RapidFireValue or 3
	local originalRates = {}
	local newRates = {}
	local validWeaponTables = {}

	for _, v in pairs(getgc(true)) do
		if type(v) == "table" then
			local fr = rawget(v, "FireRate")
			if type(fr) == "number" then
				local hasEjection = rawget(v, "EjectionDelay") ~= nil
				local hasFireModes = rawget(v, "FireModes") ~= nil
				local hasAmmo = rawget(v, "Ammo") ~= nil

				if hasEjection or hasFireModes or hasAmmo then
					validWeaponTables[v] = true

					if not rawget(v, "_OriginalFireRate") then
						rawset(v, "_OriginalFireRate", fr)
						local origModes = {}
						local currentModes = rawget(v, "FireModes")
						if type(currentModes) == "table" then
							for _, mode in ipairs(currentModes) do
								table.insert(origModes, mode)
							end
						end
						rawset(v, "_OriginalFireModes", origModes)
						rawset(v, "_OriginalFireMode", rawget(v, "FireMode"))
					end

					local orig = v._OriginalFireRate
					local target = enabled and (orig / multiplier) or orig

					originalRates[orig] = target
					newRates[v.FireRate] = target

					v.FireRate = target

					if enabled then
						if type(v.FireModes) == "table" then
							table.clear(v.FireModes)
							table.insert(v.FireModes, "Auto")
						end
						v.FireMode = "Auto"
						if rawget(v, "CycleTiming") then
							v.CycleTiming = { 0, 0 }
						end
						if hasEjection then
							v.EjectionDelay = 0
						end
					else
						if v._OriginalFireModes and type(v.FireModes) == "table" then
							table.clear(v.FireModes)
							for _, mode in ipairs(v._OriginalFireModes) do
								table.insert(v.FireModes, mode)
							end
						end
						if v._OriginalFireMode then
							v.FireMode = v._OriginalFireMode
						end
					end
				end
			end
		end
	end

	if not getgenv().DeltaOriginalClosureFireModes then
		local weakTable = {}
		setmetatable(weakTable, { __mode = "k" })
		getgenv().DeltaOriginalClosureFireModes = weakTable
	end

	for _, fn in pairs(getgc(true)) do
		if type(fn) == "function" and not iscclosure(fn) then
			local ups = debug.getupvalues(fn)
			if ups then
				local hasMatch = false
				for _, upval in pairs(ups) do
					if type(upval) == "number" and (originalRates[upval] or newRates[upval]) then
						hasMatch = true
						break
					end
					if
						type(upval) == "string"
						and (
							upval == "Semi"
							or upval == "Burst"
							or upval == "Pump"
							or upval == "Bolt"
							or upval == "Auto"
						)
					then
						hasMatch = true
						-- Do not break here; just confirming it has a mode
					end
				end

				if hasMatch then
					for i, upval in pairs(ups) do
						-- Modify FireRate upvalue
						if type(upval) == "number" and (originalRates[upval] or newRates[upval]) then
							local targetRate = originalRates[upval] or newRates[upval]
							if upval ~= targetRate then
								pcall(function()
									debug.setupvalue(fn, i, targetRate)
								end)
							end
						end

						-- Modify FireMode upvalue
						if
							type(upval) == "string"
							and (
								upval == "Semi"
								or upval == "Burst"
								or upval == "Pump"
								or upval == "Bolt"
								or upval == "Auto"
							)
						then
							if enabled then
								if upval ~= "Auto" then
									-- Save original mode for this specific closure
									if not getgenv().DeltaOriginalClosureFireModes[fn] then
										getgenv().DeltaOriginalClosureFireModes[fn] = {}
									end
									getgenv().DeltaOriginalClosureFireModes[fn][i] = upval

									pcall(function()
										debug.setupvalue(fn, i, "Auto")
									end)
								end
							else
								-- Restore original mode if saved
								local saved = getgenv().DeltaOriginalClosureFireModes[fn]
								if saved and saved[i] and upval ~= saved[i] then
									pcall(function()
										debug.setupvalue(fn, i, saved[i])
									end)
								end
							end
						end
					end
				end
			end
		end
	end
end

ModsSection:AddToggle("RapidFire", {
	Text = "Rapid Fire",
	Default = getgenv().Config.Combat.RapidFire,
}):OnChanged(function(value)
	getgenv().Config.Combat.RapidFire = value
	pcall(function()
		applyRapidFireToGC(value)
	end)
end)

ModsSection:AddSlider("RapidFireMultiplier", {
	Text = "Rapid Fire Multiplier",
	Default = getgenv().Config.Combat.RapidFireValue,
	Min = 1,
	Max = 50,
	Rounding = 0,
	Compact = true,
})
getgenv().Options.RapidFireMultiplier:OnChanged(function(value)
	getgenv().Config.Combat.RapidFireValue = value
	if getgenv().Config.Combat.RapidFire then
		pcall(function()
			applyRapidFireToGC(true)
		end)
	end
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

HitsoundSection:AddToggle("Hitsound", {
	Text = "Hitsound",
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
	Min = 0.0,
	Max = 2.0,
	Rounding = 1,
	Compact = true,
})
getgenv().Options.HitsoundVolume:OnChanged(function(value)
	getgenv().Config.Mods.HitsoundVolume = value
end)

HitsoundSection:AddDivider()

HitsoundSection:AddToggle("HitEffects", {
	Text = "Hit Effects",
	Default = getgenv().Config.Mods.HitEffects,
}):OnChanged(function(value)
	getgenv().Config.Mods.HitEffects = value
end)

HitsoundSection:AddLabel("Hit Effects Color"):AddColorPicker("HitEffectsColor", {
	Default = getgenv().Config.Mods.HitEffectsColor,
	Title = "Hit Effects Color",
})
getgenv().Options.HitEffectsColor:OnChanged(function(value)
	getgenv().Config.Mods.HitEffectsColor = value
end)

local WorldModsSection = ModsTab:AddRightGroupbox("World")

WorldModsSection:AddToggle("ThirdPerson", {
	Text = "3rd Person",
	Default = getgenv().Config.Mods.ThirdPerson,
}):AddKeyPicker("ThirdPersonKeybind", {
	Default = getgenv().Config.Mods.ThirdPersonKeybind or "J",
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "3rd Person",
	NoUI = false,
})
getgenv().Toggles.ThirdPerson:OnChanged(function(value)
	getgenv().Config.Mods.ThirdPerson = value
end)

getgenv().Options.ThirdPersonKeybind:OnChanged(function()
	getgenv().Config.Mods.ThirdPersonKeybind = getgenv().Options.ThirdPersonKeybind.Value
end)

WorldModsSection:AddSlider("ZoomDistance", {
	Text = "Zoom Distance",
	Default = getgenv().Config.Mods.ZoomDistance or 15,
	Min = 5,
	Max = 128,
	Rounding = 1,
	Compact = true,
}):OnChanged(function(value)
	getgenv().Config.Mods.ZoomDistance = value
end)

WorldModsSection:AddDivider()

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

local grassConnection = nil

local function hidePart(part)
	if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
		if not part:GetAttribute("OriginalTransparency") then
			part:SetAttribute("OriginalTransparency", part.Transparency)
		end
		part.Transparency = 1
	end
end

local function restorePart(part)
	if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
		local orig = part:GetAttribute("OriginalTransparency")
		if orig then
			part.Transparency = orig
		end
	end
end

-- ==========================================
-- Environment Setup
-- ==========================================
local getgenv = getfenv().getgenv or function()
	return _G
end

if not getgenv().DebugLogs then
	getgenv().DebugLogs = {}
end

getgenv().AddLog = function(msg)
	local timestamp = os.date("%H:%M:%S")
	table.insert(getgenv().DebugLogs, 1, "[" .. timestamp .. "] " .. tostring(msg))
	if #getgenv().DebugLogs > 500 then
		table.remove(getgenv().DebugLogs, 501)
	end
end

local function toggleFoliageAlgorithm(enabled)
	local spawnerZones = workspace:FindFirstChild("SpawnerZones")
	local foliage = spawnerZones and spawnerZones:FindFirstChild("Foliage")

	if not foliage then
		return
	end

	local function processFoliageItem(item, isEnabled)
		if item:IsA("Model") then
			local processedCount = 0

			for _, child in ipairs(item:GetChildren()) do
				if child:IsA("BasePart") then
					local attr = child:GetAttribute("Leaf")
					if child:IsA("MeshPart") and attr ~= nil then
						if isEnabled then
							hidePart(child)
						else
							restorePart(child)
						end
						processedCount = processedCount + 1
					end
				end
			end

			return processedCount > 0
		elseif item:IsA("BasePart") then
			if item:IsA("MeshPart") and item:GetAttribute("Leaf") ~= nil then
				if isEnabled then
					hidePart(item)
				else
					restorePart(item)
				end
				return true
			end
		end
		return false
	end

	if enabled then
		for _, v in ipairs(foliage:GetDescendants()) do
			processFoliageItem(v, true)
		end

		if not grassConnection then
			grassConnection = foliage.DescendantAdded:Connect(function(v)
				processFoliageItem(v, true)
			end)
			table.insert(ConnectionList, grassConnection)
		end
	else
		if grassConnection then
			grassConnection:Disconnect()
			grassConnection = nil
		end

		for _, v in ipairs(foliage:GetDescendants()) do
			processFoliageItem(v, false)
		end
	end
end

local function toggleGrassAlgorithm(enabled)
	if enabled then
		if sethiddenproperty then
			pcall(function()
				sethiddenproperty(workspace.Terrain, "Decoration", false)
			end)
		end
	else
		if sethiddenproperty then
			pcall(function()
				sethiddenproperty(workspace.Terrain, "Decoration", true)
			end)
		end
	end
end
local landminesConnections = {}

local function toggleLandminesAlgorithm(enabled)
	local function processLandmine(item)
		if item:IsA("Model") and (item.Name == "PMN2" or item.Name == "MON50") then
			item:Destroy()
		end
	end

	if enabled then
		local targetFolders = {}

		local aiZones = workspace:FindFirstChild("AiZones")
		if aiZones then
			table.insert(targetFolders, aiZones)
		end

		local noCollision = workspace:FindFirstChild("NoCollision")
		if noCollision then
			local ncAiZones = noCollision:FindFirstChild("AiZones")
			if ncAiZones then
				table.insert(targetFolders, ncAiZones)
			end
		end

		for _, folder in ipairs(targetFolders) do
			for _, v in ipairs(folder:GetDescendants()) do
				processLandmine(v)
			end

			local conn = folder.DescendantAdded:Connect(function(v)
				processLandmine(v)
			end)
			table.insert(landminesConnections, conn)
			table.insert(ConnectionList, conn)
		end
	else
		for _, conn in ipairs(landminesConnections) do
			conn:Disconnect()
		end
		table.clear(landminesConnections)
	end
end

WorldModsSection:AddToggle("NoFoliage", {
	Text = "No Foliage",
	Default = getgenv().Config.Mods.NoFoliage,
}):OnChanged(function(value)
	getgenv().Config.Mods.NoFoliage = value
	toggleFoliageAlgorithm(value)
end)

WorldModsSection:AddToggle("RemoveGrass", {
	Text = "Remove Grass",
	Default = getgenv().Config.Mods.RemoveGrass,
}):OnChanged(function(value)
	getgenv().Config.Mods.RemoveGrass = value
	toggleGrassAlgorithm(value)
end)

WorldModsSection:AddToggle("NoLandmines", {
	Text = "No Landmines",
	Default = getgenv().Config.Mods.NoLandmines,
}):OnChanged(function(value)
	getgenv().Config.Mods.NoLandmines = value
	toggleLandminesAlgorithm(value)
end)

WorldModsSection:AddToggle("Gloom", {
	Text = "Gloom",
	Default = getgenv().Config.Mods.Gloom,
}):OnChanged(function(value)
	getgenv().Config.Mods.Gloom = value
end)

WorldModsSection:AddToggle("NoShadows", {
	Text = "No Shadows",
	Default = getgenv().Config.Mods.NoShadows,
}):OnChanged(function(value)
	getgenv().Config.Mods.NoShadows = value
end)

WorldModsSection:AddSlider("FOV", {
	Text = "FOV",
	Default = getgenv().Config.Mods.FOV or 70,
	Min = 70,
	Max = 120,
	Rounding = 0,
	Compact = true,
})
getgenv().Options.FOV:OnChanged(function(value)
	getgenv().Config.Mods.FOV = value
end)

WorldModsSection:AddSlider("WorldTime", {
	Text = "World Time",
	Default = getgenv().Config.Mods.WorldTime or 12,
	Min = 0,
	Max = 24,
	Rounding = 1,
	Compact = true,
})
getgenv().Options.WorldTime:OnChanged(function(value)
	getgenv().Config.Mods.WorldTime = value
end)

WorldModsSection:AddDropdown("WeatherType", {
	Values = { "None", "Rain", "Snow", "Sakura" },
	Default = 1,
	Multi = false,
	Text = "Weather Effect",
})
getgenv().Options.WeatherType:OnChanged(function(value)
	getgenv().Config.Mods.WeatherType = value
	if getgenv().ApplyWeatherEffect then
		getgenv().ApplyWeatherEffect(value)
	end
end)

local CharacterModsSection = ModsTab:AddRightGroupbox("Character")

CharacterModsSection:AddToggle("NoFallDamage", {
	Text = "No Fall Damage",
	Default = getgenv().Config.Mods.NoFallDamage,
}):OnChanged(function(value)
	getgenv().Config.Mods.NoFallDamage = value
end)

CharacterModsSection:AddToggle("NoVisor", {
	Text = "No Visor",
	Default = getgenv().Config.Mods.NoVisor,
}):OnChanged(function(value)
	getgenv().Config.Mods.NoVisor = value
end)

CharacterModsSection:AddToggle("Speedhack", {
	Text = "Speedhack",
	Default = getgenv().Config.Mods.Speedhack,
}):OnChanged(function(value)
	getgenv().Config.Mods.Speedhack = value
end)

CharacterModsSection:AddSlider("WalkspeedValue", {
	Text = "Walkspeed Value",
	Default = getgenv().Config.Mods.WalkspeedValue or 16,
	Min = 16,
	Max = 20,
	Rounding = 0,
	Compact = true,
})
getgenv().Options.WalkspeedValue:OnChanged(function(value)
	getgenv().Config.Mods.WalkspeedValue = value
end)

-- (Environment Setup Moved)

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
			getgenv().LinoriaLibrary:Notify("A mod has joined: " .. player.Name, 5)

			local SoundService = cloneref and cloneref(game:GetService("SoundService"))
				or game:GetService("SoundService")
			local Debris = cloneref and cloneref(game:GetService("Debris")) or game:GetService("Debris")

			local alertSound = Instance.new("Sound")
			alertSound.SoundId = "rbxassetid://124568679525758"
			alertSound.Volume = getgenv().Config.Utilities.ModDetectorVolume or 1.0
			alertSound.Parent = SoundService
			alertSound:Play()

			Debris:AddItem(alertSound, 10)
		end
	end)
end

local ModDetectorConnection = nil

ModDetectorSection:AddToggle("ModDetector", {
	Text = "Mod Detector",
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

ModDetectorSection:AddSlider("ModDetectorVolume", {
	Text = "Mod Detector Volume",
	Default = getgenv().Config.Utilities.ModDetectorVolume,
	Min = 0.5,
	Max = 5.0,
	Rounding = 1,
	Compact = true,
}):OnChanged(function(value)
	getgenv().Config.Utilities.ModDetectorVolume = value
end)

local NoClipSection = UtilitiesTab:AddRightGroupbox("No Clip")

NoClipSection:AddToggle("ClipCharacter", {
	Text = "Clip Character",
	Default = getgenv().Config.Utilities.ClipCharacter,
}):AddKeyPicker("ClipCharacterKeybind", {
	Default = getgenv().Config.Utilities.ClipCharacterKeybind or "F2",
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "Clip Character",
	NoUI = false,
})

getgenv().Toggles.ClipCharacter:OnChanged(function(value)
	getgenv().Config.Utilities.ClipCharacter = value
end)

getgenv().Options.ClipCharacterKeybind:OnChanged(function()
	getgenv().Config.Utilities.ClipCharacterKeybind = getgenv().Options.ClipCharacterKeybind.Value
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

-- [RenderStepped] Fires right before the local frame renders (priority -1000 = before all camera scripts).
-- Restores HRP.CFrame to _StoredRealCFrame so the local player's view, FOV, and camera
-- are NEVER affected by Anti-Aim jitter or Underground Desync offsets. Enemies see the
-- jittered position; you see nothing. Identical approach to Underground Desync.
RunService:BindToRenderStep("UndergroundDesync_Restore", -1000, function()
	local isDesync = getgenv().Config.Combat.UndergroundDesync
	local isAntiAim = getgenv().Config.Combat.AntiAim
	local isClipCharacter = getgenv().Config.Utilities.ClipCharacter

	if getgenv()._TPKillActive then
		isDesync = false
		isAntiAim = false
		isClipCharacter = false
	end

	if isDesync or isAntiAim then
		local Character = getTargetCharacter()
		if Character and getgenv()._StoredRealCFrame then
			local HRP = Character.HumanoidRootPart
			if not isClipCharacter then
				HRP.CFrame = getgenv()._StoredRealCFrame
			end

			-- RenderStepped restores natural movement seamlessly.
		end
	else
		-- Anti-aim / Desync turned off: clean up
		if getgenv()._StoredRealCFrame and not isClipCharacter then
			local Character = getTargetCharacter()
			if Character and Character:FindFirstChild("HumanoidRootPart") then
				Character.HumanoidRootPart.CFrame = getgenv()._StoredRealCFrame
			end
			getgenv()._StoredRealCFrame = nil
		end
	end
end)

-- [Stepped] Fires before physics simulation/network replication.
-- Anti-Aim: Physically teleports HRP to random jitter positions that replicate to enemies.
-- Underground Desync: Applies underground CFrame offset for server-side crouch desync.
-- All offsets are wall/ground-checked to avoid noclip/fly detection.
local steppedRestoreConnection = RunService.Stepped:Connect(function()
	local isDesync = getgenv().Config.Combat.UndergroundDesync
	local isAntiAim = getgenv().Config.Combat.AntiAim
	local isClipCharacter = getgenv().Config.Utilities.ClipCharacter

	if getgenv()._TPKillActive then
		isDesync = false
		isAntiAim = false
		isClipCharacter = false
	end

	local Character = getTargetCharacter()
	local HRP = Character and Character:FindFirstChild("HumanoidRootPart")

	if (isDesync or isAntiAim or isClipCharacter) and getgenv()._StoredRealCFrame and HRP then
		local prevPos = HRP.CFrame.Position
		-- If the server rubberbands the player drastically (e.g., > 15 studs),
		-- accept the server's position to prevent an infinite fight and a Noclip kick.
		local guardBlocked = getgenv()._UndergroundResolverActive or getgenv()._SkyPeekActive
		if
			not guardBlocked
			and (tick() - (getgenv()._LastGuardDeactivate or 0) > 1.5)
			and (prevPos - getgenv()._StoredRealCFrame.Position).Magnitude > 15
		then
			getgenv()._StoredRealCFrame = HRP.CFrame
		end

		local cframeToSet = getgenv()._StoredRealCFrame
		if isAntiAim then
			local rx = getgenv()._realVelocity and getgenv()._realVelocity.X or 0
			local rz = getgenv()._realVelocity and getgenv()._realVelocity.Z or 0
			if math.abs(rx) < 0.1 and math.abs(rz) < 0.1 then
				getgenv()._sleepDesyncToggle = not getgenv()._sleepDesyncToggle
				cframeToSet = cframeToSet
					* CFrame.new(
						getgenv()._sleepDesyncToggle and 0.05 or -0.05,
						0,
						getgenv()._sleepDesyncToggle and 0.05 or -0.05
					)
			end
		end

		if isClipCharacter then
			local clipOffset = CFrame.new(0, 0, -3.8) * CFrame.Angles(math.rad(135), 0, 0)
			cframeToSet = cframeToSet * clipOffset
		end

		HRP.CFrame = cframeToSet
		if getgenv()._realVelocity then
			HRP.AssemblyLinearVelocity = getgenv()._realVelocity
		end
	end
end)
table.insert(ConnectionList, steppedRestoreConnection)

-- Safety net: track consecutive falling frames to detect void-fall loop
local _voidFallCounter = getgenv()._VoidFallCounter or 0
local desyncTick = 0

local heartbeatConnection = RunService.Heartbeat:Connect(function()
	local Character = getTargetCharacter()
	if not Character then
		return
	end

	local HRP = Character.HumanoidRootPart
	local isDesync = getgenv().Config.Combat.UndergroundDesync
	local isAntiAim = getgenv().Config.Combat.AntiAim
	local isUGR = getgenv()._UndergroundResolverActive
	local isClipCharacter = getgenv().Config.Utilities.ClipCharacter

	if getgenv()._TPKillActive then
		isDesync = false
		isAntiAim = false
		isUGR = false
		isClipCharacter = false
	end

	if isDesync or isUGR or isAntiAim or isClipCharacter then
		local guardBlocked = getgenv()._UndergroundResolverActive or getgenv()._SkyPeekActive
		if not guardBlocked then
			-- Capture real position — log when something looks wrong (Y too low = inside terrain)
			local captured = HRP.CFrame

			if isClipCharacter then
				local clipOffset = CFrame.new(0, 0, -3.8) * CFrame.Angles(math.rad(135), 0, 0)
				captured = captured * clipOffset:Inverse()
			end

			local dy = 0
			if getgenv()._StoredRealCFrame then
				local prev = getgenv()._StoredRealCFrame.Position
				local cur = captured.Position
				dy = cur.Y - prev.Y

				-- Flag sudden downward jumps > 1 stud between frames (sign of geometry push-through)
			end

			-- ── VOID-FALL SAFETY NET ──────────────────────────────────────────────────
			-- If the stored position has been falling continuously (dy < -0.5 every frame)
			-- for 20+ consecutive Heartbeat ticks (~0.33s at 60Hz), we are in a void-fall
			-- feedback loop caused by the desync offset pushing HRP through terrain.
			-- Recovery: raycast upward from current XZ to find the nearest surface,
			-- snap _StoredRealCFrame back to it, re-suppress the desync offset, and zero
			-- out velocity so the loop can't re-establish itself.
			if dy < -0.5 then
				_voidFallCounter = _voidFallCounter + 1
			else
				_voidFallCounter = 0
			end
			getgenv()._VoidFallCounter = _voidFallCounter

			if _voidFallCounter >= 20 then
				_voidFallCounter = 0
				getgenv()._VoidFallCounter = 0

				local pos = HRP.CFrame.Position
				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = { Character }
				rayParams.FilterType = Enum.RaycastFilterType.Exclude
				rayParams.IgnoreWater = true

				-- Cast upward from current (underground) position to find the floor above
				local upHit = workspace:Raycast(pos, Vector3.new(0, 500, 0), rayParams)
				local recoveredCFrame

				if upHit then
					local humanoid = Character:FindFirstChildOfClass("Humanoid")
					local hipHeight = 2
					if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
						hipHeight = humanoid.HipHeight
					end
					local rootHeight = hipHeight + (HRP.Size.Y / 2)
					local safeY = upHit.Position.Y + rootHeight
					local look = HRP.CFrame.LookVector
					local flatLook = Vector3.new(look.X, 0, look.Z)
					if flatLook.Magnitude < 0.1 then
						flatLook = Vector3.new(0, 0, -1)
					end
					flatLook = flatLook.Unit
					recoveredCFrame = CFrame.lookAt(
						Vector3.new(pos.X, safeY, pos.Z),
						Vector3.new(pos.X + flatLook.X, safeY, pos.Z + flatLook.Z)
					)
				else
					-- No surface found above — cast downward as fallback
					local downHit = workspace:Raycast(pos, Vector3.new(0, -500, 0), rayParams)
					if downHit then
						local humanoid = Character:FindFirstChildOfClass("Humanoid")
						local hipHeight = 2
						if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
							hipHeight = humanoid.HipHeight
						end
						local rootHeight = hipHeight + (HRP.Size.Y / 2)
						local safeY = downHit.Position.Y + rootHeight
						local look = HRP.CFrame.LookVector
						local flatLook = Vector3.new(look.X, 0, look.Z)
						if flatLook.Magnitude < 0.1 then
							flatLook = Vector3.new(0, 0, -1)
						end
						flatLook = flatLook.Unit
						recoveredCFrame = CFrame.lookAt(
							Vector3.new(pos.X, safeY, pos.Z),
							Vector3.new(pos.X + flatLook.X, safeY, pos.Z + flatLook.Z)
						)
					else
					end
				end

				if recoveredCFrame then
					HRP.CFrame = recoveredCFrame
					HRP.AssemblyLinearVelocity = Vector3.zero
					HRP.AssemblyAngularVelocity = Vector3.zero
					getgenv()._StoredRealCFrame = recoveredCFrame
					-- Re-suppress desync offset so it doesn't immediately push HRP underground again
					getgenv()._DesyncOffsetSuppressed = true
					task.delay(0.5, function()
						getgenv()._DesyncOffsetSuppressed = false
					end)
				end

				return
			end
			-- ── END VOID-FALL SAFETY NET ──────────────────────────────────────────────

			getgenv()._StoredRealCFrame = captured
		else
			-- Guard is active
			desyncTick = desyncTick + 1
			if desyncTick >= 60 then
				desyncTick = 0
			end
		end
		getgenv()._realVelocity = HRP.AssemblyLinearVelocity
		getgenv()._realRotVelocity = HRP.AssemblyAngularVelocity

		local targetCFrame = getgenv()._StoredRealCFrame
		if isDesync then
			-- If returning from UGR or SkyPeek, DO NOT apply the deep underground offset.
			-- Let the character cleanly return to the surface first so the server doesn't flag noclip.
			-- _DesyncOffsetSuppressed is set by the UGR snap-back handler for a brief landing window:
			-- without it, the offset pushes the HRP underground immediately after snap, which causes
			-- physics to freefall and feed back into _StoredRealCFrame — void-fall loop.
			if not guardBlocked and not getgenv()._DesyncOffsetSuppressed then
				targetCFrame = targetCFrame * undergroundDesyncOffset
			end
		end

		if isClipCharacter then
			local clipOffset = CFrame.new(0, 0, -3.8) * CFrame.Angles(math.rad(135), 0, 0)
			targetCFrame = targetCFrame * clipOffset
		end

		if isDesync or isClipCharacter then
			HRP.CFrame = targetCFrame
		end

		if not guardBlocked then
			desyncTick = desyncTick + 1
			if desyncTick >= 60 then
				desyncTick = 0
			end
		end
	end

	if isAntiAim and not isDesync then
		local hum = Character:FindFirstChild("Humanoid")
		if hum then
			hum.AutoRotate = false
		end

		-- Apply jitter HERE in Heartbeat (after physics), NOT in Stepped (before physics).
		-- This is the same timing as Underground Desync: physics commits the real position,
		-- then we move the HRP post-physics. RenderStepped at -1000 restores it before any
		-- camera or render script runs — local view and FOV are completely unaffected.
		if
			not getgenv()._TPKillActive
			and getgenv()._StoredRealCFrame
			and not (getgenv()._UndergroundResolverActive or getgenv()._SkyPeekActive)
		then
			-- Ultimate Ground-Hugging Anti-Aim (Physics Safe)
			-- Bypasses Fly/Speedhack checks by ensuring every jitter point is precisely snapped
			-- to the exact floor level, preventing the physics engine from applying Y-axis gravity
			-- drops or wall-ejection forces that trigger the Anti-Cheat.

			local radius = getgenv().Config.Combat.AntiAimRadius or 5
			local angle = math.random() * math.pi * 2
			local dist = math.random() * radius

			local flatOffset = Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
			local origin = getgenv()._StoredRealCFrame.Position
			local jitterPos = origin

			-- Safety: raycast to ensure we don't clip into walls
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { Character }
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.IgnoreWater = true
			raycastParams.RespectCanCollide = true

			local wallHit = workspace:Raycast(origin, flatOffset, raycastParams)
			if not wallHit then
				-- Jitter path is clear of walls. Now find the exact floor height.
				local checkPos = origin + flatOffset
				-- Cast from 3 studs above down to 10 studs below
				local groundHit =
					workspace:Raycast(checkPos + Vector3.new(0, 3, 0), Vector3.new(0, -10, 0), raycastParams)

				if groundHit then
					local humanoid = Character:FindFirstChildOfClass("Humanoid")
					local hipHeight = 2
					if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
						hipHeight = humanoid.HipHeight
					end
					local rootHeight = hipHeight + (HRP.Size.Y / 2)

					-- Snap perfectly to the floor geometry
					jitterPos = Vector3.new(checkPos.X, groundHit.Position.Y + rootHeight, checkPos.Z)
				end
			end

			-- Absolute Safety Net: If the calculated jitter position differs in height by more than
			-- 2.5 studs (e.g., trying to jitter up a steep cliff or down a hole), abort the jitter
			-- to prevent Flyhack detection from extreme vertical changes.
			if math.abs(jitterPos.Y - origin.Y) > 2.5 then
				jitterPos = origin
			end

			local randomRot = CFrame.Angles(0, math.random() * math.pi * 2, 0)

			HRP.CFrame = CFrame.new(jitterPos) * randomRot

			-- Scramble angular velocity heavily for resolver breaking, but keep linear velocity real
			-- so the server's momentum calculations stay stable.
			HRP.AssemblyAngularVelocity =
				Vector3.new(math.random(-250, 250), math.random(-250, 250), math.random(-250, 250))
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

local hitboxLiftingConnection = RunService.RenderStepped:Connect(function()
	local localPlayer = game:GetService("Players").LocalPlayer
	local lift_h = getgenv().Config.Combat.LiftHitboxesHeight or 2
	local shouldLift = getgenv().Config.Combat.LiftHitboxes

	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		if player ~= localPlayer then
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root then
				local current_cf = root.CFrame
				local last_lifted = root:GetAttribute("LastLiftedCFrame")
				local base_cf = current_cf

				if last_lifted and typeof(last_lifted) == "CFrame" then
					local last_h = root:GetAttribute("LastLiftedHeight") or 2
					if math.abs(current_cf.Position.Y - last_lifted.Position.Y) < 0.05 then
						base_cf = current_cf - Vector3.new(0, last_h, 0)
					end
				end

				if shouldLift then
					local new_cf = base_cf + Vector3.new(0, lift_h, 0)
					root.CFrame = new_cf
					root:SetAttribute("LastLiftedCFrame", new_cf)
					root:SetAttribute("LastLiftedHeight", lift_h)
				else
					root.CFrame = base_cf
					root:SetAttribute("LastLiftedCFrame", nil)
					root:SetAttribute("LastLiftedHeight", nil)
				end
			end
		end
	end
end)
table.insert(ConnectionList, hitboxLiftingConnection)

if not getgenv().DesyncHooked then
	getgenv().DesyncHooked = true
	local oldIndex
	oldIndex = hookmetamethod(
		game,
		"__index",
		newcclosure(function(self, key)
			if not checkcaller() then
				if key == "Length" and typeof(self) == "Instance" and self:IsA("AnimationTrack") then
					local w = getgenv()._DeltaActiveWeaponTable
					if w and type(w) == "table" and type(rawget(w, "clientAnimationTracks")) == "table" then
						if getgenv().Config and getgenv().Config.Combat then
							if getgenv().Config.Combat.InstantEquip then
								local c = w.clientAnimationTracks
								local s = rawget(w, "serverAnimationTracks")
								if self == c.Equip or (s and type(s) == "table" and self == s.Equip) then
									return 0.01
								end
							end
						end
					end
				end

				if
					getgenv().Config.Mods.ThirdPerson
					and key == "CFrame"
					and (self == Workspace.CurrentCamera or self == Workspace.Camera)
				then
					local callerScript = getcallingscript and getcallingscript()
					local callerName = callerScript and callerScript.Name or ""

					-- Only spoof for the specific scripts that handle FPS viewmodel and bullets
					if
						callerName == "CharacterController"
						or callerName == "FirstPersonBody"
						or callerName == "Effects"
					then
						local char = Workspace:FindFirstChild(LocalPlayer.Name)
						if char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart") then
							local cleanHeadPos = char.Head.Position
							if getgenv()._StoredRealCFrame then
								local hrp = char.HumanoidRootPart
								local realHrpCFrame = oldIndex(hrp, "CFrame")
								local realHeadCFrame = oldIndex(char.Head, "CFrame")
								local relative = realHrpCFrame:ToObjectSpace(realHeadCFrame)

								local baseCFrame = getgenv()._StoredRealCFrame
								-- DO NOT apply the underground desync offset for the camera/viewmodel spoof.
								-- We want the player's camera to stay on the surface where they physically appear to be playing from.
								if getgenv().Config.Combat.AntiAim and getgenv().FakeCFrame then
									baseCFrame = getgenv().FakeCFrame
								end

								-- Mathematically calculate exactly where the Head SHOULD be if we weren't jittering
								cleanHeadPos = (baseCFrame * relative).Position
							end

							local realCFrame = oldIndex(self, key)
							return CFrame.new(cleanHeadPos, cleanHeadPos + realCFrame.LookVector)
						end
					end
				end
				local isDesync = getgenv().Config.Combat.UndergroundDesync
				local isAntiAim = getgenv().Config.Combat.AntiAim
				local isUGR = getgenv()._UndergroundResolverActive

				if (isDesync or isUGR or isAntiAim) and getgenv()._StoredRealCFrame then
					if key == "CFrame" or key == "Position" then
						local char = getTargetCharacter()
						if
							char
							and typeof(self) == "Instance"
							and self:IsA("BasePart")
							and self:IsDescendantOf(char)
						then
							local hrp = char:FindFirstChild("HumanoidRootPart")
							if hrp then
								local baseCFrame = getgenv()._StoredRealCFrame

								if self == hrp then
									return key == "CFrame" and baseCFrame or baseCFrame.Position
								else
									-- Calculate relative offset for all other hitboxes (Head, Torso, HeadTopHitbox)
									-- Because the real HRP is jittering massively, we need to base it off the unjittered position
									local realSelf = oldIndex(self, "CFrame")
									local realHRP = oldIndex(hrp, "CFrame")
									-- Since we manually teleport the hrp, the parts follow it physically, so we must calculate
									-- the offset based on where the parts actually are relative to the jittered HRP
									local relative = realHRP:ToObjectSpace(realSelf)
									local fakeSelf = baseCFrame * relative

									return key == "CFrame" and fakeSelf or fakeSelf.Position
								end
							end
						end
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
				if method == "GetPivot" then
					local isDesync = getgenv().Config.Combat.UndergroundDesync
					local isAntiAim = getgenv().Config.Combat.AntiAim
					local isUGR = getgenv()._UndergroundResolverActive

					if (isDesync or isUGR or isAntiAim) and getgenv()._StoredRealCFrame then
						local char = getTargetCharacter()
						if char and typeof(self) == "Instance" then
							local hrp = char:FindFirstChild("HumanoidRootPart")
							if hrp then
								local baseCFrame = getgenv()._StoredRealCFrame

								if self == char then
									return baseCFrame
								elseif self:IsA("BasePart") and self:IsDescendantOf(char) then
									if self == hrp then
										return baseCFrame
									else
										local realSelf = self.CFrame
										local realHRP = hrp.CFrame
										local relative = realHRP:ToObjectSpace(realSelf)
										return baseCFrame * relative
									end
								end
							end
						end
					end
				elseif method == "FireServer" or method == "InvokeServer" then
					local remoteName = tostring(self.Name)

					-- ===================================================
					-- LAYER 2: UpdateTilt Pitch Oscillation (Torso Spin)
					-- Intercepts UpdateTilt:FireServer() and replaces the pitch
					-- ===================================================
					if remoteName == "UpdateTilt" then
						if getgenv()._TPKillActive and getgenv()._TPKillPos and getgenv()._TPKillTarget then
							local args = table.pack(...)
							local targetAimPart = getgenv()._TPKillTarget.Parent
									and getgenv()._TPKillTarget.Parent:FindFirstChild("Head")
								or getgenv()._TPKillTarget
							local aimPos = targetAimPart.Position
							local basePos = getgenv()._TPKillPos
							local serverOrigin = basePos + Vector3.new(0, 1.6, 0)
							local perfectDir = (aimPos - serverOrigin).Unit
							local clampedY = math.clamp(perfectDir.Y, -1, 1)
							local pitch = math.asin(clampedY)
							pitch = math.clamp(pitch, -1.55, 1.55) -- prevent exact -90/90 gimbal lock
							args[1] = pitch
							args[2] = 0
							args.n = math.max(args.n, 2)
							setnamecallmethod(method)
							return oldNamecall(self, table.unpack(args, 1, args.n))
						elseif getgenv().Config.Combat.AntiAim then
							local args = table.pack(...)
							args[1] = math.sin(os.clock() * 40) * 0.8
							args.n = math.max(args.n, 1)
							setnamecallmethod(method)
							return oldNamecall(self, table.unpack(args, 1, args.n))
						end
					end

					if getgenv()._IH_Interceptor then
						local shouldDrop, postAction, modArgs = getgenv()._IH_Interceptor(method, remoteName, { ... })
						if shouldDrop then
							return
						end
						if postAction then
							setnamecallmethod(method)
							local result = table.pack(oldNamecall(self, unpack(modArgs or { ... })))
							postAction()
							return table.unpack(result, 1, result.n)
						end
					end
				end
			end
			setnamecallmethod(method)
			return oldNamecall(self, ...)
		end)
	)
end

-- ==========================================
-- Settings Tab
-- ==========================================
local UISection = SettingsTab:AddLeftGroupbox("UI")

UISection:AddButton("Unload", function() end)

UISection:AddToggle("LockKeybindHUD", {
	Text = "Lock Keybinds HUD",
	Default = getgenv().Config.Utilities.LockKeybindHUD,
})
getgenv().Toggles.LockKeybindHUD:OnChanged(function(val)
	getgenv().Config.Utilities.LockKeybindHUD = val
end)

UISection:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
	Default = "RightControl",
	NoUI = true,
	Text = "Menu Keybind",
})
Library.ToggleKeybind = getgenv().Options.MenuKeybind

if not getgenv()._LinoriaToggleListener then
	getgenv()._LinoriaIsToggled = true
	getgenv()._LinoriaToggleListener = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
		if getgenv().Options and getgenv().Options.MenuKeybind then
			local bind = getgenv().Options.MenuKeybind.Value
			if type(bind) == "string" and input.KeyCode.Name == bind then
				getgenv()._LinoriaIsToggled = not getgenv()._LinoriaIsToggled
			elseif typeof(bind) == "EnumItem" and input.KeyCode == bind then
				getgenv()._LinoriaIsToggled = not getgenv()._LinoriaIsToggled
			end
		end
	end)
end

-- Custom Config Manager
local ConfigFolder = "Retro/config"
if not isfolder("Retro") then
	makefolder("Retro")
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
		if k == "HitlistPlayers" then
			continue
		end
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
	getgenv()._DeltaScriptSilentToggles = true
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

	local function safeSetKeyPicker(name, key, mode)
		if Options and Options[name] and key ~= nil then
			local succ = pcall(function()
				Options[name]:SetValue(key, mode)
			end)
			if not succ then
				pcall(function()
					Options[name]:SetValue({ key, mode })
				end)
			end
		end
	end

	local function safeSetColorPicker(name, val)
		if Options and Options[name] and val ~= nil then
			local succ = pcall(function()
				if Options[name].SetValueRGB then
					Options[name]:SetValueRGB(val)
				else
					Options[name]:SetValue(val)
				end
			end)
			if not succ then
				succ = pcall(function()
					Options[name]:SetValue(val:ToHex())
				end)
			end
			if not succ then
				succ = pcall(function()
					Options[name]:SetValue(val.R, val.G, val.B)
				end)
			end
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
		safeSetToggle("ESP", data.ESP.Enabled)
		safeSetOption("ESPMaxDistance", data.ESP.MaxDistance)
		safeSetToggle("HealthBar", data.ESP.ShowHealthBar)
		safeSetColorPicker("TextColor", parseColor(data.ESP.TextColor))
		safeSetColorPicker("OutlineColor", parseColor(data.ESP.OutlineColor))
		safeSetOption("TextSize", data.ESP.TextSize)

		if data.ESP.Font ~= nil then
			local fontMapReverse = { [0] = "UI", [1] = "System", [2] = "Plex", [3] = "Monospace" }
			safeSetOption("ESPFont", fontMapReverse[data.ESP.Font] or "Plex")
		end

		safeSetToggle("Chams", data.ESP.ChamsEnabled)
		safeSetColorPicker("ChamsFillColor", parseColor(data.ESP.ChamsFillColor))
		safeSetColorPicker("NPCChamsFillColor", parseColor(data.ESP.NPCChamsFillColor))

		if data.ESP.BoundingBox2DEnabled ~= nil then
			safeSetToggle("2DBoundingBox", data.ESP.BoundingBox2DEnabled)
		end
		if data.ESP.BoundingBox2DStyle ~= nil then
			safeSetOption("BoundingBox2DStyle", data.ESP.BoundingBox2DStyle)
		end
		if data.ESP.BoundingBox2DColor ~= nil then
			safeSetColorPicker("2DBoxColor", parseColor(data.ESP.BoundingBox2DColor))
		end

		safeSetToggle("VisibleCheck", data.ESP.VisibleCheck)
		safeSetColorPicker("VisibleColor", parseColor(data.ESP.VisibleColor))

		safeSetToggle("HideArms", data.ESP.HideArms)
		safeSetToggle("ArmChams", data.ESP.ViewmodelArmChams)
		safeSetColorPicker("ArmColor", parseColor(data.ESP.ViewmodelArmColor))
		safeSetOption("ArmMaterial", data.ESP.ViewmodelArmMaterial)

		safeSetToggle("GunChams", data.ESP.ViewmodelGunChams)
		safeSetColorPicker("GunColor", parseColor(data.ESP.ViewmodelGunColor))
		safeSetOption("GunMaterial", data.ESP.ViewmodelGunMaterial)

		safeSetOption("ViewmodelChamsTransparency", data.ESP.ViewmodelChamsTransparency)
		safeSetOption("ViewmodelOffsetX", data.ESP.ViewmodelOffsetX)
		safeSetOption("ViewmodelOffsetY", data.ESP.ViewmodelOffsetY)
		safeSetOption("ViewmodelOffsetZ", data.ESP.ViewmodelOffsetZ)

		safeSetToggle("NPCESP", data.ESP.NPCESPEnabled)
		safeSetColorPicker("NPCTextColor", parseColor(data.ESP.NPCTextColor))
		safeSetColorPicker("NPCOutlineColor", parseColor(data.ESP.NPCOutlineColor))

		safeSetToggle("HelicopterESP", data.ESP.HelicopterESPEnabled)
		safeSetColorPicker("HelicopterTextColor", parseColor(data.ESP.HelicopterTextColor))
		safeSetColorPicker("HelicopterOutlineColor", parseColor(data.ESP.HelicopterOutlineColor))

		safeSetToggle("CorpseESP", data.ESP.CorpseESPEnabled)
		safeSetColorPicker("CorpseTextColor", parseColor(data.ESP.CorpseTextColor))
		safeSetColorPicker("CorpseOutlineColor", parseColor(data.ESP.CorpseOutlineColor))

		safeSetToggle("ExitESP", data.ESP.ExitESPEnabled)
		safeSetColorPicker("ExitTextColor", parseColor(data.ESP.ExitTextColor))
		safeSetColorPicker("ExitOutlineColor", parseColor(data.ESP.ExitOutlineColor))

		safeSetToggle("InventoryViewer", data.ESP.InventoryViewer)
		safeSetToggle("InventoryViewerOnlyNecessary", data.ESP.InventoryViewerOnlyNecessary)
		safeSetOption("InventoryViewerTextSize", data.ESP.InventoryViewerTextSize)
		safeSetToggle("LockInventoryViewer", data.ESP.LockInventoryViewer)
		if data.ESP.InventoryViewerX and data.ESP.InventoryViewerY then
			getgenv().Config.ESP.InventoryViewerX = data.ESP.InventoryViewerX
			getgenv().Config.ESP.InventoryViewerY = data.ESP.InventoryViewerY
		end

		safeSetToggle("TargetInfoHUD", data.ESP.TargetInfoHUD)
		safeSetToggle("LockTargetInfoHUD", data.ESP.LockTargetInfoHUD)
		if data.ESP.TargetInfoHUDX and data.ESP.TargetInfoHUDY then
			getgenv().Config.ESP.TargetInfoHUDX = data.ESP.TargetInfoHUDX
			getgenv().Config.ESP.TargetInfoHUDY = data.ESP.TargetInfoHUDY
		end
	end

	if data.SilentAim then
		safeSetToggle("BulletTracers", data.SilentAim.BulletTracers)
		safeSetToggle("TracerGlowEffect", data.SilentAim.TracerGlowEffect)
		safeSetOption("TracerType", data.SilentAim.TracerType)
		safeSetColorPicker("TracerColor", parseColor(data.SilentAim.TracerColor))
		safeSetOption("TracerTransparency", data.SilentAim.TracerTransparency)

		safeSetToggle("SilentAim", data.SilentAim.Enabled)
		safeSetOption("SilentAimTargetType", data.SilentAim.TargetType)
		safeSetOption("SilentAimTargetPart", data.SilentAim.TargetPart)
		if data.SilentAim.WhitelistPlayers then
			getgenv().Config.SilentAim.WhitelistPlayers = data.SilentAim.WhitelistPlayers
		end
		safeSetKeyPicker("UndergroundResolverKeybind", data.SilentAim.UndergroundResolverKeybind, "Toggle")
		if data.SilentAim.UndergroundDuration then
			safeSetOption("UndergroundDuration", data.SilentAim.UndergroundDuration)
		end
		if data.SilentAim.UndergroundDistance then
			safeSetOption("UndergroundDistance", data.SilentAim.UndergroundDistance)
		end
		safeSetToggle("FOVCircle", data.SilentAim.ShowFOV)
		safeSetOption("FOVType", data.SilentAim.FOVType)
		safeSetColorPicker("FOVColor", parseColor(data.SilentAim.FOVColor))
		safeSetOption("FOVRadius", data.SilentAim.FOVRadius)
		safeSetToggle("Snapline", data.SilentAim.ShowSnapline)
		safeSetToggle("VisibleCheckSnapline", data.SilentAim.VisibleCheck)
		safeSetColorPicker("SnaplineColor", parseColor(data.SilentAim.SnaplineColor))
		safeSetColorPicker("VisibleSnaplineColor", parseColor(data.SilentAim.VisibleColor))
	end

	if data.Combat then
		safeSetToggle("Crosshair", data.Combat.ShowCrosshair)
		if data.Combat.CrosshairType then
			safeSetOption("CrosshairType", data.Combat.CrosshairType)
		end
		if data.Combat.CrosshairColor then
			safeSetColorPicker("CrosshairColor", parseColor(data.Combat.CrosshairColor))
		end
		if data.Combat.CrosshairSize then
			safeSetOption("CrosshairSize", data.Combat.CrosshairSize)
		end
		if data.Combat.CrosshairDistance then
			safeSetOption("CrosshairDistance", data.Combat.CrosshairDistance)
		end
		if data.Combat.CrosshairRotationSpeed then
			safeSetOption("CrosshairRotationSpeed", data.Combat.CrosshairRotationSpeed)
		end
		safeSetToggle("TriggerBot", data.Combat.TriggerBot)
		safeSetToggle("InstantHit", data.Combat.InstantHit)

		safeSetToggle("TPKill", data.Combat.TPKill)
		safeSetKeyPicker("TPKillKeybind", data.Combat.TPKillKeybind, "Toggle")
		if data.Combat.TPKillType then
			safeSetOption("TPKillType", data.Combat.TPKillType)
		end
		if data.Combat.TPKillHeight then
			safeSetOption("TPKillHeight", data.Combat.TPKillHeight)
		end

		safeSetToggle("OriginManipulation", data.Combat.OriginManipulation)
		if data.Combat.OriginManipulationDistance then
			safeSetOption("OriginManipulationDistance", data.Combat.OriginManipulationDistance)
		end

		safeSetToggle("LiftHitboxes", data.Combat.LiftHitboxes)
		if data.Combat.LiftHitboxesHeight then
			safeSetOption("LiftHitboxesHeight", data.Combat.LiftHitboxesHeight)
		end

		safeSetToggle("UndergroundDesync", false)
		safeSetKeyPicker("UndergroundDesyncKeybind", data.Combat.UndergroundDesyncKeybind, "Toggle")

		safeSetToggle("AntiAim", false)
		safeSetKeyPicker("AntiAimKeybind", data.Combat.AntiAimKeybind, "Toggle")
		if data.Combat.AntiAimRadius then
			safeSetOption("AntiAimRadius", data.Combat.AntiAimRadius)
		end
		safeSetToggle("InstantADS", data.Combat.InstantADS)
		safeSetOption("ADSZoomMultiplier", data.Combat.ADSZoomMultiplier)
		safeSetToggle("HideViewmodelOnADS", data.Combat.HideViewmodelOnADS)
		safeSetKeyPicker("SkyPeekKeybind", data.Combat.SkyPeekKeybind, "Toggle")
		if data.Combat.SkyPeekDistance then
			safeSetOption("SkyPeekDistance", data.Combat.SkyPeekDistance)
		end
		if data.Combat.SkyPeekDuration then
			safeSetOption("SkyPeekDuration", data.Combat.SkyPeekDuration)
		end
		safeSetKeyPicker("SpiderClimbKeybind", data.Combat.SpiderClimbKeybind, "Hold")

		safeSetToggle("NoRecoil", data.Combat.NoRecoil)
		safeSetToggle("NoScope", data.Combat.NoScope)
		safeSetToggle("NoSway", data.Combat.NoSway)
		safeSetToggle("NoBob", data.Combat.NoBob)
		safeSetToggle("NoSpread", data.Combat.NoSpread)
		safeSetToggle("RapidFire", data.Combat.RapidFire)
		safeSetOption("RapidFireMultiplier", data.Combat.RapidFireValue)
		if data.Combat.InstantEquip ~= nil then
			safeSetToggle("InstantEquip", data.Combat.InstantEquip)
		end
	end

	if data.Mods then
		safeSetToggle("Hitsound", data.Mods.Hitsound)
		safeSetOption("HitsoundType", data.Mods.HitsoundType)
		safeSetOption("CustomSoundAssetIDorLocalFile", data.Mods.HitsoundCustomId)
		safeSetOption("HitsoundVolume", data.Mods.HitsoundVolume)
		safeSetToggle("HitEffects", data.Mods.HitEffects)
		if data.Mods.HitEffectsColor then
			safeSetColorPicker("HitEffectsColor", parseColor(data.Mods.HitEffectsColor))
		end

		-- Always default ThirdPerson to false upon loading; only load its keybind
		safeSetToggle("ThirdPerson", false)
		safeSetKeyPicker("ThirdPersonKeybind", data.Mods.ThirdPersonKeybind, "Toggle")
		safeSetOption("ZoomDistance", data.Mods.ZoomDistance)
		safeSetToggle("Fullbright", data.Mods.Fullbright)
		safeSetToggle("NoFog", data.Mods.NoFog)
		safeSetToggle("NoFoliage", data.Mods.NoFoliage)
		safeSetToggle("RemoveGrass", data.Mods.RemoveGrass)
		safeSetToggle("NoLandmines", data.Mods.NoLandmines)
		safeSetToggle("NoVisor", data.Mods.NoVisor)
		if data.Mods.Gloom ~= nil then
			safeSetToggle("Gloom", data.Mods.Gloom)
		end
		if data.Mods.NoShadows ~= nil then
			safeSetToggle("NoShadows", data.Mods.NoShadows)
		end
		safeSetToggle("NoFallDamage", data.Mods.NoFallDamage)
		safeSetToggle("Speedhack", data.Mods.Speedhack)
		safeSetOption("WalkspeedValue", data.Mods.WalkspeedValue)
		safeSetOption("FOV", data.Mods.FOV)
		safeSetOption("WorldTime", data.Mods.WorldTime)
		if data.Mods.WeatherType then
			safeSetOption("WeatherType", data.Mods.WeatherType)
		end
	end

	if data.Utilities then
		safeSetToggle("ClipCharacter", false)
		safeSetKeyPicker("ClipCharacterKeybind", data.Utilities.ClipCharacterKeybind, "Toggle")
		safeSetToggle("ModDetector", data.Utilities.ModDetector)
		safeSetOption("ModDetectorVolume", data.Utilities.ModDetectorVolume)
		safeSetToggle("LockKeybindHUD", data.Utilities.LockKeybindHUD)
		if data.Utilities.KeybindHUDX and data.Utilities.KeybindHUDY then
			getgenv().Config.Utilities.KeybindHUDX = data.Utilities.KeybindHUDX
			getgenv().Config.Utilities.KeybindHUDY = data.Utilities.KeybindHUDY
		end
	end

	task.delay(0.5, function()
		getgenv()._DeltaScriptSilentToggles = false
	end)
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

-- Apply Hardcoded BBot Theme
getgenv().Config.Theme = "BBot"
local BBotTheme = {
	FontColor = "ffffff",
	MainColor = "1e1e1e",
	AccentColor = "7e48a3",
	BackgroundColor = "232323",
	OutlineColor = "141414",
}
for idx, hex in pairs(BBotTheme) do
	Library[idx] = Color3.fromHex(hex)
end
if Library.GetDarkerColor then
	Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
end
if Library.UpdateColorsUsingRegistry then
	Library:UpdateColorsUsingRegistry()
end

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
getgenv().CharacterManager = CharacterManager

CharacterManager.ActiveEnemies = {}
CharacterManager.ActiveNPCs = {}
CharacterManager.ActiveHelicopters = {}
CharacterManager.ActiveHelicopterESP = {}
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

				local characterModel = player.Character or Workspace:FindFirstChild(player.Name)
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
			local newHelicopterESP = {}
			local aiZones = Workspace:FindFirstChild("AiZones")
			if aiZones then
				-- Scan standard NPCs in all zones
				for _, zone in ipairs(aiZones:GetChildren()) do
					for _, child in ipairs(zone:GetChildren()) do
						if child:IsA("Model") and child.Name ~= "MI24V" then
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

				-- Scan Helicopters only in HeliAirfield
				local heliAirfield = aiZones:FindFirstChild("HeliAirfield")
				if heliAirfield then
					for _, child in ipairs(heliAirfield:GetChildren()) do
						if child:IsA("Model") and child.Name == "MI24V" then
							-- 1. Process Pilots (Add to SilentAim & NPC ESP)
							local pilots = child:FindFirstChild("Pilots")
							if pilots then
								for _, pilot in ipairs(pilots:GetChildren()) do
									if
										pilot:IsA("Model")
										and pilot:FindFirstChild("Head")
										and pilot.Name == "Pilot"
									then
										local root = pilot:FindFirstChild("HumanoidRootPart")
											or pilot.PrimaryPart
											or pilot:FindFirstChild("Head")

										-- Add to NPC ESP
										newNPCs[pilot] = {
											Character = pilot,
											Head = pilot:FindFirstChild("Head"),
											RootPart = root,
											Name = pilot.Name,
											IsNPC = true,
											Health = 100,
											MaxHealth = 100,
										}
									end
								end
							end

							-- 2. Process Helicopter Chassis (ESP Only, NEVER Silent Aim)
							local enginePart = child:FindFirstChild("Engine")
							if enginePart and not enginePart:IsA("BasePart") then
								enginePart = nil
							end
							local heliHead = enginePart or child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
							local heliRoot = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
							if heliHead and heliRoot then
								newHelicopterESP[child] = {
									Character = child,
									Head = heliHead,
									RootPart = heliRoot,
									Name = "MI24V",
									IsHelicopterESP = true,
									Health = 100,
									MaxHealth = 100,
								}
							end
						end
					end
				end
			end
			CharacterManager.ActiveNPCs = newNPCs
			CharacterManager.ActiveHelicopterESP = newHelicopterESP

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
							RootPart = child:FindFirstChild("HumanoidRootPart"),
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

function CharacterManager.GetHelicopterESP()
	return CharacterManager.ActiveHelicopterESP
end

function CharacterManager.GetCorpses()
	return CharacterManager.ActiveCorpses
end

function CharacterManager.GetExits()
	return CharacterManager.ActiveExits
end

CharacterManager.VisibilityCache = {}
CharacterManager.LastVisCheck = {}
CharacterManager.SharedIgnoreList = nil

local sharedRaycastParams = RaycastParams.new()
sharedRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
sharedRaycastParams.IgnoreWater = false
pcall(function()
	sharedRaycastParams.CollisionGroup = "WeaponRay"
end)

function CharacterManager.GetManipulatedOrigin(base_pos, target_pos, targetRoot, isUnderground)
	if not getgenv().Config or not getgenv().Config.Combat or not getgenv().Config.Combat.OriginManipulation then
		return nil
	end

	if getgenv().TargetManager and getgenv().TargetManager.CurrentTarget then
		local currentTarget = getgenv().TargetManager.CurrentTarget
		local currentTargetRoot = currentTarget.RootPart
			or (currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart"))
			or currentTarget.Head
		if currentTargetRoot ~= targetRoot then
			return nil -- Only manipulate origin for the current Silent Aim target
		end
	end

	local max_dist = getgenv().Config.Combat.OriginManipulationDistance or 5
	local right = Workspace.CurrentCamera.CFrame.RightVector
	local up = Workspace.CurrentCamera.CFrame.UpVector
	local directions = {
		up,
		-right, -- left
		right,
		(-right + up).Unit, -- up-left
		(right + up).Unit, -- up-right
	}

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local nocollision = workspace:FindFirstChild("NoCollision")
	if nocollision then
		params.FilterDescendantsInstances = { LocalPlayer.Character, Workspace.CurrentCamera, nocollision }
	else
		params.FilterDescendantsInstances = { LocalPlayer.Character, Workspace.CurrentCamera }
	end

	if getgenv().CachedGlobalIgnoreList then
		local filtered = params.FilterDescendantsInstances
		for _, v in ipairs(getgenv().CachedGlobalIgnoreList) do
			table.insert(filtered, v)
		end
		params.FilterDescendantsInstances = filtered
	end

	local found_origin = nil
	local clear_distances = {}

	for i, dir in ipairs(directions) do
		local limit = max_dist + 1.5
		local check = Workspace:Raycast(base_pos, dir * limit, params)
		clear_distances[i] = check and check.Distance or limit
	end

	for d = 1, max_dist, 1 do
		for i, dir in ipairs(directions) do
			local dist = d
			if isUnderground and (i == 3 or i == 4 or i == 5) then
				dist = math.max(0, d - 3.8)
			end
			if dist > 0 and clear_distances[i] >= dist then
				local offset = dir * dist
				local origin_test = base_pos + offset
				local res = Workspace:Raycast(origin_test, target_pos - origin_test, params)
				if
					not res
					or (
						targetRoot
						and res.Instance
						and targetRoot.Parent
						and res.Instance:IsDescendantOf(targetRoot.Parent)
					)
				then
					local buffered_dist = dist + 1.5
					if clear_distances[i] >= buffered_dist then
						local buffered_origin = base_pos + (dir * buffered_dist)
						local b_res = Workspace:Raycast(buffered_origin, target_pos - buffered_origin, params)
						if
							not b_res
							or (
								targetRoot
								and b_res.Instance
								and targetRoot.Parent
								and b_res.Instance:IsDescendantOf(targetRoot.Parent)
							)
						then
							found_origin = buffered_origin
							break
						end
					end
					if not found_origin then
						found_origin = origin_test
						break
					end
				end
			end
		end
		if found_origin then
			break
		end
	end

	return found_origin
end

function CharacterManager.IsVisible(targetHead, characterModel)
	if not LocalPlayer.Character then
		return false
	end

	local screenPosition, isVisibleOnScreen = Camera:WorldToViewportPoint(targetHead.Position)
	local isOnScreen = isVisibleOnScreen and screenPosition.Z > 0

	if not isOnScreen and not (getgenv().Config and getgenv().Config.Combat and getgenv().Config.Combat.Autopilot) then
		return false
	end

	-- Rate limit raycasts to 10 times per second to save FPS (bypassed for Autopilot to ensure instant response)
	local now = os.clock()
	local lastCheck = CharacterManager.LastVisCheck[targetHead] or 0
	if
		not (getgenv().Config and getgenv().Config.Combat and getgenv().Config.Combat.Autopilot)
		and (now - lastCheck < 0.1)
	then
		return CharacterManager.VisibilityCache[targetHead] or false
	end

	local base_origin = Camera.CFrame.Position
	local origin = base_origin
	local direction = targetHead.Position - origin
	local target_pos = targetHead.Position

	if not getgenv().CachedGlobalIgnoreList then
		pcall(function()
			local repStorage = game:GetService("ReplicatedStorage")
			local UniversalTables = require((repStorage :: any).Modules:WaitForChild("UniversalTables", 2))
			local globalIgnore = UniversalTables.ReturnTable("GlobalIgnoreListProjectile")
			if type(globalIgnore) == "table" then
				getgenv().CachedGlobalIgnoreList = globalIgnore
			end
		end)
		if not getgenv().CachedGlobalIgnoreList then
			getgenv().CachedGlobalIgnoreList = {}
		end
	end

	local ignoreList = { LocalPlayer.Character, characterModel }
	if getgenv().CachedGlobalIgnoreList then
		for _, v in ipairs(getgenv().CachedGlobalIgnoreList) do
			table.insert(ignoreList, v)
		end
	end
	sharedRaycastParams.FilterDescendantsInstances = ignoreList

	local result = Workspace:Raycast(origin, direction, sharedRaycastParams)
	local isVis = (result == nil)

	if not isVis then
		local isUnderground = getgenv().Config and getgenv().Config.Combat and getgenv().Config.Combat.UndergroundDesync
		local targetRoot = characterModel and characterModel:FindFirstChild("HumanoidRootPart")
		local found_origin = CharacterManager.GetManipulatedOrigin(base_origin, target_pos, targetRoot, isUnderground)
		if found_origin then
			isVis = true
		end
	end

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
getgenv().TargetManager = TargetManager

function TargetManager.GetClosestTargetToMouse()
	local config = getgenv().Config.SilentAim
	local targetType = config.TargetType or "Players"

	local mouseLocation = UserInputService:GetMouseLocation()
	local shortestDistance = config.FOVRadius
	local closestTarget = nil

	local function processCharacters(characters)
		for character, playerData in pairs(characters) do
			if config.WhitelistPlayers and playerData.Player and config.WhitelistPlayers[playerData.Player.Name] then
				continue
			end

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
	FOVCircleGlows = {},
	Snapline = Drawing.new("Line"),
	SparkleHead = Drawing.new("Circle"),
	Sparkles = {},
	SparklesPool = {},
	CrosshairLines = {},
	CrosshairGlows = {},
}
for i = 1, 8 do
	local line = Drawing.new("Line")
	line.Color = Color3.fromRGB(255, 255, 255)
	line.Thickness = 1.5
	line.ZIndex = 2
	line.Visible = false
	table.insert(CombatManager.CrosshairLines, line)

	local glowsForLine = {}
	for g = 1, 8 do
		local glow = Drawing.new("Line")
		glow.Color = Color3.fromRGB(255, 255, 255)
		glow.Thickness = math.floor(1 + (g ^ 1.2))
		glow.Transparency = math.clamp(0.6 / (g ^ 1.1), 0.05, 0.6)
		glow.ZIndex = 1
		glow.Visible = false
		table.insert(glowsForLine, glow)
	end
	table.insert(CombatManager.CrosshairGlows, glowsForLine)
end
getgenv().CombatManager = CombatManager

-- Initialize Drawings
CombatManager.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
CombatManager.FOVCircle.Thickness = 1
CombatManager.FOVCircle.Filled = false
CombatManager.FOVCircle.Transparency = 1
CombatManager.FOVCircle.ZIndex = 2

for i = 1, 8 do
	local glow = Drawing.new("Circle")
	glow.Filled = false
	glow.Color = Color3.fromRGB(255, 255, 255)
	glow.Thickness = math.floor(1 + (i ^ 1.7))
	glow.Transparency = math.clamp(0.6 / (i ^ 1.2), 0.02, 0.6)
	glow.ZIndex = 1
	glow.Visible = false
	table.insert(CombatManager.FOVCircleGlows, glow)
end

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
local math_min = math.min
local math_pi_half = math.pi / 2
local os_clock = os.clock
local Vector2_new = Vector2.new
local Color3_fromRGB = Color3.fromRGB

function CombatManager.Update()
	local config = getgenv().Config.SilentAim
	local mouseLocation = UserInputService:GetMouseLocation()

	-- Update FOV Circle
	if config.ShowFOV then
		local fovColor = config.FOVColor or Color3_fromRGB(255, 255, 255)
		CombatManager.FOVCircle.Position = mouseLocation
		CombatManager.FOVCircle.Radius = config.FOVRadius
		CombatManager.FOVCircle.Color = fovColor
		CombatManager.FOVCircle.Visible = true

		for _, glow in ipairs(CombatManager.FOVCircleGlows) do
			glow.Position = mouseLocation
			glow.Radius = config.FOVRadius
			glow.Color = fovColor
			glow.Visible = true
		end

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
		if CombatManager.FOVCircle.Visible then
			CombatManager.FOVCircle.Visible = false
			for _, glow in ipairs(CombatManager.FOVCircleGlows) do
				glow.Visible = false
			end
			CombatManager.SparkleHead.Visible = false
		end
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
	local currentTarget = TargetManager.CurrentTarget

	local targetScreenPosition = nil
	local targetIsVisible = false
	local targetAimPart = nil

	if currentTarget then
		local targetPartName = config.TargetPart or "Head"
		targetAimPart = (currentTarget.Character and currentTarget.Character:FindFirstChild(targetPartName))
			or currentTarget.Head
		if targetAimPart then
			targetScreenPosition, targetIsVisible = Camera:WorldToViewportPoint(targetAimPart.Position)
		end
	end

	if config.ShowSnapline and targetScreenPosition then
		if targetIsVisible and targetScreenPosition.Z > 0 then
			local isVisible3D = config.VisibleCheck
				and CharacterManager.IsVisible(
					targetAimPart,
					currentTarget.Player and currentTarget.Player.Character or currentTarget.Head.Parent
				)
			CombatManager.Snapline.From = mouseLocation
			CombatManager.Snapline.To = Vector2_new(targetScreenPosition.X, targetScreenPosition.Y)
			CombatManager.Snapline.Color = isVisible3D and config.VisibleColor or config.SnaplineColor
			CombatManager.Snapline.Visible = true
		else
			CombatManager.Snapline.Visible = false
		end
	else
		CombatManager.Snapline.Visible = false
	end

	-- Update Crosshair
	local combatConfig = getgenv().Config.Combat
	if combatConfig.ShowCrosshair then
		local camera = Workspace.CurrentCamera
		if camera then
			local center = mouseLocation

			if targetScreenPosition and targetIsVisible and targetScreenPosition.Z > 0 then
				center = Vector2_new(targetScreenPosition.X, targetScreenPosition.Y)
			end

			local cType = combatConfig.CrosshairType
			local cColor = combatConfig.CrosshairColor or Color3_fromRGB(127, 72, 163)
			local time = os_clock()

			if cType == "Default" then
				local size = combatConfig.CrosshairSize or 13.6
				local gap = combatConfig.CrosshairDistance or 6.8
				for i = 1, 4 do
					local line = CombatManager.CrosshairLines[i]
					local glows = CombatManager.CrosshairGlows[i]
					local angle = (i - 1) * math_pi_half
					local dir = Vector2_new(math_cos(angle), math_sin(angle))

					line.From = center + dir * gap
					line.To = center + dir * (gap + size)
					line.Color = cColor
					line.Visible = true

					for g = 1, 8 do
						local glow = glows[g]
						local inset = math_min(glow.Thickness * 0.4, size * 0.45)
						glow.From = center + dir * (gap + inset)
						glow.To = center + dir * (gap + size - inset)
						glow.Color = cColor
						glow.Visible = true
					end
				end
				if CombatManager.CrosshairLines[5].Visible then
					for i = 5, 8 do
						CombatManager.CrosshairLines[i].Visible = false
						for g = 1, 8 do
							CombatManager.CrosshairGlows[i][g].Visible = false
						end
					end
				end
			elseif cType == "Rotation" then
				local size = combatConfig.CrosshairSize or 17
				local gap = combatConfig.CrosshairDistance or 8.5
				local speed = combatConfig.CrosshairRotationSpeed or 3
				local spin = time * speed
				for i = 1, 4 do
					local line = CombatManager.CrosshairLines[i]
					local glows = CombatManager.CrosshairGlows[i]
					local angle = (i - 1) * math_pi_half + spin
					local dir = Vector2_new(math_cos(angle), math_sin(angle))

					line.From = center + dir * gap
					line.To = center + dir * (gap + size)
					line.Color = cColor
					line.Visible = true

					for g = 1, 8 do
						local glow = glows[g]
						local inset = math_min(glow.Thickness * 0.4, size * 0.45)
						glow.From = center + dir * (gap + inset)
						glow.To = center + dir * (gap + size - inset)
						glow.Color = cColor
						glow.Visible = true
					end
				end
				if CombatManager.CrosshairLines[5].Visible then
					for i = 5, 8 do
						CombatManager.CrosshairLines[i].Visible = false
						for g = 1, 8 do
							CombatManager.CrosshairGlows[i][g].Visible = false
						end
					end
				end
			elseif cType == "Nazi" then
				local size = combatConfig.CrosshairSize or 17
				local gap = combatConfig.CrosshairDistance or 0
				local speed = combatConfig.CrosshairRotationSpeed or 3
				local spin = time * speed
				for i = 1, 4 do
					local idx1 = (i - 1) * 2 + 1
					local idx2 = (i - 1) * 2 + 2

					local line1 = CombatManager.CrosshairLines[idx1]
					local line2 = CombatManager.CrosshairLines[idx2]
					local glows1 = CombatManager.CrosshairGlows[idx1]
					local glows2 = CombatManager.CrosshairGlows[idx2]

					local angle1 = (i - 1) * math_pi_half + spin
					local angle2 = angle1 + math_pi_half
					local dir1 = Vector2_new(math_cos(angle1), math_sin(angle1))
					local dir2 = Vector2_new(math_cos(angle2), math_sin(angle2))
					local startPoint = center + dir1 * gap
					local midPoint = startPoint + dir1 * size

					line1.From = startPoint
					line1.To = midPoint
					line1.Color = cColor
					line1.Visible = true

					line2.From = midPoint
					line2.To = midPoint + dir2 * size
					line2.Color = cColor
					line2.Visible = true

					for g = 1, 8 do
						local glow1 = glows1[g]
						local inset = math_min(glow1.Thickness * 0.4, size * 0.45)
						glow1.From = startPoint + dir1 * inset
						glow1.To = midPoint - dir1 * inset
						glow1.Color = cColor
						glow1.Visible = true

						local glow2 = glows2[g]
						glow2.From = midPoint + dir2 * inset
						glow2.To = (midPoint + dir2 * size) - dir2 * inset
						glow2.Color = cColor
						glow2.Visible = true
					end
				end
			end
		end
	else
		if CombatManager.CrosshairLines[1].Visible then
			for i = 1, 8 do
				CombatManager.CrosshairLines[i].Visible = false
				for g = 1, 8 do
					CombatManager.CrosshairGlows[i][g].Visible = false
				end
			end
		end
	end
end

-- ==========================================
-- KeybindHUDManager
-- ==========================================
local KeybindHUDManager = {
	Gui = nil,
	Frames = {},
	Entries = {},
}

function KeybindHUDManager.Init()
	local success, result = pcall(function()
		return getgenv().gethui and getgenv().gethui() or game:GetService("CoreGui")
	end)
	local parent = success and result or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

	if parent:FindFirstChild("DeltaKeybindHUD") then
		parent.DeltaKeybindHUD:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "DeltaKeybindHUD"
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.Parent = parent
	KeybindHUDManager.Gui = gui

	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.BorderSizePixel = 1
	bg.ZIndex = 1
	bg.Active = true
	bg.Parent = gui
	KeybindHUDManager.Frames.Background = bg

	bg:GetPropertyChangedSignal("Position"):Connect(function()
		if getgenv().Config.Utilities then
			getgenv().Config.Utilities.KeybindHUDX = bg.Position.X.Offset
			getgenv().Config.Utilities.KeybindHUDY = bg.Position.Y.Offset
		end
	end)

	local top = Instance.new("Frame")
	top.Name = "TopLine"
	top.BorderSizePixel = 0
	top.ZIndex = 3
	top.Parent = bg
	KeybindHUDManager.Frames.TopLine = top

	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.BorderSizePixel = 0
	divider.ZIndex = 3
	divider.Parent = bg
	KeybindHUDManager.Frames.Divider = divider

	local dividerGrad = Instance.new("UIGradient")
	dividerGrad.Parent = divider
	KeybindHUDManager.Frames.DividerGrad = dividerGrad

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Text = "Keybinds"
	title.TextSize = 11
	title.Font = Enum.Font.Code
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 4
	title.TextStrokeTransparency = 0
	title.Parent = bg
	KeybindHUDManager.Frames.Title = title

	for i = 1, 20 do
		local text = Instance.new("TextLabel")
		text.BackgroundTransparency = 1
		text.TextSize = 10
		text.Font = Enum.Font.Code
		text.TextXAlignment = Enum.TextXAlignment.Left
		text.ZIndex = 4
		text.TextStrokeTransparency = 0
		text.Visible = false
		text.Parent = bg

		local val = Instance.new("TextLabel")
		val.BackgroundTransparency = 1
		val.TextSize = 10
		val.Font = Enum.Font.Code
		val.TextXAlignment = Enum.TextXAlignment.Right
		val.ZIndex = 4
		val.TextStrokeTransparency = 0
		val.Visible = false
		val.Parent = bg

		table.insert(KeybindHUDManager.Entries, { Text = text, Val = val })
	end
end

function KeybindHUDManager.Update()
	local active = {}

	local function FormatKey(keyStr)
		if typeof(keyStr) == "EnumItem" then
			return keyStr.Name
		end
		if typeof(keyStr) == "string" and keyStr ~= "None" and keyStr ~= "" then
			return keyStr
		end
		return nil
	end

	local features = {
		{
			Name = "Instant Hit",
			GetState = function()
				return getgenv().Config and getgenv().Config.Combat and getgenv().Config.Combat.InstantHit
			end,
			GetMode = function()
				return "(Toggle)"
			end,
			GetKey = function()
				return nil
			end,
		},
		{
			Name = "Autopilot",
			GetState = function()
				return getgenv().Config and getgenv().Config.Combat and getgenv().Config.Combat.Autopilot
			end,
			GetMode = function()
				return "(Toggle)"
			end,
			GetKey = function()
				return nil
			end,
		},
		{
			Name = "Triggerbot",
			GetState = function()
				return getgenv().Config and getgenv().Config.Combat and getgenv().Config.Combat.TriggerBot
			end,
			GetMode = function()
				return "(Toggle)"
			end,
			GetKey = function()
				return nil
			end,
		},
		{
			Name = "Silent Aim",
			GetState = function()
				return getgenv().Config and getgenv().Config.SilentAim and getgenv().Config.SilentAim.Enabled
			end,
			GetMode = function()
				return "(Toggle)"
			end,
			GetKey = function()
				return nil
			end,
		},
		{
			Name = "Underground Desync",
			GetState = function()
				return getgenv().Config and getgenv().Config.Combat and getgenv().Config.Combat.UndergroundDesync
			end,
			GetMode = function()
				return getgenv().Options
						and getgenv().Options.UndergroundDesyncKeybind
						and "(" .. getgenv().Options.UndergroundDesyncKeybind.Mode .. ")"
					or "(Toggle)"
			end,
			GetKey = function()
				return getgenv().Options
					and getgenv().Options.UndergroundDesyncKeybind
					and FormatKey(getgenv().Options.UndergroundDesyncKeybind.Value)
			end,
		},
		{
			Name = "Spider Climb",
			GetState = function()
				return getgenv().Options
					and getgenv().Options.SpiderClimbKeybind
					and getgenv().Options.SpiderClimbKeybind:GetState()
			end,
			GetMode = function()
				return getgenv().Options
						and getgenv().Options.SpiderClimbKeybind
						and "(" .. getgenv().Options.SpiderClimbKeybind.Mode .. ")"
					or "(Hold)"
			end,
			GetKey = function()
				return getgenv().Options
					and getgenv().Options.SpiderClimbKeybind
					and FormatKey(getgenv().Options.SpiderClimbKeybind.Value)
			end,
		},
		{
			Name = "Sky Peek",
			GetState = function()
				return getgenv()._SkyPeekActive == true
			end,
			GetMode = function()
				return "(Keypress)"
			end,
			GetKey = function()
				return getgenv().Options
					and getgenv().Options.SkyPeekKeybind
					and FormatKey(getgenv().Options.SkyPeekKeybind.Value)
			end,
		},
		{
			Name = "Underground Resolver",
			GetState = function()
				return getgenv()._UndergroundResolverActive == true
			end,
			GetMode = function()
				return "(Keypress)"
			end,
			GetKey = function()
				return getgenv().Options
					and getgenv().Options.UndergroundResolverKeybind
					and FormatKey(getgenv().Options.UndergroundResolverKeybind.Value)
			end,
		},
		{
			Name = "3rd Person",
			GetState = function()
				return getgenv().Config and getgenv().Config.Mods and getgenv().Config.Mods.ThirdPerson
			end,
			GetMode = function()
				return getgenv().Options
						and getgenv().Options.ThirdPersonKeybind
						and "(" .. getgenv().Options.ThirdPersonKeybind.Mode .. ")"
					or "(Toggle)"
			end,
			GetKey = function()
				return getgenv().Options
					and getgenv().Options.ThirdPersonKeybind
					and FormatKey(getgenv().Options.ThirdPersonKeybind.Value)
			end,
		},
	}

	for _, f in ipairs(features) do
		local stateVal = false
		local modeStr = "(Toggle)"
		local keyStr = nil
		pcall(function()
			stateVal = f.GetState() == true
		end)
		pcall(function()
			modeStr = f.GetMode()
		end)
		pcall(function()
			keyStr = f.GetKey()
		end)

		local displayName = f.Name
		if keyStr then
			displayName = "[" .. keyStr .. "] " .. displayName
		end

		table.insert(active, { Name = displayName, Mode = modeStr, State = stateVal })
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize

	local width = 180
	local entryHeight = 15
	local padding = 5
	local headerHeight = 22
	local height = headerHeight + padding + (#active * entryHeight)

	local u = getgenv().Config.Utilities
	local startX = (u and u.KeybindHUDX) or (viewport.X - width - 20)
	local startY = (u and u.KeybindHUDY) or ((viewport.Y / 2) - (height / 2))

	local d = KeybindHUDManager.Frames
	if not d.Background then
		return
	end
	local locked = false
	if getgenv().Toggles and getgenv().Toggles.LockKeybindHUD then
		locked = getgenv().Toggles.LockKeybindHUD.Value
	end
	d.Background.Draggable = not locked
	local lib = getgenv().LinoriaLibrary

	local bgColor = Color3.fromHex("232323")
	local outlineColor = Color3.fromHex("141414")
	local accentColor = Color3.fromHex("7e48a3")
	if lib then
		bgColor = lib.BackgroundColor or bgColor
		outlineColor = lib.OutlineColor or outlineColor
		accentColor = lib.AccentColor or accentColor
	end

	d.Background.BackgroundColor3 = bgColor
	d.Background.BorderColor3 = outlineColor
	d.TopLine.BackgroundColor3 = accentColor
	d.Divider.BackgroundColor3 = Color3.new(1, 1, 1)
	d.Title.TextColor3 = Color3.fromHex("CFCFCF")

	local show = true
	d.Background.Visible = show
	d.Background.Size = UDim2.new(0, width, 0, height)
	if d.Background.Position.X.Offset ~= startX or d.Background.Position.Y.Offset ~= startY then
		d.Background.Position = UDim2.new(0, startX, 0, startY)
	end

	d.TopLine.Size = UDim2.new(0, width, 0, 2)
	d.TopLine.Position = UDim2.new(0, 0, 0, 0)
	d.TopLine.Visible = show

	d.Divider.Size = UDim2.new(0, width, 0, 1)
	d.Divider.Position = UDim2.new(0, 0, 0, headerHeight - 2)
	d.Divider.Visible = show

	d.Title.Size = UDim2.new(1, -12, 0, headerHeight)
	d.Title.Position = UDim2.new(0, 6, 0, 0)
	d.Title.Visible = show

	local time = tick()
	local speed = 1.2
	local baseColor = Color3.fromHex("7D7D7D")

	local glowColor = accentColor:Lerp(Color3.new(1, 1, 1), 0.6)
	local seq = ColorSequence.new({
		ColorSequenceKeypoint.new(0, outlineColor),
		ColorSequenceKeypoint.new(0.4, accentColor),
		ColorSequenceKeypoint.new(0.5, glowColor),
		ColorSequenceKeypoint.new(0.6, accentColor),
		ColorSequenceKeypoint.new(1, outlineColor),
	})

	if d.DividerGrad then
		d.DividerGrad.Color = seq
		d.DividerGrad.Offset = Vector2.new(math.sin(time * speed), 0)
	end

	for i = 1, #KeybindHUDManager.Entries do
		local entry = KeybindHUDManager.Entries[i]
		if i <= #active and show then
			entry.Text.Text = active[i].Name
			entry.Text.Size = UDim2.new(1, -12, 0, entryHeight)
			entry.Text.Position = UDim2.new(0, 6, 0, headerHeight + ((i - 1) * entryHeight))
			entry.Text.Visible = true

			entry.Val.Text = active[i].Mode
			entry.Val.Size = UDim2.new(1, -12, 0, entryHeight)
			entry.Val.Position = UDim2.new(0, 6, 0, headerHeight + ((i - 1) * entryHeight))
			entry.Val.Visible = (active[i].Mode ~= "")

			local isActive = active[i].State

			if isActive then
				entry.Text.TextColor3 = accentColor
				entry.Val.TextColor3 = accentColor
			else
				entry.Text.TextColor3 = baseColor
				entry.Val.TextColor3 = baseColor
			end
		else
			entry.Text.Visible = false
			entry.Val.Visible = false
		end
	end
end

KeybindHUDManager.Init()
getgenv().DeltaChamsOriginalCache = getgenv().DeltaChamsOriginalCache or {}
getgenv().DeltaChamsCache = getgenv().DeltaChamsCache or {}
getgenv().DeltaChamsStateCache = getgenv().DeltaChamsStateCache or {}

-- ==========================================
-- ESPManager
-- ==========================================
local ESPManager = {
	Cache = {},
	CorpseCache = {},
	ExitCache = {},
	RestorePart = function(part: any, originalData: any) end,
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
			if cacheData.Box2DOutline then
				cacheData.Box2DOutline:Remove()
			end
			if cacheData.Box2D then
				cacheData.Box2D:Remove()
			end
			if cacheData.CornerLines then
				for _, line in ipairs(cacheData.CornerLinesOutline) do
					line:Remove()
				end
				for _, line in ipairs(cacheData.CornerLines) do
					line:Remove()
				end
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

	if
		config.ShowKDR
		and playerData.Player
		and not playerData.IsCorpse
		and not playerData.IsExit
		and not playerData.IsNPC
		and not playerData.IsHelicopterESP
		and not playerData.IsHelicopter
	then
		local kills, deaths = StatsManager.GetPlayerKDR(playerData.Player.Name)
		local ratio = (deaths > 0) and (kills / deaths) or kills
		table.insert(textLines, string.format("KDR: %.2f", ratio))
	end

	return table.concat(textLines, "\n")
end

local espOffsetRoot = Vector3.new(0, 3, 0)
local espOffsetHead = Vector3.new(0, 1.5, 0)

local function DrawEntity(character, data, config, config_sa, camPos, worldToViewportPoint)
	local distStuds = (camPos - data.Head.Position).Magnitude
	local distMeters = math.floor(distStuds * 0.33)
	if distMeters > (config.MaxDistance or 1500) then
		ESPManager.RemoveDrawing(character)
		local highlight = getgenv().DeltaChamsCache and getgenv().DeltaChamsCache[character]
		if highlight then
			highlight:Destroy()
			getgenv().DeltaChamsCache[character] = nil
		end
		return
	end

	local isVisible3D = false
	if
		config.VisibleCheck
		and not data.IsCorpse
		and not data.IsExit
		and (config.Enabled or config.ChamsEnabled or config.NPCESPEnabled or config.HelicopterESPEnabled)
	then
		local targetPartName = config_sa.TargetPart or "Head"
		local aimPart = (character and character:FindFirstChild(targetPartName)) or data.Head
		isVisible3D = CharacterManager.IsVisible(aimPart, character)
	end

	-- Handle Text ESP
	if
		(config.Enabled and not data.IsCorpse and not data.IsExit and not data.IsNPC and not data.IsHelicopterESP)
		or (config.NPCESPEnabled and data.IsNPC)
		or (config.CorpseESPEnabled and data.IsCorpse)
		or (config.ExitESPEnabled and data.IsExit)
		or (config.HelicopterESPEnabled and data.IsHelicopterESP)
	then
		local cacheData = ESPManager.Cache[character]
		if not cacheData then
			cacheData = {
				Text = ESPManager.CreateTextDrawing(),
				DistanceText = ESPManager.CreateTextDrawing(),
				Bg = Drawing.new("Square"),
				Bar = Drawing.new("Square"),
				Box2DOutline = Drawing.new("Square"),
				Box2D = Drawing.new("Square"),
			}
			cacheData.Bg.Filled = true
			cacheData.Bg.Color = Color3.fromRGB(0, 0, 0)
			cacheData.Bg.Thickness = 1
			cacheData.Bar.Filled = true
			cacheData.Bar.Color = Color3.fromRGB(0, 255, 0)
			cacheData.Bar.Thickness = 1
			cacheData.Box2DOutline.Filled = false
			cacheData.Box2DOutline.Thickness = 3
			cacheData.Box2D.Filled = false
			cacheData.Box2D.Thickness = 1
			cacheData.CornerLines = {}
			cacheData.CornerLinesOutline = {}
			for i = 1, 8 do
				local outline = Drawing.new("Line")
				outline.Thickness = 3
				outline.Color = Color3.fromRGB(0, 0, 0)
				outline.Visible = false
				cacheData.CornerLinesOutline[i] = outline
				local line = Drawing.new("Line")
				line.Thickness = 1
				line.Visible = false
				cacheData.CornerLines[i] = line
			end
			ESPManager.Cache[character] = cacheData
		end
		local textDrawing = type(cacheData) == "table" and cacheData.Text or cacheData

		local screenPosition, isVisibleOnScreen = worldToViewportPoint(Camera, data.Head.Position + espOffsetHead)
		local boxTopScreenPos = worldToViewportPoint(Camera, data.Head.Position + Vector3.new(0, 0.5, 0))

		if isVisibleOnScreen and screenPosition.Z > 0 then
			local textStr = ESPManager.FormatPlayerText(data)
			if config.ShowDistance and (data.IsCorpse or data.IsExit) then
				textStr = textStr .. "\n(" .. tostring(distMeters) .. " m)"
			end

			if textDrawing.Text ~= textStr then
				textDrawing.Text = textStr
			end

			textDrawing.Position = Vector2.new(screenPosition.X, screenPosition.Y - 15)

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
			elseif data.IsHelicopterESP then
				color = isVisible3D and config.VisibleColor or config.HelicopterTextColor
				outlineColor = config.HelicopterOutlineColor
			else
				color = isVisible3D and config.VisibleColor or config.TextColor
				outlineColor = config.OutlineColor
			end

			if textDrawing.Color ~= color then
				textDrawing.Color = color
			end
			if textDrawing.OutlineColor ~= outlineColor then
				textDrawing.OutlineColor = outlineColor
			end
			if textDrawing.Size ~= config.TextSize then
				textDrawing.Size = config.TextSize
			end
			if textDrawing.Font ~= config.Font then
				textDrawing.Font = config.Font
			end
			if not textDrawing.Visible then
				textDrawing.Visible = true
			end

			local screenLegs
			if data.RootPart then
				screenLegs = worldToViewportPoint(Camera, data.RootPart.Position - espOffsetRoot)
			else
				screenLegs = Vector3.new(screenPosition.X, screenPosition.Y + 30, 0)
			end

			if type(cacheData) == "table" and cacheData.DistanceText then
				if config.ShowDistance and not (data.IsCorpse or data.IsExit) then
					local dStr = "(" .. tostring(distMeters) .. " m)"
					if cacheData.DistanceText.Text ~= dStr then
						cacheData.DistanceText.Text = dStr
					end
					cacheData.DistanceText.Position = Vector2.new(screenLegs.X, screenLegs.Y + 5)
					if cacheData.DistanceText.Color ~= color then
						cacheData.DistanceText.Color = color
					end
					if cacheData.DistanceText.OutlineColor ~= outlineColor then
						cacheData.DistanceText.OutlineColor = outlineColor
					end
					if cacheData.DistanceText.Size ~= config.TextSize then
						cacheData.DistanceText.Size = config.TextSize
					end
					if cacheData.DistanceText.Font ~= config.Font then
						cacheData.DistanceText.Font = config.Font
					end
					if not cacheData.DistanceText.Visible then
						cacheData.DistanceText.Visible = true
					end
				else
					if cacheData.DistanceText.Visible then
						cacheData.DistanceText.Visible = false
					end
				end
			end

			local showBar = config.ShowHealthBar
				and ((config.Enabled and not data.IsCorpse and not data.IsExit and not data.IsNPC and not data.IsHelicopterESP) or (config.NPCESPEnabled and data.IsNPC) or (config.HelicopterESPEnabled and data.IsHelicopterESP))
				and data.Health
				and data.MaxHealth
			if showBar and data.RootPart and type(cacheData) == "table" then
				local height = math.clamp(screenLegs.Y - boxTopScreenPos.Y, 5, 1000)
				local barWidth = 3
				local offsetX = (height / 3.5) + 5
				local bgPosX = boxTopScreenPos.X + offsetX
				local bgPosY = boxTopScreenPos.Y

				cacheData.Bg.Size = Vector2.new(barWidth + 2, height + 2)
				cacheData.Bg.Position = Vector2.new(bgPosX - 1, bgPosY - 1)
				if not cacheData.Bg.Visible then
					cacheData.Bg.Visible = true
				end

				local healthPercent = math.clamp(data.Health / data.MaxHealth, 0, 1)
				local barHeight = height * healthPercent
				cacheData.Bar.Size = Vector2.new(barWidth, barHeight)
				cacheData.Bar.Position = Vector2.new(bgPosX, bgPosY + (height - barHeight))
				cacheData.Bar.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 100), healthPercent)
				if not cacheData.Bar.Visible then
					cacheData.Bar.Visible = true
				end
			elseif type(cacheData) == "table" then
				if cacheData.Bg.Visible then
					cacheData.Bg.Visible = false
				end
				if cacheData.Bar.Visible then
					cacheData.Bar.Visible = false
				end
			end

			if config.BoundingBox2DEnabled then
				if type(cacheData) == "table" then
					local height = math.clamp(screenLegs.Y - boxTopScreenPos.Y, 5, 1000)
					local width = height / 2
					local boxPosX = boxTopScreenPos.X - (width / 2)
					local boxPosY = boxTopScreenPos.Y

					if config.BoundingBox2DStyle == "Corner" then
						if cacheData.Box2DOutline.Visible then
							cacheData.Box2DOutline.Visible = false
						end
						if cacheData.Box2D.Visible then
							cacheData.Box2D.Visible = false
						end

						local len = width / 3

						local o1 = cacheData.CornerLinesOutline[1]
						o1.From = Vector2.new(boxPosX, boxPosY)
						o1.To = Vector2.new(boxPosX + len, boxPosY)
						if not o1.Visible then
							o1.Visible = true
						end

						local o2 = cacheData.CornerLinesOutline[2]
						o2.From = o1.From
						o2.To = Vector2.new(boxPosX, boxPosY + len)
						if not o2.Visible then
							o2.Visible = true
						end

						local o3 = cacheData.CornerLinesOutline[3]
						o3.From = Vector2.new(boxPosX + width, boxPosY)
						o3.To = Vector2.new(boxPosX + width - len, boxPosY)
						if not o3.Visible then
							o3.Visible = true
						end

						local o4 = cacheData.CornerLinesOutline[4]
						o4.From = o3.From
						o4.To = Vector2.new(boxPosX + width, boxPosY + len)
						if not o4.Visible then
							o4.Visible = true
						end

						local o5 = cacheData.CornerLinesOutline[5]
						o5.From = Vector2.new(boxPosX, boxPosY + height)
						o5.To = Vector2.new(boxPosX + len, boxPosY + height)
						if not o5.Visible then
							o5.Visible = true
						end

						local o6 = cacheData.CornerLinesOutline[6]
						o6.From = o5.From
						o6.To = Vector2.new(boxPosX, boxPosY + height - len)
						if not o6.Visible then
							o6.Visible = true
						end

						local o7 = cacheData.CornerLinesOutline[7]
						o7.From = Vector2.new(boxPosX + width, boxPosY + height)
						o7.To = Vector2.new(boxPosX + width - len, boxPosY + height)
						if not o7.Visible then
							o7.Visible = true
						end

						local o8 = cacheData.CornerLinesOutline[8]
						o8.From = o7.From
						o8.To = Vector2.new(boxPosX + width, boxPosY + height - len)
						if not o8.Visible then
							o8.Visible = true
						end

						local boxColor = config.BoundingBox2DColor
						for i = 1, 8 do
							local line = cacheData.CornerLines[i]
							local outline = cacheData.CornerLinesOutline[i]
							line.From = outline.From
							line.To = outline.To
							line.Color = boxColor
							if not line.Visible then
								line.Visible = true
							end
						end
					else
						if cacheData.CornerLines then
							for i = 1, 8 do
								if cacheData.CornerLinesOutline[i].Visible then
									cacheData.CornerLinesOutline[i].Visible = false
								end
								if cacheData.CornerLines[i].Visible then
									cacheData.CornerLines[i].Visible = false
								end
							end
						end

						cacheData.Box2DOutline.Size = Vector2.new(width, height)
						cacheData.Box2DOutline.Position = Vector2.new(boxPosX, boxPosY)
						cacheData.Box2DOutline.Color = Color3.fromRGB(0, 0, 0)
						if not cacheData.Box2DOutline.Visible then
							cacheData.Box2DOutline.Visible = true
						end

						cacheData.Box2D.Size = Vector2.new(width, height)
						cacheData.Box2D.Position = Vector2.new(boxPosX, boxPosY)
						cacheData.Box2D.Color = config.BoundingBox2DColor
						if not cacheData.Box2D.Visible then
							cacheData.Box2D.Visible = true
						end
					end
				end
			elseif type(cacheData) == "table" then
				if cacheData.Box2DOutline and cacheData.Box2DOutline.Visible then
					cacheData.Box2DOutline.Visible = false
				end
				if cacheData.Box2D and cacheData.Box2D.Visible then
					cacheData.Box2D.Visible = false
				end
				if cacheData.CornerLines then
					for i = 1, 8 do
						if cacheData.CornerLinesOutline[i].Visible then
							cacheData.CornerLinesOutline[i].Visible = false
						end
						if cacheData.CornerLines[i].Visible then
							cacheData.CornerLines[i].Visible = false
						end
					end
				end
			end
		else
			if textDrawing.Visible then
				textDrawing.Visible = false
			end
			if type(cacheData) == "table" then
				if cacheData.DistanceText then
					cacheData.DistanceText.Visible = false
				end
				cacheData.Bg.Visible = false
				cacheData.Bar.Visible = false
				if cacheData.Box2DOutline then
					cacheData.Box2DOutline.Visible = false
				end
				if cacheData.Box2D then
					cacheData.Box2D.Visible = false
				end
				if cacheData.CornerLines then
					for i = 1, 8 do
						if cacheData.CornerLinesOutline[i].Visible then
							cacheData.CornerLinesOutline[i].Visible = false
						end
						if cacheData.CornerLines[i].Visible then
							cacheData.CornerLines[i].Visible = false
						end
					end
				end
			end
		end
	else
		-- Garbage collect unused ESP memory when its toggle is off
		ESPManager.RemoveDrawing(character)
	end

	-- Handle Chams (Highlight)
	local shouldDrawChams = false
	if config.ChamsEnabled and not data.IsCorpse and not data.IsExit then
		local isPlayer = not data.IsNPC and not data.IsHelicopterESP
		if isPlayer then
			shouldDrawChams = config.Enabled -- Players require Enable ESP to be ON
		elseif data.IsNPC then
			shouldDrawChams = config.NPCESPEnabled -- NPCs require NPC ESP to be ON
		elseif data.IsHelicopterESP then
			shouldDrawChams = config.HelicopterESPEnabled -- Helicopters require Helicopter ESP to be ON
		end
	end

	-- Pin.Reta Exact 1:1 Engine (Direct Material Overwrite + SUNC Optimization)
	if shouldDrawChams then
		local fillCol = data.IsNPC and config.NPCChamsFillColor or config.ChamsFillColor
		local drawColor = (config.VisibleCheck and isVisible3D) and config.VisibleColor or fillCol
		local outlineColor = config.VisibleCheck and config.VisibleColor or fillCol
		local shouldHighlightBeEnabled = not isVisible3D
		local targetMaterial = Enum.Material.Neon

		-- SUNC: Retrieve or Initialize State Tracking
		local state = getgenv().DeltaChamsStateCache[character]
		if not state then
			state = {
				fillColor = nil,
				outlineColor = nil,
				highlightEnabled = nil,
				bodyColor = nil,
				bodyMaterial = nil,
			}
			getgenv().DeltaChamsStateCache[character] = state
		end

		-- Highlight ESP (Wallhacks)
		local highlight = getgenv().DeltaChamsCache[character]
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Parent = CoreGui
			-- SUNC: Use cloneref to bypass GC leaks
			highlight.Adornee = cloneref and cloneref(character) or character
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 0
			getgenv().DeltaChamsCache[character] = highlight
		end

		-- SUNC: State-Based Highlight Update
		if state.fillColor ~= drawColor then
			highlight.FillColor = drawColor
			state.fillColor = drawColor
		end
		if state.outlineColor ~= outlineColor then
			highlight.OutlineColor = outlineColor
			state.outlineColor = outlineColor
		end
		if state.highlightEnabled ~= shouldHighlightBeEnabled then
			highlight.Enabled = shouldHighlightBeEnabled
			state.highlightEnabled = shouldHighlightBeEnabled
		end

		-- Direct Body Overwrite (Forces Roblox to calculate bloom natively)
		local originalCache = getgenv().DeltaChamsOriginalCache[character]
		if not originalCache then
			originalCache = {}

			local function processPart(part)
				if part:IsA("BasePart") then
					if part.Name == "HumanoidRootPart" or string.find(string.lower(part.Name), "hitbox") then
						return
					end
					-- SUNC: Use cloneref for part caching to prevent hard memory leaks
					local safePart = cloneref and cloneref(part) or part
					if not originalCache[safePart] then
						local cacheData = {
							Material = safePart.Material,
							Color = safePart.Color,
							Transparency = safePart.Transparency,
							SpecMeshes = {},
							Decals = {},
						}

						if safePart:IsA("MeshPart") then
							pcall(function()
								cacheData.TextureID = safePart.TextureID
								cacheData.UsePartColor = safePart.UsePartColor
								safePart.TextureID = ""
								safePart.UsePartColor = true
							end)
						end

						for _, child in ipairs(safePart:GetChildren()) do
							if child:IsA("SpecialMesh") then
								local specData = { Mesh = child }
								pcall(function()
									specData.TextureId = child.TextureId
									specData.VertexColor = child.VertexColor
									child.TextureId = ""
									child.VertexColor = Vector3.new(1, 1, 1)
								end)
								table.insert(cacheData.SpecMeshes, specData)
							elseif child:IsA("SurfaceAppearance") then
								child:Destroy()
							elseif child:IsA("Decal") or child:IsA("Texture") then
								table.insert(cacheData.Decals, { Decal = child, Trans = child.Transparency })
								pcall(function()
									child.Transparency = 1
								end)
							end
						end

						originalCache[safePart] = cacheData
						if
							safePart.Transparency < 1
							or safePart:IsA("MeshPart")
							or safePart:FindFirstChildWhichIsA("SpecialMesh")
						then
							safePart.Transparency = 0
						end

						-- SUNC: Apply current active state to newly attached parts
						local currState = getgenv().DeltaChamsStateCache[character]
						if currState and currState.bodyMaterial then
							safePart.Material = currState.bodyMaterial
							safePart.Color = currState.bodyColor
						end
					end
				elseif part:IsA("SurfaceAppearance") then
					part:Destroy()
				end
			end

			for _, part in ipairs(character:GetDescendants()) do
				processPart(part)
			end

			-- SUNC: Dynamic listener for mid-game clothing changes (Zero loop overhead)
			state.connection = character.DescendantAdded:Connect(processPart)
			getgenv().DeltaChamsOriginalCache[character] = originalCache
		end

		-- SUNC: State-Based Material & Color Sync (Eliminates FPS drain)
		if state.bodyColor ~= drawColor or state.bodyMaterial ~= targetMaterial then
			for part, _ in pairs(originalCache) do
				if part.Parent then
					part.Color = drawColor
					part.Material = targetMaterial
				end
			end
			state.bodyColor = drawColor
			state.bodyMaterial = targetMaterial
		end
	else
		-- Cleanup Highlight
		local highlight = getgenv().DeltaChamsCache and getgenv().DeltaChamsCache[character]
		if highlight then
			highlight:Destroy()
			getgenv().DeltaChamsCache[character] = nil
		end

		-- Restore Original Body (Best Effort)
		local originalCache = getgenv().DeltaChamsOriginalCache and getgenv().DeltaChamsOriginalCache[character]
		if originalCache then
			for part, originalData in pairs(originalCache) do
				ESPManager.RestorePart(part, originalData)
			end
			getgenv().DeltaChamsOriginalCache[character] = nil
		end

		-- Clear State
		local stateToClear = getgenv().DeltaChamsStateCache[character]
		if stateToClear and stateToClear.connection then
			stateToClear.connection:Disconnect()
		end
		getgenv().DeltaChamsStateCache[character] = nil
	end
end

function ESPManager.RestorePart(part, originalData)
	if not part or not part.Parent then
		return
	end
	part.Material = originalData.Material
	part.Color = originalData.Color
	part.Transparency = originalData.Transparency

	if part:IsA("MeshPart") then
		if originalData.TextureID ~= nil then
			pcall(function()
				part.TextureID = originalData.TextureID
			end)
		end
		if originalData.UsePartColor ~= nil then
			pcall(function()
				part.UsePartColor = originalData.UsePartColor
			end)
		end
	end

	if originalData.SpecMeshes then
		for i = 1, #originalData.SpecMeshes do
			local data = originalData.SpecMeshes[i]
			if data.Mesh and data.Mesh.Parent then
				pcall(function()
					data.Mesh.TextureId = data.TextureId or ""
					data.Mesh.VertexColor = data.VertexColor or Vector3.new(1, 1, 1)
				end)
			end
		end
	end

	if originalData.Decals then
		for i = 1, #originalData.Decals do
			local data = originalData.Decals[i]
			if data.Decal and data.Decal.Parent then
				pcall(function()
					data.Decal.Transparency = data.Trans
				end)
			end
		end
	end
end

function ESPManager.Update()
	local config_sa = getgenv().Config.SilentAim
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
		for _, highlight in pairs(getgenv().DeltaChamsCache) do
			highlight:Destroy()
		end
		table.clear(getgenv().DeltaChamsCache)
		for _, originalCache in pairs(getgenv().DeltaChamsOriginalCache) do
			for part, originalData in pairs(originalCache) do
				ESPManager.RestorePart(part, originalData)
			end
		end
		table.clear(getgenv().DeltaChamsOriginalCache)
		for _, state in pairs(getgenv().DeltaChamsStateCache) do
			if type(state) == "table" and state.connection then
				state.connection:Disconnect()
			end
		end
		table.clear(getgenv().DeltaChamsStateCache)
		return
	end

	local activeCharacters = CharacterManager.GetActiveCharacters() or {}
	local activeNPCs = CharacterManager.GetNPCs() or {}
	local activeCorpses = config.CorpseESPEnabled and CharacterManager.GetCorpses() or {}
	local activeExits = config.ExitESPEnabled and CharacterManager.GetExits() or {}
	local activeHelicopterESP = CharacterManager.GetHelicopterESP() or {}

	-- Text ESP Cleanup
	for cachedCharacter, cacheData in pairs(ESPManager.Cache) do
		if
			not activeCharacters[cachedCharacter]
			and not activeNPCs[cachedCharacter]
			and not activeCorpses[cachedCharacter]
			and not activeExits[cachedCharacter]
			and not activeHelicopterESP[cachedCharacter]
		then
			ESPManager.RemoveDrawing(cachedCharacter)
		end
	end

	-- Highlight & Original Body Restoration
	for cachedCharacter, highlight in pairs(getgenv().DeltaChamsCache) do
		local isStale = not activeCharacters[cachedCharacter]
			and not activeNPCs[cachedCharacter]
			and not activeHelicopterESP[cachedCharacter]
		local shouldRemove = isStale or not config.ChamsEnabled

		if activeCharacters[cachedCharacter] and not config.Enabled then
			shouldRemove = true
		elseif activeNPCs[cachedCharacter] and not config.NPCESPEnabled then
			shouldRemove = true
		elseif activeHelicopterESP[cachedCharacter] and not config.HelicopterESPEnabled then
			shouldRemove = true
		end

		if shouldRemove then
			highlight:Destroy()
			getgenv().DeltaChamsCache[cachedCharacter] = nil

			local originalCache = getgenv().DeltaChamsOriginalCache[cachedCharacter]
			if originalCache then
				for part, originalData in pairs(originalCache) do
					ESPManager.RestorePart(part, originalData)
				end
				getgenv().DeltaChamsOriginalCache[cachedCharacter] = nil
			end

			local stateToClear = getgenv().DeltaChamsStateCache[cachedCharacter]
			if stateToClear and stateToClear.connection then
				stateToClear.connection:Disconnect()
			end
			getgenv().DeltaChamsStateCache[cachedCharacter] = nil
		end
	end

	local camPos = Camera.CFrame.Position
	local worldToViewportPoint = Camera.WorldToViewportPoint

	for character, data in pairs(activeCharacters) do
		DrawEntity(character, data, config, config_sa, camPos, worldToViewportPoint)
	end
	for character, data in pairs(activeNPCs) do
		DrawEntity(character, data, config, config_sa, camPos, worldToViewportPoint)
	end
	for character, data in pairs(activeCorpses) do
		DrawEntity(character, data, config, config_sa, camPos, worldToViewportPoint)
	end
	for character, data in pairs(activeExits) do
		DrawEntity(character, data, config, config_sa, camPos, worldToViewportPoint)
	end
	for character, data in pairs(activeHelicopterESP) do
		DrawEntity(character, data, config, config_sa, camPos, worldToViewportPoint)
	end
end

-- ==========================================
-- BulletTracerManager
-- ==========================================
local BulletTracerManager = {
	Tracers = getgenv().DeltaTracersCache or {},
	LastFlicker = 0,
	LastRawColor = nil,
	LastParsedColor = nil,
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

BulletTracerManager.InstanceCache = {
	Beams = {},
	Attachments = {},
	Parts = {},
}

function BulletTracerManager.GetAttachment()
	local cache = BulletTracerManager.InstanceCache.Attachments
	if #cache > 0 then
		return table.remove(cache)
	end
	return Instance.new("Attachment")
end

function BulletTracerManager.ReleaseAttachment(att)
	if not att then
		return
	end
	att.Parent = nil
	if #BulletTracerManager.InstanceCache.Attachments < 500 then
		table.insert(BulletTracerManager.InstanceCache.Attachments, att)
	else
		att:Destroy()
	end
end

function BulletTracerManager.GetBeam()
	local cache = BulletTracerManager.InstanceCache.Beams
	if #cache > 0 then
		return table.remove(cache)
	end
	return Instance.new("Beam")
end

function BulletTracerManager.ReleaseBeam(beam)
	if not beam then
		return
	end
	beam.Parent = nil
	if #BulletTracerManager.InstanceCache.Beams < 500 then
		table.insert(BulletTracerManager.InstanceCache.Beams, beam)
	else
		beam:Destroy()
	end
end

function BulletTracerManager.GetPart()
	local cache = BulletTracerManager.InstanceCache.Parts
	if #cache > 0 then
		return table.remove(cache)
	end
	return Instance.new("Part")
end

function BulletTracerManager.ReleasePart(part)
	if not part then
		return
	end
	part.Parent = nil
	if #BulletTracerManager.InstanceCache.Parts < 500 then
		table.insert(BulletTracerManager.InstanceCache.Parts, part)
	else
		part:Destroy()
	end
end

function BulletTracerManager.CreateFOVLayeredGlowBeam(a0, a1, cColor, cTrans)
	local glowBeams = {}
	for j = 1, 4 do
		local opacity = math.clamp(0.8 / (j ^ 1.2), 0.02, 0.8) * (1 - cTrans)
		local widthScale = 1 + (j * 0.4)

		local gb = BulletTracerManager.GetBeam()
		gb.Attachment0 = a0
		gb.Attachment1 = a1
		gb.FaceCamera = true
		gb.Color = ColorSequence.new(cColor)
		gb.Transparency = NumberSequence.new(1 - opacity)
		gb.Width0 = 0.2 * widthScale
		gb.Width1 = 0.2 * widthScale
		gb.LightEmission = 1
		gb.LightInfluence = 0
		gb.Parent = Workspace.Terrain
		table.insert(glowBeams, gb)
	end
	return glowBeams
end

function BulletTracerManager.CreateFOVLayeredGlowPart(basePart, segmentDist, cColor, cTrans)
	local glowParts = {}
	for j = 1, 4 do
		local opacity = math.clamp(0.8 / (j ^ 1.2), 0.02, 0.8) * (1 - cTrans)
		local widthScale = 1 + (j * 0.4)

		local glowPart = BulletTracerManager.GetPart()
		glowPart.Anchored = true
		glowPart.CanCollide = false
		glowPart.CanQuery = false
		glowPart.CastShadow = false
		glowPart.Material = Enum.Material.Neon
		glowPart.Shape = Enum.PartType.Cylinder
		local gWidth = 0.05 * widthScale
		glowPart.Size = Vector3.new(segmentDist, gWidth, gWidth)
		glowPart.Color = cColor
		glowPart.CFrame = basePart.CFrame
		glowPart.Transparency = 1 - opacity
		glowPart.Parent = Workspace.Terrain
		table.insert(glowParts, glowPart)
	end
	return glowParts
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

	local cColor = BulletTracerManager.ParseColor(config.TracerColor)
	local cTrans = config.TracerTransparency
	if type(cTrans) ~= "number" then
		cTrans = 0.5
	end

	local points = { origin }
	for i = 1, numSegments - 1 do
		local offset = direction * (distance * (i / numSegments))
		local randOffset = (right * (math.random() - 0.5) + up * (math.random() - 0.5)) * (distance * 0.1)
		table.insert(points, origin + offset + randOffset)
	end
	table.insert(points, hitPos)

	for i = 1, #points - 1 do
		local a0 = BulletTracerManager.GetAttachment()
		a0.WorldPosition = points[i]
		a0.Parent = Workspace.Terrain

		local a1 = BulletTracerManager.GetAttachment()
		a1.WorldPosition = points[i + 1]
		a1.Parent = Workspace.Terrain

		local beam = BulletTracerManager.GetBeam()
		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.FaceCamera = true
		beam.Color = ColorSequence.new(cColor)
		beam.Transparency = NumberSequence.new(math.clamp(cTrans - 0.3, 0, 1))
		beam.Width0 = 0.2
		beam.Width1 = 0.2
		beam.LightEmission = 1
		beam.LightInfluence = 0
		beam.Parent = Workspace.Terrain

		table.insert(strandInfo.Beams, { Beam = beam, A0 = a0, A1 = a1 })

		local glowBeams = {}
		if config.TracerGlowEffect then
			glowBeams = BulletTracerManager.CreateFOVLayeredGlowBeam(a0, a1, cColor, cTrans)
		end

		strandInfo.Beams[#strandInfo.Beams].Glows = glowBeams
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

	local cColor = BulletTracerManager.ParseColor(config.TracerColor)
	local cTrans = config.TracerTransparency
	if type(cTrans) ~= "number" then
		cTrans = 0.5
	end

	local points = { origin }
	for i = 1, numSegments - 1 do
		local offset = direction * (distance * (i / numSegments))
		local sign = (i % 2 == 0) and 1 or -1
		local spikeOffset = up * 1.5 * sign
		table.insert(points, origin + offset + spikeOffset)
	end
	table.insert(points, hitPos)

	for i = 1, #points - 1 do
		local a0 = BulletTracerManager.GetAttachment()
		a0.WorldPosition = points[i]
		a0.Parent = Workspace.Terrain

		local a1 = BulletTracerManager.GetAttachment()
		a1.WorldPosition = points[i + 1]
		a1.Parent = Workspace.Terrain

		local beam = BulletTracerManager.GetBeam()
		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.FaceCamera = true
		beam.Color = ColorSequence.new(cColor)
		beam.Transparency = NumberSequence.new(math.clamp(cTrans - 0.3, 0, 1))
		beam.Width0 = 0.2
		beam.Width1 = 0.2
		beam.LightEmission = 1
		beam.LightInfluence = 0
		beam.Parent = Workspace.Terrain

		table.insert(strandInfo.Beams, { Beam = beam, A0 = a0, A1 = a1 })

		local glowBeams = {}
		if config.TracerGlowEffect then
			glowBeams = BulletTracerManager.CreateFOVLayeredGlowBeam(a0, a1, cColor, cTrans)
		end

		strandInfo.Beams[#strandInfo.Beams].Glows = glowBeams
	end

	table.insert(BulletTracerManager.Tracers, strandInfo)
end

function BulletTracerManager.CreateRetroLaser(origin, hitPos, config)
	local distance = (hitPos - origin).Magnitude
	local direction = (hitPos - origin).Unit

	local segmentLength = 12
	local gapLength = 8
	local totalSpacing = segmentLength + gapLength
	local numSegments = math.min(30, math.ceil(distance / totalSpacing))

	if numSegments == 30 then
		totalSpacing = distance / numSegments
		segmentLength = totalSpacing * (12 / 20)
	end

	local cColor = BulletTracerManager.ParseColor(config.TracerColor)
	local cTrans = config.TracerTransparency
	if type(cTrans) ~= "number" then
		cTrans = 0.5
	end

	local beams = {}

	for i = 1, numSegments do
		local a0 = BulletTracerManager.GetAttachment()
		a0.Parent = Workspace.Terrain

		local a1 = BulletTracerManager.GetAttachment()
		a1.Parent = Workspace.Terrain

		local beam = BulletTracerManager.GetBeam()
		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.FaceCamera = true
		beam.Color = ColorSequence.new(cColor)
		beam.Transparency = NumberSequence.new(math.clamp(cTrans - 0.3, 0, 1))
		beam.Width0 = 0.8
		beam.Width1 = 0.8
		beam.LightEmission = 1
		beam.LightInfluence = 0
		beam.Parent = Workspace.Terrain

		local glowBeams = {}
		if config.TracerGlowEffect then
			glowBeams = BulletTracerManager.CreateFOVLayeredGlowBeam(a0, a1, cColor, cTrans)
		end

		table.insert(beams, { Beam = beam, Glows = glowBeams, A0 = a0, A1 = a1, BaseIndex = i - 1 })
	end

	table.insert(BulletTracerManager.Tracers, {
		IsRetroLaser = true,
		Origin = origin,
		HitPos = hitPos,
		Direction = direction,
		Distance = distance,
		SegmentLength = segmentLength,
		TotalSpacing = totalSpacing,
		Beams = beams,
		CreationTime = os.clock(),
		ExpireTime = os.clock() + 2,
	})
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
	elseif config.TracerType == "Retro Laser" then
		BulletTracerManager.CreateRetroLaser(origin, hitPos, config)
	else
		local dist = (hitPos - origin).Magnitude
		local numParts = math.ceil(dist / 1000)
		local segmentDist = dist / numParts
		local cTrans = config.TracerTransparency
		if type(cTrans) ~= "number" then
			cTrans = 0.5
		end

		local partsTable = {}
		local glowPartsTable = {}

		local cColor = BulletTracerManager.ParseColor(config.TracerColor)

		for i = 1, numParts do
			local offset = segmentDist * (i - 0.5)
			local tracerPart = BulletTracerManager.GetPart()
			tracerPart.Anchored = true
			tracerPart.CanCollide = false
			tracerPart.CanQuery = false
			tracerPart.CastShadow = false
			tracerPart.Material = Enum.Material.Neon
			tracerPart.Shape = Enum.PartType.Cylinder
			tracerPart.Size = Vector3.new(segmentDist, 0.05, 0.05)
			tracerPart.CFrame = CFrame.lookAt(origin, hitPos)
				* CFrame.new(0, 0, -offset)
				* CFrame.Angles(0, math.pi / 2, 0)
			tracerPart.Color = cColor
			tracerPart.Transparency = math.clamp(cTrans - 0.3, 0, 1)
			tracerPart.Parent = Workspace.Terrain
			table.insert(partsTable, tracerPart)

			if config.TracerGlowEffect then
				local glowParts = BulletTracerManager.CreateFOVLayeredGlowPart(tracerPart, segmentDist, cColor, cTrans)
				for _, gp in ipairs(glowParts) do
					table.insert(glowPartsTable, gp)
				end
			end
		end

		table.insert(BulletTracerManager.Tracers, {
			Parts = partsTable,
			GlowParts = glowPartsTable,
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

	if BulletTracerManager.LastRawColor ~= config.TracerColor then
		BulletTracerManager.LastRawColor = config.TracerColor
		BulletTracerManager.LastParsedColor = BulletTracerManager.ParseColor(config.TracerColor)
	end
	local cColor = BulletTracerManager.LastParsedColor or Color3.fromRGB(255, 255, 255)

	local cTrans = config.TracerTransparency
	if type(cTrans) ~= "number" then
		cTrans = 0.5
	end
	local cachedColor = ColorSequence.new(cColor)
	local cachedTransparency = NumberSequence.new(math.clamp(cTrans - 0.3, 0, 1))
	local glowTransparency = NumberSequence.new(math.clamp(cTrans + 0.2, 0, 1))
	local partTransparency = math.clamp(cTrans - 0.3, 0, 1)

	for i = #BulletTracerManager.Tracers, 1, -1 do
		local tracer = BulletTracerManager.Tracers[i]
		if now > tracer.ExpireTime or not config.BulletTracers then
			if tracer.Beam then
				BulletTracerManager.ReleaseBeam(tracer.Beam)
			end
			if tracer.GlowBeam then
				BulletTracerManager.ReleaseBeam(tracer.GlowBeam)
			end
			if tracer.Parts then
				for _, p in ipairs(tracer.Parts) do
					BulletTracerManager.ReleasePart(p)
				end
			end
			if tracer.GlowParts then
				for _, gp in ipairs(tracer.GlowParts) do
					BulletTracerManager.ReleasePart(gp)
				end
			end
			if tracer.A0 then
				BulletTracerManager.ReleaseAttachment(tracer.A0)
			end
			if tracer.A1 then
				BulletTracerManager.ReleaseAttachment(tracer.A1)
			end
			if tracer.Beams then
				for _, b in pairs(tracer.Beams) do
					if b.Beam then
						BulletTracerManager.ReleaseBeam(b.Beam)
					end
					if b.Glow then
						BulletTracerManager.ReleaseBeam(b.Glow)
					end
					if b.Glows then
						for _, gb in ipairs(b.Glows) do
							BulletTracerManager.ReleaseBeam(gb)
						end
					end
					if b.A0 then
						BulletTracerManager.ReleaseAttachment(b.A0)
					end
					if b.A1 then
						BulletTracerManager.ReleaseAttachment(b.A1)
					end
				end
			end
			if tracer.Segments then
				for _, seg in ipairs(tracer.Segments) do
					if seg.Part then
						BulletTracerManager.ReleasePart(seg.Part)
					end
					if seg.Glow then
						BulletTracerManager.ReleaseBeam(seg.Glow)
					end
				end
			end
			table.remove(BulletTracerManager.Tracers, i)
		else
			local colorChanged = (tracer.LastColor ~= cColor)
			local transChanged = (tracer.LastTrans ~= cTrans)

			if colorChanged or transChanged then
				tracer.LastColor = cColor
				tracer.LastTrans = cTrans

				if tracer.Beam and not tracer.IsLightning then
					tracer.Beam.Color = cachedColor
					tracer.Beam.Transparency = cachedTransparency
				end
				if tracer.Parts then
					for _, p in ipairs(tracer.Parts) do
						p.Color = cColor
						p.Transparency = partTransparency
					end
				end
				if tracer.GlowBeam then
					tracer.GlowBeam.Color = cachedColor
					tracer.GlowBeam.Transparency = glowTransparency
				end
				if tracer.GlowParts then
					for _, gp in ipairs(tracer.GlowParts) do
						gp.Color = cColor
					end
				end
				if tracer.Beams then
					for _, b in pairs(tracer.Beams) do
						if not tracer.IsLightning and b.Beam then
							b.Beam.Color = cachedColor
							b.Beam.Transparency = cachedTransparency
						end
						if b.Glows then
							for j, gb in ipairs(b.Glows) do
								gb.Color = cachedColor
								local opacity = math.clamp(0.8 / (j ^ 1.2), 0.02, 0.8) * (1 - cTrans)
								gb.Transparency = NumberSequence.new(1 - opacity)
							end
						end
					end
				end
			end

			if tracer.IsLightning and tracer.Beams and shouldFlicker then
				local flicker = math.random() * 0.3
				local flickerTransparency = NumberSequence.new(math.clamp(flicker, 0, 1))
				for _, b in pairs(tracer.Beams) do
					if b.Beam then
						b.Beam.Color = cachedColor
						b.Beam.Transparency = flickerTransparency
					end
				end
			end

			if tracer.IsRetroLaser and tracer.Beams then
				local scrollSpeed = 200
				local offsetDist = (now - tracer.CreationTime) * scrollSpeed

				for _, b in ipairs(tracer.Beams) do
					local currentDist = (offsetDist + (b.BaseIndex * tracer.TotalSpacing)) % tracer.Distance

					local actualLength = tracer.SegmentLength
					if currentDist + actualLength > tracer.Distance then
						actualLength = math.max(0.01, tracer.Distance - currentDist)
					end

					local pos0 = tracer.Origin + tracer.Direction * currentDist
					local pos1 = tracer.Origin + tracer.Direction * (currentDist + actualLength)

					if b.A0 and b.A1 then
						b.A0.WorldPosition = pos0
						b.A1.WorldPosition = pos1
					end

					if colorChanged or transChanged then
						if b.Beam then
							b.Beam.Color = cachedColor
							b.Beam.Transparency = cachedTransparency
						end
						if b.Glow then
							b.Glow.Color = cachedColor
							b.Glow.Transparency = glowTransparency
						end
						if b.Glows then
							for j, gb in ipairs(b.Glows) do
								gb.Color = cachedColor
								local opacity = math.clamp(0.8 / (j ^ 1.2), 0.02, 0.8) * (1 - cTrans)
								gb.Transparency = NumberSequence.new(1 - opacity)
							end
						end
					end
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
				local target = nil
				if getgenv()._AutopilotTargetOverride and getgenv()._DeltaIsAutoHolding then
					target = getgenv()._AutopilotTargetOverride
				else
					target = TargetManager and TargetManager.CurrentTarget
				end

				if getgenv().Config.SilentAim.Enabled and target then
					local targetPartName = getgenv().Config.SilentAim.TargetPart or "Head"
					local targetAimPart = (target.Character and target.Character:FindFirstChild(targetPartName))
						or target.Head
					local targetRoot = target.RootPart
						or (target.Character and target.Character:FindFirstChild("HumanoidRootPart"))
						or targetAimPart

					local ammoName = type(args[7]) == "string" and args[7] or ""
					getgenv().LastFiredAmmoName = ammoName
					local muzzleVelocity = (getgenv().DeltaVelocityCache and getgenv().DeltaVelocityCache[ammoName])
						or 3000

					local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
					local wasCrouching = false
					local isUnderground = getgenv().Config.Combat.UndergroundDesync
						and getgenv()._StoredRealCFrame
						and not getgenv()._TPKillActive

					if isUnderground and humanoid then
						wasCrouching = humanoid:GetAttribute("Crouch") or false
						if not wasCrouching then
							humanoid:SetAttribute("Crouch", true)
						end
					end

					local origin = Camera.CFrame.Position
					if not getgenv().CachedFunctionLibraryExtension then
						pcall(function()
							getgenv().CachedFunctionLibraryExtension = require(
								ReplicatedStorage:WaitForChild("Modules", 2):WaitForChild("FunctionLibraryExtension", 2)
							)
						end)
					end
					if getgenv().CachedFunctionLibraryExtension then
						pcall(function()
							origin = getgenv().CachedFunctionLibraryExtension:GetEstimatedCameraPosition(LocalPlayer)
						end)
					end

					if isUnderground and humanoid and not wasCrouching then
						humanoid:SetAttribute("Crouch", false)
					end

					local realOrigin = origin

					if getgenv().Config.Combat.OriginManipulation then
						local found_origin = getgenv().CharacterManager
							and getgenv().CharacterManager.GetManipulatedOrigin
							and getgenv().CharacterManager.GetManipulatedOrigin(
								realOrigin,
								targetAimPart.Position,
								targetRoot,
								isUnderground
							)

						if found_origin then
							origin = found_origin
							realOrigin = found_origin
						end
					end

					local serverOrigin = realOrigin
					if getgenv()._TPKillActive and getgenv()._TPKillPos then
						local basePos = getgenv()._TPKillPos
						serverOrigin =
							getgenv().CachedFunctionLibraryExtension:GetEstimatedCameraPosition(LocalPlayer, basePos)
					elseif isUnderground then
						local localOffset = getgenv()._StoredRealCFrame:PointToObjectSpace(realOrigin)
						local undergroundDesyncOffset = CFrame.new(0, -3.8, 0) * CFrame.Angles(math.rad(-90), 0, 0)
						local undergroundHRP_CFrame = getgenv()._StoredRealCFrame * undergroundDesyncOffset
						serverOrigin = undergroundHRP_CFrame:PointToWorldSpace(localOffset)
					end

					local aimPos

					if getgenv().Config.Combat.InstantHit and not getgenv()._TPKillActive then
						aimPos = targetAimPart.Position
						TargetManager.PredictedPosition = aimPos
						local perfectDir = (aimPos - realOrigin).Unit
						origin = aimPos - perfectDir * 0.5
					else
						local targetVelocity = targetRoot.AssemblyLinearVelocity
						local v = muzzleVelocity
						local G = 70

						-- Exact quadratic formula solver for projectile motion
						local timeToHit = (targetAimPart.Position - serverOrigin).Magnitude / v
						for i = 1, 3 do
							local targetPos = targetAimPart.Position + targetVelocity * timeToHit
							local A = targetPos - serverOrigin
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
						aimPos = finalPredictedPos + Vector3.new(0, finalDrop, 0)
						TargetManager.PredictedPosition = finalPredictedPos
					end

					local serverAimDirection = (aimPos - serverOrigin).Unit
					local clientAimDirection = (aimPos - origin).Unit
					getgenv().LastServerAimDirection = serverAimDirection

					local trueMuzzleOrigin = realOrigin
					if type(args[5]) == "table" and args[5].CFrame then
						trueMuzzleOrigin = args[5].CFrame.Position
					elseif typeof(args[5]) == "CFrame" then
						trueMuzzleOrigin = args[5].Position
					end

					local viewmodelOffset = Vector3.new(
						getgenv().Config.ESP.ViewmodelOffsetX or 0,
						getgenv().Config.ESP.ViewmodelOffsetY or 0,
						getgenv().Config.ESP.ViewmodelOffsetZ or 0
					)
					trueMuzzleOrigin = trueMuzzleOrigin + Camera.CFrame:VectorToWorldSpace(viewmodelOffset)

					local aimCFrame = CFrame.lookAt(origin, origin + clientAimDirection * 100)
					if typeof(args[5]) == "Instance" then
						args[5] = { CFrame = aimCFrame }
					elseif type(args[5]) == "table" then
						args[5].CFrame = aimCFrame
					else
						args[5] = { CFrame = aimCFrame }
					end

					if getgenv().Config.SilentAim.BulletTracers then
						BulletTracerManager.AddTracer(trueMuzzleOrigin, TargetManager.PredictedPosition)
					end
				else
					if getgenv().Config.Combat.NoRecoil then
						local origin = workspace.CurrentCamera.CFrame.Position
						local lookVector = workspace.CurrentCamera.CFrame.LookVector
						local aimCFrame = CFrame.lookAt(origin, origin + lookVector * 1000)
						if typeof(args[5]) == "Instance" then
							args[5] = { CFrame = aimCFrame }
						elseif type(args[5]) == "table" then
							args[5].CFrame = aimCFrame
						else
							args[5] = { CFrame = aimCFrame }
						end
					end
					if getgenv().Config.SilentAim.BulletTracers then
						if not getgenv().CachedFunctionLibraryExtension then
							pcall(function()
								getgenv().CachedFunctionLibraryExtension = require(
									ReplicatedStorage:WaitForChild("Modules", 2)
										:WaitForChild("FunctionLibraryExtension", 2)
								)
							end)
						end
						local origin = Camera.CFrame.Position
						if getgenv().CachedFunctionLibraryExtension then
							pcall(function()
								origin =
									getgenv().CachedFunctionLibraryExtension:GetEstimatedCameraPosition(LocalPlayer)
							end)
						end

						local trueMuzzleOrigin = origin
						if type(args[5]) == "table" and args[5].CFrame then
							trueMuzzleOrigin = args[5].CFrame.Position
						elseif typeof(args[5]) == "CFrame" then
							trueMuzzleOrigin = args[5].Position
						end

						local viewmodelOffset = Vector3.new(
							getgenv().Config.ESP.ViewmodelOffsetX or 0,
							getgenv().Config.ESP.ViewmodelOffsetY or 0,
							getgenv().Config.ESP.ViewmodelOffsetZ or 0
						)
						trueMuzzleOrigin = trueMuzzleOrigin + Camera.CFrame:VectorToWorldSpace(viewmodelOffset)

						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Exclude
						params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
						local result = Workspace:Raycast(origin, Camera.CFrame.LookVector * 5000, params)
						local hitPos = result and result.Position or (origin + Camera.CFrame.LookVector * 5000)
						BulletTracerManager.AddTracer(trueMuzzleOrigin, hitPos)
					end
				end

				local rets = table.pack(oldCreateBullet(table.unpack(args, 1, args.n)))
				return table.unpack(rets, 1, rets.n)
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
			if springHooked and fpsHooked then
				break
			end
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
									getgenv()._DeltaActiveWeaponTable = self

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

											if getgenv().UpdateWeaponSwayAndBob then
												getgenv().UpdateWeaponSwayAndBob()
											end
										end

										if not rawget(self, "OrigReloadLength") and rawget(self, "ReloadLength") then
											rawset(self, "OrigReloadLength", self.ReloadLength)
										end
										if
											not rawget(self, "OrigReloadChamberLength")
											and rawget(self, "ReloadChamberLength")
										then
											rawset(self, "OrigReloadChamberLength", self.ReloadChamberLength)
										end
										if
											not rawget(self, "OrigReloadNoMagLength")
											and rawget(self, "ReloadNoMagLength")
										then
											rawset(self, "OrigReloadNoMagLength", self.ReloadNoMagLength)
										end
										if not rawget(self, "OrigEquipTValue") and rawget(self, "EquipTValue") then
											rawset(self, "OrigEquipTValue", self.EquipTValue)
										end

										if getgenv().Config.Combat.InstantEquip then
											if rawget(self, "EquipTValue") then
												self.EquipTValue = 0
											end
											if
												type(rawget(self, "settings")) == "table"
												and rawget(self.settings, "EquipTValue")
											then
												self.settings.EquipTValue = 0
											end
										else
											if rawget(self, "OrigEquipTValue") then
												self.EquipTValue = self.OrigEquipTValue
											end
											if
												type(rawget(self, "settings")) == "table"
												and rawget(self.settings, "EquipTValue")
												and rawget(self, "OrigEquipTValue")
											then
												self.settings.EquipTValue = self.OrigEquipTValue
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

							if not rawget(v, "OrigReloadLength") and rawget(v, "ReloadLength") then
								rawset(v, "OrigReloadLength", v.ReloadLength)
							end
							if not rawget(v, "OrigReloadChamberLength") and rawget(v, "ReloadChamberLength") then
								rawset(v, "OrigReloadChamberLength", v.ReloadChamberLength)
							end
							if not rawget(v, "OrigReloadNoMagLength") and rawget(v, "ReloadNoMagLength") then
								rawset(v, "OrigReloadNoMagLength", v.ReloadNoMagLength)
							end
							if not rawget(v, "OrigEquipTValue") and rawget(v, "EquipTValue") then
								rawset(v, "OrigEquipTValue", v.EquipTValue)
							end

							if getgenv().Config.Combat.InstantEquip then
								if rawget(v, "EquipTValue") then
									v.EquipTValue = 0
								end
								if type(rawget(v, "settings")) == "table" and rawget(v.settings, "EquipTValue") then
									v.settings.EquipTValue = 0
								end
							else
								if rawget(v, "OrigEquipTValue") then
									v.EquipTValue = v.OrigEquipTValue
								end
								if
									type(rawget(v, "settings")) == "table"
									and rawget(v.settings, "EquipTValue")
									and rawget(v, "OrigEquipTValue")
								then
									v.settings.EquipTValue = v.OrigEquipTValue
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

getgenv().NativeHitSoundIds = {}
pcall(function()
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
			getgenv().NativeHitSoundIds[current.SoundId] = true
		end
	end

	-- Additional known native hitsound IDs from trace
	getgenv().NativeHitSoundIds["rbxassetid://4581679226"] = true
	getgenv().NativeHitSoundIds["rbxassetid://4581679458"] = true
	getgenv().NativeHitSoundIds["rbxassetid://4581643869"] = true
	getgenv().NativeHitSoundIds["rbxassetid://4581728529"] = true
end)

getgenv().DeltaNamecallHook = newcclosure(function(self, ...)
	local oldNamecall = getgenv().OriginalNamecall
	local method = getnamecallmethod()
	local args = { ... }

	if getgenv()._TPKillActive and (method == "FireServer" or method == "InvokeServer") then
		local selfName = typeof(self) == "Instance" and self.Name or tostring(self)

		local argStr = ""
		for i, v in ipairs(args) do
			local argVal = tostring(v)
			if typeof(v) == "Instance" then
				argVal = v.GetFullName and v:GetFullName() or v.Name
			end
			argStr = argStr .. type(v) .. "(" .. argVal .. ")"
			if i < #args then
				argStr = argStr .. ", "
			end
		end

		local logMsg = string.format("[TPKILL SPY] %s: %s | Args: %s", method, selfName, argStr)
		print(logMsg)
		if getgenv().AddLog then
			getgenv().AddLog(logMsg)
		end
	end

	if method == "Play" and typeof(self) == "Instance" and self:IsA("AnimationTrack") then
		local w = getgenv()._DeltaActiveWeaponTable
		if w and type(w) == "table" and type(rawget(w, "clientAnimationTracks")) == "table" then
			if getgenv().Config and getgenv().Config.Combat then
				if getgenv().Config.Combat.InstantEquip then
					if self == w.clientAnimationTracks.Equip then
						local ret = oldNamecall(self, ...)
						self:AdjustSpeed(99999)
						return ret
					end
				end
			end
		end
	end

	if method == "GetAttribute" and typeof(self) == "Instance" then
		if getgenv().Config and getgenv().Config.Combat then
			if getgenv().Config.Combat.InstantEquip then
				if args[1] == "EquipTValue" then
					return 0
				end
			end
		end
	end

	if method == "TakeDamage" and typeof(self) == "Instance" and self:IsA("Humanoid") then
		local lp = game:GetService("Players").LocalPlayer
		if lp and lp.Character and self:IsDescendantOf(lp.Character) then
			if getgenv().Config and getgenv().Config.Mods and getgenv().Config.Mods.NoFallDamage then
				return
			end
		end
	end

	if method == "FireServer" then
		local selfName = typeof(self) == "Instance" and self.Name or ""

		if selfName == "UpdateCrouch" then
			if not checkcaller() and not getgenv()._IsScriptCrouch then
				local isCrouching = args[1]

				-- BLOCK uncrouch packets while UGR is active to maintain our persistent crouch state.
				-- The game's native character controller constantly tries to uncrouch the player
				-- when they walk/jump, which overwrites our persistent crouch and ruins hit registration.
				local isUnderground = getgenv().Config.Combat.UndergroundDesync or getgenv()._UndergroundResolverActive
				if isUnderground and not isCrouching then
					return
				end
			end
		end

		if selfName == "ProjectileInflict" or selfName == "MeleeInflict" or selfName == "MeleeInfIict" then
			getgenv().LastDamageInflictedTime = tick()

			if
				getgenv().Config
				and getgenv().Config.Mods
				and (getgenv().Config.Mods.Hitsound or getgenv().Config.Mods.HitEffects)
			then
				local targetPart = args[1]
				if targetPart and typeof(targetPart) == "Instance" then
					local character = targetPart:FindFirstAncestorOfClass("Model")
					if character then
						local root = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart") or character
						local function getHealth()
							if not character or not character.Parent then
								return 0
							end
							if root then
								local h = root:GetAttribute("Health")
								if h then
									return h
								end
							end
							local hum = character:FindFirstChildOfClass("Humanoid")
							if hum then
								return hum.Health
							end
							return 100
						end

						local hitPos = targetPart:IsA("BasePart") and targetPart.Position or Vector3.new()

						getgenv().RecentHits = getgenv().RecentHits or {}
						getgenv().MonitoredCharacters = getgenv().MonitoredCharacters or {}

						local recentHits = getgenv().RecentHits
						local monitoredChars = getgenv().MonitoredCharacters
						local genv = getgenv()

						recentHits[character] = { time = os.clock(), part = targetPart, pos = hitPos }

						if not monitoredChars[character] then
							monitoredChars[character] = true
							task.spawn(function()
								local lastHealth = getHealth()
								while character and character.Parent and lastHealth > 0 do
									task.wait(0.05)
									local currentHealth = getHealth()

									if currentHealth < lastHealth then
										local damageDealt = math.floor(lastHealth - currentHealth)
										lastHealth = currentHealth

										local hitData = recentHits[character]
										if hitData and (os.clock() - hitData.time) < 1.0 then
											local isKill = (currentHealth <= 0)
											local now = os.clock()

											if
												not genv.LastCustomHitsound
												or (now - genv.LastCustomHitsound) > 0.05
											then
												genv.LastCustomHitsound = now
												if genv.HitsoundManager and genv.HitsoundManager.Play then
													genv.HitsoundManager.Play()
												end
												if genv.HitEffectManager and genv.HitEffectManager.Play then
													genv.HitEffectManager.Play(
														hitData.part,
														hitData.pos,
														damageDealt,
														isKill
													)
												end
											elseif isKill then
												if genv.HitEffectManager and genv.HitEffectManager.Play then
													genv.HitEffectManager.Play(
														hitData.part,
														hitData.pos,
														damageDealt,
														true
													)
												end
											end

											if isKill then
												recentHits[character] = nil
												break
											end
										end
									elseif currentHealth > lastHealth then
										lastHealth = currentHealth
									end
								end

								local hitData = recentHits[character]
								if hitData and (os.clock() - hitData.time) < 1.0 then
									local now = os.clock()
									if not genv.LastCustomHitsound or (now - genv.LastCustomHitsound) > 0.05 then
										genv.LastCustomHitsound = now
										if genv.HitsoundManager and genv.HitsoundManager.Play then
											genv.HitsoundManager.Play()
										end
									end
									if genv.HitEffectManager and genv.HitEffectManager.Play then
										genv.HitEffectManager.Play(hitData.part, hitData.pos, 100, true)
									end
								end

								monitoredChars[character] = nil
								recentHits[character] = nil
							end)
						end
					end
				end
			end
		end
	end

	if method == "PlayLocalSound" then
		if typeof(self) == "Instance" and self:IsA("SoundService") then
			local sound = args[1]
			if sound and typeof(sound) == "Instance" and sound:IsA("Sound") then
				if getgenv().NativeHitSoundIds and getgenv().NativeHitSoundIds[sound.SoundId] then
					if getgenv().Config and getgenv().Config.Mods and getgenv().Config.Mods.Hitsound then
						sound.Volume = 0
						return -- Completely suppress the native hitsound by blocking the PlayLocalSound call
					end
				end
			end
		end
	end

	if method == "Play" then
		if typeof(self) == "Instance" and self:IsA("Sound") then
			if getgenv().NativeHitSoundIds and getgenv().NativeHitSoundIds[self.SoundId] then
				if getgenv().Config and getgenv().Config.Mods and getgenv().Config.Mods.Hitsound then
					self.Volume = 0
					return -- Completely suppress the native hitsound by blocking the Play call
				end
			end
		end

		if typeof(self) == "Instance" and self:IsA("AnimationTrack") then
			local name = self.Name or ""
			local lowerName = string.lower(name)

			if getgenv().Config and getgenv().Config.Combat and getgenv().Config.Combat.UndergroundDesync then
				if
					string.find(lowerName, "crouch")
					or string.find(lowerName, "walk")
					or string.find(lowerName, "run")
				then
					return
				end
			end

			if getgenv().Config and getgenv().Config.Combat and getgenv().Config.Combat.NoSway then
				if
					string.find(lowerName, "walk")
					or string.find(lowerName, "run")
					or string.find(lowerName, "sprint")
				then
					setnamecallmethod(method)
					local ret = getgenv().OriginalNamecall(self, ...)
					task.spawn(function()
						pcall(function()
							self:AdjustWeight(0.001)
						end)
					end)
					return ret
				end
			end

			if getgenv().TemporaryNoRecoil then
				if string.match(name, "UseAiming$") or string.match(name, "Use$") or string.match(name, "UseAlt$") then
					getgenv().IsFiring = true
					task.delay(0.15, function()
						getgenv().IsFiring = false
					end)

					setnamecallmethod(method)
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

		if getgenv().Config.Combat.InstantHit then
			if lowerAttr == "muzzlevelocity" then
				return 1000000
			end
		end

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
								min = min or 0
								max = max or 1
								return (min + max) / 2 -- Always perfectly centered
							end
						elseif key == "NextInteger" then
							return function(_, min, max)
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

local cachedSettingsModules = {}
local function scanForModules(root, shouldLog)
	if not root then
		return
	end
	for _, desc in ipairs(root:GetDescendants()) do
		if desc:IsA("ModuleScript") and desc.Name == "SettingsModule" and desc.Parent then
			if not cachedSettingsModules[desc] then
				cachedSettingsModules[desc] = true
			end
		end
	end
end

-- Scan ItemsList once at startup to avoid expensive GetDescendants() calls every second
local ItemsList = ReplicatedStorage:FindFirstChild("Itemslist") or ReplicatedStorage:FindFirstChild("ItemsList")
scanForModules(ItemsList, false)

table.insert(
	ThreadList,
	task.spawn(function()
		while task.wait(1) do
			-- Only dynamically scan smaller roots (Camera and Character)
			scanForModules(Workspace.CurrentCamera, true)
			if LocalPlayer and LocalPlayer.Character then
				scanForModules(LocalPlayer.Character, true)
			end

			for desc in pairs(cachedSettingsModules) do
				if not desc.Parent then
					cachedSettingsModules[desc] = nil
					continue
				end

				local success, stats = pcall(require, desc)

				if success and type(stats) == "table" and stats.FireRate then
					if not originalFireRates[desc] then
						originalFireRates[desc] = stats.FireRate
					end
					if stats.FireModes and not originalFireModes[desc] then
						originalFireModes[desc] = table.clone(stats.FireModes)
					end
					if stats.FireMode and not originalCurrentFireMode[desc] then
						originalCurrentFireMode[desc] = stats.FireMode
					end

					if getgenv().Config.Combat.RapidFire then
						local multiplier = getgenv().Config.Combat.RapidFireValue or 3
						local newRate = originalFireRates[desc] / multiplier

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
						if stats.FireRate ~= originalFireRates[desc] then
							stats.FireRate = originalFireRates[desc]
							-- ==========================================
							-- InventoryViewer Manager
							-- ==========================================
						end

						if originalFireModes[desc] and stats.FireModes then
							table.clear(stats.FireModes)
							for _, mode in ipairs(originalFireModes[desc]) do
								table.insert(stats.FireModes, mode)
							end
						end
						if originalCurrentFireMode[desc] and stats.FireMode then
							stats.FireMode = originalCurrentFireMode[desc]
						end
					end
				end
			end
		end
	end)
)

if not getgenv()._deltaDamageHooksApplied then
	getgenv()._deltaDamageHooksApplied = true

	local oldNewindex
	oldNewindex = hookmetamethod(game, "__newindex", function(self, index, value)
		if index == "Health" and self:IsA("Humanoid") then
			local lp = game:GetService("Players").LocalPlayer
			if lp and lp.Character and self:IsDescendantOf(lp.Character) then
				if getgenv().Config and getgenv().Config.Mods and getgenv().Config.Mods.NoFallDamage then
					if type(value) == "number" and value < self.Health then
						return
					end
				end
			end
		end

		return oldNewindex(self, index, value)
	end)
end

local function TriggerNoFallDamageRobust(hrp, humanoid)
	if getgenv()._noFallDamageTaskActive == hrp then
		return
	end
	getgenv()._noFallDamageTaskActive = hrp

	task.spawn(function()
		pcall(function()
			if humanoid then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
				humanoid:ChangeState(Enum.HumanoidStateType.Running)

				while hrp and hrp.Parent and humanoid and humanoid.Parent and getgenv().Config.Mods.NoFallDamage do
					if hrp.Velocity.Y > -2 then
						task.wait(0.15)
						if hrp and hrp.Parent and hrp.Velocity.Y > -2 then
							break
						end
					end
					task.wait(0.05)
				end

				if humanoid and humanoid.Parent then
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
				end
			end
		end)

		if getgenv()._noFallDamageTaskActive == hrp then
			getgenv()._noFallDamageTaskActive = nil
		end
	end)
end

local WeatherParticleManager = {
	Part = nil,
	Emitter = nil,
	CurrentWeather = "None",
	ActiveLeaves = {},
	LeafPool = {},
	CachedEmitters = nil :: any,
	LastLeafSpawn = 0,
	LastLeafUpdate = 0,
}

function WeatherParticleManager.Init()
	local Lighting = safeGetService("Lighting")
	local weatherStatus = Lighting:FindFirstChild("WeatherStatus")
	WeatherParticleManager.WeatherEffects = weatherStatus and weatherStatus:FindFirstChild("WeatherEffects")

	local noCollision = Workspace:FindFirstChild("NoCollision")
	WeatherParticleManager.WeatherEffectArea = noCollision and noCollision:FindFirstChild("WeatherEffectArea")

	if WeatherParticleManager.WeatherEffectArea then
		WeatherParticleManager.TopAttachment =
			WeatherParticleManager.WeatherEffectArea:FindFirstChild("TopEffectAttachment")
	end

	if WeatherParticleManager.TopAttachment and WeatherParticleManager.TopAttachment:FindFirstChild("HeavySnow") then
		local hs = WeatherParticleManager.TopAttachment.HeavySnow
		WeatherParticleManager.OriginalHeavySnow = {
			Texture = hs.Texture,
			Color = hs.Color,
			Size = hs.Size,
			Transparency = hs.Transparency,
		}
	end

	if not WeatherParticleManager.CachedEmitters then
		WeatherParticleManager.CachedEmitters = {}
		if WeatherParticleManager.WeatherEffects and WeatherParticleManager.TopAttachment then
			for _, effectName in ipairs({ "HeavyRain", "LightRain", "HeavySnow", "LightSnow" }) do
				local folder = WeatherParticleManager.WeatherEffects:FindFirstChild(effectName)
				local emitter = WeatherParticleManager.TopAttachment:FindFirstChild(effectName)
				if folder and folder:FindFirstChild("Rate") and folder:FindFirstChild("Speed") and emitter then
					local backgroundEmitter =
						WeatherParticleManager.WeatherEffectArea:FindFirstChild(effectName .. "_Background")
					if not backgroundEmitter then
						backgroundEmitter = emitter:Clone()
						backgroundEmitter.Name = effectName .. "_Background"
						backgroundEmitter.Parent = WeatherParticleManager.WeatherEffectArea
					end
					WeatherParticleManager.CachedEmitters[effectName] = {
						folder = folder,
						emitter = emitter,
						backgroundEmitter = backgroundEmitter,
					}
				end
			end
		end
	end

	WeatherParticleManager.Initialized = true
end

function WeatherParticleManager.Apply(weatherType)
	if not WeatherParticleManager.Initialized then
		WeatherParticleManager.Init()
	end

	WeatherParticleManager.CurrentWeather = weatherType

	if
		WeatherParticleManager.TopAttachment
		and WeatherParticleManager.TopAttachment:FindFirstChild("HeavySnow")
		and WeatherParticleManager.OriginalHeavySnow
	then
		local hs = WeatherParticleManager.TopAttachment.HeavySnow
		if weatherType == "Snow" then
			hs.Texture = WeatherParticleManager.OriginalHeavySnow.Texture
			hs.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			hs.Size = NumberSequence.new(0.5, 0.8)
		else
			hs.Texture = WeatherParticleManager.OriginalHeavySnow.Texture
			hs.Color = WeatherParticleManager.OriginalHeavySnow.Color
			hs.Size = WeatherParticleManager.OriginalHeavySnow.Size
			hs.Transparency = WeatherParticleManager.OriginalHeavySnow.Transparency
		end
	end
end

function WeatherParticleManager.Update()
	if not WeatherParticleManager.Initialized then
		return
	end
	if not WeatherParticleManager.WeatherEffects then
		return
	end

	if WeatherParticleManager.WeatherEffectArea and WeatherParticleManager.WeatherEffectArea.Size.X ~= 600 then
		WeatherParticleManager.WeatherEffectArea.Size = Vector3.new(600, 1, 600)
		WeatherParticleManager.WeatherEffectArea.Transparency = 1
	end

	local currentTick = tick()
	local dt = currentTick - WeatherParticleManager.LastLeafUpdate
	WeatherParticleManager.LastLeafUpdate = currentTick

	local math_random = math.random
	local cframe_new = CFrame.new
	local cframe_angles = CFrame.Angles
	local vector3_new = Vector3.new

	if WeatherParticleManager.CurrentWeather == "Sakura" then
		if currentTick - WeatherParticleManager.LastLeafSpawn > 0.05 then
			WeatherParticleManager.LastLeafSpawn = currentTick
			local camera = workspace.CurrentCamera
			if camera then
				local camPos = camera.CFrame.Position
				for _ = 1, 3 do
					local leaf
					if #WeatherParticleManager.LeafPool > 0 then
						leaf = table.remove(WeatherParticleManager.LeafPool)
					else
						leaf = Instance.new("Part")
						leaf.Name = "SakuraLeafModel"
						leaf.Size = vector3_new(2.0, 0.1, 1.4)
						leaf.Color = Color3.fromRGB(255, 183, 197)
						leaf.Material = Enum.Material.SmoothPlastic
						leaf.CanCollide = false
						leaf.CanTouch = false
						leaf.CanQuery = false
						leaf.CastShadow = false
						leaf.Anchored = true

						local mesh = Instance.new("SpecialMesh")
						mesh.MeshType = Enum.MeshType.FileMesh
						mesh.MeshId = "rbxassetid://48100239"
						mesh.Scale = vector3_new(2.5, 2.5, 2.5)
						mesh.Parent = leaf

						leaf.Parent = workspace
					end

					local pos = camPos
						+ vector3_new(math_random(-150, 150), math_random(60, 120), math_random(-150, 150))
					local initialCFrame = cframe_new(pos) * cframe_angles(math_random(), math_random(), math_random())
					leaf.CFrame = initialCFrame

					table.insert(WeatherParticleManager.ActiveLeaves, {
						part = leaf,
						pos = pos,
						rotBase = initialCFrame - pos,
						vel = vector3_new(math_random(-10, 10), math_random(-25, -15), math_random(-10, 10)),
						rotVel = vector3_new(math_random(-5, 5), math_random(-5, 5), math_random(-5, 5)),
						spawnTime = currentTick,
					})
				end
			end
		end
	end

	local partsToMove = {}
	local cframesToMove = {}

	for i = #WeatherParticleManager.ActiveLeaves, 1, -1 do
		local data = WeatherParticleManager.ActiveLeaves[i]
		if currentTick - data.spawnTime > 15 then
			table.insert(partsToMove, data.part)
			table.insert(cframesToMove, cframe_new(0, -99999, 0))
			table.insert(WeatherParticleManager.LeafPool, data.part)
			table.remove(WeatherParticleManager.ActiveLeaves, i)
		else
			data.pos = data.pos + data.vel * dt
			data.rotBase = data.rotBase * cframe_angles(data.rotVel.X * dt, data.rotVel.Y * dt, data.rotVel.Z * dt)
			local newCFrame = cframe_new(data.pos) * data.rotBase

			table.insert(partsToMove, data.part)
			table.insert(cframesToMove, newCFrame)
		end
	end

	if #partsToMove > 0 then
		safeGetService("Workspace"):BulkMoveTo(partsToMove, cframesToMove, Enum.BulkMoveMode.FireCFrameChanged)
	end

	if WeatherParticleManager.CachedEmitters then
		for effectName, cached in pairs(WeatherParticleManager.CachedEmitters) do
			local folder = cached.folder
			local emitter = cached.emitter
			local backgroundEmitter = cached.backgroundEmitter

			if effectName == "HeavySnow" then
				backgroundEmitter.Texture = emitter.Texture
				backgroundEmitter.Color = emitter.Color
				backgroundEmitter.Size = emitter.Size
			end

			if WeatherParticleManager.CurrentWeather == "Rain" and effectName == "HeavyRain" then
				folder.Rate.Value = 100
				folder.Speed.Value = 100
				emitter.Enabled = false
				backgroundEmitter.Enabled = true
				backgroundEmitter.Rate = 15000
				backgroundEmitter.Size = NumberSequence.new(0.6, 1.2)
				backgroundEmitter.Speed = NumberRange.new(100, 120)
				backgroundEmitter.Lifetime = NumberRange.new(5, 7)

				backgroundEmitter.Rotation = NumberRange.new(0)
				backgroundEmitter.RotSpeed = NumberRange.new(0)
				backgroundEmitter.Acceleration = Vector3.new(0, 0, 0)
				backgroundEmitter.SpreadAngle = Vector2.new(0, 0)
				pcall(function()
					backgroundEmitter.Drag = 0
					backgroundEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
				end)

				emitter.Size = NumberSequence.new(0.6, 1.2)
			elseif WeatherParticleManager.CurrentWeather == "Snow" and effectName == "HeavySnow" then
				folder.Rate.Value = 100
				folder.Speed.Value = 20
				emitter.Enabled = false
				backgroundEmitter.Enabled = true
				backgroundEmitter.Rate = 6000
				backgroundEmitter.Speed = NumberRange.new(20, 30)
				backgroundEmitter.Lifetime = NumberRange.new(15, 20)

				backgroundEmitter.Rotation = NumberRange.new(0, 360)
				backgroundEmitter.RotSpeed = NumberRange.new(-30, 30)
				backgroundEmitter.Acceleration = Vector3.new(0, 0, 0)
				backgroundEmitter.SpreadAngle = Vector2.new(10, 10)
				pcall(function()
					backgroundEmitter.Drag = 0
					backgroundEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
				end)
			elseif WeatherParticleManager.CurrentWeather == "Sakura" and effectName == "HeavySnow" then
				folder.Rate.Value = 0
				folder.Speed.Value = 15
				emitter.Enabled = false
				backgroundEmitter.Enabled = false
			else
				folder.Rate.Value = 0
				emitter.Enabled = false
				backgroundEmitter.Enabled = false
			end
		end
	end
end

getgenv().ApplyWeatherEffect = WeatherParticleManager.Apply
if getgenv().Config.Mods.WeatherType then
	WeatherParticleManager.Apply(getgenv().Config.Mods.WeatherType)
end

local WorldModsManager = {}

local cachedTerrain = workspace:FindFirstChildOfClass("Terrain")
local cachedClouds = cachedTerrain and cachedTerrain:FindFirstChildOfClass("Clouds")
local cachedAtmosphere = _Lighting:FindFirstChildOfClass("Atmosphere")

function WorldModsManager.Update()
	WeatherParticleManager.Update()
	if getgenv().Config.Mods.ThirdPerson then
		local UIS = game:GetService("UserInputService")
		if UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
			UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		end
	else
		local char = Workspace:FindFirstChild(LocalPlayer.Name)
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid and not humanoid.AutoRotate then
				humanoid.AutoRotate = true
			end
		end
	end

	if getgenv().Config.Mods.Fullbright then
		if _Lighting.Ambient ~= Color3.fromRGB(255, 255, 255) then
			_Lighting.Ambient = Color3.fromRGB(255, 255, 255)
			_Lighting.Brightness = 2
			_Lighting.ClockTime = 14
			_Lighting.GlobalShadows = false
		end
	elseif getgenv().Config.Mods.NoShadows then
		if _Lighting.GlobalShadows then
			_Lighting.GlobalShadows = false
		end
	end

	if getgenv().Config.Mods.Gloom then
		if _Lighting.ClockTime ~= 0 then
			_Lighting.ClockTime = 0
		end
		if _Lighting.GeographicLatitude ~= 45 then
			_Lighting.GeographicLatitude = 45
		end

		if cachedClouds and cachedClouds.Enabled then
			cachedClouds.Enabled = false
		end

		if cachedAtmosphere then
			if cachedAtmosphere.Haze ~= 0 then
				cachedAtmosphere.Haze = 0
			end
			if cachedAtmosphere.Density ~= 0 then
				cachedAtmosphere.Density = 0
			end
		end
	elseif getgenv().Config.Mods.WorldTime then
		if _Lighting.ClockTime ~= getgenv().Config.Mods.WorldTime then
			_Lighting.ClockTime = getgenv().Config.Mods.WorldTime
		end
	end

	if getgenv().Config.Mods.NoFog then
		if _Lighting.FogEnd ~= 100000 then
			_Lighting.FogEnd = 100000
		end
		if cachedAtmosphere and cachedAtmosphere.Density ~= 0 then
			cachedAtmosphere.Density = 0
		end
	end

	local sEffects = getgenv()._cachedScreenEffects
	local mFrame = getgenv()._cachedMainFrame
	if not sEffects or not sEffects.Parent or not mFrame or not mFrame.Parent then
		local pGui = LocalPlayer:FindFirstChild("PlayerGui")
		local noInset = pGui and pGui:FindFirstChild("NoInsetGui")
		mFrame = noInset and noInset:FindFirstChild("MainFrame")
		sEffects = mFrame and mFrame:FindFirstChild("ScreenEffects")
		getgenv()._cachedScreenEffects = sEffects
		getgenv()._cachedMainFrame = mFrame
	end

	if sEffects then
		if getgenv().Config.Mods.NoVisor then
			if not getgenv()._deltaVisorsHidden then
				getgenv()._deltaVisorsHidden = {}
			end

			local visor = sEffects:FindFirstChild("Visor")
			if visor and visor.Visible then
				visor.Visible = false
				getgenv()._deltaVisorsHidden.Visor = true
			end

			local mask = sEffects:FindFirstChild("Mask")
			if mask and mask.Visible then
				mask.Visible = false
				getgenv()._deltaVisorsHidden.Mask = true
			end

			local helmetMask = sEffects:FindFirstChild("HelmetMask")
			if helmetMask and helmetMask.Visible then
				helmetMask.Visible = false
				getgenv()._deltaVisorsHidden.HelmetMask = true
			end
		elseif getgenv()._deltaVisorsHidden then
			if getgenv()._deltaVisorsHidden.Visor then
				local visor = sEffects:FindFirstChild("Visor")
				if visor then
					visor.Visible = true
				end
			end

			if getgenv()._deltaVisorsHidden.Mask then
				local mask = sEffects:FindFirstChild("Mask")
				if mask then
					mask.Visible = true
				end
			end

			if getgenv()._deltaVisorsHidden.HelmetMask then
				local helmetMask = sEffects:FindFirstChild("HelmetMask")
				if helmetMask then
					helmetMask.Visible = true
				end
			end

			getgenv()._deltaVisorsHidden = nil
		end
	end

	if getgenv().Config.Mods.FOV and getgenv().Config.Mods.FOV ~= 70 then
		if not getgenv().DeltaIsZooming then
			if Camera.FieldOfView ~= getgenv().Config.Mods.FOV then
				Camera.FieldOfView = getgenv().Config.Mods.FOV
			end
		end
	end

	local char = Workspace:FindFirstChild(LocalPlayer.Name)
	if char then
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if humanoid and hrp then
			if getgenv().Config.Mods.Speedhack then
				if humanoid.WalkSpeed ~= getgenv().Config.Mods.WalkspeedValue then
					humanoid.WalkSpeed = getgenv().Config.Mods.WalkspeedValue
				end
			end

			if getgenv().Config.Mods.NoFallDamage then
				if hrp.Velocity.Y < -30 then
					TriggerNoFallDamageRobust(hrp, humanoid)

					local params = RaycastParams.new()
					params.FilterDescendantsInstances = { char }
					params.FilterType = Enum.RaycastFilterType.Exclude
					params.RespectCanCollide = true
					local lookAhead = math.abs(hrp.Velocity.Y) * 0.15
					if Workspace:Raycast(hrp.Position, Vector3.new(0, -lookAhead, 0), params) then
						hrp.Velocity = Vector3.new(hrp.Velocity.X, -25, hrp.Velocity.Z)
					end
				end
			else
				-- Restore states if they were previously disabled by older logic
				if not humanoid:GetStateEnabled(Enum.HumanoidStateType.Freefall) then
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
					humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
				end
			end
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
			sound.Parent = _SoundService
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

local cloneref = cloneref or function(...)
	return ...
end
local TS = cloneref(game:GetService("TweenService"))
local RS = cloneref(game:GetService("RunService"))

local HitEffectManager = {}
getgenv().HitEffectManager = HitEffectManager

local AVAILABLE_EFFECTS = { "Arcade Pop", "CRT Glitch", "JRPG Cascade", "8-Bit Drift", "Cyber Strike", "Voxel Smash" }
local HIT_WORDS = { "YES!", "OK!", "HIT!", "SMASH!", "PERFECT!" }

local function getHitEffectGui()
	if getgenv().RetroHitEffectsGui and getgenv().RetroHitEffectsGui.Parent then
		getgenv().RetroHitEffectsGui.DisplayOrder = 999999
		getgenv().RetroHitEffectsGui.Enabled = true
		return getgenv().RetroHitEffectsGui
	end

	if not LocalPlayer then
		return nil
	end

	local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
	if not playerGui then
		return nil
	end

	local sg = playerGui:FindFirstChild("RetroHitEffectsGui")
	if not sg then
		sg = Instance.new("ScreenGui")
		sg.Name = "RetroHitEffectsGui"
		sg.IgnoreGuiInset = true
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		sg.ResetOnSpawn = false
		sg.Parent = playerGui
	end

	sg.DisplayOrder = 999999
	sg.Enabled = true
	getgenv().RetroHitEffectsGui = sg

	return sg
end

getgenv().CascadeHitTracker = getgenv().CascadeHitTracker or 0

function HitEffectManager.Play(targetPart, hitPos, damageDealt, isKill)
	if not getgenv().Config.Mods.HitEffects then
		return
	end

	local effectType = AVAILABLE_EFFECTS[math.random(1, #AVAILABLE_EFFECTS)]

	local effectColor = Color3.fromHex("#7f48a3")
	if getgenv().Options and getgenv().Options.HitEffectsColor then
		local c = getgenv().Options.HitEffectsColor.Value
		if typeof(c) == "Color3" then
			effectColor = c
		end
	elseif getgenv().Config and getgenv().Config.Mods and getgenv().Config.Mods.HitEffectsColor then
		local c = getgenv().Config.Mods.HitEffectsColor
		if typeof(c) == "Color3" then
			effectColor = c
		end
	end

	task.spawn(function()
		pcall(function()
			if isKill then
				task.spawn(function()
					local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
					if playerGui then
						local flashGui = Instance.new("ScreenGui")
						flashGui.Name = "HotlineKillFlash"
						flashGui.IgnoreGuiInset = true
						flashGui.DisplayOrder = 1000
						flashGui.Parent = playerGui

						local duration = 2.0
						local thickness = 200

						local frames = {}
						local function createEdge(size, pos, anchor, rot)
							local frame = Instance.new("Frame")
							frame.BackgroundColor3 = effectColor
							frame.BorderSizePixel = 0
							frame.Size = size
							frame.Position = pos
							frame.AnchorPoint = anchor
							frame.BackgroundTransparency = 0.2
							frame.Parent = flashGui

							local gradient = Instance.new("UIGradient")
							gradient.Rotation = rot
							gradient.Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(1, 1),
							})
							gradient.Parent = frame
							table.insert(frames, frame)
						end

						createEdge(UDim2.new(1, 0, 0, thickness), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0), 90) -- Top
						createEdge(UDim2.new(1, 0, 0, thickness), UDim2.new(0, 0, 1, 0), Vector2.new(0, 1), 270) -- Bottom
						createEdge(UDim2.new(0, thickness, 1, 0), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0), 0) -- Left
						createEdge(UDim2.new(0, thickness, 1, 0), UDim2.new(1, 0, 0, 0), Vector2.new(1, 0), 180) -- Right

						local viewport = workspace.CurrentCamera.ViewportSize
						local numDrops = math.random(60, 100)

						for i = 1, numDrops do
							local drop = Instance.new("Frame")
							drop.BackgroundColor3 = effectColor
							drop.BorderSizePixel = 0
							drop.BackgroundTransparency = 0.3

							local corner = Instance.new("UICorner")
							corner.CornerRadius = UDim.new(1, 0)
							corner.Parent = drop

							local width = math.random(4, 16)
							local height = width + math.random(0, width)
							drop.Size = UDim2.fromOffset(width, height)

							local margin = 180
							local x, y = 0, 0

							local region = math.random(1, 4)
							if region == 1 then
								x = math.random(0, viewport.X)
								y = math.random(0, margin)
							elseif region == 2 then
								x = math.random(0, viewport.X)
								y = math.random(viewport.Y - margin, viewport.Y)
							elseif region == 3 then
								x = math.random(0, margin)
								y = math.random(0, viewport.Y)
							else
								x = math.random(viewport.X - margin, viewport.X)
								y = math.random(0, viewport.Y)
							end

							drop.Position = UDim2.fromOffset(x, y)
							drop.Parent = flashGui
							table.insert(frames, drop)

							local fallDist = math.random(80, 400)
							local fallDuration = duration * (math.random(8, 12) / 10)
							TS
								:Create(
									drop,
									TweenInfo.new(fallDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
									{
										Position = UDim2.fromOffset(x, y + fallDist),
										Size = UDim2.fromOffset(width * 0.5, height * 1.5),
									}
								)
								:Play()
						end

						task.delay(duration, function()
							local tInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
							for _, f in ipairs(frames) do
								TS:Create(f, tInfo, { BackgroundTransparency = 1 }):Play()
							end
						end)

						task.delay(duration + 0.6, function()
							flashGui:Destroy()
						end)
					end
				end)
			end

			local sg = getHitEffectGui()
			if not sg then
				return
			end

			local camera = workspace.CurrentCamera
			local screenPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y * 0.7)

			if hitPos then
				local vec, isVis = camera:WorldToViewportPoint(hitPos)
				if isVis then
					screenPos = Vector2.new(vec.X, vec.Y)
				end
			end

			local textStr
			local textScale = 1
			if isKill then
				textStr = "KILLED!!!"
				textScale = 1.5
			else
				textStr = HIT_WORDS[math.random(1, #HIT_WORDS)]
			end

			local label = Instance.new("TextLabel")
			label.BackgroundTransparency = 1
			label.Text = textStr
			label.TextColor3 = effectColor
			pcall(function()
				label.Font = Enum.Font.Arcade
			end)
			if label.Font ~= Enum.Font.Arcade then
				label.Font = Enum.Font.GothamBold
			end
			label.TextSize = math.floor(24 * textScale)
			label.TextStrokeTransparency = 0
			label.TextStrokeColor3 = Color3.new(0, 0, 0)
			label.Size = UDim2.fromOffset(200, 60)
			label.AnchorPoint = Vector2.new(0.5, 0.5)
			label.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
			label.ZIndex = 100
			label.Parent = sg

			if effectType == "Arcade Pop" then
				local rot = math.random(-15, 15)
				label.TextSize = 0
				label.Rotation = rot

				TS:Create(
					label,
					TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
					{ TextSize = math.floor(36 * textScale) }
				):Play()

				task.delay(0.2, function()
					TS:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
						Position = UDim2.fromOffset(screenPos.X, screenPos.Y - 80),
						TextTransparency = 1,
						TextStrokeTransparency = 1,
						TextSize = 0,
						Rotation = rot * 2,
					}):Play()
				end)
				task.delay(0.6, function()
					label:Destroy()
				end)
			elseif effectType == "CRT Glitch" then
				label.TextSize = math.floor(32 * textScale)
				local targetPos = UDim2.fromOffset(screenPos.X + math.random(-15, 15), screenPos.Y - 100)

				TS:Create(
					label,
					TweenInfo.new(0.6, Enum.EasingStyle.Sine),
					{ Position = targetPos, TextTransparency = 1, TextStrokeTransparency = 1 }
				):Play()

				task.spawn(function()
					for i = 1, 6 do
						if label.Parent then
							label.Position = UDim2.fromOffset(
								targetPos.X.Offset + math.random(-8, 8),
								targetPos.Y.Offset + math.random(-4, 4)
							)
							label.TextTransparency = math.random(0, 3) / 10
						end
						task.wait(0.05)
					end
				end)
				task.delay(0.6, function()
					label:Destroy()
				end)
			elseif effectType == "JRPG Cascade" then
				getgenv().CascadeHitTracker = (getgenv().CascadeHitTracker + 1) % 10
				local offsetIdx = getgenv().CascadeHitTracker

				label.Position = UDim2.fromOffset(screenPos.X + (offsetIdx * 20) - 80, screenPos.Y - (offsetIdx * 8))
				label.TextSize = math.floor(44 * textScale)
				label.Rotation = -15
				label.TextTransparency = 1

				TS:Create(label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextSize = math.floor(28 * textScale),
					Rotation = 0,
					TextTransparency = 0,
				}):Play()

				task.delay(0.2, function()
					TS:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Position = label.Position + UDim2.fromOffset(0, 60),
						TextTransparency = 1,
						TextStrokeTransparency = 1,
					}):Play()
				end)
				task.delay(0.7, function()
					label:Destroy()
				end)
			elseif effectType == "8-Bit Drift" then
				label.TextSize = math.floor(24 * textScale)

				local duration = 1.0
				local baseY = screenPos.Y
				local targetY = baseY - 120
				local baseX = screenPos.X
				local elapsed = 0

				local conn
				conn = RS.RenderStepped:Connect(function(dt)
					if not label.Parent then
						conn:Disconnect()
						return
					end

					elapsed = elapsed + dt
					if elapsed > duration then
						conn:Disconnect()
						label:Destroy()
						return
					end

					local progress = elapsed / duration
					local currentY = baseY - ((baseY - targetY) * progress)
					local waveX = math.sin(elapsed * 12) * 40

					label.Position = UDim2.fromOffset(baseX + waveX, currentY)
					label.Rotation = math.sin(elapsed * 12) * 20
					label.TextColor3 = effectColor

					if progress > 0.6 then
						local alpha = (progress - 0.6) / 0.4
						label.TextTransparency = alpha
						label.TextStrokeTransparency = alpha
					end
				end)
			elseif effectType == "Cyber Strike" then
				label.TextSize = math.floor(32 * textScale)
				label.TextColor3 = effectColor

				label.TextStrokeTransparency = 1
				local uiStroke = Instance.new("UIStroke")
				uiStroke.Color = effectColor
				uiStroke.Thickness = 2.5
				uiStroke.Transparency = 0
				uiStroke.Parent = label

				local uiScale = Instance.new("UIScale")
				uiScale.Scale = 2.5
				uiScale.Parent = label

				TS:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), { Scale = 1 })
					:Play()

				local targetPos = UDim2.fromOffset(screenPos.X + math.random(-40, 40), screenPos.Y - 90)

				task.delay(0.15, function()
					TS:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
						Position = targetPos,
						TextTransparency = 1,
						Rotation = math.random(-10, 10),
					}):Play()
					TS:Create(
						uiStroke,
						TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{ Transparency = 1 }
					):Play()
				end)
				task.delay(0.55, function()
					label:Destroy()
				end)
			elseif effectType == "Voxel Smash" then
				label.TextSize = math.floor(28 * textScale)
				label.TextColor3 = effectColor

				local duration = 0.7
				local targetY = screenPos.Y - 90
				local elapsed = 0

				local conn
				conn = RS.RenderStepped:Connect(function(dt)
					if not label.Parent then
						conn:Disconnect()
						return
					end

					elapsed = elapsed + dt
					if elapsed > duration then
						conn:Disconnect()
						label:Destroy()
						return
					end

					local step = math.floor(elapsed * 15) / 15
					local currentY = screenPos.Y - ((screenPos.Y - targetY) * (step / duration))

					label.Position = UDim2.fromOffset(screenPos.X, currentY)

					if step > 0.5 then
						label.TextTransparency = (math.floor(elapsed * 30) % 2 == 0) and 0 or 1
						label.TextStrokeTransparency = label.TextTransparency
					end
				end)
			end
		end)
	end)
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
	Locked = false,
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

	for npcInstance, npcData in pairs(CharacterManager.ActiveNPCs) do
		local head = npcData.Head
		if head then
			local screenPosition, isVisibleOnScreen = Camera:WorldToViewportPoint(head.Position)
			if isVisibleOnScreen and screenPosition.Z > 0 then
				local distanceToMouse = (Vector2.new(screenPosition.X, screenPosition.Y) - mouseLocation).Magnitude
				if distanceToMouse < shortestDistance then
					local replicatedPlayers = ReplicatedStorage:FindFirstChild("Players")
					local playerFolder = replicatedPlayers and replicatedPlayers:FindFirstChild(npcData.Name)
					local parentFolder = playerFolder or npcInstance

					shortestDistance = distanceToMouse
					closestTarget = {
						Type = "NPC",
						Name = npcData.Name,
						TargetInstance = npcInstance,
						ParentFolder = parentFolder,
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

		if config.InventoryViewerOnlyNecessary and not isValuable then
			continue
		end

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
	local textSize = config.InventoryViewerTextSize or 13
	local titleHeight = math.round(textSize * 3.07)
	local itemSpacing = math.round(textSize * 1.38)
	local padding = 12
	local totalHeight = padding * 2 + titleHeight + (#uniqueOrder * itemSpacing)
	local width = math.clamp(math.round((textSize / 13) * InventoryViewer.Width), 180, 600)

	if not InventoryViewer.UserPosition then
		local confX = getgenv().Config.ESP.InventoryViewerX
		local confY = getgenv().Config.ESP.InventoryViewerY
		if confX and confY then
			InventoryViewer.UserPosition = Vector2.new(confX, confY)
		else
			InventoryViewer.UserPosition = Vector2.new(viewportSize.X - width - 100, (viewportSize.Y - totalHeight) / 2)
		end
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

	if targetInfo and targetInfo.Type == "Corpse" then
		targetName = string.gsub(targetName, "'s Corpse$", "")
		targetName = string.gsub(targetName, " Corpse$", "")
		targetName = string.gsub(targetName, " Corpse's$", "")
	end

	-- Create title
	local titleFormat = (targetInfo and targetInfo.Type == "Corpse") and "%s Corpse's Inventory" or "%s's Inventory"
	InventoryViewer.TitleText.Text = string.format(titleFormat, targetName)
	InventoryViewer.TitleText.Size = math.max(14, textSize + 1)
	InventoryViewer.TitleText.Position = Vector2.new(x + width / 2, y + padding)
	InventoryViewer.TitleText.Visible = true

	if InventoryViewer.DividerText then
		InventoryViewer.DividerText.Size = textSize
		InventoryViewer.DividerText.Position = Vector2.new(x + width / 2, y + padding + math.round(textSize * 1.15))
		InventoryViewer.DividerText.Visible = true
	end

	InventoryViewer.OrderedItems = uniqueOrder
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
			textDrawing.Size = textSize
			textDrawing.Font = config.Font or 2
			InventoryViewer.TextCache[cacheKey] = textDrawing
		end

		textDrawing.Size = textSize

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

function InventoryViewer.UpdatePositions()
	if not InventoryViewer.UserPosition then
		return
	end
	local x = InventoryViewer.UserPosition.X
	local y = InventoryViewer.UserPosition.Y
	local config = getgenv().Config.ESP
	local textSize = config.InventoryViewerTextSize or 13
	local titleHeight = math.round(textSize * 3.07)
	local itemSpacing = math.round(textSize * 1.38)
	local padding = 12

	local viewportSize = workspace.CurrentCamera.ViewportSize
	local width = InventoryViewer.Background and InventoryViewer.Background.Size.X or 180
	local totalHeight = InventoryViewer.Background and InventoryViewer.Background.Size.Y or 200

	x = math.clamp(x, 0, math.max(0, viewportSize.X - width))
	y = math.clamp(y, 0, math.max(0, viewportSize.Y - totalHeight))
	InventoryViewer.UserPosition = Vector2.new(x, y)

	if InventoryViewer.Background then
		InventoryViewer.Background.Position = Vector2.new(x, y)
	end
	if InventoryViewer.Border then
		InventoryViewer.Border.Position = Vector2.new(x, y)
	end

	if InventoryViewer.TitleText then
		InventoryViewer.TitleText.Position = Vector2.new(x + width / 2, y + padding)
	end
	if InventoryViewer.DividerText then
		InventoryViewer.DividerText.Position = Vector2.new(x + width / 2, y + padding + math.round(textSize * 1.15))
	end

	if InventoryViewer.OrderedItems then
		for index, cacheKey in ipairs(InventoryViewer.OrderedItems) do
			local textDrawing = InventoryViewer.TextCache[cacheKey]
			if textDrawing then
				local itemY = y + padding + titleHeight + (index - 1) * itemSpacing
				textDrawing.Position = Vector2.new(x + 15, itemY)
			end
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
						not InventoryViewer.Locked
						and mousePos.X >= bgPos.X
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
				local newPos = mousePos - InventoryViewer.DragOffset
				InventoryViewer.UserPosition = newPos
				getgenv().Config.ESP.InventoryViewerX = newPos.X
				getgenv().Config.ESP.InventoryViewerY = newPos.Y
				if InventoryViewer.UpdatePositions then
					InventoryViewer.UpdatePositions()
				else
					InventoryViewer.Draw()
				end
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

			local targetName = closestTarget.Name or "Unknown"
			if closestTarget.Type == "Corpse" then
				targetName = string.gsub(targetName, "'s Corpse$", "")
				targetName = string.gsub(targetName, " Corpse$", "")
				targetName = string.gsub(targetName, " Corpse's$", "")
			end

			local titleFormat = closestTarget.Type == "Corpse" and "%s Corpse's Inventory" or "%s's Inventory"
			InventoryViewer.TitleText.Text = string.format(titleFormat, targetName)
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

-- ==========================================
-- Bullet Hole ESP Manager
-- ==========================================
task.spawn(function()
	local RS = game:GetService("ReplicatedStorage")
	local FuncLib
	while not FuncLib do
		pcall(function()
			FuncLib = (require :: any)(RS:WaitForChild("Modules", 2):WaitForChild("FunctionLibraryExtension", 2))
		end)
		task.wait(1)
	end

	if not getgenv().OriginalPenetration then
		getgenv().OriginalPenetration = FuncLib.Penetration
		FuncLib.Penetration = function(self, instance, startPos, dir, armorPen, ...)
			return getgenv().OriginalPenetration(self, instance, startPos, dir, armorPen, ...)
		end
	end
end)

-- ==========================================
-- InstantHit Manager (namecall-based)
-- ==========================================
-- GC dump proved upvalue swapping is broken: all upvalue VALUES are nil at scan time,
-- meaning getgc() returns a cold/stale closure that never runs.
-- The __namecall hook provably works (it produced all Remote Spy logs).
-- Strategy: intercept FireProjectile:InvokeServer inside __namecall, then immediately
-- call ProjectileInflict:FireServer with forged hit data targeting the enemy hitbox.

local InstantHitManager = {}

-- Find the actual ProjectileInflict remote from ReplicatedStorage
local function getInflictRemote()
	if getgenv()._IH_InflictRemote then
		return getgenv()._IH_InflictRemote
	end
	local rs = game:GetService("ReplicatedStorage")
	local remote = workspace:FindFirstChild("ProjectileInflict", true) or rs:FindFirstChild("ProjectileInflict", true)
	if remote then
		getgenv()._IH_InflictRemote = remote
	end
	return remote
end

function InstantHitManager.Activate()
	local passedBullets = {}
	local forgedBullets = {}

	getgenv()._IH_Interceptor = function(method, remoteName, args)
		if
			not getgenv().Config.Combat.InstantHit
			and not getgenv().Config.SilentAim.Enabled
			and not getgenv()._TPKillActive
			and not (getgenv()._AutopilotTargetOverride and getgenv()._DeltaIsAutoHolding)
		then
			return false
		end

		if method == "InvokeServer" and remoteName == "FireProjectile" then
			if not getgenv().Config.Combat.InstantHit and getgenv().Config.SilentAim.Enabled then
				if getgenv().LastServerAimDirection then
					args[1] = getgenv().LastServerAimDirection
				end
				return false, function() end, args
			end
			local bulletId = args[2]
			local fireTimestamp = args[3]

			-- TPKill diagnostic: confirm FireProjectile is being intercepted at all

			local target = nil
			if getgenv()._AutopilotTargetOverride and getgenv()._DeltaIsAutoHolding then
				target = getgenv()._AutopilotTargetOverride
			else
				target = TargetManager and TargetManager.CurrentTarget
			end

			local targetAimPart = nil

			if getgenv()._TPKillActive and getgenv()._TPKillTarget then
				-- If TPKill is active, we MUST shoot at the locked TPKill target.
				local char = getgenv()._TPKillTarget.Parent
				targetAimPart = char and char:FindFirstChild("Head") or getgenv()._TPKillTarget
			elseif target then
				local targetPartName = getgenv().Config.SilentAim and getgenv().Config.SilentAim.TargetPart or "Head"
				targetAimPart = (target.Character and target.Character:FindFirstChild(targetPartName))
					or (target.Character and target.Character:FindFirstChild("Head"))
					or (target.Character and target.Character.PrimaryPart)
			end

			if targetAimPart then
				local serverOrigin
				local isUnderground = false

				local realOrigin = workspace.CurrentCamera.CFrame.Position
				if not getgenv().CachedFunctionLibraryExtension then
					pcall(function()
						getgenv().CachedFunctionLibraryExtension = require(
							ReplicatedStorage:WaitForChild("Modules", 2):WaitForChild("FunctionLibraryExtension", 2)
						)
					end)
				end
				if getgenv().CachedFunctionLibraryExtension then
					pcall(function()
						realOrigin = getgenv().CachedFunctionLibraryExtension:GetEstimatedCameraPosition(LocalPlayer)
					end)
				end

				if getgenv()._TPKillActive and getgenv()._TPKillPos then
					local basePos = getgenv()._TPKillPos
					serverOrigin = basePos + Vector3.new(0, 1.6, 0)
				else
					isUnderground = getgenv().Config.Combat.UndergroundDesync
						and getgenv()._StoredRealCFrame
						and not getgenv()._TPKillActive

					serverOrigin = realOrigin
					local found_origin = nil

					if getgenv().Config.Combat.OriginManipulation then
						local targetRoot = (target and target.RootPart)
							or (target and target.Character and target.Character:FindFirstChild("HumanoidRootPart"))
							or targetAimPart
						found_origin = getgenv().CharacterManager
							and getgenv().CharacterManager.GetManipulatedOrigin
							and getgenv().CharacterManager.GetManipulatedOrigin(
								realOrigin,
								targetAimPart.Position,
								targetRoot,
								isUnderground
							)
					end

					if isUnderground then
						local localOffset = getgenv()._StoredRealCFrame:PointToObjectSpace(found_origin or realOrigin)
						local undergroundDesyncOffset = CFrame.new(0, -3.8, 0) * CFrame.Angles(math.rad(-90), 0, 0)
						local undergroundHRP_CFrame = getgenv()._StoredRealCFrame * undergroundDesyncOffset
						serverOrigin = undergroundHRP_CFrame:PointToWorldSpace(localOffset)
					elseif found_origin then
						serverOrigin = found_origin
					end
				end

				local predictedPos = getgenv().Config.SilentAim.Prediction
						and getgenv().Config.SilentAim.Enabled
						and typeof(getgenv().PredictionPoint) == "Vector3"
						and getgenv().PredictionPoint
					or targetAimPart.Position

				local distance
				if getgenv()._TPKillActive and getgenv()._TPKillPos then
					distance = (predictedPos - serverOrigin).Magnitude
				else
					local trueDistance = (predictedPos - realOrigin).Magnitude
					local tpDistance = (predictedPos - serverOrigin).Magnitude
					distance = math.max(trueDistance, tpDistance)
				end

				local ammoName = getgenv().LastFiredAmmoName or ""
				local v = (getgenv().DeltaVelocityCache and getgenv().DeltaVelocityCache[ammoName]) or 2500

				local safeVelocity = v * 0.85
				local expectedFlightTime = distance / safeVelocity

				local perfectDirection = (predictedPos - serverOrigin).Unit

				if getgenv().AddLog then
					getgenv().AddLog(
						string.format(
							"[InstantHit Calc] Dist: %.2f | V: %.2f | SafeV: %.2f | FlightTime: %.4f | UGR: %s",
							distance,
							v,
							safeVelocity,
							expectedFlightTime,
							tostring(isUnderground and true or false)
						)
					)
				end

				args[1] = perfectDirection

				-- Standard InstantHit: Backdate FireProjectile so it arrives instantly.
				-- Since TPKill waits for ping before firing, the server already knows we are in the sky,
				-- so we can safely backdate the shot without causing an invalid origin reject.
				local spoofedFireTimestamp = fireTimestamp - expectedFlightTime
				local inflictDelay = 0

				local inflictTimestamp = fireTimestamp

				local hitWorldPos
				local rayParams = RaycastParams.new()
				rayParams.FilterType = Enum.RaycastFilterType.Include
				if targetAimPart.Parent then
					rayParams.FilterDescendantsInstances = { targetAimPart.Parent }
				else
					rayParams.FilterDescendantsInstances = { targetAimPart }
				end

				local rayResult = workspace:Raycast(serverOrigin, perfectDirection * (distance + 10), rayParams)
				if rayResult then
					hitWorldPos = rayResult.Position
				else
					hitWorldPos = targetAimPart.Position - (perfectDirection * 0.55)
				end

				hitWorldPos = hitWorldPos
					+ Vector3.new(math.random(-5, 5) / 1000, math.random(-5, 5) / 1000, math.random(-5, 5) / 1000)

				-- Mathematically precise hit CFrame (position only, identity rotation like native script)
				local bulletWorldCFrame = CFrame.new(hitWorldPos)
				local hitCFrame = targetAimPart.CFrame:ToObjectSpace(bulletWorldCFrame)

				args[3] = spoofedFireTimestamp
				forgedBullets[bulletId] = true

				local function sendInflict()
					local inflict = getInflictRemote()
					if inflict then
						passedBullets[bulletId] = true

						local isUnderground = (
							getgenv().Config.Combat.UndergroundDesync or getgenv()._UndergroundResolverActive
						) and not getgenv()._TPKillActive
						if isUnderground then
							task.wait()
						end

						if getgenv()._TPKillActive then
							local debugMsg = string.format(
								"[TPKILL EXPLICIT] BulletId: %s | Target: %s | SentDir: %.3f,%.3f,%.3f | OrigCFrame: %.1f,%.1f,%.1f | TargetPos: %.1f,%.1f,%.1f | HitCFrame.Z: %.3f | Inflict Timestamp: %s",
								tostring(bulletId),
								tostring(targetAimPart),
								args[1].X,
								args[1].Y,
								args[1].Z,
								getgenv()._TPKillOriginalCFrame and getgenv()._TPKillOriginalCFrame.Position.X or 0,
								getgenv()._TPKillOriginalCFrame and getgenv()._TPKillOriginalCFrame.Position.Y or 0,
								getgenv()._TPKillOriginalCFrame and getgenv()._TPKillOriginalCFrame.Position.Z or 0,
								targetAimPart.Position.X,
								targetAimPart.Position.Y,
								targetAimPart.Position.Z,
								hitCFrame.ZVector.Z,
								tostring(inflictTimestamp)
							)
							print(debugMsg)
							if getgenv().AddLog then
								getgenv().AddLog(debugMsg)
							end
						end

						inflict:FireServer(targetAimPart, hitCFrame, bulletId, inflictTimestamp)
					end
				end

				if inflictDelay > 0 then
					task.spawn(function()
						task.wait(inflictDelay)
						sendInflict()
					end)
				else
					task.defer(sendInflict)
				end

				return false, function() end, args
			end
			return false
		elseif method == "FireServer" and remoteName == "ProjectileInflict" then
			-- Gate: only run forged/natural packet management when InstantHit OR TPKill
			-- is the feature responsible.
			if not getgenv().Config.Combat.InstantHit and not getgenv()._TPKillActive then
				return false
			end
			local bulletId = args[3]

			if passedBullets[bulletId] then
				passedBullets[bulletId] = nil
				return false -- Let our zero-delay packet through
			end

			if forgedBullets[bulletId] then
				return true -- DROP the natural physics packet to prevent anti-cheat kick
			end

			return false
		end -- elseif FireServer ProjectileInflict

		return false
	end -- _IH_Interceptor
	return true
end -- InstantHitManager.Activate

function InstantHitManager.Deactivate()
	getgenv()._IH_Interceptor = nil
end

-- Wire up the toggle
getgenv().Toggles.InstantHit:OnChanged(function(value)
	getgenv().Config.Combat.InstantHit = value
end)

-- Initialize the interceptor permanently so Autopilot can always use it
-- The interceptor itself has internal checks to remain dormant if features are disabled
InstantHitManager.Activate()

table.insert(
	ThreadList,
	task.spawn(function()
		while true do
			pcall(InventoryViewer.CheckTarget)
			task.wait(0.25)
		end
	end)
)

local function UpdateViewmodelRender()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local isADS = false
	local configCombat = getgenv().Config.Combat
	if configCombat.HideViewmodelOnADS and getgenv().DeltaIsZooming == true then
		isADS = true
	end
	if getgenv().Config.Mods.ThirdPerson then
		isADS = true
	end

	local config = getgenv().Config.ESP
	local hideArms = config.HideArms
	local armEnabled = config.ViewmodelArmChams and not isADS
	local gunEnabled = config.ViewmodelGunChams and not isADS
	local baseTrans = math.clamp(config.ViewmodelChamsTransparency, 0, 1)

	local viewModel = camera:FindFirstChild("ViewModel")
	if not viewModel or not viewModel:IsA("Model") then
		return
	end

	-- Initialize Caches
	if not getgenv().DeltaViewmodelOriginalProps then
		getgenv().DeltaViewmodelOriginalProps = setmetatable({}, { __mode = "k" })
	end
	if not getgenv().DeltaViewmodelAppliedProps then
		getgenv().DeltaViewmodelAppliedProps = setmetatable({}, { __mode = "k" })
	end

	-- Rebuild Cache if needed
	local currentDescendantsCount = #viewModel:GetDescendants()
	local cacheValid = true

	if
		getgenv().DeltaCachedViewmodelParent ~= viewModel
		or not getgenv().DeltaCachedActiveTargets
		or getgenv().DeltaCachedViewmodelCount ~= currentDescendantsCount
	then
		cacheValid = false
	end

	if cacheValid and getgenv().DeltaCachedActiveParts then
		for _, desc in ipairs(viewModel:GetDescendants()) do
			if desc:IsA("BasePart") and not getgenv().DeltaCachedActiveParts[desc] then
				cacheValid = false
				break
			end
		end
	end

	if not cacheValid then
		getgenv().DeltaCachedViewmodelParent = viewModel
		getgenv().DeltaCachedViewmodelCount = currentDescendantsCount

		local tTargets, tParts = {}, {}
		local bPartsArray = {}

		local function isBodyPart(name)
			name = string.lower(name)
			return string.find(name, "arm")
				or string.find(name, "hand")
				or string.find(name, "shirt")
				or string.find(name, "sleeve")
				or string.find(name, "glove")
		end

		for _, desc in ipairs(viewModel:GetChildren()) do
			local isBody = isBodyPart(desc.Name)
			local targetType = isBody and "Body" or "Gun"
			tTargets[desc] = targetType

			if desc:IsA("BasePart") then
				tParts[desc] = targetType
			else
				for _, sub in ipairs(desc:GetDescendants()) do
					if sub:IsA("BasePart") then
						tParts[sub] = targetType
					end
				end
			end
		end

		for _, desc in ipairs(viewModel:GetDescendants()) do
			if desc:IsA("BasePart") then
				table.insert(bPartsArray, desc)

				-- Pre-cache original properties
				local specMesh = desc:FindFirstChildWhichIsA("SpecialMesh")
				local surfApp = desc:FindFirstChildWhichIsA("SurfaceAppearance")
				getgenv().DeltaViewmodelOriginalProps[desc] = {
					Transparency = desc.Transparency,
					Material = desc.Material,
					Color = desc.Color,
					TextureID = desc:IsA("MeshPart") and desc.TextureID or nil,
					SpecMesh = specMesh,
					SpecMeshTex = specMesh and specMesh.TextureId or nil,
					SurfApp = surfApp,
				}
			end
		end

		getgenv().DeltaCachedActiveTargets = tTargets
		getgenv().DeltaCachedActiveParts = tParts
		getgenv().DeltaCachedBasePartsArray = bPartsArray
	end

	-- Fast references for render loop
	local activePartsCache = getgenv().DeltaCachedActiveParts
	local baseParts = getgenv().DeltaCachedBasePartsArray
	local origProps = getgenv().DeltaViewmodelOriginalProps
	local appliedProps = getgenv().DeltaViewmodelAppliedProps

	local armColor = config.ViewmodelArmColor
	local gunColor = config.ViewmodelGunColor
	local armMat = Enum.Material[config.ViewmodelArmMaterial] or Enum.Material.ForceField
	local gunMat = Enum.Material[config.ViewmodelGunMaterial] or Enum.Material.ForceField

	-- Unified Render Pass
	for _, desc in ipairs(baseParts) do
		local pType = activePartsCache[desc]
		local props = origProps[desc]
		local current = appliedProps[desc]

		if props then
			-- 1. Apply Transparency Modifier (HideArms/ADS)
			local isArm = pType == "Body"
			if hideArms and isArm then
				desc.LocalTransparencyModifier = 1
			else
				desc.LocalTransparencyModifier = isADS and 1 or 0
			end

			-- 2. Apply Chams
			local chamsActive = (isArm and armEnabled) or (pType == "Gun" and gunEnabled)

			if chamsActive and props.Transparency < 1 then
				local targetTrans = baseTrans
				local targetColor = isArm and armColor or gunColor
				local targetMaterial = isArm and armMat or gunMat

				if
					not current
					or current.T ~= targetTrans
					or current.C ~= targetColor
					or current.M ~= targetMaterial
				then
					desc.Transparency = targetTrans
					desc.Material = targetMaterial
					desc.Color = targetColor

					if desc:IsA("MeshPart") then
						desc.TextureID = ""
					end
					if props.SpecMesh then
						props.SpecMesh.TextureId = ""
					end
					if props.SurfApp and props.SurfApp.Parent == desc then
						props.SurfApp.Parent = nil
					end

					appliedProps[desc] = { T = targetTrans, C = targetColor, M = targetMaterial }
				end
			else
				-- Restore original properties if Chams disabled
				if
					not current
					or current.T ~= props.Transparency
					or current.C ~= props.Color
					or current.M ~= props.Material
				then
					desc.Transparency = props.Transparency
					desc.Material = props.Material
					desc.Color = props.Color

					if desc:IsA("MeshPart") and props.TextureID then
						desc.TextureID = props.TextureID
					end
					if props.SpecMesh and props.SpecMeshTex then
						props.SpecMesh.TextureId = props.SpecMeshTex
					end
					if props.SurfApp and props.SurfApp.Parent ~= desc then
						props.SurfApp.Parent = desc
					end

					appliedProps[desc] = { T = props.Transparency, C = props.Color, M = props.Material }
				end
			end
		end
	end
end

local function UpdateViewmodelOffset()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local viewModel = camera:FindFirstChild("ViewModel")
	if not viewModel or not viewModel:IsA("Model") then
		return
	end

	local hrp = viewModel:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local config = getgenv().Config.ESP
	local vec = Vector3.new(config.ViewmodelOffsetX, config.ViewmodelOffsetY, config.ViewmodelOffsetZ)

	if not getgenv().DeltaViewmodelOriginalC0 then
		getgenv().DeltaViewmodelOriginalC0 = {}
	end
	local origC0 = getgenv().DeltaViewmodelOriginalC0

	local joints = { "LeftUpperArm", "RightUpperArm", "ItemRoot", "Motor6D" }
	for _, jointName in ipairs(joints) do
		local weld = hrp:FindFirstChild(jointName)
		if weld and weld:IsA("Motor6D") then
			-- CACHE BY STRING NAME, NOT BY INSTANCE!
			-- The game clones the instances which causes instance-based caches to
			-- absorb the previous offset and slowly float away.
			if not origC0[jointName] then
				origC0[jointName] = weld.C0
			end
			weld.C0 = origC0[jointName] + vec
		end
	end
end

-- Hook into Camera to apply offset when viewmodel is added, and CLEAR cache when removed
local function hookCamera(cam)
	if not cam then
		return
	end
	cam.ChildAdded:Connect(function(child)
		if child.Name == "ViewModel" or child:IsA("Model") then
			task.delay(0.1, function()
				pcall(UpdateViewmodelOffset)
			end)
		end
	end)
	cam.ChildRemoved:Connect(function(child)
		if child.Name == "ViewModel" or child:IsA("Model") then
			-- Clear the C0 cache so the next weapon caches its true original C0!
			getgenv().DeltaViewmodelOriginalC0 = {}
		end
	end)
end
hookCamera(Workspace.CurrentCamera)
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	hookCamera(Workspace.CurrentCamera)
end)

-- Update config and instantly apply when sliders are moved
getgenv().Options.ViewmodelOffsetX:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelOffsetX = value
	pcall(UpdateViewmodelOffset)
end)
getgenv().Options.ViewmodelOffsetY:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelOffsetY = value
	pcall(UpdateViewmodelOffset)
end)
getgenv().Options.ViewmodelOffsetZ:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelOffsetZ = value
	pcall(UpdateViewmodelOffset)
end)

-- Apply once on load in case the viewmodel is already equipped
task.spawn(function()
	pcall(UpdateViewmodelOffset)
end)

-- ==========================================
-- ==========================================
-- Target Info HUD Manager (Animated Modern Retro Style)
-- ==========================================
local TargetHUDManager = {}
getgenv().TargetHUDManager = TargetHUDManager
TargetHUDManager.Locked = getgenv().Config.ESP.LockTargetInfoHUD or false

local TweenService = game:GetService("TweenService")

local PlayersFolder = ReplicatedStorage:FindFirstChild("Players")

local coreGui = (gethui and gethui()) or game:GetService("CoreGui")
if coreGui:FindFirstChild("TargetInfoHUD") then
	coreGui.TargetInfoHUD:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TargetInfoHUD"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
	screenGui.Parent = coreGui
end)

local mainFrame = Instance.new("CanvasGroup")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 120)
mainFrame.Position = UDim2.new(0.5, 0, 1, -100)
mainFrame.AnchorPoint = Vector2.new(0.5, 1)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.GroupTransparency = 1
mainFrame.Parent = screenGui

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1.0
uiScale.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Thickness = 3
uiStroke.Parent = mainFrame

local strokeGradient = Instance.new("UIGradient")
strokeGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromHex("7e48a3")),
	ColorSequenceKeypoint.new(0.5, Color3.fromHex("b222b2")),
	ColorSequenceKeypoint.new(1, Color3.fromHex("7e48a3")),
})
strokeGradient.Rotation = 0
strokeGradient.Parent = uiStroke

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local scanlines = Instance.new("ImageLabel")
scanlines.Name = "Scanlines"
scanlines.Size = UDim2.new(1, 0, 1, 0)
scanlines.BackgroundTransparency = 1
scanlines.Image = "rbxassetid://7114833477"
scanlines.ImageTransparency = 0.65
scanlines.ScaleType = Enum.ScaleType.Tile
scanlines.TileSize = UDim2.new(1, 0, 0, 6)
scanlines.ZIndex = 10
scanlines.Parent = mainFrame

local avatarImage = Instance.new("ImageLabel")
avatarImage.Name = "Avatar"
avatarImage.Size = UDim2.new(0, 90, 0, 90)
avatarImage.Position = UDim2.new(0, 15, 0.5, 0)
avatarImage.AnchorPoint = Vector2.new(0, 0.5)
avatarImage.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
avatarImage.Parent = mainFrame

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(1, 0)
avatarCorner.Parent = avatarImage

local avatarStroke = Instance.new("UIStroke")
avatarStroke.Color = Color3.fromHex("7e48a3")
avatarStroke.Thickness = 2.5
avatarStroke.Parent = avatarImage

local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.Size = UDim2.new(0, 3, 1, -30)
divider.Position = UDim2.new(0, 117, 0.5, 0)
divider.AnchorPoint = Vector2.new(0.5, 0.5)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

local dividerGradient = Instance.new("UIGradient")
dividerGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 15)),
	ColorSequenceKeypoint.new(0.2, Color3.fromHex("7e48a3")),
	ColorSequenceKeypoint.new(0.8, Color3.fromHex("b222b2")),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15)),
})
dividerGradient.Rotation = 90
dividerGradient.Parent = divider

local infoFrame = Instance.new("Frame")
infoFrame.Name = "Info"
infoFrame.Size = UDim2.new(1, -135, 1, -20)
infoFrame.Position = UDim2.new(0, 125, 0.5, 0)
infoFrame.AnchorPoint = Vector2.new(0, 0.5)
infoFrame.BackgroundTransparency = 1
infoFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = infoFrame

local function createHUDText(name, order, size, defaultText)
	local t = Instance.new("TextLabel")
	t.Name = name
	t.Size = UDim2.new(1, 0, 0, size)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.Arcade
	t.TextSize = size
	t.Text = defaultText
	t.TextColor3 = Color3.fromRGB(240, 240, 240)
	t.TextStrokeTransparency = 0.2
	t.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.RichText = true
	t.LayoutOrder = order
	t.Parent = infoFrame
	return t
end

local nameText = createHUDText("NameText", 1, 20, "PLAYER1")
nameText.TextColor3 = Color3.fromHex("7e48a3")

local hpContainer = Instance.new("Frame")
hpContainer.Name = "HPContainer"
hpContainer.Size = UDim2.new(1, -10, 0, 14)
hpContainer.BackgroundTransparency = 0.5
hpContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hpContainer.BorderSizePixel = 0
hpContainer.LayoutOrder = 2
hpContainer.Parent = infoFrame

local hpContainerCorner = Instance.new("UICorner")
hpContainerCorner.CornerRadius = UDim.new(0, 4)
hpContainerCorner.Parent = hpContainer

local hpFill = Instance.new("Frame")
hpFill.Name = "Fill"
hpFill.Size = UDim2.new(1, 0, 1, 0)
hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
hpFill.BorderSizePixel = 0
hpFill.Parent = hpContainer

local hpFillCorner = Instance.new("UICorner")
hpFillCorner.CornerRadius = UDim.new(0, 4)
hpFillCorner.Parent = hpFill

local hpText = createHUDText("HPText", 1, 14, "100 / 100")
hpText.Size = UDim2.new(1, 0, 1, 0)
hpText.Parent = hpContainer
hpText.TextXAlignment = Enum.TextXAlignment.Center
hpText.ZIndex = 2

local kdrText = createHUDText("KDRText", 3, 14, '<font color="#7e48a3">KDR:</font> 0.00')
local timeText = createHUDText("TimeText", 4, 14, '<font color="#7e48a3">PLAYTIME:</font> 00:00:00')
local weaponText = createHUDText("WeaponText", 5, 14, '<font color="#7e48a3">WEAPON:</font> UNARMED')

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
	if
		(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
		and not TargetHUDManager.Locked
	then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position =
			UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		getgenv().Config.ESP.TargetInfoHUDX = mainFrame.Position.X.Offset
		getgenv().Config.ESP.TargetInfoHUDY = mainFrame.Position.Y.Offset
	end
end)

local isFadingOut = false
local visibilityTween = nil
function TargetHUDManager.SetVisibility(val)
	if val then
		if mainFrame.GroupTransparency > 0 then
			mainFrame.Visible = true
			isFadingOut = false
			if visibilityTween then
				visibilityTween:Cancel()
			end
			visibilityTween = TweenService:Create(
				mainFrame,
				TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{ GroupTransparency = 0 }
			)
			visibilityTween:Play()
		end
	else
		if mainFrame.GroupTransparency < 1 and not isFadingOut then
			isFadingOut = true
			if visibilityTween then
				visibilityTween:Cancel()
			end
			visibilityTween = TweenService:Create(
				mainFrame,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ GroupTransparency = 1 }
			)
			visibilityTween:Play()
			task.spawn(function()
				visibilityTween.Completed:Wait()
				if isFadingOut then
					mainFrame.Visible = false
				end
			end)
		end
	end
end

-- Continuous Animation Loop
local scanlineOffset = 0
local animConnection
if animConnection then
	animConnection:Disconnect()
end
animConnection = RunService.RenderStepped:Connect(function(dt)
	if not mainFrame or not mainFrame.Parent then
		animConnection:Disconnect()
		return
	end
	if mainFrame.Visible and mainFrame.GroupTransparency < 1 then
		strokeGradient.Rotation = (strokeGradient.Rotation + (dt * 150)) % 360
		scanlineOffset = (scanlineOffset + (dt * 45)) % 6
		scanlines.Position = UDim2.new(0, 0, 0, scanlineOffset)
		mainFrame.Rotation = math.sin(os.clock() * 4) * 2.5
	end
end)

-- Caches to avoid Roblox layout recalculation lag and Tween allocation spam
local StateCache = {
	TextSize = -1,
	Health = -1,
	MaxHealth = -1,
	Kills = -1,
	Deaths = -1,
	TimePlayed = -1,
	WeaponName = "",
	PlayerName = "",
	UserId = -1,
}

local currentHealthTween = nil

function TargetHUDManager.Update()
	local config = getgenv().Config.ESP
	local target = TargetManager.CurrentTarget

	if not config.TargetInfoHUD or not target or not target.Character or not target.Player then
		TargetHUDManager.SetVisibility(false)
		return
	end

	-- Dynamically scale based on HUDSize ONLY if changed
	local hScale = config.TargetInfoHUDSize or 1.0
	if StateCache.TextSize ~= hScale then
		StateCache.TextSize = hScale
		uiScale.Scale = hScale
	end

	TargetHUDManager.SetVisibility(true)
	TargetHUDManager.Locked = config.LockTargetInfoHUD

	if config.TargetInfoHUDX and config.TargetInfoHUDY and not dragging then
		mainFrame.Position = UDim2.new(0.5, config.TargetInfoHUDX, 1, config.TargetInfoHUDY)
	end

	-- Name and Avatar Update
	local currentName = target.Player.Name
	local currentUserId = target.Player.UserId
	if StateCache.PlayerName ~= currentName then
		StateCache.PlayerName = currentName
		nameText.Text = currentName
	end
	if StateCache.UserId ~= currentUserId then
		StateCache.UserId = currentUserId
		avatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. currentUserId .. "&w=420&h=420"
	end

	-- Health Update
	local hum = target.Character:FindFirstChild("Humanoid")
	if hum then
		local h = math.floor(hum.Health)
		local mh = math.floor(hum.MaxHealth)
		if StateCache.Health ~= h or StateCache.MaxHealth ~= mh then
			StateCache.Health = h
			StateCache.MaxHealth = mh
			hpText.Text = string.format("%d / %d", h, mh)

			local healthPercent = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
			local targetColor = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 100), healthPercent)
			if currentHealthTween then
				currentHealthTween:Cancel()
			end
			currentHealthTween =
				TweenService:Create(hpFill, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(healthPercent, 0, 1, 0),
					BackgroundColor3 = targetColor,
				})
			currentHealthTween:Play()
		end
	else
		if StateCache.Health ~= -1 then
			StateCache.Health = -1
			hpText.Text = "??? / ???"
			hpFill.Size = UDim2.new(0, 0, 1, 0)
		end
	end

	-- Stats Update
	local kills, deaths, timePlayed = 0, 1, 0
	local weaponName = "UNARMED"

	if not PlayersFolder then
		PlayersFolder = ReplicatedStorage:FindFirstChild("Players")
	end

	if PlayersFolder then
		local rp_plr = PlayersFolder:FindFirstChild(target.Player.Name)
		if rp_plr then
			local status = rp_plr:FindFirstChild("Status")
			if status then
				local journey = status:FindFirstChild("Journey")
				if journey then
					local stats = journey:FindFirstChild("Statistics")
					if stats then
						kills = stats:GetAttribute("Kills") or 0
						deaths = stats:GetAttribute("Deaths") or 1
						if deaths <= 0 then
							deaths = 1
						end
						timePlayed = stats:GetAttribute("TimePlayed") or 0
					end
				end

				local gameplayVars = status:FindFirstChild("GameplayVariables")
				if gameplayVars then
					local equippedTool = gameplayVars:FindFirstChild("EquippedTool")
					if equippedTool and equippedTool.Value then
						weaponName = equippedTool.Value.Name
					end
				end
			end
		end
	end

	if weaponName == "UNARMED" then
		local tool = target.Character:FindFirstChildOfClass("Tool")
		if tool then
			weaponName = tool.Name
		end
	end

	if StateCache.Kills ~= kills or StateCache.Deaths ~= deaths then
		StateCache.Kills = kills
		StateCache.Deaths = deaths
		kdrText.Text = string.format('<font color="#7e48a3">KDR:</font> %d/%d (%.2f)', kills, deaths, kills / deaths)
	end

	if StateCache.TimePlayed ~= timePlayed then
		StateCache.TimePlayed = timePlayed
		local hTime = math.floor(timePlayed / 3600)
		local mTime = math.floor((timePlayed % 3600) / 60)
		local sTime = math.floor(timePlayed % 60)
		timeText.Text = string.format('<font color="#7e48a3">PLAYTIME:</font> %02d:%02d:%02d', hTime, mTime, sTime)
	end

	if StateCache.WeaponName ~= weaponName then
		StateCache.WeaponName = weaponName
		weaponText.Text = '<font color="#7e48a3">WEAPON:</font> ' .. string.upper(weaponName)
	end
end

local forceRenderDebounce = {}
local renderConnection = RunService.RenderStepped:Connect(function()
	pcall(UpdateViewmodelRender)
	WorldModsManager.Update()
	ESPManager.Update()
	CombatManager.Update()
	BulletTracerManager.Update()
	KeybindHUDManager.Update()
	if getgenv().TargetHUDManager then
		getgenv().TargetHUDManager.Update()
	end

	if getgenv().Config.ESP.ForceRender then
		local rp_players = game:GetService("ReplicatedStorage"):FindFirstChild("Players")
		local my_char = LocalPlayer.Character
		local my_pos = my_char and my_char:FindFirstChild("HumanoidRootPart") and my_char.HumanoidRootPart.Position

		if rp_players and my_pos then
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and (not p.Character or not p.Character:FindFirstChild("HumanoidRootPart")) then
					local rp_plr = rp_players:FindFirstChild(p.Name)
					local status = rp_plr and rp_plr:FindFirstChild("Status")
					local uac = status and status:FindFirstChild("UAC")
					local pos = uac and uac:GetAttribute("LastVerifiedPos")

					if pos and typeof(pos) == "Vector3" then
						local dist = (pos - my_pos).Magnitude
						if dist <= 12000 then -- 12000 studs ~ 3360 meters
							local now = tick()
							if not forceRenderDebounce[p] or (now - forceRenderDebounce[p] > 1.5) then
								forceRenderDebounce[p] = now
								task.spawn(function()
									pcall(function()
										LocalPlayer:RequestStreamAroundAsync(pos, 0.5)
									end)
								end)
							end
						end
					end
				end
			end
		end
	end

	if getgenv()._TPKillActive and getgenv().Config.Combat.TPKill then
		local tpTarget = getgenv()._TPKillTarget
		if tpTarget and tpTarget.Parent and tick() - getgenv()._TPKillStartTime < 3 then
			local char = LocalPlayer.Character
			local hrp = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
			if hrp then
				local height = getgenv().Config.Combat.TPKillHeight or 200
				local tpType = getgenv().Config.Combat.TPKillType
				local newPos

				if tpType == 2 or tpType == "Below" then
					local undergroundDist = math.min(80, height)
					local safeY = tpTarget.Position.Y - undergroundDist
					if safeY <= -3 then
						safeY = -3 + 5
					end
					newPos = tpTarget.Position + Vector3.new(0, safeY - tpTarget.Position.Y, 0)
				else
					newPos = tpTarget.Position + Vector3.new(0, height, 0)
				end
				getgenv()._TPKillPos = newPos

				local lookTargetPos = tpTarget.Position
				if tpTarget.Parent and tpTarget.Parent:FindFirstChild("Head") then
					lookTargetPos = tpTarget.Parent.Head.Position
				end
				-- Only look horizontally, let UpdateTilt handle vertical aiming
				local horizontalTarget = Vector3.new(lookTargetPos.X, newPos.Y, lookTargetPos.Z)
				if (horizontalTarget - newPos).Magnitude < 0.001 then
					horizontalTarget = newPos + Vector3.new(1, 0, 0)
				end
				hrp.CFrame = CFrame.lookAt(newPos, horizontalTarget)
				hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

				if getgenv()._TPKillPlatform then
					getgenv()._TPKillPlatform.CFrame = CFrame.new(newPos - Vector3.new(0, 3, 0))
				end

				-- Wait for the player's position to replicate to the server based on ping
				if not getgenv()._tpkill_ready then
					if not getgenv()._tpkill_waiting then
						getgenv()._tpkill_waiting = true
						task.spawn(function()
							local stats = game:GetService("Stats")
							local network = stats:FindFirstChild("Network")
							local ping = 0.05
							if network then
								local serverStatsItem = network:FindFirstChild("ServerStatsItem")
								if serverStatsItem then
									local dataPing = serverStatsItem:FindFirstChild("Data Ping")
									if dataPing then
										ping = dataPing:GetValue() / 1000
									end
								end
							end

							-- Wait strictly for physics replication to arrive on the server.
							-- Polling LastVerifiedPos takes too long (2s delay), causing the target to move and the shot to miss.
							task.wait(math.clamp(ping, 0.05, 0.2) + 0.03)

							getgenv()._tpkill_ready = true
							getgenv()._tpkill_waiting = false
						end)
					end
				else
					-- Ensure we are still active and target still exists after the wait
					if getgenv()._TPKillActive and getgenv()._TPKillTarget and getgenv()._TPKillTarget.Parent then
						-- Fire AFTER teleporting and waiting so FireProjectile is dispatched from the sky
						if not getgenv()._trigger_held then
							getgenv()._trigger_held = true
							if getgenv()._DeltaNativePress then
								getgenv()._DeltaNativePress(getgenv()._DeltaActiveWeaponTable)
							end
						end
					end
				end
			end
		elseif getgenv()._TPKillActive then
			-- Timeout or target lost, deactivate
			if getgenv().AddLog then
				getgenv().AddLog("[TPKill] Deactivated (Target lost or 3s timeout reached)")
			end

			if getgenv()._trigger_held then
				getgenv()._trigger_held = false
				if getgenv()._DeltaNativeRelease then
					getgenv()._DeltaNativeRelease(getgenv()._DeltaActiveWeaponTable)
				end
			end

			-- Safely and immediately restore position to prevent Noclip detected
			local char = LocalPlayer.Character
			local hrp = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
			if hrp and getgenv()._TPKillOriginalCFrame then
				hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				hrp.CFrame = getgenv()._TPKillOriginalCFrame + Vector3.new(0, 2, 0)
			end

			if getgenv().Toggles and getgenv().Toggles.TPKill then
				getgenv().Toggles.TPKill:SetValue(false)
			end
		end
	end
end)
table.insert(ConnectionList, renderConnection)

-- High priority camera and character overrides for TPKill
RunService:BindToRenderStep("DeltaTPKillCameraLock", 201, function()
	local cam = Workspace.CurrentCamera
	if getgenv()._TPKillActive and getgenv()._TPKillTarget then
		if cam then
			local tpTarget = getgenv()._TPKillTarget
			local lookTargetPos = tpTarget.Position
			if tpTarget.Parent and tpTarget.Parent:FindFirstChild("Head") then
				lookTargetPos = tpTarget.Parent.Head.Position
			end
			cam.CFrame = CFrame.lookAt(cam.CFrame.Position, lookTargetPos)
		end
	end
end)

-- Extreme priority camera and character overrides for ThirdPersonMod
RunService:BindToRenderStep("DeltaThirdPersonMod", 10000, function()
	if getgenv()._TPKillActive then
		return
	end -- Do not run ThirdPersonMod when TPKill is active

	if getgenv().Config.Mods.ThirdPerson then
		local char = Workspace:FindFirstChild(LocalPlayer.Name)
		local cam = Workspace.CurrentCamera
		if char and cam then
			local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("RootPart") or char.PrimaryPart
			local head = char:FindFirstChild("Head")
			local zoomDist = getgenv().Config.Mods.ZoomDistance or 15

			if root then
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.AutoRotate = false
				end

				local lookVector = cam.CFrame.LookVector
				local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z)
				if flatLook.Magnitude > 0 then
					root.CFrame = CFrame.lookAt(root.Position, root.Position + flatLook)
				end
			end

			if head then
				local camRot = cam.CFrame - cam.CFrame.Position
				cam.CFrame = CFrame.new(head.Position) * camRot * CFrame.new(1.5, 1.5, zoomDist)
			end

			-- Force the character model to be visible (bypasses Roblox's native first-person invisibility)
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.LocalTransparencyModifier = 0
				end
			end
		end
	else
		-- (Removed legacy reset)
	end
end)

local currentSpiderTween = nil
local currentSpiderConn = nil
local currentSpiderValue = nil

table.insert(
	ConnectionList,
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if UserInputService:GetFocusedTextBox() then
			return
		end

		local combatConfig = getgenv().Config.Combat
		local silentAimConfig = getgenv().Config.SilentAim

		if
			silentAimConfig
			and silentAimConfig.UndergroundResolverKeybind
			and input.KeyCode.Name == silentAimConfig.UndergroundResolverKeybind
		then
			if getgenv()._UndergroundResolverActive or getgenv()._SkyPeekActive then
				return
			end
			local character = Workspace:FindFirstChild(LocalPlayer.Name)
			if not character then
				return
			end
			local hrp = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
			if not hrp then
				return
			end

			local startCFrame = (getgenv().Config.Combat.UndergroundDesync or getgenv().Config.Combat.AntiAim)
					and getgenv()._StoredRealCFrame
				or hrp.CFrame

			local distance = silentAimConfig.UndergroundDistance or 20

			if getgenv().Config.Combat.UndergroundDesync and game.PlaceId ~= 97143334217269 then
				local preferredTargetY = startCFrame.Position.Y - distance
				local hardcodedTerrainY = -3

				-- If the preferred distance pushes us into or below the hardcoded terrain layer,
				-- stop 5 studs above it to avoid void-falling.
				if preferredTargetY <= hardcodedTerrainY then
					distance = startCFrame.Position.Y - (hardcodedTerrainY + 5)
				end
			end

			local targetCFrame = startCFrame - Vector3.new(0, distance, 0)

			local duration = silentAimConfig.UndergroundDuration or 1.0
			if getgenv().Config.Combat.UndergroundDesync then
				duration = 2.0
			end

			local cfValue = Instance.new("CFrameValue")
			cfValue.Value = startCFrame

			local tweenDown = _TweenService:Create(
				cfValue,
				TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{ Value = targetCFrame }
			)

			if getgenv().Config.Mods and getgenv().Config.Mods.NoFallDamage then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					local oldFreefall = humanoid:GetStateEnabled(Enum.HumanoidStateType.Freefall)
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
					task.delay(duration + 0.5, function()
						humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, oldFreefall)
					end)
				end
			end

			local velocityConn = nil
			velocityConn = RunService.Heartbeat:Connect(function()
				if hrp and hrp.Parent then
					hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				end
			end)

			local conn = cfValue.Changed:Connect(function(val)
				if getgenv().Config.Combat.UndergroundDesync or getgenv().Config.Combat.AntiAim then
					getgenv()._StoredRealCFrame = val
				else
					hrp.CFrame = val
				end
			end)

			getgenv()._UndergroundResolverActive = true
			getgenv()._UGRVisualDepth = nil

			-- REVERTED ANCHOR: Anchoring here breaks damage registration because anchored
			-- parts don't replicate their physics state to the server.
			-- Instead, we leave them unanchored but use `velocityConn` to continuously kill
			-- any velocity buildup from terrain collisions, preventing RNG void falls.
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
			end

			tweenDown:Play()
			tweenDown.Completed:Connect(function()
				-- Destroy BEFORE Disconnect: prevents a ghost .Changed firing with an underground
				-- interpolated value on 'conn' after we've already stopped caring about it.
				cfValue:Destroy()
				conn:Disconnect()
				if velocityConn then
					velocityConn:Disconnect()
					velocityConn = nil
				end

				-- Raycast downward from startCFrame to find the true terrain surface.
				-- Cast origin is 4 studs above to handle terrain that rose (slopes, rocks).
				local safeReturnCFrame = startCFrame
				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = { character }
				rayParams.FilterType = Enum.RaycastFilterType.Exclude
				rayParams.IgnoreWater = true
				rayParams.RespectCanCollide = true
				local origin = startCFrame.Position + Vector3.new(0, 4, 0)
				local rayResult = workspace:Raycast(origin, Vector3.new(0, -15, 0), rayParams)

				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if rayResult then
					local surfaceY = rayResult.Position.Y
					local hipHeight = 2
					if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
						hipHeight = humanoid.HipHeight
					end
					-- R15 and R6 generally place HRP ~3 studs above feet
					local rootHeight = hipHeight + (hrp.Size.Y / 2)
					local safeY = surfaceY + rootHeight
					local p = startCFrame.Position

					-- Remove any pitch/roll that might clip corners into the terrain
					local look = startCFrame.LookVector
					local flatLook = Vector3.new(look.X, 0, look.Z).Unit
					if flatLook.Magnitude < 0.1 then
						flatLook = Vector3.new(0, 0, -1)
					end
					safeReturnCFrame = CFrame.lookAt(
						Vector3.new(p.X, safeY, p.Z),
						Vector3.new(p.X + flatLook.X, safeY, p.Z + flatLook.Z)
					)
				else
				end

				if getgenv().Config.Combat.UndergroundDesync then
					-- Instead of snapping instantly (which the server rejects as a teleport, causing a rubberband back underground),
					-- we tween back up over 0.5s to trick the anti-cheat into accepting the movement as valid velocity.
					local cfValueUp = Instance.new("CFrameValue")
					cfValueUp.Value = hrp.CFrame

					local tweenUp = _TweenService:Create(
						cfValueUp,
						TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{ Value = safeReturnCFrame }
					)

					local connUp = cfValueUp.Changed:Connect(function(val)
						if getgenv().Config.Combat.UndergroundDesync or getgenv().Config.Combat.AntiAim then
							getgenv()._StoredRealCFrame = val
						else
							hrp.CFrame = val
						end
					end)

					getgenv()._DesyncOffsetSuppressed = true

					tweenUp:Play()
					tweenUp.Completed:Connect(function()
						cfValueUp:Destroy()
						connUp:Disconnect()

						hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

						if hrp and hrp.Parent then
							hrp.CFrame = safeReturnCFrame
							hrp.Anchored = false
						end

						if getgenv().Config.Combat.UndergroundDesync or getgenv().Config.Combat.AntiAim then
							getgenv()._StoredRealCFrame = safeReturnCFrame
						end

						if humanoid then
							humanoid:ChangeState(Enum.HumanoidStateType.Running)
						end

						getgenv()._UndergroundResolverActive = false
						getgenv()._LastGuardDeactivate = tick()

						-- Give physics 0.3s to land on the surface cleanly before applying the deep offset
						task.delay(0.3, function()
							getgenv()._DesyncOffsetSuppressed = false
						end)
					end)
				else
					-- Normal instantaneous snap-back when desync is off
					hrp.CFrame = safeReturnCFrame
					if getgenv().Config.Combat.UndergroundDesync or getgenv().Config.Combat.AntiAim then
						getgenv()._StoredRealCFrame = safeReturnCFrame
					end

					hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

					hrp.Anchored = true
					if humanoid then
						humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
					end

					task.delay(0.4, function()
						if hrp and hrp.Parent then
							hrp.Anchored = false
						end
						if humanoid then
							humanoid:ChangeState(Enum.HumanoidStateType.Running)
						end
						if hrp and hrp.Parent then
							hrp.CFrame = safeReturnCFrame
							hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
							hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
						end
						if getgenv().Config.Combat.UndergroundDesync or getgenv().Config.Combat.AntiAim then
							getgenv()._StoredRealCFrame = safeReturnCFrame
						end
						getgenv()._UndergroundResolverActive = false
						getgenv()._LastGuardDeactivate = tick()
					end)
				end
			end)
		end

		if combatConfig and combatConfig.SkyPeekKeybind and input.KeyCode.Name == combatConfig.SkyPeekKeybind then
			if getgenv()._SkyPeekActive or getgenv()._UndergroundResolverActive then
				return
			end
			local character = Workspace:FindFirstChild(LocalPlayer.Name)
			if not character then
				return
			end
			local hrp = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
			if not hrp then
				return
			end

			local startCFrame = (getgenv().Config.Combat.UndergroundDesync or getgenv().Config.Combat.AntiAim)
					and getgenv()._StoredRealCFrame
				or hrp.CFrame

			local distance = combatConfig.SkyPeekDistance or 20
			local targetCFrame = startCFrame + Vector3.new(0, distance, 0)
			local duration = combatConfig.SkyPeekDuration or 1.0

			local cfValue = Instance.new("CFrameValue")
			cfValue.Value = startCFrame

			local tweenUp = _TweenService:Create(
				cfValue,
				TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{ Value = targetCFrame }
			)

			if getgenv().Config.Mods and getgenv().Config.Mods.NoFallDamage then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					local oldFreefall = humanoid:GetStateEnabled(Enum.HumanoidStateType.Freefall)
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
					task.delay(duration + 0.5, function()
						humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, oldFreefall)
					end)
				end
			end

			local velocityConn = nil
			velocityConn = RunService.Heartbeat:Connect(function()
				if hrp and hrp.Parent then
					hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				end
			end)

			local conn = cfValue.Changed:Connect(function(val)
				if getgenv().Config.Combat.UndergroundDesync or getgenv().Config.Combat.AntiAim then
					getgenv()._StoredRealCFrame = val
				else
					hrp.CFrame = val
				end
			end)

			getgenv()._SkyPeekActive = true

			-- REVERTED ANCHOR: Keep unanchored for replication but freeze velocity
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
			end

			tweenUp:Play()
			tweenUp.Completed:Connect(function()
				cfValue:Destroy()
				conn:Disconnect()
				if velocityConn then
					velocityConn:Disconnect()
					velocityConn = nil
				end

				-- Raycast downward from startCFrame to find the true terrain surface.
				-- Cast origin is 4 studs above to handle terrain that rose (slopes, rocks).
				local safeReturnCFrame = startCFrame
				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = { character }
				rayParams.FilterType = Enum.RaycastFilterType.Exclude
				rayParams.IgnoreWater = true
				rayParams.RespectCanCollide = true
				local origin = startCFrame.Position + Vector3.new(0, 4, 0)
				local rayResult = workspace:Raycast(origin, Vector3.new(0, -15, 0), rayParams)

				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if rayResult then
					local surfaceY = rayResult.Position.Y
					local hipHeight = 2
					if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
						hipHeight = humanoid.HipHeight
					end
					-- R15 and R6 generally place HRP ~3 studs above feet
					local rootHeight = hipHeight + (hrp.Size.Y / 2)
					local safeY = surfaceY + rootHeight
					local p = startCFrame.Position

					-- Remove any pitch/roll that might clip corners into the terrain
					local look = startCFrame.LookVector
					local flatLook = Vector3.new(look.X, 0, look.Z).Unit
					if flatLook.Magnitude < 0.1 then
						flatLook = Vector3.new(0, 0, -1)
					end
					safeReturnCFrame = CFrame.lookAt(
						Vector3.new(p.X, safeY, p.Z),
						Vector3.new(p.X + flatLook.X, safeY, p.Z + flatLook.Z)
					)
				else
				end

				-- Apply snap atomically: hrp.CFrame and _StoredRealCFrame must match
				-- before the guard releases so Stepped doesn't re-embed into old position.
				hrp.CFrame = safeReturnCFrame
				if getgenv().Config.Combat.UndergroundDesync or getgenv().Config.Combat.AntiAim then
					getgenv()._StoredRealCFrame = safeReturnCFrame
				end

				hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

				-- Anchor briefly to kill any built-up collision momentum and reset state
				hrp.Anchored = true
				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
				end

				-- Defer flag release to ensure the server fully replicates the safe surface
				-- position before Heartbeat resumes applying the deep desync offset.
				task.delay(0.4, function()
					if hrp and hrp.Parent then
						hrp.Anchored = false
					end
					if humanoid then
						humanoid:ChangeState(Enum.HumanoidStateType.Running)
					end
					getgenv()._SkyPeekActive = false
					getgenv()._LastGuardDeactivate = tick()
				end)
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
			if currentSpiderConn then
				currentSpiderConn:Disconnect()
			end
			if currentSpiderValue then
				currentSpiderValue:Destroy()
			end

			local startCFrame = (getgenv().Config.Combat.UndergroundDesync or getgenv().Config.Combat.AntiAim)
					and getgenv()._StoredRealCFrame
				or hrp.CFrame

			local distance = 1000
			local speed = 18 -- 18 studs per second
			local targetCFrame = startCFrame + Vector3.new(0, distance, 0)

			currentSpiderValue = Instance.new("CFrameValue")
			currentSpiderValue.Value = startCFrame

			currentSpiderTween = _TweenService:Create(
				currentSpiderValue,
				TweenInfo.new(distance / speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
				{ Value = targetCFrame }
			)

			currentSpiderConn = currentSpiderValue.Changed:Connect(function(val)
				if getgenv().Config.Combat.UndergroundDesync or getgenv().Config.Combat.AntiAim then
					getgenv()._StoredRealCFrame = val
				else
					hrp.CFrame = val
				end
			end)

			currentSpiderTween:Play()
		end
	end)
)

table.insert(
	ConnectionList,
	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if UserInputService:GetFocusedTextBox() then
			return
		end
		local combatConfig = getgenv().Config.Combat

		if combatConfig.SpiderClimbKeybind and input.KeyCode.Name == combatConfig.SpiderClimbKeybind then
			if currentSpiderTween then
				currentSpiderTween:Cancel()
				currentSpiderTween = nil
			end
			if currentSpiderConn then
				currentSpiderConn:Disconnect()
				currentSpiderConn = nil
			end
			if currentSpiderValue then
				currentSpiderValue:Destroy()
				currentSpiderValue = nil
			end
		end
	end)
)

-- ==========================================
-- TriggerBot Manager (Native Weapon Flag, Mouse-Free)
-- ==========================================
local TriggerBotManager = {}
do
	local tbConnection = nil
	if getgenv()._trigger_held == nil then
		getgenv()._trigger_held = false
	end

	-- SUNC: Centralized native shoot helper.
	-- Writes directly to the weapon controller's fire flags, bypassing all mouse input.
	-- RapidFire forces FireMode to Auto on all weapons, so we only need to hold MouseHeld.
	local function nativePress(ctrl)
		if not ctrl then
			return
		end
		rawset(ctrl, "MouseHeld", true)
		rawset(ctrl, "LeftMouseDown", true)
	end
	local function nativeRelease(ctrl)
		if not ctrl then
			return
		end
		rawset(ctrl, "MouseHeld", false)
		rawset(ctrl, "LeftMouseDown", false)
	end
	-- Expose for TPKill / other subsystems
	getgenv()._DeltaNativePress = nativePress
	getgenv()._DeltaNativeRelease = nativeRelease

	function TriggerBotManager.Activate()
		if tbConnection then
			return true
		end

		tbConnection = RunService.RenderStepped:Connect(function()
			if not getgenv().Config.Combat.TriggerBot then
				if getgenv()._trigger_held and not getgenv()._TPKillActive then
					getgenv()._trigger_held = false
					nativeRelease(getgenv()._DeltaActiveWeaponTable)
				end
				return
			end

			if getgenv()._TPKillActive then
				return
			end

			local config = getgenv().Config.SilentAim
			local target = TargetManager.CurrentTarget
			local shouldShoot = false

			if target then
				local targetPartName = (config and config.TargetPart) or "Head"
				local aimPart = (target.Character and target.Character:FindFirstChild(targetPartName)) or target.Head

				if aimPart then
					local characterModel = (target.Player and target.Player.Character) or target.Head.Parent
					if CharacterManager.IsVisible(aimPart, characterModel) then
						local rootPart = characterModel:FindFirstChild("HumanoidRootPart")
						local hum = characterModel:FindFirstChildOfClass("Humanoid")
						local health = (rootPart and rootPart:GetAttribute("Health")) or (hum and hum.Health) or 0
						if health > 0 then
							shouldShoot = true
						end
					end
				end
			end

			local ctrl = getgenv()._DeltaActiveWeaponTable

			local canShoot = shouldShoot and type(ctrl) == "table"

			if canShoot then
				if not getgenv()._trigger_held then
					nativePress(ctrl)
					getgenv()._trigger_held = true
					getgenv()._trigger_last_press = os.clock()
				else
					local rapidFire = getgenv().Config and getgenv().Config.Combat and getgenv().Config.Combat.RapidFire
					if not rapidFire then
						if os.clock() - (getgenv()._trigger_last_press or 0) > 0.05 then
							nativeRelease(ctrl)
							getgenv()._trigger_held = false
						end
					end
				end
			else
				if getgenv()._trigger_held then
					nativeRelease(ctrl)
					getgenv()._trigger_held = false
				end
			end
		end)

		return true
	end

	function TriggerBotManager.Deactivate()
		if tbConnection then
			tbConnection:Disconnect()
			tbConnection = nil
		end
		if getgenv()._trigger_held then
			getgenv()._trigger_held = false
			nativeRelease(getgenv()._DeltaActiveWeaponTable)
		end
	end

	if getgenv().Toggles.TriggerBot then
		getgenv().Toggles.TriggerBot:OnChanged(function(value)
			getgenv().Config.Combat.TriggerBot = value
			if value then
				TriggerBotManager.Activate()
			else
				TriggerBotManager.Deactivate()
			end
		end)
	end

	getgenv()._TriggerBotDeactivate = TriggerBotManager.Deactivate
end

-- Removed SpringV2 hook as it was unoptimized and caused bugs by disabling core spring physics globally.

RunService:BindToRenderStep("DeltaNoScopeEnforcer", 3100, function()
	if getgenv().Config and getgenv().Config.Combat and getgenv().Config.Combat.NoScope then
		-- 1. Handle 2D ScreenEffects Scopes
		local sEffects = getgenv()._cachedScreenEffects
		if sEffects then
			local scopes = sEffects:FindFirstChild("Scopes")
			if scopes and scopes.Visible then
				scopes.Visible = false
				for _, child in ipairs(scopes:GetChildren()) do
					if child:IsA("GuiObject") and child.Visible then
						child.Visible = false
					end
				end
			end

			-- Legacy generic 2D fallback targets
			local targets = { "Scope", "ScopeFrame", "SightFrame", "Lens", "Reticle", "BlackScreen" }
			for _, name in ipairs(targets) do
				local obj = sEffects:FindFirstChild(name)
				if obj and obj.Visible then
					obj.Visible = false
				end
			end
		end

		local mFrame = getgenv()._cachedMainFrame
		if mFrame then
			local targets = { "Scope", "ScopeFrame", "SightFrame", "Lens", "Reticle", "BlackScreen" }
			for _, name in ipairs(targets) do
				local obj = mFrame:FindFirstChild(name)
				if obj and obj.Visible then
					obj.Visible = false
				end
			end
		end

		-- 2. Handle 3D ViewModel PIP Scopes (Optimized)
		local camera = workspace.CurrentCamera
		if camera then
			local vm = camera:FindFirstChild("ViewModel")
			local item = vm and vm:FindFirstChild("Item")
			local attachments = item and item:FindFirstChild("Attachments")
			local sight = attachments and attachments:FindFirstChild("Sight")
			if sight then
				for _, child in ipairs(sight:GetChildren()) do
					if (child:IsA("SurfaceGui") or child:IsA("BillboardGui")) and child.Enabled then
						child.Enabled = false
					elseif child.Name == "Reticle" then
						for _, subchild in ipairs(child:GetChildren()) do
							if (subchild:IsA("SurfaceGui") or subchild:IsA("BillboardGui")) and subchild.Enabled then
								subchild.Enabled = false
							end
						end
					end
				end
			end
		end
	end
end)

task.delay(1, function()
	getgenv()._DeltaScriptSilentToggles = false
end)
