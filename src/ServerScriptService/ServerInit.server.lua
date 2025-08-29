-- Main server initializer script
-- This script initializes all server services for the Pet Simulator

-- Require all services
local PetService = require(script.Parent.PetService)
local SpawnerModule = require(script.Parent.SpawnerModule)
local CoinService = require(script.Parent.CoinService)

print("Pet Simulator server initialized successfully!")
print("Press P to open pet menu")
print("Coin chest has been spawned in the game world")