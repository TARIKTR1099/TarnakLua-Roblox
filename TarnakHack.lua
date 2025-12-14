local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

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

-- Temel GUI ayarları
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TarnakGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Loading Frame
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(0, 250, 0, 100)
LoadingFrame.Position = UDim2.new(0.5, -125, 0.5, -50)
LoadingFrame.BackgroundColor3 = Colors.Section
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = ScreenGui

local LoadingLabel = Instance.new("TextLabel")
LoadingLabel.Size = UDim2.new(1, 0, 1, 0)
LoadingLabel.BackgroundTransparency = 1
LoadingLabel.TextColor3 = Colors.Accent
LoadingLabel.Font = Enum.Font.SourceSansBold
LoadingLabel.TextSize = 28
LoadingLabel.Text = "Tarnak Hileleri\nLoading..."
LoadingLabel.Parent = LoadingFrame

wait(1) -- Yükleniyor efekti için

LoadingFrame:Destroy()

-- Ana Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Position = UDim2.new(1, -330, 0.25, 0)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Colors.Section
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "Tarnak Hileleri"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 22
TitleLabel.TextColor3 = Colors.Accent
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 2)
TitleLabel.Size = UDim2.new(0, 200, 0, 30)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 20
CloseButton.TextColor3 = Colors.Accent
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.Size = UDim2.new(0, 40, 1, 0)
CloseButton.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Text = "─"
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 20
MinimizeButton.TextColor3 = Colors.Accent
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Position = UDim2.new(1, -80, 0, 0)
MinimizeButton.Size = UDim2.new(0, 40, 1, 0)
MinimizeButton.Parent = TitleBar

local LogoButton = Instance.new("TextButton")
LogoButton.Text = "T"
LogoButton.Font = Enum.Font.SourceSansBold
LogoButton.TextSize = 24
LogoButton.TextColor3 = Colors.Accent
LogoButton.BackgroundColor3 = Colors.Section
LogoButton.Position = UDim2.new(1, -25, 0.15, 0)
LogoButton.Size = UDim2.new(0, 40, 0, 40)
LogoButton.AnchorPoint = Vector2.new(0.5,0.5)
LogoButton.Visible = false
LogoButton.Parent = ScreenGui
LogoButton.AutoButtonColor = false
LogoButton.BorderSizePixel = 0
LogoButton.Name = "TarnakLogo"
LogoButton.ZIndex = 10
LogoButton.TextScaled = true
LogoButton.TextWrapped = true
LogoButton.TextYAlignment = Enum.TextYAlignment.Center
LogoButton.TextXAlignment = Enum.TextXAlignment.Center
LogoButton.BackgroundTransparency = 0
LogoButton.Modal = true
LogoButton.AutoButtonColor = true
LogoButton.Style = Enum.ButtonStyle.RobloxRoundButton

local function minimize()
    if not MainFrame.Visible then return end
    MainFrame.Visible = false
    LogoButton.Visible = true
end

local function restore()
    if MainFrame.Visible then return end
    MainFrame.Visible = true
    LogoButton.Visible = false
end

CloseButton.MouseButton1Click:Connect(function()
    -- Uçmayı kapat ve temizle
    if Flying then
        Flying = false
        if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
        if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
        Humanoid.PlatformStand = false
    end
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(minimize)
LogoButton.MouseButton1Click:Connect(restore)

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        MainFrame:CaptureFocus()
        local dragStart = input.Position
        local frameStart = MainFrame.Position

        local connMove, connEnd

        connMove = UserInputService.InputChanged:Connect(function(moveInput)
            if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = moveInput.Position - dragStart
                MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
            end
        end)

        connEnd = UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                connMove:Disconnect()
                connEnd:Disconnect()
                MainFrame:ReleaseFocus()
            end
        end)
    end
end)

local SideMenu = Instance.new("Frame")
SideMenu.BackgroundColor3 = Colors.Section
SideMenu.Size = UDim2.new(0, 100, 1, -36)
SideMenu.Position = UDim2.new(0, 0, 0, 36)
SideMenu.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 6)
SideLayout.FillDirection = Enum.FillDirection.Vertical
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = SideMenu

local ContentFrame = Instance.new("Frame")
ContentFrame.BackgroundColor3 = Colors.Background
ContentFrame.Size = UDim2.new(1, -100, 1, -36)
ContentFrame.Position = UDim2.new(0, 100, 0, 36)
ContentFrame.Parent = MainFrame
ContentFrame.ClipsDescendants = true

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
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
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = Colors.Background
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 18
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

