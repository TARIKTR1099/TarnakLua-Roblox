-- TarnakLua-Roblox - Ultimate Edition
-- Rayfield UI Library
-- Açma/Kapama: PageDown veya Break tuşu

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ==================== SERVİSLER ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local ContextActionService = game:GetService("ContextActionService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ==================== BAŞLANGIÇ DEĞERLERİ ====================
local OriginalSettings = {
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = workspace.Gravity,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    GlobalShadows = Lighting.GlobalShadows,
    LightingEffects = {},
}

for _, effect in pairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("BlurEffect") or effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
        OriginalSettings.LightingEffects[effect] = {Enabled = effect.Enabled}
    end
end

-- ==================== GLOBAL DEĞİŞKENLER ====================
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local antiAfkEnabled = false
local autoClickerEnabled = false
local spamAutoEnabled = false
local invisibleEnabled = false
local noAnimationsEnabled = false
local noParticlesEnabled = false
local noLightsEnabled = false
local noFogEnabled = false
local noShadowsEnabled = false
local shiftBoostEnabled = false
local infiniteJumpEnabled = false
local fullbrightEnabled = false
local nightVisionEnabled = false
local noBlurEnabled = false
local noBloomEnabled = false
local noSunRaysEnabled = false
local noDOFEnabled = false
local customAmbientEnabled = false
local rainbowAmbientEnabled = false
local customTimeEnabled = false
local dashEnabled = false

local tpwalking = false
local speeds = 1
local nowe = false
local walkSpeedValue = 16
local jumpPowerValue = 50
local dashDistance = 50
local shiftBoostMultiplier = 2
local autoClickerDelay = 0.1
local autoClickerToggleKey = Enum.KeyCode.X
local spamAutoKey = Enum.KeyCode.E
local spamAutoDelay = 0.1
local customTimeValue = 14
local customAmbientColor = Color3.fromRGB(150, 150, 150)

local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local currentSpeed = 0
local maxspeed = 50

local espConnections = {}
local espObjects = {}
local tracerLines = {}
local allConnections = {}

local selectedObject = nil
local compassGui = nil
local builderTool = nil
local currentBuilderMode = "Select"
local isDragging = false
local dragStart = nil
local dragOffset = nil

-- Tool Ayarları
local swordDamage = 35
local swordRange = 6
local gunDamage = 25
local gunFireRate = 0.15
local magicDamage = 40
local magicCooldown = 1

-- ==================== YARDIMCI FONKSİYONLAR ====================
local function addConnection(conn)
    if conn then table.insert(allConnections, conn) end
    return conn
end

local function copyToClipboard(text)
    if setclipboard then setclipboard(tostring(text)) return true
    elseif toclipboard then toclipboard(tostring(text)) return true end
    return false
end

local function getKeyFromString(text)
    local specialKeys = {
        ["SPACE"] = Enum.KeyCode.Space, ["ENTER"] = Enum.KeyCode.Return,
        ["TAB"] = Enum.KeyCode.Tab, ["SHIFT"] = Enum.KeyCode.LeftShift,
        ["LSHIFT"] = Enum.KeyCode.LeftShift, ["RSHIFT"] = Enum.KeyCode.RightShift,
        ["CTRL"] = Enum.KeyCode.LeftControl, ["LCTRL"] = Enum.KeyCode.LeftControl,
        ["RCTRL"] = Enum.KeyCode.RightControl, ["ALT"] = Enum.KeyCode.LeftAlt,
        ["LALT"] = Enum.KeyCode.LeftAlt, ["RALT"] = Enum.KeyCode.RightAlt,
        ["BACKSPACE"] = Enum.KeyCode.Backspace, ["ESC"] = Enum.KeyCode.Escape,
        ["ESCAPE"] = Enum.KeyCode.Escape, ["UP"] = Enum.KeyCode.Up,
        ["DOWN"] = Enum.KeyCode.Down, ["LEFT"] = Enum.KeyCode.Left,
        ["RIGHT"] = Enum.KeyCode.Right, ["HOME"] = Enum.KeyCode.Home,
        ["END"] = Enum.KeyCode.End, ["PAGEUP"] = Enum.KeyCode.PageUp,
        ["PAGEDOWN"] = Enum.KeyCode.PageDown, ["INSERT"] = Enum.KeyCode.Insert,
        ["DELETE"] = Enum.KeyCode.Delete, ["CAPSLOCK"] = Enum.KeyCode.CapsLock,
        ["F1"] = Enum.KeyCode.F1, ["F2"] = Enum.KeyCode.F2, ["F3"] = Enum.KeyCode.F3,
        ["F4"] = Enum.KeyCode.F4, ["F5"] = Enum.KeyCode.F5, ["F6"] = Enum.KeyCode.F6,
        ["F7"] = Enum.KeyCode.F7, ["F8"] = Enum.KeyCode.F8, ["F9"] = Enum.KeyCode.F9,
        ["F10"] = Enum.KeyCode.F10, ["F11"] = Enum.KeyCode.F11, ["F12"] = Enum.KeyCode.F12,
        ["0"] = Enum.KeyCode.Zero, ["1"] = Enum.KeyCode.One, ["2"] = Enum.KeyCode.Two,
        ["3"] = Enum.KeyCode.Three, ["4"] = Enum.KeyCode.Four, ["5"] = Enum.KeyCode.Five,
        ["6"] = Enum.KeyCode.Six, ["7"] = Enum.KeyCode.Seven, ["8"] = Enum.KeyCode.Eight,
        ["9"] = Enum.KeyCode.Nine,
    }
    
    local key = specialKeys[text:upper()]
    if not key then
        pcall(function() key = Enum.KeyCode[text:upper()] end)
    end
    return key
end

-- ==================== EKRAN PUSULA/KONUM GUI ====================
local function createCompassGui()
    if compassGui then compassGui:Destroy() end
    
    compassGui = Instance.new("ScreenGui")
    compassGui.Name = "TarnakCompass"
    compassGui.ResetOnSpawn = false
    compassGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function() compassGui.Parent = CoreGui end)
    if not compassGui.Parent then
        compassGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "CompassFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 100)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = compassGui
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 180, 0)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -45, 0, 24)
    titleLabel.Position = UDim2.new(0, 12, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = "🧭 PUSULA & KONUM"
    titleLabel.Parent = mainFrame
    
    local compassLabel = Instance.new("TextLabel")
    compassLabel.Name = "Compass"
    compassLabel.Size = UDim2.new(1, -24, 0, 24)
    compassLabel.Position = UDim2.new(0, 12, 0, 32)
    compassLabel.BackgroundTransparency = 1
    compassLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    compassLabel.Font = Enum.Font.GothamBold
    compassLabel.TextSize = 16
    compassLabel.TextXAlignment = Enum.TextXAlignment.Left
    compassLabel.Text = "Yön: ?"
    compassLabel.Parent = mainFrame
    
    local posLabel = Instance.new("TextLabel")
    posLabel.Name = "Position"
    posLabel.Size = UDim2.new(1, -24, 0, 20)
    posLabel.Position = UDim2.new(0, 12, 0, 56)
    posLabel.BackgroundTransparency = 1
    posLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    posLabel.Font = Enum.Font.GothamSemibold
    posLabel.TextSize = 13
    posLabel.TextXAlignment = Enum.TextXAlignment.Left
    posLabel.Text = "X: 0 | Y: 0 | Z: 0"
    posLabel.Parent = mainFrame
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "Speed"
    speedLabel.Size = UDim2.new(1, -24, 0, 16)
    speedLabel.Position = UDim2.new(0, 12, 0, 78)
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 11
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Text = "🏃 Hız: 0 studs/s"
    speedLabel.Parent = mainFrame
    
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 32, 0, 32)
    copyBtn.Position = UDim2.new(1, -40, 0, 6)
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 16
    copyBtn.Text = "📋"
    copyBtn.Parent = mainFrame
    
    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 8)
    copyCorner.Parent = copyBtn
    
    copyBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            copyToClipboard(string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
            copyBtn.Text = "✓"
            wait(1)
            copyBtn.Text = "📋"
        end
    end)
    
    local lastPos = Vector3.new(0, 0, 0)
    spawn(function()
        while compassGui and compassGui.Parent do
            wait(0.05)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                local lookVector = char.HumanoidRootPart.CFrame.LookVector
                local angle = math.deg(math.atan2(lookVector.X, lookVector.Z))
                
                local speed = (pos - lastPos).Magnitude / 0.05
                lastPos = pos
                
                local directions = {
                    {min = -22.5, max = 22.5, name = "Kuzey", emoji = "⬆️"},
                    {min = 22.5, max = 67.5, name = "Kuzeydoğu", emoji = "↗️"},
                    {min = 67.5, max = 112.5, name = "Doğu", emoji = "➡️"},
                    {min = 112.5, max = 157.5, name = "Güneydoğu", emoji = "↘️"},
                    {min = -67.5, max = -22.5, name = "Kuzeybatı", emoji = "↖️"},
                    {min = -112.5, max = -67.5, name = "Batı", emoji = "⬅️"},
                    {min = -157.5, max = -112.5, name = "Güneybatı", emoji = "↙️"},
                }
                
                local direction, emoji = "Güney", "⬇️"
                for _, d in ipairs(directions) do
                    if angle >= d.min and angle < d.max then
                        direction, emoji = d.name, d.emoji
                        break
                    end
                end
                
                compassLabel.Text = emoji .. " " .. direction .. " (" .. math.floor(angle) .. "°)"
                posLabel.Text = string.format("📍 X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z)
                speedLabel.Text = string.format("🏃 Hız: %.1f studs/s", speed)
            end
        end
    end)
    
    return compassGui
end

createCompassGui()

-- ==================== GELİŞMİŞ BUILDER TOOL - ROBLOX STUDIO TARZI ====================
local function createStudioHandles(part)
    if not part or not part:IsA("BasePart") then return end
    
    -- Önceki handles'ları temizle
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:find("StudioHandle") or obj.Name == "BuilderSelection" then
            obj:Destroy()
        end
    end
    
    -- Selection Box (Mavi kutu)
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Name = "BuilderSelection"
    selectionBox.Adornee = part
    selectionBox.Color3 = Color3.fromRGB(0, 170, 255)
    selectionBox.LineThickness = 0.03
    selectionBox.SurfaceColor3 = Color3.fromRGB(0, 100, 200)
    selectionBox.SurfaceTransparency = 0.9
    selectionBox.Parent = part
    
    -- Move Handles (Oklar)
    local moveHandles = Instance.new("Handles")
    moveHandles.Name = "StudioHandle_Move"
    moveHandles.Adornee = part
    moveHandles.Color3 = Color3.fromRGB(0, 200, 255)
    moveHandles.Style = Enum.HandlesStyle.Movement
    moveHandles.Parent = part
    
    moveHandles.MouseDrag:Connect(function(face, distance)
        local normal = Vector3.FromNormalId(face)
        part.CFrame = part.CFrame + (normal * distance)
    end)
    
    return selectionBox, moveHandles
end

local function createBuilderTool()
    if builderTool then builderTool:Destroy() end
    
    builderTool = Instance.new("Tool")
    builderTool.Name = "🔧 Studio Builder"
    builderTool.RequiresHandle = true
    builderTool.CanBeDropped = false
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.5, 0.5, 2)
    handle.BrickColor = BrickColor.new("Bright blue")
    handle.Material = Enum.Material.Neon
    handle.Parent = builderTool
    
    builderTool.Grip = CFrame.new(0, 0, -0.5)
    
    -- Builder GUI
    local builderGui = Instance.new("ScreenGui")
    builderGui.Name = "BuilderGui"
    builderGui.ResetOnSpawn = false
    
    local mainPanel = Instance.new("Frame")
    mainPanel.Size = UDim2.new(0, 350, 0, 600)
    mainPanel.Position = UDim2.new(1, -360, 0.5, -300)
    mainPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainPanel.BackgroundTransparency = 0.05
    mainPanel.BorderSizePixel = 0
    mainPanel.Visible = false
    mainPanel.Parent = builderGui
    mainPanel.Active = true
    mainPanel.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainPanel
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 2
    stroke.Parent = mainPanel
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
    title.Text = "🔧 STUDIO BUILDER - Roblox Studio Mode"
    title.Parent = mainPanel
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Name = "SelectedLabel"
    selectedLabel.Size = UDim2.new(1, -20, 0, 25)
    selectedLabel.Position = UDim2.new(0, 10, 0, 45)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    selectedLabel.Font = Enum.Font.GothamBold
    selectedLabel.TextSize = 12
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.Text = "📦 Seçili: Yok"
    selectedLabel.Parent = mainPanel
    
    -- Mode butonları
    local modeFrame = Instance.new("Frame")
    modeFrame.Size = UDim2.new(1, -20, 0, 35)
    modeFrame.Position = UDim2.new(0, 10, 0, 75)
    modeFrame.BackgroundTransparency = 1
    modeFrame.Parent = mainPanel
    
    local modeLayout = Instance.new("UIListLayout")
    modeLayout.FillDirection = Enum.FillDirection.Horizontal
    modeLayout.Padding = UDim.new(0, 5)
    modeLayout.Parent = modeFrame
    
    local modes = {"Select", "Move", "Scale", "Rotate", "Delete", "Clone"}
    local modeButtons = {}
    
    for _, mode in ipairs(modes) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 50, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.Text = mode:sub(1, 4)
        btn.Parent = modeFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            currentBuilderMode = mode
            for _, b in pairs(modeButtons) do
                b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
            btn.BackgroundColor3 = Color3.fromRGB(0, 130, 220)
        end)
        
        table.insert(modeButtons, btn)
    end
    
    modeButtons[1].BackgroundColor3 = Color3.fromRGB(0, 130, 220)
    
    -- Scroll Frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 0, 470)
    scrollFrame.Position = UDim2.new(0, 10, 0, 120)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
    scrollFrame.Parent = mainPanel
    
    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding = UDim.new(0, 6)
    scrollLayout.Parent = scrollFrame
    
    -- Input oluşturma fonksiyonu
    local function createInput(name, placeholder, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 40)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.Parent = scrollFrame
        
        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0, 6)
        fCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.45, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 11
        label.Text = name
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.5, -15, 0, 28)
        input.Position = UDim2.new(0.48, 0, 0.5, -14)
        input.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.Font = Enum.Font.Gotham
        input.TextSize = 11
        input.PlaceholderText = placeholder
        input.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
        input.Parent = frame
        
        local iCorner = Instance.new("UICorner")
        iCorner.CornerRadius = UDim.new(0, 5)
        iCorner.Parent = input
        
        input.FocusLost:Connect(function() callback(input.Text) end)
        
        return input
    end
    
    -- Button oluşturma fonksiyonu
    local function createButton(name, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.BackgroundColor3 = color or Color3.fromRGB(0, 120, 200)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Text = name
        btn.Parent = scrollFrame
        
        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 6)
        bCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- Section oluşturma
    local function createSection(name)
        local sec = Instance.new("TextLabel")
        sec.Size = UDim2.new(1, -10, 0, 25)
        sec.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        sec.TextColor3 = Color3.fromRGB(255, 200, 0)
        sec.Font = Enum.Font.GothamBold
        sec.TextSize = 11
        sec.Text = "  " .. name
        sec.TextXAlignment = Enum.TextXAlignment.Left
        sec.Parent = scrollFrame
        
        local sCorner = Instance.new("UICorner")
        sCorner.CornerRadius = UDim.new(0, 4)
        sCorner.Parent = sec
    end
    
    -- Transform Section
    createSection("📐 Transform (Dönüşüm)")
    
    createInput("📏 Boyut X", "4", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            local num = tonumber(t)
            if num then selectedObject.Size = Vector3.new(num, selectedObject.Size.Y, selectedObject.Size.Z) end
        end
    end)
    
    createInput("📏 Boyut Y", "4", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            local num = tonumber(t)
            if num then selectedObject.Size = Vector3.new(selectedObject.Size.X, num, selectedObject.Size.Z) end
        end
    end)
    
    createInput("📏 Boyut Z", "4", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            local num = tonumber(t)
            if num then selectedObject.Size = Vector3.new(selectedObject.Size.X, selectedObject.Size.Y, num) end
        end
    end)
    
    createInput("📍 Pozisyon X", "0", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            local num = tonumber(t)
            if num then selectedObject.Position = Vector3.new(num, selectedObject.Position.Y, selectedObject.Position.Z) end
        end
    end)
    
    createInput("📍 Pozisyon Y", "10", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            local num = tonumber(t)
            if num then selectedObject.Position = Vector3.new(selectedObject.Position.X, num, selectedObject.Position.Z) end
        end
    end)
    
    createInput("📍 Pozisyon Z", "0", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            local num = tonumber(t)
            if num then selectedObject.Position = Vector3.new(selectedObject.Position.X, selectedObject.Position.Y, num) end
        end
    end)
    
    createInput("🔄 Rotasyon X", "0", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            local num = tonumber(t)
            if num then
                local _, ry, rz = selectedObject.CFrame:ToEulerAnglesYXZ()
                selectedObject.CFrame = CFrame.new(selectedObject.Position) * CFrame.Angles(math.rad(num), ry, rz)
            end
        end
    end)
    
    createInput("🔄 Rotasyon Y", "0", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            local num = tonumber(t)
            if num then
                local rx, _, rz = selectedObject.CFrame:ToEulerAnglesYXZ()
                selectedObject.CFrame = CFrame.new(selectedObject.Position) * CFrame.Angles(rx, math.rad(num), rz)
            end
        end
    end)
    
    createInput("🔄 Rotasyon Z", "0", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            local num = tonumber(t)
            if num then
                local rx, ry, _ = selectedObject.CFrame:ToEulerAnglesYXZ()
                selectedObject.CFrame = CFrame.new(selectedObject.Position) * CFrame.Angles(rx, ry, math.rad(num))
            end
        end
    end)
    
    -- Appearance Section
    createSection("🎨 Görünüm")
    
    createInput("🎨 Renk R,G,B", "255,0,0", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            local parts = t:split(",")
            if #parts == 3 then
                local r, g, b = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
                if r and g and b then selectedObject.Color = Color3.fromRGB(r, g, b) end
            end
        end
    end)
    
    createInput("🔍 Transparency", "0", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            local num = tonumber(t)
            if num then selectedObject.Transparency = math.clamp(num, 0, 1) end
        end
    end)
    
    createInput("💎 Material", "Neon", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            pcall(function() selectedObject.Material = Enum.Material[t] end)
        end
    end)
    
    createInput("✨ Reflectance", "0", function(t)
        if selectedObject and selectedObject:IsA("BasePart") then
            local num = tonumber(t)
            if num then selectedObject.Reflectance = math.clamp(num, 0, 1) end
        end
    end)
    
    -- Physics Section
    createSection("⚡ Fizik")
    
    createButton("🔒 Anchored Aç/Kapa", Color3.fromRGB(100, 100, 0), function()
        if selectedObject and selectedObject:IsA("BasePart") then
            selectedObject.Anchored = not selectedObject.Anchored
        end
    end)
    
    createButton("👻 CanCollide Aç/Kapa", Color3.fromRGB(100, 0, 100), function()
        if selectedObject and selectedObject:IsA("BasePart") then
            selectedObject.CanCollide = not selectedObject.CanCollide
        end
    end)
    
    createButton("🌀 Massless Aç/Kapa", Color3.fromRGB(0, 100, 100), function()
        if selectedObject and selectedObject:IsA("BasePart") then
            selectedObject.Massless = not selectedObject.Massless
        end
    end)
    
    -- Actions Section
    createSection("🛠️ Eylemler")
    
    createButton("🎲 Rastgele Renk", Color3.fromRGB(150, 50, 150), function()
        if selectedObject and selectedObject:IsA("BasePart") then
            selectedObject.BrickColor = BrickColor.Random()
        end
    end)
    
    createButton("📦 Objeyi Kopyala", Color3.fromRGB(0, 150, 0), function()
        if selectedObject and selectedObject.Parent then
            local clone = selectedObject:Clone()
            clone.Parent = selectedObject.Parent
            clone.CFrame = selectedObject.CFrame * CFrame.new(5, 0, 0)
            selectedObject = clone
            selectedLabel.Text = "📦 Seçili: " .. clone.Name
            createStudioHandles(clone)
        end
    end)
    
    createButton("🗑️ Objeyi Sil", Color3.fromRGB(200, 0, 0), function()
        if selectedObject and selectedObject.Parent then
            selectedObject:Destroy()
            selectedObject = nil
            selectedLabel.Text = "📦 Seçili: Yok"
        end
    end)
    
    -- Create Section
    createSection("➕ Yeni Oluştur")
    
    createButton("➕ Yeni Part", Color3.fromRGB(0, 100, 200), function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local newPart = Instance.new("Part")
            newPart.Size = Vector3.new(4, 4, 4)
            newPart.Position = char.HumanoidRootPart.Position + Vector3.new(0, 5, 10)
            newPart.Anchored = true
            newPart.BrickColor = BrickColor.Random()
            newPart.Parent = workspace
            selectedObject = newPart
            selectedLabel.Text = "📦 Seçili: " .. newPart.Name
            createStudioHandles(newPart)
        end
    end)
    
    createButton("🔵 Yeni Sphere", Color3.fromRGB(0, 80, 180), function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local newPart = Instance.new("Part")
            newPart.Shape = Enum.PartType.Ball
            newPart.Size = Vector3.new(4, 4, 4)
            newPart.Position = char.HumanoidRootPart.Position + Vector3.new(0, 5, 10)
            newPart.Anchored = true
            newPart.BrickColor = BrickColor.Random()
            newPart.Parent = workspace
            selectedObject = newPart
            selectedLabel.Text = "📦 Seçili: " .. newPart.Name
            createStudioHandles(newPart)
        end
    end)
    
    createButton("🔷 Yeni Wedge", Color3.fromRGB(0, 60, 160), function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local newPart = Instance.new("WedgePart")
            newPart.Size = Vector3.new(4, 4, 4)
            newPart.Position = char.HumanoidRootPart.Position + Vector3.new(0, 5, 10)
            newPart.Anchored = true
            newPart.BrickColor = BrickColor.Random()
            newPart.Parent = workspace
            selectedObject = newPart
            selectedLabel.Text = "📦 Seçili: " .. newPart.Name
            createStudioHandles(newPart)
        end
    end)
    
    createButton("🔶 Yeni Cylinder", Color3.fromRGB(200, 100, 0), function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local newPart = Instance.new("Part")
            newPart.Shape = Enum.PartType.Cylinder
            newPart.Size = Vector3.new(4, 4, 4)
            newPart.Position = char.HumanoidRootPart.Position + Vector3.new(0, 5, 10)
            newPart.Anchored = true
            newPart.BrickColor = BrickColor.Random()
            newPart.Parent = workspace
            selectedObject = newPart
            selectedLabel.Text = "📦 Seçili: " .. newPart.Name
            createStudioHandles(newPart)
        end
    end)
    
    -- Effects Section
    createSection("✨ Efektler Ekle")
    
    createButton("💡 PointLight Ekle", Color3.fromRGB(200, 200, 0), function()
        if selectedObject and selectedObject:IsA("BasePart") then
            local light = Instance.new("PointLight")
            light.Brightness = 1
            light.Range = 20
            light.Parent = selectedObject
        end
    end)
    
    createButton("🔥 Fire Ekle", Color3.fromRGB(255, 100, 0), function()
        if selectedObject and selectedObject:IsA("BasePart") then
            local fire = Instance.new("Fire")
            fire.Parent = selectedObject
        end
    end)
    
    createButton("💨 Smoke Ekle", Color3.fromRGB(150, 150, 150), function()
        if selectedObject and selectedObject:IsA("BasePart") then
            local smoke = Instance.new("Smoke")
            smoke.Parent = selectedObject
        end
    end)
    
    createButton("✨ Sparkles Ekle", Color3.fromRGB(255, 255, 0), function()
        if selectedObject and selectedObject:IsA("BasePart") then
            local sparkles = Instance.new("Sparkles")
            sparkles.Parent = selectedObject
        end
    end)
    
    createButton("🌟 ParticleEmitter Ekle", Color3.fromRGB(200, 100, 200), function()
        if selectedObject and selectedObject:IsA("BasePart") then
            local particle = Instance.new("ParticleEmitter")
            particle.Rate = 20
            particle.Lifetime = NumberRange.new(1, 2)
            particle.Speed = NumberRange.new(5, 10)
            particle.Parent = selectedObject
        end
    end)
    
    createButton("🧹 Tüm Efektleri Sil", Color3.fromRGB(150, 0, 0), function()
        if selectedObject then
            for _, child in pairs(selectedObject:GetChildren()) do
                if child:IsA("PointLight") or child:IsA("SpotLight") or child:IsA("Fire") or child:IsA("Smoke") or child:IsA("Sparkles") or child:IsA("ParticleEmitter") then
                    child:Destroy()
                end
            end
        end
    end)
    
    -- Tool Events
    builderTool.Equipped:Connect(function()
        builderGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        mainPanel.Visible = true
    end)
    
    builderTool.Unequipped:Connect(function()
        mainPanel.Visible = false
        -- Handles'ları temizle
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:find("StudioHandle") or obj.Name == "BuilderSelection" then
                obj:Destroy()
            end
        end
    end)
    
    -- Drag sistemi
    local dragging = false
    local dragPart = nil
    local dragOffset = nil
    
    builderTool.Activated:Connect(function()
        local target = Mouse.Target
        if target and target:IsA("BasePart") then
            local isPlayerPart = false
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and target:IsDescendantOf(player.Character) then
                    isPlayerPart = true
                    break
                end
            end
            
            if not isPlayerPart then
                if currentBuilderMode == "Select" then
                    selectedObject = target
                    selectedLabel.Text = "📦 Seçili: " .. target.Name .. " [" .. target.ClassName .. "]"
                    createStudioHandles(target)
                    
                elseif currentBuilderMode == "Move" then
                    dragging = true
                    dragPart = target
                    dragOffset = target.Position - Mouse.Hit.p
                    
                elseif currentBuilderMode == "Delete" then
                    target:Destroy()
                    
                elseif currentBuilderMode == "Clone" then
                    local clone = target:Clone()
                    clone.Parent = target.Parent
                    clone.CFrame = target.CFrame * CFrame.new(5, 0, 0)
                    selectedObject = clone
                    selectedLabel.Text = "📦 Seçili: " .. clone.Name
                    createStudioHandles(clone)
                    
                elseif currentBuilderMode == "Scale" then
                    selectedObject = target
                    selectedLabel.Text = "📦 Seçili: " .. target.Name .. " (Boyutlandırma)"
                    createStudioHandles(target)
                    
                elseif currentBuilderMode == "Rotate" then
                    if target then
                        target.CFrame = target.CFrame * CFrame.Angles(0, math.rad(45), 0)
                    end
                end
            end
        end
    end)
    
    -- Mouse move for dragging
    addConnection(Mouse.Move:Connect(function()
        if dragging and dragPart and currentBuilderMode == "Move" then
            dragPart.Position = Mouse.Hit.p + dragOffset
        end
    end))
    
    -- Mouse up to stop dragging
    addConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragPart = nil
        end
    end))
    
    builderTool.Parent = LocalPlayer.Backpack
    return builderTool
