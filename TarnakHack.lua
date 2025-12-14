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
    Background = Color3.fromRGB(25,25,25),
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

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 480)
MainFrame.Position = UDim2.new(0.5, -290, 0.3, 0)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.CanResize = true

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Colors.Section
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "Tarnak Gelişmiş Hileler"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 20
TitleLabel.TextColor3 = Colors.Accent
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 3)
TitleLabel.Size = UDim2.new(0.6, 0, 0, 30)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Text = "−"
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 24
MinimizeButton.TextColor3 = Colors.Accent
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Position = UDim2.new(1, -80, 0, 0)
MinimizeButton.Size = UDim2.new(0, 40, 1, 0)
MinimizeButton.Parent = TitleBar
MinimizeButton.Name = "MinimizeBtn"

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 24
CloseButton.TextColor3 = Colors.Accent
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.Size = UDim2.new(0, 40, 1, 0)
CloseButton.Parent = TitleBar
CloseButton.Name = "CloseBtn"

local function normalizeAll()
    stopFly()
    if SpectatorOn then stopSpectator() end
    if animationsOff then toggleAnimations(false) end
    if BugActive then toggleBug(false) end
    if XRayOn then toggleXRay(false) end
    if AimbotOn then AimbotOn = false end
    if ESPOn then ESPOn = false end
end

CloseButton.MouseButton1Click:Connect(function()
    normalizeAll()
    ScreenGui:Destroy()
end)

local minimized = false
local originalSize, originalPos

MinimizeButton.MouseButton1Click:Connect(function()
    if not minimized then
        originalSize = MainFrame.Size
        originalPos = MainFrame.Position
        MainFrame.Size = UDim2.new(0, 150, 0, 36)
        MainFrame.Position = UDim2.new(1, -160, 0.3, 0)
        minimized = true
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = originalSize
        MainFrame.Position = originalPos
        minimized = false
        MinimizeButton.Text = "−"
    end
end)

local SideMenu = Instance.new("Frame")
SideMenu.BackgroundColor3 = Colors.Section
SideMenu.Size = UDim2.new(0, 140, 1, -36)
SideMenu.Position = UDim2.new(0, 0, 0, 36)
SideMenu.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 8)
SideLayout.FillDirection = Enum.FillDirection.Vertical
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = SideMenu

local ContentFrame = Instance.new("Frame")
ContentFrame.BackgroundColor3 = Colors.Background
ContentFrame.Size = UDim2.new(1, -140, 1, -36)
ContentFrame.Position = UDim2.new(0, 140, 0, 36)
ContentFrame.Parent = MainFrame
ContentFrame.ClipsDescendants = true

local Pages = {}
local CurrentPage

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 5
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = ContentFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
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
    btn.Size = UDim2.new(1, -10, 0, 45)
    btn.BackgroundColor3 = Colors.Background
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 18
    btn.TextColor3 = Colors.TextPrimary
    btn.Parent = SideMenu

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Section}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Background}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        switchPage(name)
    end)

    return btn
end

createSideButton("Hileler")
createSideButton("Loadstring")
createPage("Hileler")
createPage("Loadstring")
switchPage("Hileler")

local hileleriPage = Pages["Hileler"]
local loadstringPage = Pages["Loadstring"]

-- Collapsible Section Fonksiyonu
local function createSection(title, parent)
    local sectionContainer = Instance.new("Frame")
    sectionContainer.Size = UDim2.new(1, 0, 0, 0)
    sectionContainer.BackgroundTransparency = 1
    sectionContainer.Parent = parent

    local sectionHeader = Instance.new("TextButton")
    sectionHeader.Size = UDim2.new(1, 0, 0, 28)
    sectionHeader.BackgroundColor3 = Colors.Section
    sectionHeader.BorderSizePixel = 0
    sectionHeader.Text = "▼ " .. title
    sectionHeader.Font = Enum.Font.SourceSansSemibold
    sectionHeader.TextSize = 16
    sectionHeader.TextColor3 = Colors.Accent
    sectionHeader.Parent = sectionContainer

    local sectionContent = Instance.new("Frame")
    sectionContent.Size = UDim2.new(1, 0, 0, 0)
    sectionContent.BackgroundTransparency = 1
    sectionContent.Parent = sectionContainer

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = sectionContent

    local expanded = true

    sectionHeader.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            sectionHeader.Text = "▼ " .. title
            sectionContent.Visible = true
        else
            sectionHeader.Text = "▶ " .. title
            sectionContent.Visible = false
        end
    end)

    return sectionContainer, sectionContent
