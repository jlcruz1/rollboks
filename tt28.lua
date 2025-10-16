-- Load Ghost GUI Library
loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/UI-Library/refs/heads/main/Ghost%20Gui'))()

-- Wait for GUI to load and change the title
local gui = game.CoreGui:WaitForChild("GhostGui")
gui.MainFrame.Title.Text = "Elizabeth Menu"

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Communication = ReplicatedStorage:FindFirstChild("Communication")
local cleanRemote = Communication and Communication:FindFirstChild("SCleanTrash")
local setCleaningState = Communication and Communication:FindFirstChild("SSetCleaningState")

local tableFind = table.find
local function arrayContains(list, value)
    if tableFind then
        return tableFind(list, value)
    end

    for i, v in ipairs(list) do
        if v == value then
            return i
        end
    end

    return nil
end

local function tableClear(t)
    if table.clear then
        table.clear(t)
        return
    end

    for k in pairs(t) do
        t[k] = nil
    end
end

----------------------------------------------------------------
-- 🧺 Pool + Tycoon helpers
----------------------------------------------------------------
local poolNames = {"itemPools", "sItemPools", "trashPools"}
local poolCache = {}

local function scanForPools(root)
    if not root then
        return
    end

    for _, child in ipairs(root:GetChildren()) do
        if arrayContains(poolNames, child.Name) then
            poolCache[child.Name] = child
        end
        scanForPools(child)
    end
end

local function refreshPools()
    tableClear(poolCache)
    scanForPools(player)
end

refreshPools()

player.DescendantAdded:Connect(function(desc)
    if desc and arrayContains(poolNames, desc.Name) then
        poolCache[desc.Name] = desc
    end
end)

player.DescendantRemoving:Connect(function(desc)
    if desc and arrayContains(poolNames, desc.Name) and poolCache[desc.Name] == desc then
        poolCache[desc.Name] = nil
    end
end)

local function getPool(name)
    local pool = poolCache[name]
    if pool and pool.Parent then
        return pool
    end

    refreshPools()
    pool = poolCache[name]
    if pool and pool.Parent then
        return pool
    end

    return nil
end

local function waitForPool(name, timeout)
    local deadline = os.clock() + (timeout or 6)
    local pool = getPool(name)

    while not pool and os.clock() < deadline do
        task.wait(0.2)
        pool = getPool(name)
    end

    return pool
end

local function clearFolder(folder)
    local removed = 0

    if folder then
        for _, item in ipairs(folder:GetChildren()) do
            local ok = pcall(function()
                item:Destroy()
            end)
            if ok then
                removed += 1
            end
        end
    end

    return removed
end

local function clearPools(names, timeout)
    local totalRemoved = 0
    local missing = {}

    for _, name in ipairs(names) do
        local pool = waitForPool(name, timeout)
        if pool then
            totalRemoved += clearFolder(pool)
        else
            table.insert(missing, name)
        end
    end

    return totalRemoved, missing
end

local function matchesOwner(tycoon)
    if not tycoon then
        return false
    end

    local attrUserId = tycoon:GetAttribute("OwnerUserId")
    if typeof(attrUserId) == "number" and attrUserId == player.UserId then
        return true
    end

    local owner = tycoon:FindFirstChild("Owner")
    if owner then
        if owner:IsA("ObjectValue") and owner.Value == player then
            return true
        elseif owner:IsA("StringValue") and owner.Value == player.Name then
            return true
        elseif owner:IsA("IntValue") and owner.Value == player.UserId then
            return true
        end
    end

    local ownerId = tycoon:FindFirstChild("OwnerUserId") or tycoon:FindFirstChild("OwnerId")
    if ownerId and ownerId:IsA("IntValue") and ownerId.Value == player.UserId then
        return true
    end

    return false
end

local function findTycoon()
    local container = Workspace:FindFirstChild("Tycoons")
        or Workspace:FindFirstChild("Tycoon")
        or Workspace:FindFirstChild("TycoonFolder")

    if not container then
        return nil
    end

    for _, tycoon in ipairs(container:GetChildren()) do
        if matchesOwner(tycoon) then
            return tycoon
        end
    end

    return nil
end

