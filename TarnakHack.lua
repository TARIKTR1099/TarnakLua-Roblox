local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local Colors = {
    Background = Color3.fromRGB(30,30,30),
    Section = Color3.fromRGB(45,45,45),
    Accent = Color3.fromRGB(255, 100, 100),
    TextPrimary = Color3.fromRGB(240,240,240),
    TextSecondary = Color3.fromRGB(180,180,180),
    ToggleOn = Color3.fromRGB(100,200,100),
    ToggleOff = Color3.fromRGB(200,50,50),
    SliderTrack = Color3.fromRGB(70,70,70),
    SliderFill = Color3.fromRGB(255,100,100),
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TarnakGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local function createLabel(text,parent,posY)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,-20,0,25)
    label.Position = UDim2.new(0,10,posY,0)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 16
    label.TextColor3 = Colors.TextPrimary
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function createTextBox(placeholder,parent,posY)
    local box = Instance.new("TextBox")
    box.PlaceholderText = placeholder
    box.ClearTextOnFocus = false
    box.Size = UDim2.new(1,-20,0,30)
    box.Position = UDim2.new(0,10,posY,0)
    box.BackgroundColor3 = Colors.Section
    box.TextColor3 = Colors.TextPrimary
    box.Font = Enum.Font.SourceSansSemibold
    box.TextSize = 16
    box.Parent = parent
    return box
end

local function createButton(text,parent,posY,width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,width or 150,0,30)
    btn.Position = UDim2.new(0,10,posY,0)
    btn.BackgroundColor3 = Colors.Section
    btn.TextColor3 = Colors.TextPrimary
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 18
    btn.Text = text
    btn.Parent = parent
    return btn
end

local function createToggle(labelText, parent, default, posY, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Colors.Section
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0, 0, posY, 0)
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = labelText
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 18
    label.TextColor3 = Colors.TextPrimary
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 25)
    toggleBtn.Position = UDim2.new(0.8, 0, 0.22, 0)
    toggleBtn.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.TextSize = 14
    toggleBtn.TextColor3 = Colors.TextPrimary
    toggleBtn.Parent = frame

    local toggled = default

    toggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        toggleBtn.BackgroundColor3 = toggled and Colors.ToggleOn or Colors.ToggleOff
        toggleBtn.Text = toggled and "ON" or "OFF"
        callback(toggled)
    end)

    return frame, function() return toggled end
end

local function createSlider(labelText, min, max, default, parent, posY, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = Colors.Section
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0, 0, posY, 0)
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = labelText .. ": " .. tostring(default)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 18
    label.TextColor3 = Colors.TextPrimary
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 20)
    sliderFrame.Position = UDim2.new(0, 10, 0, 26)
    sliderFrame.BackgroundColor3 = Colors.SliderTrack
    sliderFrame.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.SliderFill
    fill.Parent = sliderFrame

    local dragging = false

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    sliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            local value = min + pos * (max - min)
            label.Text = labelText .. ": " .. string.format("%.1f", value)
            callback(value)
        end
    end)

    return frame
end

-- Ana GUI
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 550)
MainFrame.Position = UDim2.new(0.5, -190, 0.3, 0)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Colors.Section
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "Tarnak Gelişmiş Hileler"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 22
TitleLabel.TextColor3 = Colors.Accent
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 5)
TitleLabel.Size = UDim2.new(0.7, 0, 0, 30)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 24
CloseButton.TextColor3 = Colors.Accent
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(0.9, 0, 0, 0)
CloseButton.Size = UDim2.new(0, 40, 1, 0)
CloseButton.Parent = TitleBar

CloseButton.MouseButton1Click:Connect(function()
    -- Normalleşme fonksiyonu
    stopFly()
    stopSpectator()
    toggleAnimations(false)
    toggleBug(false)
    toggleXRay(false)
    ScreenGui:Destroy()
end)

