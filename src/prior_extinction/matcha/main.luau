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
	Corpses = {
		Enabled = false,
		Color = Color3.fromRGB(128, 128, 128), -- Gray
	},
	TeleportBelow = {
		Enabled = true,
		TpKey = "T",
	},
}

local Workspace = game:GetService("Workspace") or game.Workspace
local RunService = game:GetService("RunService") or game.RunService
local Players = game:GetService("Players") or game.Players
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players and Players.LocalPlayer

local espCache = {}
local fossilCache = {}
local corpseCache = {}
local aimbotActive = false
local tpBelowActive = false
local aimbotSnapline = Drawing.new("Line")
local aimbotKeybindWidget = nil
local tpKeybindWidget = nil
local tpToggleWidget = nil

local teleportState = {
	active = false,
	originalCFrame = nil,
	character = nil,
	anchoredParts = {},
}

local hasMatchaUI = typeof(UI) == "table" and typeof(UI.AddTab) == "function"

-- Safe getter function to retrieve Roblox Enums on demand, preventing premature indexing issues
local function getRobloxEnum(enumName, itemName)
	local enum = Enum[enumName]
	if enum then
		local success, result = pcall(function()
			return enum[itemName]
		end)
		if success then
			return result
		end
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
	if typeof(key) == "string" then
		local keyCode = getRobloxEnum("KeyCode", key)
		if keyCode then
			return keyCode
		end
		local uiType = getRobloxEnum("UserInputType", key)
		if uiType then
			return uiType
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
	if not configPath then
		return current
	end
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
			espSec:Toggle("corpse_enabled", "Corpse ESP", Config.Corpses.Enabled)
			-- Right Column: Aimbot
			local aimSec = tab:Section("Aimbot Settings", "Right")
			aimSec:Toggle("aim_enabled", "Aimbot Enabled", Config.Aimbot.Enabled)

			-- Keybind for Aimbot (linked under toggle)
			local defaultKey = resolveKey(Config.Aimbot.AimKey) or 0x51
			local kb = aimSec:Keybind("aim_kb", defaultKey, "hold")
			aimbotKeybindWidget = kb
			kb:AddToHotkey("Aimbot Lock", "aim_enabled")

			aimSec:SliderInt("aim_smoothing", "Aim Smoothing", 1, 20, Config.Aimbot.Smoothing)
			aimSec:Toggle("aim_snapline", "Aim Snapline", Config.Aimbot.Snapline.Enabled)

			-- Teleport Below
			local tpSec = tab:Section("Escape", "Right")
			local tpToggle = tpSec:Toggle("tp_below_enabled", "Teleport Below (-50 Y)", Config.TeleportBelow.Enabled)
			tpToggleWidget = tpToggle

			local defaultTpKey = resolveKey(Config.TeleportBelow.TpKey) or 0x54
			local tpKb = tpSec:Keybind("tp_kb", defaultTpKey, "toggle")
			tpKeybindWidget = tpKb
			tpKb:AddToHotkey("Teleport Below", "tp_below_enabled")
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

local function getTpKeyEnum()
	local keyStr = Config.TeleportBelow.TpKey
	if typeof(keyStr) == "string" then
		local success, key = pcall(function()
			return Enum.KeyCode[keyStr]
		end)
		if success and key then
			return key
		end
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
	-- In Prior Extinction, the dino model is at Workspace.Characters[localPlayer.Name]
	if localPlayer then
		local chars = Workspace:FindFirstChild("Characters")
		local character = chars and chars:FindFirstChild(localPlayer.Name)
		if character then
			local primaryPart = character.PrimaryPart
				or character:FindFirstChild("HumanoidRootPart")
				or character:FindFirstChildWhichIsA("BasePart")
			if primaryPart then
				local pos = primaryPart.Position
				if typeof(pos) == "Vector3" then
					return pos
				end
			end
		end
	end

	if Workspace.CurrentCamera then
		local success, cf = pcall(function()
			return Workspace.CurrentCamera.CFrame
		end)
		if success and cf then
			local pos = cf.Position or cf.p
			if typeof(pos) == "Vector3" then
				return pos
			end
		end
	end

	return Vector3.new(0, 0, 0)
