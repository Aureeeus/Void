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
		},
		SilentAim = {
			Enabled = false,
			FOVRadius = 180,
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
		},
		Mods = {
			Fullbright = false,
			NoFog = false,
		},
	}

-- ==========================================
-- WindUI Initialization
-- ==========================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = ".ftgs hub  |  Project Delta",
	Icon = "solar:ghost-bold",
	Folder = "ProjectDeltaHub",
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
	Title = "ESP Configuration",
})

ESPSettingsSection:Toggle({
	Title = "Enable ESP",
	Value = getgenv().Config.ESP.Enabled,
	Callback = function(state)
		getgenv().Config.ESP.Enabled = state
	end,
})

ESPSettingsSection:Space()

ESPSettingsSection:Colorpicker({
	Title = "Text Color",
	Default = getgenv().Config.ESP.TextColor,
	Callback = function(color)
		getgenv().Config.ESP.TextColor = color
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "Outline Color",
	Default = getgenv().Config.ESP.OutlineColor,
	Callback = function(color)
		getgenv().Config.ESP.OutlineColor = color
	end,
})

ESPSettingsSection:Slider({
	Title = "Text Size",
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
	Value = getgenv().Config.ESP.ChamsEnabled,
	Callback = function(state)
		getgenv().Config.ESP.ChamsEnabled = state
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "Chams Fill Color",
	Default = getgenv().Config.ESP.ChamsFillColor,
	Callback = function(color)
		getgenv().Config.ESP.ChamsFillColor = color
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "Chams Outline Color",
	Default = getgenv().Config.ESP.ChamsOutlineColor,
	Callback = function(color)
		getgenv().Config.ESP.ChamsOutlineColor = color
	end,
})

ESPSettingsSection:Space()

ESPSettingsSection:Toggle({
	Title = "Visible Check",
	Value = getgenv().Config.ESP.VisibleCheck,
	Callback = function(state)
		getgenv().Config.ESP.VisibleCheck = state
	end,
})

ESPSettingsSection:Colorpicker({
	Title = "Visible Color",
	Default = getgenv().Config.ESP.VisibleColor,
	Callback = function(color)
		getgenv().Config.ESP.VisibleColor = color
	end,
})

local BulletTracersSection = VisualsTab:Section({
	Title = "Bullet Tracers",
})

BulletTracersSection:Toggle({
	Title = "Enable Bullet Tracers",
	Value = getgenv().Config.SilentAim.BulletTracers,
	Callback = function(state)
		getgenv().Config.SilentAim.BulletTracers = state
	end,
})

BulletTracersSection:Colorpicker({
	Title = "Tracer Color",
	Default = getgenv().Config.SilentAim.TracerColor,
	Callback = function(color)
		getgenv().Config.SilentAim.TracerColor = color
	end,
})

