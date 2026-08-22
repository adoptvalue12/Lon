-- Yuno Hub - Prison Life (WindUI)
--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalizationService = game:GetService("LocalizationService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

--==================================================
-- COLORS
--==================================================
local Colors = {
    Orange = Color3.fromHex("#FF6B1A"),
    DarkOrange = Color3.fromHex("#FF4500"),
    Purple = Color3.fromHex("#9D4EDD"),
    DarkPurple = Color3.fromHex("#5A189A"),
    Blood = Color3.fromHex("#8B0000"),
    Ghost = Color3.fromHex("#E0E0E0"),
    Pumpkin = Color3.fromHex("#FF7518"),
    Witch = Color3.fromHex("#6B2E8A"),
    Midnight = Color3.fromHex("#0D0221"),
    Toxic = Color3.fromHex("#39FF14"),
    Red = Color3.fromHex("#FF0000"),
    Green = Color3.fromHex("#00FF00"),
    Gold = Color3.fromHex("#FFD700"),
    Silver = Color3.fromHex("#C0C0C0"),
    Blue = Color3.fromHex("#1E90FF"),
    Cyan = Color3.fromHex("#00FFFF"),
    White = Color3.fromHex("#FFFFFF"),
}

--==================================================
-- GRADIENT TEXT
--==================================================
local function CreateGradientText(text, color1, color2)
    local result = ""
    local length = #text
    for i = 1, length do
        local progress = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((color1.R + (color2.R - color1.R) * progress) * 255)
        local g = math.floor((color1.G + (color2.G - color1.G) * progress) * 255)
        local b = math.floor((color1.B + (color2.B - color1.B) * progress) * 255)
        result = result .. string.format('<font color="rgb(%d, %d, %d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

--==================================================
-- POPUP
--==================================================
local popupClosed = false
WindUI:Popup({
    Title = CreateGradientText("Yuno Hub", Colors.Red, Colors.Gold),
    Icon = "crown",
    Content = CreateGradientText("Best Prison Life Script", Colors.Gold, Colors.Blue) .. "<br/>" .. CreateGradientText("Enjoy the features!", Colors.Blue, Colors.Purple),
    Buttons = {
        { Title = "Exit", Callback = function() end, Variant = "Tertiary" },
        { Title = "Continue", Callback = function() popupClosed = true end, Variant = "Primary" }
    },
})
repeat task.wait() until popupClosed

--==================================================
-- SETTINGS
--==================================================
local Settings = {
    ESP = false,
    Aimbot = false,
    NoClip = false,
    Speed = false,
    Jump = false,
    Fly = false,
    InfiniteStamina = false,
    AutoArrest = false,
    AutoKill = false,
    AutoEscape = false,
    AutoFarm = false,
    RemoveDoors = false,
}

--==================================================
-- CREATE WINDOW
--==================================================
local Window = WindUI:CreateWindow({
    Title = CreateGradientText("Yuno Hub | Prison Life", Colors.Red, Colors.Gold),
    Author = "by Yuno",
    Folder = "YunoHub",
    Icon = "crown",
    NewElements = true,
    Size = UDim2.new(0, 580, 0, 480),
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
        Color = ColorSequence.new(Colors.Red, Colors.Gold),
    },
    User = { Enabled = true, Anonymous = false, Callback = function() end },
})

local MainSection = Window:Section({
    Title = CreateGradientText("Yuno Functions", Colors.Pumpkin, Colors.Purple),
    Icon = "flame",
    Opened = true,
})

--==================================================
-- TABS
--==================================================
local TeleportTab = MainSection:Tab({ Title = "Teleports", Icon = "move" })
local CombatTab = MainSection:Tab({ Title = "Combat", Icon = "sword" })
local PlayerTab = MainSection:Tab({ Title = "Player", Icon = "user" })
local WorldTab = MainSection:Tab({ Title = "World", Icon = "globe" })
local SettingsTab = MainSection:Tab({ Title = "Settings", Icon = "settings" })

--==================================================
-- TELEPORTS
--==================================================
TeleportTab:Section({ Title = "Locations", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
local teleports = {
    {name = "Prison", pos = Vector3.new(12, 10, 900)},
    {name = "Yard", pos = Vector3.new(0, 10, 960)},
    {name = "Armory", pos = Vector3.new(0, 10, 700)},
    {name = "Infirmary", pos = Vector3.new(0, 10, 800)},
    {name = "Cafeteria", pos = Vector3.new(0, 10, 1100)},
    {name = "Cells", pos = Vector3.new(0, 10, 850)},
    {name = "Guard Tower", pos = Vector3.new(100, 30, 950)},
    {name = "Helipad", pos = Vector3.new(-200, 10, 1100)},
    {name = "Escape Zone", pos = Vector3.new(-500, 10, 1200)},
}
for _, tp in ipairs(teleports) do
    TeleportTab:Button({
        Title = tp.name,
        Icon = "map-pin",
        Callback = function()
            if RootPart then RootPart.CFrame = CFrame.new(tp.pos) end
        end
    })
    TeleportTab:Space()
end

--==================================================
-- COMBAT
--==================================================
CombatTab:Section({ Title = "Combat Options", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
CombatTab:Toggle({
    Title = "Aimbot",
    Desc = "Auto-aim at nearest player",
    Default = false,
    Callback = function(v) Settings.Aimbot = v end
})
CombatTab:Space()
CombatTab:Toggle({
    Title = "Auto Arrest",
    Desc = "Auto arrest nearby prisoners (when guard)",
    Default = false,
    Callback = function(v) Settings.AutoArrest = v end
})
CombatTab:Space()
CombatTab:Toggle({
    Title = "Auto Kill",
    Desc = "Auto kill nearby guards (when prisoner)",
    Default = false,
    Callback = function(v) Settings.AutoKill = v end
})

--==================================================
-- PLAYER
--==================================================
PlayerTab:Section({ Title = "Player Options", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
PlayerTab:Toggle({
    Title = "ESP",
    Desc = "Highlight players with boxes and health bars",
    Default = false,
    Callback = function(v) Settings.ESP = v end
})
PlayerTab:Space()
PlayerTab:Toggle({
    Title = "NoClip",
    Desc = "Walk through walls",
    Default = false,
    Callback = function(v) Settings.NoClip = v end
})
PlayerTab:Space()
PlayerTab:Toggle({
    Title = "Speed",
    Desc = "Increase walk speed",
    Default = false,
    Callback = function(v) Settings.Speed = v end
})
PlayerTab:Space()
PlayerTab:Toggle({
    Title = "Jump",
    Desc = "Increase jump power",
    Default = false,
    Callback = function(v) Settings.Jump = v end
})
PlayerTab:Space()
PlayerTab:Toggle({
    Title = "Fly",
    Desc = "Fly with WASD + Space/Shift",
    Default = false,
    Callback = function(v) Settings.Fly = v end
})
PlayerTab:Space()
PlayerTab:Toggle({
    Title = "Infinite Stamina",
    Desc = "Never run out of stamina",
    Default = false,
    Callback = function(v) Settings.InfiniteStamina = v end
})

--==================================================
-- WORLD
--==================================================
WorldTab:Section({ Title = "World Mods", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
WorldTab:Toggle({
    Title = "Remove Doors",
    Desc = "Delete all doors from the map",
    Default = false,
    Callback = function(v)
        Settings.RemoveDoors = v
        if v then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("door") then obj:Destroy() end
            end
            for _, model in pairs(workspace:GetChildren()) do
                if model:IsA("Model") and model.Name:lower():find("door") then model:Destroy() end
            end
        end
    end
})
WorldTab:Space()
WorldTab:Toggle({
    Title = "Auto Escape",
    Desc = "Automatically walk to escape zone",
    Default = false,
    Callback = function(v) Settings.AutoEscape = v end
})
WorldTab:Space()
WorldTab:Toggle({
    Title = "Auto Farm (Cafeteria)",
    Desc = "Farm food/drink at cafeteria",
    Default = false,
    Callback = function(v) Settings.AutoFarm = v end
})

--==================================================
-- SETTINGS (Keybind etc.)
--==================================================
SettingsTab:Section({ Title = "GUI Settings", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
SettingsTab:Keybind({
    Title = "GUI Toggle Key",
    Desc = "Press to open/close GUI",
    Value = "G",
    Callback = function(key)
        Window:SetToggleKey(Enum.KeyCode[key])
        WindUI:Notify({ Title = "Keybind Set", Content = "GUI toggle key: " .. key, Icon = "keyboard", Duration = 3 })
    end
})

--==================================================
-- ESP SYSTEM
--==================================================
local espObjects = {}
local function CreateESP(player)
    if espObjects[player] or player == LocalPlayer then return end
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255,255,255)
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1

    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = Color3.fromRGB(255,255,255)
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0,0,0)

    local healthBar = Drawing.new("Line")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0,255,0)
    healthBar.Thickness = 3

    espObjects[player] = {box = box, nameTag = nameTag, healthBar = healthBar}
end

local function UpdateESP()
    for player, obj in pairs(espObjects) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
            local root = character.HumanoidRootPart
            local humanoid = character.Humanoid
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
            if onScreen then
                local distance = (RootPart.Position - root.Position).Magnitude
                local size = math.clamp(200 / distance, 30, 150)
                obj.box.Visible = true
                obj.box.Size = Vector2.new(size, size * 1.5)
                obj.box.Position = Vector2.new(pos.X - size/2, pos.Y - size*0.75)
                obj.box.Color = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255,255,255)

                obj.nameTag.Visible = true
                obj.nameTag.Text = player.Name .. " (" .. math.floor(distance) .. "m)"
                obj.nameTag.Position = Vector2.new(pos.X, pos.Y - size*0.9 - 15)
                obj.nameTag.Color = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255,255,255)

                obj.healthBar.Visible = true
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                obj.healthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                local barWidth = size * 0.6
                local barY = pos.Y + size * 0.4
                obj.healthBar.From = Vector2.new(pos.X - barWidth/2, barY)
                obj.healthBar.To = Vector2.new(pos.X - barWidth/2 + barWidth * healthPercent, barY)
            else
                obj.box.Visible = false
                obj.nameTag.Visible = false
                obj.healthBar.Visible = false
            end
        else
            obj.box.Visible = false
            obj.nameTag.Visible = false
            obj.healthBar.Visible = false
        end
    end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        espObjects[player].box:Remove()
        espObjects[player].nameTag:Remove()
        espObjects[player].healthBar:Remove()
        espObjects[player] = nil
    end
end)
for _, player in pairs(Players:GetPlayers()) do CreateESP(player) end

--==================================================
-- AIMBOT
--==================================================
local function GetClosestPlayer()
    local closest, minDist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)).Magnitude
                if dist < minDist then minDist = dist closest = player end
            end
        end
    end
    return closest
end

--==================================================
-- FLY
--==================================================
local flying = false
local flySpeed = 50

--==================================================
-- NOCLIP
--==================================================
local noclipEnabled = false
local noclipConn

--==================================================
-- MAIN LOOP
--==================================================
RunService.Heartbeat:Connect(function(dt)
    -- ESP
    if Settings.ESP then UpdateESP()
    else
        for _, obj in pairs(espObjects) do
            obj.box.Visible = false
            obj.nameTag.Visible = false
            obj.healthBar.Visible = false
        end
    end

    -- Aimbot
    if Settings.Aimbot then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = target.Character.HumanoidRootPart
            local direction = (targetRoot.Position - workspace.CurrentCamera.CFrame.Position).Unit
            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, workspace.CurrentCamera.CFrame.Position + direction)
        end
    end

    -- Speed
    if Settings.Speed then Humanoid.WalkSpeed = 50 else Humanoid.WalkSpeed = 16 end

    -- Jump
    if Settings.Jump then Humanoid.JumpPower = 100 else Humanoid.JumpPower = 50 end

    -- Infinite Stamina
    if Settings.InfiniteStamina then Humanoid.Stamina = 100 end

    -- Auto Arrest / Kill
    if Settings.AutoArrest or Settings.AutoKill then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local dist = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < 5 then
                    if Settings.AutoArrest and LocalPlayer.Team == game.Teams.Prisoners then
                        VirtualUser:ClickOnCharacter(player.Character)
                    end
                    if Settings.AutoKill and LocalPlayer.Team == game.Teams.Guards then
                        VirtualUser:ClickOnCharacter(player.Character)
                    end
                end
            end
        end
    end

    -- NoClip
    if Settings.NoClip then
        if not noclipEnabled then
            noclipEnabled = true
            noclipConn = RunService.Stepped:Connect(function()
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end)
        end
    else
        if noclipEnabled then
            noclipEnabled = false
            if noclipConn then noclipConn:Disconnect() end
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end

    -- Fly
    if Settings.Fly then
        if not flying then
            flying = true
            Humanoid.PlatformStand = true
        end
        local moveDirection = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0,1,0) end
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * flySpeed * dt * 10
            RootPart.CFrame = RootPart.CFrame + moveDirection
        end
    else
        if flying then
            flying = false
            Humanoid.PlatformStand = false
        end
    end

    -- Auto Escape
    if Settings.AutoEscape then
        local escapePos = Vector3.new(-500, 10, 1200)
        if (RootPart.Position - escapePos).Magnitude > 5 then
            RootPart.CFrame = RootPart.CFrame + (escapePos - RootPart.Position).Unit * 20 * dt
        end
    end

    -- Auto Farm (Cafeteria)
    if Settings.AutoFarm then
        local cafeteriaPos = Vector3.new(0, 10, 1100)
        if (RootPart.Position - cafeteriaPos).Magnitude > 5 then
            RootPart.CFrame = RootPart.CFrame + (cafeteriaPos - RootPart.Position).Unit * 20 * dt
        else
            VirtualUser:ClickOnScreen()
        end
    end
end)

--==================================================
-- CHARACTER RESPAWN
--==================================================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end)

--==================================================
-- NOTIFY START
--==================================================
WindUI:Notify({
    Title = "Yuno Hub",
    Content = "Welcome to Prison Life!",
    Icon = "crown",
    Duration = 5,
})
