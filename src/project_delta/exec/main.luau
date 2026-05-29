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

ESPSettingsSection:Space()

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
	Title = "Use Visible Color",
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
		local rootPart = characterModel:FindFirstChild("HumanoidRootPart")
		local head = characterModel:FindFirstChild("Head")

		if humanoid and rootPart and head and humanoid.Health > 0 then
			activeCharacters[characterModel] = {
				Player = player,
				Head = head,
				RootPart = rootPart,
			}
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
				textDrawing.Color = config.TextColor
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

			local isVisible = config.VisibleCheck and CharacterManager.IsVisible(playerData.Head, character)
			highlight.FillColor = isVisible and config.VisibleColor or config.ChamsFillColor
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

	print(
		string.format(
			"[Tracer Debug] Added 3D Tracer! Distance: %.2f | Color: %s",
			distance,
			tostring(config.TracerColor)
		)
	)
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

					local origin = Camera.CFrame.Position
					local distance = (targetHead.Position - origin).Magnitude
					local timeToHit = distance / muzzleVelocity

					local targetVelocity = targetRoot.AssemblyLinearVelocity
					local drop = 0.5 * 70 * (timeToHit ^ 2)

					TargetManager.PredictedPosition = targetHead.Position
						+ (targetVelocity * timeToHit)
						+ Vector3.new(0, drop, 0)

					args[5] = {
						CFrame = CFrame.lookAt(origin, TargetManager.PredictedPosition),
					}

					if getgenv().Config.SilentAim.BulletTracers then
						BulletTracerManager.AddTracer(origin, TargetManager.PredictedPosition)
					end
				else
					if getgenv().Config.SilentAim.BulletTracers then
						local origin = Camera.CFrame.Position
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

	if method == "GetAttribute" and getgenv().Config.Combat.NoRecoil then
		local attrName = args[1]
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

	if not checkcaller() and getgenv().Config.SilentAim.Enabled and TargetManager.CurrentTarget then
		local targetHead = TargetManager.CurrentTarget.Head

		if method == "FireServer" or method == "InvokeServer" then
			-- Override ProjectileInflict (which actually applies the damage to a player)
			-- args[1] = Target Instance, args[2] = Local Offset (ObjectSpace)
			if self.Name == "ProjectileInflict" then
				args[1] = targetHead
				args[2] = Vector3.new(0, 0, 0) -- Dead center of the head
				return oldNamecall(self, unpack(args))
			end
		end

		-- Hook Workspace:Raycast() to spoof bullet visual tracers and local hits
		if method == "Raycast" and (self == workspace or self.Name == "Workspace") then
			local origin = args[1]
			local originalDir = args[2]
			local raycastParams = args[3]

			if typeof(raycastParams) == "RaycastParams" and raycastParams.CollisionGroup == "WeaponRay" then
				local targetPos = TargetManager.PredictedPosition or targetHead.Position
				local newDirection = (targetPos - origin).Unit * originalDir.Magnitude

				args[2] = newDirection
				return oldNamecall(self, unpack(args))
			end
		end
	end

	return oldNamecall(self, ...)
end)

-- ==========================================
-- Main Loop
-- ==========================================
RunService.RenderStepped:Connect(function()
	ESPManager.Update()
	CombatManager.Update()
	BulletTracerManager.Update()
end)
