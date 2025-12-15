-- TarnakLua-Roblox - Ultimate Edition
-- Rayfield UI Library
-- Tüm özellikler dahil - Killer sistemi ile güvenli kapatma

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
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ==================== BAŞLANGIÇ DEĞERLERİ (Killer için) ====================
local OriginalSettings = {
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = workspace.Gravity,
    LightingSettings = {},
    AnimateDisabled = false,
}

-- Lighting ayarlarını kaydet
for _, effect in pairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("BlurEffect") or effect:IsA("BloomEffect") then
        OriginalSettings.LightingSettings[effect] = effect.Enabled
    end
end

-- ==================== GLOBAL DEĞİŞKENLER ====================
local flyEnabled = false
local noclipEnabled = false
local flyNoclipEnabled = false
local espEnabled = false
local godModeEnabled = false
local antiAfkEnabled = false
local autoClickerEnabled = false
local spamAutoEnabled = false
local invisibleEnabled = false
local noAnimationsEnabled = false
local noEffectsEnabled = false
local noLightsEnabled = false
local shiftBoostEnabled = false
local infiniteJumpEnabled = false
local fullbrightEnabled = false
local respawnAtDeathEnabled = false
local freecamEnabled = false

local flySpeed = 1
local tpwalking = false
local speeds = 1
local nowe = false
local walkSpeedValue = 16
local jumpPowerValue = 50
local dashDistance = 50
local shiftBoostMultiplier = 2
local autoClickerDelay = 0.1
local spamAutoKey = Enum.KeyCode.E
local spamAutoDelay = 0.1
local lastDeathPosition = nil

-- Kontrol değişkenleri
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local currentSpeed = 0
local maxspeed = 50

-- ESP için
local espConnections = {}
local espObjects = {}
local tracerLines = {}

-- Tüm bağlantılar (Killer için)
local allConnections = {}

-- ==================== YARDIMCI FONKSİYONLAR ====================

-- Bağlantı kaydetme
local function addConnection(conn)
    if conn then
        table.insert(allConnections, conn)
    end
    return conn
end

-- Panoya kopyala
local function copyToClipboard(text)
    if setclipboard then
        setclipboard(tostring(text))
        return true
    elseif toclipboard then
        toclipboard(tostring(text))
        return true
    end
    return false
end

-- Sayı formatla
local function formatNumber(num)
    local formatted = tostring(num)
    local k = 1
    while k > 0 do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    end
    return formatted
end

