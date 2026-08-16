local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library = assert(loadstring((game :: any):HttpGet(repo .. "Library.lua")))()

local function safeGetService(serviceName)
	local service = game:GetService(serviceName)
	return cloneref and cloneref(service) or service
end

local Players = safeGetService("Players")
local Workspace = safeGetService("Workspace")
local RunService = safeGetService("RunService")
local UserInputService = safeGetService("UserInputService")
local HttpService = safeGetService("HttpService")

local LocalPlayer = cloneref and cloneref(Players.LocalPlayer) or Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Lighting = safeGetService("Lighting")

-- Global configuration to prevent duplication
getgenv().Config = getgenv().Config
	or {
		ESP = {
			Enabled = false,
			MaxDistance = 1500,
			TextSize = 13,
			TextColor = Color3.fromRGB(255, 255, 255),
			OutlineColor = Color3.fromRGB(0, 0, 0),
			BoxColor = Color3.fromRGB(255, 255, 255),
			BoxTransparency = 1,
			PlayerESP = false,
			NPCESP = false,
			PlayerChams = false,
			NPCChams = false,
			ChamsFillColor = Color3.fromRGB(255, 255, 255),
			ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
			ChamsFillTransparency = 0,
			ChamsOutlineTransparency = 0,
			VisibleCheck = false,
			VisibleCheckColor = Color3.fromRGB(0, 255, 0),
			VisibleChamsFillColor = Color3.fromRGB(255, 255, 255),
			VisibleChamsOutlineColor = Color3.fromRGB(255, 255, 255),
			CorpseESP = false,
			CorpseChams = false,
			CorpseColor = Color3.fromRGB(150, 150, 150),
		},
		SilentAim = {
			Enabled = false,
			FOV = 150,
			FOVColor = Color3.fromRGB(255, 255, 255),
			FOVVisible = false,
			TargetType = "Players",
			SnaplineVisible = false,
			SnaplineColor = Color3.fromRGB(255, 0, 0),
			SnaplineVisibleColor = Color3.fromRGB(0, 255, 0),
		},
		Lighting = {
			CustomLighting = false,
			Ambient = Color3.fromRGB(255, 255, 255),
			Brightness = 2,
			ClockTime = 14,
			GlobalShadows = false,

			CustomFog = false,
			FogEnd = 100000,
			DisablePostEffects = false,
		},
		Terrain = {
			NoGrass = false,
		},
		Rage = {
			RapidFire = false,
			RapidFireMultiplier = 5,
			NoRecoil = false,
		},
	}

local globalRaycastParams = RaycastParams.new()
globalRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
globalRaycastParams.IgnoreWater = true

local function CheckVisibility(targetModel, origin, ignoreList)
	local head = targetModel:FindFirstChild("Head")
	if not head then
		return false
	end

	local direction = head.Position - origin
	globalRaycastParams.FilterDescendantsInstances = ignoreList

	local result = Workspace:Raycast(origin, direction, globalRaycastParams)
	if result then
		return result.Instance:IsDescendantOf(targetModel)
	end
	return true
end

-- ==========================================
-- ESP Manager Architecture
-- ==========================================
local ESPManager = {
	Cache = {},
	Connections = {},
}

getgenv().ESPManager = ESPManager

function ESPManager:CreateDrawing(class, properties)
	local drawing = Drawing.new(class)
	for prop, value in pairs(properties) do
		drawing[prop] = value
	end
	return drawing
end

function ESPManager:AddESP(model, isNPC)
	if self.Cache[model] then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Highlight_" .. tostring(model.Name)
	highlight.Adornee = model
	-- Parent to CoreGui to bypass game deletion/anti-cheat sweeps in Workspace
	local coreGui = game:GetService("CoreGui")
	highlight.Parent = coreGui:FindFirstChild("RobloxGui") or coreGui
	highlight.Enabled = false

	local drawings = {
		BoxOutline = self:CreateDrawing("Square", {
			Thickness = 3,
			Color = Color3.fromRGB(0, 0, 0),
			Transparency = getgenv().Config.ESP.BoxTransparency,
			Filled = false,
			Visible = false,
		}),
		Box = self:CreateDrawing("Square", {
			Thickness = 1,
			Color = getgenv().Config.ESP.BoxColor,
			Transparency = getgenv().Config.ESP.BoxTransparency,
			Filled = false,
			Visible = false,
		}),
		HealthOutline = self:CreateDrawing("Square", {
			Thickness = 1,
			Color = Color3.fromRGB(0, 0, 0),
			Filled = true,
			Visible = false,
		}),
		HealthFill = self:CreateDrawing("Square", {
			Thickness = 1,
			Color = Color3.fromRGB(0, 255, 0),
			Filled = true,
			Visible = false,
		}),
		Name = self:CreateDrawing("Text", {
			Text = model.Name,
			Size = getgenv().Config.ESP.TextSize,
			Center = true,
			Outline = true,
			OutlineColor = getgenv().Config.ESP.OutlineColor,
			Color = getgenv().Config.ESP.TextColor,
			Visible = false,
		}),
		Distance = self:CreateDrawing("Text", {
			Text = "",
			Size = getgenv().Config.ESP.TextSize,
			Center = true,
			Outline = true,
			OutlineColor = getgenv().Config.ESP.OutlineColor,
			Color = getgenv().Config.ESP.TextColor,
			Visible = false,
		}),
	}

	self.Cache[model] = {
		Model = model,
		Drawings = drawings,
		Highlight = highlight,
		IsNPC = isNPC,
	}
end

function ESPManager:RemoveESP(model)
	if self.Cache[model] then
		for _, drawing in pairs(self.Cache[model].Drawings) do
			drawing:Remove()
		end
		if self.Cache[model].Highlight then
			self.Cache[model].Highlight:Destroy()
		end
		self.Cache[model] = nil
	end
end

