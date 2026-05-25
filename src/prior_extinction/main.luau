local Config = {
	ESP = {
		Enabled = true,
		ColorFar = Color3.new(0, 1, 0), -- 700+ studs (Green)
		ColorMid = Color3.new(1, 1, 0), -- 200-700 studs (Yellow)
		ColorNear = Color3.new(1, 0, 0), -- <=200 studs (Red)
		TextOutline = true,
		TextSize = 14,
		YOffset = 5,
	},
	Fullbright = {
		Enabled = false,
	},
	NoFog = {
		Enabled = false,
	},
	Aimbot = {
		Enabled = true,
		AimKey = "Q", -- Can be a key string (e.g. "Q", "E") or mouse button string (e.g. "MouseButton2")
		Toggle = false, -- true = click to toggle on/off, false = hold to lock
		Smoothing = 5, -- 1 = instant snap, higher = smoother/slower movement
		Snapline = {
			Enabled = true,
			Color = Color3.new(1, 0, 0),
			Thickness = 1.5,
			Transparency = 0.8,
		},
	},
	Fossils = {
		Enabled = false,
		Color = Color3.new(0, 0.4, 1), -- Default fallback color
		ColorSmall = Color3.fromRGB(0, 200, 255), -- Cyan/Light Blue for small fossils
		ColorMedium = Color3.fromRGB(0, 120, 255), -- Vibrant blue for medium fossils
		ColorRare = Color3.fromRGB(255, 165, 0), -- Gold/Orange for rare fossils (Amber/Sphere)
	},
}

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local espCache = {}
local fossilCache = {}
local aimbotActive = false
local aimbotSnapline = Drawing.new("Line")
local aimbotKeybindWidget = nil

local hasMatchaUI = typeof(UI) == "table" and typeof(UI.AddTab) == "function"

-- Safe getter function to retrieve Roblox Enums on demand, preventing premature indexing issues
local function getRobloxEnum(enumName, itemName)
	local enum = Enum[enumName]
	if enum then
		return enum[itemName]
	end
	return nil
end

local SPECIAL_KEYS = {
	[0x01] = "MouseButton1",
	[0x02] = "MouseButton2",
	[0x04] = "MouseButton3",
	[0x05] = "MouseButton4",
	[0x06] = "MouseButton5",
	[0x10] = "LeftShift",
	[0x11] = "LeftControl",
	[0x12] = "LeftAlt",
	[0x20] = "Space",
}

local NUM_MAP = { "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine" }

local function resolveKey(key)
	if typeof(key) == "EnumItem" then
		return key
	end
	if typeof(key) == "number" then
		if SPECIAL_KEYS[key] then
			local keyName = SPECIAL_KEYS[key]
			if string.find(keyName, "MouseButton") then
				return getRobloxEnum("UserInputType", keyName)
			else
				return getRobloxEnum("KeyCode", keyName)
			end
		elseif key >= 0x41 and key <= 0x5A then -- A-Z
			local char = string.char(key)
			return getRobloxEnum("KeyCode", char)
		elseif key >= 0x30 and key <= 0x39 then -- 0-9
			local name = NUM_MAP[key - 0x30 + 1]
			return getRobloxEnum("KeyCode", name)
		end
	end
	return nil
end

local function getValue(id, configPath)
	if hasMatchaUI then
		local success, val = pcall(function()
			return UI.GetValue(id)
		end)
		if success and val ~= nil then
			return val
		end
	end

	-- Fallback to local Config table
	local current = Config
	for _, step in ipairs(configPath) do
		if current and typeof(current) == "table" then
			current = current[step]
		else
			return nil
		end
	end
	return current
end

-- Initialize Matcha Tab if loaded
if hasMatchaUI then
	pcall(function()
		UI.AddTab("Void", function(tab)
			-- Left Column: ESP & Lighting
			local espSec = tab:Section("ESP Settings", "Left")
			espSec:Toggle("esp_enabled", "ESP Main", Config.ESP.Enabled)
			espSec:Toggle("fossil_enabled", "Fossil ESP", Config.Fossils.Enabled)

			local lightSec = tab:Section("Visual Adjustments", "Left")
			lightSec:Toggle("fullbright_enabled", "Fullbright", Config.Fullbright.Enabled)
			lightSec:Toggle("nofog_enabled", "No Fog", Config.NoFog.Enabled)

			-- Right Column: Aimbot
			local aimSec = tab:Section("Aimbot Settings", "Right")
			aimSec:Toggle("aim_enabled", "Aimbot Enabled", Config.Aimbot.Enabled)

			-- Keybind for Aimbot (linked under toggle)
			local defaultKey = 0x51 -- Q Key
			local kb = aimSec:Keybind("aim_kb", defaultKey, "hold")
			aimbotKeybindWidget = kb
			kb:AddToHotkey("Aimbot Lock", "aim_enabled")

			aimSec:SliderInt("aim_smoothing", "Aim Smoothing", 1, 20, Config.Aimbot.Smoothing)
			aimSec:Toggle("aim_snapline", "Aim Snapline", Config.Aimbot.Snapline.Enabled)
		end)
	end)
