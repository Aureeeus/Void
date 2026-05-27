local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local WindUI = nil

-- [[ GLOBAL CONFIGURATION ]]
getgenv().Config = getgenv().Config
	or {
		KillAura = {
			Enabled = false,
			ReachRadius = 30,
			ToggleKey = Enum.KeyCode.T,
			Cooldown = 1.0,
			TargetPart = "Dynamic", -- "Dynamic", "Head", "HumanoidRootPart", "Hip", "Leg"
		},
		ESP = {
			Enabled = true,
			ToggleKey = Enum.KeyCode.Y,
			ColorFar = Color3.fromRGB(0, 255, 0), -- >= 700 studs (Green)
			ColorMid = Color3.fromRGB(255, 255, 0), -- 200-700 studs (Yellow)
			ColorNear = Color3.fromRGB(255, 0, 0), -- <= 200 studs (Red)
			Opacity = 1,
			TextSize = 16,
		},
		HitboxExpander = {
			Enabled = false,
			Size = Vector3.new(15, 15, 15),
			Transparency = 0.5,
			TargetPart = "HumanoidRootPart", -- "HumanoidRootPart" or "Head"
		},
		Mods = {
			NoCooldown = false,
		},
		MenuKeybind = Enum.KeyCode.RightShift,
	}

local Config = getgenv().Config

local state = {
	auraEnabled = Config.KillAura.Enabled,
	espEnabled = Config.ESP.Enabled,
	lastAttackTime = 0,
	originalSizes = {},
	espCache = {},
}

-- Fetch Knit Controllers securely
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local CharacterController = Knit.GetController("CharacterController")
local AIRegistrationController = Knit.GetController("AIRegistrationController")

local MockHitbox = require(ReplicatedStorage.Modules.Combat.MockHitbox)
local ComputeLocationalMultiplier = require(ReplicatedStorage.Modules.Combat.ComputeLocationalMultiplier)

-- [[ ANTICHEAT BYPASS ]]
local oldIndex
oldIndex = hookmetamethod(
	game,
	"__index",
	newcclosure(function(self, key)
		if not checkcaller() and key == "Size" then
			if state.originalSizes[self] then
				return state.originalSizes[self]
			end
		end
		return oldIndex(self, key)
	end)
)

-- [[ UTILITIES ]]
local function Notify(text)
	if setclipboard then
		print("[Prior Extinction]: " .. text)
	end
end

local function getHitboxPart(character)
	local hitbox = character:FindFirstChild("Hitbox") or character:FindFirstChild("HitBox")

	if Config.HitboxExpander.TargetPart == "Head" then
		if hitbox and hitbox:IsA("Model") then
			local head = hitbox:FindFirstChild("Head")
				or hitbox:FindFirstChild("head")
				or hitbox:FindFirstChild("Skull")
			if head then
				return head
			end
		end
	elseif Config.HitboxExpander.TargetPart == "Hip" then
		if hitbox and hitbox:IsA("Model") then
			local hip = hitbox:FindFirstChild("Hip")
			if hip then
				return hip
			end
		end
	elseif Config.HitboxExpander.TargetPart == "Leg" then
		if hitbox and hitbox:IsA("Model") then
			for _, child in ipairs(hitbox:GetChildren()) do
				local name = string.lower(child.Name)
				if string.find(name, "leg") then
					return child
				end
			end
		end
	end

	if hitbox and hitbox:IsA("Model") then
		local body = hitbox:FindFirstChild("Body")
			or hitbox:FindFirstChild("Torso")
			or hitbox:FindFirstChild("HumanoidRootPart")
		if body then
			return body
		end
	end
	return character:FindFirstChild("HumanoidRootPart")
		or character.PrimaryPart
		or character:FindFirstChildWhichIsA("BasePart")
end