end

-- Uçma Ayarları Bölümü
local flySection, flyContent = createSection("Uçma ve Ayarları", hileleriPage)

local ctrl = {f = 0, b = 0, l = 0, r = 0}
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
    if Keys.Space then moveVec = moveVec + Vector3.new(0,1,0) end
    if Keys.LeftShift then moveVec = moveVec - Vector3.new(0,1,0) end

    if moveVec.Magnitude > 0 then
        BodyVelocity.Velocity = moveVec.Unit * FlySpeed
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

-- Uçma Başlat Butonu
local flyButtonFrame = Instance.new("Frame")
flyButtonFrame.Size = UDim2.new(1, 0, 0, 30)
flyButtonFrame.BackgroundTransparency = 1
flyButtonFrame.Parent = flyContent

local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.45, 0, 1, 0)
flyButton.Position = UDim2.new(0, 0, 0, 0)
flyButton.BackgroundColor3 = Colors.ToggleOff
flyButton.BorderSizePixel = 0
flyButton.Text = "UÇMAYI AÇ"
flyButton.Font = Enum.Font.SourceSansBold
flyButton.TextSize = 14
flyButton.TextColor3 = Colors.TextPrimary
flyButton.Parent = flyButtonFrame

local flyStatus = Instance.new("TextLabel")
flyStatus.Size = UDim2.new(0.45, 0, 1, 0)
flyStatus.Position = UDim2.new(0.55, 0, 0, 0)
flyStatus.BackgroundColor3 = Colors.Section
flyStatus.BorderSizePixel = 0
flyStatus.Text = "KAPA"
flyStatus.Font = Enum.Font.SourceSansBold
flyStatus.TextSize = 14
flyStatus.TextColor3 = Colors.ToggleOff
flyStatus.Parent = flyButtonFrame

flyButton.MouseButton1Click:Connect(function()
    if not Flying then
        startFly()
        flyButton.BackgroundColor3 = Colors.ToggleOn
        flyButton.Text = "UÇMAYI KAPA"
        flyStatus.Text = "AÇ"
        flyStatus.TextColor3 = Colors.ToggleOn
    else
        stopFly()
        flyButton.BackgroundColor3 = Colors.ToggleOff
        flyButton.Text = "UÇMAYI AÇ"
        flyStatus.Text = "KAPA"
        flyStatus.TextColor3 = Colors.ToggleOff
    end
end)

-- Uçma Hızı Slider
local speedSliderFrame = Instance.new("Frame")
speedSliderFrame.Size = UDim2.new(1, 0, 0, 40)
speedSliderFrame.BackgroundColor3 = Colors.Section
speedSliderFrame.BorderSizePixel = 0
speedSliderFrame.Parent = flyContent

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -10, 0, 18)
speedLabel.Position = UDim2.new(0, 5, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Uçma Hızı: 80"
speedLabel.Font = Enum.Font.SourceSansSemibold
speedLabel.TextSize = 14
speedLabel.TextColor3 = Colors.TextPrimary
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedSliderFrame

local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(1, -10, 0, 15)
speedSlider.Position = UDim2.new(0, 5, 0, 22)
speedSlider.BackgroundColor3 = Colors.SliderTrack
speedSlider.Parent = speedSliderFrame

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new((FlySpeed - 10) / (500 - 10), 0, 1, 0)
speedFill.BackgroundColor3 = Colors.SliderFill
speedFill.Parent = speedSlider

local speedDragging = false

speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        speedDragging = true
    end
end)
speedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        speedDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if speedDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = math.clamp((input.Position.X - speedSlider.AbsolutePosition.X) / speedSlider.AbsoluteSize.X, 0, 1)
        speedFill.Size = UDim2.new(pos, 0, 1, 0)
        FlySpeed = 10 + pos * (500 - 10)
        speedLabel.Text = "Uçma Hızı: " .. string.format("%.0f", FlySpeed)
    end
end)

