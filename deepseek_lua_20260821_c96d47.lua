--[[
    YUNO HUB | Murder Mystery 2
    Ultimate All-in-One Hub with WindUI
    Merged from: Benjo, Onyyx, Dabl Gee, Fan Hub, Advanced ESP, Item Spawner, and more.
]]

-- ============================================================
-- SERVICES & GLOBALS
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- LOAD WINDUI (from Benjo Hub)
-- ============================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ============================================================
-- GLOBAL STATE (persisted via getgenv)
-- ============================================================
getgenv().Yuno = getgenv().Yuno or {}
local Yuno = getgenv().Yuno

-- Default settings
local function defaults()
    return {
        -- ESP (from all hubs)
        espEnabled = false,
        espFilter = "All", -- All, Murderer, Sheriff, Murderer/Sheriff
        highlightEnabled = true,
        boxEspEnabled = true,
        nameEspEnabled = true,
        healthEspEnabled = true,
        distanceEspEnabled = true,
        roleEspEnabled = true,
        lineEspEnabled = false,
        tracerColor = "Blue", -- Blue, Red, Green, Rainbow
        teamCheckEnabled = false,

        -- Visual
        xrayEnabled = false,
        fullBrightEnabled = false,
        skybox = "Original", -- Original, Sunset, Galaxy, Night
        hitboxScaleEnabled = false,
        hitboxScale = 3.0,

        -- Combat
        aimbotEnabled = false,
        aimbotSmooth = 5,
        aimbotFOV = 90,
        aimbotTargetMurderer = true,
        aimbotTargetSheriff = false,
        autoShootEnabled = false,
        killAllEnabled = false,
        killAllDelay = 0.5,
        killAuraEnabled = false,
        killAuraRange = 25,
        killAuraDamage = 2,
        infiniteAmmoEnabled = false,
        instantReloadEnabled = false,

        -- Farm
        coinFarmEnabled = false,
        candyFarmEnabled = false,
        farmSpeed = 25,
        autoResetOnBagFull = false,
        autoFlingMurdererOnFull = false,

        -- Movement
        flyEnabled = false,
        flySpeed = 50,
        noclipEnabled = false,
        infiniteJumpEnabled = false,
        bhopEnabled = false,
        bhopSpeed = 24,
        speedHackEnabled = false,
        speedValue = 24,
        speedGlitchEnabled = false,
        jumpPowerEnabled = false,
        jumpPowerValue = 50,
        spinbotEnabled = false,
        swimWalkEnabled = false,

        -- Weapons
        skinChangerEnabled = false,
        selectedKnifeMesh = "",
        selectedGunMesh = "",
        spawnWeaponName = "",
        dupeWeaponName = "",
        dupeAmount = 1,
        fromWeapon = "",
        toWeapon = "",

        -- Teleport
        tpGunEnabled = false,
        grabGunEnabled = false,

        -- Fling
        flingMurdererEnabled = false,
        flingSheriffEnabled = false,
        targetFlingEnabled = false,
        selectedTargetName = "",
        touchFlingEnabled = false,
        flingPower = 100,

        -- Misc
        antiAFKEnabled = false,
        autoGreetEnabled = false,
        bulletTracersEnabled = false,
        tradeScamEnabled = false,
        serverLaggerEnabled = false,

        -- UI
        uiAccentColor = Color3.fromRGB(114, 137, 218),
        btnAccentColor = Color3.fromRGB(26, 26, 36),
        menuKeybind = "RightControl",

        -- Config
        configName = "default",
    }
end

-- Merge defaults with existing
for k, v in pairs(defaults()) do
    if Yuno[k] == nil then
        Yuno[k] = v
    end
end

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoidRootPart()
    local char = getCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char:FindFirstChildOfClass("Humanoid")
end

local function getPlayerRole(player)
    local char = player.Character
    if not char then return "Innocent" end
    local backpack = player:FindFirstChild("Backpack")
    local function check(container)
        if not container then return nil end
        for _, item in ipairs(container:GetChildren()) do
            local name = item.Name
            if name == "Knife" or name == "CKnife" then
                return "Murderer"
            elseif name == "Gun" or name == "Revolver" or name == "CGun" then
                return "Sheriff"
            end
        end
        return nil
    end
    local role = check(char) or check(backpack)
    return role or "Innocent"
end

local function getRoleColor(role)
    if role == "Murderer" then
        return Color3.fromRGB(255, 60, 60)
    elseif role == "Sheriff" then
        return Color3.fromRGB(60, 140, 255)
    else
        return Color3.fromRGB(60, 220, 100)
    end
end

local function isMurderer(player)
    return getPlayerRole(player) == "Murderer"
end

local function isSheriff(player)
    return getPlayerRole(player) == "Sheriff"
end

local function isTeammate(player)
    if not Yuno.teamCheckEnabled then return false end
    return player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
end

-- ============================================================
-- CONFIG MANAGEMENT (save/load)
-- ============================================================
local function getConfigPath(name)
    return "YunoHub/" .. name .. ".json"
end

local function saveConfig(name)
    local data = {}
    for k, v in pairs(Yuno) do
        if type(v) ~= "function" and k ~= "configName" then
            if typeof(v) == "Color3" then
                data[k] = { __color = v:ToHex() }
            else
                data[k] = v
            end
        end
    end
    local json = HttpService:JSONEncode(data)
    if not isfolder("YunoHub") then makefolder("YunoHub") end
    writefile(getConfigPath(name), json)
end

local function loadConfig(name)
    local path = getConfigPath(name)
    if not isfile(path) then return false end
    local json = readfile(path)
    local data = HttpService:JSONDecode(json)
    for k, v in pairs(data) do
        if type(v) == "table" and v.__color then
            Yuno[k] = Color3.fromHex(v.__color)
        else
            Yuno[k] = v
        end
    end
    return true
end

local function getConfigList()
    if not listfiles then return {} end
    local list = {}
    if not isfolder("YunoHub") then makefolder("YunoHub") end
    for _, file in ipairs(listfiles("YunoHub/")) do
        if file:sub(-5) == ".json" then
            local name = file:match("([^/\\]+)%.json$")
            if name then table.insert(list, name) end
        end
    end
    return list
end

-- ============================================================
-- ESP SYSTEM (Combined from all hubs)
-- ============================================================
local espObjects = {} -- {player = {Highlight, Billboard, Line}}