-- ==================== KILLER SİSTEMİ ====================
local function KillScript()
    -- Tüm toggle'ları kapat
    flyEnabled = false
    noclipEnabled = false
    flyNoclipEnabled = false
    espEnabled = false
    godModeEnabled = false
    antiAfkEnabled = false
    autoClickerEnabled = false
    spamAutoEnabled = false
    invisibleEnabled = false
    noAnimationsEnabled = false
    noEffectsEnabled = false
    noLightsEnabled = false
    shiftBoostEnabled = false
    infiniteJumpEnabled = false
    fullbrightEnabled = false
    freecamEnabled = false
    nowe = false
    tpwalking = false
    
    -- Tüm bağlantıları kes
    for _, conn in pairs(allConnections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
    end
    allConnections = {}
    
    -- ESP temizle
    for _, conn in pairs(espConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    espConnections = {}
    
    for _, line in pairs(tracerLines) do
        if line then pcall(function() line:Remove() end) end
    end
    tracerLines = {}
    
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then
            pcall(function() obj:Destroy() end)
        end
    end
    espObjects = {}
    
    -- Karakter temizle
    local character = LocalPlayer.Character
    if character then
        -- Fly objelerini temizle
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if torso then
            local bg = torso:FindFirstChild("FlyGyro")
            local bv = torso:FindFirstChild("FlyVelocity")
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end
        
        -- Sarı küreyi temizle
        local sphere = character:FindFirstChild("YellowSphere")
        if sphere then sphere:Destroy() end
        
        -- Force field temizle
        local ff = character:FindFirstChild("GodModeFF")
        if ff then ff:Destroy() end
        
        -- Humanoid ayarlarını sıfırla
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.WalkSpeed = OriginalSettings.WalkSpeed
            humanoid.JumpPower = OriginalSettings.JumpPower
            
            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                pcall(function()
                    humanoid:SetStateEnabled(state, true)
                end)
            end
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        
        -- Animate'i aç
        local animate = character:FindFirstChild("Animate")
        if animate then animate.Disabled = false end
        
        -- Görünürlüğü düzelt
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
                part.CanCollide = true
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 0
            end
        end
    end
    
    -- Lighting ayarlarını geri yükle
    for effect, enabled in pairs(OriginalSettings.LightingSettings) do
        if effect and effect.Parent then
            pcall(function() effect.Enabled = enabled end)
        end
    end
    
    -- Workspace ışıklarını aç
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            pcall(function() obj.Enabled = true end)
        end
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            pcall(function() obj.Enabled = true end)
        end
    end
    
    Lighting.GlobalShadows = true
    workspace.Gravity = OriginalSettings.Gravity
    
    print("=====================================")
    print("TarnakLua-Roblox başarıyla kapatıldı!")
    print("Tüm ayarlar normale döndürüldü.")
    print("=====================================")
end

-- ==================== ANA PENCERE ====================
local Window = Rayfield:CreateWindow({
    Name = "TarnakLua-Roblox",
    LoadingTitle = "TarnakLua-Roblox",
    LoadingSubtitle = "Ultimate Script Hub ",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "TarnakLuaConfig"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false
})

-- ==================== UÇUŞ TAB ====================
local FlyTab = Window:CreateTab("✈️ Uçuş", nil)

local FlySection = FlyTab:CreateSection("Uçuş Kontrolleri")

-- Tuş bağlantıları için
local flyKeyConnections = {}

local function setupFlyControls()
    for _, conn in pairs(flyKeyConnections) do
        if conn then conn:Disconnect() end
    end
    flyKeyConnections = {}
    
    flyKeyConnections[1] = addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
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
            humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
        
        local animate = character:FindFirstChild("Animate")
        if animate then animate.Disabled = false end
    end
    
    tpwalking = false
    ctrl = {f = 0, b = 0, l = 0, r = 0}
    lastctrl = {f = 0, b = 0, l = 0, r = 0}
    currentSpeed = 0
end

-- Ana Fly Toggle
local FlyToggle = FlyTab:CreateToggle({
    Name = "✈️ Uçuşu Aktif Et (WASD ile hareket)",
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
            
            -- TranslateBy ile hız çarpanı (Orijinal kod)
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
            
            -- Animasyonları durdur
            local animate = character:FindFirstChild("Animate")
            if animate then animate.Disabled = true end
            
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(0)
            end
            
            -- Humanoid durumlarını devre dışı bırak
            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                pcall(function() humanoid:SetStateEnabled(state, false) end)
            end
            humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
            
            -- R6/R15 uyumlu uçuş
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
            
            -- Uçuş döngüsü
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
            
            Rayfield:Notify({Title = "Uçuş Aktif", Content = "WASD hareket, Up/Down butonları yüksel/alçal", Duration = 3})
        else
            cleanupFly()
            Rayfield:Notify({Title = "Uçuş Kapalı", Content = "Normal harekete dönüldü", Duration = 2})
        end
    end,
})

-- Mevcut Hız Göstergesi
local CurrentSpeedLabel = FlyTab:CreateLabel("📊 Mevcut Hız: " .. speeds)

-- Hız TextBox
local FlySpeedInput = FlyTab:CreateInput({
    Name = "⚡ Uçuş Hızı (Limitsiz)",
    PlaceholderText = "Hız girin (1, 10, 100, 1000...)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 1 then
            speeds = math.floor(num)
            CurrentSpeedLabel:Set("📊 Mevcut Hız: " .. speeds)
            
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
                                local boost = 1
                                if shiftBoostEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                                    boost = shiftBoostMultiplier
                                end
                                chr:TranslateBy(hum.MoveDirection * boost)
                            end
                        end
                    end)
                end
            end
            
            Rayfield:Notify({Title = "Hız Değişti", Content = "Yeni hız: " .. speeds, Duration = 2})
        else
            Rayfield:Notify({Title = "Hata", Content = "Geçerli sayı girin (minimum 1)", Duration = 2})
        end
    end,
})

-- Hız Butonları
local SpeedButtonsSection = FlyTab:CreateSection("Hız Butonları")

local FlySpeedPlus = FlyTab:CreateButton({
    Name = "➕ Hız +1",
    Callback = function()
        speeds = speeds + 1
        CurrentSpeedLabel:Set("📊 Mevcut Hız: " .. speeds)
        
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
        
        Rayfield:Notify({Title = "Hız", Content = "Mevcut: " .. speeds, Duration = 1})
    end,
})

local FlySpeedPlus10 = FlyTab:CreateButton({
    Name = "➕ Hız +10",
    Callback = function()
        speeds = speeds + 10
        CurrentSpeedLabel:Set("📊 Mevcut Hız: " .. speeds)
        
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
        
        Rayfield:Notify({Title = "Hız", Content = "Mevcut: " .. speeds, Duration = 1})
    end,
})

local FlySpeedMinus = FlyTab:CreateButton({
    Name = "➖ Hız -1",
    Callback = function()
        if speeds > 1 then
            speeds = speeds - 1
            CurrentSpeedLabel:Set("📊 Mevcut Hız: " .. speeds)
            
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
            
            Rayfield:Notify({Title = "Hız", Content = "Mevcut: " .. speeds, Duration = 1})
        else
            Rayfield:Notify({Title = "Uyarı", Content = "Hız 1'den az olamaz!", Duration = 2})
        end
    end,
})

local FlySpeedMinus10 = FlyTab:CreateButton({
    Name = "➖ Hız -10",
    Callback = function()
        if speeds > 10 then
            speeds = speeds - 10
        else
            speeds = 1
        end
        CurrentSpeedLabel:Set("📊 Mevcut Hız: " .. speeds)
        
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
        
        Rayfield:Notify({Title = "Hız", Content = "Mevcut: " .. speeds, Duration = 1})
    end,
})

-- Yükseklik Kontrolü
local HeightSection = FlyTab:CreateSection("Yükseklik Kontrolü")

local upHolding = false
local downHolding = false

local UpButton = FlyTab:CreateButton({
    Name = "⬆️ Yukarı Çık (Toggle)",
    Callback = function()
        upHolding = not upHolding
        if upHolding then
            spawn(function()
                while upHolding do
                    wait()
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)
                    end
                end
            end)
            Rayfield:Notify({Title = "Yukarı", Content = "Yukarı çıkma AKTİF - Durdurmak için tekrar tıkla", Duration = 2})
        else
            Rayfield:Notify({Title = "Yukarı", Content = "Durduruldu", Duration = 1})
        end
    end,
})

local DownButton = FlyTab:CreateButton({
    Name = "⬇️ Aşağı İn (Toggle)",
    Callback = function()
        downHolding = not downHolding
        if downHolding then
            spawn(function()
                while downHolding do
                    wait()
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -1, 0)
                    end
                end
            end)
            Rayfield:Notify({Title = "Aşağı", Content = "Aşağı inme AKTİF - Durdurmak için tekrar tıkla", Duration = 2})
        else
            Rayfield:Notify({Title = "Aşağı", Content = "Durduruldu", Duration = 1})
        end
    end,
})

