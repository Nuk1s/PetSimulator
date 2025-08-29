--[[
    Pet GUI - User interface for pet management
    Includes left detail panel and right pet list with proper styling
]]--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get remote events
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local petRemotes = {
    GetPets = remoteEvents:WaitForChild("GetPets"),
    EquipPet = remoteEvents:WaitForChild("EquipPet"),
    UnequipPet = remoteEvents:WaitForChild("UnequipPet"),
    DeletePet = remoteEvents:WaitForChild("DeletePet")
}

-- UI State
local isLeftPanelOpen = false
local selectedPet = nil

-- Rarity colors for borders
local rarityColors = {
    Common = Color3.fromRGB(150, 150, 150),
    Rare = Color3.fromRGB(0, 150, 255),
    Epic = Color3.fromRGB(150, 0, 255),
    Legendary = Color3.fromRGB(255, 215, 0),
    Mythic = Color3.fromRGB(255, 100, 100)
}

-- Create main UI
local function createPetGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Right panel (pet list)
    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(0, 250, 0.6, 0)
    rightPanel.Position = UDim2.new(1, -260, 0.2, 0)
    rightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    rightPanel.BackgroundTransparency = 0.1
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = screenGui
    
    -- Right panel corner
    local rightCorner = Instance.new("UICorner")
    rightCorner.CornerRadius = UDim.new(0, 10)
    rightCorner.Parent = rightPanel
    
    -- Right panel title
    local rightTitle = Instance.new("TextLabel")
    rightTitle.Name = "Title"
    rightTitle.Size = UDim2.new(1, 0, 0, 40)
    rightTitle.Position = UDim2.new(0, 0, 0, 0)
    rightTitle.BackgroundTransparency = 1
    rightTitle.Text = "My Pets"
    rightTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightTitle.TextScaled = true
    rightTitle.Font = Enum.Font.GothamBold
    rightTitle.Parent = rightPanel
    
    -- Pet list scroll frame
    local petList = Instance.new("ScrollingFrame")
    petList.Name = "PetList"
    petList.Size = UDim2.new(1, -20, 1, -50)
    petList.Position = UDim2.new(0, 10, 0, 45)
    petList.BackgroundTransparency = 1
    petList.BorderSizePixel = 0
    petList.ScrollBarThickness = 8
    petList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    petList.Parent = rightPanel
    
    -- Pet list layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = petList
    
    -- Left panel (pet details)
    local leftPanel = Instance.new("Frame")
    leftPanel.Name = "LeftPanel"
    leftPanel.Size = UDim2.new(0, 300, 0.8, 0)
    leftPanel.Position = UDim2.new(0, -310, 0.1, 0)
    leftPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    leftPanel.BackgroundTransparency = 0.1
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = screenGui
    
    -- Left panel corner
    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 10)
    leftCorner.Parent = leftPanel
    
    return screenGui, rightPanel, leftPanel, petList
end