-- Returns the best target part AND the closest hitbox part to the weapon origin.
-- mode: "Dynamic" | "Head" | "HumanoidRootPart" | "Hip" | "Leg"
-- Returns: targetPart, closestPart, closestDistance
local function getKillAuraTarget(character, weaponPosition)
	local mode = Config.KillAura.TargetPart or "Dynamic"
	local hitbox = character:FindFirstChild("Hitbox") or character:FindFirstChild("HitBox")

	-- Collect all available hitbox parts for proximity checks
	local hitboxParts = {}
	if hitbox and hitbox:IsA("Model") then
		for _, child in ipairs(hitbox:GetChildren()) do
			if child:IsA("BasePart") then
				table.insert(hitboxParts, child)
			end
		end
	end
	if #hitboxParts == 0 then
		-- Fallback: use getHitboxPart result as only candidate
		local fallback = getHitboxPart(character)
		if fallback then
			table.insert(hitboxParts, fallback)
		end
	end

	-- Find the closest hitbox part to the weapon origin (Solution A + C)
	local closestPart = nil
	local closestDist = math.huge
	if weaponPosition then
		for _, part in ipairs(hitboxParts) do
			local dist = (part.Position - weaponPosition).Magnitude
			if dist < closestDist then
				closestDist = dist
				closestPart = part
			end
		end
	end

	-- Determine the targeted attack part based on mode
	local targetPart = nil

	if mode == "Dynamic" then
		-- Solution A: always attack the part closest to our weapon/mouth
		targetPart = closestPart

	elseif mode == "Head" then
		if hitbox and hitbox:IsA("Model") then
			targetPart = hitbox:FindFirstChild("Head")
				or hitbox:FindFirstChild("head")
				or hitbox:FindFirstChild("Skull")
		end

	elseif mode == "HumanoidRootPart" then
		if hitbox and hitbox:IsA("Model") then
			targetPart = hitbox:FindFirstChild("HumanoidRootPart")
				or hitbox:FindFirstChild("Body")
				or hitbox:FindFirstChild("Torso")
		end

	elseif mode == "Hip" then
		if hitbox and hitbox:IsA("Model") then
			targetPart = hitbox:FindFirstChild("Hip")
		end

	elseif mode == "Leg" then
		if hitbox and hitbox:IsA("Model") then
			for _, child in ipairs(hitbox:GetChildren()) do
				local name = string.lower(child.Name)
				if string.find(name, "leg") and not string.find(name, "hip") and not string.find(name, "pelvis") then
					targetPart = child
					break
				end
			end
		end
	end

	-- Final fallback: use closest part if forced mode part wasn't found
	if not targetPart then
		targetPart = closestPart or getHitboxPart(character)
	end

	return targetPart, closestPart, closestDist
end

local function getWeaponPart(character)
	local hitbox = character:FindFirstChild("Hitbox") or character:FindFirstChild("HitBox")
	if hitbox and hitbox:IsA("Model") then
		local mouth = hitbox:FindFirstChild("Mouth") or hitbox:FindFirstChild("Beak") or hitbox:FindFirstChild("Head")
		if mouth then
			return mouth
		end
	end
	return getHitboxPart(character)
end

local function getDinoData(model)
	local playerName = model.Name
	local dinoName = tostring(model:GetAttribute("Type") or "Unknown")
	local stage = tostring(model:GetAttribute("Stage") or "Unknown")

	local health = model:GetAttribute("Health") or 0
	local maxHealth = model:GetAttribute("MaxHealth") or 100

	return playerName, math.floor(health), math.floor(maxHealth), dinoName, stage
end

local function createEspLabel()
	local text = Drawing.new("Text")
	text.Visible = false
	text.Center = true
	text.Outline = true
	text.Font = 2
	text.Size = Config.ESP.TextSize
	text.Transparency = Config.ESP.Opacity
	return text
end

local function isDinosaur(model)
	return model:IsA("Model")
		and (model:FindFirstChild("PVP") or model:FindFirstChild("CharacterStats") or model:FindFirstChild("Hitbox"))
end

local function getCharactersFolder()
	return Workspace:FindFirstChild("Characters") or Workspace:FindFirstChild("SpawnedAI") or Workspace
end