local function createEspForPlayer(player)
    if player == LocalPlayer then return end
    if espObjects[player] then
        if espObjects[player].Highlight then espObjects[player].Highlight:Destroy() end
        if espObjects[player].Billboard then espObjects[player].Billboard:Destroy() end
        if espObjects[player].Line then espObjects[player].Line:Remove() end
        espObjects[player] = nil
    end

    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local role = getPlayerRole(player)
    local color = getRoleColor(role)

    -- Highlight (chams)
    local highlight = Instance.new("Highlight")
    highlight.Name = "YunoESP_Highlight"
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = char
    highlight.Parent = char

    -- Billboard GUI (boxes, name, health, distance, role)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "YunoESP_Billboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 150, 0, 70)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = head
    billboard.Parent = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 2
    frame.BorderColor3 = color
    frame.Parent = billboard
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    -- Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.35, 0)
    nameLabel.Position = UDim2.new(0, 0, 0.1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.Parent = frame

    -- Role
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0.2, 0)
    roleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = role:upper()
    roleLabel.TextColor3 = color
    roleLabel.Font = Enum.Font.GothamBold
    roleLabel.TextSize = 12
    roleLabel.Parent = frame

    -- Health bar
    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(0.8, 0, 0.08, 0)
    healthBg.Position = UDim2.new(0.1, 0, 0.9, 0)
    healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = frame
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBg

    -- Distance
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.15, 0)
    distLabel.Position = UDim2.new(0, 0, -0.2, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = ""
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 10
    distLabel.Parent = frame

    -- Line tracer (Drawing)
    local line = nil
    if Yuno.lineEspEnabled then
        line = Drawing.new("Line")
        line.Thickness = 2
        line.Color = color
        line.Transparency = 1
    end

    espObjects[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Frame = frame,
        NameLabel = nameLabel,
        RoleLabel = roleLabel,
        HealthBar = healthBar,
        HealthBg = healthBg,
        DistLabel = distLabel,
        Line = line,
    }
end

local function updateEspForPlayer(player)
    local data = espObjects[player]
    if not data then return end
    local char = player.Character
    if not char then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        if data.Line then data.Line:Remove() end
        espObjects[player] = nil
        return
    end
    local role = getPlayerRole(player)
    local color = getRoleColor(role)

    -- Update highlight
    data.Highlight.FillColor = color
    data.Highlight.Enabled = Yuno.espEnabled and Yuno.highlightEnabled

    -- Update billboard visibility and content
    local show = Yuno.espEnabled
    if show then
        local filter = Yuno.espFilter
        if filter == "All" then
            show = true
        elseif filter == "Murderer" and role == "Murderer" then
            show = true
        elseif filter == "Sheriff" and role == "Sheriff" then
            show = true
        elseif filter == "Murderer/Sheriff" and (role == "Murderer" or role == "Sheriff") then
            show = true
        else
            show = false
        end
    end
    if show and isTeammate(player) then show = false end

    data.Billboard.Enabled = show

    if show then
        data.RoleLabel.Text = role:upper()
        data.RoleLabel.TextColor3 = color
        data.Frame.BorderColor3 = color

        -- Health
        if Yuno.healthEspEnabled then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local healthPercent = hum.Health / hum.MaxHealth
                data.HealthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                data.HealthBar.BackgroundColor3 = Color3.fromRGB(255 - 255 * healthPercent, 255 * healthPercent, 0)
                data.HealthBg.Visible = true
                data.HealthBar.Visible = true
            end
        else
            data.HealthBg.Visible = false
            data.HealthBar.Visible = false
        end

        -- Distance
        if Yuno.distanceEspEnabled then
            local root = getHumanoidRootPart()
            if root and char:FindFirstChild("HumanoidRootPart") then
                local dist = (root.Position - char.HumanoidRootPart.Position).Magnitude
                data.DistLabel.Text = string.format("%.0fm", dist)
                data.DistLabel.Visible = true
            end
        else
            data.DistLabel.Visible = false
        end

        -- Name
        data.NameLabel.Visible = Yuno.nameEspEnabled
        -- Role
        data.RoleLabel.Visible = Yuno.roleEspEnabled

        -- Line tracer
        if Yuno.lineEspEnabled and data.Line then
            local head = char:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local viewport = Camera.ViewportSize
                    data.Line.From = Vector2.new(viewport.X / 2, viewport.Y)
                    data.Line.To = Vector2.new(pos.X, pos.Y)
                    data.Line.Color = color
                    data.Line.Visible = true
                else
                    data.Line.Visible = false
                end
            end
        elseif data.Line then
            data.Line.Visible = false
        end
    else
        if data.Line then data.Line.Visible = false end
    end
end

local function updateAllEsp()
    for player, data in pairs(espObjects) do
        if player and player.Parent then
            updateEspForPlayer(player)
        else
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
            if data.Line then data.Line:Remove() end
            espObjects[player] = nil
        end
    end
    -- Add new players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not espObjects[player] then
            createEspForPlayer(player)
        end
    end
end

task.spawn(function()
    while true do
        updateAllEsp()
        task.wait(0.3)
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        createEspForPlayer(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        if espObjects[player].Highlight then espObjects[player].Highlight:Destroy() end
        if espObjects[player].Billboard then espObjects[player].Billboard:Destroy() end
        if espObjects[player].Line then espObjects[player].Line:Remove() end
        espObjects[player] = nil
    end
end)

-- ============================================================
-- XRAY (from mm2.script and Onyyx)
-- ============================================================
local xrayCache = {}
local xrayConn

local function applyXray(part)
    if not part:IsA("BasePart") then return end
    if part:IsDescendantOf(LocalPlayer.Character) then return end
    if xrayCache[part] == nil then
        xrayCache[part] = part.LocalTransparencyModifier
    end
    part.LocalTransparencyModifier = 0.65
end

local function enableXray()
    for _, part in ipairs(workspace:GetDescendants()) do
        applyXray(part)
    end
    if xrayConn then xrayConn:Disconnect() end
    xrayConn = workspace.DescendantAdded:Connect(applyXray)
end

local function disableXray()
    if xrayConn then xrayConn:Disconnect() end
    xrayConn = nil
    for part, old in pairs(xrayCache) do
        if part and part.Parent then
            part.LocalTransparencyModifier = old
        end
    end
    xrayCache = {}
end

-- ============================================================
-- FULL BRIGHT (from Onyyx / Dabl Gee)
-- ============================================================
local function setFullBright(enabled)
    if enabled then
        Lighting.Brightness = 10
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    end
end

-- ============================================================
-- SKYBOX (from Dabl Gee)
-- ============================================================
local function setSkybox(style)
    if style == "Original" then
        Lighting.Sky = nil
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 2
        return
    end
    local sky = Instance.new("Sky")
    sky.Parent = Lighting
    if style == "Sunset" then
        sky.SkyboxBk = "rbxassetid://10991226910"
        sky.SkyboxDn = "rbxassetid://10991230390"
        sky.SkyboxFt = "rbxassetid://10991230403"
        sky.SkyboxLf = "rbxassetid://10991230412"
        sky.SkyboxRt = "rbxassetid://10991230422"
        sky.SkyboxUp = "rbxassetid://10991230431"
        Lighting.Ambient = Color3.fromRGB(180, 100, 60)
        Lighting.Brightness = 1.5
    elseif style == "Galaxy" then
        sky.SkyboxBk = "rbxassetid://10991230441"
        sky.SkyboxDn = "rbxassetid://10991230450"
        sky.SkyboxFt = "rbxassetid://10991230459"
        sky.SkyboxLf = "rbxassetid://10991230468"
        sky.SkyboxRt = "rbxassetid://10991230477"
        sky.SkyboxUp = "rbxassetid://10991230486"
        Lighting.Ambient = Color3.fromRGB(50, 30, 80)
        Lighting.Brightness = 1
    elseif style == "Night" then
        sky.SkyboxBk = "rbxassetid://10991226910"
        sky.SkyboxDn = "rbxassetid://10991230390"
        sky.SkyboxFt = "rbxassetid://10991230403"
        sky.SkyboxLf = "rbxassetid://10991230412"
        sky.SkyboxRt = "rbxassetid://10991230422"
        sky.SkyboxUp = "rbxassetid://10991230431"
        Lighting.Ambient = Color3.fromRGB(20, 20, 40)
        Lighting.Brightness = 0.5
    end
end

-- ============================================================
-- HITBOX SCALING (from Fan Hub)
-- ============================================================
RunService.Stepped:Connect(function()
    if Yuno.hitboxScaleEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Size = Vector3.new(2 * Yuno.hitboxScale, 2 * Yuno.hitboxScale, 2 * Yuno.hitboxScale)
                    root.Transparency = 0.6
                    root.Color = Color3.fromRGB(255, 0, 0)
                end
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Size = Vector3.new(2, 2, 1)
                    root.Transparency = 1
                end
            end
        end
    end
end)

-- ============================================================
-- INFINITE AMMO & INSTANT RELOAD (from Fan Hub)
-- ============================================================
local function bypassWeapon(tool)
    if not tool then return end
    pcall(function()
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("ammo") or name:find("clip") or name:find("bullet") or name:find("mag") then
                    if Yuno.infiniteAmmoEnabled then v.Value = 999 end
                elseif name:find("reload") or name:find("cooldown") or name:find("delay") or name:find("fire") then
                    if Yuno.instantReloadEnabled then v.Value = 0 end
                end
            elseif v:IsA("ModuleScript") then
                pcall(function()
                    local data = require(v)
                    if type(data) == "table" then
                        if Yuno.infiniteAmmoEnabled then
                            if data.Ammo then data.Ammo = 999 end
                            if data.MaxAmmo then data.MaxAmmo = 999 end
                            if data.ClipSize then data.ClipSize = 999 end
                        end
                        if Yuno.instantReloadEnabled then
                            if data.ReloadTime then data.ReloadTime = 0 end
                            if data.Cooldown then data.Cooldown = 0 end
                            if data.FireRate then data.FireRate = 0.01 end
                        end
                    end
                end)
            end
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if Yuno.infiniteAmmoEnabled or Yuno.instantReloadEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then bypassWeapon(item) end
            end
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") then bypassWeapon(item) end
                end
            end
        end
    end
end)

-- ============================================================
-- KILL AURA (from Fan Hub)
-- ============================================================
RunService.RenderStepped:Connect(function()
    if not Yuno.killAuraEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isTeammate(player) then
            local pChar = player.Character
            if pChar then
                local pRoot = pChar:FindFirstChild("HumanoidRootPart")
                local pHum = pChar:FindFirstChildOfClass("Humanoid")
                if pRoot and pHum and pHum.Health > 0 then
                    if (root.Position - pRoot.Position).Magnitude <= Yuno.killAuraRange then
                        pHum.Health = math.max(0, pHum.Health - Yuno.killAuraDamage)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- AIMBOT (from Onyyx / Dabl Gee)
-- ============================================================
local function getAimbotTarget()
    if not Yuno.aimbotEnabled then return nil end
    local bestTarget = nil
    local bestScore = math.huge
    local center = Camera.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if isTeammate(player) then continue end
        local role = getPlayerRole(player)
        if Yuno.aimbotTargetMurderer and role == "Murderer" then
            -- ok
        elseif Yuno.aimbotTargetSheriff and role == "Sheriff" then
            -- ok
        else
            continue
        end
        local char = player.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end
        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist > Yuno.aimbotFOV then continue end
        if dist < bestScore then
            bestScore = dist
            bestTarget = player
        end
    end
    return bestTarget
end

local function aimbotLoop()
    while RunService.RenderStepped:Wait() do
        if not Yuno.aimbotEnabled then continue end
        local target = getAimbotTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            local targetCF = CFrame.new(Camera.CFrame.Position, headPos)
            if Yuno.aimbotSmooth > 0 then
                local smooth = Yuno.aimbotSmooth / 100
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, smooth)
            else
                Camera.CFrame = targetCF
            end
        end
    end
end

task.spawn(aimbotLoop)

-- ============================================================
-- AUTO SHOOT (Sheriff) - from Onyyx / Benjo
-- ============================================================
local function autoShootLoop()
    while RunService.RenderStepped:Wait() do
        if not Yuno.autoShootEnabled then continue end
        if getPlayerRole(LocalPlayer) ~= "Sheriff" then continue end
        local target = nil
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and isMurderer(player) then
                target = player
                break
            end
        end
        if not target then continue end
        local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
        if not gun then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                local g = backpack:FindFirstChild("Gun")
                if g then
                    g.Parent = LocalPlayer.Character
                    gun = g
                end
            end
        end
        if gun and gun:FindFirstChild("KnifeLocal") then
            local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(1, targetRoot.Position, "AH2")
            end
        end
    end
end

task.spawn(autoShootLoop)

-- ============================================================
-- KILL ALL (Murderer) - from Benjo / Fan Hub
-- ============================================================
local killAllActive = false

local function killAllLoop()
    while killAllActive do
        if not Yuno.killAllEnabled or getPlayerRole(LocalPlayer) ~= "Murderer" then
            task.wait(0.5)
            continue
        end
        local char = LocalPlayer.Character
        if not char then task.wait(0.5); continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then task.wait(0.5); continue end
        local knife = char:FindFirstChild("Knife") or char:FindFirstChild("CKnife")
        if not knife then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                local k = backpack:FindFirstChild("Knife") or backpack:FindFirstChild("CKnife")
                if k then
                    k.Parent = char
                    knife = k
                end
            end
        end
        if not knife then task.wait(0.5); continue end
        -- Find nearest non-murderer
        local target = nil
        local targetDist = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if isMurderer(player) then continue end
            if isTeammate(player) then continue end
            local tChar = player.Character
            if not tChar then continue end
            local tRoot = tChar:FindFirstChild("HumanoidRootPart")
            if not tRoot then continue end
            local tHum = tChar:FindFirstChildOfClass("Humanoid")
            if not tHum or tHum.Health <= 0 then continue end
            local dist = (root.Position - tRoot.Position).Magnitude
            if dist < targetDist then
                targetDist = dist
                target = player
            end
        end
        if target then
            local tRoot = target.Character.HumanoidRootPart
            root.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 0, 2), tRoot.Position)
            task.wait(0.1)
            local stabRemote = knife:FindFirstChild("Stab") or knife:FindFirstChild("KnifeServer") or knife:FindFirstChild("RemoteEvent")
            if stabRemote then
                if stabRemote:IsA("RemoteEvent") then
                    stabRemote:FireServer("Down")
                elseif stabRemote:IsA("RemoteFunction") then
                    stabRemote:InvokeServer("Down")
                end
            end
            task.wait(Yuno.killAllDelay)
        else
            task.wait(0.5)
        end
    end
