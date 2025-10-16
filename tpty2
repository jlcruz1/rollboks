-- Samuraa1 Hub - Theme Park Tycoon 2 Private Script
-- Combined with Smart Ride Manager for maximum automation
-- Features: Auto Garbage Collection, Smart Ride Manager, Fly, Noclip, AntiAFK, etc.

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Local player references
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera
local PlaceId = game.PlaceId
local JobId = game.JobId

-- State
local savedHumanoidRootPartCFrame
getgenv().CollectGarbage = false -- global toggle for auto-collect
getgenv().RideManagerEnabled = false -- Smart Ride Manager state
local AntiAFKConnection
local InfiniteJumpEnabled = false
local NoclipEnabled = false
local FlyEnabled = false
local FlySpeed = 100
local WalkSpeedEnabled = false
local WalkSpeedMethod = "Normal"
local WalkSpeedValue = 16
local JumpPowerValue = 50

-- Smart Ride Manager State
getgenv().RideStats = {
    totalEarnings = 0,
    ridesProcessed = 0,
    rideDetails = {},
    lastUpdate = tick()
}

-- Smart Ride Manager Config
local RIDE_CHECK_INTERVAL = 1
local RIDE_RESTART_DELAY = 0.3
local MONEY_COLLECT_OFFSET = Vector3.new(0, 5, 0)

-- External library loading
local BASE_URL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(BASE_URL .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(BASE_URL .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(BASE_URL .. "addons/SaveManager.lua"))()

-- UI setup
local Options = Library.Options
local Toggles = Library.Toggles
local Window = Library:CreateWindow({
    Title = "Samuraa1 Hub + Smart Ride Manager",
    Footer = "Theme Park Tycoon 2 Private Script",
    ToggleKeybind = Enum.KeyCode.RightControl,
    Center = true,
    AutoShow = true,
    Size = UDim2.fromOffset(898 - 18, 2019 - 1494)
})

local mainTab = Window:AddTab("Main", "layout-dashboard")

-- ===================================
-- UTILITY FUNCTIONS (SHARED)
-- ===================================

local function sendVirtualKey(keyCode)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, nil)
    task.wait(0.01)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, nil)
end

local function findMyTycoon()
    for _, tycoon in ipairs(Workspace.Tycoons:GetChildren()) do
        if tycoon:FindFirstChild("OwnerName") and tycoon.OwnerName.Value == LocalPlayer.Name then
            return tycoon
        end
    end
    return nil
end

-- ===================================
-- GARBAGE COLLECTION (ORIGINAL)
-- ===================================

local function collectGarbageOnce()
    local tycoon = findMyTycoon()
    if not tycoon then return end

    local trashContainer = tycoon:FindFirstChild("trashPools") or tycoon:FindFirstChild("Trash") or tycoon:FindFirstChild("trash")
    if not trashContainer then return end

    local hrp = HumanoidRootPart
    if not hrp then return end

    local originalCFrame = hrp.CFrame

    for _, descendant in ipairs(trashContainer:GetDescendants()) do
        if not getgenv().CollectGarbage then
            break
        end

        if descendant:IsA("MeshPart") and descendant.Name == "__Trash" then
            hrp.CFrame = CFrame.new(descendant.Position + Vector3.new(0, 3, 0))
            task.wait(0.1)
            sendVirtualKey(Enum.KeyCode.F)
            task.wait(0.4)
            if hrp and originalCFrame then
                hrp.CFrame = originalCFrame
            end
            break
        end
    end
end

getgenv().Toggle = function()
    getgenv().CollectGarbage = not getgenv().CollectGarbage
    if getgenv().CollectGarbage then
        spawn(function()
            while getgenv().CollectGarbage do
                collectGarbageOnce()
                task.wait(0.5)
            end
        end)
    end
end

-- ===================================
-- SMART RIDE MANAGER FUNCTIONS
-- ===================================

local function teleportToPosition(position, offset)
    offset = offset or Vector3.new(0, 0, 0)
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(position + offset)
        task.wait(0.1)
    end
end

local function getRideStatus(ride)
    local runningValue = ride:FindFirstChild("Running") or ride:FindFirstChild("Active") or ride:FindFirstChild("IsRunning")
    if runningValue then
        return runningValue.Value
    end
    
    local primaryPart = ride:FindFirstChild("PrimaryPart") or ride:FindFirstChildOfClass("Part")
    if primaryPart and primaryPart:IsA("BasePart") then
        local speed = primaryPart.AssemblyLinearVelocity.Magnitude
        return speed > 1
    end
    
    return false
end