BulletTracersSection:Slider({
	Title = "Tracer Transparency",
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

-- ==========================================
-- UI Combat Tab
-- ==========================================
local CombatSection = CombatTab:Section({
	Title = "Silent Aim Configuration",
})

CombatSection:Toggle({
	Title = "Enable Silent Aim",
	Value = getgenv().Config.SilentAim.Enabled,
	Callback = function(state)
		getgenv().Config.SilentAim.Enabled = state
	end,
})

CombatSection:Space()

CombatSection:Toggle({
	Title = "Show FOV Circle",
	Value = getgenv().Config.SilentAim.ShowFOV,
	Callback = function(state)
		getgenv().Config.SilentAim.ShowFOV = state
	end,
})

CombatSection:Toggle({
	Title = "Show Snapline",
	Value = getgenv().Config.SilentAim.ShowSnapline,
	Callback = function(state)
		getgenv().Config.SilentAim.ShowSnapline = state
	end,
})

CombatSection:Space()

CombatSection:Slider({
	Title = "FOV Radius",
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

CombatSection:Space()

CombatSection:Toggle({
	Title = "Visible Check (Snapline)",
	Value = getgenv().Config.SilentAim.VisibleCheck,
	Callback = function(state)
		getgenv().Config.SilentAim.VisibleCheck = state
	end,
})

CombatSection:Colorpicker({
	Title = "Visible Snapline Color",
	Default = getgenv().Config.SilentAim.VisibleColor,
	Callback = function(color)
		getgenv().Config.SilentAim.VisibleColor = color
	end,
})

CombatSection:Space()

CombatSection:Toggle({
	Title = "No Recoil & Spread",
	Value = getgenv().Config.Combat.NoRecoil,
	Callback = function(state)
		getgenv().Config.Combat.NoRecoil = state
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
	Value = getgenv().Config.Combat.RapidFire,
	Callback = function(state)
		getgenv().Config.Combat.RapidFire = state
	end,
})

ModsSection:Slider({
	Title = "Rapid Fire Multiplier",
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
	Title = "World Settings",
})

WorldModsSection:Toggle({
	Title = "Fullbright",
	Value = getgenv().Config.Mods.Fullbright,
	Callback = function(state)
		getgenv().Config.Mods.Fullbright = state
	end,
})

WorldModsSection:Toggle({
	Title = "No Fog",
	Value = getgenv().Config.Mods.NoFog,
	Callback = function(state)
		getgenv().Config.Mods.NoFog = state
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
	Title = "UI Configuration",
})

UISection:Keybind({
	Title = "Toggle Menu Key",
	Desc = "Change the keybind to hide/show the interface",
	Value = "RightControl",
	Callback = function(keyName)
		pcall(function()
			Window:SetToggleKey(Enum.KeyCode[keyName])
		end)
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

function CharacterManager.GetActiveCharacters()
	local activeCharacters = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if not LocalPlayer or player.UserId == LocalPlayer.UserId then
			continue
		end

		local characterModel = Workspace:FindFirstChild(player.Name)
		if not characterModel or not characterModel:IsA("Model") then
			continue
		end

		local humanoid = characterModel:FindFirstChild("Humanoid")
		local rootPart = characterModel.PrimaryPart or characterModel:FindFirstChild("HumanoidRootPart")
		local head = characterModel:FindFirstChild("Head")

		if humanoid and rootPart and head then
			local health = rootPart:GetAttribute("Health")
			if health == nil then
				health = humanoid.Health
			end

			if health > 0 then
				activeCharacters[characterModel] = {
					Player = player,
					Head = head,
					RootPart = rootPart,
				}
			end
		end
	end

	return activeCharacters
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
	local textLines = { playerData.Player.Name }

	if config.ShowKDR then
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
	local anyActive = config.Enabled or config.ChamsEnabled
	local activeCharacters = anyActive and CharacterManager.GetActiveCharacters() or {}

	-- Text ESP Cleanup
	for cachedCharacter, textDrawing in pairs(ESPManager.Cache) do
		if not activeCharacters[cachedCharacter] or not config.Enabled then
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

	if not anyActive then
		return
	end

	for character, playerData in pairs(activeCharacters) do
		local isVisible3D = false
		if config.VisibleCheck and (config.Enabled or config.ChamsEnabled) then
			isVisible3D = CharacterManager.IsVisible(playerData.Head, character)
		end

		-- Handle Text ESP
		if config.Enabled then
			local textDrawing = ESPManager.Cache[character]
			if not textDrawing then
				textDrawing = ESPManager.CreateTextDrawing()
				ESPManager.Cache[character] = textDrawing
			end

			local screenPosition, isVisibleOnScreen =
				Camera:WorldToViewportPoint(playerData.Head.Position + Vector3.new(0, 1.5, 0))

			if isVisibleOnScreen then
				local distanceInMeters =
					math.floor((Camera.CFrame.Position - playerData.Head.Position).Magnitude * 0.28)

				textDrawing.Text = ESPManager.FormatPlayerText(playerData, distanceInMeters)
				textDrawing.Position = Vector2.new(screenPosition.X, screenPosition.Y)
				textDrawing.Color = isVisible3D and config.VisibleColor or config.TextColor
				textDrawing.OutlineColor = config.OutlineColor
				textDrawing.Size = config.TextSize
				textDrawing.Font = config.Font
				textDrawing.Visible = true
			else
				textDrawing.Visible = false
			end
		end

		-- Handle Chams (Highlight)
		if config.ChamsEnabled then
			local highlight = ESPManager.ChamsCache[character]
			if not highlight then
				highlight = Instance.new("Highlight")
				-- Parent to CoreGui to evade memory scanning on Workspace
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

	local distance = (hitPos - origin).Magnitude

	local part = Instance.new("Part")
	part.Name = "Tracer"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Shape = Enum.PartType.Block -- Block acts perfectly like a laser/cylinder line when scaled thinly
	part.Material = Enum.Material.Neon
	part.Color = config.TracerColor
	part.Transparency = config.TracerTransparency

	-- Create laser cylinder line stretching from origin to hitPos
	part.Size = Vector3.new(0.05, 0.05, distance)
	part.CFrame = CFrame.lookAt(origin, hitPos) * CFrame.new(0, 0, -distance / 2)
	part.Parent = Workspace.Terrain

	table.insert(BulletTracerManager.Tracers, {
		Part = part,
		ExpireTime = os.clock() + 2,
	})
end

function BulletTracerManager.Update()
	local config = getgenv().Config.SilentAim
	local now = os.clock()

	for i = #BulletTracerManager.Tracers, 1, -1 do
		local tracer = BulletTracerManager.Tracers[i]
		if now > tracer.ExpireTime or not config.BulletTracers then
			if tracer.Part then
				tracer.Part:Destroy()
			end
			table.remove(BulletTracerManager.Tracers, i)
		else
			if tracer.Part then
				tracer.Part.Color = config.TracerColor
				tracer.Part.Transparency = config.TracerTransparency
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

		if getgenv().Config.Combat.RapidFire and attrName == "FireRate" then
			local originalValue = oldNamecall(self, unpack(args))
			if type(originalValue) == "number" then
				local newValue
				if originalValue < 10 then
					-- Cooldown style (e.g. 0.1s delay between shots)
					newValue = originalValue / getgenv().Config.Combat.RapidFireValue
				else
					-- RPM style (e.g. 600 rounds per minute)
					newValue = originalValue * getgenv().Config.Combat.RapidFireValue
				end
				print(
					"[RapidFire Debug] Original:",
					originalValue,
					"| Modded:",
					newValue,
					"| Multiplier:",
					getgenv().Config.Combat.RapidFireValue
				)
				return newValue
			end
		end
	end

	if not checkcaller() and getgenv().Config.SilentAim.Enabled and TargetManager.CurrentTarget then
		if method == "FireServer" or method == "InvokeServer" then
			if self.Name == "ProjectileInflict" then
				print("[Damage Debug] ProjectileInflict Fired! Physical bullet naturally hit:", tostring(args[1]))
				-- We no longer spoof this to "Head". We let the game send the exact part it hit to the server.
				-- If the bullet hit the RightUpperArm on the client, it will also hit the RightUpperArm on the server's trajectory simulation.
				-- If we lie and say we hit the Head when the Arm was in the way, the server's anti-cheat rejects the damage completely!
			end
		end
	end

	return oldNamecall(self, ...)
end)

-- ==========================================
-- WorldMods Manager
-- ==========================================
local WorldModsManager = {}

function WorldModsManager.Update()
	local Lighting = game:GetService("Lighting")

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
-- Main Loop
-- ==========================================
RunService.RenderStepped:Connect(function()
	ESPManager.Update()
	CombatManager.Update()
	BulletTracerManager.Update()
	WorldModsManager.Update()
end)