end

local function formatEspTextLines(character, distance)
	local name = character.Name
	local health = character:GetAttribute("Health") or 0
	local maxHealth = character:GetAttribute("MaxHealth") or 100

	local characterType = tostring(character:GetAttribute("Type") or "Unknown")
	local stage = tostring(character:GetAttribute("Stage") or "Unknown")

	return {
		name,
		string.format("%d / %d", math.floor(health), math.floor(maxHealth)),
		characterType,
		stage,
		string.format("%d m", math.floor(distance * 0.28)),
	}
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
		for character, textLabels in pairs(espCache) do
			for _, label in ipairs(textLabels) do
				label:Remove()
			end
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
				espCache[character] = {}
			end
		end
	end

	local localPosition = getLocalPlayerPosition()

	-- 2. Process our cache
	for character, textLabels in pairs(espCache) do
		-- If they are NOT in the activeCharacters list (they died, left the folder, or were destroyed), wipe them.
		if not activeCharacters[character] then
			for _, label in ipairs(textLabels) do
				label:Remove()
			end
			espCache[character] = nil
			continue
		end

		local targetPart = getTargetPart(character)

		-- If they are alive but the target part hasn't loaded yet, HIDE the ESP
		if not targetPart then
			for _, label in ipairs(textLabels) do
				label.Visible = false
			end
			continue
		end

		if typeof(targetPart.Position) ~= "Vector3" then
			for _, label in ipairs(textLabels) do
				label.Visible = false
			end
			continue
		end

		local espWorldPosition = targetPart.Position + Vector3.new(0, Config.ESP.YOffset, 0)
		local screenPosition, isOnScreen = worldToScreen(espWorldPosition)

		if isOnScreen then
			local distance = (targetPart.Position - localPosition).Magnitude
			local lines = formatEspTextLines(character, distance)

			-- Ensure we have exactly the right amount of Drawing objects
			while #textLabels < #lines do
				table.insert(textLabels, createEspLabel())
			end
			while #textLabels > #lines do
				local label = table.remove(textLabels)
				label:Remove()
			end

			local lineHeight = Config.ESP.TextSize + 2
			local yOffset = screenPosition.Y

			for i, textLabel in ipairs(textLabels) do
				textLabel.Text = lines[i]

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

				textLabel.Position = Vector2.new(screenPosition.X, yOffset + (i - 1) * lineHeight)
				textLabel.Visible = true
			end
		else
			for _, label in ipairs(textLabels) do
				label.Visible = false
			end
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

local fossilUpdateTick = 0
local cachedFossilList = {}

