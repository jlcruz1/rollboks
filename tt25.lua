local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/UI-Library/refs/heads/main/Ghost%20Gui'))()

----------------------------------------------------------------
-- :window: UI Setup
----------------------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TrashCleanerMenu"

local mainFrame = Instance.new("Frame", gui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = ":broom: Trash Cleaner Menu"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

----------------------------------------------------------------
-- :x: Close Button (Top-Left)
----------------------------------------------------------------
local closeButton = Instance.new("TextButton", mainFrame)
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(0, 10, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.BorderSizePixel = 0
closeButton.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

----------------------------------------------------------------
-- :radio_button: Button Helper
----------------------------------------------------------------
local function AddButton(name, func)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, (#mainFrame:GetChildren() - 1) * 45)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = name
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(func)
end

----------------------------------------------------------------
-- :wastebasket: Trash Remover Logic
----------------------------------------------------------------
local function CleanTrash()
    local count = 0
    for _, tycoon in pairs(workspace.Tycoons:GetChildren()) do
        local trashFolder = tycoon:FindFirstChild("Trash")
            or tycoon:FindFirstChild("trashPools")
            or tycoon:FindFirstChild("trashPool")
        
        if trashFolder then
            for _, trash in pairs(trashFolder:GetChildren()) do
                if trash:IsA("Model") or trash:IsA("Part") then
                    trash:Destroy()
                    count += 1
                end
            end
        end
    end

    game.StarterGui:SetCore("SendNotification", {
        Title = ":broom: Trash Cleaner";
        Text = "Removed " .. tostring(count) .. " trash objects!";
        Duration = 4;
    })
end

----------------------------------------------------------------
-- :gear: Add UI Buttons
----------------------------------------------------------------
AddButton(":broom: Clean Trash", CleanTrash)

----------------------------------------------------------------
-- :keyboard: Toggle Menu (RightShift)
----------------------------------------------------------------
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.RightShift and not gp then
        gui.Enabled = not gui.Enabled
    end
end)
