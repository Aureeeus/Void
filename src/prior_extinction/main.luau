local EspConfig = {
	Enabled = true,
	ColorFar = Color3.new(0, 1, 0), -- 700+ studs (Green)
	ColorMid = Color3.new(1, 1, 0), -- 200-700 studs (Yellow)
	ColorNear = Color3.new(1, 0, 0), -- <=200 studs (Red)
	TextOutline = true,
	TextSize = 14,
	YOffset = 5,
}

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local espCache = {}

local function isAlive(character)
	local health = character:GetAttribute("Health")
	if health and health > 0 then
		return true
	end
	return false
end

local function createEspLabel()
	local textLabel = Drawing.new("Text")
	textLabel.Outline = EspConfig.TextOutline
	textLabel.Size = EspConfig.TextSize
	textLabel.Font = 2
	textLabel.Center = true
	textLabel.Visible = false
	return textLabel
end

local function getTargetPart(character)
	if character.PrimaryPart then
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
	-- Use executor's native worldtoscreen if available
	local globalEnv = (getgenv or getfenv)()
	local w2s = globalEnv.worldtoscreen or globalEnv.WorldToScreen or _G.worldtoscreen

	if typeof(w2s) == "function" then
		local success, screenPos, isOnScreen = pcall(w2s, position)
		if success then
			return screenPos, isOnScreen
		end
	end

	-- Fallback to Roblox Camera
	local camera = Workspace.CurrentCamera
	if camera then
		local success, screenPos, isOnScreen = pcall(function()
			return camera:WorldToScreenPoint(position)
		end)
		if success then
			return screenPos, isOnScreen
		end
	end

	return Vector3.new(0, 0, 0), false
end

local function updateEsp()
	local folder = Workspace:FindFirstChild("Characters")

	if not EspConfig.Enabled or not folder then
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

		local espWorldPosition = targetPart.Position + Vector3.new(0, EspConfig.YOffset, 0)
		local screenPosition, isOnScreen = worldToScreen(espWorldPosition)

		if isOnScreen then
			local distance = (targetPart.Position - localPosition).Magnitude
			textLabel.Text = formatEspText(character, distance)

			-- Distance-based coloring
			if distance >= 700 then
				textLabel.Color = EspConfig.ColorFar
			elseif distance <= 200 then
				textLabel.Color = EspConfig.ColorNear
			else
				textLabel.Color = EspConfig.ColorMid
			end

			-- Realtime config updates
			textLabel.Outline = EspConfig.TextOutline
			textLabel.Size = EspConfig.TextSize

			textLabel.Position = Vector2.new(screenPosition.X, screenPosition.Y)
			textLabel.Visible = true
		else
			textLabel.Visible = false
		end
	end
end

-- Bind to RenderStepped
RunService.RenderStepped:Connect(updateEsp)
print("[+] ESP loader executed successfully.")