end

local function getAimKeyEnum()
	local keyStr = Config.Aimbot.AimKey
	if typeof(keyStr) == "string" then
		-- Try KeyCode first
		local success, key = pcall(function()
			return Enum.KeyCode[keyStr]
		end)
		if success and key then
			return key
		end
		-- Try UserInputType
		local success2, key2 = pcall(function()
			return Enum.UserInputType[keyStr]
		end)
		if success2 and key2 then
			return key2
		end
	end
	return keyStr
end

local function isAlive(character)
	-- Try attribute health
	local health = character:GetAttribute("Health")
	if health then
		return health > 0
	end

	-- Try humanoid health
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		return humanoid.Health > 0
	end

	-- Fallback: if character exists and has parts, assume they are alive
	return true
end

local function createEspLabel()
	local textLabel = Drawing.new("Text")
	textLabel.Outline = Config.ESP.TextOutline
	textLabel.Size = Config.ESP.TextSize
	textLabel.Font = 2
	textLabel.Center = true
	textLabel.Visible = false
	return textLabel
end

local function getTargetPart(character)
	-- Prioritize the "Hitbox" model/folder first
	local hitbox = character:FindFirstChild("Hitbox")
	if hitbox and (hitbox:IsA("Model") or hitbox:IsA("Folder")) then
		local head = hitbox:FindFirstChild("Head") or hitbox:FindFirstChild("Skull") or hitbox:FindFirstChild("head")
		if head and head:IsA("BasePart") then
			return head
		end

		if hitbox:IsA("Model") and hitbox.PrimaryPart then
			return hitbox.PrimaryPart
		end

		for _, child in ipairs(hitbox:GetChildren()) do
			if child:IsA("BasePart") then
				return child
			end
		end
	end

	-- Default fallbacks
	if character.PrimaryPart and character.PrimaryPart:IsA("BasePart") then
		return character.PrimaryPart
	end

	local head = character:FindFirstChild("Head")
	if head and head:IsA("BasePart") then
		return head
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("BasePart") then
			return child
		end
	end

	return nil
end

local function getLocalPlayerPosition()
	local character = localPlayer.Character
	if character then
		if character.PrimaryPart then
			return character.PrimaryPart.Position
		elseif character:FindFirstChild("HumanoidRootPart") then
			return character.HumanoidRootPart.Position
		end
	end
	return Workspace.CurrentCamera.CFrame.Position
end

local function formatEspText(character, distance)
	local name = character.Name
	local health = character:GetAttribute("Health") or 0
	local maxHealth = character:GetAttribute("MaxHealth") or 100

	local characterType = tostring(character:GetAttribute("Type") or "Unknown")
	local stage = tostring(character:GetAttribute("Stage") or "Unknown")

	return string.format(
		"%s\n%d / %d\n%s\n%s\n%d studs",
		name,
		math.floor(health),
		math.floor(maxHealth),
		characterType,
		stage,
		math.floor(distance)
	)
end

local function worldToScreen(position)
	-- Prioritize Roblox's highly optimized and reliable WorldToViewportPoint
	local camera = Workspace.CurrentCamera
	if camera then
		local success, screenPos, isOnScreen = pcall(function()
			return camera:WorldToViewportPoint(position)
		end)
		if success and screenPos then
			return screenPos, isOnScreen
		end
	end

	-- Fallback to executor's custom function if camera fails
	local globalEnv = (getgenv or getfenv)()
	local w2s = globalEnv.worldtoscreen or globalEnv.WorldToScreen or _G.worldtoscreen
	if typeof(w2s) == "function" then
		local success, screenPos, isOnScreen = pcall(w2s, position)
		if success and screenPos then
			return screenPos, isOnScreen
		end
	end

	return Vector3.new(0, 0, 0), false
end

