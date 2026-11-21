
-- FREE GAMEPASS SYSTEM V4
-- CLIENT CORRIGIDO
-- Interface com diagnostico de servidor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Evita duplicar a interface
local old = playerGui:FindFirstChild("FreeGamepassSystem")

if old then
    old:Destroy()
end

local function create(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local gui = create("ScreenGui", {
    Name = "FreeGamepassSystem",
    ResetOnSpawn = false,
    DisplayOrder = 50
}, playerGui)

local openButton = create("TextButton", {
    Size = UDim2.fromOffset(145, 45),
    Position = UDim2.new(0, 15, 0.5, 0),
    BackgroundColor3 = Color3.fromRGB(35, 100, 255),
    Text = "FREE PASSES",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 16,
    Font = Enum.Font.GothamBold
}, gui)

create("UICorner", {
    CornerRadius = UDim.new(0, 10)
}, openButton)

local panel = create("Frame", {
    Size = UDim2.fromOffset(310, 255),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(28, 31, 40),
    Visible = false
}, gui)

create("UICorner", {
    CornerRadius = UDim.new(0, 14)
}, panel)

create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundTransparency = 1,
    Text = "FREE GAMEPASS V4",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 20,
    Font = Enum.Font.GothamBold
}, panel)

local input = create("TextBox", {
    Size = UDim2.new(1, -30, 0, 44),
    Position = UDim2.fromOffset(15, 60),
    BackgroundColor3 = Color3.fromRGB(49, 53, 65),
    PlaceholderText = "Digite o Gamepass ID",
    Text = "",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 16,
    ClearTextOnFocus = false
}, panel)

create("UICorner", {
    CornerRadius = UDim.new(0, 8)
}, input)

local freeButton = create("TextButton", {
    Size = UDim2.new(1, -30, 0, 48),
    Position = UDim2.fromOffset(15, 118),
    BackgroundColor3 = Color3.fromRGB(40, 105, 255),
    Text = "Free",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 22,
    Font = Enum.Font.GothamBold
}, panel)

create("UICorner", {
    CornerRadius = UDim.new(0, 9)
}, freeButton)

local status = create("TextLabel", {
    Size = UDim2.new(1, -26, 0, 70),
    Position = UDim2.fromOffset(13, 174),
    BackgroundTransparency = 1,
    Text = "Verificando servidor...",
    TextColor3 = Color3.fromRGB(220, 225, 235),
    TextSize = 13,
    TextWrapped = true
}, panel)

local remote = nil

local function updateStatus()
    if not remote then
        status.Text = "Servidor nao configurado. Instale Server.lua no seu jogo."
    elseif player:GetAttribute("FreePassOwner") ~= true then
        status.Text = "Acesso restrito ao primeiro jogador registrado."
    else
        status.Text = "Dono confirmado! Digite o Gamepass ID."
    end
end

openButton.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

player:GetAttributeChangedSignal(
    "FreePassOwner"
):Connect(updateStatus)

task.spawn(function()
    local found = ReplicatedStorage:WaitForChild(
        "FreeGamepassRequest", 10
    )

    if found and found:IsA("RemoteFunction") then
        remote = found
    end

    updateStatus()
end)

freeButton.MouseButton1Click:Connect(function()
    if not remote then
        updateStatus()
        return
    end

    if player:GetAttribute("FreePassOwner") ~= true then
        updateStatus()
        return
    end

    local id = tonumber(input.Text)

    if not id or id <= 0 or id % 1 ~= 0 then
        status.Text = "Gamepass ID invalido."
        return
    end

    freeButton.Active = false
    status.Text = "Ativando..."

    local ok, success, message = pcall(function()
        return remote:InvokeServer("grant", id)
    end)

    if ok then
        status.Text = tostring(message)
        if success then
            freeButton.Text = "Activated!"
        end
    else
        status.Text = "Erro de conexao com o servidor."
    end

    freeButton.Active = true
end)

input:GetPropertyChangedSignal("Text"):Connect(function()
    freeButton.Text = "Free"
end)

updateStatus()