-- Fly Ekstra
local FlyExtraSection = FlyTab:CreateSection("Uçuş Ekstra")

local FlyNoclipToggle = FlyTab:CreateToggle({
    Name = "👻 Uçarken Her Şeyin İçinden Geç (NoClip)",
    CurrentValue = false,
    Flag = "FlyNoclipToggle",
    Callback = function(Value)
        flyNoclipEnabled = Value
        
        if Value then
            spawn(function()
                while flyNoclipEnabled do
                    RunService.Stepped:Wait()
                    local character = LocalPlayer.Character
                    if character and flyEnabled then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
            Rayfield:Notify({Title = "Fly NoClip", Content = "Uçarken duvarlardan geçebilirsin!", Duration = 2})
        end
    end,
})

-- ==================== HAREKET TAB ====================
local MovementTab = Window:CreateTab("🏃 Hareket", nil)

-- Yürüme Hızı
local WalkSection = MovementTab:CreateSection("Yürüme Hızı")

local CurrentWalkSpeedLabel = MovementTab:CreateLabel("📊 Mevcut Yürüme Hızı: " .. walkSpeedValue)

local WalkSpeedInput = MovementTab:CreateInput({
    Name = "🏃 Yürüme Hızı Ayarla",
    PlaceholderText = "Hız girin (varsayılan: 16)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 0 then
            walkSpeedValue = num
            CurrentWalkSpeedLabel:Set("📊 Mevcut Yürüme Hızı: " .. walkSpeedValue)
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = num
                end
            end
            Rayfield:Notify({Title = "Yürüme Hızı", Content = "Yeni hız: " .. num, Duration = 2})
        end
    end,
})

local WalkSpeedPlus = MovementTab:CreateButton({
    Name = "➕ Yürüme Hızı +10",
    Callback = function()
        walkSpeedValue = walkSpeedValue + 10
        CurrentWalkSpeedLabel:Set("📊 Mevcut Yürüme Hızı: " .. walkSpeedValue)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = walkSpeedValue end
        end
        Rayfield:Notify({Title = "Yürüme Hızı", Content = "Mevcut: " .. walkSpeedValue, Duration = 1})
    end,
})

local WalkSpeedMinus = MovementTab:CreateButton({
    Name = "➖ Yürüme Hızı -10",
    Callback = function()
        if walkSpeedValue >= 10 then
            walkSpeedValue = walkSpeedValue - 10
        else
            walkSpeedValue = 0
        end
        CurrentWalkSpeedLabel:Set("📊 Mevcut Yürüme Hızı: " .. walkSpeedValue)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = walkSpeedValue end
        end
        Rayfield:Notify({Title = "Yürüme Hızı", Content = "Mevcut: " .. walkSpeedValue, Duration = 1})
    end,
})

local WalkSpeedReset = MovementTab:CreateButton({
    Name = "🔄 Varsayılana Sıfırla (16)",
    Callback = function()
        walkSpeedValue = 16
        CurrentWalkSpeedLabel:Set("📊 Mevcut Yürüme Hızı: " .. walkSpeedValue)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
        Rayfield:Notify({Title = "Sıfırlandı", Content = "Yürüme hızı: 16", Duration = 1})
    end,
})

-- Zıplama Gücü
local JumpSection = MovementTab:CreateSection("Zıplama Gücü")

local CurrentJumpPowerLabel = MovementTab:CreateLabel("📊 Mevcut Zıplama Gücü: " .. jumpPowerValue)

local JumpPowerInput = MovementTab:CreateInput({
    Name = "🦘 Zıplama Gücü Ayarla",
    PlaceholderText = "Güç girin (varsayılan: 50)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 0 then
            jumpPowerValue = num
            CurrentJumpPowerLabel:Set("📊 Mevcut Zıplama Gücü: " .. jumpPowerValue)
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = num
                    humanoid.UseJumpPower = true
                end
            end
            Rayfield:Notify({Title = "Zıplama Gücü", Content = "Yeni güç: " .. num, Duration = 2})
        end
    end,
})

local JumpPowerPlus = MovementTab:CreateButton({
    Name = "➕ Zıplama Gücü +25",
    Callback = function()
        jumpPowerValue = jumpPowerValue + 25
        CurrentJumpPowerLabel:Set("📊 Mevcut Zıplama Gücü: " .. jumpPowerValue)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = jumpPowerValue
                humanoid.UseJumpPower = true
            end
        end
        Rayfield:Notify({Title = "Zıplama Gücü", Content = "Mevcut: " .. jumpPowerValue, Duration = 1})
    end,
})

local JumpPowerMinus = MovementTab:CreateButton({
    Name = "➖ Zıplama Gücü -25",
    Callback = function()
        if jumpPowerValue >= 25 then
            jumpPowerValue = jumpPowerValue - 25
        else
            jumpPowerValue = 0
        end
        CurrentJumpPowerLabel:Set("📊 Mevcut Zıplama Gücü: " .. jumpPowerValue)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = jumpPowerValue
                humanoid.UseJumpPower = true
            end
        end
        Rayfield:Notify({Title = "Zıplama Gücü", Content = "Mevcut: " .. jumpPowerValue, Duration = 1})
    end,
})

local JumpPowerReset = MovementTab:CreateButton({
    Name = "🔄 Varsayılana Sıfırla (50)",
    Callback = function()
        jumpPowerValue = 50
        CurrentJumpPowerLabel:Set("📊 Mevcut Zıplama Gücü: " .. jumpPowerValue)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = 50
                humanoid.UseJumpPower = true
            end
        end
        Rayfield:Notify({Title = "Sıfırlandı", Content = "Zıplama gücü: 50", Duration = 1})
    end,
})

-- Infinite Jump
local InfiniteJumpToggle = MovementTab:CreateToggle({
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
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end
            end))
            Rayfield:Notify({Title = "Sonsuz Zıplama", Content = "Havada da zıplayabilirsin!", Duration = 2})
        end
    end,
})

