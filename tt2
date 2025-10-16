-- ✅ Load the UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/UI-Library/refs/heads/main/Ghost%20Gui"))()
local Window = Library:CreateWindow("Auto Farm Menu") -- 🌟 Menu Title

-- 🧭 Tab / Section
local FarmTab = Window:CreateTab("Main")

-- 🧠 Variables
local autoTrashEnabled = false
local autoMoneyEnabled = false
local antiAFKEnabled = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 🔸 Remote Events (based on your explorer)
local CleanTrashEvent = ReplicatedStorage:WaitForChild("Communication"):WaitForChild("SCleanTrash")
local MoneyEvent = ReplicatedStorage:WaitForChild("Communication"):WaitForChild("CShowMoneyDelta")

-----------------------------------------------------------
-- 🧹 AUTO TRASH COLLECTOR
-----------------------------------------------------------
FarmTab:CreateToggle("Auto Trash Collector", false, function(state)
	autoTrashEnabled = state
	if state then
		task.spawn(function()
			while autoTrashEnabled do
				for _, tycoon in pairs(Workspace.Tycoons:GetChildren()) do
					local trashFolder = tycoon:FindFirstChild("Trash")
					if trashFolder then
						for _, trash in pairs(trashFolder:GetChildren()) do
							if trash:IsA("BasePart") then
								CleanTrashEvent:FireServer(trash)
							end
						end
					end
				end
				task.wait(2) -- 🕒 interval for collecting trash
			end
		end)
	end
end)

-----------------------------------------------------------
-- 💰 AUTO MONEY ADDER (for testing only)
-----------------------------------------------------------
FarmTab:CreateToggle("Auto Money", false, function(state)
	autoMoneyEnabled = state
	if state then
		task.spawn(function()
			while autoMoneyEnabled do
				MoneyEvent:FireServer(1000) -- 💵 amount per tick
				task.wait(1) -- 🕒 interval for adding money
			end
		end)
	end
end)

-----------------------------------------------------------
-- 🏃 ANTI-AFK
-----------------------------------------------------------
FarmTab:CreateToggle("Anti-AFK", false, function(state)
	antiAFKEnabled = state
	if state then
		local vu = game:GetService("VirtualUser")
		LocalPlayer.Idled:Connect(function()
			if antiAFKEnabled then
				vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
				task.wait(1)
				vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
			end
		end)
	end
end)
