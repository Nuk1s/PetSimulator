--[[
    Pet Service - Server-side pet management
    Handles pet spawning, deletion, and persistence
]]--

local PetService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Create RemoteEvents if they don't exist
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
if not remoteEvents then
    remoteEvents = Instance.new("Folder")
    remoteEvents.Name = "RemoteEvents"
    remoteEvents.Parent = ReplicatedStorage
end

local petRemotes = {
    GetPets = remoteEvents:FindFirstChild("GetPets") or Instance.new("RemoteFunction"),
    EquipPet = remoteEvents:FindFirstChild("EquipPet") or Instance.new("RemoteEvent"),
    UnequipPet = remoteEvents:FindFirstChild("UnequipPet") or Instance.new("RemoteEvent"),
    DeletePet = remoteEvents:FindFirstChild("DeletePet") or Instance.new("RemoteEvent"),
    UpdatePetPositions = remoteEvents:FindFirstChild("UpdatePetPositions") or Instance.new("RemoteEvent")
}

-- Setup remote events
for name, remote in pairs(petRemotes) do
    remote.Name = name
    remote.Parent = remoteEvents
end

-- Pet data storage
local playerPets = {}
local equippedPets = {}

-- Pet configuration
local PET_CONFIG = {
    {id = 1, name = "Puppy", rarity = "Common", model = "PuppyModel", stats = {strength = 10, speed = 5}},
    {id = 2, name = "Kitten", rarity = "Common", model = "KittenModel", stats = {strength = 8, speed = 7}},
    {id = 3, name = "Dragon", rarity = "Legendary", model = "DragonModel", stats = {strength = 50, speed = 20}},
    {id = 4, name = "Phoenix", rarity = "Mythic", model = "PhoenixModel", stats = {strength = 80, speed = 35}},
    {id = 5, name = "Wolf", rarity = "Rare", model = "WolfModel", stats = {strength = 25, speed = 15}},
    {id = 6, name = "Tiger", rarity = "Epic", model = "TigerModel", stats = {strength = 40, speed = 25}}
}

-- Initialize player data
local function initializePlayer(player)
    if not playerPets[player.UserId] then
        playerPets[player.UserId] = {}
        equippedPets[player.UserId] = {}
        
        -- Give starter pets
        table.insert(playerPets[player.UserId], {
            id = 1,
            petId = 1,
            name = "Starter Puppy",
            rarity = "Common",
            stats = {strength = 10, speed = 5},
            equipped = false
        })
    end
end

-- Get pets for a player
petRemotes.GetPets.OnServerInvoke = function(player)
    initializePlayer(player)
    return playerPets[player.UserId] or {}
end

-- Equip a pet
petRemotes.EquipPet.OnServerEvent:Connect(function(player, petId)
    initializePlayer(player)
    local pets = playerPets[player.UserId]
    
    for i, pet in ipairs(pets) do
        if pet.id == petId then
            pet.equipped = true
            if not table.find(equippedPets[player.UserId], petId) then
                table.insert(equippedPets[player.UserId], petId)
            end
            
            -- Limit to 6 equipped pets
            if #equippedPets[player.UserId] > 6 then
                local oldestPetId = table.remove(equippedPets[player.UserId], 1)
                -- Find and unequip the oldest pet
                for j, oldPet in ipairs(pets) do
                    if oldPet.id == oldestPetId then
                        oldPet.equipped = false
                        break
                    end
                end
            end
            
            -- Update pet positions
            petRemotes.UpdatePetPositions:FireClient(player, equippedPets[player.UserId])
            break
        end
    end
end)

-- Unequip a pet
petRemotes.UnequipPet.OnServerEvent:Connect(function(player, petId)
    initializePlayer(player)
    local pets = playerPets[player.UserId]
    
    for i, pet in ipairs(pets) do
        if pet.id == petId then
            pet.equipped = false
            local index = table.find(equippedPets[player.UserId], petId)
            if index then
                table.remove(equippedPets[player.UserId], index)
            end
            
            -- Update pet positions
            petRemotes.UpdatePetPositions:FireClient(player, equippedPets[player.UserId])
            break
        end
    end
end)

-- Delete a pet
petRemotes.DeletePet.OnServerEvent:Connect(function(player, petId)
    initializePlayer(player)
    local pets = playerPets[player.UserId]
    
    for i = #pets, 1, -1 do
        if pets[i].id == petId then
            -- Unequip if equipped
            if pets[i].equipped then
                local index = table.find(equippedPets[player.UserId], petId)
                if index then
                    table.remove(equippedPets[player.UserId], index)
                end
            end
            
            -- Remove from pets list
            table.remove(pets, i)
            
            -- Update pet positions
            petRemotes.UpdatePetPositions:FireClient(player, equippedPets[player.UserId])
            break
        end
    end
end)

-- Initialize existing players
Players.PlayerAdded:Connect(initializePlayer)
for _, player in pairs(Players:GetPlayers()) do
    initializePlayer(player)
end

return PetService