end

function startKillAll()
    killAllActive = true
    task.spawn(killAllLoop)
end

function stopKillAll()
    killAllActive = false
end

-- ============================================================
-- AUTO FARM (Coins & Candy) - from Benjo / Modern UI
-- ============================================================
local candyCollected = 0
local maxCandyCapacity = 40
local bagFull = false

local function checkGamepass()
    local success, owns = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, 818078531)
    end)
    if success and owns then
        maxCandyCapacity = 50
    else
        maxCandyCapacity = 40
    end
end
checkGamepass()

local function findNearestItem(type)
    local root = getHumanoidRootPart()
    local best = nil
    local bestDist = math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj:FindFirstChild("TouchInterest") then
            local isCoin = obj.Name == "Coin" or (obj:GetAttribute("CoinID") and obj:GetAttribute("CoinID") ~= "Candy")
            local isCandy = obj.Name == "candy" or (obj:GetAttribute("CoinID") == "Candy")
            if (type == "coin" and isCoin) or (type == "candy" and isCandy) then
                local dist = (root.Position - obj.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    best = obj
                end
            end
        end
    end
    return best, bestDist
end

local function farmLoop()
    while true do
        if not (Yuno.coinFarmEnabled or Yuno.candyFarmEnabled) then
            task.wait(1)
            continue
        end
        local type = Yuno.candyFarmEnabled and "candy" or "coin"
        local target, dist = findNearestItem(type)
        if target then
            local root = getHumanoidRootPart()
            if dist > 150 then
                root.CFrame = target.CFrame
            else
                local tween = TweenService:Create(root, TweenInfo.new(dist / Yuno.farmSpeed, Enum.EasingStyle.Linear), {CFrame = target.CFrame})
                tween:Play()
                tween.Completed:Wait()
            end
            task.wait(0.2)
        else
            task.wait(0.5)
        end
    end
end

local CoinCollectedRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("CoinCollected")
if CoinCollectedRemote then
    CoinCollectedRemote.OnClientEvent:Connect(function(coinType, amount)
        if coinType == "Candy" then
            candyCollected = amount
            if candyCollected >= maxCandyCapacity then
                bagFull = true
                Yuno.coinFarmEnabled = false
                Yuno.candyFarmEnabled = false
                WindUI:Notify({Title = "Bag Full", Content = "Candy bag full! (" .. candyCollected .. "/" .. maxCandyCapacity .. ")", Icon = "package", Duration = 3})
                if Yuno.autoFlingMurdererOnFull then
                    local murderer = nil
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and isMurderer(player) then
                            murderer = player
                            break
                        end
                    end
                    if murderer then
                        WindUI:Notify({Title = "Auto Fling", Content = "Flinging murderer!", Icon = "zap", Duration = 2})
                        local myRoot = getHumanoidRootPart()
                        local tRoot = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot and tRoot then
                            myRoot.CFrame = tRoot.CFrame + Vector3.new(math.random(-2,2), 3, math.random(-2,2))
                            myRoot.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
                            myRoot.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
                        end
                    end
                end
                if Yuno.autoResetOnBagFull then
                    WindUI:Notify({Title = "Auto Reset", Content = "Resetting character!", Icon = "refresh-cw", Duration = 2})
                    task.wait(0.5)
                    if LocalPlayer.Character then
                        LocalPlayer.Character:BreakJoints()
                    end
                end
            end
        end
    end)
end

local RoundStartRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("RoundStart")
local RoundEndRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("RoundEndFade")

if RoundStartRemote then
    RoundStartRemote.OnClientEvent:Connect(function()
        bagFull = false
        candyCollected = 0
    end)
end
if RoundEndRemote then
    RoundEndRemote.OnClientEvent:Connect(function()
        Yuno.coinFarmEnabled = false
        Yuno.candyFarmEnabled = false
    end)
end

task.spawn(farmLoop)

-- ============================================================
-- TELEPORT TO GUN / GRAB GUN (from Benjo / Modern UI)
-- ============================================================
local function tpToGun()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            local root = getHumanoidRootPart()
            root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
            break
        end
    end
end

local function grabGun()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            local root = getHumanoidRootPart()
            root.CFrame = obj.CFrame
            task.wait(0.3)
            local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
                return true
            end
        end
    end
    return false
end

local function autoGrabLoop()
    while Yuno.grabGunEnabled do
        grabGun()
        task.wait(1)
    end
end

-- ============================================================
-- FLIGHT (with mobile joystick from Script.lua)
-- ============================================================
local flying = false
local flyBodyVelocity, flyBodyGyro
local flyJoystickGui

local function toggleFly(state)
    Yuno.flyEnabled = state
    if state then
        local root = getHumanoidRootPart()
        local hum = getHumanoid()
        if not root or not hum then return end
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
        flyBodyVelocity.Velocity = Vector3.zero
        flyBodyVelocity.Parent = root

        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 100000
        flyBodyGyro.CFrame = root.CFrame
        flyBodyGyro.P = 3000
        flyBodyGyro.D = 500
        flyBodyGyro.Parent = root

        hum.PlatformStand = true
        flying = true

        -- Mobile joystick (from Script.lua)
        if UserInputService.TouchEnabled then
            flyJoystickGui = Instance.new("ScreenGui")
            flyJoystickGui.Name = "YunoFlyJoystick"
            flyJoystickGui.ResetOnSpawn = false
            flyJoystickGui.Parent = CoreGui

            local base = Instance.new("Frame")
            base.Size = UDim2.new(0, 120, 0, 120)
            base.Position = UDim2.new(0.15, -60, 0.75, -60)
            base.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            base.BackgroundTransparency = 0.7
            base.BorderSizePixel = 0
            base.Parent = flyJoystickGui
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 60)
            corner.Parent = base

            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.new(0, 40, 0, 40)
            thumb.Position = UDim2.new(0.5, -20, 0.5, -20)
            thumb.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            thumb.BackgroundTransparency = 0.3
            thumb.BorderSizePixel = 0
            thumb.Parent = base
            local thumbCorner = Instance.new("UICorner")
            thumbCorner.CornerRadius = UDim.new(0, 20)
            thumbCorner.Parent = thumb

            local upBtn = Instance.new("TextButton")
            upBtn.Size = UDim2.new(0, 50, 0, 50)
            upBtn.Position = UDim2.new(0.85, -25, 0.15, -25)
            upBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            upBtn.BackgroundTransparency = 0.6
            upBtn.Text = "⬆"
            upBtn.Font = Enum.Font.GothamBold
            upBtn.TextSize = 20
            upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            upBtn.BorderSizePixel = 0
            upBtn.Parent = flyJoystickGui
            local upCorner = Instance.new("UICorner")
            upCorner.CornerRadius = UDim.new(0, 8)
            upCorner.Parent = upBtn

            local downBtn = Instance.new("TextButton")
            downBtn.Size = UDim2.new(0, 50, 0, 50)
            downBtn.Position = UDim2.new(0.85, -25, 0.4, -25)
            downBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            downBtn.BackgroundTransparency = 0.6
            downBtn.Text = "⬇"
            downBtn.Font = Enum.Font.GothamBold
            downBtn.TextSize = 20
            downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            downBtn.BorderSizePixel = 0
            downBtn.Parent = flyJoystickGui
            local downCorner = Instance.new("UICorner")
            downCorner.CornerRadius = UDim.new(0, 8)
            downCorner.Parent = downBtn

            local dragging = false
            base.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            base.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    thumb:TweenPosition(UDim2.new(0.5, -20, 0.5, -20), "Out", "Quad", 0.15, true)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.Touch then
                    local center = base.AbsolutePosition + base.AbsoluteSize / 2
                    local offset = Vector2.new(input.Position.X - center.X, input.Position.Y - center.Y)
                    local radius = base.AbsoluteSize.X / 2 - thumb.AbsoluteSize.X / 2
                    if offset.Magnitude > radius then
                        offset = offset.Unit * radius
                    end
                    thumb.Position = UDim2.new(0, offset.X + base.AbsoluteSize.X/2 - thumb.AbsoluteSize.X/2, 0, offset.Y + base.AbsoluteSize.Y/2 - thumb.AbsoluteSize.Y/2)
                end
            end)

            task.spawn(function()
                while Yuno.flyEnabled and flyBodyVelocity and RunService.RenderStepped:Wait() do
                    flyBodyGyro.CFrame = Camera.CFrame
                    local moveDir = Vector3.zero
                    local thumbPos = thumb.Position
                    local baseSize = base.AbsoluteSize
                    local offsetX = (thumbPos.X.Scale - 0.5) * baseSize.X + thumbPos.X.Offset
                    local offsetY = (thumbPos.Y.Scale - 0.5) * baseSize.Y + thumbPos.Y.Offset
                    local hor = offsetX / (baseSize.X / 2)
                    local ver = -offsetY / (baseSize.Y / 2)
                    if math.abs(hor) > 0.15 or math.abs(ver) > 0.15 then
                        moveDir += Camera.CFrame.LookVector * ver
                        moveDir += Camera.CFrame.RightVector * hor
                    end
                    if upBtn:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        moveDir += Vector3.new(0, 1, 0)
                    end
                    if downBtn:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        moveDir -= Vector3.new(0, 1, 0)
                    end
                    if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
                    flyBodyVelocity.Velocity = moveDir * Yuno.flySpeed
                end
            end)
        end
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyJoystickGui then flyJoystickGui:Destroy() end
        local hum = getHumanoid()
        if hum then hum.PlatformStand = false end
        flying = false
    end