end

-- ==================== DÜZELTİLMİŞ KILIÇ SİSTEMİ ====================
local function createSword()
    local sword = Instance.new("Tool")
    sword.Name = "⚔️ Güçlü Kılıç"
    sword.RequiresHandle = true
    sword.CanBeDropped = true
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1.2, 5)
    handle.BrickColor = BrickColor.new("Dark stone grey")
    handle.Material = Enum.Material.Metal
    handle.Parent = sword
    
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://12221720"
    mesh.TextureId = "rbxassetid://12224218"
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Parent = handle
    
    -- ✅ DÜZELTİLDİ: Kılıç artık doğru tutuluyor
    sword.Grip = CFrame.new(0, 0, -1.5) * CFrame.Angles(0, 0, math.rad(180))
    
    local debounce = false
    local damageDebounce = {}
    
    sword.Activated:Connect(function()
        if debounce then return end
        debounce = true
        
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://218504594"
                local track = humanoid:LoadAnimation(anim)
                track:Play()
                
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://12222208"
                sound.Volume = 0.7
                sound.Parent = handle
                sound:Play()
                Debris:AddItem(sound, 1)
            end
        end
        
        wait(0.4)
        debounce = false
        damageDebounce = {}
    end)
    
    handle.Touched:Connect(function(hit)
        if not debounce then return end
        if sword.Parent ~= LocalPlayer.Character then return end
        
        local targetHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
        if targetHumanoid and targetHumanoid ~= LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            if not damageDebounce[targetHumanoid] then
                damageDebounce[targetHumanoid] = true
                targetHumanoid:TakeDamage(swordDamage)
                
                local hitSound = Instance.new("Sound")
                hitSound.SoundId = "rbxassetid://220833976"
                hitSound.Volume = 0.5
                hitSound.Parent = hit
                hitSound:Play()
                Debris:AddItem(hitSound, 1)
            end
        end
    end)
    
    sword.Parent = LocalPlayer.Backpack
    return sword