local function updateEsp()
	local folder = Workspace:FindFirstChild("Characters")

	local espEnabled = getValue("esp_enabled", { "ESP", "Enabled" })
	if not espEnabled or not folder then
		for character, textLabel in pairs(espCache) do
			textLabel:Remove()
			espCache[character] = nil
		end
		return
	end

	-- 1. Gather all truly active and alive characters this exact frame
	local activeCharacters = {}

	for _, character in ipairs(folder:GetChildren()) do
		-- Skip local player ESP if their name matches
		if localPlayer and character.Name == localPlayer.Name then
			continue
		end

		if isAlive(character) then
			activeCharacters[character] = true

			if not espCache[character] then
				espCache[character] = createEspLabel()
			end
		end
	end

	local localPosition = getLocalPlayerPosition()

	-- 2. Process our cache
	for character, textLabel in pairs(espCache) do
		-- If they are NOT in the activeCharacters list (they died, left the folder, or were destroyed), wipe them.
		if not activeCharacters[character] then
			textLabel:Remove()
			espCache[character] = nil
			continue
		end

		local targetPart = getTargetPart(character)

		-- If they are alive but the target part hasn't loaded yet, HIDE the ESP
		if not targetPart then
			textLabel.Visible = false
			continue
		end

		if typeof(targetPart.Position) ~= "Vector3" then
			textLabel.Visible = false
			continue
		end

		local espWorldPosition = targetPart.Position + Vector3.new(0, Config.ESP.YOffset, 0)
		local screenPosition, isOnScreen = worldToScreen(espWorldPosition)

		if isOnScreen then
			local distance = (targetPart.Position - localPosition).Magnitude
			textLabel.Text = formatEspText(character, distance)

			-- Distance-based coloring
			if distance >= 700 then
				textLabel.Color = Config.ESP.ColorFar
			elseif distance <= 200 then
				textLabel.Color = Config.ESP.ColorNear
			else
				textLabel.Color = Config.ESP.ColorMid
			end

			-- Realtime config updates
			textLabel.Outline = Config.ESP.TextOutline
			textLabel.Size = Config.ESP.TextSize

			textLabel.Position = Vector2.new(screenPosition.X, screenPosition.Y)
			textLabel.Visible = true
		else
			textLabel.Visible = false
		end
	end
end

local function getFossilDetails(fossil)
	local targetPart = nil
	local displayName = "Fossil"
	local displayColor = Config.Fossils.Color

	-- Detect specific fossil structural parts based on dump logs
	local sphere = fossil:FindFirstChild("Sphere")
	local fossilM = fossil:FindFirstChild("FossilM")
	local fossilS = fossil:FindFirstChild("FossilS")

	if sphere and sphere:IsA("BasePart") then
		targetPart = sphere
		displayName = "Rare Fossil"
		displayColor = Config.Fossils.ColorRare
	elseif fossilM and fossilM:IsA("BasePart") then
		targetPart = fossilM
		displayName = "Fossil [M]"
		displayColor = Config.Fossils.ColorMedium
	elseif fossilS and fossilS:IsA("BasePart") then
		targetPart = fossilS
		displayName = "Fossil [S]"
		displayColor = Config.Fossils.ColorSmall
	else
		-- Fallback to the part containing the proximity prompt
		for _, child in ipairs(fossil:GetChildren()) do
			if child:IsA("BasePart") and child:FindFirstChildOfClass("ProximityPrompt") then
				targetPart = child
				break
			end
		end

		-- Secondary fallback
		if not targetPart then
			if fossil:IsA("BasePart") then
				targetPart = fossil
			elseif fossil:IsA("Model") then
				targetPart = fossil.PrimaryPart or fossil:FindFirstChildOfClass("BasePart")
			end
		end
	end

	return targetPart, displayName, displayColor
end