local function createToggle(labelText, parent, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Colors.Section
    frame.BorderSizePixel = 0
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

local function createSlider(labelText, min, max, default, parent, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = Colors.Section
    frame.BorderSizePixel = 0
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

local function createButton(text, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.BackgroundColor3 = Colors.Section
    btn.TextColor3 = Colors.TextPrimary
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 18
    btn.Text = text
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Sayfa isimleri
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

-- Uçma & İzleyici Mod Sayfası
local flyPage = Pages["Uçma & İzleyici"]
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

local flyToggle, flyGet = createToggle("Uçmayı Aç/Kapa", flyPage, false, function(state)
    if state then
        if not Flying then
            Flying = true
            BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
            BodyVelocity.Parent = RootPart
            BodyVelocity.Velocity = Vector3.new(0,0,0)
            Humanoid.PlatformStand = true
            FlyConnection = RunService.Heartbeat:Connect(updateFlyVelocity)
        end
    else
        if Flying then
            Flying = false
            if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
            if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
            Humanoid.PlatformStand = false
        end
    end
end)

local flySpeedSlider = createSlider("Uçma Hızı", 10, 500, FlySpeed, flyPage, function(value)
    FlySpeed = value
end)

-- İzleyici Modu Toggle ve Hız Ayarı
local SpectatorOn = false
local SpectatorSpeed = 100
local spectatorToggle, spectatorGet = createToggle("İzleyici Modu (Uçma + İçinden Geçme)", flyPage, false, function(state)
    SpectatorOn = state
    if SpectatorOn then
        if not Flying then
            flyToggle(true)
        end
        -- İçinden geçme için çarpışmayı kapat
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part ~= RootPart then
                part.CanCollide = false
            end
        end
    else
        -- Çarpışmayı geri aç
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part ~= RootPart then
                part.CanCollide = true
            end
        end
    end
end)

local spectatorSpeedLabel = Instance.new("TextLabel")
spectatorSpeedLabel.Size = UDim2.new(1, -20, 0, 20)
spectatorSpeedLabel.BackgroundTransparency = 1
spectatorSpeedLabel.TextColor3 = Colors.TextPrimary
spectatorSpeedLabel.Font = Enum.Font.SourceSansSemibold
spectatorSpeedLabel.TextSize = 16
spectatorSpeedLabel.Text = "İzleyici Hızı: " .. SpectatorSpeed
spectatorSpeedLabel.Parent = flyPage

local spectatorSpeedFrame = Instance.new("Frame")
spectatorSpeedFrame.Size = UDim2.new(1, -20, 0, 30)
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

-- İzleyici mod uçuş hızını update et
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

-- Animasyonları tamamen durdurma fonksiyonu
local function stopAllAnimations()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, anim in pairs(hum:GetPlayingAnimationTracks()) do
                    anim:Stop()
                end
            end
            -- Ayrıca Animator varsa durdur
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

local animPage = Pages["Animasyonlar"]
local animationsOff = false
local animToggle, animGet = createToggle("Animasyonları Kapat (Tüm Karakterler)", animPage, false, function(state)
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

-- Işınlanma Sayfası
local tpPage = Pages["Işınlanma"]

local TPInfoLabel = Instance.new("TextLabel")
TPInfoLabel.Text = "İşaretlenen koordinatlar: X (Zorunlu), Y ve Z (Opsiyonel)"
TPInfoLabel.Font = Enum.Font.SourceSansSemibold
TPInfoLabel.TextSize = 14
TPInfoLabel.TextColor3 = Colors.TextSecondary
TPInfoLabel.BackgroundTransparency = 1
TPInfoLabel.Size = UDim2.new(1, -20, 0, 20)
TPInfoLabel.Position = UDim2.new(0, 10, 0, 10)
TPInfoLabel.Parent = tpPage

local TPXInput = Instance.new("TextBox")
TPXInput.PlaceholderText = "X Koordinatı (zorunlu)"
TPXInput.Size = UDim2.new(1, -20, 0, 30)
TPXInput.BackgroundColor3 = Colors.Section
TPXInput.TextColor3 = Colors.TextPrimary
TPXInput.Font = Enum.Font.SourceSansSemibold
TPXInput.TextSize = 16
TPXInput.ClearTextOnFocus = false
TPXInput.Parent = tpPage
TPXInput.Position = UDim2.new(0, 10, 0, 35)

local TPYInput = Instance.new("TextBox")
TPYInput.PlaceholderText = "Y Koordinatı (opsiyonel)"
TPYInput.Size = UDim2.new(1, -20, 0, 30)
TPYInput.BackgroundColor3 = Colors.Section
TPYInput.TextColor3 = Colors.TextPrimary
TPYInput.Font = Enum.Font.SourceSansSemibold
TPYInput.TextSize = 16
TPYInput.ClearTextOnFocus = false
TPYInput.Parent = tpPage
TPYInput.Position = UDim2.new(0, 10, 0, 70)

local TPZInput = Instance.new("TextBox")
TPZInput.PlaceholderText = "Z Koordinatı (opsiyonel)"
TPZInput.Size = UDim2.new(1, -20, 0, 30)
TPZInput.BackgroundColor3 = Colors.Section
TPZInput.TextColor3 = Colors.TextPrimary
TPZInput.Font = Enum.Font.SourceSansSemibold
TPZInput.TextSize = 16
TPZInput.ClearTextOnFocus = false
TPZInput.Parent = tpPage
TPZInput.Position = UDim2.new(0, 10, 0, 105)

local function tpTo(x,y,z)
    if not x then return end
    y = y or RootPart.Position.Y
    z = z or RootPart.Position.Z
    RootPart.CFrame = CFrame.new(x,y,z)
end

createButton("Işınlan", tpPage, function()
    local x = tonumber(TPXInput.Text)
    if not x then
        warn("X koordinatı zorunlu!")
        return
    end
    local y = tonumber(TPYInput.Text)
    local z = tonumber(TPZInput.Text)
    tpTo(x,y,z)
end)

-- Sinek Modu Sayfası
local bugPage = Pages["Sinek Modu"]
local BugPart
local BugActive = false

local bugToggle, bugGet = createToggle("Sinek Modu (Kafa Üstü Uçma)", bugPage, false, function(state)
    BugActive = state
    if BugActive then
        if not BugPart then
            BugPart = Instance.new("Part")
            BugPart.Size = Vector3.new(1,1,1)
            BugPart.Shape = Enum.PartType.Ball
            BugPart.Anchored = true
            BugPart.CanCollide = false
            BugPart.Material = Enum.Material.Neon
            BugPart.Color = Color3.fromRGB(255, 255, 0)
            BugPart.Parent = Workspace
        end
        RunService:BindToRenderStep("BugMove", 301, function()
            if BugActive and BugPart then
                local cam = workspace.CurrentCamera
                BugPart.CFrame = cam.CFrame * CFrame.new(0,0,-5)
                -- Karakter görünmez
                if Character and Character:FindFirstChild("Head") then
                    Character.Head.Transparency = 1
                    for _, part in pairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") and part ~= RootPart then
                            part.Transparency = 1
                        end
                    end
                end
            else
                RunService:UnbindFromRenderStep("BugMove")
                if BugPart then
                    BugPart:Destroy()
                    BugPart = nil
                    -- Karakter görünür yap
                    if Character and Character:FindFirstChild("Head") then
                        Character.Head.Transparency = 0
                        for _, part in pairs(Character:GetDescendants()) do
                            if part:IsA("BasePart") and part ~= RootPart then
                                part.Transparency = 0
                            end
                        end
                    end
                end
            end
        end)
    else
        RunService:UnbindFromRenderStep("BugMove")
        if BugPart then
            BugPart:Destroy()
            BugPart = nil
            -- Karakter görünür yap
            if Character and Character:FindFirstChild("Head") then
                Character.Head.Transparency = 0
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") and part ~= RootPart then
                        part.Transparency = 0
                    end
                end
            end
        end
    end
end)

-- XRay Sayfası (Sadece şeffaflık, içinden geçme yok)
local xrayPage = Pages["XRay"]
local XRayOn = false
local TransparentParts = {}

local xrayToggle, xrayGet = createToggle("XRay", xrayPage, false, function(state)
    XRayOn = state
    if XRayOn then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 and part.CanCollide then
                TransparentParts[part] = {part.Transparency, part.CanCollide}
                part.Transparency = 0.5
            end
        end
    else
        for part, props in pairs(TransparentParts) do
            if part and part:IsA("BasePart") then
                part.Transparency = props[1]
            end
        end
        TransparentParts = {}
    end
end)

-- Aimbot & ESP Sayfası
local aimbotPage = Pages["Aimbot & ESP"]
local AimbotOn = false
local ESPOn = false
local AimPartName = "Head"

local aimbotToggle, aimbotGet = createToggle("Aimbot", aimbotPage, false, function(state)
    AimbotOn = state
end)

local espToggle, espGet = createToggle("ESP", aimbotPage, false, function(state)
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

-- Spam & AutoClicker Sayfası
local spamPage = Pages["Spam & AutoClicker"]

local SpamKey = Enum.KeyCode.Unknown
local SpamDelay = 0
local SpamActive = false

local AutoClickerKey = Enum.KeyCode.Unknown
local AutoClickerDelay = 0
local AutoClickerActive = false

local SpamLabel = Instance.new("TextLabel")
SpamLabel.Size = UDim2.new(1, -20, 0, 25)
SpamLabel.BackgroundTransparency = 1
SpamLabel.TextColor3 = Colors.TextPrimary
SpamLabel.Font = Enum.Font.SourceSansSemibold
SpamLabel.TextSize = 16
SpamLabel.Text = "Spam Mesaj Tuşu: Yok"
SpamLabel.Parent = spamPage

local SpamDelayBox = Instance.new("TextBox")
SpamDelayBox.PlaceholderText = "Spam gecikmesi (saniye) 0 = sürekli"
SpamDelayBox.Size = UDim2.new(1, -20, 0, 30)
SpamDelayBox.BackgroundColor3 = Colors.Section
SpamDelayBox.TextColor3 = Colors.TextPrimary
SpamDelayBox.Font = Enum.Font.SourceSansSemibold
SpamDelayBox.TextSize = 16
SpamDelayBox.ClearTextOnFocus = false
SpamDelayBox.Parent = spamPage

local SpamSetKeyBtn = createButton("Spam Tuşunu Ayarla", spamPage, function()
    SpamLabel.Text = "Bir tuşa basın..."
    local con
    con = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        SpamKey = input.KeyCode
        SpamLabel.Text = "Spam Mesaj Tuşu: " .. tostring(SpamKey.Name)
        con:Disconnect()
    end)
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

-- AutoClicker Tuş ve Delay
local AutoClickerLabel = Instance.new("TextLabel")
AutoClickerLabel.Size = UDim2.new(1, -20, 0, 25)
AutoClickerLabel.BackgroundTransparency = 1
AutoClickerLabel.TextColor3 = Colors.TextPrimary
AutoClickerLabel.Font = Enum.Font.SourceSansSemibold
AutoClickerLabel.TextSize = 16
AutoClickerLabel.Text = "Otomatik Tıklama Tuşu: Yok"
AutoClickerLabel.Parent = spamPage

local AutoClickerDelayBox = Instance.new("TextBox")
AutoClickerDelayBox.PlaceholderText = "Clicker gecikmesi (saniye)"
AutoClickerDelayBox.Size = UDim2.new(1, -20, 0, 30)
AutoClickerDelayBox.BackgroundColor3 = Colors.Section
AutoClickerDelayBox.TextColor3 = Colors.TextPrimary
AutoClickerDelayBox.Font = Enum.Font.SourceSansSemibold
AutoClickerDelayBox.TextSize = 16
AutoClickerDelayBox.ClearTextOnFocus = false
AutoClickerDelayBox.Parent = spamPage

local AutoClickerSetKeyBtn = createButton("Otomatik Tıklama Tuşunu Ayarla", spamPage, function()
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

-- Spam ve AutoClicker loop
spawn(function()
    while true do
        wait(0.1)
        if SpamKey ~= Enum.KeyCode.Unknown and UserInputService:IsKeyDown(SpamKey) then
            if SpamDelay == 0 or (tick() % SpamDelay) < 0.1 then
                local chat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if chat then
                    local SayMessageRequest = chat:FindFirstChild("SayMessageRequest")
                    if SayMessageRequest then
                        SayMessageRequest:FireServer("Tarnak Spam Mesaj", "All")
                    end
                end
            end
        end
        if AutoClickerKey ~= Enum.KeyCode.Unknown and UserInputService:IsKeyDown(AutoClickerKey) then
            if AutoClickerDelay == 0 or (tick() % AutoClickerDelay) < 0.1 then
                local mouse = LocalPlayer:GetMouse()
                mouse1click()
            end
        end
    end
end)

-- Loadstring Sayfası
local loadstringPage = Pages["Loadstring"]

createButton("InfiniteYield Aç", loadstringPage, function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

createButton("Dış Script Aç", loadstringPage, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dertonware/scriptasda/refs/heads/main/scriptlua", true))()
end)

createButton("Cmd Aç", loadstringPage, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/cmd/main/main.lua"))()
end)

-- Pusula Sayfası
local compassPage = Pages["Pusula"]

local CompassLabel = Instance.new("TextLabel")
CompassLabel.Size = UDim2.new(1, -20, 0, 25)
CompassLabel.BackgroundTransparency = 1
CompassLabel.TextColor3 = Colors.TextPrimary
CompassLabel.Font = Enum.Font.SourceSansSemibold
CompassLabel.TextSize = 16
CompassLabel.Text = "X: 0 Y: 0 Z: 0"
CompassLabel.Parent = compassPage

RunService.Heartbeat:Connect(function()
    if RootPart and RootPart.Parent then
        local pos = RootPart.Position
        CompassLabel.Text = string.format("X: %.1f  Y: %.1f  Z: %.1f", pos.X, pos.Y, pos.Z)
    end
end)

return ScreenGui