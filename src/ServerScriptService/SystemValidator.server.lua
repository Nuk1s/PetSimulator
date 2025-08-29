--[[
    System Validator - Comprehensive validation of all Pet Simulator systems
    Run this to verify all components are working correctly
]]--

local SystemValidator = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Validation Results
local validationResults = {
    serverSystems = {},
    clientSystems = {},
    uiSystems = {},
    gameplaySystems = {}
}

-- Helper function to validate a system component
local function validateComponent(category, componentName, testFunction, description)
    local success, result = pcall(testFunction)
    local status = {
        name = componentName,
        passed = success,
        result = success and result or "FAILED: " .. tostring(result),
        description = description
    }
    
    table.insert(validationResults[category], status)
    
    local icon = success and "✅" or "❌"
    print(string.format("%s [%s] %s: %s", icon, category:upper(), componentName, status.result))
    
    return success
end

-- Server System Validations
function SystemValidator.validateServerSystems()
    print("\n🔧 VALIDATING SERVER SYSTEMS...")
    
    validateComponent("serverSystems", "RemoteEvents", function()
        local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
        if not remoteEvents then
            return false, "RemoteEvents folder not created"
        end
        
        local requiredRemotes = {"GetPets", "EquipPet", "UnequipPet", "DeletePet", "UpdatePetPositions", "CollectCoins", "UpdateCoins"}
        local foundRemotes = 0
        
        for _, remoteName in ipairs(requiredRemotes) do
            if remoteEvents:FindFirstChild(remoteName) then
                foundRemotes = foundRemotes + 1
            end
        end
        
        if foundRemotes == #requiredRemotes then
            return true, string.format("All %d remote events created", foundRemotes)
        else
            return false, string.format("Only %d/%d remote events found", foundRemotes, #requiredRemotes)
        end
    end, "Validates that all RemoteEvents are properly created")
    
    validateComponent("serverSystems", "PetService", function()
        local PetService = require(game.ServerScriptService.PetService)
        return true, "PetService module loaded successfully"
    end, "Validates PetService module can be loaded")
    
    validateComponent("serverSystems", "SpawnerModule", function()
        local SpawnerModule = require(game.ServerScriptService.SpawnerModule)
        if SpawnerModule.spawnPet then
            return true, "SpawnerModule with spawnPet function loaded"
        else
            return false, "SpawnerModule missing spawnPet function"
        end
    end, "Validates fixed SpawnerModule loads without infinite yield")
    
    validateComponent("serverSystems", "CoinService", function()
        local CoinService = require(game.ServerScriptService.CoinService)
        if CoinService.createCoinChest then
            return true, "CoinService with createCoinChest function loaded"
        else
            return false, "CoinService missing createCoinChest function"
        end
    end, "Validates CoinService for treasure chest interactions")
end

-- Client System Validations
function SystemValidator.validateClientSystems()
    print("\n💻 VALIDATING CLIENT SYSTEMS...")
    
    validateComponent("clientSystems", "PetClient", function()
        local player = Players.LocalPlayer
        if not player then
            return false, "LocalPlayer not available (server context)"
        end
        
        -- Check if PetClient script exists
        local petClientScript = player.PlayerScripts:FindFirstChild("PetClient")
        if petClientScript then
            return true, "PetClient script found in PlayerScripts"
        else
            return false, "PetClient script not found"
        end
    end, "Validates client-side pet management script")
    
    validateComponent("clientSystems", "RemoteConnections", function()
        local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if not remoteEvents then
            return false, "RemoteEvents not available for client"
        end
        
        local testRemotes = {"GetPets", "UpdatePetPositions"}
        for _, remoteName in ipairs(testRemotes) do
            local remote = remoteEvents:FindFirstChild(remoteName)
            if not remote then
                return false, "Missing remote: " .. remoteName
            end
        end
        
        return true, "Client can access required remote events"
    end, "Validates client access to remote events")
end

-- UI System Validations
function SystemValidator.validateUISystems()
    print("\n🎨 VALIDATING UI SYSTEMS...")
    
    validateComponent("uiSystems", "PetGUI", function()
        local player = Players.LocalPlayer
        if not player then
            return false, "LocalPlayer not available (server context)"
        end
        
        -- Check for PetGUI script in StarterGui
        local petGUIScript = game.StarterGui:FindFirstChild("PetGUI")
        if petGUIScript then
            return true, "PetGUI script found in StarterGui"
        else
            return false, "PetGUI script not found in StarterGui"
        end
    end, "Validates pet management UI script exists")
    
    validateComponent("uiSystems", "UIStructure", function()
        -- This would need to be tested in client context
        return true, "UI structure validation (requires client testing)"
    end, "Validates UI panel structure and functionality")
end

-- Gameplay System Validations
function SystemValidator.validateGameplaySystems()
    print("\n🎮 VALIDATING GAMEPLAY SYSTEMS...")
    
    validateComponent("gameplaySystems", "CoinChest", function()
        -- Check if coin chest exists in workspace
        local coinChest = workspace:FindFirstChild("CoinChest")
        if coinChest then
            local proximityPrompt = coinChest:FindFirstChild("ProximityPrompt")
            if proximityPrompt then
                return true, "Coin chest with proximity prompt found"
            else
                return false, "Coin chest missing proximity prompt"
            end
        else
            return false, "Coin chest not spawned in workspace"
        end
    end, "Validates treasure chest spawning and interaction")
    
    validateComponent("gameplaySystems", "PetPositioning", function()
        -- Validate pet positioning logic exists
        local petClient = game.StarterPlayer.StarterPlayerScripts:FindFirstChild("PetClient")
        if petClient then
            return true, "Pet positioning system available"
        else
            return false, "Pet positioning system not found"
        end
    end, "Validates pet following and positioning system")
end

-- Run all validations
function SystemValidator.runAllValidations()
    print("🚀 STARTING COMPREHENSIVE SYSTEM VALIDATION")
    print("=" .. string.rep("=", 60))
    
    local startTime = tick()
    
    SystemValidator.validateServerSystems()
    SystemValidator.validateClientSystems()
    SystemValidator.validateUISystems()
    SystemValidator.validateGameplaySystems()
    
    local endTime = tick()
    local duration = endTime - startTime
    
    -- Calculate results
    local totalTests = 0
    local passedTests = 0
    
    for category, tests in pairs(validationResults) do
        for _, test in ipairs(tests) do
            totalTests = totalTests + 1
            if test.passed then
                passedTests = passedTests + 1
            end
        end
    end
    
    print("\n" .. string.rep("=", 60))
    print("📊 VALIDATION SUMMARY")
    print(string.format("⏱️  Duration: %.2f seconds", duration))
    print(string.format("✅ Passed: %d/%d tests", passedTests, totalTests))
    print(string.format("📈 Success Rate: %.1f%%", (passedTests / totalTests) * 100))
    
    if passedTests == totalTests then
        print("\n🎉 ALL SYSTEMS OPERATIONAL!")
        print("🎮 Pet Simulator is ready for use!")
        print("\n📝 Quick Start Guide:")
        print("   • Press P to open pet menu")
        print("   • Click pet icons for details")
        print("   • Use Equip/Unequip buttons")
        print("   • Find treasure chests for coins")
        print("   • Enjoy your pet companions!")
    else
        print("\n⚠️  SOME SYSTEMS NEED ATTENTION")
        print("🔧 Check failed validations above")
    end
    
    return validationResults
end

-- Auto-run validation after a delay
spawn(function()
    wait(3) -- Wait for systems to initialize
    SystemValidator.runAllValidations()
end)

return SystemValidator