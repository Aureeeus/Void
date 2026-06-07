if getgenv()._DeltaScriptCleanup then
	pcall(getgenv()._DeltaScriptCleanup)
end

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

	if getgenv().DeltaViewmodelChamsCache then
		for _, data in pairs(getgenv().DeltaViewmodelChamsCache) do
			pcall(function()
				data.Highlight:Destroy()
			end)
		end
	end
	getgenv().DeltaViewmodelChamsCache = {}

	if getgenv().DeltaViewmodelOriginalProps then
		for obj, props in pairs(getgenv().DeltaViewmodelOriginalProps) do
			pcall(function()
				if obj and obj.Parent then
					obj.Transparency = props.Transparency
					obj.Material = props.Material
					obj.Color = props.Color
					if obj:IsA("MeshPart") and props.TextureID then
						obj.TextureID = props.TextureID
					end
					if props.SpecMesh and props.SpecMeshTex then
						props.SpecMesh.TextureId = props.SpecMeshTex
					end
				end
			end)
		end
	end
	getgenv().DeltaViewmodelOriginalProps = {}
	getgenv().DeltaViewmodelAppliedProps = nil

	getgenv().DeltaInflictDumped = nil

	-- Restore original upvalues if InstantHit was active
	if getgenv()._InstantHitOriginalInflict and getgenv()._InstantHitCreateBulletFn then
		pcall(function()
			debug.setupvalue(getgenv()._InstantHitCreateBulletFn, 15, getgenv()._InstantHitOriginalInflict)
		end)
	end
	if getgenv()._InstantHitOriginalRicochet and getgenv()._InstantHitCreateBulletFn then
		pcall(function()
			debug.setupvalue(getgenv()._InstantHitCreateBulletFn, 14, getgenv()._InstantHitOriginalRicochet)
		end)
	end
	if getgenv()._InstantHitOriginalFireProj and getgenv()._InstantHitCreateBulletFn then
		pcall(function()
			debug.setupvalue(getgenv()._InstantHitCreateBulletFn, 11, getgenv()._InstantHitOriginalFireProj)
		end)
	end
	getgenv()._InstantHitCreateBulletFn = nil
	getgenv()._InstantHitOriginalInflict = nil
	getgenv()._InstantHitOriginalRicochet = nil
	getgenv()._InstantHitOriginalFireProj = nil

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
			ViewmodelBodyChams = false,
			ViewmodelBodyFillColor = Color3.fromRGB(255, 255, 255),
			ViewmodelBodyOutlineColor = Color3.fromRGB(255, 255, 255),
			ViewmodelGunChams = false,
			ViewmodelGunFillColor = Color3.fromRGB(255, 255, 255),
			ViewmodelGunOutlineColor = Color3.fromRGB(255, 255, 255),
			EnableGunSparkles = false,
			GunGlowIntensity = 0.8,
			ViewmodelChamsTransparency = 0.55,
			ViewmodelChamsEffect = 1,
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
			InstantHit = false,
			NoRecoil = false,
			NoSpread = false,
			InstantADS = false,
			ADSZoomMultiplier = 1.0,
			HideViewmodelOnADS = false,
			RapidFire = false,
			RapidFireValue = 3,
			UndergroundDesync = false,
			UndergroundDesyncKeybind = "U",
			AntiAim = false,
			AntiAimMethod = "Orbital Dodge",
			FlyKeybind = "T",
			SpiderClimbKeybind = "Y",
		},
		Mods = {
			ThirdPerson = false,
			ThirdPersonKeybind = "J",
			ZoomDistance = 15,
			FOV = 70,
			NoVisor = false,
			Fullbright = false,
			NoFog = false,
			NoFoliage = false,
			RemoveGrass = false,
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

ESPSection:AddToggle("Enable2DBoundingBox", {
	Text = "Enable 2D Bounding Box",
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

ESPSection:AddToggle("EnableHelicopterESP", {
	Text = "Enable Helicopter ESP",
	Default = getgenv().Config.ESP.HelicopterESPEnabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.HelicopterESPEnabled = value
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

local CharacterSection = VisualsTab:AddRightGroupbox("Character")

CharacterSection:AddToggle("EnableBodyChams", {
	Text = "Enable Body Chams",
	Default = getgenv().Config.ESP.ViewmodelBodyChams,
}):OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelBodyChams = value
end)

CharacterSection:AddDropdown("ViewmodelChamsEffect", {
	Values = { "None", "Breathing", "Chroma", "Both" },
	Default = getgenv().Config.ESP.ViewmodelChamsEffect,
	Multi = false,
	Text = "Effect Type",
})
getgenv().Options.ViewmodelChamsEffect:OnChanged(function(value)
	local map = { ["None"] = 1, ["Breathing"] = 2, ["Chroma"] = 3, ["Both"] = 4 }
	getgenv().Config.ESP.ViewmodelChamsEffect = map[value] or 1
end)

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

CharacterSection:AddLabel("Body Fill Color"):AddColorPicker("BodyChamsFillColor", {
	Default = getgenv().Config.ESP.ViewmodelBodyFillColor,
	Title = "Body Fill",
})
getgenv().Options.BodyChamsFillColor:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelBodyFillColor = value
end)

CharacterSection:AddLabel("Body Outline Color"):AddColorPicker("BodyChamsOutlineColor", {
	Default = getgenv().Config.ESP.ViewmodelBodyOutlineColor,
	Title = "Body Outline",
})
getgenv().Options.BodyChamsOutlineColor:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelBodyOutlineColor = value
end)

CharacterSection:AddDivider()

CharacterSection:AddToggle("EnableGunChams", {
	Text = "Enable Gun Chams",
	Default = getgenv().Config.ESP.ViewmodelGunChams,
}):OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelGunChams = value
end)

CharacterSection:AddLabel("Gun Fill Color"):AddColorPicker("GunChamsFillColor", {
	Default = getgenv().Config.ESP.ViewmodelGunFillColor,
	Title = "Gun Fill",
})
getgenv().Options.GunChamsFillColor:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelGunFillColor = value
end)

CharacterSection:AddLabel("Gun Outline Color"):AddColorPicker("GunChamsOutlineColor", {
	Default = getgenv().Config.ESP.ViewmodelGunOutlineColor,
	Title = "Gun Outline",
})
getgenv().Options.GunChamsOutlineColor:OnChanged(function(value)
	getgenv().Config.ESP.ViewmodelGunOutlineColor = value
end)

CharacterSection:AddDivider()

CharacterSection:AddToggle("EnableGunSparkles", {
	Text = "Enable Gun Sparkles",
	Default = getgenv().Config.ESP.EnableGunSparkles,
}):OnChanged(function(value)
	getgenv().Config.ESP.EnableGunSparkles = value
end)