end

-- ==================== GÖRÜNMEZİ ELLİ SİLAH SİSTEMİ ====================
local function createGun()
    local gun = Instance.new("Tool")
    gun.Name = "🔫 Güçlü Silah"
    gun.RequiresHandle = true
    gun.CanBeDropped = true
    
    -- ✅ GÖRÜNMEZ HANDLE - El boş görünecek
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.1, 0.1, 0.1)
    handle.Transparency = 1  -- Görünmez
    handle.CanCollide = false
    handle.Parent = gun
    
    gun.Grip = CFrame.new(0, 0, 0)
    
    local debounce = false
    
    gun.Activated:Connect(function()
        if debounce then return end
        debounce = true
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Ateş sesi
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://131072992"
            sound.Volume = 0.6
            sound.Parent = character.HumanoidRootPart
            sound:Play()
            Debris:AddItem(sound, 1)
            
            -- Silah ışığı efekti (elden çıkar)
            local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
            local origin = rightHand and rightHand.Position or character.HumanoidRootPart.Position
            local direction = (Mouse.Hit.p - origin).Unit * 1000
            
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {character}
            
            local result = workspace:Raycast(origin, direction, rayParams)
            
            -- Mermi izi
            local bullet = Instance.new("Part")
            bullet.Size = Vector3.new(0.15, 0.15, 4)
            bullet.BrickColor = BrickColor.new("Bright yellow")
            bullet.Material = Enum.Material.Neon
            bullet.Anchored = true
            bullet.CanCollide = false
            bullet.CFrame = CFrame.new(origin, result and result.Position or (origin + direction))
            bullet.Parent = workspace
            
            local endPos = result and result.Position or (origin + direction)
            TweenService:Create(bullet, TweenInfo.new(0.08), {
                CFrame = CFrame.new(endPos, endPos + direction)
            }):Play()
            
            Debris:AddItem(bullet, 0.1)
            
            if result then
                local hit = result.Instance
                local targetHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid") or hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
                if targetHumanoid then
                    targetHumanoid:TakeDamage(gunDamage)
                end
                
                -- Vuruş efekti
                local hitEffect = Instance.new("Part")
                hitEffect.Size = Vector3.new(0.8, 0.8, 0.8)
                hitEffect.Shape = Enum.PartType.Ball
                hitEffect.BrickColor = BrickColor.new("Bright orange")
                hitEffect.Material = Enum.Material.Neon
                hitEffect.Anchored = true
                hitEffect.CanCollide = false
                hitEffect.Position = result.Position
                hitEffect.Parent = workspace
                
                TweenService:Create(hitEffect, TweenInfo.new(0.2), {
                    Size = Vector3.new(2, 2, 2),
                    Transparency = 1
                }):Play()
                
                Debris:AddItem(hitEffect, 0.25)
            end
        end
        
        wait(gunFireRate)
        debounce = false
    end)
    
    gun.Parent = LocalPlayer.Backpack
    return gun
end

-- ==================== BÜYÜ SİSTEMİ ====================
local function createMagicWand()
    local wand = Instance.new("Tool")
    wand.Name = "🔮 Büyü Asası"
    wand.RequiresHandle = true
    wand.CanBeDropped = true
    
    -- Görünmez handle - el boş
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.1, 0.1, 0.1)
    handle.Transparency = 1
    handle.CanCollide = false
    handle.Parent = wand
    
    local currentMagic = "Fireball"
    local magicTypes = {"Fireball", "Ice", "Lightning", "Heal", "Shield"}
    local magicIndex = 1
    
    local debounce = false
    
    -- Büyü değiştirme (Q tuşu)
    addConnection(UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Q then
            if wand.Parent == LocalPlayer.Character then
                magicIndex = magicIndex + 1
                if magicIndex > #magicTypes then magicIndex = 1 end
                currentMagic = magicTypes[magicIndex]
                Rayfield:Notify({Title = "Büyü", Content = "Seçili: " .. currentMagic, Duration = 1})
            end
        end
    end))
    
    local function castFireball()
        local character = LocalPlayer.Character
        if not character then return end
        
        local origin = character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
        local direction = (Mouse.Hit.p - origin).Unit
        
        local fireball = Instance.new("Part")
        fireball.Size = Vector3.new(2, 2, 2)
        fireball.Shape = Enum.PartType.Ball
        fireball.BrickColor = BrickColor.new("Bright orange")
        fireball.Material = Enum.Material.Neon
        fireball.Anchored = false
        fireball.CanCollide = false
        fireball.Position = origin
        fireball.Parent = workspace
        
        local fire = Instance.new("Fire")
        fire.Size = 5
        fire.Heat = 10
        fire.Parent = fireball
        
        local light = Instance.new("PointLight")
        light.Brightness = 2
        light.Range = 15
        light.Color = Color3.fromRGB(255, 150, 0)
        light.Parent = fireball
        
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = direction * 100
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = fireball
        
        -- Ses
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://180204650"
        sound.Volume = 0.5
        sound.Parent = fireball
        sound:Play()
        
        fireball.Touched:Connect(function(hit)
            if hit:IsDescendantOf(character) then return end
            
            local hum = hit.Parent:FindFirstChildOfClass("Humanoid") or hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:TakeDamage(magicDamage)
            end
            
            -- Patlama efekti
            local explosion = Instance.new("Part")
            explosion.Size = Vector3.new(1, 1, 1)
            explosion.Shape = Enum.PartType.Ball
            explosion.BrickColor = BrickColor.new("Bright orange")
            explosion.Material = Enum.Material.Neon
            explosion.Anchored = true
            explosion.CanCollide = false
            explosion.Position = fireball.Position
            explosion.Parent = workspace
            
            TweenService:Create(explosion, TweenInfo.new(0.3), {
                Size = Vector3.new(10, 10, 10),
                Transparency = 1
            }):Play()
            
            Debris:AddItem(explosion, 0.4)
            fireball:Destroy()
        end)
        
        Debris:AddItem(fireball, 5)
    end
    
    local function castIce()
        local character = LocalPlayer.Character
        if not character then return end
        
        local origin = character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
        local direction = (Mouse.Hit.p - origin).Unit
        
        for i = 1, 5 do
            spawn(function()
                wait(i * 0.1)
                local ice = Instance.new("Part")
                ice.Size = Vector3.new(1, 1, 3)
                ice.BrickColor = BrickColor.new("Pastel light blue")
                ice.Material = Enum.Material.Ice
                ice.Transparency = 0.3
                ice.Anchored = false
                ice.CanCollide = false
                ice.Position = origin + Vector3.new(math.random(-2, 2), math.random(-1, 1), 0)
                ice.Parent = workspace
                
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = direction * 80
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Parent = ice
                
                ice.Touched:Connect(function(hit)
                    if hit:IsDescendantOf(character) then return end
                    local hum = hit.Parent:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:TakeDamage(magicDamage / 2)
                        hum.WalkSpeed = hum.WalkSpeed * 0.5
                        wait(2)
                        hum.WalkSpeed = 16
                    end
                    ice:Destroy()
                end)
                
                Debris:AddItem(ice, 3)
            end)
        end
    end
    
    local function castLightning()
        local character = LocalPlayer.Character
        if not character then return end
        
        local targetPos = Mouse.Hit.p
        
        -- Şimşek çizgisi
        local lightning = Instance.new("Part")
        lightning.Size = Vector3.new(1, 200, 1)
        lightning.BrickColor = BrickColor.new("Bright yellow")
        lightning.Material = Enum.Material.Neon
        lightning.Anchored = true
        lightning.CanCollide = false
        lightning.Position = targetPos + Vector3.new(0, 100, 0)
        lightning.Parent = workspace
        
        -- Ses
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://130783738"
        sound.Volume = 1
        sound.Parent = lightning
        sound:Play()
        
        -- Alan hasarı
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if root and hum then
                    local distance = (root.Position - targetPos).Magnitude
                    if distance < 15 then
                        hum:TakeDamage(magicDamage * 1.5)
                    end
                end
            end
        end
        
        TweenService:Create(lightning, TweenInfo.new(0.3), {
            Transparency = 1,
            Size = Vector3.new(5, 200, 5)
        }):Play()
        
        Debris:AddItem(lightning, 0.4)
    end
    
    local function castHeal()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = math.min(humanoid.Health + 30, humanoid.MaxHealth)
            
            -- İyileştirme efekti
            local heal = Instance.new("Part")
            heal.Size = Vector3.new(5, 5, 5)
            heal.Shape = Enum.PartType.Ball
            heal.BrickColor = BrickColor.new("Lime green")
            heal.Material = Enum.Material.Neon
            heal.Transparency = 0.5
            heal.Anchored = true
            heal.CanCollide = false
            heal.Position = character.HumanoidRootPart.Position
            heal.Parent = workspace
            
            TweenService:Create(heal, TweenInfo.new(0.5), {
                Size = Vector3.new(15, 15, 15),
                Transparency = 1
            }):Play()
            
            Debris:AddItem(heal, 0.6)
        end
    end
    
    local function castShield()
        local character = LocalPlayer.Character
        if not character then return end
        
        local shield = Instance.new("Part")
        shield.Size = Vector3.new(8, 8, 1)
        shield.Shape = Enum.PartType.Cylinder
        shield.BrickColor = BrickColor.new("Cyan")
        shield.Material = Enum.Material.ForceField
        shield.Transparency = 0.5
        shield.Anchored = false
        shield.CanCollide = true
        shield.Parent = character
        
        local weld = Instance.new("Weld")
        weld.Part0 = character.HumanoidRootPart
        weld.Part1 = shield
        weld.C0 = CFrame.new(0, 0, 3) * CFrame.Angles(0, 0, math.rad(90))
        weld.Parent = shield
        
        Debris:AddItem(shield, 5)
    end
    
    wand.Activated:Connect(function()
        if debounce then return end
        debounce = true
        
        if currentMagic == "Fireball" then
            castFireball()
        elseif currentMagic == "Ice" then
            castIce()
        elseif currentMagic == "Lightning" then
            castLightning()
        elseif currentMagic == "Heal" then
            castHeal()
        elseif currentMagic == "Shield" then
            castShield()
        end
        
        wait(magicCooldown)
        debounce = false
    end)
    
    wand.Parent = LocalPlayer.Backpack
    return wand