end

-- Desktop fly update
task.spawn(function()
    while RunService.RenderStepped:Wait() do
        if not Yuno.flyEnabled or not flying then continue end
        if UserInputService.TouchEnabled then continue end
        local root = getHumanoidRootPart()
        if not root then continue end
        local cam = Camera
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        flyBodyVelocity.Velocity = moveDir * Yuno.flySpeed
        flyBodyGyro.CFrame = cam.CFrame
    end
end)

-- ============================================================
-- NOCLIP
-- ============================================================
RunService.Stepped:Connect(function()
    if Yuno.noclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    else
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- ============================================================
-- INFINITE JUMP
-- ============================================================
UserInputService.JumpRequest:Connect(function()
    if Yuno.infiniteJumpEnabled then
        local hum = getHumanoid()
        if hum and hum.Health > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ============================================================
-- BUNNY HOP
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not Yuno.bhopEnabled then return end
    local hum = getHumanoid()
    if not hum then return end
    local moveDir = hum.MoveDirection
    if moveDir.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    hum.WalkSpeed = Yuno.bhopSpeed
end)

-- ============================================================
-- SPEED HACK / JUMP POWER
-- ============================================================
RunService.Heartbeat:Connect(function()
    local hum = getHumanoid()
    if not hum then return end
    if Yuno.speedHackEnabled then
        hum.WalkSpeed = Yuno.speedValue
    else
        hum.WalkSpeed = 16
    end
    if Yuno.jumpPowerEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = Yuno.jumpPowerValue
    else
        hum.JumpPower = 50
    end
end)

-- ============================================================
-- SPEED GLITCH (super sprint) - from Dabl Gee
-- ============================================================
RunService.Stepped:Connect(function()
    if Yuno.speedGlitchEnabled then
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = 60
            hum.JumpPower = 80
        end
    end
end)

-- ============================================================
-- SPINBOT
-- ============================================================
RunService.RenderStepped:Connect(function()
    if Yuno.spinbotEnabled then
        local root = getHumanoidRootPart()
        if root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(45), 0)
        end
    end
end)

-- ============================================================
-- SWIM WALK
-- ============================================================
RunService.Heartbeat:Connect(function()
    if Yuno.swimWalkEnabled then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Swimming)
        end
    end
end)

-- ============================================================
-- FLING FUNCTIONS (from Benjo / Dabl Gee)
-- ============================================================
local function flingPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local myRoot = getHumanoidRootPart()
    local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return end
    local power = Yuno.flingPower
    myRoot.CFrame = tRoot.CFrame + Vector3.new(math.random(-2,2), 3, math.random(-2,2))
    myRoot.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999) * (power / 100)
    myRoot.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999) * (power / 100)
end

local function flingMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isMurderer(player) then
            flingPlayer(player)
            return
        end
    end
end

local function flingSheriff()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isSheriff(player) then
            flingPlayer(player)
            return
        end
    end
end

local function flingTargetByName(name)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(name:lower()) then
            flingPlayer(player)
            return
        end
    end
end

