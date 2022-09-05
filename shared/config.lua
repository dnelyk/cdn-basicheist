Config = {}

-- Setup ---
Config.HeistCooldown = (60000 * 60) -- Default: 1hr
Config.Debug = false -- Default: false, if true prints for events will be toggled!

-- Rewards --
Config.Reward = "rolex" -- Reward From Van!
Config.RewardAmount = math.random(24, 50) -- Amount of Reward from van!

-- Coords --
Config.LFBCoords = vector3(1362.83, 1144.2, 113.61)

-- Initial Ped Options --
Config.ManagerModel = `ig_andreas` -- Model of the Manager!
Config.ManagerCoords = vector3(1073.76, -2009.31, 31.08)
Config.ManagerIcon = 'fas fa-clipboard' -- Icon of the Target for Manager!
Config.ManangerLabel = 'Speak to Manager' -- Label of the Target for Manager!

-- Van Options --
Config.VanModel = `rumpo` -- Van Model that Spawns
Config.DropOffLocationVec3 = vector3(1140.59, -2026.27, 31.01) -- Dropoff Location (vector3)!
Config.VanLootIcon = 'fas fa-box'
Config.VanLootLabel = 'Grab the loot from the van!'

-- Enemies Config --
Config.PedHash = GetHashKey("g_m_y_mexgang_01") --- Leave GetHashKey please!
Config.Positions = { -- Postions where enemies Spawn!
    npcs = { -- 6 Locations!
        vector4(1385.61, 1142.59, 114.33, 90.86), -- Front Door!
        vector4(1386.52, 1169.18, 114.4, 105.74), -- Left Side Front by Grass!
        vector4(1416.84, 1117.68, 114.84, 104.85), -- Garage!
        vector4(1476.96, 1129.36, 114.33, 173.58), -- Far Back!
        vector4(1445.96, 1162.43, 114.33, 98.71), -- Front of Right Side Van! 
        vector4(1469.15, 1147.1, 114.3, 90.67), -- Back of Left Side Van!
    },
}

-- (AI Strength) ---
Config.AIWeaponName = "weapon_pistol" -- To change, just change "weapon_pistol" to "weapon_weaponname"!
Config.AIWeapon = GetHashKey(Config.AIWeaponName) -- Use the GetHashKey(Config.AIWeaponName) format!
Config.AIHealth = 250 -- Health of the Peds that are enemies!
Config.AIAccuracy = 50 -- Accuracy of the peds that are enemies!
Config.PedCombatAttributes = 46 -- Dont Touch unless you know what this does, should keep @ 46!