end

-- ==================== KILLER SİSTEMİ ====================
local function KillScript()
    flyEnabled = false
    noclipEnabled = false
    espEnabled = false
    antiAfkEnabled = false
    autoClickerEnabled = false
    spamAutoEnabled = false
    invisibleEnabled = false
    noAnimationsEnabled = false
    noParticlesEnabled = false
    noLightsEnabled = false
    shiftBoostEnabled = false
    infiniteJumpEnabled = false
    fullbrightEnabled = false
    nowe = false
    tpwalking = false
    
    for _, conn in pairs(allConnections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
    end
    allConnections = {}
    
    for _, conn in pairs(espConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    espConnections = {}
    
    for _, line in pairs(tracerLines) do
        if line then pcall(function() line:Remove() end) end
    end
    tracerLines = {}
    
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then pcall(function() obj:Destroy() end) end
    end
    espObjects = {}
    
    if compassGui then compassGui:Destroy() compassGui = nil end
    if builderTool then builderTool:Destroy() builderTool = nil end
    
    -- Handles temizle
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:find("StudioHandle") or obj.Name == "BuilderSelection" then
            pcall(function() obj:Destroy() end)
        end
    end
    
    Lighting.Brightness = OriginalSettings.Brightness
    Lighting.ClockTime = OriginalSettings.ClockTime
    Lighting.FogEnd = OriginalSettings.FogEnd
    Lighting.Ambient = OriginalSettings.Ambient
    Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient
    Lighting.GlobalShadows = OriginalSettings.GlobalShadows
    
    for effect, data in pairs(OriginalSettings.LightingEffects) do
        if effect and effect.Parent then
            pcall(function() effect.Enabled = data.Enabled end)
        end
    end
    
    local character = LocalPlayer.Character
    if character then
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if torso then
            local bg = torso:FindFirstChild("FlyGyro")
            local bv = torso:FindFirstChild("FlyVelocity")
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.WalkSpeed = OriginalSettings.WalkSpeed
            humanoid.JumpPower = OriginalSettings.JumpPower
        end
        
        local animate = character:FindFirstChild("Animate")
        if animate then animate.Disabled = false end
    end
    
    print("TarnakLua-Roblox V3 kapatıldı!")
end
-- ==================== ANA PENCERE ====================
local Window = Rayfield:CreateWindow({
    Name = "TarnakLua-Roblox V3",
    LoadingTitle = "TarnakLua-Roblox",
    LoadingSubtitle = "PageDown/Break ile aç/kapa",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "TarnakLuaV3"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

-- PageDown/Break ile aç kapa
addConnection(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.PageDown or input.KeyCode == Enum.KeyCode.Pause then
        Rayfield:Toggle()
    end
end))

-- ==================== UÇUŞ TAB ====================
local FlyTab = Window:CreateTab("✈️ Uçuş", nil)

local FlySection = FlyTab:CreateSection("Uçuş Kontrolleri")

local flyKeyConnections = {}

local function setupFlyControls()
    for _, conn in pairs(flyKeyConnections) do
        if conn then conn:Disconnect() end
    end
    flyKeyConnections = {}
    
    flyKeyConnections[1] = addConnection(UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1 end
        if input.KeyCode == Enum.KeyCode.S then ctrl.b = -1 end
        if input.KeyCode == Enum.KeyCode.A then ctrl.l = -1 end
        if input.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end
    end))
    
    flyKeyConnections[2] = addConnection(UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0 end
        if input.KeyCode == Enum.KeyCode.S then ctrl.b = 0 end
        if input.KeyCode == Enum.KeyCode.A then ctrl.l = 0 end
        if input.KeyCode == Enum.KeyCode.D then ctrl.r = 0 end
    end))
end

local function cleanupFly()
    for _, conn in pairs(flyKeyConnections) do
        if conn then conn:Disconnect() end
    end
    flyKeyConnections = {}
    
    local character = LocalPlayer.Character
    if character then
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if torso then
            local bg = torso:FindFirstChild("FlyGyro")
            local bv = torso:FindFirstChild("FlyVelocity")
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                pcall(function() humanoid:SetStateEnabled(state, true) end)
            end
        end
        
        local animate = character:FindFirstChild("Animate")
        if animate then animate.Disabled = false end
    end
    
    tpwalking = false
    ctrl = {f = 0, b = 0, l = 0, r = 0}
    lastctrl = {f = 0, b = 0, l = 0, r = 0}
    currentSpeed = 0
end

local CurrentSpeedLabel = FlyTab:CreateLabel("📊 Mevcut Uçuş Hızı: " .. speeds)

local FlyToggle = FlyTab:CreateToggle({
    Name = "✈️ Uçuşu Aktif Et (WASD)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        flyEnabled = Value
        nowe = Value
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        if Value then
            setupFlyControls()
            
            tpwalking = false
            wait(0.1)
            for i = 1, speeds do
                spawn(function()
                    local hb = RunService.Heartbeat
                    tpwalking = true
                    local chr = LocalPlayer.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    while tpwalking and flyEnabled and hb:Wait() and chr and hum and hum.Parent do
                        if hum.MoveDirection.Magnitude > 0 then
                            local boost = 1
                            if shiftBoostEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                                boost = shiftBoostMultiplier
                            end
                            chr:TranslateBy(hum.MoveDirection * boost)
                        end
                    end
                end)
            end
            
            local animate = character:FindFirstChild("Animate")
            if animate then animate.Disabled = true end
            
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(0)
            end
            
            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                pcall(function() humanoid:SetStateEnabled(state, false) end)
            end
            humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
            
            local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
            if not torso then return end
            
            local bgNew = Instance.new("BodyGyro")
            bgNew.Name = "FlyGyro"
            bgNew.P = 9e4
            bgNew.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bgNew.cframe = torso.CFrame
            bgNew.Parent = torso
            
            local bvNew = Instance.new("BodyVelocity")
            bvNew.Name = "FlyVelocity"
            bvNew.velocity = Vector3.new(0, 0.1, 0)
            bvNew.maxForce = Vector3.new(9e9, 9e9, 9e9)
            bvNew.Parent = torso
            
            humanoid.PlatformStand = true
            
            spawn(function()
                while flyEnabled and nowe and character and humanoid and humanoid.Parent do
                    RunService.RenderStepped:Wait()
                    
                    local bgObj = torso:FindFirstChild("FlyGyro")
                    local bvObj = torso:FindFirstChild("FlyVelocity")
                    
                    if not bgObj or not bvObj then break end
                    
                    if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                        currentSpeed = currentSpeed + 0.5 + (currentSpeed / maxspeed)
                        if currentSpeed > maxspeed then currentSpeed = maxspeed end
                    elseif currentSpeed ~= 0 then
                        currentSpeed = currentSpeed - 1
                        if currentSpeed < 0 then currentSpeed = 0 end
                    end
                    
                    local speedMultiplier = speeds
                    if shiftBoostEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        speedMultiplier = speedMultiplier * shiftBoostMultiplier
                    end
                    
                    local camCF = Camera.CoordinateFrame
                    
                    if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                        bvObj.velocity = ((camCF.lookVector * (ctrl.f + ctrl.b)) + 
                            ((camCF * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - camCF.p)) * currentSpeed * speedMultiplier
                        lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                    elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and currentSpeed ~= 0 then
                        bvObj.velocity = ((camCF.lookVector * (lastctrl.f + lastctrl.b)) + 
                            ((camCF * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - camCF.p)) * currentSpeed * speedMultiplier
                    else
                        bvObj.velocity = Vector3.new(0, 0, 0)
                    end
                    
                    bgObj.cframe = camCF * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * currentSpeed / maxspeed), 0, 0)
                end
                
                cleanupFly()
            end)
            
            Rayfield:Notify({Title = "Uçuş", Content = "Aktif! WASD ile hareket", Duration = 2})
        else
            cleanupFly()
            Rayfield:Notify({Title = "Uçuş", Content = "Kapatıldı", Duration = 2})
        end
    end,
})

local NoclipToggle = FlyTab:CreateToggle({
    Name = "👻 NoClip (Duvarlardan Geç)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        noclipEnabled = Value
        if Value then
            spawn(function()
                while noclipEnabled do
                    RunService.Stepped:Wait()
                    local character = LocalPlayer.Character
                    if character then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
            Rayfield:Notify({Title = "NoClip", Content = "Aktif!", Duration = 2})
        else
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
})

FlyTab:CreateInput({
    Name = "⚡ Uçuş Hızı Ayarla",
    PlaceholderText = tostring(speeds),
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 1 then
            speeds = math.floor(num)
            CurrentSpeedLabel:Set("📊 Mevcut Uçuş Hızı: " .. speeds)
            
            if flyEnabled then
                tpwalking = false
                wait(0.1)
                for i = 1, speeds do
                    spawn(function()
                        local hb = RunService.Heartbeat
                        tpwalking = true
                        local chr = LocalPlayer.Character
                        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                        while tpwalking and flyEnabled and hb:Wait() and chr and hum and hum.Parent do
                            if hum.MoveDirection.Magnitude > 0 then
                                chr:TranslateBy(hum.MoveDirection)
                            end
                        end
                    end)
                end
            end
            
            Rayfield:Notify({Title = "Hız", Content = "Yeni: " .. speeds, Duration = 1})
        end
    end,
})

local HeightSection = FlyTab:CreateSection("Yükseklik Kontrolü")

local upHolding, downHolding = false, false

FlyTab:CreateButton({
    Name = "⬆️ Yukarı Çık (Toggle)",
    Callback = function()
        upHolding = not upHolding
        downHolding = false
        if upHolding then
            Rayfield:Notify({Title = "Yükseklik", Content = "Yukarı çıkılıyor...", Duration = 1})
            spawn(function()
                while upHolding do
                    wait()
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)
                    end
                end
            end)
        else
            Rayfield:Notify({Title = "Yükseklik", Content = "Durduruldu", Duration = 1})
        end
    end,
})

FlyTab:CreateButton({
    Name = "⬇️ Aşağı İn (Toggle)",
    Callback = function()
        downHolding = not downHolding
        upHolding = false
        if downHolding then
            Rayfield:Notify({Title = "Yükseklik", Content = "Aşağı iniliyor...", Duration = 1})
            spawn(function()
                while downHolding do
                    wait()
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -1, 0)
                    end
                end
            end)
        else
            Rayfield:Notify({Title = "Yükseklik", Content = "Durduruldu", Duration = 1})
        end
    end,
})

FlyTab:CreateButton({
    Name = "⏹️ Yükseklik Durdur",
    Callback = function()
        upHolding = false
        downHolding = false
        Rayfield:Notify({Title = "Yükseklik", Content = "Tümü durduruldu", Duration = 1})
    end,
})

-- ==================== HAREKET TAB ====================
local MovementTab = Window:CreateTab("🏃 Hareket", nil)

local WalkSection = MovementTab:CreateSection("Yürüme & Zıplama")

local CurrentWalkLabel = MovementTab:CreateLabel("📊 Yürüme: " .. walkSpeedValue .. " | Zıplama: " .. jumpPowerValue)

MovementTab:CreateInput({
    Name = "🏃 Yürüme Hızı",
    PlaceholderText = "16",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 0 then
            walkSpeedValue = num
            CurrentWalkLabel:Set("📊 Yürüme: " .. walkSpeedValue .. " | Zıplama: " .. jumpPowerValue)
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = num end
            end
            Rayfield:Notify({Title = "Yürüme", Content = "Hız: " .. num, Duration = 1})
        end
    end,
})

MovementTab:CreateInput({
    Name = "🦘 Zıplama Gücü",
    PlaceholderText = "50",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 0 then
            jumpPowerValue = num
            CurrentWalkLabel:Set("📊 Yürüme: " .. walkSpeedValue .. " | Zıplama: " .. jumpPowerValue)
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = num
                    humanoid.UseJumpPower = true
                end
            end
            Rayfield:Notify({Title = "Zıplama", Content = "Güç: " .. num, Duration = 1})
        end
    end,
})

MovementTab:CreateButton({
    Name = "🔄 Varsayılana Sıfırla",
    Callback = function()
        walkSpeedValue = 16
        jumpPowerValue = 50
        CurrentWalkLabel:Set("📊 Yürüme: 16 | Zıplama: 50")
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
                humanoid.JumpPower = 50
            end
        end
        Rayfield:Notify({Title = "Sıfırlandı", Content = "Varsayılan değerler", Duration = 1})
    end,
})