local function findAllRides()
    local tycoon = findMyTycoon()
    if not tycoon then return {} end
    
    local rides = {}
    local rideContainers = {"Rides", "Attractions", "Amusements", "rideDropped", "rides"}
    
    for _, containerName in ipairs(rideContainers) do
        local container = tycoon:FindFirstChild(containerName)
        if container then
            for _, ride in ipairs(container:GetChildren()) do
                if ride:IsA("Model") or ride:IsA("Folder") then
                    table.insert(rides, ride)
                end
            end
        end
    end
    
    return rides
end

local function getRideIncome(ride)
    local incomeValue = ride:FindFirstChild("Income") 
        or ride:FindFirstChild("Money") 
        or ride:FindFirstChild("Earnings")
        or ride:FindFirstChild("Profit")
    
    if incomeValue and (incomeValue:IsA("IntValue") or incomeValue:IsA("NumberValue")) then
        return incomeValue.Value
    end
    
    return 0
end

local function collectRideIncome(ride)
    if not ride then return 0 end
    
    local income = getRideIncome(ride)
    if income <= 0 then return 0 end
    
    local rideName = ride.Name
    
    local ridePosition = ride:FindFirstChild("HumanoidRootPart") or ride:FindFirstChildOfClass("Part")
    if ridePosition then
        local originalPos = HumanoidRootPart.CFrame
        teleportToPosition(ridePosition.Position, MONEY_COLLECT_OFFSET)
        task.wait(0.2)
        
        sendVirtualKey(Enum.KeyCode.E)
        task.wait(0.3)
        
        local mouse = LocalPlayer:GetMouse()
        mouse:TriggerButton1(ridePosition)
        
        HumanoidRootPart.CFrame = originalPos
    end
    
    getgenv().RideStats.totalEarnings = getgenv().RideStats.totalEarnings + income
    getgenv().RideStats.ridesProcessed = getgenv().RideStats.ridesProcessed + 1
    
    if not getgenv().RideStats.rideDetails[rideName] then
        getgenv().RideStats.rideDetails[rideName] = {
            earnings = 0,
            timesRun = 0,
            lastCollected = tick()
        }
    end
    
    getgenv().RideStats.rideDetails[rideName].earnings = getgenv().RideStats.rideDetails[rideName].earnings + income
    getgenv().RideStats.rideDetails[rideName].timesRun = getgenv().RideStats.rideDetails[rideName].timesRun + 1
    getgenv().RideStats.rideDetails[rideName].lastCollected = tick()
    
    return income
end

local function restartRide(ride)
    if not ride then return end
    
    local ridePosition = ride:FindFirstChild("HumanoidRootPart") or ride:FindFirstChildOfClass("Part")
    if ridePosition then
        local originalPos = HumanoidRootPart.CFrame
        teleportToPosition(ridePosition.Position, Vector3.new(0, 3, 0))
        task.wait(0.2)
        
        sendVirtualKey(Enum.KeyCode.E)
        task.wait(RIDE_RESTART_DELAY)
        
        HumanoidRootPart.CFrame = originalPos
        return true
    end
    
    return false
end

local function rideManagerLoop()
    while getgenv().RideManagerEnabled do
        task.wait(RIDE_CHECK_INTERVAL)
        
        local rides = findAllRides()
        
        for _, ride in ipairs(rides) do
            if not getgenv().RideManagerEnabled then break end
            
            local isRunning = getRideStatus(ride)
            
            if not isRunning then
                local income = collectRideIncome(ride)
                task.wait(0.5)
                
                if income > 0 then
                    restartRide(ride)
                    task.wait(1)
                end
            end
        end
        
        getgenv().RideStats.lastUpdate = tick()
    end
end

-- ===================================
-- UI SETUP - AUTOMATION TAB
-- ===================================

local automationGroup = mainTab:AddLeftGroupbox("Automation", "bot")

