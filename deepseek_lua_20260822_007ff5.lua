-- Yuno Hub - Prison Life Delta
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Settings
local Settings = {
    ESP = false,
    Teleport = false,
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

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YunoHub"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 450)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "Yuno Hub"
Title.TextColor3 = Color3.fromRGB(255, 200, 50)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = MainFrame

-- Tabs
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 30)
TabFrame.Position = UDim2.new(0, 0, 0, 35)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local tabs = {}
local currentTab = nil
local tabButtons = {}

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = TabFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -10, 1, -40)
    content.Position = UDim2.new(0, 5, 0, 40)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollBarThickness = 4
    content.Visible = false
    content.Parent = MainFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    local function show()
        for _, c in pairs(tabs) do
            c.Visible = false
        end
        content.Visible = true
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        end
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        currentTab = name
    end

    btn.MouseButton1Click:Connect(show)
    table.insert(tabButtons, btn)
    tabs[name] = content
    if not currentTab then show() end
    return content
end

-- Functions to create elements inside tabs
local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function AddToggle(parent, text, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.2, 0, 0.8, 0)
    toggle.Position = UDim2.new(0.8, 0, 0.1, 0)
    toggle.Text = getter() and "On" or "Off"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.BackgroundColor3 = getter() and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    toggle.BorderSizePixel = 0
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 12
    toggle.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = toggle

    toggle.MouseButton1Click:Connect(function()
        setter(not getter())
        toggle.Text = getter() and "On" or "Off"
        toggle.BackgroundColor3 = getter() and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    end)
    return toggle
end

local function AddLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.95, 0, 0, 20)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Parent = parent
    return lbl
end

-- Create Tabs
local teleportTab = CreateTab("Teleports")
local combatTab = CreateTab("Combat")
local playerTab = CreateTab("Player")
local worldTab = CreateTab("World")

-- Teleports
AddLabel(teleportTab, "Locations")
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
    AddButton(teleportTab, tp.name, function()
        if RootPart then
            RootPart.CFrame = CFrame.new(tp.pos)
        end
    end)
end

-- Combat
AddLabel(combatTab, "Combat Options")
AddToggle(combatTab, "Aimbot", function() return Settings.Aimbot end, function(v) Settings.Aimbot = v end)
AddToggle(combatTab, "Auto Arrest", function() return Settings.AutoArrest end, function(v) Settings.AutoArrest = v end)
AddToggle(combatTab, "Auto Kill", function() return Settings.AutoKill end, function(v) Settings.AutoKill = v end)

-- Player
AddLabel(playerTab, "Player Options")
AddToggle(playerTab, "ESP", function() return Settings.ESP end, function(v) Settings.ESP = v end)
AddToggle(playerTab, "NoClip", function() return Settings.NoClip end, function(v) Settings.NoClip = v end)
AddToggle(playerTab, "Speed", function() return Settings.Speed end, function(v) Settings.Speed = v end)
AddToggle(playerTab, "Jump", function() return Settings.Jump end, function(v) Settings.Jump = v end)
AddToggle(playerTab, "Fly", function() return Settings.Fly end, function(v) Settings.Fly = v end)
AddToggle(playerTab, "Infinite Stamina", function() return Settings.InfiniteStamina end, function(v) Settings.InfiniteStamina = v end)

-- World
AddLabel(worldTab, "World Mods")
AddToggle(worldTab, "Remove Doors", function() return Settings.RemoveDoors end, function(v) 
    Settings.RemoveDoors = v
    if v then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("door") then
                obj:Destroy()
            end
        end
        -- Also remove any model named Door
        for _, model in pairs(workspace:GetChildren()) do
            if model:IsA("Model") and model.Name:lower():find("door") then
                model:Destroy()
            end
        end
    end
end)
AddToggle(worldTab, "Auto Escape", function() return Settings.AutoEscape end, function(v) Settings.AutoEscape = v end)
AddToggle(worldTab, "Auto Farm (Cafeteria)", function() return Settings.AutoFarm end, function(v) Settings.AutoFarm = v end)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 4)
corner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ESP
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
                local yOffset = size / 2
                local xOffset = size / 2

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

-- Auto Farm / Escape logic
local farmTarget = nil
local escapeTarget = nil

-- Main loops
RunService.Heartbeat:Connect(function(dt)
    -- ESP
    if Settings.ESP then
        UpdateESP()
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
            local newCFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, workspace.CurrentCamera.CFrame.Position + direction)
            workspace.CurrentCamera.CFrame = newCFrame
        end
    end

    -- Speed
    if Settings.Speed then
        Humanoid.WalkSpeed = 50
    else
        Humanoid.WalkSpeed = 16
    end

    -- Jump
    if Settings.Jump then
        Humanoid.JumpPower = 100
    else
        Humanoid.JumpPower = 50
    end

    -- Infinite Stamina
    if Settings.InfiniteStamina then
        Humanoid.Stamina = 100
    end

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

    -- Fly
    if Settings.Fly then
        if not flying then
            flying = true
            Humanoid.PlatformStand = true
        end
        local moveDirection = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
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

    -- Auto Escape (walk to escape zone)
    if Settings.AutoEscape then
        local escapePos = Vector3.new(-500, 10, 1200)
        local dist = (RootPart.Position - escapePos).Magnitude
        if dist > 5 then
            local direction = (escapePos - RootPart.Position).Unit
            RootPart.CFrame = RootPart.CFrame + direction * 20 * dt
        end
    end

    -- Auto Farm (Cafeteria - collect food/drink)
    if Settings.AutoFarm then
        local cafeteriaPos = Vector3.new(0, 10, 1100)
        local dist = (RootPart.Position - cafeteriaPos).Magnitude
        if dist > 5 then
            local direction = (cafeteriaPos - RootPart.Position).Unit
            RootPart.CFrame = RootPart.CFrame + direction * 20 * dt
        else
            -- Simulate clicking on food tray or eating
            -- Not easily automated, but we can try to use VirtualUser to interact
            -- Or just loop
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

-- Initial ESP
for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

-- Cleanup
game:GetService("RunService").RenderStepped:Connect(function()
    if not ScreenGui.Parent then
        for _, obj in pairs(espObjects) do
            obj.box:Remove()
            obj.nameTag:Remove()
            obj.healthBar:Remove()
        end
        espObjects = {}
        if noclipConn then noclipConn:Disconnect() end
    end
end)