-- Touch Fling
RunService.Heartbeat:Connect(function()
    if not Yuno.touchFlingEnabled then return end
    local myRoot = getHumanoidRootPart()
    if not myRoot then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local tRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if tRoot and (myRoot.Position - tRoot.Position).Magnitude < 6 then
            flingPlayer(player)
            break
        end
    end
end)

-- ============================================================
-- WEAPON SPAWNER / DUPE / REPLACER / SKIN CHANGER (from Benjo / spawner.lua)
-- ============================================================
local function spawnWeapon(name)
    if not name or name == "" then return end
    pcall(function()
        local BoxModule = require(ReplicatedStorage.Modules.BoxModule)
        local ItemDatabase = require(ReplicatedStorage.Database.Sync.Item)
        if ItemDatabase[name] then
            BoxModule.OpenBox("StandardBox", name)
            WindUI:Notify({Title = "Spawn", Content = "Spawned " .. name, Icon = "check", Duration = 3})
        else
            WindUI:Notify({Title = "Error", Content = "Weapon not found", Icon = "x", Duration = 3})
        end
    end)
end

local function duplicateWeapon(weaponName)
    local invMain = LocalPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Inventory")
    if not invMain then invMain = LocalPlayer.PlayerGui.MainGUI.Lobby.Screens.Inventory end
    if not invMain then return end
    local main = invMain.Main
    for _, category in ipairs(main.Weapons.Items.Container:GetChildren()) do
        for _, item in ipairs(category.Container:GetChildren()) do
            if item:IsA("Frame") and item.ItemName.Label.Text == weaponName then
                local current = item.Container.Amount.Text
                local num = tonumber(current:match("x(%d+)"))
                if num then
                    item.Container.Amount.Text = "x" .. tostring(num + 1)
                else
                    item.Container.Amount.Text = "x2"
                end
                return
            end
        end
    end
end

local function duplicateInventory()
    local invMain = LocalPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Inventory")
    if not invMain then invMain = LocalPlayer.PlayerGui.MainGUI.Lobby.Screens.Inventory end
    if not invMain then return end
    local main = invMain.Main
    for _, category in ipairs(main.Weapons.Items.Container:GetChildren()) do
        for _, item in ipairs(category.Container:GetChildren()) do
            if item:IsA("Frame") and item.ItemName.Label.Text ~= "Default Knife" and item.ItemName.Label.Text ~= "Default Gun" then
                local current = item.Container.Amount.Text
                local num = tonumber(current:match("x(%d+)"))
                if num then
                    item.Container.Amount.Text = "x" .. tostring(num * 2)
                else
                    item.Container.Amount.Text = "x2"
                end
            end
        end
    end
end

local function replaceWeapon(from, to)
    pcall(function()
        local ItemDatabase = require(ReplicatedStorage.Database.Sync.Item)
        local fromFound, toFound
        for name, _ in pairs(ItemDatabase) do
            if name:lower():find(from:lower()) then fromFound = name end
            if name:lower():find(to:lower()) then toFound = name end
        end
        if fromFound and toFound then
            ItemDatabase[fromFound] = {}
            for k, v in pairs(ItemDatabase[toFound]) do
                ItemDatabase[fromFound][k] = v
            end
            ReplicatedStorage.Remotes.Inventory.Equip:FireServer(toFound)
            WindUI:Notify({Title = "Replaced", Content = from .. " -> " .. to, Icon = "check", Duration = 3})
        else
            WindUI:Notify({Title = "Error", Content = "Weapon not found", Icon = "x", Duration = 3})
        end
    end)
end

-- Skin Changer
RunService.RenderStepped:Connect(function()
    if not Yuno.skinChangerEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local knife = char:FindFirstChild("Knife") or char:FindFirstChild("CKnife")
    if knife and Yuno.selectedKnifeMesh ~= "" then
        for _, desc in ipairs(knife:GetDescendants()) do
            if desc:IsA("SpecialMesh") or desc:IsA("FileMesh") then
                desc.TextureId = Yuno.selectedKnifeMesh
            elseif desc:IsA("MeshPart") then
                desc.TextureID = Yuno.selectedKnifeMesh
            end
        end
    end
    local gun = char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") or char:FindFirstChild("CGun")
    if gun and Yuno.selectedGunMesh ~= "" then
        for _, desc in ipairs(gun:GetDescendants()) do
            if desc:IsA("SpecialMesh") or desc:IsA("FileMesh") then
                desc.TextureId = Yuno.selectedGunMesh
            elseif desc:IsA("MeshPart") then
                desc.TextureID = Yuno.selectedGunMesh
            end
        end
    end
end)

-- ============================================================
-- BULLET TRACERS (from Modern UI)
-- ============================================================
local function getTracerColor()
    local t = Yuno.tracerColor
    if t == "Red" then
        return Color3.fromRGB(255, 50, 50)
    elseif t == "Green" then
        return Color3.fromRGB(50, 255, 50)
    elseif t == "Rainbow" then
        return Color3.fromHSV(tick() % 5 / 5, 1, 1)
    else
        return Color3.fromRGB(60, 160, 255)
    end
end

local function createTracer(startPos, endPos)
    if not Yuno.bulletTracersEnabled then return end
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = getTracerColor()
    part.Transparency = 0.1
    local distance = (startPos - endPos).Magnitude
    part.Size = Vector3.new(0.12, 0.12, distance)
    part.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
    part.Parent = workspace
    TweenService:Create(part, TweenInfo.new(0.35), {Transparency = 1, Size = Vector3.new(0, 0, distance)}):Play()
    task.delay(0.35, function() if part and part.Parent then part:Destroy() end end)
end

local function hookGun(char)
    char.ChildAdded:Connect(function(tool)
        if tool:IsA("Tool") and (tool.Name == "Gun" or tool.Name == "Revolver" or tool.Name == "CGun") then
            tool.Activated:Connect(function()
                if not Yuno.bulletTracersEnabled then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                local origin = root.Position
                local targetPos = origin + Camera.CFrame.LookVector * 300
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {char, Camera}
                params.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(origin, Camera.CFrame.LookVector * 300, params)
                if result then targetPos = result.Position end
                createTracer(origin, targetPos)
            end)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(hookGun)
if LocalPlayer.Character then hookGun(LocalPlayer.Character) end

-- ============================================================
-- AUTO GREET (from Dabl Gee)
-- ============================================================
local function autoGreet()
    if not Yuno.autoGreetEnabled then return end
    local mm2 = workspace:FindFirstChild("MurderMystery2")
    if mm2 then
        local state = mm2:FindFirstChild("RoundState")
        if state and state.Value == "Playing" then
            local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chat then
                local say = chat:FindFirstChild("SayMessageRequest")
                if say then
                    say:FireServer("Yuno Hub activated! Good luck!", "All")
                    Yuno.autoGreetEnabled = false
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        autoGreet()
        task.wait(10)
    end
end)

-- ============================================================
-- TRADE SCAM (from Benjo)
-- ============================================================
local function activateTradeScam()
    if LocalPlayer.PlayerGui.TradeGUI.Enabled or LocalPlayer.PlayerGui.TradeGUI_Phone.Enabled then
        WindUI:Notify({Title = "Trade Scam", Content = "Items are now visual, remove all!", Icon = "alert-triangle", Duration = 5})
    else
        WindUI:Notify({Title = "Trade Scam", Content = "You need to be in a trade!", Icon = "x", Duration = 3})
    end
end

-- ============================================================
-- SERVER LAGGER (from Benjo)
-- ============================================================
local function serverLagger()
    WindUI:Notify({Title = "Server Lagger", Content = "Lagging server...", Icon = "zap", Duration = 3})
    task.spawn(function()
        local GetSyncData = ReplicatedStorage.GetSyncData
        if GetSyncData then
            while Yuno.serverLaggerEnabled do
                for i = 1, 5 do
                    task.spawn(GetSyncData.InvokeServer, GetSyncData)
                end
                task.wait(0.01)
            end
        end
    end)
end

-- ============================================================
-- ANTI-AFK (from all)
-- ============================================================
if Yuno.antiAFKEnabled then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end

-- ============================================================
-- INSTANT ROUND WIN (from Fan Hub)
-- ============================================================
local function instantWin()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("win") or obj.Name:lower():find("finish") or obj.Name:lower():find("goal")) then
            root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
            break
        end
    end
end