-- İzleyici Mod (Çarpışmayı Kapatır)
local SpectatorOn = false

local spectatorButtonFrame = Instance.new("Frame")
spectatorButtonFrame.Size = UDim2.new(1, 0, 0, 30)
spectatorButtonFrame.BackgroundTransparency = 1
spectatorButtonFrame.Parent = flyContent

local spectatorButton = Instance.new("TextButton")
spectatorButton.Size = UDim2.new(0.45, 0, 1, 0)
spectatorButton.Position = UDim2.new(0, 0, 0, 0)
spectatorButton.BackgroundColor3 = Colors.ToggleOff
spectatorButton.BorderSizePixel = 0
spectatorButton.Text = "İZLEYİCİ AÇ"
spectatorButton.Font = Enum.Font.SourceSansBold
spectatorButton.TextSize = 14
spectatorButton.TextColor3 = Colors.TextPrimary
spectatorButton.Parent = spectatorButtonFrame

local spectatorStatus = Instance.new("TextLabel")
spectatorStatus.Size = UDim2.new(0.45, 0, 1, 0)
spectatorStatus.Position = UDim2.new(0.55, 0, 0, 0)
spectatorStatus.BackgroundColor3 = Colors.Section
spectatorStatus.BorderSizePixel = 0
spectatorStatus.Text = "KAPA"
spectatorStatus.Font = Enum.Font.SourceSansBold
spectatorStatus.TextSize = 14
spectatorStatus.TextColor3 = Colors.ToggleOff
spectatorStatus.Parent = spectatorButtonFrame

local function stopSpectator()
    SpectatorOn = false
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part ~= RootPart then
            part.CanCollide = true
        end
    end
    spectatorButton.BackgroundColor3 = Colors.ToggleOff
    spectatorButton.Text = "İZLEYİCİ AÇ"
    spectatorStatus.Text = "KAPA"
    spectatorStatus.TextColor3 = Colors.ToggleOff
end

spectatorButton.MouseButton1Click:Connect(function()
    if not SpectatorOn then
        SpectatorOn = true
        if not Flying then startFly() end
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part ~= RootPart then
                part.CanCollide = false
            end
        end
        spectatorButton.BackgroundColor3 = Colors.ToggleOn
        spectatorButton.Text = "İZLEYİCİ KAPA"
        spectatorStatus.Text = "AÇ"
        spectatorStatus.TextColor3 = Colors.ToggleOn
    else
        stopSpectator()
    end
end)

-- Sinek Modu (Karakter Gizle, Küre Göster)
local BugActive = false
local BugAccessory
local bugSphere

local bugButtonFrame = Instance.new("Frame")
bugButtonFrame.Size = UDim2.new(1, 0, 0, 30)
bugButtonFrame.BackgroundTransparency = 1
bugButtonFrame.Parent = flyContent

local bugButton = Instance.new("TextButton")
bugButton.Size = UDim2.new(0.45, 0, 1, 0)
bugButton.Position = UDim2.new(0, 0, 0, 0)
bugButton.BackgroundColor3 = Colors.ToggleOff
bugButton.BorderSizePixel = 0
bugButton.Text = "SİNEK MODU AÇ"
bugButton.Font = Enum.Font.SourceSansBold
bugButton.TextSize = 14
bugButton.TextColor3 = Colors.TextPrimary
bugButton.Parent = bugButtonFrame

local bugStatus = Instance.new("TextLabel")
bugStatus.Size = UDim2.new(0.45, 0, 1, 0)
bugStatus.Position = UDim2.new(0.55, 0, 0, 0)
bugStatus.BackgroundColor3 = Colors.Section
bugStatus.BorderSizePixel = 0
bugStatus.Text = "KAPA"
bugStatus.Font = Enum.Font.SourceSansBold
bugStatus.TextSize = 14
bugStatus.TextColor3 = Colors.ToggleOff
bugStatus.Parent = bugButtonFrame