local function updateFossilEsp()
	local folder = Workspace:FindFirstChild("SpawnedFossils")

	local fossilsEnabled = getValue("fossil_enabled", { "Fossils", "Enabled" })
	if not fossilsEnabled or not folder then
		for fossil, textLabels in pairs(fossilCache) do
			for _, label in ipairs(textLabels) do
				label:Remove()
			end
			fossilCache[fossil] = nil
		end
		return
	end

	-- 1. Gather all active fossils efficiently (Update list once per second)
	local currentTime = os.clock()
	if currentTime > fossilUpdateTick then
		cachedFossilList = folder:GetChildren()
		fossilUpdateTick = currentTime + 1
	end

	local activeFossils = {}
	for _, fossil in ipairs(cachedFossilList) do
		if fossil.Parent then -- Ensure it hasn't been deleted
			activeFossils[fossil] = true
			if not fossilCache[fossil] then
				fossilCache[fossil] = {}
			end
		end
	end

	local localPosition = getLocalPlayerPosition()

	-- 2. Process cache
	for fossil, textLabels in pairs(fossilCache) do
		if not activeFossils[fossil] then
			for _, label in ipairs(textLabels) do
				label:Remove()
			end
			fossilCache[fossil] = nil
			continue
		end

		local targetPart, displayName, displayColor = getFossilDetails(fossil)

		if not targetPart then
			for _, label in ipairs(textLabels) do
				label.Visible = false
			end
			continue
		end

		local tPos = targetPart.Position
		if typeof(tPos) ~= "Vector3" or typeof(localPosition) ~= "Vector3" then
			for _, label in ipairs(textLabels) do
				label.Visible = false
			end
			continue
		end

		local distanceInStuds = (tPos - localPosition).Magnitude
		local distanceInMeters = math.floor(distanceInStuds * 0.28)

		-- Distance check: only 'Rare Fossil' can be seen from infinity. Everything else is capped at 150m.
		if displayName ~= "Rare Fossil" and distanceInMeters > 150 then
			for _, label in ipairs(textLabels) do
				label.Visible = false
			end
			continue
		end

		local espWorldPosition = targetPart.Position
		local screenPosition, isOnScreen = worldToScreen(espWorldPosition)

		if isOnScreen then
			local lines = { displayName, string.format("%d m", distanceInMeters) }

			while #textLabels < #lines do
				table.insert(textLabels, createEspLabel())
			end
			while #textLabels > #lines do
				local label = table.remove(textLabels)
				label:Remove()
			end

			local lineHeight = Config.ESP.TextSize + 2
			local yOffset = screenPosition.Y

			for i, textLabel in ipairs(textLabels) do
				textLabel.Text = lines[i]
				textLabel.Color = displayColor
				textLabel.Outline = Config.ESP.TextOutline
				textLabel.Size = Config.ESP.TextSize
				textLabel.Position = Vector2.new(screenPosition.X, yOffset + (i - 1) * lineHeight)
				textLabel.Visible = true
			end
		else
			for _, label in ipairs(textLabels) do
				label.Visible = false
			end
		end
	end
end

local corpseUpdateTick = 0
local cachedCorpseList = {}

local function updateCorpseEsp()
	local espEnabled = getValue("esp_enabled", { "ESP", "Enabled" })
	local corpsesEnabled = getValue("corpse_enabled", { "Corpses", "Enabled" })

	local charIgnore = Workspace:FindFirstChild("CharacterIgnore")
	local ragdollsFolder = charIgnore and charIgnore:FindFirstChild("Ragdolls")

	if not corpsesEnabled or not espEnabled or not ragdollsFolder then
		for corpse, textLabels in pairs(corpseCache) do
			for _, label in ipairs(textLabels) do
				label:Remove()
			end
			corpseCache[corpse] = nil
		end
		return
	end

	-- 1. Gather all active corpses efficiently (Update list once per second)
	local currentTime = os.clock()
	if currentTime > corpseUpdateTick then
		cachedCorpseList = {}
		for _, host in ipairs(ragdollsFolder:GetChildren()) do
			if host.Name == "Host" then
				local physics = host:FindFirstChild("Physics")
				if physics and physics:FindFirstChild("HumanoidRootPart") then
					table.insert(cachedCorpseList, host)
				end
			end
		end
		corpseUpdateTick = currentTime + 1
	end

	local activeCorpses = {}
	for _, host in ipairs(cachedCorpseList) do
		if host.Parent then
			activeCorpses[host] = true
			if not corpseCache[host] then
				corpseCache[host] = {}
			end
		end
	end

	local localPosition = getLocalPlayerPosition()

	-- 2. Process cache
	for host, textLabels in pairs(corpseCache) do
		if not activeCorpses[host] then
			for _, label in ipairs(textLabels) do
				label:Remove()
			end
			corpseCache[host] = nil
			continue
		end

		local physics = host:FindFirstChild("Physics")
		local rootPart = physics and physics:FindFirstChild("HumanoidRootPart")

		if not rootPart then
			for _, label in ipairs(textLabels) do
				label.Visible = false
			end
			continue
		end

		local tPos
		pcall(function()
			tPos = rootPart.Position
		end)

		if typeof(tPos) ~= "Vector3" or typeof(localPosition) ~= "Vector3" then
			for _, label in ipairs(textLabels) do
				label.Visible = false
			end
			continue
		end

		local distanceInStuds = (tPos - localPosition).Magnitude
		local distanceInMeters = math.floor(distanceInStuds * 0.28)

		local screenPosition, isOnScreen = worldToScreen(tPos)

		if isOnScreen then
			-- Read attributes
			local weight = physics:GetAttribute("Weight") or host:GetAttribute("Weight") or "?"
			local species = physics:GetAttribute("Species") or host:GetAttribute("Species") or "Unknown"

			local weightStr = tostring(weight)
			if type(weight) == "number" then
				weightStr = string.format("%d", math.floor(weight))
			end

			local lines = {
				"Corpse",
				string.format("%s lbs", weightStr),
				tostring(species),
				string.format("%d m", distanceInMeters),
			}

			while #textLabels < #lines do
				table.insert(textLabels, createEspLabel())
			end
			while #textLabels > #lines do
				local label = table.remove(textLabels)
				label:Remove()
			end

			local lineHeight = Config.ESP.TextSize + 2
			local yOffset = screenPosition.Y

			for i, textLabel in ipairs(textLabels) do
				textLabel.Text = lines[i]
				textLabel.Color = Config.Corpses.Color
				textLabel.Outline = Config.ESP.TextOutline
				textLabel.Size = Config.ESP.TextSize
				textLabel.Position = Vector2.new(screenPosition.X, yOffset + (i - 1) * lineHeight)
				textLabel.Visible = true
			end
		else
			for _, label in ipairs(textLabels) do
				label.Visible = false
			end
		end
	end
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
		local success, enabled = pcall(function()
			return aimbotKeybindWidget:IsEnabled()
		end)
		if success then
			isAiming = enabled
		else
			pcall(function()
				isAiming = aimbotKeybindWidget.value
			end)
		end
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