function ESPManager:Update()
	local espConfig = getgenv().Config.ESP
	if not espConfig.Enabled then
		for _, cache in pairs(self.Cache) do
			for _, drawing in pairs(cache.Drawings) do
				drawing.Visible = false
			end
			if cache.Highlight then
				cache.Highlight.Enabled = false
			end
		end
		return
	end

	local origin = Camera.CFrame.Position
	local ignoreList = nil -- Built lazily only if needed by visible check

	for model, cache in pairs(self.Cache) do
		local drawings = cache.Drawings
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Head")

		if not (model and model.Parent and hrp and humanoid and humanoid.Health > 0) then
			for _, drawing in pairs(drawings) do
				drawing.Visible = false
			end
			if cache.Highlight then
				cache.Highlight.Enabled = false
			end
			continue
		end

		-- Check filters
		local isLocalPlayer = false
		local isCorpse = model.Name == "Sleeper"
		
		if LocalPlayer.Character and model == LocalPlayer.Character then
			isLocalPlayer = true
		elseif model.Name == tostring(LocalPlayer.UserId) then
			isLocalPlayer = true
		elseif isCorpse and model.Parent and model.Parent.Name == tostring(LocalPlayer.UserId) then
			isLocalPlayer = true
		end
		
		local showBox = not isLocalPlayer and (cache.IsNPC and espConfig.NPCESP or not cache.IsNPC and espConfig.PlayerESP)
		local showChams = not isLocalPlayer
			and (cache.IsNPC and espConfig.NPCChams or not cache.IsNPC and espConfig.PlayerChams)
			
		-- Override for corpses
		if isCorpse and not isLocalPlayer then
			showBox = espConfig.CorpseESP
			showChams = espConfig.CorpseChams
		end

		if not showBox and not showChams then
			for _, drawing in pairs(drawings) do
				drawing.Visible = false
			end
			if cache.Highlight then
				cache.Highlight.Enabled = false
			end
			continue
		end

		local distanceMeters = (origin - hrp.Position).Magnitude * 0.28
		if distanceMeters > espConfig.MaxDistance then
			for _, drawing in pairs(drawings) do
				drawing.Visible = false
			end
			if cache.Highlight then
				cache.Highlight.Enabled = false
			end
			continue
		end

		local isVisible = false
		if espConfig.VisibleCheck and not isCorpse then
			if not ignoreList then
				ignoreList = { Camera, LocalPlayer.Character }
				for m, c in pairs(self.Cache) do
					local hum = m:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health <= 0 then
						table.insert(ignoreList, m)
					end
				end
			end
			isVisible = CheckVisibility(model, origin, ignoreList)
		end

		if showChams and cache.Highlight then
			if isCorpse then
				cache.Highlight.FillColor = espConfig.CorpseColor
				cache.Highlight.OutlineColor = espConfig.CorpseColor
			else
				cache.Highlight.FillColor = isVisible and espConfig.VisibleChamsFillColor or espConfig.ChamsFillColor
				cache.Highlight.OutlineColor = isVisible and espConfig.VisibleChamsOutlineColor
					or espConfig.ChamsOutlineColor
			end
			cache.Highlight.FillTransparency = espConfig.ChamsFillTransparency
			cache.Highlight.OutlineTransparency = espConfig.ChamsOutlineTransparency
			cache.Highlight.Enabled = true
		elseif cache.Highlight then
			cache.Highlight.Enabled = false
		end

		local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
		if onScreen and showBox then
			local head = model:FindFirstChild("Head")
			local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
				or Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
			local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

			local boxHeight = math.abs(headPos.Y - legPos.Y)
			local boxWidth = boxHeight * 0.6
			local boxTopLeft = Vector2.new(pos.X - boxWidth / 2, headPos.Y)
			local boxSize = Vector2.new(boxWidth, boxHeight)

			drawings.BoxOutline.Position = boxTopLeft
			drawings.BoxOutline.Size = boxSize
			drawings.BoxOutline.Transparency = espConfig.BoxTransparency
			drawings.BoxOutline.Visible = true

			drawings.Box.Position = boxTopLeft
			drawings.Box.Size = boxSize
			drawings.Box.Color = isCorpse and espConfig.CorpseColor or espConfig.BoxColor
			drawings.Box.Transparency = espConfig.BoxTransparency
			drawings.Box.Visible = true

			local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
			local healthBarHeight = boxHeight * healthPercent

			drawings.HealthOutline.Position = Vector2.new(boxTopLeft.X - 6, boxTopLeft.Y - 1)
			drawings.HealthOutline.Size = Vector2.new(4, boxHeight + 2)
			drawings.HealthOutline.Visible = not isCorpse

			drawings.HealthFill.Position = Vector2.new(boxTopLeft.X - 5, boxTopLeft.Y + (boxHeight - healthBarHeight))
			drawings.HealthFill.Size = Vector2.new(2, healthBarHeight)
			drawings.HealthFill.Color = Color3.new(1 - healthPercent, healthPercent, 0)
			drawings.HealthFill.Visible = not isCorpse

			drawings.Name.Text = isCorpse and "Corpse" or model.Name
			drawings.Name.Position = Vector2.new(pos.X, boxTopLeft.Y - drawings.Name.Size - 2)
			drawings.Name.Size = espConfig.TextSize
			drawings.Name.Color = isCorpse and espConfig.CorpseColor or (isVisible and espConfig.VisibleCheckColor or espConfig.TextColor)
			drawings.Name.Visible = true

			drawings.Distance.Text = string.format("[%d m]", math.floor(distanceMeters))
			drawings.Distance.Position = Vector2.new(pos.X, boxTopLeft.Y + boxHeight + 2)
			drawings.Distance.Size = espConfig.TextSize
			drawings.Distance.Color = isCorpse and espConfig.CorpseColor or (isVisible and espConfig.VisibleCheckColor or espConfig.TextColor)
			drawings.Distance.Visible = true
		else
			for _, drawing in pairs(drawings) do
				drawing.Visible = false
			end
		end
	end
end