local function toggleBug(state)
    BugActive = state
    if BugActive then
        bugSphere = Instance.new("Part")
        bugSphere.Name = "BugSphere"
        bugSphere.Shape = Enum.PartType.Ball
        bugSphere.Size = Vector3.new(1, 1, 1)
        bugSphere.CanCollide = false
        bugSphere.Material = Enum.Material.Neon
        bugSphere.Color = Color3.fromRGB(255, 255, 0)
        bugSphere.Transparency = 0.4
        bugSphere.Parent = Workspace

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = Character.HumanoidRootPart
        weld.Part1 = bugSphere
        weld.Parent = bugSphere

        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
        bugButton.BackgroundColor3 = Colors.ToggleOn
        bugButton.Text = "SİNEK MODU KAPA"
        bugStatus.Text = "AÇ"
        bugStatus.TextColor3 = Colors.ToggleOn
    else
        if bugSphere then
            bugSphere:Destroy()
            bugSphere = nil
        end
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
        bugButton.BackgroundColor3 = Colors.ToggleOff
        bugButton.Text = "SİNEK MODU AÇ"
        bugStatus.Text = "KAPA"
        bugStatus.TextColor3 = Colors.ToggleOff
    end
end

bugButton.MouseButton1Click:Connect(function()
    toggleBug(not BugActive)
end)

-- Animasyon Kapatma Bölümü
local animSection, animContent = createSection("Animasyonlar", hileleriPage)
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

local function toggleAnimations(state)
    animationsOff = state
    if animationsOff then
        stopAllAnimations()
    end
end

local animButtonFrame = Instance.new("Frame")
animButtonFrame.Size = UDim2.new(1, 0, 0, 30)
animButtonFrame.BackgroundTransparency = 1
animButtonFrame.Parent = animContent

local animButton = Instance.new("TextButton")
animButton.Size = UDim2.new(0.45, 0, 1, 0)
animButton.Position = UDim2.new(0, 0, 0, 0)
animButton.BackgroundColor3 = Colors.ToggleOff
animButton.BorderSizePixel = 0
animButton.Text = "KAPA"
animButton.Font = Enum.Font.SourceSansBold
animButton.TextSize = 14
animButton.TextColor3 = Colors.TextPrimary
animButton.Parent = animButtonFrame

local animStatus = Instance.new("TextLabel")
animStatus.Size = UDim2.new(0.45, 0, 1, 0)
animStatus.Position = UDim2.new(0.55, 0, 0, 0)
animStatus.BackgroundColor3 = Colors.Section
animStatus.BorderSizePixel = 0
animStatus.Text = "KAPA"
animStatus.Font = Enum.Font.SourceSansBold
animStatus.TextSize = 14
animStatus.TextColor3 = Colors.ToggleOff
animStatus.Parent = animButtonFrame

animButton.MouseButton1Click:Connect(function()
    if not animationsOff then
        toggleAnimations(true)
        animButton.BackgroundColor3 = Colors.ToggleOn
        animButton.Text = "AÇ"
        animStatus.Text = "AÇ"
        animStatus.TextColor3 = Colors.ToggleOn
    else
        toggleAnimations(false)
        animButton.BackgroundColor3 = Colors.ToggleOff
        animButton.Text = "KAPA"
        animStatus.Text = "KAPA"
        animStatus.TextColor3 = Colors.ToggleOff
    end
end)

-- Işınlanma & Pusula Bölümü
local tpSection, tpContent = createSection("Işınlanma & Pusula", hileleriPage)

local compassLabel = Instance.new("TextLabel")
compassLabel.Size = UDim2.new(1, 0, 0, 22)
compassLabel.BackgroundTransparency = 1
compassLabel.Text = "Pozisyon: X: 0  Y: 0  Z: 0"
compassLabel.Font = Enum.Font.SourceSansSemibold
compassLabel.TextSize = 12
compassLabel.TextColor3 = Colors.TextSecondary
compassLabel.TextXAlignment = Enum.TextXAlignment.Left
compassLabel.Parent = tpContent

local tpInputFrame = Instance.new("Frame")
tpInputFrame.Size = UDim2.new(1, 0, 0, 32)
tpInputFrame.BackgroundTransparency = 1
tpInputFrame.Parent = tpContent

local function createSmallInput(placeholder, posX, parent)
    local box = Instance.new("TextBox")
    box.PlaceholderText = placeholder
    box.ClearTextOnFocus = false
    box.Size = UDim2.new(0, 50, 1, 0)
    box.Position = UDim2.new(posX, 0, 0, 0)
    box.BackgroundColor3 = Colors.Section
    box.TextColor3 = Colors.TextPrimary
    box.PlaceholderColor3 = Colors.TextSecondary
    box.Font = Enum.Font.SourceSansSemibold
    box.TextSize = 12
    box.Parent = parent
    return box