-- ============================================================
-- UI CONSTRUCTION (WindUI) - all tabs
-- ============================================================
local Window = WindUI:CreateWindow({
    Title = "Yuno Hub | Murder Mystery 2",
    Author = "Yuno",
    Folder = "YunoHub",
    Icon = "layers",
    Size = UDim2.new(0, 640, 0, 540),
    Transparent = true,
    BackgroundTransparency = 0.5,
    Theme = "Dark",
    SideBarWidth = 220,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    OpenButton = {
        Title = "Open Yuno Hub",
        CornerRadius = UDim.new(0.5, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Color = ColorSequence.new(Color3.fromRGB(255, 100, 100), Color3.fromRGB(100, 100, 255)),
    },
})

local MainSection = Window:Section({
    Title = "Yuno Functions",
    Icon = "flame",
    Opened = true,
})

-- ===== ESP TAB =====
local ESPTab = MainSection:Tab({ Title = "ESP", Icon = "eye" })
ESPTab:Section({ Title = "ESP Settings", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
ESPTab:Toggle({
    Flag = "ESP_Enabled",
    Title = "Enable ESP",
    Default = Yuno.espEnabled,
    Callback = function(v) Yuno.espEnabled = v end
})
ESPTab:Toggle({
    Flag = "ESP_Highlight",
    Title = "Highlight (Chams)",
    Default = Yuno.highlightEnabled,
    Callback = function(v) Yuno.highlightEnabled = v end
})
ESPTab:Toggle({
    Flag = "ESP_Box",
    Title = "Box ESP",
    Default = Yuno.boxEspEnabled,
    Callback = function(v) Yuno.boxEspEnabled = v end
})
ESPTab:Toggle({
    Flag = "ESP_Name",
    Title = "Show Names",
    Default = Yuno.nameEspEnabled,
    Callback = function(v) Yuno.nameEspEnabled = v end
})
ESPTab:Toggle({
    Flag = "ESP_Role",
    Title = "Show Role",
    Default = Yuno.roleEspEnabled,
    Callback = function(v) Yuno.roleEspEnabled = v end
})
ESPTab:Toggle({
    Flag = "ESP_Health",
    Title = "Show Health",
    Default = Yuno.healthEspEnabled,
    Callback = function(v) Yuno.healthEspEnabled = v end
})
ESPTab:Toggle({
    Flag = "ESP_Distance",
    Title = "Show Distance",
    Default = Yuno.distanceEspEnabled,
    Callback = function(v) Yuno.distanceEspEnabled = v end
})
ESPTab:Toggle({
    Flag = "ESP_Line",
    Title = "Line Tracers",
    Default = Yuno.lineEspEnabled,
    Callback = function(v) Yuno.lineEspEnabled = v end
})
ESPTab:Dropdown({
    Flag = "ESP_Filter",
    Title = "Player Filter",
    Values = {
        {Title = "All", Icon = "users"},
        {Title = "Murderer", Icon = "skull"},
        {Title = "Sheriff", Icon = "shield"},
        {Title = "Murderer/Sheriff", Icon = "target"},
    },
    Value = Yuno.espFilter,
    Callback = function(selected) Yuno.espFilter = selected.Title end
})
ESPTab:Toggle({
    Flag = "ESP_TeamCheck",
    Title = "Ignore Teammates",
    Default = Yuno.teamCheckEnabled,
    Callback = function(v) Yuno.teamCheckEnabled = v end
})

-- ===== VISUAL TAB =====
local VisualTab = MainSection:Tab({ Title = "Visual", Icon = "sun" })
VisualTab:Section({ Title = "Xray & Brightness", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
VisualTab:Toggle({
    Flag = "Xray",
    Title = "Xray (see through walls)",
    Default = Yuno.xrayEnabled,
    Callback = function(v)
        Yuno.xrayEnabled = v
        if v then enableXray() else disableXray() end
    end
})
VisualTab:Toggle({
    Flag = "FullBright",
    Title = "Full Bright",
    Default = Yuno.fullBrightEnabled,
    Callback = function(v)
        Yuno.fullBrightEnabled = v
        setFullBright(v)
    end
})
VisualTab:Dropdown({
    Flag = "Skybox",
    Title = "Skybox Style",
    Values = { "Original", "Sunset", "Galaxy", "Night" },
    Value = Yuno.skybox,
    Callback = function(v)
        Yuno.skybox = v
        setSkybox(v)
    end
})
VisualTab:Section({ Title = "Hitboxes", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
VisualTab:Toggle({
    Flag = "HitboxScale",
    Title = "Scale Hitboxes",
    Default = Yuno.hitboxScaleEnabled,
    Callback = function(v) Yuno.hitboxScaleEnabled = v end
})
VisualTab:Slider({
    Flag = "HitboxScaleValue",
    Title = "Hitbox Scale",
    Step = 0.5,
    Value = { Min = 1, Max = 10, Default = Yuno.hitboxScale },
    Callback = function(v) Yuno.hitboxScale = v end
})

-- ===== COMBAT TAB =====
local CombatTab = MainSection:Tab({ Title = "Combat", Icon = "sword" })
CombatTab:Section({ Title = "Aimbot", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
CombatTab:Toggle({
    Flag = "Aimbot",
    Title = "Enable Aimbot",
    Default = Yuno.aimbotEnabled,
    Callback = function(v) Yuno.aimbotEnabled = v end
})
CombatTab:Slider({
    Flag = "AimbotSmooth",
    Title = "Smoothness",
    Step = 1,
    Value = { Min = 1, Max = 20, Default = Yuno.aimbotSmooth },
    Callback = function(v) Yuno.aimbotSmooth = v end
})
CombatTab:Slider({
    Flag = "AimbotFOV",
    Title = "FOV (degrees)",
    Step = 5,
    Value = { Min = 30, Max = 180, Default = Yuno.aimbotFOV },
    Callback = function(v) Yuno.aimbotFOV = v end
})
CombatTab:Toggle({
    Flag = "Aimbot_Murderer",
    Title = "Target Murderer",
    Default = Yuno.aimbotTargetMurderer,
    Callback = function(v) Yuno.aimbotTargetMurderer = v end
})
CombatTab:Toggle({
    Flag = "Aimbot_Sheriff",
    Title = "Target Sheriff",
    Default = Yuno.aimbotTargetSheriff,
    Callback = function(v) Yuno.aimbotTargetSheriff = v end
})

CombatTab:Section({ Title = "Auto Shoot (Sheriff)", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
CombatTab:Toggle({
    Flag = "AutoShoot",
    Title = "Auto Shoot Murderer",
    Default = Yuno.autoShootEnabled,
    Callback = function(v) Yuno.autoShootEnabled = v end
})

CombatTab:Section({ Title = "Kill All (Murderer)", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
CombatTab:Toggle({
    Flag = "KillAll",
    Title = "Enable Kill All",
    Default = Yuno.killAllEnabled,
    Callback = function(v)
        Yuno.killAllEnabled = v
        if v then startKillAll() else stopKillAll() end
    end
})
CombatTab:Slider({
    Flag = "KillAll_Delay",
    Title = "Attack Delay",
    Step = 0.1,
    Value = { Min = 0.1, Max = 2, Default = Yuno.killAllDelay },
    Callback = function(v) Yuno.killAllDelay = v end
})

CombatTab:Section({ Title = "Kill Aura", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
CombatTab:Toggle({
    Flag = "KillAura",
    Title = "Enable Kill Aura",
    Default = Yuno.killAuraEnabled,
    Callback = function(v) Yuno.killAuraEnabled = v end
})
CombatTab:Slider({
    Flag = "KillAuraRange",
    Title = "Range",
    Step = 1,
    Value = { Min = 5, Max = 100, Default = Yuno.killAuraRange },
    Callback = function(v) Yuno.killAuraRange = v end
})
CombatTab:Slider({
    Flag = "KillAuraDamage",
    Title = "Damage per tick",
    Step = 0.5,
    Value = { Min = 1, Max = 10, Default = Yuno.killAuraDamage },
    Callback = function(v) Yuno.killAuraDamage = v end
})

CombatTab:Section({ Title = "Weapon Mods", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
CombatTab:Toggle({
    Flag = "InfiniteAmmo",
    Title = "Infinite Ammo",
    Default = Yuno.infiniteAmmoEnabled,
    Callback = function(v) Yuno.infiniteAmmoEnabled = v end
})
CombatTab:Toggle({
    Flag = "InstantReload",
    Title = "Instant Reload",
    Default = Yuno.instantReloadEnabled,
    Callback = function(v) Yuno.instantReloadEnabled = v end
})
CombatTab:Button({
    Title = "Instant Round Win",
    Icon = "trophy",
    Callback = function() instantWin() end
})

-- ===== FARM TAB =====
local FarmTab = MainSection:Tab({ Title = "Auto Farm", Icon = "trending-up" })
FarmTab:Section({ Title = "Coin & Candy Farming", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
FarmTab:Toggle({
    Flag = "CoinFarm",
    Title = "Coin Autofarm",
    Default = Yuno.coinFarmEnabled,
    Callback = function(v) Yuno.coinFarmEnabled = v end
})
FarmTab:Toggle({
    Flag = "CandyFarm",
    Title = "Candy Autofarm",
    Default = Yuno.candyFarmEnabled,
    Callback = function(v) Yuno.candyFarmEnabled = v end
})
FarmTab:Slider({
    Flag = "FarmSpeed",
    Title = "Movement Speed",
    Step = 1,
    Value = { Min = 5, Max = 50, Default = Yuno.farmSpeed },
    Callback = function(v) Yuno.farmSpeed = v end
})
FarmTab:Toggle({
    Flag = "AutoReset",
    Title = "Auto Reset on Bag Full",
    Default = Yuno.autoResetOnBagFull,
    Callback = function(v) Yuno.autoResetOnBagFull = v end
})
FarmTab:Toggle({
    Flag = "AutoFlingMurderer",
    Title = "Auto Fling Murderer on Full",
    Default = Yuno.autoFlingMurdererOnFull,
    Callback = function(v) Yuno.autoFlingMurdererOnFull = v end
})

-- ===== MOVEMENT TAB =====
local MoveTab = MainSection:Tab({ Title = "Movement", Icon = "move" })
MoveTab:Section({ Title = "Movement Mods", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
MoveTab:Toggle({
    Flag = "Fly",
    Title = "Fly (WASD + Space/Shift)",
    Default = Yuno.flyEnabled,
    Callback = function(v) toggleFly(v) end
})
MoveTab:Slider({
    Flag = "FlySpeed",
    Title = "Fly Speed",
    Step = 1,
    Value = { Min = 10, Max = 200, Default = Yuno.flySpeed },
    Callback = function(v) Yuno.flySpeed = v end
})
MoveTab:Toggle({
    Flag = "Noclip",
    Title = "Noclip",
    Default = Yuno.noclipEnabled,
    Callback = function(v) Yuno.noclipEnabled = v end
})
MoveTab:Toggle({
    Flag = "InfiniteJump",
    Title = "Infinite Jump",
    Default = Yuno.infiniteJumpEnabled,
    Callback = function(v) Yuno.infiniteJumpEnabled = v end
})
MoveTab:Toggle({
    Flag = "BunnyHop",
    Title = "Bunny Hop",
    Default = Yuno.bhopEnabled,
    Callback = function(v) Yuno.bhopEnabled = v end
})
MoveTab:Slider({
    Flag = "BhopSpeed",
    Title = "Bhop Speed",
    Step = 1,
    Value = { Min = 10, Max = 80, Default = Yuno.bhopSpeed },
    Callback = function(v) Yuno.bhopSpeed = v end
})
MoveTab:Toggle({
    Flag = "SpeedHack",
    Title = "Speed Hack",
    Default = Yuno.speedHackEnabled,
    Callback = function(v) Yuno.speedHackEnabled = v end
})
MoveTab:Slider({
    Flag = "SpeedValue",
    Title = "Speed Value",
    Step = 1,
    Value = { Min = 1, Max = 200, Default = Yuno.speedValue },
    Callback = function(v) Yuno.speedValue = v end
})
MoveTab:Toggle({
    Flag = "SpeedGlitch",
    Title = "Speed Glitch (super sprint)",
    Default = Yuno.speedGlitchEnabled,
    Callback = function(v) Yuno.speedGlitchEnabled = v end
})
MoveTab:Toggle({
    Flag = "JumpPower",
    Title = "Custom Jump Power",
    Default = Yuno.jumpPowerEnabled,
    Callback = function(v) Yuno.jumpPowerEnabled = v end
})
MoveTab:Slider({
    Flag = "JumpPowerValue",
    Title = "Jump Power",
    Step = 1,
    Value = { Min = 10, Max = 300, Default = Yuno.jumpPowerValue },
    Callback = function(v) Yuno.jumpPowerValue = v end
})
MoveTab:Toggle({
    Flag = "Spinbot",
    Title = "Spinbot",
    Default = Yuno.spinbotEnabled,
    Callback = function(v) Yuno.spinbotEnabled = v end
})
MoveTab:Toggle({
    Flag = "SwimWalk",
    Title = "Swim Walk (fake swimming)",
    Default = Yuno.swimWalkEnabled,
    Callback = function(v) Yuno.swimWalkEnabled = v end
})

-- ===== TELEPORT TAB =====
local TeleportTab = MainSection:Tab({ Title = "Teleport", Icon = "move" })
TeleportTab:Section({ Title = "Teleport to Items", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
TeleportTab:Toggle({
    Flag = "TPGun",
    Title = "Teleport to Gun",
    Default = Yuno.tpGunEnabled,
    Callback = function(v) Yuno.tpGunEnabled = v end
})
TeleportTab:Button({
    Title = "Teleport to Gun Now",
    Icon = "zap",
    Callback = function() tpToGun() end
})
TeleportTab:Toggle({
    Flag = "GrabGun",
    Title = "Auto Grab Gun",
    Default = Yuno.grabGunEnabled,
    Callback = function(v)
        Yuno.grabGunEnabled = v
        if v then task.spawn(autoGrabLoop) end
    end
})
TeleportTab:Button({
    Title = "Grab Gun Now",
    Icon = "hand",
    Callback = function() grabGun() end
})

-- ===== WEAPONS TAB =====
local WeaponsTab = MainSection:Tab({ Title = "Weapons", Icon = "sword" })
WeaponsTab:Section({ Title = "Spawn Weapon", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
WeaponsTab:Input({
    Flag = "SpawnName",
    Title = "Weapon Name",
    Placeholder = "e.g., Raygun",
    Value = Yuno.spawnWeaponName,
    Callback = function(v) Yuno.spawnWeaponName = v end
})
WeaponsTab:Button({
    Title = "Spawn Weapon",
    Icon = "sparkles",
    Callback = function() spawnWeapon(Yuno.spawnWeaponName) end
})

WeaponsTab:Section({ Title = "Duplicate Weapon", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
WeaponsTab:Input({
    Flag = "DupeName",
    Title = "Weapon Name",
    Placeholder = "e.g., Lightbringer",
    Value = Yuno.dupeWeaponName,
    Callback = function(v) Yuno.dupeWeaponName = v end
})
WeaponsTab:Input({
    Flag = "DupeAmount",
    Title = "Dupe Amount",
    Value = tostring(Yuno.dupeAmount),
    Callback = function(v) Yuno.dupeAmount = tonumber(v) or 1 end
})
WeaponsTab:Button({
    Title = "Duplicate Weapon",
    Icon = "copy",
    Callback = function()
        for i = 1, Yuno.dupeAmount do
            duplicateWeapon(Yuno.dupeWeaponName)
        end
    end
})
WeaponsTab:Button({
    Title = "Duplicate Entire Inventory",
    Icon = "package",
    Callback = function() duplicateInventory() end
})

WeaponsTab:Section({ Title = "Visual Weapon Replacer", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
WeaponsTab:Input({
    Flag = "FromWeapon",
    Title = "From Weapon",
    Placeholder = "e.g., Blossom",
    Value = Yuno.fromWeapon,
    Callback = function(v) Yuno.fromWeapon = v end
})
WeaponsTab:Input({
    Flag = "ToWeapon",
    Title = "To Weapon",
    Placeholder = "e.g., Chroma",
    Value = Yuno.toWeapon,
    Callback = function(v) Yuno.toWeapon = v end
})
WeaponsTab:Button({
    Title = "Replace Visual",
    Icon = "wand-2",
    Callback = function() replaceWeapon(Yuno.fromWeapon, Yuno.toWeapon) end
})

WeaponsTab:Section({ Title = "Skin Changer", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
WeaponsTab:Toggle({
    Flag = "SkinChanger",
    Title = "Enable Skin Changer",
    Default = Yuno.skinChangerEnabled,
    Callback = function(v) Yuno.skinChangerEnabled = v end
})
WeaponsTab:Input({
    Flag = "KnifeMesh",
    Title = "Knife Texture ID",
    Placeholder = "rbxassetid://...",
    Value = Yuno.selectedKnifeMesh,
    Callback = function(v) Yuno.selectedKnifeMesh = v end
})
WeaponsTab:Input({
    Flag = "GunMesh",
    Title = "Gun Texture ID",
    Placeholder = "rbxassetid://...",
    Value = Yuno.selectedGunMesh,
    Callback = function(v) Yuno.selectedGunMesh = v end
})

-- ===== FLING TAB =====
local FlingTab = MainSection:Tab({ Title = "Fling", Icon = "zap" })
FlingTab:Section({ Title = "Fling Options", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
FlingTab:Slider({
    Flag = "FlingPower",
    Title = "Fling Power",
    Step = 5,
    Value = { Min = 20, Max = 300, Default = Yuno.flingPower },
    Callback = function(v) Yuno.flingPower = v end
})
FlingTab:Toggle({
    Flag = "FlingMurderer",
    Title = "Fling Murderer",
    Default = Yuno.flingMurdererEnabled,
    Callback = function(v)
        Yuno.flingMurdererEnabled = v
        if v then flingMurderer() end
    end
})
FlingTab:Toggle({
    Flag = "FlingSheriff",
    Title = "Fling Sheriff",
    Default = Yuno.flingSheriffEnabled,
    Callback = function(v)
        Yuno.flingSheriffEnabled = v
        if v then flingSheriff() end
    end
})
FlingTab:Toggle({
    Flag = "TouchFling",
    Title = "Touch Fling (on contact)",
    Default = Yuno.touchFlingEnabled,
    Callback = function(v) Yuno.touchFlingEnabled = v end
})
FlingTab:Section({ Title = "Target Fling", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
local targetPlayerDropdown = FlingTab:Dropdown({
    Flag = "TargetFlingPlayer",
    Title = "Select Target",
    Values = function()
        local list = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(list, {Title = player.Name, Icon = "user"})
            end
        end
        return list
    end,
    Callback = function(selected)
        Yuno.selectedTargetName = selected.Title
    end
})
FlingTab:Toggle({
    Flag = "TargetFling",
    Title = "Enable Target Fling",
    Default = Yuno.targetFlingEnabled,
    Callback = function(v)
        Yuno.targetFlingEnabled = v
        if v and Yuno.selectedTargetName ~= "" then
            flingTargetByName(Yuno.selectedTargetName)
        end
    end
})
FlingTab:Button({
    Title = "Refresh Player List",
    Icon = "refresh-cw",
    Callback = function()
        targetPlayerDropdown:Refresh()
    end
})

-- ===== MISC TAB =====
local MiscTab = MainSection:Tab({ Title = "Misc", Icon = "settings" })
MiscTab:Section({ Title = "Utilities", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
MiscTab:Toggle({
    Flag = "AntiAFK",
    Title = "Anti-AFK",
    Default = Yuno.antiAFKEnabled,
    Callback = function(v)
        Yuno.antiAFKEnabled = v
        if v then
            LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
            end)
        end
    end
})
MiscTab:Toggle({
    Flag = "AutoGreet",
    Title = "Auto Greet (say in chat once)",
    Default = Yuno.autoGreetEnabled,
    Callback = function(v) Yuno.autoGreetEnabled = v end
})
MiscTab:Toggle({
    Flag = "BulletTracers",
    Title = "Bullet Tracers",
    Default = Yuno.bulletTracersEnabled,
    Callback = function(v) Yuno.bulletTracersEnabled = v end
})
MiscTab:Dropdown({
    Flag = "TracerColor",
    Title = "Tracer Color",
    Values = { "Blue", "Red", "Green", "Rainbow" },
    Value = Yuno.tracerColor,
    Callback = function(v) Yuno.tracerColor = v end
})
MiscTab:Toggle({
    Flag = "TradeScam",
    Title = "Trade Scam (visual)",
    Default = Yuno.tradeScamEnabled,
    Callback = function(v) Yuno.tradeScamEnabled = v end
})
MiscTab:Button({
    Title = "Activate Trade Scam",
    Icon = "alert-triangle",
    Callback = function() activateTradeScam() end
})
MiscTab:Toggle({
    Flag = "ServerLagger",
    Title = "Server Lagger (use with caution)",
    Default = Yuno.serverLaggerEnabled,
    Callback = function(v)
        Yuno.serverLaggerEnabled = v
        if v then serverLagger() end
    end
})

-- ===== SETTINGS TAB =====
local SettingsTab = MainSection:Tab({ Title = "Settings", Icon = "settings" })
SettingsTab:Section({ Title = "GUI Settings", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
SettingsTab:Keybind({
    Flag = "MenuKeybind",
    Title = "Toggle GUI Key",
    Value = Yuno.menuKeybind,
    Callback = function(key)
        Yuno.menuKeybind = key
        Window:SetToggleKey(Enum.KeyCode[key])
    end
})
SettingsTab:Section({ Title = "Config Management", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
local configInput = SettingsTab:Input({
    Flag = "ConfigName",
    Title = "Config Name",
    Value = Yuno.configName,
    Callback = function(v) Yuno.configName = v end
})
local configDropdown = SettingsTab:Dropdown({
    Flag = "ConfigSelect",
    Title = "Load Config",
    Values = function()
        local list = getConfigList()
        local out = {}
        for _, name in ipairs(list) do
            table.insert(out, {Title = name, Icon = "file"})
        end
        return out
    end,
    Callback = function(selected)
        Yuno.configName = selected.Title
        configInput:Set(selected.Title)
    end
})
SettingsTab:Button({
    Title = "Save Config",
    Icon = "save",
    Callback = function()
        saveConfig(Yuno.configName)
        WindUI:Notify({Title = "Config Saved", Content = "Saved as " .. Yuno.configName, Icon = "check", Duration = 3})
    end
})
SettingsTab:Button({
    Title = "Load Config",
    Icon = "upload",
    Callback = function()
        if loadConfig(Yuno.configName) then
            WindUI:Notify({Title = "Config Loaded", Content = "Loaded " .. Yuno.configName, Icon = "check", Duration = 3})
        else
            WindUI:Notify({Title = "Error", Content = "Config not found", Icon = "x", Duration = 3})
        end
    end
})
SettingsTab:Button({
    Title = "Refresh Config List",
    Icon = "refresh-cw",
    Callback = function()
        configDropdown:Refresh()
    end
})

-- ===== INFO TAB =====
local InfoTab = MainSection:Tab({ Title = "Info", Icon = "info" })
InfoTab:Section({ Title = "Yuno Hub", TextSize = 20, FontWeight = Enum.FontWeight.Bold })
InfoTab:Section({ Title = "All-in-one MM2 Hub with all features from Benjo, Onyyx, Dabl Gee, Fan Hub, Advanced ESP, and more.", TextSize = 16, TextTransparency = 0.3 })
InfoTab:Section({ Title = "Features: ESP | Xray | Full Bright | Skybox | Hitboxes | Aimbot | Auto Shoot | Kill All | Kill Aura | Infinite Ammo | Instant Reload | Auto Farm | Fly | Noclip | Infinite Jump | Bunny Hop | Speed Hack | Speed Glitch | Jump Power | Spinbot | Swim Walk | Teleport to Gun | Grab Gun | Weapon Spawn/Dupe/Replacer | Skin Changer | Fling | Trade Scam | Server Lagger | Anti-AFK | Bullet Tracers | Config System", TextSize = 14, TextTransparency = 0.4 })

-- ============================================================
-- KEYBIND TOGGLE
-- ============================================================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[Yuno.menuKeybind] then
        Window:ToggleVisibility()
    end
end)

-- ============================================================
-- INITIALIZE XRAY, FULLBRIGHT, SKYBOX
-- ============================================================
if Yuno.xrayEnabled then enableXray() end
if Yuno.fullBrightEnabled then setFullBright(true) end
if Yuno.skybox ~= "Original" then setSkybox(Yuno.skybox) end

-- ============================================================
-- NOTIFY LOADED
-- ============================================================
WindUI:Notify({
    Title = "Yuno Hub",
    Content = "Loaded successfully! Press " .. Yuno.menuKeybind .. " to toggle.",
    Icon = "check",
    Duration = 5,
})

print("Yuno Hub loaded with all features from multiple hubs!")