-- Create pet item in the list
local function createPetItem(pet, petList)
    local petItem = Instance.new("Frame")
    petItem.Name = "Pet_" .. pet.id
    petItem.Size = UDim2.new(1, -20, 0, 80)
    petItem.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    petItem.BorderSizePixel = 0
    petItem.Parent = petList
    
    -- Pet item corner
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 8)
    itemCorner.Parent = petItem
    
    -- Rarity border
    local rarityBorder = Instance.new("UIStroke")
    rarityBorder.Color = rarityColors[pet.rarity] or rarityColors.Common
    rarityBorder.Thickness = 3
    rarityBorder.Parent = petItem
    
    -- Pet icon
    local petIcon = Instance.new("Frame")
    petIcon.Name = "Icon"
    petIcon.Size = UDim2.new(0, 60, 0, 60)
    petIcon.Position = UDim2.new(0, 10, 0, 10)
    petIcon.BackgroundColor3 = rarityColors[pet.rarity] or rarityColors.Common
    petIcon.BorderSizePixel = 0
    petIcon.Parent = petItem
    
    -- Pet icon corner
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 6)
    iconCorner.Parent = petIcon
    
    -- Pet icon inner glow
    local iconGlow = Instance.new("Frame")
    iconGlow.Size = UDim2.new(0.8, 0, 0.8, 0)
    iconGlow.Position = UDim2.new(0.1, 0, 0.1, 0)
    iconGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    iconGlow.BackgroundTransparency = 0.7
    iconGlow.BorderSizePixel = 0
    iconGlow.Parent = petIcon
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 4)
    glowCorner.Parent = iconGlow
    
    -- Pet name
    local petName = Instance.new("TextLabel")
    petName.Name = "PetName"
    petName.Size = UDim2.new(0, 140, 0, 25)
    petName.Position = UDim2.new(0, 80, 0, 10)
    petName.BackgroundTransparency = 1
    petName.Text = pet.name
    petName.TextColor3 = Color3.fromRGB(255, 255, 255)
    petName.TextScaled = true
    petName.Font = Enum.Font.GothamBold
    petName.TextXAlignment = Enum.TextXAlignment.Left
    petName.Parent = petItem
    
    -- Pet rarity
    local petRarity = Instance.new("TextLabel")
    petRarity.Name = "PetRarity"
    petRarity.Size = UDim2.new(0, 140, 0, 20)
    petRarity.Position = UDim2.new(0, 80, 0, 35)
    petRarity.BackgroundTransparency = 1
    petRarity.Text = pet.rarity
    petRarity.TextColor3 = rarityColors[pet.rarity] or rarityColors.Common
    petRarity.TextScaled = true
    petRarity.Font = Enum.Font.Gotham
    petRarity.TextXAlignment = Enum.TextXAlignment.Left
    petRarity.Parent = petItem
    
    -- Equipped indicator
    local equippedIndicator = Instance.new("TextLabel")
    equippedIndicator.Name = "EquippedIndicator"
    equippedIndicator.Size = UDim2.new(0, 140, 0, 15)
    equippedIndicator.Position = UDim2.new(0, 80, 0, 55)
    equippedIndicator.BackgroundTransparency = 1
    equippedIndicator.Text = pet.equipped and "✓ Equipped" or ""
    equippedIndicator.TextColor3 = Color3.fromRGB(100, 255, 100)
    equippedIndicator.TextScaled = true
    equippedIndicator.Font = Enum.Font.Gotham
    equippedIndicator.TextXAlignment = Enum.TextXAlignment.Left
    equippedIndicator.Parent = petItem
    
    -- Click detection
    local clickButton = Instance.new("TextButton")
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.Parent = petItem
    
    -- Handle click to show details
    clickButton.MouseButton1Click:Connect(function()
        showPetDetails(pet)
    end)
    
    return petItem
end