end

local tpXInput = createSmallInput("X", 0, tpInputFrame)
local tpYInput = createSmallInput("Y", 0.35, tpInputFrame)
local tpZInput = createSmallInput("Z", 0.70, tpInputFrame)

local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.new(1, 0, 0, 28)
tpButton.BackgroundColor3 = Colors.Section
tpButton.BorderSizePixel = 0
tpButton.Text = "IŞINLAN"
tpButton.Font = Enum.Font.SourceSansBold
tpButton.TextSize = 14
tpButton.TextColor3 = Colors.TextPrimary
tpButton.Parent = tpContent

tpButton.MouseButton1Click:Connect(function()
    local x = tonumber(tpXInput.Text)
    if not x then warn("X gerekli!") return end
    local y = tonumber(tpYInput.Text) or RootPart.Position.Y
    local z = tonumber(tpZInput.Text) or RootPart.Position.Z
    RootPart.CFrame = CFrame.new(x, y, z)
end)

RunService.Heartbeat:Connect(function()
    if RootPart and RootPart.Parent then
        local pos = RootPart.Position
        compassLabel.Text = string.format("Pozisyon: X: %.0f  Y: %.0f  Z: %.0f", pos.X, pos.Y, pos.Z)
    end
end)

-- XRay Bölümü
local xraySection, xrayContent = createSection("XRay", hileleriPage)
local XRayOn = false
local TransparentParts = {}

local xrayButtonFrame = Instance.new("Frame")
xrayButtonFrame.Size = UDim2.new(1, 0, 0, 30)
xrayButtonFrame.BackgroundTransparency = 1
xrayButtonFrame.Parent = xrayContent

local xrayButton = Instance.new("TextButton")
xrayButton.Size = UDim2.new(0.45, 0, 1, 0)
xrayButton.Position = UDim2.new(0, 0, 0, 0)
xrayButton.BackgroundColor3 = Colors.ToggleOff
xrayButton.BorderSizePixel = 0
xrayButton.Text = "AÇ"
xrayButton.Font = Enum.Font.SourceSansBold
xrayButton.TextSize = 14
xrayButton.TextColor3 = Colors.TextPrimary
xrayButton.Parent = xrayButtonFrame

local xrayStatus = Instance.new("TextLabel")
xrayStatus.Size = UDim2.new(0.45, 0, 1, 0)
xrayStatus.Position = UDim2.new(0.55, 0, 0, 0)
xrayStatus.BackgroundColor3 = Colors.Section
xrayStatus.BorderSizePixel = 0
xrayStatus.Text = "KAPA"
xrayStatus.Font = Enum.Font.SourceSansBold
xrayStatus.TextSize = 14
xrayStatus.TextColor3 = Colors.ToggleOff
xrayStatus.Parent = xrayButtonFrame

local function toggleXRay(state)
    XRayOn = state
    if XRayOn then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                TransparentParts[part] = part.Transparency
                part.Transparency = 0.5
            end
        end
        xrayButton.BackgroundColor3 = Colors.ToggleOn
        xrayButton.Text = "KAPA"
        xrayStatus.Text = "AÇ"
        xrayStatus.TextColor3 = Colors.ToggleOn
    else
        for part, trans in pairs(TransparentParts) do
            if part and part:IsA("BasePart") then
                part.Transparency = trans
            end
        end
        TransparentParts = {}
        xrayButton.BackgroundColor3 = Colors.ToggleOff
        xrayButton.Text = "AÇ"
        xrayStatus.Text = "KAPA"
        xrayStatus.TextColor3 = Colors.ToggleOff
    end
end

xrayButton.MouseButton1Click:Connect(function()
    toggleXRay(not XRayOn)
end)

-- Aimbot & ESP Bölümü
local aimbotSection, aimbotContent = createSection("Aimbot & ESP", hileleriPage)
local AimbotOn = false
local ESPOn = false