-- [[ MODS: NO COOLDOWN (Method: Manual Override) ]]
-- Bypasses the PVP.lua script completely and fires manual "Kill Aura" style 
-- hits precisely when the user clicks Mouse1/Mouse2.
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not Config.Mods.NoCooldown then return end

	local attackType, animName
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		attackType = "Primary"
		animName = "Attack1"
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		attackType = "Secondary"
		animName = "Attack2"
	else
		return
	end

	local myCharacter = LocalPlayer.Character
	if not myCharacter then return end

	local myRoot = myCharacter.PrimaryPart or myCharacter:FindFirstChild("HumanoidRootPart")
	local myWeapon = getWeaponPart(myCharacter)
	if not myRoot or not myWeapon then return end

	-- Play animation locally to simulate attack
	pcall(function()
		local CharacterState = require(ReplicatedStorage.Common.CharacterState)
		if CharacterState.Animate and CharacterState.Animate.Animations[animName] then
			CharacterState.Animate:PlayAnimation(animName)
		end
	end)

	pcall(function()
		local myReplica = CharacterController:GetCharacterReplica(myCharacter)
		if not myReplica then return end
		myReplica:FireServer("RegisterAttack", "Attacks/" .. attackType, animName, nil)

		-- Find target in range
		local folder = getCharactersFolder()
		for _, obj in ipairs(folder:GetChildren()) do
			if obj == myCharacter or not isDinosaur(obj) then continue end
			if obj:GetAttribute("SpawnInvincible") or obj:GetAttribute("Attached") == LocalPlayer.Name then continue end

			local targetHead, closestPart = getKillAuraTarget(obj, myWeapon.Position)
			if not targetHead or not closestPart then continue end

			local dist = (myWeapon.Position - closestPart.Position).Magnitude
			if dist <= Config.KillAura.ReachRadius then
				local targetReplica = CharacterController:GetCharacterReplica(obj) or AIRegistrationController:GetReplicaFromModel(obj)
				if targetReplica then
					local multiplier = ComputeLocationalMultiplier(targetReplica, targetHead.Name, targetHead.Position)
					local targetHitbox = MockHitbox(targetHead)
					local myWeaponHitbox = MockHitbox(myWeapon)
					
					task.delay(0.15, function()
						targetReplica:FireServer("Attack", nil, targetHitbox, myWeaponHitbox, multiplier, nil)
					end)
					break -- Only hit one target per click for manual attacks, like normal game
				end
			end
		end
	end)
end)

