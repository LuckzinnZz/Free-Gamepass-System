
-- FREE GAMEPASS SYSTEM V5
-- CLIENT / LOCALSCRIPT
-- Painel arrastavel + deteccao de Gamepass

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("FreeGamepassSystem")
if old then
    old:Destroy()
end

local function make(className, props, parent)
    local obj = Instance.new(className)

    for key, value in pairs(props) do
        obj[key] = value
    end

    obj.Parent = parent
    return obj
end

local gui = make("ScreenGui", {
    Name = "FreeGamepassSystem",
    ResetOnSpawn = false,
    DisplayOrder = 100,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

local open = make("TextButton", {
    Size = UDim2.fromOffset(140, 44),
    Position = UDim2.new(0, 12, 0.45, 0),
    BackgroundColor3 = Color3.fromRGB(35, 100, 255),
    Text = "FREE PASSES",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 15,
    Font = Enum.Font.GothamBold
}, gui)

make("UICorner", {
    CornerRadius = UDim.new(0, 10)
}, open)

local panel = make("Frame", {
    Size = UDim2.fromOffset(310, 275),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(27, 30, 40),
    Visible = false,
    Active = true
}, gui)

make("UICorner", {
    CornerRadius = UDim.new(0, 14)
}, panel)

local header = make("TextButton", {
    Size = UDim2.new(1, -45, 0, 45),
    BackgroundTransparency = 1,
    Text = "FREE GAMEPASS V5  ≡",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, panel)

local close = make("TextButton", {
    Size = UDim2.fromOffset(38, 38),
    Position = UDim2.new(1, -42, 0, 4),
    BackgroundColor3 = Color3.fromRGB(180, 50, 60),
    Text = "X",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 18
}, panel)

make("UICorner", {
    CornerRadius = UDim.new(0, 8)
}, close)

local passName = make("TextLabel", {
    Size = UDim2.new(1, -24, 0, 40),
    Position = UDim2.fromOffset(12, 48),
    BackgroundTransparency = 1,
    Text = "Nenhuma Gamepass detectada",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 15,
    TextWrapped = true,
    Font = Enum.Font.GothamBold
}, panel)

local input = make("TextBox", {
    Size = UDim2.new(1, -28, 0, 42),
    Position = UDim2.fromOffset(14, 93),
    BackgroundColor3 = Color3.fromRGB(49, 53, 65),
    PlaceholderText = "ID da Gamepass",
    Text = "",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 17,
    ClearTextOnFocus = false
}, panel)

make("UICorner", {
    CornerRadius = UDim.new(0, 8)
}, input)

local free = make("TextButton", {
    Size = UDim2.new(1, -28, 0, 48),
    Position = UDim2.fromOffset(14, 145),
    BackgroundColor3 = Color3.fromRGB(35, 100, 255),
    Text = "Free",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 22,
    Font = Enum.Font.GothamBold
}, panel)

make("UICorner", {
    CornerRadius = UDim.new(0, 9)
}, free)

local status = make("TextLabel", {
    Size = UDim2.new(1, -26, 0, 67),
    Position = UDim2.fromOffset(13, 202),
    BackgroundTransparency = 1,
    Text = "Verificando servidor...",
    TextColor3 = Color3.fromRGB(215, 220, 230),
    TextSize = 13,
    TextWrapped = true
}, panel)

-- Arrastar pelo cabecalho: mouse ou toque
local dragging = false
local dragStart
local startPosition
local dragInput

header.InputBegan:Connect(function(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.MouseButton1
        or inputObject.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = inputObject.Position
        startPosition = panel.Position

        inputObject.Changed:Connect(function()
            if inputObject.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.MouseMovement
        or inputObject.UserInputType == Enum.UserInputType.Touch then
        dragInput = inputObject
    end
end)

UserInputService.InputChanged:Connect(function(inputObject)
    if dragging and inputObject == dragInput then
        local delta = inputObject.Position - dragStart

        panel.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

open.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

close.MouseButton1Click:Connect(function()
    panel.Visible = false
end)

-- Comunicacao com o servidor
local remote = nil

local function updateStatus()
    if not remote then
        status.Text = "Servidor ausente. Instale Server.lua no seu jogo."
    elseif player:GetAttribute("FreePassOwner") ~= true then
        status.Text = "Acesso Free reservado ao primeiro jogador registrado."
    else
        status.Text = "Dono confirmado. Selecione uma Gamepass."
    end
end

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

-- Identificacao automatica do ID
local selectedId = nil

local function selectPass(id)
    if typeof(id) ~= "number" or id <= 0 then
        return
    end

    selectedId = id
    input.Text = tostring(id)
    passName.Text = "Gamepass ID: " .. tostring(id)
    free.Text = "Free"

    task.spawn(function()
        local success, info = pcall(function()
            return MarketplaceService:GetProductInfo(
                id,
                Enum.InfoType.GamePass
            )
        end)

        if selectedId ~= id then
            return
        end

        if success and info and info.Name then
            passName.Text = info.Name
        end
    end)
end

-- Detecta solicitacoes de compra de Gamepass
MarketplaceService.PromptGamePassPurchaseRequested:Connect(
    function(promptPlayer, gamePassId)
        if promptPlayer ~= player then
            return
        end

        selectPass(gamePassId)
        panel.Visible = true
    end
)

-- Permite preencher manualmente tambem
input.FocusLost:Connect(function()
    local id = tonumber(input.Text)

    if id and id > 0 and id % 1 == 0 then
        selectPass(id)
    end
end)

free.MouseButton1Click:Connect(function()
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
        status.Text = "ID invalido."
        return
    end

    free.Active = false
    free.Text = "Aguarde..."
    status.Text = "Solicitando desbloqueio virtual..."

    local ok, success, message = pcall(function()
        return remote:InvokeServer("grant", id)
    end)

    if ok then
        status.Text = tostring(message)

        if success then
            free.Text = "Activated!"
        else
            free.Text = "Free"
        end
    else
        status.Text = "Erro de comunicacao."
        free.Text = "Free"
    end

    free.Active = true
end)

input:GetPropertyChangedSignal("Text"):Connect(function()
    if free.Text == "Activated!" then
        free.Text = "Free"
    end
end)

updateStatus()