local SideMenu = Instance.new("Frame")
SideMenu.BackgroundColor3 = Colors.Section
SideMenu.Size = UDim2.new(0, 120, 1, -40)
SideMenu.Position = UDim2.new(0, 0, 0, 40)
SideMenu.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 8)
SideLayout.FillDirection = Enum.FillDirection.Vertical
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = SideMenu

local ContentFrame = Instance.new("Frame")
ContentFrame.BackgroundColor3 = Colors.Background
ContentFrame.Size = UDim2.new(1, -120, 1, -40)
ContentFrame.Position = UDim2.new(0, 120, 0, 40)
ContentFrame.Parent = MainFrame
ContentFrame.ClipsDescendants = true

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentFrame

local Pages = {}
local CurrentPage

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 6
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    Pages[name] = page
    return page
end

local function switchPage(name)
    if CurrentPage then CurrentPage.Visible = false end
    local page = Pages[name]
    if page then
        page.Visible = true
        CurrentPage = page
    end
end

local function createSideButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.BackgroundColor3 = Colors.Background
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 20
    btn.TextColor3 = Colors.TextPrimary
    btn.Parent = SideMenu

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Section}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Background}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        switchPage(name)
    end)

    return btn
end

local pageNames = {
    "Uçma & İzleyici",
    "Işınlanma",
    "Sinek Modu",
    "Animasyonlar",
    "XRay",
    "Aimbot & ESP",
    "Spam & AutoClicker",
    "Loadstring",
    "Pusula"
}

for _, name in ipairs(pageNames) do
    createSideButton(name)
    createPage(name)
end
switchPage("Uçma & İzleyici")

-- Uçma & İzleyici Modu

local flyPage = Pages["Uçma & İzleyici"]

local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local maxspeed = 50
local speedv = 0

local Flying = false
local FlySpeed = 80
local BodyVelocity
local FlyConnection
local Keys = {W=false, A=false, S=false, D=false, Space=false, LeftShift=false}

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Keys[input.KeyCode.Name] ~= nil then Keys[input.KeyCode.Name] = true end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if Keys[input.KeyCode.Name] ~= nil then Keys[input.KeyCode.Name] = false end
end)

local verticalMoveDir = 0

local function updateFlyVelocity()
    if not Flying or not BodyVelocity then return end
    local cam = workspace.CurrentCamera
    local moveVec = Vector3.new(0,0,0)
    if Keys.W then moveVec = moveVec + cam.CFrame.LookVector end
    if Keys.S then moveVec = moveVec - cam.CFrame.LookVector end
    if Keys.A then moveVec = moveVec - cam.CFrame.RightVector end
    if Keys.D then moveVec = moveVec + cam.CFrame.RightVector end
    if Keys.Space then verticalMoveDir = 1 end
    if Keys.LeftShift then verticalMoveDir = -1 end
    if not (Keys.Space or Keys.LeftShift) then verticalMoveDir = 0 end

    if moveVec.Magnitude > 0 or verticalMoveDir ~= 0 then
        BodyVelocity.Velocity = moveVec.Unit * FlySpeed + Vector3.new(0, verticalMoveDir * math.max(5, FlySpeed / 2), 0)
    else
        BodyVelocity.Velocity = Vector3.new(0,0,0)
    end
end

local function startFly()
    if Flying then return end
    Flying = true
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
    BodyVelocity.Parent = RootPart
    BodyVelocity.Velocity = Vector3.new(0,0,0)
    Humanoid.PlatformStand = true
    FlyConnection = RunService.Heartbeat:Connect(updateFlyVelocity)
end

local function stopFly()
    if not Flying then return end
    Flying = false
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    Humanoid.PlatformStand = false
end

local flyToggle, flyGet = createToggle("Uçmayı Aç/Kapa", flyPage, false, 0, function(state)
    if state then
        startFly()
    else
        stopFly()
    end
end)

local flySpeedSlider = createSlider("Uçma Hızı", 10, 500, FlySpeed, flyPage, 0.1, function(value)
    FlySpeed = value
end)

