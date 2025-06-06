
-- Custom Infinite Yield ESP avec armes, RemoteSpy, caméra furtive et interface cachée
-- Fait pour Apoc Rising 2

-- Anti-détection basique
local hiddenUIName = "__UI"
local function protectGUI(gui)
    pcall(function() gui.Name = hiddenUIName end)
    pcall(function() gui.ResetOnSpawn = false end)
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
end

-- ESP Module
local Drawing = Drawing
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local espEnabled = true
local showWeapons = true
local textSize = 14
local espObjects = {}

function createESP(plr)
    if plr == LocalPlayer then return end
    local esp = Drawing.new("Text")
    esp.Size = textSize
    esp.Center = true
    esp.Outline = true
    esp.Font = 2
    esp.Color = Color3.new(1, 1, 1)
    espObjects[plr] = esp
end

function removeESP(plr)
    if espObjects[plr] then
        espObjects[plr]:Remove()
        espObjects[plr] = nil
    end
end

for _,plr in ipairs(Players:GetPlayers()) do
    createESP(plr)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    for plr, esp in pairs(espObjects) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
            if pos.Z > 0 then
                local weapon = "?"
                if showWeapons then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        weapon = tool.Name
                    else
                        for _,t in ipairs(plr:FindFirstChildOfClass("Backpack"):GetChildren()) do
                            if t:IsA("Tool") then
                                weapon = t.Name
                                break
                            end
                        end
                    end
                end
                local dist = math.floor((Camera.CFrame.Position - char.HumanoidRootPart.Position).Magnitude)
                esp.Text = string.format("[%s]\n%s • %dm", plr.Name, weapon, dist)
                esp.Position = Vector2.new(pos.X, pos.Y)
                esp.Visible = true
            else
                esp.Visible = false
            end
        else
            esp.Visible = false
        end
    end
end)

-- RemoteSpy ultra léger
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if tostring(method) == "FireServer" or tostring(method) == "InvokeServer" then
        print("📡", self:GetFullName(), "args:", unpack(args))
    end
    return oldNamecall(self, ...)
end)

-- Caméra furtive
_G.silentViewTarget = nil
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.silentViewTarget and _G.silentViewTarget.Character and _G.silentViewTarget.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, _G.silentViewTarget.Character.Head.Position)
    end
end)

-- Commande pour activer la caméra furtive
game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
    if msg:sub(1, 5) == "!spy " then
        local name = msg:sub(6):lower()
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Name:lower():sub(1, #name) == name then
                _G.silentViewTarget = p
                print("👁️ Caméra fixée sur", p.Name)
            end
        end
    elseif msg == "!unspy" then
        _G.silentViewTarget = nil
        print("👁️ Caméra restaurée")
    elseif msg == "!esp" then
        espEnabled = not espEnabled
        print("ESP activé :", espEnabled)
    elseif msg:sub(1,10) == "!espsize " then
        local s = tonumber(msg:sub(11))
        if s then
            textSize = s
            for _,v in pairs(espObjects) do
                v.Size = textSize
            end
            print("🆙 Taille texte ESP :", textSize)
        end
    end
end)