-- ============================================================================
-- USER INTERFACE INITIALIZATION (WindUI)
-- ============================================================================
local function initGui()
	local success, err = pcall(function()
		return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
	end)
	if not success or not err then
		warn("[Prior Extinction] Failed to load WindUI: " .. tostring(err))
		return
	end
	WindUI = err

	if getgenv().PriorExtinctionHub then
		pcall(function()
			getgenv().PriorExtinctionHub:Destroy()
		end)
	end

	local Window = WindUI:CreateWindow({
		Title = "Void Extinction",
		SubTitle = "skibidi",
		Author = "jadi",
		Folder = "PriorExtinction",
		Size = UDim2.fromOffset(500, 420),
		Transparent = true,
		Theme = "Rose",
	})

	getgenv().PriorExtinctionHub = Window
	pcall(function()
		Window:SetToggleKey(nil)
	end)

	-- [[ COMBAT TAB ]]
	local CombatTab = Window:Tab({ Title = "Combat", Icon = "swords" })
	local killauraSection = CombatTab:Section({ Title = "Kill Aura" })

	killauraSection:Toggle({
		Title = "Enable Kill Aura",
		Desc = "Automatically bites enemies around you.",
		Value = Config.KillAura.Enabled,
		Callback = function(val)
			Config.KillAura.Enabled = val
			state.auraEnabled = val
		end,
	})

	killauraSection:Slider({
		Title = "Reach Radius",
		Desc = "Maximum distance to attack (Studs).",
		Value = { Min = 5, Max = 100, Default = Config.KillAura.ReachRadius },
		Callback = function(val)
			Config.KillAura.ReachRadius = val
		end,
	})

	killauraSection:Slider({
		Title = "Cooldown",
		Desc = "Seconds between attacks.",
		Value = { Min = 0.1, Max = 3.0, Default = Config.KillAura.Cooldown },
		Callback = function(val)
			Config.KillAura.Cooldown = val
		end,
	})

	killauraSection:Dropdown({
		Title = "Target Part",
		Desc = "Which enemy part to bite. Dynamic = closest to your mouth.",
		Values = { "Dynamic", "Head", "HumanoidRootPart", "Hip", "Leg" },
		Value = Config.KillAura.TargetPart,
		Callback = function(val)
			Config.KillAura.TargetPart = val
		end,
	})

	local hitboxSection = CombatTab:Section({ Title = "Hitbox Expander" })

	hitboxSection:Toggle({
		Title = "Enable Expander",
		Desc = "Enlarges enemy hitboxes.",
		Value = Config.HitboxExpander.Enabled,
		Callback = function(val)
			Config.HitboxExpander.Enabled = val
		end,
	})

	hitboxSection:Dropdown({
		Title = "Target Part",
		Desc = "Which body part to expand.",
		Values = { "HumanoidRootPart", "Head", "Hip", "Leg" },
		Value = Config.HitboxExpander.TargetPart,
		Callback = function(val)
			Config.HitboxExpander.TargetPart = val
		end,
	})

	-- [[ MODS TAB ]]
	local ModsTab = Window:Tab({ Title = "Mods", Icon = "zap" })
	local noCooldownSection = ModsTab:Section({ Title = "Attack Mods" })

	noCooldownSection:Toggle({
		Title = "No Attack Cooldown",
		Desc = "Zeroes the client-side attack cooldown multiplier. Spam Mouse1/Mouse2 freely.",
		Value = Config.Mods.NoCooldown,
		Callback = function(val)
			Config.Mods.NoCooldown = val
		end,
	})

	-- [[ VISUALS TAB ]]
	local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
	local espSection = VisualsTab:Section({ Title = "ESP Settings" })

	espSection:Toggle({
		Title = "Enable ESP",
		Desc = "Draws player info on screen.",
		Value = Config.ESP.Enabled,
		Callback = function(val)
			Config.ESP.Enabled = val
			state.espEnabled = val
			if not val then
				for _, esp in pairs(state.espCache) do
					if esp.Text then
						esp.Text.Visible = false
					end
				end
			end
		end,
	})

	-- [[ SETTINGS TAB ]]
	local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })
	local uiSection = SettingsTab:Section({ Title = "UI Settings" })

	uiSection:Dropdown({
		Title = "Active Theme",
		Desc = "Selects the window theme palette",
		Values = { "Midnight", "Dark", "Light", "Rose", "Plant", "Indigo", "Sky", "Violet", "Amber", "Emerald" },
		Value = "Rose",
		Callback = function(themeName)
			pcall(function()
				WindUI:SetTheme(themeName)
			end)
		end,
	})

	uiSection:Keybind({
		Title = "Menu Keybind",
		Desc = "Press to minimize or restore the UI panel",
		Value = Config.MenuKeybind.Name,
		Callback = function(newKey)
			local cleanKey = typeof(newKey) == "EnumItem" and newKey
				or Enum.KeyCode[newKey:gsub("^Enum%.KeyCode%.", "")]
			Config.MenuKeybind = cleanKey
		end,
	})

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Config.MenuKeybind then
			if getgenv().PriorExtinctionHub then
				pcall(function()
					getgenv().PriorExtinctionHub:Toggle()
				end)
			end
		end
	end)
end

task.spawn(initGui)

