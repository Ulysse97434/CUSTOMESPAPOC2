

local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local enabled = true
local maxDistance = 10000

-- GUI setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ESP_GUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0, 20, 0, 150)
Frame.Size = UDim2.new(0, 200, 0, 140)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Visible = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "ESP Settings"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local toggleButton = Instance.new("TextButton", Frame)
toggleButton.Position = UDim2.new(0, 0, 0, 40)
toggleButton.Size = UDim2.new(1, 0, 0, 30)
toggleButton.Text = "Toggle ESP: ON"
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 18

toggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggleButton.Text = "Toggle ESP: " .. (enabled and "ON" or "OFF")
end)

-- ESP setup
local espFolder = Instance.new("Folder", game.CoreGui)
espFolder.Name = "ESP_UI"

local espData = {}

function createESP(player)
    if player == localPlayer then return end
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.Adornee = char:FindFirstChild("Head")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = espFolder

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Text = player.Name

    local toolLabel = Instance.new("TextLabel", billboard)
    toolLabel.Position = UDim2.new(0, 0, 0.5, 0)
    toolLabel.Size = UDim2.new(1, 0, 0.5, 0)
    toolLabel.BackgroundTransparency = 1
    toolLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    toolLabel.TextStrokeTransparency = 0.7
    toolLabel.TextScaled = true
    toolLabel.Font = Enum.Font.SourceSans
    toolLabel.Text = ""

    return {billboard = billboard, nameLabel = nameLabel, toolLabel = toolLabel}
end

function updateESP()
    if not enabled then return end
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if not espData[player] then
                espData[player] = createESP(player)
            end
            local char = player.Character
            local toolList = {}
            for _, item in ipairs(player.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(toolList, item.Name)
                end
            end
            local holding = char:FindFirstChildOfClass("Tool")
            if holding then
                table.insert(toolList, holding.Name)
            end
            local dist = math.floor((camera.CFrame.Position - char.Head.Position).Magnitude)
            if dist < maxDistance then
                espData[player].toolLabel.Text = "[" .. table.concat(toolList, ", ") .. "] - " .. dist .. "m"
                espData[player].billboard.Enabled = true
            else
                espData[player].billboard.Enabled = false
            end
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        espData[player] = createESP(player)
    end)
end)