-- ==========================================
-- Track Folders
-- ==========================================
local function SetupFolderTracking()
	local aiFolder = Workspace:FindFirstChild("AI")
	local offlinePlayersFolder = Workspace:FindFirstChild("OfflinePlayers")
	local activePlayersFolder = Workspace:FindFirstChild("Players")

	local function onChildAdded(child, isNPC)
		task.wait(0.1) -- small yield to let character build
		if child:IsA("Model") then
			local targetModel = child
			if not isNPC then
				local sleeper = child:FindFirstChild("Sleeper")
				if sleeper and sleeper:IsA("Model") then
					targetModel = sleeper
				end
			end
			ESPManager:AddESP(targetModel, isNPC)
		end
	end

	-- Track OfflinePlayers (Live physical bodies, including teammates like confidentnova)
	if offlinePlayersFolder then
		for _, child in pairs(offlinePlayersFolder:GetChildren()) do
			if child:IsA("Model") then
				local targetModel = child
				local sleeper = child:FindFirstChild("Sleeper")
				if sleeper and sleeper:IsA("Model") then
					targetModel = sleeper
				end
				ESPManager:AddESP(targetModel, false)
			end
		end
		table.insert(ESPManager.Connections, offlinePlayersFolder.ChildAdded:Connect(function(child)
			onChildAdded(child, false)
		end))
		table.insert(ESPManager.Connections, offlinePlayersFolder.ChildRemoved:Connect(function(child)
			local targetModel = child
			local sleeper = child:FindFirstChild("Sleeper")
			if sleeper and sleeper:IsA("Model") then
				targetModel = sleeper
			end
			ESPManager:RemoveESP(targetModel)
		end))
	end
	
	-- Track active moving players (stored in Workspace.Players in this specific game)
	if activePlayersFolder then
		for _, child in pairs(activePlayersFolder:GetChildren()) do
			if child:IsA("Model") then
				ESPManager:AddESP(child, false)
			end
		end
		table.insert(ESPManager.Connections, activePlayersFolder.ChildAdded:Connect(function(child)
			onChildAdded(child, false)
		end))
		table.insert(ESPManager.Connections, activePlayersFolder.ChildRemoved:Connect(function(child)
			ESPManager:RemoveESP(child)
		end))
	end

	-- Track active LocalPlayer / other player models if they spawn directly in Workspace
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		if player.Character then
			ESPManager:AddESP(player.Character, false)
		end
		table.insert(
			ESPManager.Connections,
			player.CharacterAdded:Connect(function(char)
				onChildAdded(char, false)
			end)
		)
	end
	table.insert(
		ESPManager.Connections,
		game:GetService("Players").PlayerAdded:Connect(function(player)
			table.insert(
				ESPManager.Connections,
				player.CharacterAdded:Connect(function(char)
					onChildAdded(char, false)
				end)
			)
		end)
	)

	-- Track AI (NPCs)
	if aiFolder then
		for _, child in pairs(aiFolder:GetChildren()) do
			if child:IsA("Model") then
				ESPManager:AddESP(child, true)
			end
		end
		table.insert(
			ESPManager.Connections,
			aiFolder.ChildAdded:Connect(function(child)
				onChildAdded(child, true)
			end)
		)
		table.insert(
			ESPManager.Connections,
			aiFolder.ChildRemoved:Connect(function(child)
				ESPManager:RemoveESP(child)
			end)
		)
	end
end
SetupFolderTracking()

table.insert(
	ESPManager.Connections,
	RunService.RenderStepped:Connect(function()
		ESPManager:Update()
	end)
)

-- ==========================================
-- Silent Aim Architecture
-- ==========================================
local SilentAimManager = {
	FOVCircle = ESPManager:CreateDrawing("Circle", {
		Thickness = 1,
		Color = getgenv().Config.SilentAim.FOVColor,
		Transparency = 1,
		NumSides = 60,
		Radius = getgenv().Config.SilentAim.FOV,
		Filled = false,
		Visible = getgenv().Config.SilentAim.FOVVisible,
	}),
	Snapline = ESPManager:CreateDrawing("Line", {
		Thickness = 1,
		Color = getgenv().Config.SilentAim.SnaplineColor,
		Transparency = 1,
		Visible = false,
	}),
	CurrentTarget = nil,
	CurrentProjectileStats = nil,
}
getgenv().SilentAimManager = SilentAimManager

-- Gets the closest valid target relative to mouse cursor
function SilentAimManager:GetClosestTarget()
	local silentAimConfig = getgenv().Config.SilentAim
	local espConfig = getgenv().Config.ESP
	local mousePos = UserInputService:GetMouseLocation()
	local closestModel = nil
	local closestDist = silentAimConfig.FOV
	local origin = Camera.CFrame.Position
	local targetType = silentAimConfig.TargetType
	local maxDist = espConfig.MaxDistance

	for model, cache in pairs(ESPManager.Cache) do
		-- Filter checks
		if targetType == "Players" and cache.IsNPC then
			continue
		end
		if targetType == "NPCs" and not cache.IsNPC then
			continue
		end
		if model == LocalPlayer.Character then
			continue
		end
		if model.Name == "Sleeper" then
			continue
		end

		local humanoid = model:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			continue
		end

		local hrp = model:FindFirstChild("HumanoidRootPart")
		local head = model:FindFirstChild("Head")

		if hrp and head then
			local distance = (origin - hrp.Position).Magnitude
			if distance * 0.28 <= maxDist then
				local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
					if dist <= closestDist then
						closestDist = dist
						closestModel = model
					end
				end
			end
		end
	end

	return closestModel
end