-- Dash Sistemi
local DashSection = MovementTab:CreateSection("Dash (Q Tuşu)")

local CurrentDashLabel = MovementTab:CreateLabel("📊 Dash Mesafesi: " .. dashDistance)

local DashDistanceInput = MovementTab:CreateInput({
    Name = "💨 Dash Mesafesi Ayarla",
    PlaceholderText = "Mesafe girin (varsayılan: 50)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 1 then
            dashDistance = num
            CurrentDashLabel:Set("📊 Dash Mesafesi: " .. dashDistance)
            Rayfield:Notify({Title = "Dash", Content = "Mesafe: " .. num, Duration = 2})
        end
    end,
})

local dashEnabled = false
local dashConnection = nil

local DashToggle = MovementTab:CreateToggle({
    Name = "💨 Dash Aktif (Q Tuşu ile Dash At)",
    CurrentValue = false,
    Flag = "DashToggle",
    Callback = function(Value)
        dashEnabled = Value
        
        if Value then
            dashConnection = addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode == Enum.KeyCode.Q then
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            local direction = humanoid.MoveDirection
                            if direction.Magnitude == 0 then
                                direction = character.HumanoidRootPart.CFrame.LookVector
                            end
                            character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + (direction * dashDistance)
                        end
                    end
                end
            end))
            Rayfield:Notify({Title = "Dash", Content = "Q tuşuyla " .. dashDistance .. " studs dash at!", Duration = 2})
        else
            if dashConnection then
                dashConnection:Disconnect()
                dashConnection = nil
            end
        end
    end,
})

-- Shift Boost Sistemi
local ShiftSection = MovementTab:CreateSection("Shift Hızlanma (Enerjisiz)")

local CurrentShiftLabel = MovementTab:CreateLabel("📊 Shift Çarpanı: " .. shiftBoostMultiplier .. "x")

local ShiftBoostInput = MovementTab:CreateInput({
    Name = "⚡ Shift Hızlanma Çarpanı",
    PlaceholderText = "Çarpan girin (varsayılan: 2)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 1 then
            shiftBoostMultiplier = num
            CurrentShiftLabel:Set("📊 Shift Çarpanı: " .. shiftBoostMultiplier .. "x")
            Rayfield:Notify({Title = "Shift Boost", Content = "Çarpan: " .. num .. "x", Duration = 2})
        end
    end,
})

local ShiftBoostToggle = MovementTab:CreateToggle({
    Name = "⚡ Shift ile Hızlan (Enerji Tüketmez)",
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
            end)
            Rayfield:Notify({Title = "Shift Boost", Content = "Shift basılı tutarak " .. shiftBoostMultiplier .. "x hızlan!", Duration = 2})
        else
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = walkSpeedValue
                end
            end
        end
    end,
})

-- NoClip
local NoclipSection = MovementTab:CreateSection("NoClip")