local tpDebounce = false

-- Input Listeners for Toggle and Hold support (ignoring gameProcessed so keys always register)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- Teleport Below Keybind Handling
	local tpKey = nil
	if hasMatchaUI and tpKeybindWidget then
		pcall(function()
			tpKey = resolveKey(tpKeybindWidget:GetKey())
		end)
	end
	if not tpKey then
		tpKey = getTpKeyEnum()
	end

	if tpKey then
		local tpMatch = false
		pcall(function()
			if input.UserInputType == tpKey or input.KeyCode == tpKey then
				tpMatch = true
			end
		end)
		if tpMatch then
			local bindType = "toggle"
			if hasMatchaUI and tpKeybindWidget then
				pcall(function()
					bindType = tpKeybindWidget:GetType()
				end)
			end

			if bindType == "toggle" or bindType == "click" then
				tpBelowActive = not tpBelowActive
			else
				tpBelowActive = true
			end
		end
	end

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
	-- Teleport Below Keybind Handling
	local tpKey = nil
	if hasMatchaUI and tpKeybindWidget then
		pcall(function()
			tpKey = resolveKey(tpKeybindWidget:GetKey())
		end)
	end
	if not tpKey then
		tpKey = getTpKeyEnum()
	end

	if tpKey then
		local tpMatch = false
		pcall(function()
			if input.UserInputType == tpKey or input.KeyCode == tpKey then
				tpMatch = true
			end
		end)
		if tpMatch then
			local bindType = "hold"
			if hasMatchaUI and tpKeybindWidget then
				pcall(function()
					bindType = tpKeybindWidget:GetType()
				end)
			else
				bindType = "toggle"
			end
			if bindType == "hold" then
				tpBelowActive = false
			end
		end
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