local function collectTrashParts(root, bag)
    bag = bag or {}
    if not root then
        return bag
    end

    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("BasePart") and child.Name:lower():find("trash") then
            table.insert(bag, child)
        elseif child:IsA("Folder") then
            local lower = child.Name:lower()
            if lower:find("trash") then
                collectTrashParts(child, bag)
            else
                collectTrashParts(child, bag)
            end
        else
            collectTrashParts(child, bag)
        end
    end

    return bag
end

local function fireRemote(remote, ...)
    if not remote then
        return false
    end

    if remote:IsA("RemoteFunction") then
        local ok = pcall(function()
            remote:InvokeServer(...)
        end)
        return ok
    end

    local ok = pcall(function()
        remote:FireServer(...)
    end)
    return ok
end

local function cleanTrashServerSide(trashParts)
    if not cleanRemote or not setCleaningState then
        return 0, "remote-missing"
    end

    if not trashParts or #trashParts == 0 then
        return 0, "none"
    end

    fireRemote(setCleaningState, true)

    local cleaned = 0
    for _, trash in ipairs(trashParts) do
        if trash and trash.Parent then
            if fireRemote(cleanRemote, trash) then
                cleaned += 1
            end
        end
    end

    fireRemote(setCleaningState, false)

    return cleaned, (cleaned > 0 and "ok") or "none"
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
local helpers = sharedEnv.ElizabethHelpers

helpers.poolNames = poolNames
helpers.waitForPool = waitForPool
helpers.clearPools = clearPools
helpers.notify = notify
helpers.findTycoon = findTycoon
helpers.collectTrashParts = collectTrashParts
helpers.cleanTrashServerSide = cleanTrashServerSide
helpers.cleanRemote = cleanRemote
helpers.setCleaningState = setCleaningState
helpers.fireRemote = fireRemote

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
    local totalRemoved, missingPools = helpers.clearPools(helpers.poolNames, 4)

    local tycoon = helpers.findTycoon()
    local trashParts = tycoon and helpers.collectTrashParts(tycoon) or {}
    local cleanedCount, status = helpers.cleanTrashServerSide(trashParts)

    if totalRemoved > 0 then
        helpers.notify("🧹 Auto Cleanup", "Cleared "..totalRemoved.." pooled items.")
    end

    if cleanedCount > 0 then
        helpers.notify("🧹 Auto Cleanup", "Cleaned "..cleanedCount.." trash pile(s) in your park.")
    end

    if (not tycoon) and status ~= "remote-missing" then
        helpers.notify("Elizabeth", "Tycoon not found yet — claim your park first.")
    end

    if status == "remote-missing" then
        helpers.notify("Elizabeth", "SCleanTrash remote not available in this copy.")
    end

    if missingPools and #missingPools > 0 then
        helpers.notify("Elizabeth", "Missing pools: "..table.concat(missingPools, ", "))
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

    local tycoon = helpers.findTycoon()
    if not tycoon then
        helpers.notify("Elizabeth", "Tycoon not found — claim your park first.")
        return
    end

    local trashParts = helpers.collectTrashParts(tycoon)
    local cleaned, status = helpers.cleanTrashServerSide(trashParts)

    if cleaned > 0 then
        helpers.notify("🗑️ Trash Cleared", "Removed "..cleaned.." trash pile(s)!")
    elseif status == "remote-missing" then
        helpers.notify("Elizabeth", "Cannot reach SCleanTrash remote in this copy.")
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

    local totalRemoved, missingPools = helpers.clearPools(helpers.poolNames, 4)

    local tycoon = helpers.findTycoon()
    local trashParts = tycoon and helpers.collectTrashParts(tycoon) or {}
    local cleaned, status = helpers.cleanTrashServerSide(trashParts)

    if totalRemoved + cleaned > 0 then
        helpers.notify("🧼 Clean All", "Cleared "..(totalRemoved + cleaned).." items/trash.")
    elseif status == "remote-missing" then
        helpers.notify("Elizabeth", "Cannot reach SCleanTrash remote in this copy.")
    else
        helpers.notify("🧼 Clean All", "Nothing to clean right now.")
    end

    if (not tycoon) and status ~= "remote-missing" then
        helpers.notify("Elizabeth", "Tycoon not found yet — claim your park first.")
    end

    if missingPools and #missingPools > 0 then
        helpers.notify("Elizabeth", "Missing pools: "..table.concat(missingPools, ", "))
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