local NoclipToggle = MovementTab:CreateToggle({
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
            Rayfield:Notify({Title = "NoClip", Content = "Duvarlardan geçebilirsin!", Duration = 2})
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

-- ==================== GÖRÜNÜRLÜK TAB ====================
local VisibilityTab = Window:CreateTab("👻 Görünürlük", nil)

local CharSection = VisibilityTab:CreateSection("Karakter Görünürlüğü")

-- Görünmez + Sarı Küre
local InvisibleToggle = VisibilityTab:CreateToggle({
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
            
            Rayfield:Notify({Title = "Görünmezlik", Content = "Karakterin görünmez, sarı küre takılı!", Duration = 2})
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
        end
    end,
})

-- Animasyonlar
local AnimSection = VisibilityTab:CreateSection("Animasyon & Efekt")

local NoAnimationsToggle = VisibilityTab:CreateToggle({
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
            Rayfield:Notify({Title = "Animasyon", Content = "Animasyonlar kapatıldı!", Duration = 2})
        else
            if animate then animate.Disabled = false end
        end
    end,
})

local NoEffectsToggle = VisibilityTab:CreateToggle({
    Name = "✨ Tüm Efektleri Kapat (Partikül, Duman, vb.)",
    CurrentValue = false,
    Flag = "NoEffectsToggle",
    Callback = function(Value)
        noEffectsEnabled = Value
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or 
               obj:IsA("Smoke") or obj:IsA("Sparkles") or
               obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = not Value
            end
        end
        
        Rayfield:Notify({Title = "Efektler", Content = Value and "Kapatıldı!" or "Açıldı!", Duration = 2})
    end,
})

-- Işıklar
local LightSection = VisibilityTab:CreateSection("Işıklandırma")

local NoLightsToggle = VisibilityTab:CreateToggle({
    Name = "💡 Tüm Işıkları Kapat",
    CurrentValue = false,
    Flag = "NoLightsToggle",
    Callback = function(Value)
        noLightsEnabled = Value
        
        if Value then
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("BlurEffect") or effect:IsA("BloomEffect") or 
                   effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or 
                   effect:IsA("DepthOfFieldEffect") or effect:IsA("Atmosphere") then
                    effect.Enabled = false
                end
            end
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    obj.Enabled = false
                end
            end
            
            Lighting.GlobalShadows = false
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            
            Rayfield:Notify({Title = "Işıklar", Content = "Tüm ışıklar kapatıldı!", Duration = 2})
        else
            for effect, enabled in pairs(OriginalSettings.LightingSettings) do
                if effect and effect.Parent then
                    effect.Enabled = enabled
                end
            end
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    obj.Enabled = true
                end
            end
            
            Lighting.GlobalShadows = true
        end
    end,
})

local FullbrightToggle = VisibilityTab:CreateToggle({
    Name = "☀️ Fullbright (Her Yer Aydınlık)",
    CurrentValue = false,
    Flag = "FullbrightToggle",
    Callback = function(Value)
        fullbrightEnabled = Value
        
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Rayfield:Notify({Title = "Fullbright", Content = "Her yer aydınlık!", Duration = 2})
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
    end,
})

-- ==================== ESP TAB ====================
local ESPTab = Window:CreateTab("👁️ ESP", nil)

local ESPSection = ESPTab:CreateSection("Oyuncu ESP (Wallhack)")

-- ESP Temizle
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
        if obj and obj.Parent then
            pcall(function() obj:Destroy() end)
        end
    end
    espObjects = {}
end

-- ESP Oluştur (DÜZELTİLDİ - Çizgiler bizden başlıyor)
local function createPlayerESP(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_ESP"
    highlight.Adornee = character
    highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    table.insert(espObjects, highlight)
    
    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name .. "_Billboard"
    billboard.Adornee = rootPart
    billboard.Size = UDim2.new(0, 150, 0, 70)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    table.insert(espObjects, billboard)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0, 15)
    distanceLabel.Position = UDim2.new(0, 0, 0, 20)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    distanceLabel.Parent = billboard
    
    -- Sağlık barı
    local healthBG = Instance.new("Frame")
    healthBG.Size = UDim2.new(0.8, 0, 0, 8)
    healthBG.Position = UDim2.new(0.1, 0, 0, 38)
    healthBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    healthBG.BorderSizePixel = 1
    healthBG.Parent = billboard
    
    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBG
    
    local healthText = Instance.new("TextLabel")
    healthText.Size = UDim2.new(1, 0, 0, 12)
    healthText.Position = UDim2.new(0, 0, 0, 50)
    healthText.BackgroundTransparency = 1
    healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthText.TextStrokeTransparency = 0
    healthText.Font = Enum.Font.Gotham
    healthText.TextSize = 10
    healthText.Parent = billboard
    
    -- Tracer (BİZDEN OYUNCUYA - KALIN ÇİZGİ)
    local tracerLine = nil
    pcall(function()
        tracerLine = Drawing.new("Line")
        tracerLine.Visible = true
        tracerLine.Color = Color3.fromRGB(255, 255, 0)
        tracerLine.Thickness = 3 -- Kalın çizgi
        tracerLine.Transparency = 1
        table.insert(tracerLines, tracerLine)
    end)
    
    -- Güncelleme döngüsü
    local updateConn = addConnection(RunService.RenderStepped:Connect(function()
        if not espEnabled then return end
        if not player or not player.Character then return end
        
        local char = player.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if not hum or not root then return end
        
        local localChar = LocalPlayer.Character
        if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
        
        -- BİZDEN OYUNCUYA MESAFE
        local distance = (root.Position - localChar.HumanoidRootPart.Position).Magnitude
        distanceLabel.Text = math.floor(distance) .. " studs uzakta"
        
        -- Sağlık
        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        healthText.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. " HP"
        
        -- Tracer - BİZDEN BAŞLAYIP OYUNCUYA GİDİYOR
        if tracerLine then
            local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
            if onScreen then
                -- BİZİM EKRAN ALTI (ORTADAN)
                tracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                -- OYUNCUNUN EKRAN POZİSYONU
                tracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
                tracerLine.Visible = true
            else
                tracerLine.Visible = false
            end
        end
    end))
    table.insert(espConnections, updateConn)
    
    -- Ölünce temizle
    local diedConn = addConnection(humanoid.Died:Connect(function()
        if highlight and highlight.Parent then highlight:Destroy() end
        if billboard and billboard.Parent then billboard:Destroy() end
        if tracerLine then pcall(function() tracerLine:Remove() end) end
    end))
    table.insert(espConnections, diedConn)
end

local ESPToggle = ESPTab:CreateToggle({
    Name = "👁️ ESP Aktif (Duvardan Gör)",
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
            
            local playerAddedConn = addConnection(Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    wait(1)
                    if espEnabled then createPlayerESP(player) end
                end)
            end))
            table.insert(espConnections, playerAddedConn)
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local charAddedConn = addConnection(player.CharacterAdded:Connect(function()
                        wait(1)
                        if espEnabled then createPlayerESP(player) end
                    end))
                    table.insert(espConnections, charAddedConn)
                end
            end
            
            Rayfield:Notify({Title = "ESP", Content = "Wallhack aktif! Tüm oyuncuları görebilirsin.", Duration = 3})
        else
            clearESP()
        end
    end,
})

local ESPInfo = ESPTab:CreateParagraph({
    Title = "ESP Bilgi",
    Content = "• Sarı çizgiler SENİN ekranından oyunculara gider\n• Mesafe hesaplaması SANA göre yapılır\n• Highlight ile duvarların arkasını gör"
})

-- ==================== IŞINLANMA TAB ====================
local TeleportTab = Window:CreateTab("🌀 Işınlanma", nil)

-- Mevcut Konum
local LocationSection = TeleportTab:CreateSection("📍 Mevcut Konumun")

local LocationLabel = TeleportTab:CreateLabel("Konum yükleniyor...")

