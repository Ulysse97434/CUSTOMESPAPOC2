
-- DenHub-style ESP for Apocalypse Rising 2 (Xeno Compatible)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "DenStyleHub"
gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Size = UDim2.new(0, 200, 0, 130)
main.Position = UDim2.new(0, 20, 0.5, -65)
main.BorderSizePixel = 0
main.Visible = true

-- Toggle UI
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then
        main.Visible = not main.Visible
    end
end)

-- Buttons
local function createButton(txt, y, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Text = txt .. ": OFF"

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = txt .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

local espEnabled = false
createButton("ESP", 10, function(s) espEnabled = s end)

-- Billboard storage
local espObjects = {}

local function createESP(plr)
    if espObjects[plr] then return end
    local char = plr.Character
    if not char or not char:FindFirstChild("Head") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESPBillboard"
    bb.Adornee = char:FindFirstChild("Head")
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.AlwaysOnTop = true
    bb.Parent = char:FindFirstChild("Head")

    local text = Instance.new("TextLabel", bb)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextStrokeTransparency = 0.5
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = 14
    text.Text = "[ESP]"

    espObjects[plr] = {gui = bb, label = text}
end

local function removeESP(plr)
    if espObjects[plr] then
        espObjects[plr].gui:Destroy()
        espObjects[plr] = nil
    end
end

Players.PlayerRemoving:Connect(removeESP)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        createESP(p)
    end)
end)

RunService.RenderStepped:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            if not espObjects[plr] then
                createESP(plr)
            end

            local obj = espObjects[plr]
            if espEnabled then
                local distance = math.floor((plr.Character.Head.Position - Camera.CFrame.Position).Magnitude)
                local tool = plr.Character:FindFirstChildOfClass("Tool")
                local weapon = tool and tool.Name or "?"
                obj.label.Text = string.format("[%s]\n%s - %dm", plr.Name, weapon, distance)
                obj.gui.Enabled = true
            else
                obj.gui.Enabled = false
            end
        end
    end
end)
