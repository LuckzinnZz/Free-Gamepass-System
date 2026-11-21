
-- FREE GAMEPASS SYSTEM V3
-- Client.lua
-- Interface exclusiva do dono permanente

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild(
    "FreeGamepassRequest", 15
)

if not remote then
    warn("Free Gamepass: servidor nao instalado")
    return
end

local gui = Instance.new("ScreenGui")
gui.Name = "FreeGamepassSystem"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function create(class, props, parent)
    local obj = Instance.new(class)
    for key, value in pairs(props) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local button = create("TextButton", {
    Size = UDim2.fromOffset(140, 45),
    Position = UDim2.new(0, 15, 0.5, 0),
    BackgroundColor3 = Color3.fromRGB(40, 100, 255),
    Text = "FREE PASSES",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    Visible = false
}, gui)

create("UICorner", {
    CornerRadius = UDim.new(0, 10)
}, button)

local panel = create("Frame", {
    Size = UDim2.fromOffset(310, 230),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(30, 32, 38),
    Visible = false
}, gui)

create("UICorner", {
    CornerRadius = UDim.new(0, 14)
}, panel)

create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 55),
    BackgroundTransparency = 1,
    Text = "FREE GAMEPASS",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 21,
    Font = Enum.Font.GothamBold
}, panel)

local input = create("TextBox", {
    Size = UDim2.new(1, -30, 0, 45),
    Position = UDim2.fromOffset(15, 65),
    BackgroundColor3 = Color3.fromRGB(50, 53, 62),
    PlaceholderText = "Gamepass ID",
    Text = "",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 17,
    ClearTextOnFocus = false
}, panel)

create("UICorner", {
    CornerRadius = UDim.new(0, 8)
}, input)

local free = create("TextButton", {
    Size = UDim2.new(1, -30, 0, 48),
    Position = UDim2.fromOffset(15, 125),
    BackgroundColor3 = Color3.fromRGB(45, 105, 255),
    Text = "Free",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 22,
    Font = Enum.Font.GothamBold
}, panel)

create("UICorner", {
    CornerRadius = UDim.new(0, 9)
}, free)

local status = create("TextLabel", {
    Size = UDim2.new(1, -30, 0, 45),
    Position = UDim2.fromOffset(15, 180),
    BackgroundTransparency = 1,
    Text = "Enter a Gamepass ID",
    TextColor3 = Color3.fromRGB(210, 210, 215),
    TextSize = 13,
    TextWrapped = true
}, panel)

button.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

free.MouseButton1Click:Connect(function()
    local id = tonumber(input.Text)

    if not id then
        status.Text = "Invalid Gamepass ID"
        return
    end

    free.Active = false
    status.Text = "Activating..."

    local ok, success, message = pcall(function()
        return remote:InvokeServer("grant", id)
    end)

    if ok and success then
        free.Text = "Activated!"
        status.Text = message
    else
        status.Text = ok and tostring(message)
            or "Connection error"
    end

    free.Active = true
end)

local function updateAccess()
    local allowed =
        player:GetAttribute("FreePassOwner") == true

    button.Visible = allowed

    if not allowed then
        panel.Visible = false
    end
end

player:GetAttributeChangedSignal(
    "FreePassOwner"
):Connect(updateAccess)

updateAccess()