spawn(function()
    while wait(0.3) do
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local pos = character.HumanoidRootPart.Position
            LocationLabel:Set(string.format("📍 X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z))
        end
    end
end)

local CopyLocationBtn = TeleportTab:CreateButton({
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

-- Oyuncuya Işınlanma
local PlayerTPSection = TeleportTab:CreateSection("👤 Oyuncuya Işınlan")

local function getPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return list
end

local selectedPlayer = nil

local TeleportDropdown = TeleportTab:CreateDropdown({
    Name = "Oyuncu Seç",
    Options = getPlayerList(),
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "TeleportPlayerDropdown",
    Callback = function(Options)
        selectedPlayer = Options[1]
    end,
})

local TeleportButton = TeleportTab:CreateButton({
    Name = "🌀 Seçilen Oyuncuya Işınlan",
    Callback = function()
        if selectedPlayer then
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

local RefreshPlayersBtn = TeleportTab:CreateButton({
    Name = "🔄 Oyuncu Listesini Yenile",
    Callback = function()
        Rayfield:Notify({Title = "Yenilendi", Content = "Listeyi tekrar aç", Duration = 2})
    end,
})

-- Koordinata Işınlanma
local CoordSection = TeleportTab:CreateSection("📌 Koordinata Işınlan")

_G.TeleportX = 0
_G.TeleportY = 0
_G.TeleportZ = 0

local TeleportXInput = TeleportTab:CreateInput({
    Name = "X Koordinatı",
    PlaceholderText = "X değeri",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text) _G.TeleportX = tonumber(Text) or 0 end,
})

local TeleportYInput = TeleportTab:CreateInput({
    Name = "Y Koordinatı",
    PlaceholderText = "Y değeri",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text) _G.TeleportY = tonumber(Text) or 0 end,
})

local TeleportZInput = TeleportTab:CreateInput({
    Name = "Z Koordinatı",
    PlaceholderText = "Z değeri",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text) _G.TeleportZ = tonumber(Text) or 0 end,
})

local TeleportToCoordBtn = TeleportTab:CreateButton({
    Name = "📌 Koordinata Işınlan",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(_G.TeleportX, _G.TeleportY, _G.TeleportZ)
            Rayfield:Notify({Title = "Işınlandın", Content = string.format("(%.0f, %.0f, %.0f)", _G.TeleportX, _G.TeleportY, _G.TeleportZ), Duration = 2})
        end
    end,
})

-- Pusula
local CompassSection = TeleportTab:CreateSection("🧭 Pusula")

local CompassLabel = TeleportTab:CreateLabel("Yön yükleniyor...")

spawn(function()
    while wait(0.1) do
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local lookVector = character.HumanoidRootPart.CFrame.LookVector
            local angle = math.deg(math.atan2(lookVector.X, lookVector.Z))
            
            local direction = "?"
            if angle >= -22.5 and angle < 22.5 then direction = "Kuzey (N)"
            elseif angle >= 22.5 and angle < 67.5 then direction = "Kuzeydoğu (NE)"
            elseif angle >= 67.5 and angle < 112.5 then direction = "Doğu (E)"
            elseif angle >= 112.5 and angle < 157.5 then direction = "Güneydoğu (SE)"
            elseif angle >= 157.5 or angle < -157.5 then direction = "Güney (S)"
            elseif angle >= -157.5 and angle < -112.5 then direction = "Güneybatı (SW)"
            elseif angle >= -112.5 and angle < -67.5 then direction = "Batı (W)"
            elseif angle >= -67.5 and angle < -22.5 then direction = "Kuzeybatı (NW)"
            end
            
            CompassLabel:Set("🧭 " .. direction .. " (" .. math.floor(angle) .. "°)")
        end
    end
end)

-- ==================== OTOMASYON TAB ====================
local AutoTab = Window:CreateTab("🤖 Otomasyon", nil)

-- Auto Clicker
local AutoClickSection = AutoTab:CreateSection("🖱️ Auto Clicker")

local AutoClickerToggle = AutoTab:CreateToggle({
    Name = "🖱️ Auto Clicker (Otomatik Tıkla)",
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
            Rayfield:Notify({Title = "Auto Clicker", Content = "Her " .. autoClickerDelay .. " saniyede tıklar!", Duration = 2})
        end
    end,
})

local AutoClickerDelayInput = AutoTab:CreateInput({
    Name = "Tıklama Aralığı (saniye)",
    PlaceholderText = "Örn: 0.1",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num > 0 then
            autoClickerDelay = num
            Rayfield:Notify({Title = "Aralık", Content = num .. " saniye", Duration = 1})
        end
    end,
})

-- Spam Auto
local SpamSection = AutoTab:CreateSection("⌨️ Tuş Spam (Oyunlarda E, F vb.)")

local SpamAutoToggle = AutoTab:CreateToggle({
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
            Rayfield:Notify({Title = "Tuş Spam", Content = "Spam başladı!", Duration = 2})
        end
    end,
})

local SpamKeyInput = AutoTab:CreateInput({
    Name = "Spam Tuşu (E, F, R, G vb.)",
    PlaceholderText = "Tuş harfi girin",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local success, key = pcall(function() return Enum.KeyCode[Text:upper()] end)
        if success and key then
            spamAutoKey = key
            Rayfield:Notify({Title = "Tuş Ayarlandı", Content = Text:upper(), Duration = 2})
        end
    end,
})

local SpamDelayInput = AutoTab:CreateInput({
    Name = "Spam Aralığı (0 = Basılı Tut)",
    PlaceholderText = "Örn: 0.1",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 0 then
            spamAutoDelay = num
        end
    end,
})

-- Anti AFK
local AntiAFKSection = AutoTab:CreateSection("💤 Anti AFK")

local AntiAFKToggle = AutoTab:CreateToggle({
    Name = "💤 Anti AFK (Oyundan Atılma)",
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
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                end
            end))
            
            Rayfield:Notify({Title = "Anti AFK", Content = "Artık AFK atılmayacaksın!", Duration = 3})
        end
    end,
})

-- ==================== ÖLÜMSÜZLÜK TAB ====================
local GodTab = Window:CreateTab("❤️ Ölümsüzlük", nil)

local GodSection = GodTab:CreateSection("🛡️ Can Sistemleri")

local GodModeToggle = GodTab:CreateToggle({
    Name = "🛡️ Ölümsüzlük (Can Sürekli Dolu)",
    CurrentValue = false,
    Flag = "GodModeToggle",
    Callback = function(Value)
        godModeEnabled = Value
        
        if Value then
            spawn(function()
                while godModeEnabled do
                    wait(0.1)
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.Health = hum.MaxHealth
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if root then lastDeathPosition = root.CFrame end
                        end
                    end
                end
            end)
            Rayfield:Notify({Title = "God Mode", Content = "Canın sürekli dolu!", Duration = 3})
        end
    end,
})

local RespawnSection = GodTab:CreateSection("🔄 Respawn Ayarları")

local RespawnAtDeathToggle = GodTab:CreateToggle({
    Name = "🔄 Ölünce Son Konuma Dön",
    CurrentValue = false,
    Flag = "RespawnAtDeathToggle",
    Callback = function(Value)
        respawnAtDeathEnabled = Value
        
        if Value then
            addConnection(LocalPlayer.CharacterAdded:Connect(function(character)
                wait(1)
                if lastDeathPosition and respawnAtDeathEnabled then
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if root then root.CFrame = lastDeathPosition end
                end
            end))
            Rayfield:Notify({Title = "Respawn", Content = "Öldüğünde son konuma döneceksin!", Duration = 2})
        end
    end,
})

local ForceFieldToggle = GodTab:CreateToggle({
    Name = "🔵 Force Field (Görsel Kalkan)",
    CurrentValue = false,
    Flag = "ForceFieldToggle",
    Callback = function(Value)
        local character = LocalPlayer.Character
        if not character then return end
        
        local ff = character:FindFirstChild("GodModeFF")
        
        if Value then
            if not ff then
                ff = Instance.new("ForceField")
                ff.Name = "GodModeFF"
                ff.Parent = character
            end
        else
            if ff then ff:Destroy() end
        end
    end,
})

-- Oyuncu Öldürme
local KillSection = GodTab:CreateSection("💀 Oyuncu Sistemi")

local selectedKillPlayer = nil

local KillDropdown = GodTab:CreateDropdown({
    Name = "Hedef Oyuncu Seç",
    Options = getPlayerList(),
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "KillPlayerDropdown",
    Callback = function(Options)
        selectedKillPlayer = Options[1]
    end,
})

local KillButton = GodTab:CreateButton({
    Name = "💀 Oyuncuya Saldır/Fırlat",
    Callback = function()
        if selectedKillPlayer then
            local targetPlayer = Players:FindFirstChild(selectedKillPlayer)
            if targetPlayer and targetPlayer.Character then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        character.HumanoidRootPart.CFrame = targetRoot.CFrame
                        Rayfield:Notify({Title = "Saldırı", Content = selectedKillPlayer .. " hedef alındı!", Duration = 2})
                    end
                end
            end
        else
            Rayfield:Notify({Title = "Hata", Content = "Önce oyuncu seç!", Duration = 2})
        end
    end,
})

-- ==================== SCRİPTLER TAB ====================
local ScriptsTab = Window:CreateTab("📜 Scriptler", nil)

local PopularSection = ScriptsTab:CreateSection("🌟 Popüler Scriptler")

local InfiniteYieldBtn = ScriptsTab:CreateButton({
    Name = "🔧 Infinite Yield - Kapsamlı Admin Komutları",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Infinite Yield...", Duration = 3})
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end,
})

local CMDBtn = ScriptsTab:CreateButton({
    Name = "💻 CMD - Basit Komut Sistemi",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "CMD...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/cmd/main/main.lua"))()
    end,
})