-- İzleyici modu uçuşun içinde çarpışma kapatma ve hız ayarı
local SpectatorOn = false
local SpectatorSpeed = 120

local spectatorToggle, spectatorGet = createToggle("İzleyici Modu (Uçma + İçinden Geçme)", flyPage, false, 0.25, function(state)
    SpectatorOn = state
    if SpectatorOn then
        if not flyGet() then
            flyToggle(true)
        end
        -- Çarpışmayı kapat
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part ~= RootPart then
                part.CanCollide = false
            end
        end
    else
        -- Çarpışmayı aç
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part ~= RootPart then
                part.CanCollide = true
            end
        end
    end
end)

local spectatorSpeedLabel = createLabel("İzleyici Hızı: " .. SpectatorSpeed, flyPage, 0.32)
local spectatorSpeedFrame = Instance.new("Frame")
spectatorSpeedFrame.Size = UDim2.new(1, -20, 0, 30)
spectatorSpeedFrame.Position = UDim2.new(0, 10, 0.37, 0)
spectatorSpeedFrame.BackgroundColor3 = Colors.Section
spectatorSpeedFrame.Parent = flyPage

local minusBtn = Instance.new("TextButton")
minusBtn.Text = "-"
minusBtn.Size = UDim2.new(0, 40, 1, 0)
minusBtn.Font = Enum.Font.SourceSansBold
minusBtn.TextSize = 24
minusBtn.TextColor3 = Colors.Accent
minusBtn.BackgroundColor3 = Colors.Background
minusBtn.Parent = spectatorSpeedFrame

local plusBtn = Instance.new("TextButton")
plusBtn.Text = "+"
plusBtn.Size = UDim2.new(0, 40, 1, 0)
plusBtn.Position = UDim2.new(1, -40, 0, 0)
plusBtn.Font = Enum.Font.SourceSansBold
plusBtn.TextSize = 24
plusBtn.TextColor3 = Colors.Accent
plusBtn.BackgroundColor3 = Colors.Background
plusBtn.Parent = spectatorSpeedFrame

local speedValueLabel = Instance.new("TextLabel")
speedValueLabel.Text = tostring(SpectatorSpeed)
speedValueLabel.Font = Enum.Font.SourceSansSemibold
speedValueLabel.TextSize = 20
speedValueLabel.TextColor3 = Colors.TextPrimary
speedValueLabel.BackgroundTransparency = 1
speedValueLabel.Position = UDim2.new(0, 50, 0, 0)
speedValueLabel.Size = UDim2.new(1, -100, 1, 0)
speedValueLabel.Parent = spectatorSpeedFrame

minusBtn.MouseButton1Click:Connect(function()
    SpectatorSpeed = SpectatorSpeed - 10
    if SpectatorSpeed < 1 then SpectatorSpeed = 1 end
    speedValueLabel.Text = tostring(SpectatorSpeed)
end)

plusBtn.MouseButton1Click:Connect(function()
    SpectatorSpeed = SpectatorSpeed + 10
    speedValueLabel.Text = tostring(SpectatorSpeed)
end)