-- Auto Collect Garbage
automationGroup:AddToggle("Garbage", {
    Text = "Auto Collect Garbage",
    Default = false,
    Callback = function(enabled)
        getgenv().CollectGarbage = enabled
        if enabled then
            spawn(function()
                while getgenv().CollectGarbage do
                    collectGarbageOnce()
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- Smart Ride Manager Toggle
automationGroup:AddToggle("RideManager", {
    Text = "Smart Ride Manager",
    Default = false,
    Callback = function(enabled)
        getgenv().RideManagerEnabled = enabled
        if enabled then
            spawn(rideManagerLoop)
        end
    end
})

-- ===================================
-- UI SETUP - RIDE STATS TAB
-- ===================================

local statsTab = Window:AddTab("Ride Stats", "trending-up")
local rideStatsGroup = statsTab:AddLeftGroupbox("Earnings", "dollar-sign")

local totalEarningsLabel = rideStatsGroup:AddLabel("Total Earnings: $0")
local ridesProcessedLabel = rideStatsGroup:AddLabel("Rides Processed: 0")
local earningsRateLabel = rideStatsGroup:AddLabel("Earnings/Min: $0")

RunService.Heartbeat:Connect(function()
    if getgenv().RideManagerEnabled then
        local stats = getgenv().RideStats
        local elapsed = tick() - stats.lastUpdate
        local earningsPerMin = elapsed > 0 and (stats.totalEarnings / (elapsed / 60)) or 0
        
        totalEarningsLabel:SetText("Total Earnings: $" .. tostring(stats.totalEarnings))
        ridesProcessedLabel:SetText("Rides Processed: " .. tostring(stats.ridesProcessed))
        earningsRateLabel:SetText("Earnings/Min: $" .. math.floor(earningsPerMin))
    end
end)

local detailsGroup = statsTab:AddRightGroupbox("Top Rides", "award")

local function updateRideDetails()
    detailsGroup:Clear()
    
    local rideList = {}
    for rideName, details in pairs(getgenv().RideStats.rideDetails) do
        table.insert(rideList, {name = rideName, earnings = details.earnings, runs = details.timesRun})
    end
    
    table.sort(rideList, function(a, b) return a.earnings > b.earnings end)
    
    for i = 1, math.min(5, #rideList) do
        local ride = rideList[i]
        detailsGroup:AddLabel(ride.name .. ": $" .. ride.earnings .. " (" .. ride.runs .. "x)")
    end
end

spawn(function()
    while true do
        task.wait(5)
        if getgenv().RideManagerEnabled then
            updateRideDetails()
        end
    end
end)

local controlGroup = statsTab:AddLeftGroupbox("Controls", "sliders-vertical")

controlGroup:AddButton({
    Text = "Reset Statistics",
    Func = function()
        getgenv().RideStats = {
            totalEarnings = 0,
            ridesProcessed = 0,
            rideDetails = {},
            lastUpdate = tick()
        }
    end
})

-- ===================================
-- UI SETUP - LOCAL PLAYER TAB
-- ===================================

local localTab = Window:AddTab("Local Player", "user")
local generalGroup = localTab:AddLeftGroupbox("General", "user")

-- Anti AFK
generalGroup:AddToggle("AntiAFK", {
    Text = "Anti AFK",
    Default = false,
    Callback = function(enabled)
        if enabled then
            AntiAFKConnection = LocalPlayer.Idled:Connect(function()
                local start = tick()
                while tick() - start < 1 do
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
                    task.wait(3)
                end
            end)
        else
            if AntiAFKConnection then
                AntiAFKConnection:Disconnect()
                AntiAFKConnection = nil
            end
        end
    end
})

-- Infinite Jump
generalGroup:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(enabled)
        InfiniteJumpEnabled = enabled
    end
})

generalGroup:AddKeyPicker("InfJumpKey", {
    Default = "V",
    Mode = "Toggle",
    Text = "Inf Jump Keybind",
    SyncToggleState = true,
    Callback = function() end
})

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Players.LocalPlayer.CharacterAdded:Connect(function(char)
    Humanoid = char:WaitForChild("Humanoid")
end)

-- Fly
generalGroup:AddToggle("FlyEnabled", {
    Text = "Fly",
    Default = false,
    Callback = function(enabled)
        FlyEnabled = enabled
        if not enabled and HumanoidRootPart then
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
})

generalGroup:AddKeyPicker("FlyKey", {
    Default = "G",
    Mode = "Toggle",
    Text = "Fly Keybind",
    SyncToggleState = true,
    Callback = function() end
})

generalGroup:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = FlySpeed,
    Min = 1,
    Max = 2000,
    Rounding = 0,
    Callback = function(value)
        FlySpeed = value
    end
})

-- Camera settings
local cameraGroup = localTab:AddLeftGroupbox("Camera", "camera")
cameraGroup:AddSlider("FOVValue", {
    Text = "Field Of View (FOV) Changer",
    Default = Camera and Camera.FieldOfView or 70,
    Min = 1,
    Max = 120,
    Rounding = 0,
    Callback = function(value)
        if Camera then Camera.FieldOfView = value end
    end
})

cameraGroup:AddSlider("CameraZoom", {
    Text = "Camera Zoom",
    Default = 40,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        if value == 0 then
            LocalPlayer.CameraMaxZoomDistance = math.huge
            LocalPlayer.CameraMinZoomDistance = 1
        else
            LocalPlayer.CameraMaxZoomDistance = value
            LocalPlayer.CameraMinZoomDistance = math.min(0.5, value / 2)
        end
    end
})