local ExternalBtn = ScriptsTab:CreateButton({
    Name = "📁 Dış Script - Ek Özellikler",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Dış Script...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/dertonware/scriptasda/refs/heads/main/scriptlua", true))()
    end,
})

local DexBtn = ScriptsTab:CreateButton({
    Name = "🔍 Dex Explorer - Oyun Dosyalarını Gör",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Dex Explorer...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end,
})

local RemoteSpyBtn = ScriptsTab:CreateButton({
    Name = "🕵️ Simple Spy - Remote/Event Takibi",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Simple Spy...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
    end,
})

local MoreScriptsSection = ScriptsTab:CreateSection("🔥 Daha Fazla Script")

local CoolKidBtn = ScriptsTab:CreateButton({
    Name = "😎 CoolKid - Troll & Eğlence Komutları",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "CoolKid...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nicholasthegreat/CoolKid/main/Main"))()
    end,
})

local DarkDexBtn = ScriptsTab:CreateButton({
    Name = "🌑 Dark Dex - Gelişmiş Explorer",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Dark Dex...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/loglizzy/lazy-dex/main/main.lua"))()
    end,
})

local OwlHubBtn = ScriptsTab:CreateButton({
    Name = "🦉 Owl Hub - Çoklu Oyun Desteği",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Owl Hub...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt"))()
    end,
})

local NamelessBtn = ScriptsTab:CreateButton({
    Name = "👤 Nameless Admin - Admin Paneli",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Nameless Admin...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source"))()
    end,
})

