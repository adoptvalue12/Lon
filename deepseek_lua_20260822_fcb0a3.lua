-- Yuno Hub - Prison Life Delta (Rayfield UI)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

-- Settings
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

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Yuno Hub",
    Icon = 0,
    LoadingTitle = "Yuno Hub Loading...",
    LoadingSubtitle = "by Yuno",
    Theme = "Dark",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "YunoHub"
    },
})

-- Tabs
local TeleportTab = Window:CreateTab("Teleports")
local CombatTab = Window:CreateTab("Combat")
local PlayerTab = Window:CreateTab("Player")
local WorldTab = Window:CreateTab("World")

-- Teleports Section
local TeleportSection = TeleportTab:CreateSection("Locations")
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
    TeleportTab:CreateButton({
        Name = tp.name,
        Callback = function()
            if RootPart then
                RootPart.CFrame = CFrame.new(tp.pos)
            end
        end,
    })
end

-- Combat Tab
CombatTab:CreateSection("Combat Options")
CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(v)
        Settings.Aimbot = v
    end,
})
CombatTab:CreateToggle({
    Name = "Auto Arrest",
    CurrentValue = false,
    Flag = "AutoArrest",
    Callback = function(v)
        Settings.AutoArrest = v
    end,
})
CombatTab:CreateToggle({
    Name = "Auto Kill",
    CurrentValue = false,
    Flag = "AutoKill",
    Callback = function(v)
        Settings.AutoKill = v
    end,
})

-- Player Tab
PlayerTab:CreateSection("Player Options")
PlayerTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(v)
        Settings.ESP = v
    end,
})
PlayerTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(v)
        Settings.NoClip = v
    end,
})
PlayerTab:CreateToggle({
    Name = "Speed",
    CurrentValue = false,
    Flag = "Speed",
    Callback = function(v)
        Settings.Speed = v
    end,
})
PlayerTab:CreateToggle({
    Name = "Jump",
    CurrentValue = false,
    Flag = "Jump",
    Callback = function(v)
        Settings.Jump = v
    end,
})
PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(v)
        Settings.Fly = v
    end,
})
PlayerTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Flag = "InfiniteStamina",
    Callback = function(v)
        Settings.InfiniteStamina = v
    end,
})

-- World Tab
WorldTab:CreateSection("World Mods")
WorldTab:CreateToggle({
    Name = "Remove Doors",
    CurrentValue = false,
    Flag = "RemoveDoors",
    Callback = function(v)
        Settings.RemoveDoors = v
        if v then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("door") then
                    obj:Destroy()
                end
            end
            for _, model in pairs(workspace:GetChildren()) do
                if model:IsA("Model") and model.Name:lower():find("door") then
                    model:Destroy()
                end
            end
        end
    end,
})
WorldTab:CreateToggle({
    Name = "Auto Escape",
    CurrentValue = false,
    Flag = "AutoEscape",
    Callback = function(v)
        Settings.AutoEscape = v
    end,
})
WorldTab:CreateToggle({
    Name = "Auto Farm (Cafeteria)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(v)
        Settings.AutoFarm = v
    end,
})

-- ESP System
local espObjects = {}
local function CreateESP(player)
    if espObjects[player] then return end
    if player == LocalPlayer then return end
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1

    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = Color3.fromRGB(255, 255, 255)
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)

    local healthBar = Drawing.new("Line")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 0)
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
                obj.box.Color = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255, 255, 255)

                obj.nameTag.Visible = true
                obj.nameTag.Text = player.Name .. " (" .. math.floor(distance) .. "m)"
                obj.nameTag.Position = Vector2.new(pos.X, pos.Y - size*0.9 - 15)
                obj.nameTag.Color = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255, 255, 255)

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

-- Aimbot
local function GetClosestPlayer()
    local closest = nil
    local minDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

-- Fly variables
local flying = false
local flySpeed = 50

-- NoClip
local noclipEnabled = false
local noclipConn

-- Main loops
RunService.Heartbeat:Connect(function(dt)
    if Settings.ESP then
        UpdateESP()
    else
        for _, obj in pairs(espObjects) do
            obj.box.Visible = false
            obj.nameTag.Visible = false
            obj.healthBar.Visible = false
        end
    end

    if Settings.Aimbot then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = target.Character.HumanoidRootPart
            local direction = (targetRoot.Position - workspace.CurrentCamera.CFrame.Position).Unit
            local newCFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, workspace.CurrentCamera.CFrame.Position + direction)
            workspace.CurrentCamera.CFrame = newCFrame
        end
    end

    if Settings.Speed then
        Humanoid.WalkSpeed = 50
    else
        Humanoid.WalkSpeed = 16
    end

    if Settings.Jump then
        Humanoid.JumpPower = 100
    else
        Humanoid.JumpPower = 50
    end

    if Settings.InfiniteStamina then
        Humanoid.Stamina = 100
    end

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

    if Settings.NoClip then
        if not noclipEnabled then
            noclipEnabled = true
            noclipConn = RunService.Stepped:Connect(function()
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end
    else
        if noclipEnabled then
            noclipEnabled = false
            if noclipConn then noclipConn:Disconnect() end
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end

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
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
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

    if Settings.AutoEscape then
        local escapePos = Vector3.new(-500, 10, 1200)
        local dist = (RootPart.Position - escapePos).Magnitude
        if dist > 5 then
            local direction = (escapePos - RootPart.Position).Unit
            RootPart.CFrame = RootPart.CFrame + direction * 20 * dt
        end
    end

    if Settings.AutoFarm then
        local cafeteriaPos = Vector3.new(0, 10, 1100)
        local dist = (RootPart.Position - cafeteriaPos).Magnitude
        if dist > 5 then
            local direction = (cafeteriaPos - RootPart.Position).Unit
            RootPart.CFrame = RootPart.CFrame + direction * 20 * dt
        else
            VirtualUser:ClickOnScreen()
        end
    end
end)

-- Character respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end)

-- Initial ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

-- Cleanup on GUI close
Rayfield:Notify({
    Title = "Yuno Hub",
    Content = "Welcome to Yuno Hub!",
    Duration = 5,
})