local function updateFossilEsp()
	local folder = Workspace:FindFirstChild("SpawnedFossils")

	local espEnabled = getValue("esp_enabled", { "ESP", "Enabled" })
	local fossilsEnabled = getValue("fossil_enabled", { "Fossils", "Enabled" })
	if not fossilsEnabled or not folder then
		for fossil, textLabel in pairs(fossilCache) do
			textLabel:Remove()
			fossilCache[fossil] = nil
		end
		return
	end

	-- 1. Gather all active fossils
	local activeFossils = {}
	for _, fossil in ipairs(folder:GetChildren()) do
		activeFossils[fossil] = true
		if not fossilCache[fossil] then
			fossilCache[fossil] = createEspLabel()
		end
	end

	local localPosition = getLocalPlayerPosition()

	-- 2. Process cache
	for fossil, textLabel in pairs(fossilCache) do
		if not activeFossils[fossil] then
			textLabel:Remove()
			fossilCache[fossil] = nil
			continue
		end

		local targetPart, displayName, displayColor = getFossilDetails(fossil)

		if not targetPart then
			textLabel.Visible = false
			continue
		end

		local espWorldPosition = targetPart.Position
		local screenPosition, isOnScreen = worldToScreen(espWorldPosition)

		if isOnScreen then
			local distance = (targetPart.Position - localPosition).Magnitude
			textLabel.Text = string.format("%s\n%d studs", displayName, math.floor(distance))
			textLabel.Color = displayColor
			textLabel.Outline = Config.ESP.TextOutline
			textLabel.Size = Config.ESP.TextSize
			textLabel.Position = Vector2.new(screenPosition.X, screenPosition.Y)
			textLabel.Visible = true
		else
			textLabel.Visible = false
		end
	end
end

local function applyFullbright()
	local fullbrightEnabled = getValue("fullbright_enabled", { "Fullbright", "Enabled" })
	if not fullbrightEnabled then
		return
	end

	pcall(function()
		Lighting.Brightness = 2
	end)
	pcall(function()
		Lighting.ClockTime = 14
	end)
	pcall(function()
		Lighting.GlobalShadows = false
	end)
	pcall(function()
		Lighting.Ambient = Color3.new(1, 1, 1)
	end)
	pcall(function()
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
	end)
	pcall(function()
		Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
	end)
	pcall(function()
		Lighting.ColorShift_Top = Color3.new(1, 1, 1)
	end)

	-- Destroying atmosphere/sky is the only guaranteed way to force fullbright in modern Roblox
	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("Atmosphere") or child:IsA("Sky") then
			pcall(function()
				child:Destroy()
			end)
		elseif
			child:IsA("PostEffect")
			or child:IsA("ColorCorrectionEffect")
			or child:IsA("BloomEffect")
			or child:IsA("BlurEffect")
			or child:IsA("SunRaysEffect")
		then
			pcall(function()
				child.Enabled = false
			end)
		end
	end
end

local function applyNoFog()
	local noFogEnabled = getValue("nofog_enabled", { "NoFog", "Enabled" })
	if not noFogEnabled then
		return
	end

	pcall(function()
		Lighting.FogEnd = 100000
	end)
	pcall(function()
		Lighting.FogStart = 0
	end)
end

local function getMouseLocation()
	local success, pos = pcall(function()
		return UserInputService:GetMouseLocation()
	end)
	if success and pos then
		return pos
	end

	-- Fallback to universally supported Player Mouse object
	local mouse = localPlayer and localPlayer:GetMouse()
	if mouse then
		return Vector2.new(mouse.X, mouse.Y)
	end

	return Vector2.new(0, 0)
end

local function getClosestTarget()
	local folder = Workspace:FindFirstChild("Characters")
	if not folder or not localPlayer then
		return nil
	end

	local mousePos = getMouseLocation()
	local closestPart = nil
	local minDistance = math.huge

	for _, character in ipairs(folder:GetChildren()) do
		if localPlayer.Character and character == localPlayer.Character then
			continue
		end
		if localPlayer and character.Name == localPlayer.Name then
			continue
		end
		if not isAlive(character) then
			continue
		end

		local aimPart = getTargetPart(character)
		if aimPart then
			local screenPos, isOnScreen = worldToScreen(aimPart.Position)
			if isOnScreen then
				local sx = screenPos.X
				local sy = screenPos.Y
				local mx = mousePos.X
				local my = mousePos.Y

				local dx = sx - mx
				local dy = sy - my
				local dist = math.sqrt(dx * dx + dy * dy)

				if dist < minDistance then
					minDistance = dist
					closestPart = aimPart
				end
			end
		end
	end

	return closestPart
end