local FlingBtn = ScriptsTab:CreateButton({
    Name = "🚀 Fling Script - Oyuncuları Fırlat",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Fling...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe./main/Fe%20fling"))()
    end,
})

local ChatSpamBtn = ScriptsTab:CreateButton({
    Name = "💬 Chat Spammer - Sohbet Spam",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Chat Spammer...", Duration = 3})
        loadstring(game:HttpGet("https://pastebin.com/raw/JK5rcxyf"))()
    end,
})

local OrcaBtn = ScriptsTab:CreateButton({
    Name = "🌐 Orca - Server Hop & Araçlar",
    Callback = function()
        Rayfield:Notify({Title = "Yükleniyor", Content = "Orca...", Duration = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/richie0866/orca/master/public/latest.lua"))()
    end,
})

-- ==================== AYARLAR TAB ====================
local SettingsTab = Window:CreateTab("⚙️ Ayarlar", nil)

-- Profil Bilgileri
local ProfileSection = SettingsTab:CreateSection("👤 Profil Bilgilerin")

local ProfileInfo = SettingsTab:CreateParagraph({
    Title = "Hesap Bilgileri",
    Content = "Yükleniyor..."
})

-- Profil bilgilerini yükle
spawn(function()
    wait(1)
    local userId = LocalPlayer.UserId
    local username = LocalPlayer.Name
    local displayName = LocalPlayer.DisplayName
    local accountAge = LocalPlayer.AccountAge
    local membershipType = tostring(LocalPlayer.MembershipType):gsub("Enum.MembershipType.", "")
    
    local profileText = string.format(
        "👤 Kullanıcı Adı: %s\n" ..
        "🎭 Görünen Ad: %s\n" ..
        "🆔 User ID: %s\n" ..
        "📅 Hesap Yaşı: %d gün\n" ..
        "⭐ Üyelik: %s",
        username, displayName, tostring(userId), accountAge, membershipType
    )
    
    ProfileInfo:Set({
        Title = "Hesap Bilgilerin",
        Content = profileText
    })
end)

local CopyUserIdBtn = SettingsTab:CreateButton({
    Name = "📋 User ID Kopyala",
    Callback = function()
        if copyToClipboard(tostring(LocalPlayer.UserId)) then
            Rayfield:Notify({Title = "Kopyalandı", Content = "User ID: " .. LocalPlayer.UserId, Duration = 2})
        end
    end,
})

local CopyUsernameBtn = SettingsTab:CreateButton({
    Name = "📋 Kullanıcı Adı Kopyala",
    Callback = function()
        if copyToClipboard(LocalPlayer.Name) then
            Rayfield:Notify({Title = "Kopyalandı", Content = LocalPlayer.Name, Duration = 2})
        end
    end,
})

-- Oyun Bilgileri
local GameSection = SettingsTab:CreateSection("🎮 Oyun Bilgileri")

local GameInfo = SettingsTab:CreateParagraph({
    Title = "Oyun Detayları",
    Content = string.format(
        "🎮 Oyun ID: %s\n" ..
        "🌐 Server ID: %s\n" ..
        "👥 Oyuncu Sayısı: %d/%d",
        tostring(game.PlaceId),
        tostring(game.JobId),
        #Players:GetPlayers(),
        Players.MaxPlayers
    )
})

local CopyGameIdBtn = SettingsTab:CreateButton({
    Name = "📋 Oyun ID Kopyala",
    Callback = function()
        if copyToClipboard(tostring(game.PlaceId)) then
            Rayfield:Notify({Title = "Kopyalandı", Content = "Oyun ID: " .. game.PlaceId, Duration = 2})
        end
    end,
})

local CopyServerIdBtn = SettingsTab:CreateButton({
    Name = "📋 Server ID Kopyala",
    Callback = function()
        if copyToClipboard(tostring(game.JobId)) then
            Rayfield:Notify({Title = "Kopyalandı", Content = "Server ID kopyalandı!", Duration = 2})
        end
    end,
})

local RejoinBtn = SettingsTab:CreateButton({
    Name = "🔄 Oyuna Yeniden Katıl",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

local ServerHopBtn = SettingsTab:CreateButton({
    Name = "🌐 Farklı Servera Geç",
    Callback = function()
        Rayfield:Notify({Title = "Server Hop", Content = "Yeni server aranıyor...", Duration = 2})
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(servers.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end,
})

-- Uygulama Ayarları
local AppSection = SettingsTab:CreateSection("🔧 Uygulama")

local KillScriptBtn = SettingsTab:CreateButton({
    Name = "❌ Scripti Kapat ve Her Şeyi Sıfırla (KILLER)",
    Callback = function()
        Rayfield:Notify({
            Title = "KILLER",
            Content = "Tüm ayarlar sıfırlanıyor...",
            Duration = 2,
        })
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
    
    -- Uçuş aktifse sıfırla
    if flyEnabled then
        flyEnabled = false
        nowe = false
        tpwalking = false
        cleanupFly()
    end
    
    -- ESP yeniden oluştur
    if espEnabled then
        wait(1)
        clearESP()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                createPlayerESP(player)
            end
        end
    end
end))

-- ==================== HOŞGELDIN ====================
Rayfield:Notify({
    Title = "TarnakLua-Roblox",
    Content = "Script yüklendi! Ayarlardan KILLER ile güvenli kapat.",
    Duration = 5,
})

print("=====================================")
print("   TarnakLua-Roblox")
print("   Ultimate Script Hub")
print("=====================================")
print("• Tüm özellikler menüden erişilebilir")
print("• KILLER sistemi ile güvenli kapatma")
print("• Her şey orijinal kodlara uygun")
print("=====================================")