CharacterSection:AddSlider("GunGlowIntensity", {
	Text = "Gun Glow Intensity",
	Default = getgenv().Config.ESP.GunGlowIntensity,
	Min = 0,
	Max = 1,
	Rounding = 2,
	Compact = false,
})
getgenv().Options.GunGlowIntensity:OnChanged(function(value)
	getgenv().Config.ESP.GunGlowIntensity = value
end)

CharacterSection:AddDivider() -- ==========================================
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

local AntiAimSection = CombatTab:AddLeftGroupbox("Anti Aim")

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
	Text = "Absolute Anti-Aim",
	Default = false,
}):OnChanged(function(value)
	getgenv().Config.Combat.AntiAim = value
	if not getgenv()._DeltaScriptSilentToggles and getgenv().LinoriaLibrary then
		if value then
			getgenv().LinoriaLibrary:Notify("Enabled Absolute Anti-Aim", 3)
		else
			getgenv().LinoriaLibrary:Notify("Disabled Absolute Anti-Aim", 3)
		end
	end
end)

AntiAimSection:AddDropdown("AntiAimMethod", {
	Values = { "Orbital Dodge", "Prediction Breaker", "Micro Jitter" },
	Default = 1,
	Multi = false,
	Text = "Anti-Aim Method",
})
getgenv().Options.AntiAimMethod:OnChanged(function(value)
	getgenv().Config.Combat.AntiAimMethod = value
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
	Compact = false,
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
	Min = 0.0,
	Max = 2.0,
	Rounding = 1,
	Compact = false,
})
getgenv().Options.HitsoundVolume:OnChanged(function(value)
	getgenv().Config.Mods.HitsoundVolume = value
end)

local WorldModsSection = ModsTab:AddRightGroupbox("World")

WorldModsSection:AddToggle("ThirdPerson", {
	Text = "Enable 3rd Person",
	Default = getgenv().Config.Mods.ThirdPerson,
}):AddKeyPicker("ThirdPersonKeybind", {
	Default = getgenv().Config.Mods.ThirdPersonKeybind or "J",
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "Enable 3rd Person",
	NoUI = false,
})
getgenv().Toggles.ThirdPerson:OnChanged(function(value)
	getgenv().Config.Mods.ThirdPerson = value
	if not getgenv()._DeltaScriptSilentToggles and getgenv().LinoriaLibrary then
		if value then
			getgenv().LinoriaLibrary:Notify("Enabled 3rd Person", 3)
		else
			getgenv().LinoriaLibrary:Notify("Disabled 3rd Person", 3)
		end
	end
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
	Compact = false,
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

WorldModsSection:AddToggle("NoVisor", {
	Text = "No Visor",
	Default = getgenv().Config.Mods.NoVisor,
}):OnChanged(function(value)
	getgenv().Config.Mods.NoVisor = value
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
	local isDesync = getgenv().Config.Combat.UndergroundDesync
	local isAntiAim = getgenv().Config.Combat.AntiAim

	if isDesync or isAntiAim then
		local Character = getTargetCharacter()
		if Character and getgenv()._StoredRealCFrame then
			local HRP = Character.HumanoidRootPart
			HRP.CFrame = getgenv()._StoredRealCFrame
		end
	else
		if getgenv()._StoredRealCFrame then
			local Character = getTargetCharacter()
			if Character and Character:FindFirstChild("HumanoidRootPart") then
				Character.HumanoidRootPart.CFrame = getgenv()._StoredRealCFrame
			end
			getgenv()._StoredRealCFrame = nil
		end
	end
end)

local desyncTick = 0

local heartbeatConnection = RunService.Heartbeat:Connect(function()
	local Character = getTargetCharacter()
	if Character then
		local HRP = Character.HumanoidRootPart

		local isDesync = getgenv().Config.Combat.UndergroundDesync
		local isAntiAim = getgenv().Config.Combat.AntiAim

		if isDesync or isAntiAim then
			getgenv()._StoredRealCFrame = HRP.CFrame
			getgenv()._realVelocity = HRP.AssemblyLinearVelocity
			getgenv()._realRotVelocity = HRP.AssemblyAngularVelocity

			if isAntiAim then
				local method = getgenv().Config.Combat.AntiAimMethod or "Orbital Dodge"
				
				if method == "Prediction Breaker" then
					local flip = (tick() * 10) % 2 > 1 and 1 or -1
					HRP.AssemblyLinearVelocity = Vector3.new(45 * flip, 0, 45 * flip)
					HRP.AssemblyAngularVelocity = Vector3.new(0, 50 * flip, 0)
					HRP.CFrame = getgenv()._StoredRealCFrame * CFrame.Angles(
						math.random() * math.pi * 2,
						math.random() * math.pi * 2,
						math.random() * math.pi * 2
					)
				elseif method == "Micro Jitter" then
					local offset = Vector3.new(math.random(-2, 2), math.random(-1, 1), math.random(-2, 2))
					HRP.CFrame = getgenv()._StoredRealCFrame * CFrame.new(offset) * CFrame.Angles(
						math.random() * math.pi * 2,
						math.random() * math.pi * 2,
						math.random() * math.pi * 2
					)
				else
					-- ORBITAL DODGE + AURA SPINBOT:
					-- Moving the center of mass in a fast, tight 2-stud orbit makes incoming projectiles cleanly miss!
					-- We raycast the offset to absolutely guarantee the fake position never clips into a wall, 
					-- completely preventing the physics engine from freezing or flinging you.
					local t = tick() * 15
					local offsetVector = Vector3.new(
						math.sin(t) * 2,
						math.sin(t * 1.3) * 2 + 2, -- 0 to 4 studs up
						math.cos(t) * 2
					)
					
					-- Wall collision prevention
					local rayOrigin = getgenv()._StoredRealCFrame.Position
					local rayParams = RaycastParams.new()
					rayParams.FilterDescendantsInstances = {Character}
					rayParams.FilterType = Enum.RaycastFilterType.Exclude
					
					local rayResult = workspace:Raycast(rayOrigin, offsetVector, rayParams)
					if rayResult then
						offsetVector = offsetVector.Unit * math.max(0, rayResult.Distance - 0.5)
					end

					HRP.CFrame = getgenv()._StoredRealCFrame * (isDesync and undergroundDesyncOffset or CFrame.new(offsetVector)) * CFrame.Angles(
						math.random() * math.pi * 2,
						math.random() * math.pi * 2,
						math.random() * math.pi * 2
					)
				end
			elseif isDesync then
				HRP.CFrame = getgenv()._StoredRealCFrame * undergroundDesyncOffset
			end

			desyncTick = desyncTick + 1
			if desyncTick >= 60 then
				if isAntiAim and getgenv().AddLog then
					local method = getgenv().Config.Combat.AntiAimMethod or "Orbital Dodge"
					getgenv().AddLog("Absolute Anti-Aim: " .. method .. " Active")
				end
				desyncTick = 0
			end
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
			if not checkcaller() then
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
						if char and char:FindFirstChild("Head") then
							local realCFrame = oldIndex(self, key)
							return CFrame.new(char.Head.Position, char.Head.Position + realCFrame.LookVector)
						end
					end
				end
				local isDesync = getgenv().Config.Combat.UndergroundDesync
				local isAntiAim = getgenv().Config.Combat.AntiAim
				
				if (isDesync or isAntiAim) and getgenv()._StoredRealCFrame then
					if key == "CFrame" or key == "Position" then
						local char = getTargetCharacter()
						if char and self == char:FindFirstChild("HumanoidRootPart") then
							spoofTick = spoofTick + 1
							if spoofTick >= 60 then
								spoofTick = 0
							end
							return key == "CFrame" and getgenv()._StoredRealCFrame
								or getgenv()._StoredRealCFrame.Position
						end
					end
				end
				if isAntiAim then
					if key == "AssemblyLinearVelocity" or key == "Velocity" then
						local char = getTargetCharacter()
						if char and self == char:FindFirstChild("HumanoidRootPart") then
							return getgenv()._realVelocity or Vector3.zero
						end
					elseif key == "AssemblyAngularVelocity" or key == "RotVelocity" then
						local char = getTargetCharacter()
						if char and self == char:FindFirstChild("HumanoidRootPart") then
							return getgenv()._realRotVelocity or Vector3.zero
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
				if method == "FireServer" or method == "InvokeServer" then
					local remoteName = tostring(self.Name)
					
					-- ABSOLUTE GOD MODE (NaN INJECTION)
					-- Project Delta relies on UpdateTilt to dynamically adjust the player's waist and spine Motor6Ds.
					-- By injecting 0/0 (NaN) into this remote while AntiAim is active, the server attempts to calculate
					-- a CFrame using an undefined number. This crashes the local replication of our hitboxes on the server,
					-- instantly turning our UpperTorso, Head, and Arms into 'NaN' invisible voids!
					-- Because SilentAim / InstantHit relies on locking onto the UpperTorso, their script will mathematically fail
					-- when it tries to aim at a target that effectively doesn't exist in the 3D space!
					if getgenv().Config.Combat.AntiAim and remoteName == "UpdateTilt" then
						setnamecallmethod(method)
						return oldNamecall(self, 0/0)
					end
					
					-- Always log the bullet creation and damage remotes so we can reverse engineer the structure
					-- Also log ALL remotes if Absolute Anti-Aim is active
					if ((remoteName == "ProjectileInflict" or remoteName == "FireProjectile") or getgenv().Config.Combat.AntiAim) and getgenv().AddLog then
						local args = { ... }
						local function dumpVar(v)
							if type(v) == "table" then
								local s = "{"
								for k2, v2 in pairs(v) do
									s = s
										.. tostring(k2)
										.. "="
										.. (type(v2) == "table" and "{...}" or tostring(v2))
										.. ", "
								end
								return s .. "}"
							elseif typeof(v) == "Instance" then
								return "Instance(" .. v.ClassName .. ":" .. v.Name .. ")"
							else
								return tostring(v)
							end
						end
						local argParts = {}
						for i, v in ipairs(args) do
							argParts[i] = string.format("[%d] (%s) %s", i, typeof(v), dumpVar(v))
						end
						getgenv().AddLog(
							"Remote Spy [" .. method .. "] " .. remoteName .. ":\n  " .. table.concat(argParts, "\n  ")
						)
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
			setclipboard(table.concat(getgenv().DebugLogs or {}, "\n"))
			Library:Notify("Successfully copied debug logs to clipboard.")
		end
	end,
	DoubleClick = false,
})