local function applyAimbot()
	local function hideSnapline()
		if aimbotSnapline then
			aimbotSnapline.Visible = false
		end
	end

	-- Update active state from Matcha UI if available
	local isAiming = false
	if hasMatchaUI and aimbotKeybindWidget then
		pcall(function()
			local bindType = aimbotKeybindWidget:GetType()
			if bindType == "always" then
				isAiming = true
			else
				isAiming = aimbotActive
			end
		end)
	else
		isAiming = aimbotActive
	end

	local aimEnabled = getValue("aim_enabled", { "Aimbot", "Enabled" })
	if not aimEnabled then
		hideSnapline()
		return
	end

	local targetPart = getClosestTarget()
	if targetPart then
		local screenPos, isOnScreen = worldToScreen(targetPart.Position)
		if isOnScreen then
			local camera = Workspace.CurrentCamera
			if camera then
				local viewportSize = camera.ViewportSize
				local sx = screenPos.X
				local sy = screenPos.Y
				local mx = viewportSize.X / 2
				local my = viewportSize.Y / 2

				-- 1. Draw snapline (Always show when Aimbot is enabled and target is visible)
				local snaplineEnabled = getValue("aim_snapline", { "Aimbot", "Snapline", "Enabled" })
				if aimbotSnapline and snaplineEnabled then
					aimbotSnapline.From = Vector2.new(mx, my)
					aimbotSnapline.To = Vector2.new(sx, sy)
					aimbotSnapline.Color = Config.Aimbot.Snapline.Color
					aimbotSnapline.Thickness = Config.Aimbot.Snapline.Thickness
					aimbotSnapline.Transparency = Config.Aimbot.Snapline.Transparency
					aimbotSnapline.Visible = true
				else
					hideSnapline()
				end

				-- 2. Move mouse with smoothing (Only lock when actively aiming)
				if isAiming then
					local smooth = getValue("aim_smoothing", { "Aimbot", "Smoothing" })
					local dx = (sx - mx) / smooth
					local dy = (sy - my) / smooth

					-- Use executor's native mousemoverel
					local globalEnv = (getgenv or getfenv)()
					local moveRel = globalEnv.mousemoverel or globalEnv.MouseMoveRel or _G.mousemoverel
					if typeof(moveRel) == "function" then
						pcall(moveRel, dx, dy)
					end
				end
			else
				hideSnapline()
			end
		else
			hideSnapline()
		end
	else
		hideSnapline()
	end
end

-- Input Listeners for Toggle and Hold support (ignoring gameProcessed so keys always register)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	local aimEnabled = getValue("aim_enabled", { "Aimbot", "Enabled" })
	if not aimEnabled then
		return
	end

	-- Resolve target key dynamically from Matcha UI keybind if available, else fallback
	local targetKey = nil
	if hasMatchaUI and aimbotKeybindWidget then
		pcall(function()
			targetKey = resolveKey(aimbotKeybindWidget:GetKey())
		end)
	end
	if not targetKey then
		targetKey = getAimKeyEnum()
	end

	if not targetKey then
		return
	end

	local match = false
	pcall(function()
		if input.UserInputType == targetKey or input.KeyCode == targetKey then
			match = true
		end
	end)

	if match then
		-- Resolve keybind type (toggle vs hold)
		local bindType = "hold"
		if hasMatchaUI and aimbotKeybindWidget then
			pcall(function()
				bindType = aimbotKeybindWidget:GetType()
			end)
		else
			if Config.Aimbot.Toggle then
				bindType = "toggle"
			end
		end

		if bindType == "toggle" or bindType == "click" then
			aimbotActive = not aimbotActive
		else
			aimbotActive = true
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	-- Resolve target key dynamically from Matcha UI keybind if available, else fallback
	local targetKey = nil
	if hasMatchaUI and aimbotKeybindWidget then
		pcall(function()
			targetKey = resolveKey(aimbotKeybindWidget:GetKey())
		end)
	end
	if not targetKey then
		targetKey = getAimKeyEnum()
	end

	if not targetKey then
		return
	end

	local match = false
	pcall(function()
		if input.UserInputType == targetKey or input.KeyCode == targetKey then
			match = true
		end
	end)

	if match then
		-- Resolve keybind type (toggle vs hold)
		local bindType = "hold"
		if hasMatchaUI and aimbotKeybindWidget then
			pcall(function()
				bindType = aimbotKeybindWidget:GetType()
			end)
		else
			if Config.Aimbot.Toggle then
				bindType = "toggle"
			end
		end

		if bindType == "hold" then
			aimbotActive = false
		end
	end
end)

-- Bind Aimbot to run after the default Camera script (fixes stutters/overriding camera scripts)
local successBind = pcall(function()
	RunService:BindToRenderStep("AimbotLock", Enum.RenderPriority.Camera.Value + 1, applyAimbot)
end)

if not successBind then
	-- Fallback if BindToRenderStep is restricted by Matcha
	RunService.RenderStepped:Connect(function()
		applyAimbot()
	end)
end

-- Bind other features to RenderStepped
RunService.RenderStepped:Connect(function()
	updateEsp()
	updateFossilEsp()
	applyFullbright()
	applyNoFog()
end)
print("[+] Script loader executed successfully.")