-- Show pet details in left panel
function showPetDetails(pet)
    selectedPet = pet
    local leftPanel = playerGui.PetGUI.LeftPanel
    
    -- Clear existing content
    for _, child in ipairs(leftPanel:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "UICorner" then
            child:Destroy()
        end
    end
    
    -- Pet image (large)
    local petImage = Instance.new("Frame")
    petImage.Name = "PetImage"
    petImage.Size = UDim2.new(0, 120, 0, 120)
    petImage.Position = UDim2.new(0.5, -60, 0, 20)
    petImage.BackgroundColor3 = rarityColors[pet.rarity] or rarityColors.Common
    petImage.BorderSizePixel = 0
    petImage.Parent = leftPanel
    
    local imageCorner = Instance.new("UICorner")
    imageCorner.CornerRadius = UDim.new(0, 10)
    imageCorner.Parent = petImage
    
    -- Pet name (large)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -20, 0, 40)
    nameLabel.Position = UDim2.new(0, 10, 0, 150)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = pet.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = leftPanel
    
    -- Pet rarity
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Name = "RarityLabel"
    rarityLabel.Size = UDim2.new(1, -20, 0, 30)
    rarityLabel.Position = UDim2.new(0, 10, 0, 190)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.Text = pet.rarity
    rarityLabel.TextColor3 = rarityColors[pet.rarity] or rarityColors.Common
    rarityLabel.TextScaled = true
    rarityLabel.Font = Enum.Font.Gotham
    rarityLabel.Parent = leftPanel
    
    -- Stats section
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -20, 0, 25)
    statsLabel.Position = UDim2.new(0, 10, 0, 230)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "Stats:"
    statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statsLabel.TextScaled = true
    statsLabel.Font = Enum.Font.GothamBold
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = leftPanel
    
    -- Strength stat
    local strengthLabel = Instance.new("TextLabel")
    strengthLabel.Name = "StrengthLabel"
    strengthLabel.Size = UDim2.new(1, -20, 0, 20)
    strengthLabel.Position = UDim2.new(0, 10, 0, 260)
    strengthLabel.BackgroundTransparency = 1
    strengthLabel.Text = "Strength: " .. (pet.stats.strength or 0)
    strengthLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    strengthLabel.TextScaled = true
    strengthLabel.Font = Enum.Font.Gotham
    strengthLabel.TextXAlignment = Enum.TextXAlignment.Left
    strengthLabel.Parent = leftPanel
    
    -- Speed stat
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(1, -20, 0, 20)
    speedLabel.Position = UDim2.new(0, 10, 0, 285)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. (pet.stats.speed or 0)
    speedLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    speedLabel.TextScaled = true
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = leftPanel
    
    -- Equip/Unequip button
    local equipButton = Instance.new("TextButton")
    equipButton.Name = "EquipButton"
    equipButton.Size = UDim2.new(0.8, 0, 0, 50)
    equipButton.Position = UDim2.new(0.1, 0, 0, 320)
    equipButton.BackgroundColor3 = pet.equipped and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
    equipButton.BorderSizePixel = 0
    equipButton.Text = pet.equipped and "Unequip" or "Equip"
    equipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    equipButton.TextScaled = true
    equipButton.Font = Enum.Font.GothamBold
    equipButton.Parent = leftPanel
    
    local equipCorner = Instance.new("UICorner")
    equipCorner.CornerRadius = UDim.new(0, 8)
    equipCorner.Parent = equipButton
    
    -- Delete button
    local deleteButton = Instance.new("TextButton")
    deleteButton.Name = "DeleteButton"
    deleteButton.Size = UDim2.new(0.8, 0, 0, 40)
    deleteButton.Position = UDim2.new(0.1, 0, 0, 380)
    deleteButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    deleteButton.BorderSizePixel = 0
    deleteButton.Text = "Delete Pet"
    deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    deleteButton.TextScaled = true
    deleteButton.Font = Enum.Font.Gotham
    deleteButton.Parent = leftPanel
    
    local deleteCorner = Instance.new("UICorner")
    deleteCorner.CornerRadius = UDim.new(0, 8)
    deleteCorner.Parent = deleteButton
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = leftPanel
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Button handlers
    equipButton.MouseButton1Click:Connect(function()
        if pet.equipped then
            petRemotes.UnequipPet:FireServer(pet.id)
        else
            petRemotes.EquipPet:FireServer(pet.id)
        end
        hideLeftPanel()
        refreshPetList()
    end)
    
    deleteButton.MouseButton1Click:Connect(function()
        petRemotes.DeletePet:FireServer(pet.id)
        hideLeftPanel()
        refreshPetList()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        hideLeftPanel()
    end)
    
    -- Show the panel with animation
    showLeftPanel()
end

-- Show left panel with slide animation
function showLeftPanel()
    local leftPanel = playerGui.PetGUI.LeftPanel
    isLeftPanelOpen = true
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(leftPanel, tweenInfo, {
        Position = UDim2.new(0, 10, 0.1, 0)
    })
    tween:Play()
end

-- Hide left panel with slide animation
function hideLeftPanel()
    local leftPanel = playerGui.PetGUI.LeftPanel
    isLeftPanelOpen = false
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(leftPanel, tweenInfo, {
        Position = UDim2.new(0, -310, 0.1, 0)
    })
    tween:Play()
end

-- Refresh pet list
function refreshPetList()
    local petList = playerGui.PetGUI.RightPanel.PetList
    
    -- Clear existing items
    for _, child in ipairs(petList:GetChildren()) do
        if child:IsA("Frame") and string.find(child.Name, "Pet_") then
            child:Destroy()
        end
    end
    
    -- Get updated pets
    spawn(function()
        local pets = petRemotes.GetPets:InvokeServer()
        
        -- Create pet items
        for _, pet in ipairs(pets) do
            createPetItem(pet, petList)
        end
        
        -- Update canvas size
        petList.CanvasSize = UDim2.new(0, 0, 0, #pets * 90 + 10)
    end)
end

-- Initialize GUI
local function initializePetGUI()
    local screenGui, rightPanel, leftPanel, petList = createPetGUI()
    
    -- Initial pet list load
    refreshPetList()
    
    -- Toggle pet menu with P key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.P then
            local rightPanel = playerGui.PetGUI.RightPanel
            local isVisible = rightPanel.Position.X.Offset > -260
            
            local targetPos = isVisible and UDim2.new(1, 10, 0.2, 0) or UDim2.new(1, -260, 0.2, 0)
            
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(rightPanel, tweenInfo, {Position = targetPos})
            tween:Play()
            
            if isVisible and isLeftPanelOpen then
                hideLeftPanel()
            end
        end
    end)
end

-- Wait for player to load and initialize
spawn(function()
    wait(2)
    initializePetGUI()
end)