cameraGroup:AddButton({
    Text = "Reset Camera Zoom",
    Func = function()
        cameraGroup.Flags.CameraZoom.Value = 40
        LocalPlayer.CameraMaxZoomDistance = 100
        LocalPlayer.CameraMinZoomDistance = 0.5
    end
})

-- Movement group
local moveGroup = localTab:AddRightGroupbox("Movement", "move")
moveGroup:AddToggle("WalkSpeedEnabled", {
    Text = "Enable WalkSpeed",
    Default = false,
    Callback = function(enabled)
        WalkSpeedEnabled = enabled
        if not enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

moveGroup:AddDropdown("WalkSpeedMethod", {
    Text = "WalkSpeed Method",
    Default = "Normal",
    Values = {"Normal", "CFrame"},
    Callback = function(value)
        WalkSpeedMethod = value
    end
})

moveGroup:AddSlider("WalkSpeedValue", {
    Text = "WalkSpeed Value",
    Default = WalkSpeedValue,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        WalkSpeedValue = value
        if WalkSpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

moveGroup:AddKeyPicker("WalkSpeedKey", {
    Default = "C",
    Mode = "Toggle",
    Text = "WalkSpeed Toggle",
    SyncToggleState = true
})

RunService.Heartbeat:Connect(function()
    if WalkSpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if WalkSpeedMethod == "CFrame" then
            if Humanoid.WalkSpeed ~= 16 then
                Humanoid.WalkSpeed = 16
            end
            local moveDir = Humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                LocalPlayer.Character:TranslateBy(moveDir.Unit * (WalkSpeedValue / 100))
            end
        elseif WalkSpeedMethod == "Normal" then
            if Humanoid.WalkSpeed ~= WalkSpeedValue then
                Humanoid.WalkSpeed = WalkSpeedValue
            end
        end
    end
end)

local GravitySliderDefault = workspace.Gravity
moveGroup:AddSlider("JumpPower", {
    Text = "JumpPower Changer",
    Default = JumpPowerValue,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
        JumpPowerValue = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local h = LocalPlayer.Character.Humanoid
            h.UseJumpPower = true
            h.JumpPower = value
            h:SetAttribute("JumpingEnabled", value > 0)
        end
    end
})

moveGroup:AddSlider("GravityValue", {
    Text = "Gravity Changer",
    Default = GravitySliderDefault,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        Workspace.Gravity = value
    end
})

Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
    Workspace.Gravity = moveGroup.Flags.GravityValue.Value or Workspace.Gravity
end)

-- Noclip implementation
generalGroup:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(enabled)
        NoclipEnabled = enabled

        if not Character then return end

        if enabled then
            local originalCollisions = {}
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    originalCollisions[part] = part.CanCollide
                end
            end

            local noclipConn
            noclipConn = RunService.Stepped:Connect(function()
                if not Character then
                    noclipConn:Disconnect()
                    return
                end
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)

            NoclipEnabled = true
            generalGroup._noclipConnection = noclipConn
            generalGroup._originalCollisions = originalCollisions
        else
            if generalGroup._noclipConnection then
                generalGroup._noclipConnection:Disconnect()
                generalGroup._noclipConnection = nil
            end
            if generalGroup._originalCollisions then
                for part, canCollide in pairs(generalGroup._originalCollisions) do
                    if part and part:IsA("BasePart") then
                        part.CanCollide = canCollide
                    end
                end
                generalGroup._originalCollisions = nil
            end
        end
    end
})

generalGroup:AddKeyPicker("NoclipKey", {
    Default = "N",
    Mode = "Toggle",
    Text = "Noclip Keybind",
    SyncToggleState = true
})

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    if NoclipEnabled then
        generalGroup:Set(true)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    local h = char:WaitForChild("Humanoid")
    if WalkSpeedEnabled then
        h.WalkSpeed = WalkSpeedValue
    end
    h.UseJumpPower = true
    h.JumpPower = JumpPowerValue
end)

-- Fly movement in RenderStepped
RunService.RenderStepped:Connect(function()
    if FlyEnabled and HumanoidRootPart and Camera then
        local velocity = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then velocity -= Vector3.new(0,1,0) end

        if velocity.Magnitude > 0 then
            velocity = velocity.Unit * FlySpeed
        end
        HumanoidRootPart.Velocity = velocity
    end
end)

-- ===================================
-- UI SETUP - SERVER TAB
-- ===================================

local serverTab = Window:AddTab("Server", "server")
local serverGroup = serverTab:AddLeftGroupbox("Main", "hard-drive")

