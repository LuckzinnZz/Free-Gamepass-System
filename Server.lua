
-- FREE GAMEPASS SYSTEM V5
-- SERVER / SERVERSCRIPTSERVICE
-- Desbloqueios virtuais para o dono permanente

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Mantem o registro de dono da V3
local ownerStore = DataStoreService:GetDataStore(
    "FreeGamepassPermanentOwnerV1"
)

-- Mantem os desbloqueios anteriores
local passStore = DataStoreService:GetDataStore(
    "FreeGamepassUnlocksV3"
)

local OWNER_KEY = "PermanentOwner"
local ownerId = nil

local remote = ReplicatedStorage:FindFirstChild(
    "FreeGamepassRequest"
)

if not remote then
    remote = Instance.new("RemoteFunction")
    remote.Name = "FreeGamepassRequest"
    remote.Parent = ReplicatedStorage
end

local function validId(id)
    return typeof(id) == "number"
        and id > 0
        and id % 1 == 0
        and id < 9007199254740992
end

local function verifyOwner(candidateId)
    if ownerId ~= nil then
        return ownerId == candidateId
    end

    local success, result = pcall(function()
        return ownerStore:UpdateAsync(
            OWNER_KEY,
            function(current)
                if current == nil then
                    return candidateId
                end

                return current
            end
        )
    end)

    if not success or not validId(result) then
        warn("FreeGamepass: erro ao verificar dono")
        return false
    end

    ownerId = result
    return ownerId == candidateId
end

local function grant(player, passId)
    player:SetAttribute(
        "FreePass_" .. tostring(passId),
        true
    )
end

local function setupPlayer(player)
    if not verifyOwner(player.UserId) then
        player:SetAttribute("FreePassOwner", false)
        return
    end

    player:SetAttribute("FreePassOwner", true)

    local success, saved = pcall(function()
        return passStore:GetAsync(
            "Passes_" .. tostring(player.UserId)
        )
    end)

    if success and typeof(saved) == "table" then
        for _, id in ipairs(saved) do
            if validId(id) then
                grant(player, id)
            end
        end
    end
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(setupPlayer, player)
end

remote.OnServerInvoke = function(player, action, passId)
    if not verifyOwner(player.UserId) then
        return false, "Acesso negado."
    end

    if action ~= "grant" or not validId(passId) then
        return false, "Pedido invalido."
    end

    -- Confirma que o ID pertence a uma Gamepass
    local infoOk, info = pcall(function()
        return MarketplaceService:GetProductInfo(
            passId,
            Enum.InfoType.GamePass
        )
    end)

    if not infoOk or not info then
        return false, "Gamepass nao encontrada."
    end

    -- Salva primeiro, concede depois
    local saved = pcall(function()
        passStore:UpdateAsync(
            "Passes_" .. tostring(player.UserId),
            function(old)
                local list =
                    typeof(old) == "table" and old or {}

                for _, id in ipairs(list) do
                    if id == passId then
                        return list
                    end
                end

                table.insert(list, passId)
                return list
            end
        )
    end)

    if not saved then
        return false, "Erro ao salvar. Tente novamente."
    end

    grant(player, passId)

    return true, "Beneficio virtual registrado: " .. info.Name
end
