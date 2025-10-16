-- Load Ghost GUI Library
loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/UI-Library/refs/heads/main/Ghost%20Gui'))()

-- Wait for GUI to load and change the title
local gui = game.CoreGui:WaitForChild("GhostGui")
gui.MainFrame.Title.Text = "Elizabeth Menu"

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

----------------------------------------------------------------
-- 🧺 Pool discovery helpers
----------------------------------------------------------------
local poolNames = {"itemPools", "sItemPools", "trashPools"}
local poolMap = {}

local function scanForPools(root)
    if not root then
        return
    end

    for _, name in ipairs(poolNames) do
        if root.Name == name then
            poolMap[name] = root
        end
    end

    for _, child in ipairs(root:GetChildren()) do
        scanForPools(child)
    end
end

scanForPools(player)

player.DescendantAdded:Connect(function(desc)
    if desc and table.find(poolNames, desc.Name) then
        poolMap[desc.Name] = desc
    end
end)

player.DescendantRemoving:Connect(function(desc)
    if desc and table.find(poolNames, desc.Name) and poolMap[desc.Name] == desc then
        poolMap[desc.Name] = nil
    end
end)

local function getPool(name)
    local pool = poolMap[name]
    if pool and pool.Parent then
        return pool
    end

    poolMap[name] = nil
    scanForPools(player)
    pool = poolMap[name]

    if pool and pool.Parent then
        return pool
    end

    return nil
end

local function waitForPool(name, timeout)
    local deadline = os.clock() + (timeout or 8)
    local pool = getPool(name)

    while not pool and os.clock() < deadline do
        task.wait(0.2)
        pool = getPool(name)
    end

    return pool
end

local function clearFolderContents(folder)
    local count = 0

    if folder then
        for _, item in ipairs(folder:GetChildren()) do
            local ok = pcall(function()
                item:Destroy()
            end)

            if ok then
                count += 1
            end
        end
    end

    return count
end

local function clearPools(names, timeout)
    local total = 0
    local missing = {}

    for _, name in ipairs(names) do
        local pool = waitForPool(name, timeout)
        if pool then
            total += clearFolderContents(pool)
        else
            table.insert(missing, name)
        end
    end

    return total, missing
end

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5,
        })
    end)
end

local sharedEnv = (getgenv and getgenv()) or _G
sharedEnv.ElizabethHelpers = sharedEnv.ElizabethHelpers or {}
sharedEnv.ElizabethHelpers.waitForPool = waitForPool
sharedEnv.ElizabethHelpers.clearPools = clearPools
sharedEnv.ElizabethHelpers.poolNames = poolNames
sharedEnv.ElizabethHelpers.notify = notify
sharedEnv.ElizabethHelpers.clearFolderContents = clearFolderContents
sharedEnv.ElizabethHelpers.getPool = getPool

local helpers = sharedEnv.ElizabethHelpers

----------------------------------------------------------------
-- 🪄 UI Enhancement: Rounded Corners + Shadow
----------------------------------------------------------------
local function beautify(frame)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = frame
end

-- Apply style to main frame
beautify(gui.MainFrame)

----------------------------------------------------------------
-- ❌ Close (X) Button — Now on Left Side
----------------------------------------------------------------
local closeButton = Instance.new("TextButton")
closeButton.Parent = gui.MainFrame
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(0, 10, 0, 8) -- left side
closeButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.ZIndex = 10
beautify(closeButton)

closeButton.MouseEnter:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
end)
closeButton.MouseLeave:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
end)

closeButton.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

----------------------------------------------------------------
-- ⌨️ Right Shift Hotkey to Reopen GUI
----------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)

----------------------------------------------------------------
-- 🧹 Auto Cleanup (Runs Once on Load)
----------------------------------------------------------------
task.spawn(function()
    local totalRemoved, missing = helpers.clearPools(poolNames, 6)

    if totalRemoved > 0 then
        helpers.notify("🧹 Auto Cleanup", "Removed "..totalRemoved.." unused items from all pools.")
    end

    if missing and #missing > 0 then
        helpers.notify("Elizabeth", "Missing pools: "..table.concat(missing, ", "))
    end
end)

----------------------------------------------------------------
-- 🗑️ Remove Trash Button
----------------------------------------------------------------
AddContent("TextButton", "Remove Trash", [[
    local helpers = (getgenv and getgenv().ElizabethHelpers) or _G.ElizabethHelpers
    if not helpers then
        return
    end

    local pool, missing = helpers.waitForPool("trashPools", 6), {}
    local removed = helpers.clearFolderContents(pool)

    if removed > 0 then
        helpers.notify("🗑️ Trash Cleared", "Removed "..removed.." trash item(s)!")
    else
        helpers.notify("🗑️ Remove Trash", "No trash found right now.")
    end
]])

----------------------------------------------------------------
-- 🧼 Clean All Button (Items + SItems + Trash)
----------------------------------------------------------------
AddContent("TextButton", "Clean All", [[
    local helpers = (getgenv and getgenv().ElizabethHelpers) or _G.ElizabethHelpers
    if not helpers then
        return
    end

    local totalRemoved, missing = helpers.clearPools(helpers.poolNames, 6)

    if totalRemoved > 0 then
        helpers.notify("🧼 Clean All", "Removed "..totalRemoved.." total items from all pools!")
    else
        helpers.notify("🧼 Clean All", "Nothing to clean right now.")
    end

    if missing and #missing > 0 then
        helpers.notify("Elizabeth", "Missing pools: "..table.concat(missing, ", "))
    end
]])

----------------------------------------------------------------
-- 📌 Fixed Text at the Bottom (Elizabeth)
----------------------------------------------------------------
local TextLabel = AddContent("TextLabel")
TextLabel.Text = "Elizabeth"

----------------------------------------------------------------
-- 🛡️ Anti-AFK Button
----------------------------------------------------------------
AddContent("TextButton", "Anti-AFK", [[
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Anti-AFK";
        Text = "Anti-AFK activated successfully!";
        Duration = 5;
    })
]])
