
-- ESP Clean pour Apocalypse Rising 2
-- Ulysse v1 - à but pédagogique

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Setup UI (discret, clean)
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "__uxp"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false

local Frame = Instance.new("Frame", Gui)
Frame.Position = UDim2.new(0, 30, 0.5, -80)
Frame.Size = UDim2.new(0, 200, 0, 160)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Visible = true
Frame.BorderSizePixel = 0

local function makeToggle(name, y, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Text = name .. ": OFF"
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

-- Global toggles
local showESP, showTracers, showHitbox, showSkeleton = false, false, false, false
makeToggle("ESP", 10, function(s) showESP = s end)
makeToggle("Tracers", 45, function(s) showTracers = s end)
makeToggle("Hitbox", 80, function(s) showHitbox = s end)
makeToggle("Skeleton", 115, function(s) showSkeleton = s end)

-- Drawing table
local drawings = {}

function newDrawing(t, props)
    local d = Drawing.new(t)
    for k,v in pairs(props) do
        d[k] = v
    end
    return d
end

function clearDrawings(p)
    if drawings[p] then
        for _,d in pairs(drawings[p]) do
            if d and d.Remove then d:Remove() end
        end
        drawings[p] = nil
    end
end

function updateDrawings(p)
    local char = p.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not Camera then return end
    local hrp = char.HumanoidRootPart
    local pos, visible = Camera:WorldToViewportPoint(hrp.Position)
    if not visible then return end

    drawings[p] = drawings[p] or {}

    -- ESP
    if showESP then
        if not drawings[p].esp then
            drawings[p].esp = newDrawing("Text", {
                Color = Color3.new(1,1,1),
                Size = 13,
                Center = true,
                Outline = true,
                Font = 2
            })
        end
        local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
        local weapon1, weapon2 = "?", "?"
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then weapon1 = tool.Name end
        local backpack = p:FindFirstChild("Backpack")
        if backpack then
            for _,v in pairs(backpack:GetChildren()) do
                if v:IsA("Tool") then
                    weapon2 = v.Name
                    break
                end
            end
        end
        drawings[p].esp.Text = string.format("[%s]\n%s / %s • %dm", p.Name, weapon1, weapon2, dist)
        drawings[p].esp.Position = Vector2.new(pos.X, pos.Y - 25)
        drawings[p].esp.Visible = true
    elseif drawings[p].esp then
        drawings[p].esp.Visible = false
    end

    -- Tracers
    if showTracers then
        drawings[p].tracer = drawings[p].tracer or newDrawing("Line", {Color=Color3.new(1,1,1), Thickness=1})
        drawings[p].tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        drawings[p].tracer.To = Vector2.new(pos.X, pos.Y)
        drawings[p].tracer.Visible = true
    elseif drawings[p].tracer then
        drawings[p].tracer.Visible = false
    end

    -- Hitbox
    if showHitbox then
        drawings[p].box = drawings[p].box or newDrawing("Square", {
            Color=Color3.new(1,0,0),
            Thickness=1,
            Filled=false,
        })
        drawings[p].box.Size = Vector2.new(40, 40)
        drawings[p].box.Position = Vector2.new(pos.X-20, pos.Y-20)
        drawings[p].box.Visible = true
    elseif drawings[p].box then
        drawings[p].box.Visible = false
    end

    -- Skeleton (simple ligne head -> HRP)
    if showSkeleton and char:FindFirstChild("Head") then
        local hpos = Camera:WorldToViewportPoint(char.Head.Position)
        drawings[p].skel = drawings[p].skel or newDrawing("Line", {Color=Color3.new(0,1,0), Thickness=1})
        drawings[p].skel.From = Vector2.new(hpos.X, hpos.Y)
        drawings[p].skel.To = Vector2.new(pos.X, pos.Y)
        drawings[p].skel.Visible = true
    elseif drawings[p].skel then
        drawings[p].skel.Visible = false
    end
end

-- Main update loop
RunService.RenderStepped:Connect(function()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            updateDrawings(p)
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    clearDrawings(p)
end)

-- Toggle GUI visibility (K key)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then
        Frame.Visible = not Frame.Visible
    end
end)