function SilentAimManager:Update()
	local silentAimConfig = getgenv().Config.SilentAim
	local enabled = silentAimConfig.Enabled

	local mousePos = UserInputService:GetMouseLocation()
	self.FOVCircle.Position = mousePos
	self.FOVCircle.Radius = silentAimConfig.FOV
	self.FOVCircle.Color = silentAimConfig.FOVColor
	self.FOVCircle.Visible = silentAimConfig.FOVVisible and enabled

	if enabled then
		self.CurrentTarget = self:GetClosestTarget()
	else
		self.CurrentTarget = nil
	end

	if self.CurrentTarget and silentAimConfig.SnaplineVisible and enabled then
		local head = self.CurrentTarget:FindFirstChild("Head")
		if head then
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				self.Snapline.From = mousePos
				self.Snapline.To = Vector2.new(screenPos.X, screenPos.Y)

				local origin = Camera.CFrame.Position
				local ignoreList = { Camera, LocalPlayer.Character }
				for m, c in pairs(ESPManager.Cache) do
					local hum = m:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health <= 0 then
						table.insert(ignoreList, m)
					end
				end

				local isVisible = CheckVisibility(self.CurrentTarget, origin, ignoreList)
				self.Snapline.Color = isVisible and silentAimConfig.SnaplineVisibleColor
					or silentAimConfig.SnaplineColor
				self.Snapline.Visible = true
			else
				self.Snapline.Visible = false
			end
		else
			self.Snapline.Visible = false
		end
	else
		self.Snapline.Visible = false
	end
end

table.insert(
	ESPManager.Connections,
	RunService.RenderStepped:Connect(function()
		SilentAimManager:Update()
	end)
)

-- Hooking Projectile creation to grab weapon stats
local ProjectileModule
for _, obj in pairs(getgc(true)) do
	if type(obj) == "table" and rawget(obj, "Modules") and rawget(obj, "OnNewProjectile") then
		ProjectileModule = obj
		break
	end
end

if ProjectileModule and type(ProjectileModule.New) == "function" then
	local oldProjectileNew = ProjectileModule.New
	ProjectileModule.New = function(self, data, ...)
		if getgenv().Config.SilentAim.Enabled and not data.FromServer then
			-- Ensure it's a Bullet (has Tracer) or Arrow (has BulletPrefab) to exclude throwables/rockets
			if data.Stats and (data.Stats.Tracer or data.Stats.BulletPrefab) then
				SilentAimManager.CurrentProjectileStats = data.Stats
			else
				SilentAimManager.CurrentProjectileStats = nil
			end
		end
		return oldProjectileNew(self, data, ...)
	end
end

-- Hooking ScreenPointToRay for Bullet Redirect
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	if checkcaller() then
		return oldNamecall(self, ...)
	end

	local method = getnamecallmethod()
	local silentAimConfig = getgenv().Config.SilentAim

	if method == "ScreenPointToRay" and silentAimConfig.Enabled then
		local target = SilentAimManager.CurrentTarget
		local stats = SilentAimManager.CurrentProjectileStats

		if target and stats then
			local hrp = target:FindFirstChild("HumanoidRootPart")
			local head = target:FindFirstChild("Head")

			if hrp and head then
				local origin = Camera.CFrame.Position
				local headPos = head.Position

				local velocity = (stats.Velocity or 1500) * 2 -- The game multiplies Velocity by 2 for studs/sec
				local dropMultiplier = stats.Drop or 0

				-- Grab velocity of target
				local targetVelocity = hrp.AssemblyLinearVelocity

				-- Iterative Time to Hit calculation (predictive)
				local timeToHit = (headPos - origin).Magnitude / velocity
				local predictedPos = headPos

				for i = 1, 3 do
					predictedPos = headPos + (targetVelocity * timeToHit)
					timeToHit = (predictedPos - origin).Magnitude / velocity
				end

				-- Calculate bullet drop expected (1/2 * drop * t^2)
				local drop = 0.5 * dropMultiplier * (timeToHit * timeToHit)

				-- Aim above the predicted target to compensate for the drop
				local aimPos = predictedPos + Vector3.new(0, drop, 0)

				-- We don't want to permanently lock this, so we clear it after use
				SilentAimManager.CurrentProjectileStats = nil

				return Ray.new(origin, (aimPos - origin).Unit)
			end
		end
	end

	return oldNamecall(self, ...)
end)

-- ==========================================
-- Environment Architecture
-- ==========================================
local EnvironmentManager = {
	OriginalLightingSettings = {
		Ambient = Lighting.Ambient,
		Brightness = Lighting.Brightness,
		ClockTime = Lighting.ClockTime,
		FogEnd = Lighting.FogEnd,
		GlobalShadows = Lighting.GlobalShadows,
	},
	OriginalTerrainSettings = {
		Decoration = (function()
			local success, val = pcall(function()
				return gethiddenproperty(Workspace.Terrain, "Decoration")
			end)
			if success and val ~= nil then
				return val
			end
			return true
		end)(),
	},
	HiddenLightingEffects = {},
	Connections = {},
}
getgenv().EnvironmentManager = EnvironmentManager

function EnvironmentManager:UpdateTerrain()
	if not sethiddenproperty then
		return
	end

	local noGrass = getgenv().Config.Terrain.NoGrass
	local targetDeco = noGrass == false and self.OriginalTerrainSettings.Decoration or false

	pcall(function()
		if gethiddenproperty(Workspace.Terrain, "Decoration") ~= targetDeco then
			sethiddenproperty(Workspace.Terrain, "Decoration", targetDeco)
		end
	end)
end

