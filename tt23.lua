-- Load Ghost GUI Library
loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/UI-Library/refs/heads/main/Ghost%20Gui'))()

-- Wait for GUI to load and change the title
local gui = game.CoreGui:WaitForChild("GhostGui")
gui.MainFrame.Title.Text = "Elizabeth Menu"

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
    local player = game:GetService("Players").LocalPlayer
    local pools = {Items = "itemPools", SItems = "sItemPools", Trash = "trashPools"}
    local totalRemoved = 0

    for _, poolName in pairs(pools) do
        local pool = player:FindFirstChild(poolName)
        if pool then
            for _, item in pairs(pool:GetChildren()) do
                item:Destroy()
                totalRemoved += 1
            end
        end
    end

    game.StarterGui:SetCore("SendNotification", {
        Title = "🧹 Auto Cleanup",
        Text = "Removed "..totalRemoved.." unused items from all pools.",
        Duration = 5;
    })
end)

----------------------------------------------------------------
-- 🗑️ Remove Trash Button
----------------------------------------------------------------
AddContent("TextButton", "Remove Trash", [[
    local player = game:GetService("Players").LocalPlayer
    local pools = {Items = "itemPools", SItems = "sItemPools", Trash = "trashPools"}
    local removed = 0

    local trashPool = player:FindFirstChild(pools.Trash)
    if trashPool then
        for _, item in pairs(trashPool:GetChildren()) do
            item:Destroy()
            removed += 1
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "🗑️ Trash Cleared",
            Text = "Removed "..removed.." trash item(s)!",
            Duration = 5;
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "🗑️ Remove Trash",
            Text = "No trash pool found in your data.",
            Duration = 5;
        })
    end
]])

----------------------------------------------------------------
-- 🧼 Clean All Button (Items + SItems + Trash)
----------------------------------------------------------------
AddContent("TextButton", "Clean All", [[
    local player = game:GetService("Players").LocalPlayer
    local pools = {Items = "itemPools", SItems = "sItemPools", Trash = "trashPools"}
    local totalRemoved = 0

    for _, poolName in pairs(pools) do
        local pool = player:FindFirstChild(poolName)
        if pool then
            for _, item in pairs(pool:GetChildren()) do
                item:Destroy()
                totalRemoved += 1
            end
        end
    end

    game.StarterGui:SetCore("SendNotification", {
        Title = "🧼 Clean All",
        Text = "Removed "..totalRemoved.." total items from all pools!",
        Duration = 5;
    })
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
