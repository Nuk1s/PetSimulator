# Pet Simulator

A Roblox Pet Simulator game with comprehensive pet collection, management, and interaction systems.

## Features

### Pet Management System
- **Pet Collection**: Collect various pets with different rarities (Common, Rare, Epic, Legendary, Mythic)
- **Pet Equipment**: Equip up to 6 pets simultaneously
- **Pet Following**: Pets intelligently follow the player with proper positioning
- **Pet UI**: Comprehensive interface with right panel (pet list) and left panel (pet details)

### Pet Positioning System
- **Smart Formation**: Pets arrange themselves in two rows around the player
  - First row: 3 pets closer to the player
  - Second row: 3 pets further from the player
- **Anti-Push System**: Pets cannot push or interfere with player movement
- **Distance Management**: Pets teleport back if they get too far from the player

### User Interface
- **Right Panel**: Displays all collected pets with:
  - Rarity border colors
  - Pet names and rarity labels
  - Equipment status indicators
- **Left Panel**: Detailed pet view with:
  - Large pet image
  - Pet statistics (Strength, Speed)
  - Equip/Unequip toggle button
  - Delete pet functionality
  - Smooth slide animations

### Coin Collection System
- **Treasure Chests**: Interactive chests scattered around the world
- **Fixed Interaction**: Proper collision detection on the entire chest object
- **Visual Effects**: Floating coins and collection animations
- **Reward System**: Random coin amounts per collection

### Technical Improvements
- **Fixed SpawnerModule**: Eliminated infinite yield errors with proper timeout handling
- **Stable Pet Deletion**: Fully functional pet removal system
- **Smooth Animations**: Tween-based UI transitions
- **Performance Optimized**: Efficient pet following and positioning algorithms

## Controls
- **P Key**: Toggle pet menu visibility
- **Click Pet Icon**: Open detailed view in left panel
- **Equip/Unequip Button**: Toggle pet equipment status
- **Delete Button**: Remove pet from collection
- **Proximity Prompts**: Interact with treasure chests

## File Structure
```
src/
├── ServerScriptService/
│   ├── ServerInit.server.lua    # Main server initializer
│   ├── PetService.lua           # Pet management backend
│   ├── SpawnerModule.lua        # Pet spawning system (fixed)
│   └── CoinService.lua          # Coin chest interaction system
├── StarterPlayerScripts/
│   └── PetClient.lua            # Client-side pet behavior
└── StarterGui/
    └── PetGUI.lua               # Pet management interface
```

## Installation
1. Copy the `src` folder structure into your Roblox Studio project
2. Ensure all scripts are placed in their respective service folders
3. The system will automatically initialize when the game starts

## Usage
1. Press **P** to open the pet menu
2. Click on any pet icon to view details
3. Use **Equip**/**Unequip** buttons to manage active pets
4. Explore the world to find treasure chests for coins
5. Up to 6 pets will follow you in formation

## Bug Fixes Implemented
1. ✅ Fixed infinite yield error in SpawnerModule
2. ✅ Implemented proper pet deletion functionality
3. ✅ Added rarity borders and pet names to UI
4. ✅ Created sliding left panel for pet details
5. ✅ Fixed pet positioning to prevent player pushing
6. ✅ Improved treasure chest interaction area
7. ✅ Added equip/unequip toggle functionality
8. ✅ Implemented 6-pet formation system with 2 rows