local aimbotButtonFrame = Instance.new("Frame")
aimbotButtonFrame.Size = UDim2.new(1, 0, 0, 30)
aimbotButtonFrame.BackgroundTransparency = 1
aimbotButtonFrame.Parent = aimbotContent

local aimbotButton = Instance.new("TextButton")
aimbotButton.Size = UDim2.new(0.45, 0, 1, 0)
aimbotButton.Position = UDim2.new(0, 0, 0, 0)
aimbotButton.BackgroundColor3 = Colors.ToggleOff
aimbotButton.BorderSizePixel = 0
aimbotButton.Text = "AÇ"
aimbotButton.Font = Enum.Font.SourceSansBold
aimbotButton.TextSize = 14
aimbotButton.TextColor3 = Colors.TextPrimary
aimbotButton.Parent = aimbotButtonFrame

local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0.45, 0, 1, 0)
espButton.Position = UDim2.new(0.55, 0, 0, 0)
espButton.BackgroundColor3 = Colors.ToggleOff
espButton.BorderSizePixel = 0
espButton.Text = "AÇ"
espButton.Font = Enum.Font.SourceSansBold
espButton.TextSize = 14
espButton.TextColor3 = Colors.TextPrimary
espButton.Parent = aimbotButtonFrame

aimbotButton.MouseButton1Click:Connect(function()
    AimbotOn = not AimbotOn
    aimbotButton.BackgroundColor3 = AimbotOn and Colors.ToggleOn or Colors.ToggleOff
    aimbotButton.Text = AimbotOn and "KAPA" or "AÇ"
end)

espButton.MouseButton1Click:Connect(function()
    ESPOn = not ESPOn
    espButton.BackgroundColor3 = ESPOn and Colors.ToggleOn or Colors.ToggleOff
    espButton.Text = ESPOn and "KAPA" or "AÇ"
end)

local function getClosestTarget()
    local closestDist = math.huge
    local target
    local cam = workspace.CurrentCamera
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local part = plr.Character.Head
            local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < closestDist and dist < 200 then
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
        if target then
            local cam = workspace.CurrentCamera
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
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
                    box.Size = Vector3.new(3, 5, 3)
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                    box.Transparency = 0.4
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

-- Spam & AutoClicker Bölümü
local spamSection, spamContent = createSection("Spam & AutoClicker", hileleriPage)

local SpamKey = Enum.KeyCode.Unknown
local SpamMsg = "Tarnak Spam Mesaj"
local AutoClickerKey = Enum.KeyCode.Unknown

local spamLabel = Instance.new("TextLabel")
spamLabel.Size = UDim2.new(1, 0, 0, 20)
spamLabel.BackgroundTransparency = 1
spamLabel.Text = "Spam Tuşu: Yok"
spamLabel.Font = Enum.Font.SourceSansSemibold
spamLabel.TextSize = 12
spamLabel.TextColor3 = Colors.TextPrimary
spamLabel.TextXAlignment = Enum.TextXAlignment.Left
spamLabel.Parent = spamContent

local spamMsgBox = Instance.new("TextBox")
spamMsgBox.PlaceholderText = "Spam mesajı"
spamMsgBox.ClearTextOnFocus = false
spamMsgBox.Size = UDim2.new(1, 0, 0, 28)
spamMsgBox.BackgroundColor3 = Colors.Section
spamMsgBox.TextColor3 = Colors.TextPrimary
spamMsgBox.Font = Enum.Font.SourceSansSemibold
spamMsgBox.TextSize = 12
spamMsgBox.Text = SpamMsg
spamMsgBox.Parent = spamContent

spamMsgBox.FocusLost:Connect(function(enter)
    if enter and spamMsgBox.Text ~= "" then
        SpamMsg = spamMsgBox.Text
    end
end)

local spamSetBtn = Instance.new("TextButton")
spamSetBtn.Size = UDim2.new(1, 0, 0, 28)
spamSetBtn.BackgroundColor3 = Colors.Section
spamSetBtn.BorderSizePixel = 0
spamSetBtn.Text = "Spam Tuşunu Ayarla"
spamSetBtn.Font = Enum.Font.SourceSansSemibold
spamSetBtn.TextSize = 12
spamSetBtn.TextColor3 = Colors.TextPrimary
spamSetBtn.Parent = spamContent