serverGroup:AddButton({
    Text = "Teleport To Private Server (Copies Invite Link)",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/FreePrivateServer.lua"))()
    end
})

-- Server hop implementation
serverGroup:AddButton({
    Text = "Server Hop",
    Func = function()
        local API_URL = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        local function fetchPage(cursor)
            local result = game:HttpGet(API_URL .. ((cursor and ("&cursor=" .. cursor)) or ""))
            return HttpService:JSONDecode(result)
        end

        local cursor = nil
        repeat
            local page = fetchPage(cursor)
            for _, server in ipairs(page.data or {}) do
                if server.playing < server.maxPlayers and server.id ~= JobId then
                    local ok, err = pcall(function()
                        TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                    end)
                    if ok then return end
                end
            end
            cursor = page.nextPageCursor
        until not cursor
    end
})

serverGroup:AddButton({
    Text = "Join Small Server",
    Func = function()
        local API_URL = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local function listServers(cursor)
            local result = game:HttpGet(API_URL .. ((cursor and ("&cursor=" .. cursor)) or ""))
            return HttpService:JSONDecode(result)
        end

        local cursor
        local serverData
        repeat
            local page = listServers(cursor)
            serverData = page.data and page.data[1]
            cursor = page.nextPageCursor
        until serverData
        if serverData then
            TeleportService:TeleportToPlaceInstance(PlaceId, serverData.id, LocalPlayer)
        end
    end
})

serverGroup:AddButton({
    Text = "Rejoin Server",
    Func = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

local jobIdInput = serverGroup:AddInput("JobIdInput", {
    Default = "",
    Numeric = false,
    Finished = false,
    ClearTextOnFocus = true,
    Text = "JobId",
    Placeholder = "Enter JobId here..."
})

serverGroup:AddButton({
    Text = "Join by JobId",
    Func = function()
        local input = jobIdInput.Value
        if not input or input == "" then
            Library:Notify({Title = "JobId Not Entered", Description = "Please enter a JobId.", Time = 5})
            return
        end
        if #input ~= 36 or not input:match("^[a-f0-9%-]+$") then
            Library:Notify({Title = "Invalid JobId", Description = "The JobId you entered is not valid.", Time = 5})
            return
        end
        TeleportService:TeleportToPlaceInstance(game.PlaceId, input, LocalPlayer)
    end
})

serverGroup:AddButton({
    Text = "Copy JobId",
    Func = function()
        pcall(function()
            setclipboard(game.JobId)
            Library:Notify({Title = "Copied", Description = "Current JobId copied to clipboard.", Time = 5})
        end)
    end
})

-- ===================================
-- UI SETUP - UI SETTINGS TAB
-- ===================================

local uiTab = Window:AddTab("UI Settings", "settings")
local menuGroup = uiTab:AddLeftGroupbox("Menu", "wrench")

menuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(v)
        Library.KeybindFrame.Visible = v
    end
})

menuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = false,
    Callback = function(v)
        Library.ShowCustomCursor = v
    end
})

menuGroup:AddDropdown("NotificationSide", {
    Values = {"Left", "Right"},
    Default = "Right",
    Text = "Notification Side",
    Callback = function(side)
        Library:SetNotifySide(side)
    end
})

menuGroup:AddDropdown("DPIDropdown", {
    Values = {"50%","75%","100%","125%","150%","175%","200%"},
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(scale)
        scale = scale:gsub("%%", "")
        local num = tonumber(scale)
        Library:SetDPIScale(num)
    end
})

menuGroup:AddDivider()
menuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind"
})

menuGroup:AddButton("Unload", function()
    Library:Unload()
end)

-- Theme and save manager integration
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetDefaultTheme({
    BackgroundColor = Color3.fromRGB(22, 35, 42),
    MainColor = Color3.fromRGB(72, 120, 220),
    AccentColor = Color3.fromRGB(194, 153, 204),
    OutlineColor = Color3.fromRGB(52, 200, 70),
    FontColor = Color3.fromRGB(255, 255, 255),
    FontFace = Enum.Font.Gotham
})

SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("Samuraa1Hub")
SaveManager:SetFolder("Samuraa1Hub/ThemeParkTycoon2")
SaveManager:BuildConfigSection(uiTab)
ThemeManager:ApplyToTab(uiTab)
SaveManager:LoadAutoloadConfig()

Library.ToggleKeybind = Options.MenuKeybind

print("✅ Script loaded successfully! Samuraa1 Hub + Smart Ride Manager")
print("🎢 Use 'Smart Ride Manager' toggle in Automation tab to start earning!")