-- [[ MAIN LOOP ]]
RunService.RenderStepped:Connect(function()
	local myCharacter = LocalPlayer.Character
	if not myCharacter then
		return
	end

	local myRoot = myCharacter.PrimaryPart or myCharacter:FindFirstChild("HumanoidRootPart")
	local myWeapon = getWeaponPart(myCharacter)

	local folder = getCharactersFolder()
	local activeDinosaurs = {}
	local activeHitboxes = {}

	for _, obj in ipairs(folder:GetChildren()) do
		if obj == myCharacter or not isDinosaur(obj) then
			continue
		end

		activeDinosaurs[obj] = true

		local targetBody = getHitboxPart(obj)
		if not targetBody then
			continue
		end

		-- Resolve kill aura target using weapon position for dynamic closest-part selection
		local weaponPos = myWeapon and myWeapon.Position or (myRoot and myRoot.Position)
		local targetHead, closestPart, closestDist = getKillAuraTarget(obj, weaponPos)
		if not targetHead then
			continue
		end

		-- [[ HITBOX EXPANDER ]]
		if Config.HitboxExpander.Enabled then
			activeHitboxes[targetBody] = true
			
			if not state.originalSizes[targetBody] then
				state.originalSizes[targetBody] = targetBody.Size
				pcall(function()
					for _, conn in ipairs(getconnections(targetBody:GetPropertyChangedSignal("Size"))) do
						conn:Disable()
					end
				end)
			end
			
			if targetBody.Size ~= Config.HitboxExpander.Size then
				targetBody.Size = Config.HitboxExpander.Size
				targetBody.Transparency = Config.HitboxExpander.Transparency
				targetBody.CanCollide = false
			end
		end

		-- [[ ESP ]]
		if state.espEnabled then
			if not state.espCache[obj] then
				state.espCache[obj] = { Text = createEspLabel() }
			end

			local espWorldPosition = targetHead.Position + Vector3.new(0, 5, 0)
			local vector, onScreen = Camera:WorldToViewportPoint(espWorldPosition)
			local espText = state.espCache[obj].Text

			if onScreen then
				local distance = myRoot and (targetHead.Position - myRoot.Position).Magnitude or 0
				local playerName, health, maxHealth, dinoType, stage = getDinoData(obj)

				espText.Text = string.format(
					"%s\n%s / %s\n%s\n%s\n%d m",
					tostring(playerName),
					tostring(health),
					tostring(maxHealth),
					tostring(dinoType),
					tostring(stage),
					math.floor(distance)
				)

				if distance >= 700 then
					espText.Color = Config.ESP.ColorFar
				elseif distance <= 200 then
					espText.Color = Config.ESP.ColorNear
				else
					espText.Color = Config.ESP.ColorMid
				end

				espText.Size = Config.ESP.TextSize
				espText.Transparency = Config.ESP.Opacity
				espText.Position = Vector2.new(vector.X, vector.Y)
				espText.Visible = true
			else
				espText.Visible = false
			end
		end

		-- [[ KILL AURA ]]
		if
			state.auraEnabled
			and tick() - state.lastAttackTime >= Config.KillAura.Cooldown
			and myRoot
			and myWeapon
			and targetHead
		then
			if not obj:GetAttribute("SpawnInvincible") and obj:GetAttribute("Attached") ~= LocalPlayer.Name then
				-- Solution C: Use the closest hitbox part distance for the trigger check,
				-- NOT the center body. This allows hitting large dinos whose leg is nearby
				-- even if their body center is outside the radius.
				local triggerDist = closestPart
					and (myWeapon.Position - closestPart.Position).Magnitude
					or (myRoot.Position - targetBody.Position).Magnitude

				if triggerDist <= Config.KillAura.ReachRadius then
					local targetReplica = CharacterController:GetCharacterReplica(obj)
						or AIRegistrationController:GetReplicaFromModel(obj)
					if targetReplica then
						state.lastAttackTime = tick()

						local myReplica = CharacterController:GetCharacterReplica(myCharacter)
						if myReplica then
							myReplica:FireServer("RegisterAttack", "Attacks/Primary", "Attack1", nil)
						end

						-- Solution A+B: Target the dynamically-resolved closest/forced part.
						-- This guarantees the server's distance check passes (mouth -> targetHead
						-- will always be within reach since we selected the nearest valid part).
						local multiplier =
							ComputeLocationalMultiplier(targetReplica, targetHead.Name, targetHead.Position)
						local targetHitbox = MockHitbox(targetHead)
						local myWeaponHitbox = MockHitbox(myWeapon)

						-- Note: The 0.15s reaction time delay is now handled globally
						-- by the Replica.FireServer hook in the Mods section.
						targetReplica:FireServer("Attack", nil, targetHitbox, myWeaponHitbox, multiplier, nil)
					end
				end
			end
		end
	end

	for obj, esp in pairs(state.espCache) do
		if not activeDinosaurs[obj] then
			if esp.Text then
				esp.Text:Remove()
			end
			state.espCache[obj] = nil
		end
	end

	for part, originalSize in pairs(state.originalSizes) do
		if not activeHitboxes[part] then
			if part.Parent then
				part.Size = originalSize
				part.Transparency = 1
				part.CanCollide = true
			end
			state.originalSizes[part] = nil
		end
	end
end)

print("[+] Void Script Loaded!")