RunService.Heartbeat:Connect(function()
    if SpectatorOn and Flying and BodyVelocity then
        local cam = workspace.CurrentCamera
        local moveVec = Vector3.new(0,0,0)
        if Keys.W then moveVec = moveVec + cam.CFrame.LookVector end
        if Keys.S then moveVec = moveVec - cam.CFrame.LookVector end
        if Keys.A then moveVec = moveVec - cam.CFrame.RightVector end
        if Keys.D then moveVec = moveVec + cam.CFrame.RightVector end
        if Keys.Space then moveVec = moveVec + Vector3.new(0,1,0) end
        if Keys.LeftShift then moveVec = moveVec - Vector3.new(0,1,0) end
        if moveVec.Magnitude > 0 then
            BodyVelocity.Velocity = moveVec.Unit * SpectatorSpeed
        else
            BodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- Animasyonlar
local animPage = Pages["Animasyonlar"]
local animationsOff = false
local function stopAllAnimations()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, anim in pairs(hum:GetPlayingAnimationTracks()) do
                    anim:Stop()
                end
            end
            for _, animator in pairs(plr.Character:GetDescendants()) do
                if animator:IsA("Animator") then
                    for _, anim in pairs(animator:GetPlayingAnimationTracks()) do
                        anim:Stop()
                    end
                end
            end
        end
    end
end

local animToggle, animGet = createToggle("Animasyonları Kapat (Tüm Karakterler)", animPage, false, 0, function(state)
    animationsOff = state
    if animationsOff then
        stopAllAnimations()
    end
end)

Players.PlayerAdded:Connect(function(plr)
    if animationsOff and plr.Character then
        stopAllAnimations()
    end
end)

-- Işınlanma
local tpPage = Pages["Işınlanma"]

createLabel("X Koordinatı (zorunlu)", tpPage, 0.05)
local TPXInput = createTextBox("", tpPage, 0.1)

createLabel("Y Koordinatı (opsiyonel)", tpPage, 0.18)
local TPYInput = createTextBox("", tpPage, 0.23)

createLabel("Z Koordinatı (opsiyonel)", tpPage, 0.31)
local TPZInput = createTextBox("", tpPage, 0.36)

local function tpTo(x,y,z)
    if not x then return end
    y = y or RootPart.Position.Y
    z = z or RootPart.Position.Z
    RootPart.CFrame = CFrame.new(x,y,z)
end

local tpButton = createButton("Işınlan", tpPage, 0.43)
tpButton.MouseButton1Click:Connect(function()
    local x = tonumber(TPXInput.Text)
    if not x then warn("X koordinatı zorunlu!") return end
    local y = tonumber(TPYInput.Text)
    local z = tonumber(TPZInput.Text)
    tpTo(x,y,z)
end)

-- Sinek Modu
local bugPage = Pages["Sinek Modu"]
local BugAccessory -- Kullanıcının takacağı aksesuar
local BugActive = false

local bugToggle, bugGet = createToggle("Sinek Modu (Aksesuar Takılınca Aktif)", bugPage, false, 0, function(state)
    BugActive = state
    if BugActive then
        -- Aksesuarı tak
        if not BugAccessory then
            BugAccessory = Instance.new("Part")
            BugAccessory.Name = "BugAccessory"
            BugAccessory.Size = Vector3.new(1,1,1)
            BugAccessory.Shape = Enum.PartType.Ball
            BugAccessory.Anchored = false
            BugAccessory.CanCollide = false
            BugAccessory.Material = Enum.Material.Neon
            BugAccessory.Color = Color3.fromRGB(255, 255, 0)
            BugAccessory.Parent = Character
            BugAccessory.Transparency = 0.7

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = Character.Head
            weld.Part1 = BugAccessory
            weld.Parent = BugAccessory
            BugAccessory.CFrame = Character.Head.CFrame * CFrame.new(0,1,0)
        end
    else
        -- Aksesuarı çıkar
        if BugAccessory then
            BugAccessory:Destroy()
            BugAccessory = nil
        end
    end
end)

-- XRay
local xrayPage = Pages["XRay"]
local XRayOn = false
local TransparentParts = {}

local xrayToggle, xrayGet = createToggle("XRay", xrayPage, false, 0, function(state)
    XRayOn = state
    if XRayOn then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 and part.CanCollide then
                TransparentParts[part] = {part.Transparency, part.CanCollide}
                part.Transparency = 0.5
                part.CanCollide = false
            end
        end
    else
        for part, props in pairs(TransparentParts) do
            if part and part:IsA("BasePart") then
                part.Transparency = props[1]
                part.CanCollide = props[2]
            end
        end
        TransparentParts = {}
    end
end)

-- Aimbot & ESP
local aimbotPage = Pages["Aimbot & ESP"]
local AimbotOn = false
local ESPOn = false
local AimPartName = "Head"

local aimbotToggle, aimbotGet = createToggle("Aimbot", aimbotPage, false, 0, function(state)
    AimbotOn = state
end)

local espToggle, espGet = createToggle("ESP", aimbotPage, false, 0.07, function(state)
    ESPOn = state
end)

local function getClosestTarget()
    local closestDist = math.huge
    local target
    local cam = workspace.CurrentCamera
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(AimPartName) then
            local part = plr.Character[AimPartName]
            local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    target = part
                end
            end
        end
    end
    return target
end

RunService.Heartbeat:Connect(function()
    if AimbotOn then
        local target = getClosestTarget()
        if target and target.Parent and target.Parent:FindFirstChild("HumanoidRootPart") then
            local cam = workspace.CurrentCamera
            local camPos = cam.CFrame.Position
            local targetPos = target.Position
            local direction = (targetPos - camPos).Unit
            -- Kamera sarsıntısını engellemek için yumuşatılmış dönüş
            local newCFrame = CFrame.new(camPos, camPos + direction)
            workspace.CurrentCamera.CFrame = newCFrame
        end
    end

    if ESPOn then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                if not hrp:FindFirstChild("TarnakESP") then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "TarnakESP"
                    box.Adornee = hrp
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Size = Vector3.new(4, 5, 4)
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                    box.Transparency = 0.5
                    box.Parent = hrp
                end
            end
        end
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                local esp = hrp:FindFirstChild("TarnakESP")
                if esp then esp:Destroy() end
            end
        end
    end
end)

-- Spam & AutoClicker
local spamPage = Pages["Spam & AutoClicker"]

local SpamKey = Enum.KeyCode.Unknown
local SpamDelay = 0
local SpamMsg = "Tarnak Spam Mesaj"
local SpamActive = false

local AutoClickerKey = Enum.KeyCode.Unknown
local AutoClickerDelay = 0
local AutoClickerActive = false

local SpamLabel = createLabel("Spam Mesaj Tuşu: Yok", spamPage, 0.05)
local SpamMsgBox = createTextBox("Spam Mesajı", spamPage, 0.10)
SpamMsgBox.Text = SpamMsg

local SpamDelayBox = createTextBox("Spam Gecikmesi (saniye, 0= sürekli)", spamPage, 0.17)
SpamDelayBox.Text = tostring(SpamDelay)

local SpamSetKeyBtn = createButton("Spam Tuşunu Ayarla", spamPage, 0.24, 180)

SpamSetKeyBtn.MouseButton1Click:Connect(function()
    SpamLabel.Text = "Bir tuşa basın..."
    local con
    con = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        SpamKey = input.KeyCode
        SpamLabel.Text = "Spam Mesaj Tuşu: " .. tostring(SpamKey.Name)
        con:Disconnect()
    end)
end)