spamSetBtn.MouseButton1Click:Connect(function()
    spamLabel.Text = "Bir tuşa basın..."
    local con
    con = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        SpamKey = input.KeyCode
        spamLabel.Text = "Spam Tuşu: " .. tostring(SpamKey.Name)
        con:Disconnect()
    end)
end)

local autoClickerLabel = Instance.new("TextLabel")
autoClickerLabel.Size = UDim2.new(1, 0, 0, 20)
autoClickerLabel.BackgroundTransparency = 1
autoClickerLabel.Text = "AutoClicker Tuşu: Yok"
autoClickerLabel.Font = Enum.Font.SourceSansSemibold
autoClickerLabel.TextSize = 12
autoClickerLabel.TextColor3 = Colors.TextPrimary
autoClickerLabel.TextXAlignment = Enum.TextXAlignment.Left
autoClickerLabel.Parent = spamContent

local autoClickerSetBtn = Instance.new("TextButton")
autoClickerSetBtn.Size = UDim2.new(1, 0, 0, 28)
autoClickerSetBtn.BackgroundColor3 = Colors.Section
autoClickerSetBtn.BorderSizePixel = 0
autoClickerSetBtn.Text = "AutoClicker Tuşunu Ayarla"
autoClickerSetBtn.Font = Enum.Font.SourceSansSemibold
autoClickerSetBtn.TextSize = 12
autoClickerSetBtn.TextColor3 = Colors.TextPrimary
autoClickerSetBtn.Parent = spamContent

autoClickerSetBtn.MouseButton1Click:Connect(function()
    autoClickerLabel.Text = "Bir tuşa basın..."
    local con
    con = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        AutoClickerKey = input.KeyCode
        autoClickerLabel.Text = "AutoClicker Tuşu: " .. tostring(AutoClickerKey.Name)
        con:Disconnect()
    end)
end)

spawn(function()
    while true do
        wait(0.05)
        if SpamKey ~= Enum.KeyCode.Unknown and UserInputService:IsKeyDown(SpamKey) then
            local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chat then
                local SayMessageRequest = chat:FindFirstChild("SayMessageRequest")
                if SayMessageRequest then
                    SayMessageRequest:FireServer(SpamMsg, "All")
                end
            end
        end
        if AutoClickerKey ~= Enum.KeyCode.Unknown and UserInputService:IsKeyDown(AutoClickerKey) then
            LocalPlayer:GetMouse().Button1Down:Fire()
        end
    end
end)

-- Loadstring Sayfası
local loadBtn1 = Instance.new("TextButton")
loadBtn1.Size = UDim2.new(1, 0, 0, 35)
loadBtn1.BackgroundColor3 = Colors.Section
loadBtn1.BorderSizePixel = 0
loadBtn1.Text = "InfiniteYield Aç"
loadBtn1.Font = Enum.Font.SourceSansSemibold
loadBtn1.TextSize = 14
loadBtn1.TextColor3 = Colors.TextPrimary
loadBtn1.Parent = loadstringPage

loadBtn1.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

local loadBtn2 = Instance.new("TextButton")
loadBtn2.Size = UDim2.new(1, 0, 0, 35)
loadBtn2.BackgroundColor3 = Colors.Section
loadBtn2.BorderSizePixel = 0
loadBtn2.Text = "Dış Script Aç"
loadBtn2.Font = Enum.Font.SourceSansSemibold
loadBtn2.TextSize = 14
loadBtn2.TextColor3 = Colors.TextPrimary
loadBtn2.Parent = loadstringPage

loadBtn2.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dertonware/scriptasda/refs/heads/main/scriptlua", true))()
end)

local loadBtn3 = Instance.new("TextButton")
loadBtn3.Size = UDim2.new(1, 0, 0, 35)
loadBtn3.BackgroundColor3 = Colors.Section
loadBtn3.BorderSizePixel = 0
loadBtn3.Text = "Cmd Aç"
loadBtn3.Font = Enum.Font.SourceSansSemibold
loadBtn3.TextSize = 14
loadBtn3.TextColor3 = Colors.TextPrimary
loadBtn3.Parent = loadstringPage

loadBtn3.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/cmd/main/main.lua"))()
end)

-- Karakter Spawn Olunca
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    normalizeAll()
end)

return ScreenGui