MovementTab:CreateToggle({
    Name = "♾️ Sonsuz Zıplama",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        infiniteJumpEnabled = Value
        if Value then
            addConnection(UserInputService.JumpRequest:Connect(function()
                if infiniteJumpEnabled then
                    local character = LocalPlayer.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
                    end
                end
            end))
            Rayfield:Notify({Title = "Sonsuz Zıplama", Content = "Aktif!", Duration = 2})
        end
    end,
})

-- Shift Boost
local ShiftSection = MovementTab:CreateSection("Shift Hızlanma")

local ShiftMultLabel = MovementTab:CreateLabel("📊 Shift Çarpanı: " .. shiftBoostMultiplier .. "x")

MovementTab:CreateInput({
    Name = "⚡ Shift Hızlanma Çarpanı",
    PlaceholderText = "2",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 1 then
            shiftBoostMultiplier = num
            ShiftMultLabel:Set("📊 Shift Çarpanı: " .. shiftBoostMultiplier .. "x")
            Rayfield:Notify({Title = "Shift Çarpan", Content = num .. "x", Duration = 1})
        end
    end,
})

MovementTab:CreateToggle({
    Name = "⚡ Shift Hızlanma Aktif",
    CurrentValue = false,
    Flag = "ShiftBoostToggle",
    Callback = function(Value)
        shiftBoostEnabled = Value
        if Value then
            spawn(function()
                while shiftBoostEnabled do
                    RunService.Heartbeat:Wait()
                    local character = LocalPlayer.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                                humanoid.WalkSpeed = walkSpeedValue * shiftBoostMultiplier
                            else
                                humanoid.WalkSpeed = walkSpeedValue
                            end
                        end
                    end
                end
                
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid.WalkSpeed = walkSpeedValue end
                end
            end)
            Rayfield:Notify({Title = "Shift Boost", Content = "Aktif! " .. shiftBoostMultiplier .. "x", Duration = 2})
        end
    end,
})

-- Dash
local DashSection = MovementTab:CreateSection("Dash (Q Tuşu)")

local DashLabel = MovementTab:CreateLabel("📊 Dash Mesafesi: " .. dashDistance)

MovementTab:CreateInput({
    Name = "💨 Dash Mesafesi",
    PlaceholderText = "50",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 1 then
            dashDistance = num
            DashLabel:Set("📊 Dash Mesafesi: " .. dashDistance)
            Rayfield:Notify({Title = "Dash", Content = "Mesafe: " .. num, Duration = 1})
        end
    end,
})

MovementTab:CreateToggle({
    Name = "💨 Dash Aktif (Animasyonlu Q)",
    CurrentValue = false,
    Flag = "DashToggle",
    Callback = function(Value)
        dashEnabled = Value
        if Value then
            addConnection(UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.KeyCode == Enum.KeyCode.Q and dashEnabled then
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            local direction = humanoid.MoveDirection
                            if direction.Magnitude == 0 then
                                direction = character.HumanoidRootPart.CFrame.LookVector
                            end
                            
                            -- Dash animasyonu
                            pcall(function()
                                local anim = Instance.new("Animation")
                                anim.AnimationId = "rbxassetid://3296660365"
                                local track = humanoid:LoadAnimation(anim)
                                track:Play()
                                Debris:AddItem(anim, 2)
                            end)
                            
                            -- Görsel efekt - başlangıç
                            local startEffect = Instance.new("Part")
                            startEffect.Size = Vector3.new(3, 3, 3)
                            startEffect.Shape = Enum.PartType.Ball
                            startEffect.Material = Enum.Material.Neon
                            startEffect.BrickColor = BrickColor.new("Cyan")
                            startEffect.Transparency = 0.3
                            startEffect.Anchored = true
                            startEffect.CanCollide = false
                            startEffect.Position = character.HumanoidRootPart.Position
                            startEffect.Parent = workspace
                            
                            TweenService:Create(startEffect, TweenInfo.new(0.4), {
                                Size = Vector3.new(8, 8, 8),
                                Transparency = 1
                            }):Play()
                            Debris:AddItem(startEffect, 0.5)
                            
                            -- Dash çizgisi efekti
                            local trail = Instance.new("Part")
                            trail.Size = Vector3.new(1, 1, dashDistance)
                            trail.Material = Enum.Material.Neon
                            trail.BrickColor = BrickColor.new("Toothpaste")
                            trail.Transparency = 0.5
                            trail.Anchored = true
                            trail.CanCollide = false
                            trail.CFrame = CFrame.new(character.HumanoidRootPart.Position + (direction * dashDistance / 2), character.HumanoidRootPart.Position + (direction * dashDistance))
                            trail.Parent = workspace
                            
                            TweenService:Create(trail, TweenInfo.new(0.3), {
                                Transparency = 1,
                                Size = Vector3.new(0.1, 0.1, dashDistance)
                            }):Play()
                            Debris:AddItem(trail, 0.4)
                            
                            -- Dash hareketi - smooth
                            local startPos = character.HumanoidRootPart.CFrame
                            local endPos = startPos + (direction * dashDistance)
                            
                            TweenService:Create(character.HumanoidRootPart, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                CFrame = endPos
                            }):Play()
                            
                            -- Ses efekti
                            local sound = Instance.new("Sound")
                            sound.SoundId = "rbxassetid://1489942817"
                            sound.Volume = 0.4
                            sound.Parent = character.HumanoidRootPart
                            sound:Play()
                            Debris:AddItem(sound, 1)
                        end
                    end
                end
            end))
            Rayfield:Notify({Title = "Dash", Content = "Q tuşu ile " .. dashDistance .. " studs dash!", Duration = 2})
        end
    end,
})

-- ==================== ARAÇLAR TAB ====================
local ToolsTab = Window:CreateTab("🔧 Araçlar", nil)

local WeaponSection = ToolsTab:CreateSection("⚔️ Silahlar")

-- Kılıç Ayarları
local SwordDamageLabel = ToolsTab:CreateLabel("⚔️ Kılıç Hasarı: " .. swordDamage)

ToolsTab:CreateInput({
    Name = "⚔️ Kılıç Hasarı Ayarla",
    PlaceholderText = "35",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 1 then
            swordDamage = num
            SwordDamageLabel:Set("⚔️ Kılıç Hasarı: " .. swordDamage)
            Rayfield:Notify({Title = "Kılıç", Content = "Hasar: " .. num, Duration = 1})
        end
    end,
})

ToolsTab:CreateButton({
    Name = "🗡️ Kılıç Ver",
    Callback = function()
        createSword()
        Rayfield:Notify({Title = "Kılıç", Content = "Envantere eklendi!", Duration = 2})
    end,
})

-- Silah Ayarları
local GunSection = ToolsTab:CreateSection("🔫 Silah Ayarları")

local GunDamageLabel = ToolsTab:CreateLabel("🔫 Silah Hasarı: " .. gunDamage)

ToolsTab:CreateInput({
    Name = "🔫 Silah Hasarı Ayarla",
    PlaceholderText = "25",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 1 then
            gunDamage = num
            GunDamageLabel:Set("🔫 Silah Hasarı: " .. gunDamage)
            Rayfield:Notify({Title = "Silah", Content = "Hasar: " .. num, Duration = 1})
        end
    end,
})

ToolsTab:CreateInput({
    Name = "⏱️ Ateş Hızı (saniye)",
    PlaceholderText = "0.15",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 0.01 then
            gunFireRate = num
            Rayfield:Notify({Title = "Silah", Content = "Ateş Hızı: " .. num .. "s", Duration = 1})
        end
    end,
})

ToolsTab:CreateButton({
    Name = "🔫 Silah Ver (Görünmez El)",
    Callback = function()
        createGun()
        Rayfield:Notify({Title = "Silah", Content = "Envantere eklendi! El boş görünür.", Duration = 2})
    end,
})

-- Büyü Ayarları
local MagicSection = ToolsTab:CreateSection("🔮 Büyü Sistemi")

local MagicDamageLabel = ToolsTab:CreateLabel("🔮 Büyü Hasarı: " .. magicDamage)

ToolsTab:CreateInput({
    Name = "🔮 Büyü Hasarı Ayarla",
    PlaceholderText = "40",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 1 then
            magicDamage = num
            MagicDamageLabel:Set("🔮 Büyü Hasarı: " .. magicDamage)
            Rayfield:Notify({Title = "Büyü", Content = "Hasar: " .. num, Duration = 1})
        end
    end,
})

ToolsTab:CreateInput({
    Name = "⏱️ Büyü Bekleme Süresi",
    PlaceholderText = "1",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 0.1 then
            magicCooldown = num
            Rayfield:Notify({Title = "Büyü", Content = "Bekleme: " .. num .. "s", Duration = 1})
        end
    end,
})

ToolsTab:CreateButton({
    Name = "🔮 Büyü Asası Ver",
    Callback = function()
        createMagicWand()
        Rayfield:Notify({Title = "Büyü", Content = "Q ile büyü değiştir! Fireball, Ice, Lightning, Heal, Shield", Duration = 4})
    end,
})

ToolsTab:CreateParagraph({
    Title = "🔮 Büyü Türleri",
    Content = "🔥 Fireball - Ateş topu fırlat\n❄️ Ice - Yavaşlatan buz\n⚡ Lightning - Şimşek çaktır\n💚 Heal - Kendini iyileştir\n🛡️ Shield - Kalkan oluştur\n\nQ tuşu ile değiştir!"
})

-- Builder Tool
local BuilderSection = ToolsTab:CreateSection("🔨 Studio Builder")

ToolsTab:CreateButton({
    Name = "🔧 Studio Builder Ver",
    Callback = function()
        createBuilderTool()
        Rayfield:Notify({Title = "Builder Tool", Content = "Roblox Studio tarzı! Mavi kutularla düzenle.", Duration = 3})
    end,
})

ToolsTab:CreateParagraph({
    Title = "📖 Builder Kullanımı",
    Content = "1. Tool'u equip et\n2. Objelere tıkla (mavi kutu belirir)\n3. Sağdaki panelden düzenle\n4. Sürükle-bırak ile taşı\n5. X,Y,Z ayrı ayrı ayarla\n6. Modlar: Select/Move/Scale/Rotate/Delete/Clone"
})

-- ==================== OTOMASYON TAB ====================
local AutoTab = Window:CreateTab("🤖 Otomasyon", nil)

local AutoClickSection = AutoTab:CreateSection("🖱️ Auto Clicker")

local AutoClickerToggle
AutoClickerToggle = AutoTab:CreateToggle({
    Name = "🖱️ Auto Clicker",
    CurrentValue = false,
    Flag = "AutoClickerToggle",
    Callback = function(Value)
        autoClickerEnabled = Value
        if Value then
            spawn(function()
                while autoClickerEnabled do
                    wait(autoClickerDelay)
                    pcall(function()
                        local VIM = game:GetService("VirtualInputManager")
                        VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 0)
                        wait(0.01)
                        VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 0)
                    end)
                end
            end)
            Rayfield:Notify({Title = "Auto Clicker", Content = "Aktif! Kapatmak için: " .. tostring(autoClickerToggleKey):gsub("Enum.KeyCode.", ""), Duration = 2})
        else
            Rayfield:Notify({Title = "Auto Clicker", Content = "Kapatıldı", Duration = 1})
        end
    end,
})

-- Auto clicker toggle tuşu listener
addConnection(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == autoClickerToggleKey then
        autoClickerEnabled = not autoClickerEnabled
        if AutoClickerToggle then AutoClickerToggle:Set(autoClickerEnabled) end
        Rayfield:Notify({Title = "Auto Clicker", Content = autoClickerEnabled and "Açıldı" or "Kapandı", Duration = 1})
    end
end))

AutoTab:CreateInput({
    Name = "⏱️ Tıklama Aralığı (saniye)",
    PlaceholderText = "0.1",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num > 0 then
            autoClickerDelay = num
            Rayfield:Notify({Title = "Aralık", Content = num .. " saniye", Duration = 1})
        end
    end,
})

local acKeyLabel = AutoTab:CreateLabel("🎮 Açma/Kapama Tuşu: " .. tostring(autoClickerToggleKey):gsub("Enum.KeyCode.", ""))

AutoTab:CreateInput({
    Name = "🎮 Açma/Kapama Tuşu Değiştir",
    PlaceholderText = "X, SPACE, F1, CTRL...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local key = getKeyFromString(Text)
        if key then
            autoClickerToggleKey = key
            acKeyLabel:Set("🎮 Açma/Kapama Tuşu: " .. Text:upper())
            Rayfield:Notify({Title = "Tuş Ayarlandı", Content = Text:upper(), Duration = 2})
        else
            Rayfield:Notify({Title = "Hata", Content = "Geçersiz tuş!", Duration = 2})
        end
    end,
})

-- Tuş Spam
local SpamSection = AutoTab:CreateSection("⌨️ Tuş Spam")

