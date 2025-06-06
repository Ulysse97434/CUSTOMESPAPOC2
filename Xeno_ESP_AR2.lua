
-- ESP complet pour Xeno Executor (compatible mobile/PC, sans Drawing API)
-- Affiche pseudo + arme principale/secondaire + distance via BillboardGui
-- Interface masquable avec la touche "K"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Création de l'interface toggle
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "XenoESP_UI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 140)
frame.Position = UDim2.new(0, 20, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Visible = true

local function createButton(name, posY, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Text = name .. ": OFF"

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

local espEnabled = false
createButton("ESP", 10, function(v) espEnabled = v end)

-- Stockage des GUI ESP
local billboardTable = {}

-- Fonction de création du Billboard
local function createBillboard(player)
    if billboardTable[player] then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP"
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.Adornee = nil
    bb.AlwaysOnTop = true
    bb.ExtentsOffset = Vector3.new(0, 2.5, 0)

    local textLabel = Instance.new("TextLabel", bb)
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14
    textLabel.Text = "..."

    billboardTable[player] = {gui = bb, label = textLabel}
end

-- Nettoyage
local function removeBillboard(player)
    if billboardTable[player] then
        billboardTable[player].gui:Destroy()
        billboardTable[player] = nil
    end
end

Players.PlayerRemoving:Connect(removeBillboard)

-- Boucle de mise à jour
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if not billboardTable[player] then
                    createBillboard(player)
                end

                local guiData = billboardTable[player]
                guiData.gui.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if espEnabled then
                    local dist = math.floor((char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    local primary, secondary = "?", "?"
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then primary = tool.Name end
                    local bp = player:FindFirstChild("Backpack")
                    if bp then
                        for _, v in pairs(bp:GetChildren()) do
                            if v:IsA("Tool") then
                                secondary = v.Name
                                break
                            end
                        end
                    end
                    guiData.label.Text = string.format("[%s]\n%s / %s • %dm", player.Name, primary, secondary, dist)
                    guiData.gui.Enabled = true
                    guiData.gui.Parent = game.CoreGui
                else
                    guiData.gui.Enabled = false
                end
            else
                removeBillboard(player)
            end
        end
    end
end)

-- Touche pour afficher/masquer interface (K)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then
        frame.Visible = not frame.Visible
    end
end)