function EnvironmentManager:UpdateLighting()
	local config = getgenv().Config.Lighting

	local targetAmbient = config.CustomLighting and config.Ambient or self.OriginalLightingSettings.Ambient
	if Lighting.Ambient ~= targetAmbient then
		Lighting.Ambient = targetAmbient
	end

	local targetBrightness = config.CustomLighting and config.Brightness or self.OriginalLightingSettings.Brightness
	if Lighting.Brightness ~= targetBrightness then
		Lighting.Brightness = targetBrightness
	end

	local targetClockTime = config.CustomLighting and config.ClockTime or self.OriginalLightingSettings.ClockTime
	if Lighting.ClockTime ~= targetClockTime then
		Lighting.ClockTime = targetClockTime
	end

	local targetShadows = config.CustomLighting and config.GlobalShadows or self.OriginalLightingSettings.GlobalShadows
	if Lighting.GlobalShadows ~= targetShadows then
		Lighting.GlobalShadows = targetShadows
	end

	local targetFogEnd = config.CustomFog and config.FogEnd or self.OriginalLightingSettings.FogEnd
	if Lighting.FogEnd ~= targetFogEnd then
		Lighting.FogEnd = targetFogEnd
	end

	if config.CustomFog and config.DisablePostEffects then
		for _, child in ipairs(Lighting:GetChildren()) do
			if child:IsA("Atmosphere") or child:IsA("PostEffect") then
				self.HiddenLightingEffects[#self.HiddenLightingEffects + 1] = child
				child.Parent = nil
			end
		end
	else
		for i = 1, #self.HiddenLightingEffects do
			local child = self.HiddenLightingEffects[i]
			if child then
				child.Parent = Lighting
			end
		end
		table.clear(self.HiddenLightingEffects)
	end
end

local LightingProperties = {
	Ambient = true,
	Brightness = true,
	ClockTime = true,
	FogEnd = true,
	GlobalShadows = true,
}

table.insert(
	EnvironmentManager.Connections,
	Lighting.Changed:Connect(function(property)
		if LightingProperties[property] then
			EnvironmentManager:UpdateLighting()
		end
	end)
)

table.insert(
	EnvironmentManager.Connections,
	Lighting.ChildAdded:Connect(function(child)
		local config = getgenv().Config.Lighting
		if config.CustomFog and config.DisablePostEffects then
			if child:IsA("Atmosphere") or child:IsA("PostEffect") then
				task.defer(function()
					EnvironmentManager.HiddenLightingEffects[#EnvironmentManager.HiddenLightingEffects + 1] = child
					child.Parent = nil
				end)
			end
		end
	end)
)

-- ==========================================
-- LinoriaLib UI Setup
-- ==========================================
local Window = Library:CreateWindow({
	Title = "Bisaya | Lone Survival",
	Center = true,
	AutoShow = true,
	TabPadding = 8,
	MenuFadeTime = 0.2,
	CenterTabs = true,
})

-- Force center the tabs since the public version of LinoriaLib doesn't natively support CenterTabs.
task.spawn(function()
	if Window.Holder then
		for _, child in pairs(Window.Holder:GetDescendants()) do
			-- TabArea is a Frame with Y Offset of 21.
			if
				child:IsA("UIListLayout")
				and child.FillDirection == Enum.FillDirection.Horizontal
				and child.Parent
				and child.Parent.Size.Y.Offset == 21
			then
				child.HorizontalAlignment = Enum.HorizontalAlignment.Center
			end
		end
	end
end)

local VisualsTab = Window:AddTab("Visuals")
local VisualsTabBox = VisualsTab:AddLeftTabbox()
local ESPSection = VisualsTabBox:AddTab("ESP")
local ChamsSection = VisualsTabBox:AddTab("Chams")

ESPSection:AddToggle("MasterESP", {
	Text = "ESP",
	Default = getgenv().Config.ESP.Enabled,
}):OnChanged(function(value)
	getgenv().Config.ESP.Enabled = value
end)

ESPSection:AddToggle("CorpseESP", {
	Text = "Corpse ESP",
	Default = getgenv().Config.ESP.CorpseESP,
}):OnChanged(function(value)
	getgenv().Config.ESP.CorpseESP = value
end)

ESPSection:AddToggle("VisibleCheck", {
	Text = "Visible Check",
	Default = getgenv().Config.ESP.VisibleCheck,
}):AddColorPicker("VisibleCheckColor", {
	Default = getgenv().Config.ESP.VisibleCheckColor,
	Title = "Visible Color",
})
getgenv().Toggles.VisibleCheck:OnChanged(function(value)
	getgenv().Config.ESP.VisibleCheck = value
end)
getgenv().Options.VisibleCheckColor:OnChanged(function(value)
	getgenv().Config.ESP.VisibleCheckColor = value
end)

ChamsSection:AddToggle("PlayerChams", {
	Text = "Players Chams",
	Default = getgenv().Config.ESP.PlayerChams,
}):OnChanged(function(value)
	getgenv().Config.ESP.PlayerChams = value
end)

ChamsSection:AddToggle("NPCChams", {
	Text = "NPCs Chams",
	Default = getgenv().Config.ESP.NPCChams,
}):OnChanged(function(value)
	getgenv().Config.ESP.NPCChams = value
end)

ChamsSection:AddToggle("CorpseChams", {
	Text = "Corpse Chams",
	Default = getgenv().Config.ESP.CorpseChams,
}):AddColorPicker("CorpseColor", {
	Default = getgenv().Config.ESP.CorpseColor,
	Title = "Corpse Color",
})
getgenv().Toggles.CorpseChams:OnChanged(function(value)
	getgenv().Config.ESP.CorpseChams = value
end)
getgenv().Options.CorpseColor:OnChanged(function(value)
	getgenv().Config.ESP.CorpseColor = value
end)

ChamsSection:AddLabel("Chams Fill"):AddColorPicker("ChamsFillColor", {
	Default = getgenv().Config.ESP.ChamsFillColor,
	Title = "Fill Color",
})
getgenv().Options.ChamsFillColor:OnChanged(function(value)
	getgenv().Config.ESP.ChamsFillColor = value
end)

ChamsSection:AddLabel("Chams Outline"):AddColorPicker("ChamsOutlineColor", {
	Default = getgenv().Config.ESP.ChamsOutlineColor,
	Title = "Outline Color",
})
getgenv().Options.ChamsOutlineColor:OnChanged(function(value)
	getgenv().Config.ESP.ChamsOutlineColor = value
end)

ChamsSection:AddLabel("Visible Fill Color"):AddColorPicker("VisibleChamsFillColor", {
	Default = getgenv().Config.ESP.VisibleChamsFillColor,
	Title = "Visible Fill Color",
})
getgenv().Options.VisibleChamsFillColor:OnChanged(function(value)
	getgenv().Config.ESP.VisibleChamsFillColor = value
end)

ChamsSection:AddLabel("Visible Outline Color"):AddColorPicker("VisibleChamsOutlineColor", {
	Default = getgenv().Config.ESP.VisibleChamsOutlineColor,
	Title = "Visible Outline Color",
})
getgenv().Options.VisibleChamsOutlineColor:OnChanged(function(value)
	getgenv().Config.ESP.VisibleChamsOutlineColor = value
end)

ChamsSection:AddSlider("ChamsFillTransparency", {
	Text = "Fill Transparency",
	Default = getgenv().Config.ESP.ChamsFillTransparency,
	Min = 0,
	Max = 1,
	Rounding = 2,
	Compact = true,
}):OnChanged(function(value)
	getgenv().Config.ESP.ChamsFillTransparency = value
end)

ChamsSection:AddSlider("ChamsOutlineTransparency", {
	Text = "Outline Transparency",
	Default = getgenv().Config.ESP.ChamsOutlineTransparency,
	Min = 0,
	Max = 1,
	Rounding = 2,
	Compact = true,
}):OnChanged(function(value)
	getgenv().Config.ESP.ChamsOutlineTransparency = value
end)

ESPSection:AddToggle("PlayerESP", {
	Text = "Players ESP",
	Default = getgenv().Config.ESP.PlayerESP,
}):OnChanged(function(value)
	getgenv().Config.ESP.PlayerESP = value
end)

ESPSection:AddToggle("NPCESP", {
	Text = "NPCs ESP",
	Default = getgenv().Config.ESP.NPCESP,
}):OnChanged(function(value)
	getgenv().Config.ESP.NPCESP = value
end)

ESPSection:AddSlider("MaxDistance", {
	Text = "Max Distance",
	Default = getgenv().Config.ESP.MaxDistance,
	Min = 50,
	Max = 3000,
	Rounding = 0,
	Compact = true,
}):OnChanged(function(value)
	getgenv().Config.ESP.MaxDistance = value
end)

ESPSection:AddLabel("Box Color"):AddColorPicker("BoxColor", {
	Default = getgenv().Config.ESP.BoxColor,
	Title = "Box Color",
})
getgenv().Options.BoxColor:OnChanged(function(value)
	getgenv().Config.ESP.BoxColor = value
end)

ESPSection:AddSlider("BoxTransparency", {
	Text = "Box Transparency",
	Default = getgenv().Config.ESP.BoxTransparency,
	Min = 0,
	Max = 1,
	Rounding = 2,
	Compact = true,
}):OnChanged(function(value)
	getgenv().Config.ESP.BoxTransparency = value
end)

ESPSection:AddLabel("Text Color"):AddColorPicker("TextColor", {
	Default = getgenv().Config.ESP.TextColor,
	Title = "Text Color",
})
getgenv().Options.TextColor:OnChanged(function(value)
	getgenv().Config.ESP.TextColor = value
end)

ESPSection:AddSlider("TextSize", {
	Text = "Text Size",
	Default = getgenv().Config.ESP.TextSize,
	Min = 8,
	Max = 24,
	Rounding = 0,
	Compact = true,
}):OnChanged(function(value)
	getgenv().Config.ESP.TextSize = value
end)

local WorldTab = Window:AddTab("World")
local lightingConfig = getgenv().Config.Lighting
local terrainConfig = getgenv().Config.Terrain

local LightingSection = WorldTab:AddLeftGroupbox("Custom Lighting")

LightingSection:AddToggle("CustomLighting", {
	Text = "Custom Lighting",
	Default = lightingConfig.CustomLighting,
}):OnChanged(function(value)
	lightingConfig.CustomLighting = value
	EnvironmentManager:UpdateLighting()
end)

LightingSection:AddLabel("Ambient Color"):AddColorPicker("LightingAmbient", {
	Default = lightingConfig.Ambient,
	Title = "Ambient Color",
})
getgenv().Options.LightingAmbient:OnChanged(function(value)
	lightingConfig.Ambient = value
	if lightingConfig.CustomLighting then
		EnvironmentManager:UpdateLighting()
	end
end)

LightingSection:AddSlider("LightingBrightness", {
	Text = "Brightness",
	Default = lightingConfig.Brightness,
	Min = 0,
	Max = 10,
	Rounding = 1,
	Compact = true,
}):OnChanged(function(value)
	lightingConfig.Brightness = value
	if lightingConfig.CustomLighting then
		EnvironmentManager:UpdateLighting()
	end
end)

LightingSection:AddSlider("LightingClockTime", {
	Text = "Clock Time",
	Default = lightingConfig.ClockTime,
	Min = 0,
	Max = 24,
	Rounding = 1,
	Compact = true,
}):OnChanged(function(value)
	lightingConfig.ClockTime = value
	if lightingConfig.CustomLighting then
		EnvironmentManager:UpdateLighting()
	end
end)

LightingSection:AddToggle("GlobalShadows", {
	Text = "Global Shadows",
	Default = lightingConfig.GlobalShadows,
}):OnChanged(function(value)
	lightingConfig.GlobalShadows = value
	if lightingConfig.CustomLighting then
		EnvironmentManager:UpdateLighting()
	end
end)

local FogSection = WorldTab:AddRightGroupbox("Fog & Atmosphere")

FogSection:AddToggle("CustomFog", {
	Text = "Custom Fog",
	Default = lightingConfig.CustomFog,
}):OnChanged(function(value)
	lightingConfig.CustomFog = value
	EnvironmentManager:UpdateLighting()
end)

FogSection:AddSlider("FogEnd", {
	Text = "Fog End",
	Default = lightingConfig.FogEnd,
	Min = 0,
	Max = 100000,
	Rounding = 0,
	Compact = true,
}):OnChanged(function(value)
	lightingConfig.FogEnd = value
	if lightingConfig.CustomFog then
		EnvironmentManager:UpdateLighting()
	end
end)

FogSection:AddToggle("DisablePostEffects", {
	Text = "No Atmosphere/Effects",
	Default = lightingConfig.DisablePostEffects,
}):OnChanged(function(value)
	lightingConfig.DisablePostEffects = value
	EnvironmentManager:UpdateLighting()
end)

local TerrainSection = WorldTab:AddRightGroupbox("Terrain")

TerrainSection:AddToggle("NoGrass", {
	Text = "No Grass",
	Default = terrainConfig.NoGrass,
}):OnChanged(function(value)
	terrainConfig.NoGrass = value
	EnvironmentManager:UpdateTerrain()
end)

local CombatTab = Window:AddTab("Combat")
local AimingSection = CombatTab:AddLeftGroupbox("Aiming")

AimingSection:AddToggle("SilentAimEnabled", {
	Text = "Silent Aim",
	Default = getgenv().Config.SilentAim.Enabled,
}):OnChanged(function(value)
	getgenv().Config.SilentAim.Enabled = value
end)

AimingSection:AddDropdown("SilentAimTargetType", {
	Values = { "Players", "NPCs", "Both" },
	Default = 1,
	Multi = false,
	Text = "Target Type",
}):OnChanged(function(value)
	getgenv().Config.SilentAim.TargetType = value
end)

AimingSection:AddToggle("FOVVisible", {
	Text = "FOV Circle",
	Default = getgenv().Config.SilentAim.FOVVisible,
}):OnChanged(function(value)
	getgenv().Config.SilentAim.FOVVisible = value
end)

AimingSection:AddLabel("FOV Color"):AddColorPicker("FOVColor", {
	Default = getgenv().Config.SilentAim.FOVColor,
	Title = "FOV Color",
})
getgenv().Options.FOVColor:OnChanged(function(value)
	getgenv().Config.SilentAim.FOVColor = value
end)

AimingSection:AddSlider("FOVRadius", {
	Text = "FOV Radius",
	Default = getgenv().Config.SilentAim.FOV,
	Min = 10,
	Max = 1000,
	Rounding = 0,
	Compact = true,
}):OnChanged(function(value)
	getgenv().Config.SilentAim.FOV = value
end)

AimingSection:AddToggle("SnaplineVisible", {
	Text = "Snapline",
	Default = getgenv().Config.SilentAim.SnaplineVisible,
}):OnChanged(function(value)
	getgenv().Config.SilentAim.SnaplineVisible = value
end)

AimingSection:AddLabel("Snapline Color"):AddColorPicker("SnaplineColor", {
	Default = getgenv().Config.SilentAim.SnaplineColor,
	Title = "Snapline Color",
})
getgenv().Options.SnaplineColor:OnChanged(function(value)
	getgenv().Config.SilentAim.SnaplineColor = value
end)

AimingSection:AddLabel("Snapline Visible Color"):AddColorPicker("SnaplineVisibleColor", {
	Default = getgenv().Config.SilentAim.SnaplineVisibleColor,
	Title = "Snapline Visible Color",
})
getgenv().Options.SnaplineVisibleColor:OnChanged(function(value)
	getgenv().Config.SilentAim.SnaplineVisibleColor = value
end)

-- ==========================================
-- Rage Section (Combat Tab)
-- ==========================================
local RageSection = CombatTab:AddRightGroupbox("Rage")

RageSection:AddToggle("RapidFire", {
	Text = "Rapid Fire",
	Default = getgenv().Config.Rage.RapidFire,
}):OnChanged(function(value)
	getgenv().Config.Rage.RapidFire = value
end)

RageSection:AddSlider("RapidFireMultiplier", {
	Text = "Fire Rate Multiplier",
	Default = getgenv().Config.Rage.RapidFireMultiplier,
	Min = 1,
	Max = 20,
	Rounding = 1,
	Compact = true,
}):OnChanged(function(value)
	getgenv().Config.Rage.RapidFireMultiplier = value
end)

RageSection:AddToggle("NoRecoil", {
	Text = "No Recoil",
	Default = getgenv().Config.Rage.NoRecoil,
}):OnChanged(function(value)
	getgenv().Config.Rage.NoRecoil = value
end)

-- ==========================================
-- Rage: Runtime Logic
-- ==========================================
do
	local hookedRecoilFn = nil
	local recoilHook = nil

	local currentBehavior = nil
	local lastBehaviorScan = 0
	local lastRecoilScan = 0

	-- Searches getgc for the DefaultGun / Bolt / Lever etc. behavior instance.
	-- It caches the behavior and only re-scans at most once per second.
	local function GetGunBehavior()
		-- 1. Check if cached behavior is still valid and equipped
		if type(currentBehavior) == "table" then
			local vm = rawget(currentBehavior, "Viewmodel")
			if type(vm) == "table" and rawget(vm, "Equipped") then
				return currentBehavior
			end
			-- Invalidated (unequipped or destroyed)
			currentBehavior = nil
		end

		-- 2. Debounce getgc scan to avoid FPS drops
		if tick() - lastBehaviorScan < 2 then
			return nil
		end
		lastBehaviorScan = tick()

		-- 3. Scan getgc
		for _, obj in pairs(getgc(true)) do
			if
				type(obj) == "table"
				and rawget(obj, "RPM") ~= nil
				and rawget(obj, "DRPM") ~= nil
				and rawget(obj, "LastFireTick") ~= nil
				and rawget(obj, "Firing") ~= nil
			then
				local vm = rawget(obj, "Viewmodel")
				if type(vm) == "table" and rawget(vm, "Equipped") then
					currentBehavior = obj
					return obj
				end
			end
		end
		return nil
	end

	-- Searches getgc for the live Recoil function stored as upvalue r12
	-- inside the DefaultGun Fire closure.
	local function FindAndHookRecoil()
		if hookedRecoilFn then
			return
		end -- already hooked

		-- Debounce
		if tick() - lastRecoilScan < 1 then
			return
		end
		lastRecoilScan = tick()

		for _, fn in pairs(getgc(true)) do
			if type(fn) == "function" then
				local ok, ups = pcall(getupvalues, fn)
				if ok and ups then
					local hasR12 = false
					local r12Ref = nil
					local hasR30 = false

					for k, v in pairs(ups) do
						if type(v) == "function" then
							hasR12 = true
							r12Ref = v
						elseif type(v) == "number" and v >= 0 and v <= 1 then
							hasR30 = true
						end
					end

					if hasR12 and hasR30 and r12Ref then
						hookedRecoilFn = r12Ref
						recoilHook = hookfunction(r12Ref, function(...)
							if getgenv().Config.Rage.NoRecoil then
								-- Return inputs unchanged so no impulse is given
								return ...
							end
							return recoilHook(...)
						end)
						break
					end
				end
			end
		end
	end

	RunService.Heartbeat:Connect(function()
		local rageConfig = getgenv().Config.Rage

		if not rageConfig then
			return
		end

		-- Rapid Fire: find behavior and clamp RPM
		if rageConfig.RapidFire or rageConfig.NoRecoil then
			local behavior = GetGunBehavior()
			if behavior then
				if rageConfig.RapidFire then
					-- Divide the default RPM by the multiplier
					local multiplier = math.max(1, rageConfig.RapidFireMultiplier or 5)
					behavior.RPM = (behavior.DRPM or behavior.RPM) / multiplier
				else
					-- Restore default when toggled off
					if behavior.DRPM then
						behavior.RPM = behavior.DRPM
					end
				end

				-- No Recoil: additionally zero the recoil spring if accessible
				if rageConfig.NoRecoil then
					local springs = rawget(behavior.Viewmodel or {}, "Springs")
					if springs then
						local rot = rawget(springs, "Rotation")
						if rot then
							for _, key in ipairs({ "Recoil", "Extra" }) do
								local spring = rawget(rot, key)
								if spring then
									if spring.Target then
										spring.Target = Vector3.zero
									end
									if spring.Velocity then
										spring.Velocity = Vector3.zero
									end
								end
							end
						end
					end
				end
			end
		end

		-- Attempt to hook the Recoil function if NoRecoil is on and not yet hooked
		if rageConfig.NoRecoil and not hookedRecoilFn then
			pcall(FindAndHookRecoil)
		end
	end)
end

-- ==========================================
-- Custom Config Manager
-- ==========================================

local ConfigFolder = "Bisaya/config"
if not isfolder("Bisaya") then
	makefolder("Bisaya")
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

local SettingsTab = Window:AddTab("Settings")
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
		safeSetToggle("MasterESP", data.ESP.Enabled)
		safeSetOption("MaxDistance", data.ESP.MaxDistance)
		safeSetOption("TextSize", data.ESP.TextSize)
		safeSetColorPicker("TextColor", parseColor(data.ESP.TextColor))
		safeSetColorPicker("BoxColor", parseColor(data.ESP.BoxColor))
		safeSetOption("BoxTransparency", data.ESP.BoxTransparency)
		safeSetToggle("PlayerESP", data.ESP.PlayerESP)
		safeSetToggle("NPCESP", data.ESP.NPCESP)

		safeSetToggle("PlayerChams", data.ESP.PlayerChams)
		safeSetToggle("NPCChams", data.ESP.NPCChams)
		safeSetColorPicker("ChamsFillColor", parseColor(data.ESP.ChamsFillColor))
		safeSetColorPicker("ChamsOutlineColor", parseColor(data.ESP.ChamsOutlineColor))
		safeSetOption("ChamsFillTransparency", data.ESP.ChamsFillTransparency)
		safeSetOption("ChamsOutlineTransparency", data.ESP.ChamsOutlineTransparency)

		safeSetToggle("VisibleCheck", data.ESP.VisibleCheck)
		safeSetColorPicker("VisibleCheckColor", parseColor(data.ESP.VisibleCheckColor))
		safeSetColorPicker("VisibleChamsFillColor", parseColor(data.ESP.VisibleChamsFillColor))
		safeSetColorPicker("VisibleChamsOutlineColor", parseColor(data.ESP.VisibleChamsOutlineColor))
	end

	if data.SilentAim then
		safeSetToggle("SilentAimEnabled", data.SilentAim.Enabled)
		safeSetOption("FOVRadius", data.SilentAim.FOV)
		safeSetColorPicker("FOVColor", parseColor(data.SilentAim.FOVColor))
		safeSetToggle("FOVVisible", data.SilentAim.FOVVisible)
		safeSetOption("SilentAimTargetType", data.SilentAim.TargetType)
		safeSetToggle("SnaplineVisible", data.SilentAim.SnaplineVisible)
		safeSetColorPicker("SnaplineColor", parseColor(data.SilentAim.SnaplineColor))
		safeSetColorPicker("SnaplineVisibleColor", parseColor(data.SilentAim.SnaplineVisibleColor))
	end

	if data.Lighting then
		safeSetToggle("CustomLighting", data.Lighting.CustomLighting)
		safeSetColorPicker("LightingAmbient", parseColor(data.Lighting.Ambient))
		safeSetOption("LightingBrightness", data.Lighting.Brightness)
		safeSetOption("LightingClockTime", data.Lighting.ClockTime)
		safeSetToggle("GlobalShadows", data.Lighting.GlobalShadows)

		safeSetToggle("CustomFog", data.Lighting.CustomFog)
		safeSetOption("FogEnd", data.Lighting.FogEnd)
		safeSetToggle("DisablePostEffects", data.Lighting.DisablePostEffects)
	end

	if data.Terrain then
		safeSetToggle("NoGrass", data.Terrain.NoGrass)
	end

	if data.Rage then
		safeSetToggle("RapidFire", data.Rage.RapidFire)
		safeSetOption("RapidFireMultiplier", data.Rage.RapidFireMultiplier)
		safeSetToggle("NoRecoil", data.Rage.NoRecoil)
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

Library:SetWatermarkVisibility(true)
local currentDate = os.date("%m/%d/%Y")
Library:SetWatermark("Bisaya | Dev Version | " .. currentDate)

-- Shift Watermark down by 100px so it doesn't overlap with other top-level UI
local currentPos = Library.Watermark.Position
Library.Watermark.Position =
	UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, currentPos.Y.Offset + 100)