local SpamAutoToggle
SpamAutoToggle = AutoTab:CreateToggle({
    Name = "⌨️ Tuş Spam Aktif",
    CurrentValue = false,
    Flag = "SpamAutoToggle",
    Callback = function(Value)
        spamAutoEnabled = Value
        if Value then
            spawn(function()
                while spamAutoEnabled do
                    if spamAutoDelay > 0 then
                        wait(spamAutoDelay)
                    else
                        RunService.Heartbeat:Wait()
                    end
                    
                    pcall(function()
                        local VIM = game:GetService("VirtualInputManager")
                        VIM:SendKeyEvent(true, spamAutoKey, false, game)
                        wait(0.01)
                        VIM:SendKeyEvent(false, spamAutoKey, false, game)
                    end)
                end
            end)
            Rayfield:Notify({Title = "Tuş Spam", Content = "Aktif! Tuş: " .. tostring(spamAutoKey):gsub("Enum.KeyCode.", ""), Duration = 2})
        else
            Rayfield:Notify({Title = "Tuş Spam", Content = "Kapatıldı", Duration = 1})
        end
    end,
})

local spamKeyLabel = AutoTab:CreateLabel("🎯 Spam Tuşu: " .. tostring(spamAutoKey):gsub("Enum.KeyCode.", ""))

AutoTab:CreateInput({
    Name = "🎮 Spam Tuşu Değiştir",
    PlaceholderText = "E, F, SPACE, ENTER...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local key = getKeyFromString(Text)
        if key then
            spamAutoKey = key
            spamKeyLabel:Set("🎯 Spam Tuşu: " .. Text:upper())
            Rayfield:Notify({Title = "Spam Tuşu", Content = Text:upper(), Duration = 2})
        else
            Rayfield:Notify({Title = "Hata", Content = "Geçersiz tuş!", Duration = 2})
        end
    end,
})

AutoTab:CreateInput({
    Name = "⏱️ Spam Aralığı (0 = sürekli)",
    PlaceholderText = "0.1",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 0 then
            spamAutoDelay = num
            Rayfield:Notify({Title = "Spam Aralığı", Content = num == 0 and "Sürekli" or (num .. " saniye"), Duration = 1})
        end
    end,
})

-- Anti AFK
local AntiAFKSection = AutoTab:CreateSection("💤 Anti AFK")

AutoTab:CreateToggle({
    Name = "💤 Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFKToggle",
    Callback = function(Value)
        antiAfkEnabled = Value
        if Value then
            spawn(function()
                while antiAfkEnabled do
                    wait(60)
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                end
            end)
            
            addConnection(LocalPlayer.Idled:Connect(function()
                if antiAfkEnabled then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end))
            
            Rayfield:Notify({Title = "Anti AFK", Content = "Aktif! Artık atılmayacaksın.", Duration = 3})
        else
            Rayfield:Notify({Title = "Anti AFK", Content = "Kapatıldı", Duration = 1})
        end
    end,
})

-- ==================== ESP TAB ====================
local ESPTab = Window:CreateTab("👁️ ESP", nil)

local ESPSection = ESPTab:CreateSection("Oyuncu ESP")

local function clearESP()
    for _, conn in pairs(espConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    espConnections = {}
    
    for _, line in pairs(tracerLines) do
        if line then pcall(function() line:Remove() end) end
    end
    tracerLines = {}
    
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then pcall(function() obj:Destroy() end) end
    end
    espObjects = {}
end

local function createPlayerESP(player)
    if player == LocalPlayer or not player.Character then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    table.insert(espObjects, highlight)
    
    -- Billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = rootPart
    billboard.Size = UDim2.new(0, 180, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    table.insert(espObjects, billboard)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 22)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0, 18)
    distanceLabel.Position = UDim2.new(0, 0, 0, 22)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    distanceLabel.Parent = billboard
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(1, 0, 0, 16)
    healthLabel.Position = UDim2.new(0, 0, 0, 40)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.TextStrokeTransparency = 0
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.TextSize = 11
    healthLabel.Parent = billboard
    
    -- Tracer
    local tracerLine
    pcall(function()
        tracerLine = Drawing.new("Line")
        tracerLine.Visible = true
        tracerLine.Color = Color3.fromRGB(255, 255, 0)
        tracerLine.Thickness = 2
        tracerLine.Transparency = 1
        table.insert(tracerLines, tracerLine)
    end)
    
    -- Update loop
    local updateConn = addConnection(RunService.RenderStepped:Connect(function()
        if not espEnabled or not player or not player.Character then return end
        
        local char = player.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if not hum or not root then return end
        
        local localChar = LocalPlayer.Character
        if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
        
        local distance = (root.Position - localChar.HumanoidRootPart.Position).Magnitude
        distanceLabel.Text = "📏 " .. math.floor(distance) .. " studs"
        
        local health = math.floor(hum.Health)
        local maxHealth = math.floor(hum.MaxHealth)
        healthLabel.Text = "❤️ " .. health .. "/" .. maxHealth
        
        if health > maxHealth * 0.5 then
            healthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        elseif health > maxHealth * 0.25 then
            healthLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        else
            healthLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        if tracerLine then
            local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
            tracerLine.Visible = onScreen
            if onScreen then
                tracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
            end
        end
    end))
    table.insert(espConnections, updateConn)
    
    -- On death
    local diedConn = addConnection(humanoid.Died:Connect(function()
        if highlight and highlight.Parent then highlight:Destroy() end
        if billboard and billboard.Parent then billboard:Destroy() end
        if tracerLine then pcall(function() tracerLine:Remove() end) end
    end))
    table.insert(espConnections, diedConn)
end

ESPTab:CreateToggle({
    Name = "👁️ ESP Aktif (Wallhack)",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        espEnabled = Value
        if Value then
            clearESP()
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    createPlayerESP(player)
                end
            end
            
            addConnection(Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    wait(1)
                    if espEnabled then createPlayerESP(player) end
                end)
            end))
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    addConnection(player.CharacterAdded:Connect(function()
                        wait(1)
                        if espEnabled then createPlayerESP(player) end
                    end))
                end
            end
            
            Rayfield:Notify({Title = "ESP", Content = "Aktif! Tüm oyuncuları görebilirsin.", Duration = 3})
        else
            clearESP()
            Rayfield:Notify({Title = "ESP", Content = "Kapatıldı", Duration = 1})
        end
    end,
})

ESPTab:CreateParagraph({
    Title = "📖 ESP Bilgi",
    Content = "• Oyuncuları duvarların arkasından gör\n• Sarı çizgiler senden oyunculara gider\n• Mesafe ve can bilgisi gösterilir\n• Takım renkleri kullanılır"
})
-- ==================== GÖRÜNÜRLÜK TAB ====================
local VisibilityTab = Window:CreateTab("👻 Görünürlük", nil)

-- Karakter Bölümü
local CharSection = VisibilityTab:CreateSection("👤 Karakter")

VisibilityTab:CreateToggle({
    Name = "👻 Görünmez + Sarı Küre",
    CurrentValue = false,
    Flag = "InvisibleToggle",
    Callback = function(Value)
        invisibleEnabled = Value
        local character = LocalPlayer.Character
        if not character then return end
        
        if Value then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = 1
                end
            end
            
            local existingSphere = character:FindFirstChild("YellowSphere")
            if existingSphere then existingSphere:Destroy() end
            
            local sphere = Instance.new("Part")
            sphere.Name = "YellowSphere"
            sphere.Shape = Enum.PartType.Ball
            sphere.Size = Vector3.new(4, 4, 4)
            sphere.BrickColor = BrickColor.new("Bright yellow")
            sphere.Material = Enum.Material.Neon
            sphere.CanCollide = false
            sphere.Anchored = false
            sphere.Parent = character
            
            local weld = Instance.new("Weld")
            weld.Part0 = character:FindFirstChild("HumanoidRootPart")
            weld.Part1 = sphere
            weld.Parent = sphere
            
            Rayfield:Notify({Title = "Görünmezlik", Content = "Aktif! Sarı küre takılı.", Duration = 2})
        else
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "YellowSphere" then
                    part.Transparency = 0
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = 0
                end
            end
            
            local sphere = character:FindFirstChild("YellowSphere")
            if sphere then sphere:Destroy() end
            
            Rayfield:Notify({Title = "Görünmezlik", Content = "Kapatıldı", Duration = 1})
        end
    end,
})

-- Animasyon Bölümü
local AnimSection = VisibilityTab:CreateSection("🎭 Animasyonlar")

VisibilityTab:CreateToggle({
    Name = "🚫 Tüm Animasyonları Kapat",
    CurrentValue = false,
    Flag = "NoAnimationsToggle",
    Callback = function(Value)
        noAnimationsEnabled = Value
        local character = LocalPlayer.Character
        if not character then return end
        
        local animate = character:FindFirstChild("Animate")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if Value then
            if animate then animate.Disabled = true end
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
            end
            Rayfield:Notify({Title = "Animasyonlar", Content = "Kapatıldı!", Duration = 2})
        else
            if animate then animate.Disabled = false end
            Rayfield:Notify({Title = "Animasyonlar", Content = "Açıldı!", Duration = 1})
        end
    end,
})

VisibilityTab:CreateButton({
    Name = "⏹️ Tüm Animasyonları Durdur",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
            end
        end
        Rayfield:Notify({Title = "Animasyonlar", Content = "Durduruldu!", Duration = 1})
    end,
})

-- Efektler Bölümü
local EffectSection = VisibilityTab:CreateSection("✨ Efektler")

VisibilityTab:CreateToggle({
    Name = "🚫 Partikül Efektleri Kapat",
    CurrentValue = false,
    Flag = "NoParticlesToggle",
    Callback = function(Value)
        noParticlesEnabled = Value
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = not Value
            end
        end
        
        if Value then
            addConnection(workspace.DescendantAdded:Connect(function(obj)
                if noParticlesEnabled then
                    if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Trail") or obj:IsA("Beam") then
                        obj.Enabled = false
                    end
                end
            end))
        end
        
        Rayfield:Notify({Title = "Partiküller", Content = Value and "Kapatıldı!" or "Açıldı!", Duration = 2})
    end,
})

-- Işıklandırma Bölümü
local LightSection = VisibilityTab:CreateSection("💡 Işıklandırma")

VisibilityTab:CreateToggle({
    Name = "☀️ Fullbright (Tam Aydınlık)",
    CurrentValue = false,
    Flag = "FullbrightToggle",
    Callback = function(Value)
        fullbrightEnabled = Value
        
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
            Rayfield:Notify({Title = "Fullbright", Content = "Her yer aydınlık!", Duration = 2})
        else
            Lighting.Brightness = OriginalSettings.Brightness
            Lighting.ClockTime = OriginalSettings.ClockTime
            Lighting.FogEnd = OriginalSettings.FogEnd
            Lighting.GlobalShadows = OriginalSettings.GlobalShadows
            Lighting.Ambient = OriginalSettings.Ambient
            Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient
            Rayfield:Notify({Title = "Fullbright", Content = "Kapatıldı", Duration = 1})
        end
    end,
})

VisibilityTab:CreateToggle({
    Name = "🌙 Gece Görüşü",
    CurrentValue = false,
    Flag = "NightVisionToggle",
    Callback = function(Value)
        nightVisionEnabled = Value
        
        if Value then
            Lighting.Ambient = Color3.fromRGB(150, 255, 150)
            Lighting.OutdoorAmbient = Color3.fromRGB(150, 255, 150)
            Lighting.Brightness = 3
            Rayfield:Notify({Title = "Gece Görüşü", Content = "Aktif!", Duration = 2})
        else
            Lighting.Ambient = OriginalSettings.Ambient
            Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient
            Lighting.Brightness = OriginalSettings.Brightness
            Rayfield:Notify({Title = "Gece Görüşü", Content = "Kapatıldı", Duration = 1})
        end
    end,
})

VisibilityTab:CreateToggle({
    Name = "🚫 Gölgeleri Kapat",
    CurrentValue = false,
    Flag = "NoShadowsToggle",
    Callback = function(Value)
        noShadowsEnabled = Value
        Lighting.GlobalShadows = not Value
        Rayfield:Notify({Title = "Gölgeler", Content = Value and "Kapatıldı!" or "Açıldı!", Duration = 1})
    end,
})

VisibilityTab:CreateToggle({
    Name = "🌫️ Sisi Kapat",
    CurrentValue = false,
    Flag = "NoFogToggle",
    Callback = function(Value)
        noFogEnabled = Value
        
        if Value then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
        else
            Lighting.FogEnd = OriginalSettings.FogEnd
            Lighting.FogStart = OriginalSettings.FogStart or 0
        end
        
        Rayfield:Notify({Title = "Sis", Content = Value and "Kapatıldı!" or "Açıldı!", Duration = 1})
    end,
})

VisibilityTab:CreateToggle({
    Name = "🚫 Tüm Işıkları Kapat",
    CurrentValue = false,
    Flag = "NoLightsToggle",
    Callback = function(Value)
        noLightsEnabled = Value
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj.Enabled = not Value
            end
        end
        
        Rayfield:Notify({Title = "Işıklar", Content = Value and "Kapatıldı!" or "Açıldı!", Duration = 1})
    end,
})

