local charh = workspace
local function tochar(plr)
    if plr == game.Players.LocalPlayer then
        if plr.Character then
            charh = plr.Character.Parent
        end
        return plr.Character
    end
    for i,v in pairs(charh:GetChildren()) do
        if v:IsA('Model') and v:FindFirstChildOfClass('Humanoid') and game.Players:GetPlayerFromCharacter(v) == plr then
            return v
        end
    end
end

local function name(x)
    return setmetatable({x=x},{__call=function(s)s.x=s.x..string.char(math.random(1,127))return s;end})()()()()()()()()()().x
end

local op = Instance.new('ScreenGui')
op.Name = name''
if syn and syn.protect_gui then
    syn.protect_gui(op)
end

local function dothing(esp)
    local char = esp.char
    local esp2 = esp.esp[1]

    local o = esp2:Clone()
    o.Parent = op
    table.insert(esp.esp, o)
    delay(2, function()
        o:Destroy()
    end)

    local pos = (char.PrimaryPart or char:FindFirstChildOfClass('Part')).Position
    local cam = workspace.CurrentCamera
    if cam then
        local pos2, on = cam:WorldToScreenPoint(pos)
        esp2.Visible = on

        local x1, y2 = 100 / cam.ViewportSize.X, 100 / cam.ViewportSize.Y
        esp2.Size = UDim2.fromScale(x1, y2)
        esp2.Position = UDim2.new(-x1 / 2, pos2.X, -y2 / 2, pos2.Y)
    end
end
local function new(Character)
    local f = Instance.new('Frame')
    f.Name = name''
    f.BackgroundTransparency = 1
    local f1 = Instance.new('Frame')
    f1.Name = name''
    f1.BorderSizePixel = 0
    f1.Size = UDim2.new(0, 1, 1, 0)
    f1.Parent = f
    local f2 = Instance.new('Frame')
    f2.AnchorPoint = Vector2.new(1, 0)
    f2.Name = name''
    f2.BorderSizePixel = 0
    f2.Size = UDim2.new(0, 1, 1, 0)
    f2.Position = UDim2.new(1, -1, 0, 0)
    f2.Parent = f

    f.Parent = op
    return f
end

local char_ = {}
local ui = {}
game.RunService.Stepped:Connect(function()
    local plrs = game.Players:GetPlayers()
    table.remove(plrs)
    for _,p in pairs(plrs) do
        if char_[p] ~= tochar(p) then
            char_[p] = tochar(p)
        end

        local char = char_[p]
        if char then
            if (ui[p] and ui[p].char) ~= char then
                if ui[p] and ui[p].esp then
                    for i,v in pairs(ui[p].esp) do
                        v:Destroy()
                    end
                end
                ui[p] = {}
                ui[p].char = char
                ui[p].esp = {
                    new(char)
                }
            end
            dothing(ui[p])
        end
    end
end)

op.Parent = game.CoreGui