SpamMsgBox.FocusLost:Connect(function(enter)
    if enter then
        SpamMsg = SpamMsgBox.Text
    end
end)

SpamDelayBox.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(SpamDelayBox.Text)
        if val and val >= 0 then
            SpamDelay = val
        else
            SpamDelayBox.Text = tostring(SpamDelay)
        end
    end
end)

local AutoClickerLabel = createLabel("Otomatik Tıklama Tuşu: Yok", spamPage, 0.33)
local AutoClickerDelayBox = createTextBox("Tıklama Gecikmesi (saniye)", spamPage, 0.38)
AutoClickerDelayBox.Text = tostring(AutoClickerDelay)

local AutoClickerSetKeyBtn = createButton("Otomatik Tıklama Tuşunu Ayarla", spamPage, 0.45, 250)

AutoClickerSetKeyBtn.MouseButton1Click:Connect(function()
    AutoClickerLabel.Text = "Bir tuşa basın..."
    local con
    con = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        AutoClickerKey = input.KeyCode
        AutoClickerLabel.Text = "Otomatik Tıklama Tuşu: " .. tostring(AutoClickerKey.Name)
        con:Disconnect()
    end)
end)

AutoClickerDelayBox.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(AutoClickerDelayBox.Text)
        if val and val >= 0 then
            AutoClickerDelay = val
        else
            AutoClickerDelayBox.Text = tostring(AutoClickerDelay)
        end
    end