local function applyTeleportBelow()
	local shouldBeTeleported = false
	if hasMatchaUI and tpToggleWidget and tpKeybindWidget then
		-- When UI is present, read the master switch and the keybind active state directly from the UI widgets.
		local tpEnabled = tpToggleWidget:GetValue() == true
		local isActive = false
		local success, enabled = pcall(function()
			return tpKeybindWidget:IsEnabled()
		end)
		if success then
			isActive = enabled
		else
			pcall(function()
				isActive = tpKeybindWidget.value
			end)
		end
		shouldBeTeleported = tpEnabled and isActive
	else
		-- No UI: use the manual config switch and manually tracked keybind state
		local tpEnabled = getValue("tp_below_enabled", { "TeleportBelow", "Enabled" })
		shouldBeTeleported = (tpEnabled == true) and (tpBelowActive == true)
	end

	-- Dino model lives at Workspace.Characters[localPlayer.Name] in Prior Extinction
	local myCharacter = nil
	if localPlayer then
		local chars = Workspace:FindFirstChild("Characters")
		if chars then
			myCharacter = chars:FindFirstChild(localPlayer.Name)
		end
		if not myCharacter then
			local spawnedAI = Workspace:FindFirstChild("SpawnedAI")
			if spawnedAI then
				myCharacter = spawnedAI:FindFirstChild(localPlayer.Name)
			end
		end
	end

	if not myCharacter then
		return
	end

	local primaryPart = myCharacter.PrimaryPart
		or myCharacter:FindFirstChild("HumanoidRootPart")
		or myCharacter:FindFirstChildWhichIsA("BasePart")
	if not primaryPart then
		return
	end

	-- If character changed (e.g. respawned), reset state silently so they aren't trapped
	if teleportState.active and teleportState.character ~= myCharacter then
		teleportState.active = false
		teleportState.originalCFrame = nil
		teleportState.character = nil
		if teleportState.platform then
			teleportState.platform:Destroy()
			teleportState.platform = nil
		end
		table.clear(teleportState.anchoredParts)
	end

	if shouldBeTeleported and not teleportState.active then
		-- Save state
		teleportState.character = myCharacter
		teleportState.originalCFrame = primaryPart.CFrame
		teleportState.active = true

		-- Stop movement so they don't walk off
		local hum = myCharacter:FindFirstChildOfClass("Humanoid")
		if hum then
			teleportState.oldWalkSpeed = hum.WalkSpeed
			teleportState.oldJumpPower = hum.JumpPower
			hum.WalkSpeed = 0
			hum.JumpPower = 0
		end

		-- Teleport them down
		primaryPart.CFrame = teleportState.originalCFrame * CFrame.new(0, -50, 0)
		pcall(function()
			primaryPart.Velocity = Vector3.new(0, 0, 0)
		end)
		pcall(function()
			primaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		end)
	elseif not shouldBeTeleported and teleportState.active then
		-- Restore state and teleport up
		if teleportState.originalCFrame then
			primaryPart.CFrame = teleportState.originalCFrame
		end

		local hum = myCharacter:FindFirstChildOfClass("Humanoid")
		if hum and teleportState.oldWalkSpeed then
			hum.WalkSpeed = teleportState.oldWalkSpeed
			hum.JumpPower = teleportState.oldJumpPower
		end

		-- Try to reset velocity if Matcha supports it so they don't shoot into the sky
		pcall(function()
			primaryPart.Velocity = Vector3.new(0, 0, 0)
		end)
		pcall(function()
			primaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		end)

		teleportState.active = false
		teleportState.originalCFrame = nil
		teleportState.character = nil
	end
end

-- Aggressive lock to fight custom dinosaur physics controllers
local function aggressiveCFrameLock()
	if teleportState.active and teleportState.character and teleportState.originalCFrame then
		local primaryPart = teleportState.character.PrimaryPart
			or teleportState.character:FindFirstChild("HumanoidRootPart")
		if primaryPart then
			primaryPart.CFrame = teleportState.originalCFrame * CFrame.new(0, -50, 0)
			pcall(function()
				primaryPart.Velocity = Vector3.new(0, 0, 0)
			end)
			pcall(function()
				primaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			end)
		end
	end
end

pcall(function()
	RunService.Stepped:Connect(aggressiveCFrameLock)
end)
pcall(function()
	RunService.Heartbeat:Connect(aggressiveCFrameLock)
end)

local function mainLoop()
	if not localPlayer and Players then
		localPlayer = Players.LocalPlayer
	end
	updateEsp()
	applyTeleportBelow()
	updateFossilEsp()
	updateCorpseEsp()
end

-- Bind other features directly to RenderStepped to avoid executor BindToRenderStep throttling/lag
pcall(function()
	RunService.RenderStepped:Connect(mainLoop)
end)

print("[+] Script loader executed successfully.")
