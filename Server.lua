
-- FREE GAMEPASS SYSTEM V3
-- Primeiro jogador = dono permanente

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local OwnerStore = DataStoreService:GetDataStore(
    "FreeGamepassPermanentOwnerV1"
)

local PassStore = DataStoreService:GetDataStore(
    "FreeGamepassUnlocksV3"
)

local Remote = Instance.new("RemoteFunction")
Remote.Name = "FreeGamepassRequest"
Remote.Parent = ReplicatedStorage

local OWNER_KEY = "PermanentOwner"
local ownerId = nil

local function getOwner(candidateId)
    local success, result = pcall(function()
        return OwnerStore:UpdateAsync(
            OWNER_KEY,
            function(current)
                if current == nil then
                    return candidateId
                end

                return current
            end
        )
    end)

    if success then
        ownerId = result
    else
        warn("Could not verify permanent owner")
    end

    return success and result == candidateId
end

local function grant(player, passId)
    player:SetAttribute(
        "FreePass_" .. tostring(passId),
        true
    )
end

Players.PlayerAdded:Connect(function(player)
    if not getOwner(player.UserId) then
        return
    end

    player:SetAttribute("FreePassOwner", true)

    local success, saved = pcall(function()
        return PassStore:GetAsync(
            "Passes_" .. tostring(player.UserId)
        )
    end)

    if success and typeof(saved) == "table" then
        for _, passId in ipairs(saved) do
            if typeof(passId) == "number" then
                grant(player, passId)
            end
        end
    end
end)

Remote.OnServerInvoke = function(player, action, passId)
    if not getOwner(player.UserId) then
        return false, "Only the first player can use this"
    end

    if action ~= "grant" then
        return false, "Invalid action"
    end

    if typeof(passId) ~= "number"
        or passId <= 0
        or passId % 1 ~= 0
        or passId >= 9007199254740992 then
        return false, "Invalid Gamepass ID"
    end

    grant(player, passId)

    local success = pcall(function()
        PassStore:UpdateAsync(
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

    if success then
        return true, "Free Gamepass activated!"
    end

    return true, "Activated, but not saved"
end
