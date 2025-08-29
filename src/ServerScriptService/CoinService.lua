--[[
    Coin Service - Handles coin chest interactions
    Fixed interaction area to work with the entire chest object
]]--

local CoinService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

-- Create RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
if not remoteEvents then
    remoteEvents = Instance.new("Folder")
    remoteEvents.Name = "RemoteEvents"
    remoteEvents.Parent = ReplicatedStorage
end

local coinRemotes = {
    CollectCoins = remoteEvents:FindFirstChild("CollectCoins") or Instance.new("RemoteEvent"),
    UpdateCoins = remoteEvents:FindFirstChild("UpdateCoins") or Instance.new("RemoteEvent")
}

-- Setup remote events
for name, remote in pairs(coinRemotes) do
    remote.Name = name
    remote.Parent = remoteEvents
end

-- Player coin storage
local playerCoins = {}

-- Initialize player coins
local function initializePlayerCoins(player)
    if not playerCoins[player.UserId] then
        playerCoins[player.UserId] = 100 -- Starting coins
    end
end

-- Create coin chest with proper interaction
function CoinService.createCoinChest(position)
    -- Create chest model
    local chest = Instance.new("Part")
    chest.Name = "CoinChest"
    chest.Size = Vector3.new(4, 3, 3)
    chest.Position = position or Vector3.new(0, 5, 0)
    chest.Material = Enum.Material.Wood
    chest.BrickColor = BrickColor.new("Brown")
    chest.Anchored = true
    
    -- Add mesh for better appearance
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1726519073" -- Treasure chest mesh
    mesh.Scale = Vector3.new(2, 2, 2)
    mesh.Parent = chest
    
    -- Create proximity prompt for interaction (attached to the main chest, not individual coins)
    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.ActionText = "Collect Coins"
    proximityPrompt.ObjectText = "Treasure Chest"
    proximityPrompt.HoldDuration = 1
    proximityPrompt.MaxActivationDistance = 10
    proximityPrompt.RequiresLineOfSight = false
    proximityPrompt.Parent = chest
    
    -- Add floating coins effect around the chest
    for i = 1, 8 do
        local coin = Instance.new("Part")
        coin.Name = "FloatingCoin"
        coin.Size = Vector3.new(0.5, 0.1, 0.5)
        coin.Material = Enum.Material.Neon
        coin.BrickColor = BrickColor.new("Bright yellow")
        coin.Shape = Enum.PartType.Cylinder
        coin.Anchored = true
        coin.CanCollide = false
        
        -- Position coins around the chest
        local angle = (i - 1) * (math.pi * 2 / 8)
        local radius = 3
        coin.Position = position + Vector3.new(
            math.cos(angle) * radius,
            math.sin(tick() * 2 + i) * 0.5 + 2,
            math.sin(angle) * radius
        )
        
        coin.Parent = chest
        
        -- Animate floating coins
        spawn(function()
            while coin.Parent do
                local time = tick()
                coin.Position = position + Vector3.new(
                    math.cos(angle) * radius,
                    math.sin(time * 2 + i) * 0.5 + 2,
                    math.sin(angle) * radius
                )
                coin.Rotation = Vector3.new(0, time * 100 + i * 45, 0)
                wait(0.1)
            end
        end)
    end
    
    -- Handle chest interaction
    proximityPrompt.Triggered:Connect(function(player)
        initializePlayerCoins(player)
        local coinsEarned = math.random(10, 50)
        playerCoins[player.UserId] = playerCoins[player.UserId] + coinsEarned
        
        -- Notify player
        coinRemotes.UpdateCoins:FireClient(player, playerCoins[player.UserId])
        
        -- Create coin collection effect
        for i = 1, 5 do
            local effectCoin = Instance.new("Part")
            effectCoin.Size = Vector3.new(0.3, 0.05, 0.3)
            effectCoin.Material = Enum.Material.Neon
            effectCoin.BrickColor = BrickColor.new("Bright yellow")
            effectCoin.Shape = Enum.PartType.Cylinder
            effectCoin.Anchored = true
            effectCoin.CanCollide = false
            effectCoin.Position = chest.Position + Vector3.new(
                math.random(-2, 2),
                math.random(1, 3),
                math.random(-2, 2)
            )
            effectCoin.Parent = workspace
            
            -- Animate coin flying to player
            spawn(function()
                local startPos = effectCoin.Position
                local endPos = player.Character.HumanoidRootPart.Position
                
                for t = 0, 1, 0.05 do
                    if effectCoin.Parent then
                        effectCoin.Position = startPos:lerp(endPos, t)
                        wait(0.05)
                    end
                end
                
                if effectCoin.Parent then
                    effectCoin:Destroy()
                end
            end)
        end
        
        print(player.Name .. " collected " .. coinsEarned .. " coins! Total: " .. playerCoins[player.UserId])
    end)
    
    chest.Parent = workspace
    return chest
end

-- Get player coins
coinRemotes.CollectCoins.OnServerEvent:Connect(function(player)
    initializePlayerCoins(player)
    coinRemotes.UpdateCoins:FireClient(player, playerCoins[player.UserId])
end)

-- Initialize players
Players.PlayerAdded:Connect(initializePlayerCoins)
for _, player in pairs(Players:GetPlayers()) do
    initializePlayerCoins(player)
end

-- Create a default coin chest in the game
spawn(function()
    wait(2) -- Wait a bit for the game to initialize
    CoinService.createCoinChest(Vector3.new(0, 5, 20))
end)

return CoinService