end)

spawn(function()
    while true do
        wait(0.1)
        if SpamKey ~= Enum.KeyCode.Unknown and UserInputService:IsKeyDown(SpamKey) then
            if SpamDelay == 0 or (tick() % SpamDelay) < 0.1 then
                local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if chat then
                    local SayMessageRequest = chat:FindFirstChild("SayMessageRequest")
                    if SayMessageRequest then
                        SayMessageRequest:FireServer(SpamMsg, "All")
                    end
                end
            end
        end
        if AutoClickerKey ~= Enum.KeyCode.Unknown and UserInputService:IsKeyDown(AutoClickerKey) then
            if AutoClickerDelay == 0 or (tick() % AutoClickerDelay) < 0.1 then
                LocalPlayer:GetMouse().Button1Down:Fire()
            end
        end
    end
end)

-- Loadstring
local loadstringPage = Pages["Loadstring"]

local loadBtn1 = createButton("InfiniteYield Aç", loadstringPage, 0.05, 220)
local loadBtn2 = createButton("Dış Script Aç", loadstringPage, 0.12, 220)
local loadBtn3 = createButton("Cmd Aç", loadstringPage, 0.19, 220)

loadBtn1.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)
loadBtn2.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dertonware/scriptasda/refs/heads/main/scriptlua", true))()
end)
loadBtn3.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/cmd/main/main.lua"))()
end)

-- Pusula
local compassPage = Pages["Pusula"]
local CompassLabel = createLabel("Pozisyon: ", compassPage, 0.05)
local TPXLabel = createLabel("X Koordinatı (ışınlanma için)", compassPage, 0.12)
local TPXBox = createTextBox("", compassPage, 0.17)

local TPYLabel = createLabel("Y Koordinatı (ışınlanma için)", compassPage, 0.25)
local TPYBox = createTextBox("", compassPage, 0.30)

local TPZLabel = createLabel("Z Koordinatı (ışınlanma için)", compassPage, 0.38)
local TPZBox = createTextBox("", compassPage, 0.43)

local TPBtn = createButton("Işınlan", compassPage, 0.50)
TPBtn.MouseButton1Click:Connect(function()
    local x = tonumber(TPXBox.Text)
    if not x then warn("X koordinatı zorunlu!") return end
    local y = tonumber(TPYBox.Text)
    local z = tonumber(TPZBox.Text)
    RootPart.CFrame = CFrame.new(x, y or RootPart.Position.Y, z or RootPart.Position.Z)
end)

RunService.Heartbeat:Connect(function()
    if RootPart and RootPart.Parent then
        local pos = RootPart.Position
        CompassLabel.Text = string.format("Pozisyon: X: %.1f  Y: %.1f  Z: %.1f", pos.X, pos.Y, pos.Z)
    end
end)

-- Normalleşme fonksiyonu (tüm modlar kapatılır, özellikler sıfırlanır)
local function normalizeAll()
    stopFly()
    if SpectatorOn then
        spectatorToggle(false)
    end
    if animationsOff then
        animToggle(false)
    end
    if BugActive then
        bugToggle(false)
    end
    if XRayOn then
        xrayToggle(false)
    end
    if AimbotOn then
        aimbotToggle(false)
    end
    if ESPOn then
        espToggle(false)
    end
    SpamKey = Enum.KeyCode.Unknown
    AutoClickerKey = Enum.KeyCode.Unknown
end

-- Karakter spawn olunca normalleştir
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    normalizeAll()
end)