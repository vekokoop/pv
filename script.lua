-- Tribes 3v3 VIP Script Hub v16 (Final Complete & Draggable Version)

---------------------------------------------------------
-- 0. تنظيف أي سكربت أو واجهة سابقة لمنع التداخل
---------------------------------------------------------
if _G.TribesVIP_Loaded then
    if _G.TribesVIP_Cleanup then
        pcall(_G.TribesVIP_Cleanup)
    end
end
_G.TribesVIP_Loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- مسح الهايلايت والواجهات القديمة بأمان
pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "VIP_FloatingToggle" or v.Name == "Orion" then
            v:Destroy()
        end
    end
    if gethui then
        for _, v in pairs(gethui():GetChildren()) do
            if v.Name == "VIP_FloatingToggle" or v.Name == "Orion" then
                v:Destroy()
            end
        end
    end
end)

---------------------------------------------------------
-- 1. المزامنة عند التنقل بين الماب واللوبي
---------------------------------------------------------
local queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
if queue_on_teleport then
    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/vekokoop/poooo/refs/heads/main/script.lua", true))()')
end

---------------------------------------------------------
-- 2. تحميل مكتبة الواجهة
---------------------------------------------------------
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Window = OrionLib:MakeWindow({
    Name = "Tribes 3v3 - VIP Hub 👑",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "TribesVIP"
})

---------------------------------------------------------
-- 3. الأيقونة العائمة + جعل القائمة الرئيسية قابلة للسحب
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "VIP_FloatingToggle"
local successGui, targetGui = pcall(function()
    return gethui()
end)
ScreenGui.Parent = (successGui and targetGui) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "👑 VIP"
ToggleButton.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleButton.TextSize = 16
ToggleButton.Active = true
ToggleButton.Draggable = true

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleButton

-- جعل نافذة أوريون الرئيسية قابلة للسحب وتفعيل زر الإخفاء والإظهار بدقة
local menuOpened = true
ToggleButton.Activated:Connect(function()
    pcall(function()
        local coreGui = game:GetService("CoreGui"):FindFirstChild("Orion") or (gethui and gethui():FindFirstChild("Orion"))
        if coreGui then
            menuOpened = not menuOpened
            coreGui.Enabled = menuOpened
            
            -- تفعيل السحب على الإطار الرئيسي للقائمة تلقائياً
            for _, frame in pairs(coreGui:GetDescendants()) do
                if frame:IsA("Frame") and frame.Size.X.Offset > 200 then
                    frame.Active = true
                    frame.Draggable = true
                end
            end
        end
    end)
end)

---------------------------------------------------------
-- دالة التحقق الذكي من الفريق
---------------------------------------------------------
local function isTeammate(player)
    if player == LocalPlayer then return true end
    
    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end
    
    if player:GetAttribute("Team") and LocalPlayer:GetAttribute("Team") then
        return player:GetAttribute("Team") == LocalPlayer:GetAttribute("Team")
    end
    
    if player.Character and LocalPlayer.Character then
        if player.Character.Parent and LocalPlayer.Character.Parent and player.Character.Parent == LocalPlayer.Character.Parent and player.Character.Parent ~= workspace then
            return true
        end
    end
    
    return false
end

---------------------------------------------------------
-- TAB 1: حركة اللاعب
---------------------------------------------------------
local MainTab = Window:MakeTab({
    Name = "اللاعب والحركة",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddSlider({
    Name = "السرعة (WalkSpeed)",
    Min = 16,
    Max = 150,
    Default = 16,
    Color = Color3.fromRGB(255, 215, 0),
    Increment = 1,
    ValueName = "سرعة",
    Callback = function(s)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = s
        end
    end
})

MainTab:AddSlider({
    Name = "قوة القفز (JumpPower)",
    Min = 50,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255, 215, 0),
    Increment = 1,
    ValueName = "قوة",
    Callback = function(s)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = s
        end
    end
})

---------------------------------------------------------
-- TAB 2: كشف الأماكن (ESP)
---------------------------------------------------------
local VisualTab = Window:MakeTab({
    Name = "كشف الأماكن",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ESP_Enabled = false

local function removeESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("ESP_Highlight")
            if hl then hl:Destroy() end
        end
    end
end

local function applyESP()
    if not ESP_Enabled then 
        removeESP()
        return 
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local highlight = char:FindFirstChild("ESP_Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.Adornee = char
                highlight.Parent = char
                highlight.FillTransparency = 0.4
                highlight.OutlineTransparency = 0
            end

            if isTeammate(player) then
                highlight.FillColor = Color3.fromRGB(0, 255, 0)   -- أخضر للتيم
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            else
                highlight.FillColor = Color3.fromRGB(255, 0, 0)   -- أحمر للخصم
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            end
            highlight.Enabled = true
        end
    end
end

VisualTab:AddToggle({
    Name = "تفعيل كشف الأماكن التلقائي",
    Default = false,
    Callback = function(state)
        ESP_Enabled = state
        if not state then removeESP() end
    end
})

local espConnection = RunService.Stepped:Connect(function()
    if ESP_Enabled then
        applyESP()
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        if ESP_Enabled then
            applyESP()
        end
    end)
end)

---------------------------------------------------------
-- TAB 3: مساعد التصويب الذكي (Aimbot)
---------------------------------------------------------
local AimbotTab = Window:MakeTab({
    Name = "مساعد التصويب",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AimbotEnabled = false
local FOV_Radius = 150

local DrawingLib = (typeof(Drawing) == "table" and Drawing) or nil
local fovCircle = nil

if DrawingLib then
    pcall(function()
        fovCircle = DrawingLib.new("Circle")
        fovCircle.Visible = false
        fovCircle.Radius = FOV_Radius
        fovCircle.Color = Color3.fromRGB(255, 215, 0)
        fovCircle.Thickness = 1.5
        fovCircle.Filled = false
        fovCircle.Transparency = 0.8
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end)

    RunService.RenderStepped:Connect(function()
        if fovCircle then
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
    end)
end

AimbotTab:AddToggle({
    Name = "إظهار دائرة الـ FOV",
    Default = false,
    Callback = function(state)
        if fovCircle then
            fovCircle.Visible = state
        end
    end
})

AimbotTab:AddToggle({
    Name = "تفعيل التصويب التلقائي",
    Default = false,
    Callback = function(state)
        AimbotEnabled = state
    end
})

AimbotTab:AddButton({
    Name = "تكبير دائرة FOV (+25)",
    Callback = function()
        FOV_Radius = math.min(FOV_Radius + 25, 500)
        if fovCircle then fovCircle.Radius = FOV_Radius end
    end
})

AimbotTab:AddButton({
    Name = "تصغير دائرة FOV (-25)",
    Callback = function()
        FOV_Radius = math.max(FOV_Radius - 25, 30)
        if fovCircle then fovCircle.Radius = FOV_Radius end
    end
})

local function getClosestEnemyTarget()
    local closestTarget = nil
    local maxDistance = FOV_Radius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isTeammate(player) and player.Character then
            local targetPart = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude

                    if dist < maxDistance then
                        maxDistance = dist
                        closestTarget = targetPart.Position
                    end
                end
            end
        end
    end
    return closestTarget
end

local aimConnection = RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local targetPos = getClosestEnemyTarget()
        if targetPos then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end)

_G.TribesVIP_Cleanup = function()
    if espConnection then espConnection:Disconnect() end
    if aimConnection then aimConnection:Disconnect() end
    removeESP()
    if fovCircle then
        pcall(function() fovCircle:Remove() end)
    end
    pcall(function() ScreenGui:Destroy() end)
end

OrionLib:Init()