-- Post-Processing Bölümü
local PostSection = VisibilityTab:CreateSection("🎨 Post-Processing")

VisibilityTab:CreateToggle({
    Name = "🚫 Blur Efekti Kapat",
    CurrentValue = false,
    Flag = "NoBlurToggle",
    Callback = function(Value)
        noBlurEnabled = Value
        
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BlurEffect") then
                effect.Enabled = not Value
            end
        end
        
        Rayfield:Notify({Title = "Blur", Content = Value and "Kapatıldı!" or "Açıldı!", Duration = 1})
    end,
})

VisibilityTab:CreateToggle({
    Name = "🚫 Bloom Efekti Kapat",
    CurrentValue = false,
    Flag = "NoBloomToggle",
    Callback = function(Value)
        noBloomEnabled = Value
        
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") then
                effect.Enabled = not Value
            end
        end
        
        Rayfield:Notify({Title = "Bloom", Content = Value and "Kapatıldı!" or "Açıldı!", Duration = 1})
    end,
})

VisibilityTab:CreateToggle({
    Name = "🚫 Sun Rays Kapat",
    CurrentValue = false,
    Flag = "NoSunRaysToggle",
    Callback = function(Value)
        noSunRaysEnabled = Value
        
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("SunRaysEffect") then
                effect.Enabled = not Value
            end
        end
        
        Rayfield:Notify({Title = "Sun Rays", Content = Value and "Kapatıldı!" or "Açıldı!", Duration = 1})
    end,
})

VisibilityTab:CreateToggle({
    Name = "🚫 Depth of Field Kapat",
    CurrentValue = false,
    Flag = "NoDOFToggle",
    Callback = function(Value)
        noDOFEnabled = Value
        
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = not Value
            end
        end
        
        Rayfield:Notify({Title = "DOF", Content = Value and "Kapatıldı!" or "Açıldı!", Duration = 1})
    end,
})

VisibilityTab:CreateButton({
    Name = "🚫 Tüm Post-Processing Kapat",
    Callback = function()
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
        Rayfield:Notify({Title = "Post-Processing", Content = "Tümü kapatıldı!", Duration = 2})
    end,
})

VisibilityTab:CreateButton({
    Name = "✅ Tüm Post-Processing Aç",
    Callback = function()
        for effect, data in pairs(OriginalSettings.LightingEffects) do
            if effect and effect.Parent then
                effect.Enabled = data.Enabled
            end
        end
        Rayfield:Notify({Title = "Post-Processing", Content = "Orijinal ayarlara döndürüldü!", Duration = 2})
    end,
})

-- Zaman Bölümü
local TimeSection = VisibilityTab:CreateSection("🕐 Zaman Ayarları")

local timeLabel = VisibilityTab:CreateLabel("🕐 Mevcut Saat: " .. math.floor(Lighting.ClockTime) .. ":00")

VisibilityTab:CreateSlider({
    Name = "🕐 Oyun Saati",
    Range = {0, 24},
    Increment = 0.5,
    CurrentValue = Lighting.ClockTime,
    Flag = "TimeSlider",
    Callback = function(Value)
        Lighting.ClockTime = Value
        local hour = math.floor(Value)
        local minute = math.floor((Value - hour) * 60)
        timeLabel:Set(string.format("🕐 Mevcut Saat: %02d:%02d", hour, minute))
    end,
})

VisibilityTab:CreateButton({
    Name = "🌅 Gündüz Yap (12:00)",
    Callback = function()
        Lighting.ClockTime = 12
        timeLabel:Set("🕐 Mevcut Saat: 12:00")
        Rayfield:Notify({Title = "Zaman", Content = "Gündüz yapıldı!", Duration = 1})
    end,
})

VisibilityTab:CreateButton({
    Name = "🌙 Gece Yap (0:00)",
    Callback = function()
        Lighting.ClockTime = 0
        timeLabel:Set("🕐 Mevcut Saat: 00:00")
        Rayfield:Notify({Title = "Zaman", Content = "Gece yapıldı!", Duration = 1})
    end,
})

VisibilityTab:CreateButton({
    Name = "🌄 Gün Doğumu (6:00)",
    Callback = function()
        Lighting.ClockTime = 6
        timeLabel:Set("🕐 Mevcut Saat: 06:00")
        Rayfield:Notify({Title = "Zaman", Content = "Gün doğumu!", Duration = 1})
    end,
})

VisibilityTab:CreateButton({
    Name = "🌇 Gün Batımı (18:00)",
    Callback = function()
        Lighting.ClockTime = 18
        timeLabel:Set("🕐 Mevcut Saat: 18:00")
        Rayfield:Notify({Title = "Zaman", Content = "Gün batımı!", Duration = 1})
    end,
})

-- Ambient Bölümü
local AmbientSection = VisibilityTab:CreateSection("🎨 Ambient Renk")

VisibilityTab:CreateInput({
    Name = "🎨 Ambient Renk (R,G,B)",
    PlaceholderText = "150,150,150",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local parts = Text:split(",")
        if #parts == 3 then
            local r, g, b = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
            if r and g and b then
                Lighting.Ambient = Color3.fromRGB(r, g, b)
                Lighting.OutdoorAmbient = Color3.fromRGB(r, g, b)
                Rayfield:Notify({Title = "Ambient", Content = "Renk değiştirildi!", Duration = 1})
            end
        end
    end,
})

VisibilityTab:CreateToggle({
    Name = "🌈 Rainbow Ambient",
    CurrentValue = false,
    Flag = "RainbowAmbientToggle",
    Callback = function(Value)
        rainbowAmbientEnabled = Value
        
        if Value then
            spawn(function()
                local hue = 0
                while rainbowAmbientEnabled do
                    hue = (hue + 0.01) % 1
                    local color = Color3.fromHSV(hue, 1, 1)
                    Lighting.Ambient = color
                    Lighting.OutdoorAmbient = color
                    wait(0.05)
                end
            end)
            Rayfield:Notify({Title = "Rainbow", Content = "Aktif!", Duration = 2})
        else
            Lighting.Ambient = OriginalSettings.Ambient
            Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient
            Rayfield:Notify({Title = "Rainbow", Content = "Kapatıldı", Duration = 1})
        end
    end,
})

VisibilityTab:CreateButton({
    Name = "🔄 Tüm Görünürlük Ayarlarını Sıfırla",
    Callback = function()
        Lighting.Brightness = OriginalSettings.Brightness
        Lighting.ClockTime = OriginalSettings.ClockTime
        Lighting.FogEnd = OriginalSettings.FogEnd
        Lighting.FogStart = OriginalSettings.FogStart or 0
        Lighting.GlobalShadows = OriginalSettings.GlobalShadows
        Lighting.Ambient = OriginalSettings.Ambient
        Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient
        
        for effect, data in pairs(OriginalSettings.LightingEffects) do
            if effect and effect.Parent then
                effect.Enabled = data.Enabled
            end
        end
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj.Enabled = true
            end
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = true
            end
        end
        
        fullbrightEnabled = false
        nightVisionEnabled = false
        noShadowsEnabled = false
        noFogEnabled = false
        noLightsEnabled = false
        noBlurEnabled = false
        noBloomEnabled = false
        noSunRaysEnabled = false
        noDOFEnabled = false
        rainbowAmbientEnabled = false
        noParticlesEnabled = false
        
        Rayfield:Notify({Title = "Sıfırlandı", Content = "Tüm görünürlük ayarları orijinale döndürüldü!", Duration = 2})
    end,
})

-- ==================== IŞINLANMA TAB ====================
local TeleportTab = Window:CreateTab("🌀 Işınlanma", nil)

-- Konum Bölümü
local LocationSection = TeleportTab:CreateSection("📍 Konum & Pusula")

local locationLabel = TeleportTab:CreateLabel("📍 Konum yükleniyor...")
local compassInfoLabel = TeleportTab:CreateLabel("🧭 Yön yükleniyor...")

spawn(function()
    while wait(0.2) do
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local pos = character.HumanoidRootPart.Position
            locationLabel:Set(string.format("📍 X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z))
            
            local lookVector = character.HumanoidRootPart.CFrame.LookVector
            local angle = math.deg(math.atan2(lookVector.X, lookVector.Z))
            
            local directions = {
                {min = -22.5, max = 22.5, name = "Kuzey ⬆️"},
                {min = 22.5, max = 67.5, name = "Kuzeydoğu ↗️"},
                {min = 67.5, max = 112.5, name = "Doğu ➡️"},
                {min = 112.5, max = 157.5, name = "Güneydoğu ↘️"},
                {min = -67.5, max = -22.5, name = "Kuzeybatı ↖️"},
                {min = -112.5, max = -67.5, name = "Batı ⬅️"},
                {min = -157.5, max = -112.5, name = "Güneybatı ↙️"},
            }
            
            local direction = "Güney ⬇️"
            for _, d in ipairs(directions) do
                if angle >= d.min and angle < d.max then
                    direction = d.name
                    break
                end
            end
            
            compassInfoLabel:Set("🧭 " .. direction .. " (" .. math.floor(angle) .. "°)")
        end
    end
end)

TeleportTab:CreateButton({
    Name = "📋 Mevcut Konumu Kopyala",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local pos = character.HumanoidRootPart.Position
            local text = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
            if copyToClipboard(text) then
                Rayfield:Notify({Title = "Kopyalandı", Content = text, Duration = 2})
            end
        end
    end,
})

TeleportTab:CreateToggle({
    Name = "🧭 Ekran Pusulası Göster/Gizle",
    CurrentValue = true,
    Flag = "CompassGuiToggle",
    Callback = function(Value)
        if Value then
            if not compassGui then createCompassGui() end
            compassGui.Enabled = true
        else
            if compassGui then compassGui.Enabled = false end
        end
    end,
})

-- Oyuncuya Işınlanma
local PlayerTPSection = TeleportTab:CreateSection("👤 Oyuncuya Işınlan")

local function getPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    if #list == 0 then table.insert(list, "Oyuncu yok") end
    return list
end

local selectedPlayer = nil

local TeleportDropdown = TeleportTab:CreateDropdown({
    Name = "Oyuncu Seç",
    Options = getPlayerList(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "TeleportPlayerDropdown",
    Callback = function(Options)
        selectedPlayer = Options[1]
    end,
})

TeleportTab:CreateButton({
    Name = "🌀 Seçilen Oyuncuya Işınlan",
    Callback = function()
        if selectedPlayer and selectedPlayer ~= "Oyuncu yok" then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    Rayfield:Notify({Title = "Işınlandın", Content = selectedPlayer .. " yanına!", Duration = 2})
                end
            else
                Rayfield:Notify({Title = "Hata", Content = "Oyuncu bulunamadı!", Duration = 2})
            end
        else
            Rayfield:Notify({Title = "Hata", Content = "Önce oyuncu seç!", Duration = 2})
        end
    end,
})

TeleportTab:CreateButton({
    Name = "🔄 Oyuncu Listesini Yenile",
    Callback = function()
        TeleportDropdown:Refresh(getPlayerList(), true)
        Rayfield:Notify({Title = "Yenilendi", Content = "Oyuncu listesi güncellendi", Duration = 1})
    end,
})

-- Koordinata Işınlanma
local CoordSection = TeleportTab:CreateSection("📌 Koordinata Işınlan")

local teleportX, teleportY, teleportZ = 0, 0, 0

TeleportTab:CreateInput({
    Name = "X Koordinatı",
    PlaceholderText = "X değeri",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        teleportX = tonumber(Text) or 0
    end,
})

TeleportTab:CreateInput({
    Name = "Y Koordinatı",
    PlaceholderText = "Y değeri",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        teleportY = tonumber(Text) or 0
    end,
})

TeleportTab:CreateInput({
    Name = "Z Koordinatı",
    PlaceholderText = "Z değeri",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        teleportZ = tonumber(Text) or 0
    end,
})

TeleportTab:CreateButton({
    Name = "📌 Koordinata Işınlan",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(teleportX, teleportY, teleportZ)
            Rayfield:Notify({Title = "Işınlandın", Content = string.format("(%.0f, %.0f, %.0f)", teleportX, teleportY, teleportZ), Duration = 2})
        end
    end,
})

-- Hızlı Işınlanma
local QuickTPSection = TeleportTab:CreateSection("⚡ Hızlı Işınlanma")

TeleportTab:CreateButton({
    Name = "🏠 Spawn'a Işınlan",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then
                character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
                Rayfield:Notify({Title = "Işınlandın", Content = "Spawn noktasına!", Duration = 2})
            else
                character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
                Rayfield:Notify({Title = "Işınlandın", Content = "Merkeze (spawn bulunamadı)", Duration = 2})
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "☁️ Gökyüzüne Işınlan (Y+500)",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local pos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y + 500, pos.Z)
            Rayfield:Notify({Title = "Işınlandın", Content = "Gökyüzüne!", Duration = 2})
        end
    end,
})

TeleportTab:CreateButton({
    Name = "🎯 Fare İmlecine Işınlan",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0, 3, 0))
            Rayfield:Notify({Title = "Işınlandın", Content = "İmleç konumuna!", Duration = 2})
        end
    end,
})

