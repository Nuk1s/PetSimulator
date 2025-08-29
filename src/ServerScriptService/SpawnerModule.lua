--[[
    Spawner Module - Fixed to prevent infinite yield
    Handles spawning mechanics with proper error handling
]]--

local SpawnerModule = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Safe WaitForChild with timeout
local function safeWaitForChild(parent, childName, timeout)
    timeout = timeout or 10
    local child = parent:FindFirstChild(childName)
    if child then
        return child
    end
    
    local startTime = tick()
    while not child and (tick() - startTime) < timeout do
        child = parent:FindFirstChild(childName)
        if child then
            return child
        end
        wait(0.1)
    end
    
    warn("Failed to find child: " .. childName .. " in " .. parent.Name .. " within " .. timeout .. " seconds")
    return nil
end

-- Initialize remote events safely
local function initializeRemoteEvents()
    local remoteEvents = safeWaitForChild(ReplicatedStorage, "RemoteEvents", 5)
    if not remoteEvents then
        remoteEvents = Instance.new("Folder")
        remoteEvents.Name = "RemoteEvents"
        remoteEvents.Parent = ReplicatedStorage
    end
    return remoteEvents
end

-- Spawn system with error handling
function SpawnerModule.spawnPet(player, petData)
    if not player or not petData then
        warn("Invalid parameters for spawnPet")
        return nil
    end
    
    -- Create a basic pet model (placeholder)
    local pet = Instance.new("Part")
    pet.Name = petData.name or "Pet"
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
    
    -- Add BodyPosition for following
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyPosition.Position = Vector3.new(0, 0, 0)
    bodyPosition.Parent = pet
    
    -- Add BodyAngularVelocity for smooth rotation
    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
    bodyAngularVelocity.Parent = pet
    
    -- Store pet data
    local stringValue = Instance.new("StringValue")
    stringValue.Name = "PetData"
    stringValue.Value = game:GetService("HttpService"):JSONEncode(petData)
    stringValue.Parent = pet
    
    return pet
end

-- Initialize the module
SpawnerModule.remoteEvents = initializeRemoteEvents()

return SpawnerModule