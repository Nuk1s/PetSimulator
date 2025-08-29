--[[
    Pet Client - Client-side pet management
    Handles pet following, positioning, and UI interactions
]]--

local PetClient = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Get remote events
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local petRemotes = {
    GetPets = remoteEvents:WaitForChild("GetPets"),
    EquipPet = remoteEvents:WaitForChild("EquipPet"),
    UnequipPet = remoteEvents:WaitForChild("UnequipPet"),
    DeletePet = remoteEvents:WaitForChild("DeletePet"),
    UpdatePetPositions = remoteEvents:WaitForChild("UpdatePetPositions")
}

-- Pet management
local equippedPets = {}
local petModels = {}

-- Spawner module
local SpawnerModule = require(game.ServerScriptService.SpawnerModule)

-- Pet positioning configuration
local PET_POSITIONS = {
    -- First row (closer to player)
    {offset = Vector3.new(-3, 0, -3), priority = 1},
    {offset = Vector3.new(3, 0, -3), priority = 2},
    {offset = Vector3.new(-2, 0, -4), priority = 3},
    -- Second row (further from player) 
    {offset = Vector3.new(2, 0, -4), priority = 4},
    {offset = Vector3.new(-4, 0, -5), priority = 5},
    {offset = Vector3.new(4, 0, -5), priority = 6}
}

-- Update pet positions around player
local function updatePetPositions()
    if not character or not humanoidRootPart then
        return
    end
    
    local playerPosition = humanoidRootPart.Position
    local playerCFrame = humanoidRootPart.CFrame
    
    for i, petModel in ipairs(petModels) do
        if petModel and petModel.Parent and i <= #PET_POSITIONS then
            local positionData = PET_POSITIONS[i]
            local targetPosition = playerCFrame * CFrame.new(positionData.offset)
            
            -- Get or create BodyPosition
            local bodyPosition = petModel:FindFirstChild("BodyPosition")
            if bodyPosition then
                -- Smooth following with distance check
                local distance = (petModel.Position - playerPosition).Magnitude
                if distance > 50 then
                    -- Pet is too far, teleport it closer
                    petModel.Position = targetPosition.Position
                else
                    -- Smooth movement
                    bodyPosition.Position = targetPosition.Position
                    bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
                    bodyPosition.D = 2000 -- Damping for smooth movement
                end
                
                -- Prevent pets from pushing the player
                local direction = (petModel.Position - playerPosition).Unit
                local pushDistance = 3
                if distance < pushDistance then
                    bodyPosition.Position = playerPosition + direction * pushDistance
                end
            end
        end
    end
end

-- Create pet model from data
local function createPetModel(petData)
    local pet = Instance.new("Part")
    pet.Name = petData.name
    pet.Size = Vector3.new(2, 2, 2)
    pet.Material = Enum.Material.Neon
    pet.Shape = Enum.PartType.Ball
    pet.TopSurface = Enum.SurfaceType.Smooth
    pet.BottomSurface = Enum.SurfaceType.Smooth
    pet.Anchored = false
    pet.CanCollide = false
    
    -- Set color based on rarity
    local rarityColors = {
        Common = Color3.fromRGB(150, 150, 150),
        Rare = Color3.fromRGB(0, 150, 255),
        Epic = Color3.fromRGB(150, 0, 255),
        Legendary = Color3.fromRGB(255, 215, 0),
        Mythic = Color3.fromRGB(255, 100, 100)
    }
    pet.Color = rarityColors[petData.rarity] or rarityColors.Common
    
    -- Add BodyPosition for smooth movement
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyPosition.Position = humanoidRootPart.Position
    bodyPosition.D = 2000
    bodyPosition.P = 3000
    bodyPosition.Parent = pet
    
    -- Add BodyAngularVelocity for rotation control
    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, 2, 0) -- Slow rotation
    bodyAngularVelocity.Parent = pet
    
    -- Add floating effect
    spawn(function()
        while pet.Parent do
            local time = tick()
            bodyPosition.Position = bodyPosition.Position + Vector3.new(0, math.sin(time * 3) * 0.1, 0)
            wait(0.1)
        end
    end)
    
    pet.Parent = workspace
    return pet
end

-- Update equipped pets
petRemotes.UpdatePetPositions.OnClientEvent:Connect(function(equippedPetIds)
    -- Clear existing pet models
    for _, petModel in ipairs(petModels) do
        if petModel and petModel.Parent then
            petModel:Destroy()
        end
    end
    petModels = {}
    
    -- Get pet data and create models
    local allPets = petRemotes.GetPets:InvokeServer()
    for _, petId in ipairs(equippedPetIds) do
        for _, pet in ipairs(allPets) do
            if pet.id == petId then
                local petModel = createPetModel(pet)
                table.insert(petModels, petModel)
                break
            end
        end
    end
    
    equippedPets = equippedPetIds
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Re-request pet positions after respawn
    wait(1)
    local allPets = petRemotes.GetPets:InvokeServer()
    local equippedPetIds = {}
    for _, pet in ipairs(allPets) do
        if pet.equipped then
            table.insert(equippedPetIds, pet.id)
        end
    end
    
    if #equippedPetIds > 0 then
        petRemotes.UpdatePetPositions:FireServer(equippedPetIds)
    end
end)

-- Main update loop for pet positioning
RunService.Heartbeat:Connect(function()
    updatePetPositions()
end)

-- Initialize
spawn(function()
    wait(2)
    -- Request initial pets
    local allPets = petRemotes.GetPets:InvokeServer()
    local equippedPetIds = {}
    for _, pet in ipairs(allPets) do
        if pet.equipped then
            table.insert(equippedPetIds, pet.id)
        end
    end
    
    if #equippedPetIds > 0 then
        petRemotes.UpdatePetPositions:FireServer(equippedPetIds)
    end
end)

return PetClient