DebugSection:AddButton({
	Text = "Clear Debug Logs",
	Func = function()
		table.clear(getgenv().DebugLogs or {})
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
		safeSetToggle("EnableESP", data.ESP.Enabled)
		safeSetOption("ESPMaxDistance", data.ESP.MaxDistance)
		safeSetToggle("ShowHealthBar", data.ESP.ShowHealthBar)
		safeSetColorPicker("TextColor", parseColor(data.ESP.TextColor))
		safeSetColorPicker("OutlineColor", parseColor(data.ESP.OutlineColor))
		safeSetOption("TextSize", data.ESP.TextSize)

		if data.ESP.Font ~= nil then
			local fontMapReverse = { [0] = "UI", [1] = "System", [2] = "Plex", [3] = "Monospace" }
			safeSetOption("ESPFont", fontMapReverse[data.ESP.Font] or "Plex")
		end

		safeSetToggle("EnableChams", data.ESP.ChamsEnabled)
		safeSetColorPicker("ChamsFillColor", parseColor(data.ESP.ChamsFillColor))
		safeSetColorPicker("NPCChamsFillColor", parseColor(data.ESP.NPCChamsFillColor))
		safeSetColorPicker("ChamsOutlineColor", parseColor(data.ESP.ChamsOutlineColor))

		if data.ESP.BoundingBox2DEnabled ~= nil then
			safeSetToggle("Enable2DBoundingBox", data.ESP.BoundingBox2DEnabled)
		end
		if data.ESP.BoundingBox2DStyle ~= nil then
			safeSetOption("BoundingBox2DStyle", data.ESP.BoundingBox2DStyle)
		end
		if data.ESP.BoundingBox2DColor ~= nil then
			safeSetColorPicker("2DBoxColor", parseColor(data.ESP.BoundingBox2DColor))
		end

		safeSetToggle("VisibleCheck", data.ESP.VisibleCheck)
		safeSetColorPicker("VisibleColor", parseColor(data.ESP.VisibleColor))

		safeSetToggle("EnableBodyChams", data.ESP.ViewmodelBodyChams)
		safeSetColorPicker("BodyChamsFillColor", parseColor(data.ESP.ViewmodelBodyFillColor))
		safeSetColorPicker("BodyChamsOutlineColor", parseColor(data.ESP.ViewmodelBodyOutlineColor))

		safeSetToggle("EnableGunChams", data.ESP.ViewmodelGunChams)
		safeSetColorPicker("GunChamsFillColor", parseColor(data.ESP.ViewmodelGunFillColor))
		safeSetColorPicker("GunChamsOutlineColor", parseColor(data.ESP.ViewmodelGunOutlineColor))

		safeSetToggle("EnableGunSparkles", data.ESP.EnableGunSparkles)
		safeSetOption("GunGlowIntensity", data.ESP.GunGlowIntensity)

		safeSetOption("ViewmodelChamsTransparency", data.ESP.ViewmodelChamsTransparency)

		safeSetToggle("EnableNPCESP", data.ESP.NPCESPEnabled)
		safeSetColorPicker("NPCTextColor", parseColor(data.ESP.NPCTextColor))
		safeSetColorPicker("NPCOutlineColor", parseColor(data.ESP.NPCOutlineColor))

		safeSetToggle("EnableHelicopterESP", data.ESP.HelicopterESPEnabled)
		safeSetColorPicker("HelicopterTextColor", parseColor(data.ESP.HelicopterTextColor))
		safeSetColorPicker("HelicopterOutlineColor", parseColor(data.ESP.HelicopterOutlineColor))

		safeSetToggle("EnableCorpseESP", data.ESP.CorpseESPEnabled)
		safeSetColorPicker("CorpseTextColor", parseColor(data.ESP.CorpseTextColor))
		safeSetColorPicker("CorpseOutlineColor", parseColor(data.ESP.CorpseOutlineColor))

		safeSetToggle("EnableExitESP", data.ESP.ExitESPEnabled)
		safeSetColorPicker("ExitTextColor", parseColor(data.ESP.ExitTextColor))
		safeSetColorPicker("ExitOutlineColor", parseColor(data.ESP.ExitOutlineColor))

		safeSetToggle("EnableInventoryViewer", data.ESP.InventoryViewer)
	end

	if data.SilentAim then
		safeSetToggle("EnableBulletTracers", data.SilentAim.BulletTracers)
		safeSetToggle("TracerGlowEffect", data.SilentAim.TracerGlowEffect)
		safeSetOption("TracerType", data.SilentAim.TracerType)
		safeSetColorPicker("TracerColor", parseColor(data.SilentAim.TracerColor))
		safeSetOption("TracerTransparency", data.SilentAim.TracerTransparency)

		safeSetToggle("EnableSilentAim", data.SilentAim.Enabled)
		safeSetOption("SilentAimTargetType", data.SilentAim.TargetType)
		safeSetOption("SilentAimTargetPart", data.SilentAim.TargetPart)
		safeSetToggle("ShowFOVCircle", data.SilentAim.ShowFOV)
		safeSetOption("FOVType", data.SilentAim.FOVType)
		safeSetColorPicker("FOVColor", parseColor(data.SilentAim.FOVColor))
		safeSetOption("FOVRadius", data.SilentAim.FOVRadius)
		safeSetToggle("ShowSnapline", data.SilentAim.ShowSnapline)
		safeSetToggle("VisibleCheckSnapline", data.SilentAim.VisibleCheck)
		safeSetColorPicker("SnaplineColor", parseColor(data.SilentAim.VisibleColor))
	end

	if data.Combat then
		safeSetToggle("InstantHit", data.Combat.InstantHit)
		safeSetToggle("UndergroundDesync", false)
		safeSetKeyPicker("UndergroundDesyncKeybind", data.Combat.UndergroundDesyncKeybind, "Toggle")
		safeSetToggle("AntiAim", data.Combat.AntiAim)
		safeSetToggle("InstantADS", data.Combat.InstantADS)
		safeSetOption("ADSZoomMultiplier", data.Combat.ADSZoomMultiplier)
		safeSetToggle("HideViewmodelOnADS", data.Combat.HideViewmodelOnADS)
		safeSetKeyPicker("FlyKeybind", data.Combat.FlyKeybind, "Toggle")
		safeSetKeyPicker("SpiderClimbKeybind", data.Combat.SpiderClimbKeybind, "Hold")

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

		-- Always default ThirdPerson to false upon loading; only load its keybind
		safeSetToggle("ThirdPerson", false)
		safeSetKeyPicker("ThirdPersonKeybind", data.Mods.ThirdPersonKeybind, "Toggle")
		safeSetOption("ZoomDistance", data.Mods.ZoomDistance)
		safeSetToggle("Fullbright", data.Mods.Fullbright)
		safeSetToggle("NoFog", data.Mods.NoFog)
		safeSetToggle("NoFoliage", data.Mods.NoFoliage)
		safeSetToggle("RemoveGrass", data.Mods.RemoveGrass)
		safeSetToggle("NoVisor", data.Mods.NoVisor)
		safeSetOption("FOV", data.Mods.FOV)
	end

	if data.Utilities then
		safeSetToggle("ModDetector", data.Utilities.ModDetector)
	end

	if data.Theme and ThemeDropdown then
		ThemeDropdown:SetValue(data.Theme)
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
									if pilot:IsA("Model") and pilot:FindFirstChild("Head") then
										local root = pilot:FindFirstChild("HumanoidRootPart") or pilot.PrimaryPart or pilot:FindFirstChild("Head")
										

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

	if not CharacterManager.SharedIgnoreList then
		CharacterManager.SharedIgnoreList = { LocalPlayer.Character, characterModel }
		for _, v in ipairs(getgenv().CachedGlobalIgnoreList) do
			table.insert(CharacterManager.SharedIgnoreList, v)
		end
	end

	CharacterManager.SharedIgnoreList[1] = LocalPlayer.Character
	CharacterManager.SharedIgnoreList[2] = characterModel
	sharedRaycastParams.FilterDescendantsInstances = CharacterManager.SharedIgnoreList

	local result = Workspace:Raycast(origin, direction, sharedRaycastParams)

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

	if config.ShowKDR and playerData.Player and not playerData.IsCorpse and not playerData.IsExit and not playerData.IsNPC and not playerData.IsHelicopterESP and not playerData.IsHelicopter then
		local kills, deaths = StatsManager.GetPlayerKDR(playerData.Player.Name)
		local ratio = (deaths > 0) and (kills / deaths) or kills
		table.insert(textLines, string.format("KDR: %.2f", ratio))
	end

	return table.concat(textLines, "\n")
end

local espOffsetRoot = Vector3.new(0, 3, 0)
local espOffsetHead = Vector3.new(0, 1.5, 0)

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
	local activeHelicopterESP = (config.HelicopterESPEnabled or config.ChamsEnabled)
			and CharacterManager.GetHelicopterESP()
		or {}

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

	-- Chams ESP Cleanup
	for cachedCharacter, highlight in pairs(getgenv().DeltaChamsCache) do
		local isNPC = activeNPCs[cachedCharacter] ~= nil
		local isHeli = activeHelicopterESP[cachedCharacter] ~= nil
		local isStale = not activeCharacters[cachedCharacter]
			and not activeNPCs[cachedCharacter]
			and not activeHelicopterESP[cachedCharacter]
		local shouldRemove = isStale
			or not config.ChamsEnabled
			or (isNPC and not config.NPCESPEnabled)
			or (isHeli and not config.HelicopterESPEnabled)

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
			and (config.Enabled or config.ChamsEnabled or config.NPCESPEnabled or config.HelicopterESPEnabled)
		then
			local targetPartName = getgenv().Config.SilentAim.TargetPart or "Head"
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

			local screenPosition, isVisibleOnScreen = Camera:WorldToViewportPoint(data.Head.Position + espOffsetHead)
			local boxTopScreenPos = Camera:WorldToViewportPoint(data.Head.Position + Vector3.new(0, 0.5, 0))

			if isVisibleOnScreen and screenPosition.Z > 0 then
				local textStr = ESPManager.FormatPlayerText(data)

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
					screenLegs = Camera:WorldToViewportPoint(data.RootPart.Position - espOffsetRoot)
				else
					screenLegs = Vector3.new(screenPosition.X, screenPosition.Y + 30, 0)
				end

				if type(cacheData) == "table" and cacheData.DistanceText then
					if config.ShowDistance then
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
		end

		-- Handle Chams (Highlight)
		if config.ChamsEnabled and not data.IsCorpse and not data.IsExit and not data.IsHelicopterESP then
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
	for character, data in pairs(activeHelicopterESP) do
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
		local dist = (hitPos - origin).Magnitude
		local numParts = math.ceil(dist / 1000)
		local segmentDist = dist / numParts
		local cTrans = config.TracerTransparency
		if type(cTrans) ~= "number" then
			cTrans = 0.5
		end

		local partsTable = {}
		local glowPartsTable = {}

		for i = 1, numParts do
			local offset = segmentDist * (i - 0.5)
			local tracerPart = Instance.new("Part")
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
			tracerPart.Color = BulletTracerManager.ParseColor(config.TracerColor)
			tracerPart.Transparency = cTrans
			tracerPart.Parent = Workspace.Terrain
			table.insert(partsTable, tracerPart)

			if config.TracerGlowEffect then
				local glowPart = tracerPart:Clone()
				glowPart.Size = Vector3.new(segmentDist, 0.15, 0.15)
				glowPart.Transparency = math.clamp(cTrans + 0.3, 0, 1)
				glowPart.Parent = Workspace.Terrain
				table.insert(glowPartsTable, glowPart)
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
			if tracer.Parts then
				for _, p in ipairs(tracer.Parts) do
					p:Destroy()
				end
			end
			if tracer.GlowParts then
				for _, gp in ipairs(tracer.GlowParts) do
					gp:Destroy()
				end
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
			if tracer.Parts then
				for _, p in ipairs(tracer.Parts) do
					p.Color = cColor
					p.Transparency = cTrans
				end
			end
			if tracer.GlowBeam then
				tracer.GlowBeam.Color = cachedColor
				tracer.GlowBeam.Transparency = NumberSequence.new(math.clamp(cTrans + 0.3, 0, 1))
			end
			if tracer.GlowParts then
				for _, gp in ipairs(tracer.GlowParts) do
					gp.Color = cColor
					gp.Transparency = math.clamp(cTrans + 0.3, 0, 1)
				end
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
					getgenv().LastFiredAmmoName = ammoName
					local muzzleVelocity = (getgenv().DeltaVelocityCache and getgenv().DeltaVelocityCache[ammoName])
						or 3000

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

					local realOrigin = origin
					local serverOrigin = realOrigin
					if getgenv().Config.Combat.UndergroundDesync and getgenv()._StoredRealCFrame then
						serverOrigin = (getgenv()._StoredRealCFrame * CFrame.new(0, -3.8, 0)).Position
					end

					local aimPos

					local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if getgenv().AddLog then
						getgenv().AddLog(
							string.format(
								"[SilentAim Spy] Ammo: %s | MuzzleVel: %s | Target: %s",
								tostring(ammoName),
								tostring(muzzleVelocity),
								tostring(target.Name)
							)
						)
						getgenv().AddLog(
							string.format(
								"[SilentAim Spy] RealOrigin: %s | ServerOrigin: %s",
								tostring(realOrigin),
								tostring(serverOrigin)
							)
						)
					end

					if getgenv().Config.Combat.InstantHit then
						aimPos = targetAimPart.Position
						TargetManager.PredictedPosition = aimPos
						local perfectDir = (aimPos - realOrigin).Unit
						origin = aimPos - perfectDir * 0.5
						if getgenv().AddLog then
							getgenv().AddLog(
								string.format(
									"[InstantHit Spy] TargetPos: %s | Diff(Root, Target): %s",
									tostring(aimPos),
									myRoot and tostring((aimPos - myRoot.Position).Magnitude) or "nil"
								)
							)
						end
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

					if type(args[5]) == "table" then
						args[5].CFrame = CFrame.lookAt(origin, origin + clientAimDirection * 100)
					else
						args[5] = { CFrame = CFrame.lookAt(origin, origin + clientAimDirection * 100) }
					end

					if getgenv().Config.SilentAim.BulletTracers then
						BulletTracerManager.AddTracer(realOrigin, TargetManager.PredictedPosition)
					end
				else
					if getgenv().Config.Combat.NoRecoil then
						local origin = workspace.CurrentCamera.CFrame.Position
						local lookVector = workspace.CurrentCamera.CFrame.LookVector
						if type(args[5]) == "table" then
							args[5].CFrame = CFrame.lookAt(origin, origin + lookVector * 1000)
						else
							args[5] = { CFrame = CFrame.lookAt(origin, origin + lookVector * 1000) }
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
						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Exclude
						params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
						local result = Workspace:Raycast(origin, Camera.CFrame.LookVector * 5000, params)
						local hitPos = result and result.Position or (origin + Camera.CFrame.LookVector * 5000)
						BulletTracerManager.AddTracer(origin, hitPos)
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

	if method == "FireServer" then
		local selfName = typeof(self) == "Instance" and self.Name or ""
		if selfName == "ProjectileInflict" or selfName == "MeleeInflict" or selfName == "MeleeInfIict" then
			getgenv().LastDamageInflictedTime = tick()

			if getgenv().Config and getgenv().Config.Mods and getgenv().Config.Mods.Hitsound then
				local targetPart = args[1]
				if targetPart and typeof(targetPart) == "Instance" then
					local character = targetPart:FindFirstAncestorOfClass("Model")
					if character then
						local root = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart") or character
						local function getHealth()
							return root:GetAttribute("Health")
								or (character:FindFirstChildOfClass("Humanoid") and character:FindFirstChildOfClass(
									"Humanoid"
								).Health)
								or 100
						end

						local initialHealth = getHealth()
						task.spawn(function()
							local startTime = tick()
							while tick() - startTime < 1 do
								task.wait(0.05)
								local currentHealth = getHealth()
								if currentHealth < initialHealth then
									local now = tick()
									if
										not getgenv().LastCustomHitsound
										or (now - getgenv().LastCustomHitsound) > 0.05
									then
										getgenv().LastCustomHitsound = now
										if getgenv().HitsoundManager and getgenv().HitsoundManager.Play then
											getgenv().HitsoundManager.Play()
										end
									end
									break
								end
							end
						end)
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
			local name = self.Name

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

local cachedSettingsModules = {}
local function scanForModules(root, shouldLog)
	if not root then
		return
	end
	for _, desc in ipairs(root:GetDescendants()) do
		if desc:IsA("ModuleScript") and desc.Name == "SettingsModule" and desc.Parent then
			if not cachedSettingsModules[desc] then
				cachedSettingsModules[desc] = true
				if shouldLog and getgenv().AddLog then
					getgenv().AddLog(
						string.format(
							"[RapidFire] Found new SettingsModule in %s (Parent: %s)",
							root.Name,
							desc.Parent.Name
						)
					)
				end
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
			scanForModules(Workspace:FindFirstChild(LocalPlayer.Name), true)

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
							if getgenv().AddLog then
								getgenv().AddLog(
									string.format(
										"[RapidFire] Modified %s (Parent: %s) FireRate: %f -> %f",
										desc.Name,
										desc.Parent and desc.Parent.Name or "Unknown",
										stats.FireRate,
										newRate
									)
								)
							end
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
							if getgenv().AddLog then
								getgenv().AddLog(
									string.format(
										"[RapidFire] Restored %s (Parent: %s) FireRate: %f",
										desc.Name,
										desc.Parent and desc.Parent.Name or "Unknown",
										originalFireRates[desc]
									)
								)
							end
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

local WorldModsManager = {}

function WorldModsManager.Update()
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
	end

	if getgenv().Config.Mods.NoFog then
		if _Lighting.FogEnd ~= 100000 then
			_Lighting.FogEnd = 100000
		end
		local atmosphere = _Lighting:FindFirstChildOfClass("Atmosphere")
		if atmosphere and atmosphere.Density ~= 0 then
			atmosphere.Density = 0
		end
	end

	local visor = getgenv()._cachedVisorUI
	if not visor or not visor.Parent then
		local pGui = LocalPlayer:FindFirstChild("PlayerGui")
		local noInset = pGui and pGui:FindFirstChild("NoInsetGui")
		local mFrame = noInset and noInset:FindFirstChild("MainFrame")
		local sEffects = mFrame and mFrame:FindFirstChild("ScreenEffects")
		visor = sEffects and sEffects:FindFirstChild("Visor")
		getgenv()._cachedVisorUI = visor
	end

	if visor then
		if getgenv().Config.Mods.NoVisor then
			if visor.Visible then
				visor.Visible = false
				getgenv()._deltaVisorHidden = true
			end
		elseif getgenv()._deltaVisorHidden then
			visor.Visible = true
			getgenv()._deltaVisorHidden = false
		end
	end

	if getgenv().Config.Mods.FOV and getgenv().Config.Mods.FOV ~= 70 then
		if not getgenv().DeltaIsZooming then
			if Camera.FieldOfView ~= getgenv().Config.Mods.FOV then
				Camera.FieldOfView = getgenv().Config.Mods.FOV
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
	local remote = rs:FindFirstChild("ProjectileInflict", true)
	if remote then
		getgenv()._IH_InflictRemote = remote
		-- Log removed
	end
	return remote
end

function InstantHitManager.Activate()
	local inflict = getInflictRemote()
	if not inflict then
		Library:Notify("[InstantHit] ProjectileInflict remote not found.", 5)
		-- Log removed
		return false
	end

	local passedBullets = {}
	local forgedBullets = {}

	getgenv()._IH_Interceptor = function(method, remoteName, args)
		if not getgenv().Config.Combat.InstantHit and not getgenv().Config.SilentAim.Enabled then
			return false
		end

		if method == "InvokeServer" and remoteName == "FireProjectile" then
			if not getgenv().Config.Combat.InstantHit and getgenv().Config.SilentAim.Enabled then
				if getgenv().LastServerAimDirection then
					args[1] = getgenv().LastServerAimDirection
				end
				return false, nil, args
			end
			local bulletId = args[2]
			local fireTimestamp = args[3]
			if getgenv().AddLog then
				getgenv().AddLog(
					string.format(
						"[Remote Spy] InvokeServer FireProjectile | BulletId: %s | TS: %s",
						tostring(bulletId),
						tostring(fireTimestamp)
					)
				)
			end

			if TargetManager and TargetManager.CurrentTarget then
				local target = TargetManager.CurrentTarget
				local targetPartName = getgenv().Config.SilentAim and getgenv().Config.SilentAim.TargetPart or "Head"
				local targetAimPart = (target.Character and target.Character:FindFirstChild(targetPartName))
					or target.Head

				if targetAimPart then
					local origin = workspace.CurrentCamera.CFrame.Position
					local serverOrigin = origin
					if getgenv().Config.Combat.UndergroundDesync and getgenv()._StoredRealCFrame then
						serverOrigin = (getgenv()._StoredRealCFrame * CFrame.new(0, -3.8, 0)).Position
					end

					local ammoName = getgenv().LastFiredAmmoName or ""
					local v = (getgenv().DeltaVelocityCache and getgenv().DeltaVelocityCache[ammoName]) or 2500

					local distance = (targetAimPart.Position - serverOrigin).Magnitude
					local expectedFlightTime
					local perfectDirection

					local isUnderground = getgenv().Config.Combat.UndergroundDesync and getgenv()._StoredRealCFrame
					if isUnderground then
						-- The server evaluates Instant Hit raycasts without gravity, so we must shoot a mathematically perfect straight line.
						perfectDirection = (targetAimPart.Position - serverOrigin).Unit
						expectedFlightTime = distance / v
					else
						-- Original framework logic
						perfectDirection = (targetAimPart.Position - serverOrigin).Unit
						local safeVelocity = v * 0.85
						expectedFlightTime = distance / safeVelocity
					end

					args[1] = perfectDirection

					local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if getgenv().AddLog then
						getgenv().AddLog(
							string.format(
								"[IH Logic] Target Part: %s | Pos: %s",
								targetAimPart.Name,
								tostring(targetAimPart.Position)
							)
						)
						getgenv().AddLog(
							string.format(
								"[IH Logic] Server Origin: %s | Distance to Target: %s",
								tostring(serverOrigin),
								tostring(distance)
							)
						)
						if myRoot then
							local rootToTargetDist = (targetAimPart.Position - myRoot.Position).Magnitude
							getgenv().AddLog(
								string.format(
									"[IH Logic] RootPart Pos: %s | Root-to-Target Distance: %s",
									tostring(myRoot.Position),
									tostring(rootToTargetDist)
								)
							)
						end
					end

					-- 2. Timestamp Backdating:
					-- We make the server believe the bullet was fired in the past.
					local spoofedFireTimestamp = fireTimestamp - expectedFlightTime

					local hitWorldPos = targetAimPart.Position
					local bulletWorldCFrame = CFrame.lookAt(hitWorldPos, hitWorldPos + perfectDirection)
					local hitCFrame = targetAimPart.CFrame:ToObjectSpace(bulletWorldCFrame)

					-- Overwrite the outbound FireProjectile timestamp with our aged timestamp
					args[3] = spoofedFireTimestamp

					-- Silence the game's natural physics packets so we don't spam the server and get kicked
					forgedBullets[bulletId] = true

					-- ZERO DELAY: Send the damage packet in the exact same frame using task.defer
					task.defer(function()
						passedBullets[bulletId] = true
						-- Pass the CURRENT timestamp as the hit time.
						-- Server calculates FlightTime = Current (Hit) - Spoofed (Fire) = expectedFlightTime
						if getgenv().AddLog then
							getgenv().AddLog(
								string.format(
									"[Remote Spy] Spoofing ProjectileInflict:FireServer | BulletId: %s",
									tostring(bulletId)
								)
							)
						end
						inflict:FireServer(targetAimPart, hitCFrame, bulletId, fireTimestamp)

						-- Log removed
					end)

					return false, function() end, args
				end
			end
		elseif method == "FireServer" and remoteName == "ProjectileInflict" then
			local bulletId = args[3]
			if getgenv().AddLog then
				getgenv().AddLog(
					string.format(
						"[Remote Spy] Intercepted natural ProjectileInflict | BulletId: %s",
						tostring(bulletId)
					)
				)
			end

			if passedBullets[bulletId] then
				if getgenv().AddLog then
					getgenv().AddLog(
						string.format(
							"[Remote Spy] Allowed SPOOFED ProjectileInflict | BulletId: %s",
							tostring(bulletId)
						)
					)
				end
				passedBullets[bulletId] = nil
				return false -- Let our zero-delay packet through
			end

			if forgedBullets[bulletId] then
				if getgenv().AddLog then
					getgenv().AddLog(
						string.format(
							"[Remote Spy] Dropped NATURAL ProjectileInflict | BulletId: %s",
							tostring(bulletId)
						)
					)
				end
				return true -- DROP the natural physics packet to prevent anti-cheat kick
			end

			if getgenv().AddLog then
				getgenv().AddLog(
					string.format(
						"[Remote Spy] Allowed un-spoofed natural ProjectileInflict | BulletId: %s",
						tostring(bulletId)
					)
				)
			end
		end

		return false
	end

	-- Log removed

	return true
end

function InstantHitManager.Deactivate()
	getgenv()._IH_Interceptor = nil
	-- Log removed
end

-- Wire up the toggle
getgenv().Toggles.InstantHit:OnChanged(function(value)
	getgenv().Config.Combat.InstantHit = value

	if value then
		local success = InstantHitManager.Activate()
		if not success then
			task.spawn(function()
				getgenv().Toggles.InstantHit:SetValue(false)
			end)
		end
	else
		InstantHitManager.Deactivate()
	end
end)

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
	if getgenv().Config.Mods.ThirdPerson then
		isADS = true
	end

	local viewModel = camera:FindFirstChild("ViewModel")
	if viewModel and viewModel:IsA("Model") then
		local parts = getgenv().DeltaCachedViewmodelParts
		if not parts or getgenv().DeltaCachedViewmodelParent ~= viewModel then
			parts = {}
			for _, desc in ipairs(viewModel:GetDescendants()) do
				if desc:IsA("BasePart") then
					table.insert(parts, desc)
				end
			end
			getgenv().DeltaCachedViewmodelParts = parts
			getgenv().DeltaCachedViewmodelParent = viewModel
		end
		for _, desc in ipairs(parts) do
			desc.LocalTransparencyModifier = isADS and 1 or 0
		end
	end
end

local function UpdateViewmodelChams()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	if not getgenv().DeltaViewmodelChamsCache then
		getgenv().DeltaViewmodelChamsCache = {}
	end

	local isADS = false
	if getgenv().Config.Combat.HideViewmodelOnADS then
		isADS = getgenv().DeltaIsZooming == true
	end
	if getgenv().Config.Mods.ThirdPerson then
		isADS = true
	end

	local config = getgenv().Config.ESP
	local bodyEnabled = config.ViewmodelBodyChams and not isADS
	local gunEnabled = config.ViewmodelGunChams and not isADS

	local effect = config.ViewmodelChamsEffect or 1
	local isPulse = (effect == 2 or effect == 4)
	local isChroma = (effect == 3 or effect == 4)

	local rgbColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
	local pulseOffset = isPulse and ((math.sin(tick() * 4) + 1) / 2 * 0.4) or 0
	local baseTrans = math.clamp(config.ViewmodelChamsTransparency + pulseOffset, 0, 1)

	local activeTargets = {}
	local activeParts = {}

	local viewModel = camera:FindFirstChild("ViewModel")
	if bodyEnabled or gunEnabled then
		if viewModel and viewModel:IsA("Model") then
			if getgenv().DeltaCachedViewmodelParent ~= viewModel or not getgenv().DeltaCachedActiveTargets then
				getgenv().DeltaCachedViewmodelParent = viewModel
				getgenv().ViewmodelDebugCount = 0
				local tTargets, tParts = {}, {}
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
					if isBody then
						tTargets[desc] = "Body"
						if desc:IsA("BasePart") then
							tParts[desc] = "Body"
						else
							for _, sub in ipairs(desc:GetDescendants()) do
								if sub:IsA("BasePart") then
									tParts[sub] = "Body"
								end
							end
						end
					else
						tTargets[desc] = "Gun"
						if desc:IsA("BasePart") then
							tParts[desc] = "Gun"
						else
							for _, sub in ipairs(desc:GetDescendants()) do
								if sub:IsA("BasePart") then
									tParts[sub] = "Gun"
								end
							end
						end
					end
				end
				getgenv().DeltaCachedActiveTargets = tTargets
				getgenv().DeltaCachedActiveParts = tParts

				if not getgenv().ViewmodelDebugCount or getgenv().ViewmodelDebugCount < 1 then
					getgenv().ViewmodelDebugCount = (getgenv().ViewmodelDebugCount or 0) + 1
					getgenv().AddLog("--- DEBUG VIEWMODEL CHAMS ---")
					getgenv().AddLog("Found ViewModel")

					local gunParts = {}
					for p, typ in pairs(tParts) do
						if typ == "Gun" then
							table.insert(gunParts, p)
						end
					end
					getgenv().AddLog("Gun Parts count: " .. tostring(#gunParts))
					for _, p in ipairs(gunParts) do
						local tex = ""
						if p:IsA("MeshPart") then
							tex = "MeshTex: " .. tostring(p.TextureID)
						end
						local spec = p:FindFirstChildWhichIsA("SpecialMesh")
						if spec then
							tex = tex .. " SpecTex: " .. tostring(spec.TextureId)
						end
						getgenv().AddLog(
							"GunPart: "
								.. p.Name
								.. " | Trans: "
								.. tostring(p.Transparency)
								.. " | Mat: "
								.. tostring(p.Material)
								.. " | "
								.. tex
						)
					end
					local sparkles = viewModel:FindFirstChild("DeltaGunSparkles", true)
					if sparkles then
						getgenv().AddLog(
							"Sparkles found! Parent: "
								.. (sparkles.Parent and sparkles.Parent.Name or "NONE")
								.. " Size: "
								.. tostring(sparkles.Size)
						)
					else
						getgenv().AddLog("No Sparkles found in ViewModel!")
					end
					getgenv().AddLog("-----------------------------")
				end
			end

			for desc, typ in pairs(getgenv().DeltaCachedActiveTargets) do
				if typ == "Body" and bodyEnabled then
					activeTargets[desc] = "Body"
				elseif typ == "Gun" and gunEnabled then
					activeTargets[desc] = "Gun"
				end
			end
			for desc, typ in pairs(getgenv().DeltaCachedActiveParts) do
				if typ == "Body" and bodyEnabled then
					activeParts[desc] = "Body"
				elseif typ == "Gun" and gunEnabled then
					activeParts[desc] = "Gun"
				end
			end

			if gunEnabled then
				local rootPart = nil
				for p, pType in pairs(activeParts) do
					if pType == "Gun" then
						local orig = getgenv().DeltaViewmodelOriginalProps and getgenv().DeltaViewmodelOriginalProps[p]
						if orig and orig.Transparency < 1 then
							rootPart = p
							break
						end
					end
				end

				local sparkles = viewModel:FindFirstChild("DeltaGunSparkles", true)
				if sparkles and rootPart and sparkles.Parent ~= rootPart then
					sparkles:Destroy()
					sparkles = nil
				end

				if config.EnableGunSparkles and rootPart then
					if not sparkles then
						sparkles = Instance.new("ParticleEmitter")
						sparkles.Name = "DeltaGunSparkles"
						sparkles.Texture = "rbxassetid://27398118"
						sparkles.Size = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.5, 0.25),
							NumberSequenceKeypoint.new(1, 0),
						})
						sparkles.Rate = 15
						sparkles.Lifetime = NumberRange.new(0.3, 0.6)
						sparkles.Speed = NumberRange.new(0.2, 0.5)
						sparkles.LightEmission = 1
						sparkles.ZOffset = 1
						sparkles.Parent = rootPart
					end
					if sparkles then
						local c = isChroma and rgbColor or config.ViewmodelGunFillColor
						sparkles.Color = ColorSequence.new(c)
					end
				elseif sparkles then
					sparkles:Destroy()
				end
			else
				local sparkles = viewModel:FindFirstChild("DeltaGunSparkles", true)
				if sparkles then
					sparkles:Destroy()
				end
			end
		end
	end

	if not getgenv().DeltaViewmodelOriginalProps then
		getgenv().DeltaViewmodelOriginalProps = {}
	end
	if not getgenv().DeltaViewmodelAppliedProps then
		getgenv().DeltaViewmodelAppliedProps = {}
	end
	local appliedProps = getgenv().DeltaViewmodelAppliedProps

	if viewModel and viewModel:IsA("Model") then
		for _, desc in ipairs(viewModel:GetDescendants()) do
			if desc:IsA("BasePart") then
				local props = getgenv().DeltaViewmodelOriginalProps[desc]
				if not props then
					local specMesh = desc:FindFirstChildWhichIsA("SpecialMesh")
					props = {
						Transparency = desc.Transparency,
						Material = desc.Material,
						Color = desc.Color,
						TextureID = desc:IsA("MeshPart") and desc.TextureID or nil,
						SpecMesh = specMesh,
						SpecMeshTex = specMesh and specMesh.TextureId or nil,
					}
					getgenv().DeltaViewmodelOriginalProps[desc] = props
				end

				local current = appliedProps[desc]
				local pType = activeParts[desc]
				if pType and props.Transparency < 1 then
					local targetTrans = (pType == "Gun") and math.clamp(baseTrans - config.GunGlowIntensity, 0, 1)
						or baseTrans
					local targetColor = isChroma and rgbColor
						or ((pType == "Body") and config.ViewmodelBodyFillColor or config.ViewmodelGunFillColor)

					if not current or current.T ~= targetTrans or current.C ~= targetColor then
						desc.Transparency = targetTrans
						desc.Material = Enum.Material.Neon
						desc.Color = targetColor
						if desc:IsA("MeshPart") then
							desc.TextureID = ""
						end
						if props.SpecMesh then
							props.SpecMesh.TextureId = ""
						end
						appliedProps[desc] = { T = targetTrans, C = targetColor }
					end
				else
					if not current or current.T ~= props.Transparency or current.C ~= props.Color then
						desc.Transparency = props.Transparency
						desc.Material = props.Material
						desc.Color = props.Color
						if desc:IsA("MeshPart") and props.TextureID then
							desc.TextureID = props.TextureID
						end
						if props.SpecMesh and props.SpecMeshTex then
							props.SpecMesh.TextureId = props.SpecMeshTex
						end
						appliedProps[desc] = { T = props.Transparency, C = props.Color }
					end
				end
			end
		end
	end

	for obj, data in pairs(getgenv().DeltaViewmodelChamsCache) do
		local highlight = data.Highlight
		local hType = data.Type
		if not activeTargets[obj] or activeTargets[obj] ~= hType then
			highlight:Destroy()
			getgenv().DeltaViewmodelChamsCache[obj] = nil
		end
	end

	for obj, hType in pairs(activeTargets) do
		local data = getgenv().DeltaViewmodelChamsCache[obj]
		local highlight
		if not data then
			highlight = Instance.new("Highlight")
			highlight.Adornee = obj
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = CoreGui
			getgenv().DeltaViewmodelChamsCache[obj] = { Highlight = highlight, Type = hType }
		else
			highlight = data.Highlight
		end

		if isChroma then
			highlight.FillColor = rgbColor
			highlight.OutlineColor = rgbColor
		elseif hType == "Body" then
			highlight.FillColor = config.ViewmodelBodyFillColor
			highlight.OutlineColor = config.ViewmodelBodyOutlineColor
		else
			highlight.FillColor = config.ViewmodelGunFillColor
			highlight.OutlineColor = config.ViewmodelGunOutlineColor
		end

		highlight.FillTransparency = baseTrans
		highlight.OutlineTransparency = baseTrans * 0.5
	end
end

local renderConnection = RunService.RenderStepped:Connect(function()
	pcall(UpdateViewmodelTransparency)
	pcall(UpdateViewmodelChams)
	WorldModsManager.Update()
	ESPManager.Update()
	CombatManager.Update()
	BulletTracerManager.Update()
end)
table.insert(ConnectionList, renderConnection)

-- High priority camera and character override for 3rd person
RunService:BindToRenderStep("DeltaThirdPersonMod", 10000, function()
	if getgenv().Config.Mods.ThirdPerson then
		local char = Workspace:FindFirstChild(LocalPlayer.Name)
		local cam = Workspace.CurrentCamera
		if char and cam then
			local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("RootPart") or char.PrimaryPart
			local head = char:FindFirstChild("Head")
			local zoomDist = getgenv().Config.Mods.ZoomDistance or 15

			-- (Removed legacy BindToRenderStep logging)

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
			local targetCFrame = startCFrame + Vector3.new(0, 5, 0)

			local tweenUp = _TweenService:Create(
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

			currentSpiderTween = _TweenService:Create(
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

task.delay(1, function()
	getgenv()._DeltaScriptSilentToggles = false
end)