-- ==================== SCRİPTLER TAB ====================
local ScriptsTab = Window:CreateTab("📜 Scriptler", nil)

local PopularSection = ScriptsTab:CreateSection("🌟 Popüler Scriptler")

ScriptsTab:CreateButton({
    Name = "🔧 Infinite Yield - Admin Komutları",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Infinite Yield...", Duration = 3})
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end,
})

ScriptsTab:CreateButton({
    Name = "💻 CMD-X - Komut Sistemi",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "CMD-X...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "🔍 Dex Explorer - Oyun Dosyaları",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Dex Explorer...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "🌑 Dark Dex - Gelişmiş Explorer",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Dark Dex...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/DarkDexV4.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "🕵️ Simple Spy - Remote Takibi",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Simple Spy...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
    end,
})

local MoreScriptsSection = ScriptsTab:CreateSection("🔥 Daha Fazla Script")

ScriptsTab:CreateButton({
    Name = "🦉 Owl Hub - Çoklu Oyun",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Owl Hub...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "👤 Nameless Admin",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Nameless Admin...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "🚀 Fling Script",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Fling...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe./main/Fe%20fling"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "💬 Chat Bypass",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Chat Bypass...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/3dsboy08/Shattervast-Mods/main/ChatBypass.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "🌐 Server Hop - Orca",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Orca...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/richie0866/orca/master/public/latest.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "🎮 Mobile Keyboard",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Mobile Keyboard...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/chillz-keyboard/main/source"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "🔓 Fe Animations - Animasyonlar",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Fe Animations...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/rfrfrfrfrf/psu/main/source.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "😎 C00lKid - Troll",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "C00lKid...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/cfsmi2/c00lguiv1/refs/heads/main/Main.lua"))()
    end,
})

-- ==================== AYARLAR TAB ====================
local SettingsTab = Window:CreateTab("⚙️ Ayarlar", nil)

-- Reload Bölümü
local ReloadSection = SettingsTab:CreateSection("🔄 Reload Sistemi")

local function ReloadAllFeatures()
    Rayfield:Notify({Title = "Reload", Content = "Özellikler yeniden yükleniyor...", Duration = 2})
    
    -- Mevcut durumları kaydet
    local savedFly = flyEnabled
    local savedEsp = espEnabled
    local savedNoclip = noclipEnabled
    
    -- Hepsini kapat
    flyEnabled = false
    noclipEnabled = false
    espEnabled = false
    infiniteJumpEnabled = false
    shiftBoostEnabled = false
    autoClickerEnabled = false
    spamAutoEnabled = false
    antiAfkEnabled = false
    invisibleEnabled = false
    noAnimationsEnabled = false
    noParticlesEnabled = false
    fullbrightEnabled = false
    nightVisionEnabled = false
    noShadowsEnabled = false
    noFogEnabled = false
    noLightsEnabled = false
    rainbowAmbientEnabled = false
    nowe = false
    tpwalking = false
    
    -- Fly temizle
    cleanupFly()
    
    -- ESP temizle
    clearESP()
    
    -- Karakter düzelt
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.WalkSpeed = walkSpeedValue
            humanoid.JumpPower = jumpPowerValue
        end
        
        local animate = character:FindFirstChild("Animate")
        if animate then animate.Disabled = false end
        
        -- Görünürlük düzelt
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "YellowSphere" then
                part.Transparency = 0
                part.CanCollide = true
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 0
            end
        end
        
        local sphere = character:FindFirstChild("YellowSphere")
        if sphere then sphere:Destroy() end
    end
    
    -- Lighting sıfırla
    Lighting.Brightness = OriginalSettings.Brightness
    Lighting.ClockTime = OriginalSettings.ClockTime
    Lighting.FogEnd = OriginalSettings.FogEnd
    Lighting.FogStart = OriginalSettings.FogStart or 0
    Lighting.GlobalShadows = OriginalSettings.GlobalShadows
    Lighting.Ambient = OriginalSettings.Ambient
    Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient
    
    for effect, data in pairs(OriginalSettings.LightingEffects) do
        if effect and effect.Parent then
            pcall(function() effect.Enabled = data.Enabled end)
        end
    end
    
    -- Handles temizle
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:find("StudioHandle") or obj.Name == "BuilderSelection" then
            pcall(function() obj:Destroy() end)
        end
    end
    
    wait(0.5)
    
    Rayfield:Notify({Title = "Reload", Content = "Tüm özellikler sıfırlandı!", Duration = 2})
end

SettingsTab:CreateButton({
    Name = "🔄 Tüm Özellikleri Reload Et",
    Callback = function()
        ReloadAllFeatures()
    end,
})

SettingsTab:CreateButton({
    Name = "🔄 Sadece Uçuşu Reload Et",
    Callback = function()
        if flyEnabled then
            flyEnabled = false
            nowe = false
            tpwalking = false
            cleanupFly()
            Rayfield:Notify({Title = "Reload", Content = "Uçuş sıfırlandı!", Duration = 2})
        else
            Rayfield:Notify({Title = "Reload", Content = "Uçuş zaten kapalı!", Duration = 2})
        end
    end,
})

SettingsTab:CreateButton({
    Name = "🔄 Sadece ESP'yi Reload Et",
    Callback = function()
        if espEnabled then
            clearESP()
            wait(0.3)
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    createPlayerESP(player)
                end
            end
            Rayfield:Notify({Title = "Reload", Content = "ESP yeniden yüklendi!", Duration = 2})
        else
            Rayfield:Notify({Title = "Reload", Content = "ESP zaten kapalı!", Duration = 2})
        end
    end,
})

SettingsTab:CreateButton({
    Name = "🔄 Karakter Ayarlarını Reload Et",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = walkSpeedValue
                humanoid.JumpPower = jumpPowerValue
                humanoid.PlatformStand = false
            end
            Rayfield:Notify({Title = "Reload", Content = "Karakter ayarları yenilendi!", Duration = 2})
        end
    end,
})

-- Profil Bölümü
local ProfileSection = SettingsTab:CreateSection("👤 Profil Bilgileri")

local profileInfo = SettingsTab:CreateParagraph({
    Title = "Hesap Bilgileri",
    Content = "Yükleniyor..."
})

spawn(function()
    wait(1)
    local userId = LocalPlayer.UserId
    local username = LocalPlayer.Name
    local displayName = LocalPlayer.DisplayName
    local accountAge = LocalPlayer.AccountAge
    local membershipType = tostring(LocalPlayer.MembershipType):gsub("Enum.MembershipType.", "")
    
    local text = string.format(
        "👤 Kullanıcı: %s\n🎭 Görünen Ad: %s\n🆔 ID: %s\n📅 Hesap Yaşı: %d gün\n⭐ Üyelik: %s",
        username, displayName, tostring(userId), accountAge, membershipType
    )
    
    profileInfo:Set({Title = "Hesap Bilgileri", Content = text})
end)

SettingsTab:CreateButton({
    Name = "📋 User ID Kopyala",
    Callback = function()
        copyToClipboard(tostring(LocalPlayer.UserId))
        Rayfield:Notify({Title = "Kopyalandı", Content = "User ID: " .. LocalPlayer.UserId, Duration = 2})
    end,
})

SettingsTab:CreateButton({
    Name = "📋 Kullanıcı Adı Kopyala",
    Callback = function()
        copyToClipboard(LocalPlayer.Name)
        Rayfield:Notify({Title = "Kopyalandı", Content = LocalPlayer.Name, Duration = 2})
    end,
})

-- Oyun Bölümü
local GameSection = SettingsTab:CreateSection("🎮 Oyun Bilgileri")

local gameInfo = SettingsTab:CreateParagraph({
    Title = "Oyun Detayları",
    Content = string.format(
        "🎮 Oyun ID: %s\n🌐 Server ID: %s\n👥 Oyuncu: %d/%d",
        tostring(game.PlaceId), game.JobId:sub(1, 8) .. "...", #Players:GetPlayers(), Players.MaxPlayers
    )
})

-- Oyuncu sayısını güncelle
spawn(function()
    while wait(5) do
        pcall(function()
            gameInfo:Set({
                Title = "Oyun Detayları",
                Content = string.format(
                    "🎮 Oyun ID: %s\n🌐 Server ID: %s\n👥 Oyuncu: %d/%d",
                    tostring(game.PlaceId), game.JobId:sub(1, 8) .. "...", #Players:GetPlayers(), Players.MaxPlayers
                )
            })
        end)
    end
end)

SettingsTab:CreateButton({
    Name = "📋 Oyun ID Kopyala",
    Callback = function()
        copyToClipboard(tostring(game.PlaceId))
        Rayfield:Notify({Title = "Kopyalandı", Content = "Oyun ID: " .. game.PlaceId, Duration = 2})
    end,
})

SettingsTab:CreateButton({
    Name = "📋 Server ID Kopyala",
    Callback = function()
        copyToClipboard(game.JobId)
        Rayfield:Notify({Title = "Kopyalandı", Content = "Server ID kopyalandı!", Duration = 2})
    end,
})

SettingsTab:CreateButton({
    Name = "🔄 Oyuna Yeniden Katıl",
    Callback = function()
        Rayfield:Notify({Title = "Rejoin", Content = "Yeniden katılınıyor...", Duration = 2})
        wait(0.5)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

SettingsTab:CreateButton({
    Name = "🌐 Farklı Servera Geç",
    Callback = function()
        Rayfield:Notify({Title = "Server Hop", Content = "Yeni server aranıyor...", Duration = 2})
        pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end)
    end,
})

-- Uygulama Bölümü
local AppSection = SettingsTab:CreateSection("🔧 Uygulama Ayarları")

SettingsTab:CreateParagraph({
    Title = "⌨️ Kısayol Tuşları",
    Content = "• PageDown / Break: Menüyü Aç/Kapa\n• Auto Clicker tuşu: Ayarlanabilir (varsayılan X)\n• Q: Dash (aktifse) / Büyü değiştir\n• WASD: Uçuş hareketi\n• Shift: Hızlanma (aktifse)"
})

SettingsTab:CreateButton({
    Name = "❌ Scripti Kapat (KILLER)",
    Callback = function()
        Rayfield:Notify({Title = "KILLER", Content = "Script kapatılıyor...", Duration = 2})
        wait(0.5)
        KillScript()
        Rayfield:Destroy()
    end,
})

-- ==================== KARAKTER YENİDEN OLUŞTURULUNCA ====================
addConnection(LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.7)
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        if not flyEnabled then
            humanoid.WalkSpeed = walkSpeedValue
            humanoid.JumpPower = jumpPowerValue
        end
    end
    
    local animate = character:FindFirstChild("Animate")
    if animate and not noAnimationsEnabled and not flyEnabled then
        animate.Disabled = false
    end
    
    if flyEnabled then
        flyEnabled = false
        nowe = false
        tpwalking = false
        cleanupFly()
        Rayfield:Notify({Title = "Uçuş", Content = "Karakter yenilendi, uçuş kapatıldı", Duration = 2})
    end
    
    if espEnabled then
        wait(1)
        clearESP()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                createPlayerESP(player)
            end
        end
    end
    
    if invisibleEnabled then
        wait(0.5)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 1
            end
        end
        
        local sphere = Instance.new("Part")
        sphere.Name = "YellowSphere"
        sphere.Shape = Enum.PartType.Ball
        sphere.Size = Vector3.new(4, 4, 4)
        sphere.BrickColor = BrickColor.new("Bright yellow")
        sphere.Material = Enum.Material.Neon
        sphere.CanCollide = false
        sphere.Anchored = false
        sphere.Parent = character
        
        local weld = Instance.new("Weld")
        weld.Part0 = character:FindFirstChild("HumanoidRootPart")
        weld.Part1 = sphere
        weld.Parent = sphere
    end
end))

-- ==================== HOŞGELDIN ====================
Rayfield:Notify({
    Title = "TarnakLua-Roblox",
    Content = "Script yüklendi! PageDown/Break ile aç/kapa",
    Duration = 5,
})

print("=====================================")
print("   TarnakLua-Roblox")
print("   Ultimate Script Hub")
print("=====================================")
print("• PageDown / Break: Menü aç/kapa")
print("• Tüm özellikler menüden erişilebilir")
print("• KILLER ile güvenli kapatma")
print("=====================================")
print("YENİ ÖZELLİKLER:")
print("• ⚔️ Kılıç düzeltildi (doğru tutuş)")
print("• 🔫 Silah görünmez el ile")
print("• 🔮 Büyü sistemi (Q ile değiştir)")
print("• 🔧 Studio Builder (sürükle-bırak)")
print("• 📐 Ayrı X,Y,Z ayarları")
print("• 🎨 Mavi seçim kutuları")
print("=====================================")