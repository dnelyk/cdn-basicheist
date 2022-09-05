-- Variables --

local QBCore = exports['qb-core']:GetCoreObject()
local getjob = false
local invan = false
local closetodrop = false
local targetcreated = false
local scoutvan = false
local lfbblipcreated = false
local dropoffblipcreated = false

-- Threads --

CreateThread(function()
    local model = Config.ManagerModel
    RequestModel(model)
    while not HasModelLoaded(model) do
      Wait(0)
    end
    local manager = CreatePed(0, model, Config.ManagerCoords, 55.64, true, false) -- vector4(1073.76, -2009.31, 32.08, 55.64)
    FreezeEntityPosition(manager, true)
    exports['qb-target']:AddTargetEntity(manager, { -- The specified entity number
      options = { -- This is your options table, in this table all the options will be specified for the target to accept
        { -- This is the first table with options, you can make as many options inside the options table as you want
          type = "client", -- This specifies the type of event the target has to trigger on click, this can be "client", "server", "command" or "qbcommand", this is OPTIONAL and will only work if the event is also specified
          event = "cdn:goldheist:getjob", -- This is the event it will trigger on click, this can be a client event, server event, command or qbcore registered command, NOTICE: Normal command can't have arguments passed through, QBCore registered ones can have arguments passed through
          icon = Config.ManagerIcon, -- This is the icon that will display next to this trigger option
          label = Config.ManangerLabel, -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
        }
      },
      distance = 2.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
    })
end)

-- Functions --

-- function CreateBlipGoldHeist(blipName, reason) --- Keeping for later :)
--     local lfbblip
--     local dropoffblip

--     if reason == "create" then
--         if blipName == "lfb" and not lfbblipcreated then
--             lfbblip = AddBlipForCoord(Config.LFBCoords)
--             BeginTextCommandSetBlipName("STRING")
--             AddTextComponentString('La Fuente Blanca')
--             EndTextCommandSetBlipName(lfbblip)
--             lfbblipcreated = true
--             SetBlipRoute(lfbblip --[[ Blip ]], true --[[ boolean ]])
--         elseif blipName == "dropoff" and not dropoffblipcreated then
--             dropoffblip = AddBlipForCoord(Config.DropOffLocationVec3)
--             BeginTextCommandSetBlipName("STRING")
--             AddTextComponentString('Foundry Drop Off')
--             EndTextCommandSetBlipName(dropoffblip)
--             dropoffblipcreated = true
--             SetBlipRoute(dropoffblip --[[ Blip ]], true --[[ boolean ]])
--         else
--             if Config.Debug then print("Ewwow, blip: "..blipName.." already created!") end
--         end
--     elseif reason == "delete" then
--         if blipName == "lfb" then
--             lfbblipcreated = false
--             RemoveBlip(lfbblip)
--             SetBlipDisplay(lfbblip --[[ Blip ]], 0 --[[ integer ]])
--             if Config.Debug then print("Deleting LFB Blip!!") end
--         elseif blipName == "dropoff" then
--             dropoffblipcreated = false
--             RemoveBlip(dropoffblip)
--             SetBlipDisplay(dropoffblip --[[ Blip ]], 0 --[[ integer ]])
--             if Config.Debug then print("Deleting Drop-Off Blip!") end
--         else
--             if Config.Debug then print("Ewwow, blip name invalid!; Cannot Delete a non-existing blip!") end
--         end
--     else
--         if Config.Debug then print("Ewwow, blip reason invalid!; Cannot delete non-existing blip!") end
--     end
-- end

function SpawnVan()
    local chance = math.random(1, 2) -- 50/50% for different locations!@
    local ped = PlayerPedId()
    local notified = false -- Default False

    if chance == 1 then
        vancoords = vector3(1458.35, 1161.84, 114.32) 
    elseif chance == 2 then
        vancoords = vector3(1465.12, 1147.17, 114.36)
    end

    scoutvan = true
    local ModelHash = Config.VanModel -- Use Compile-time hashes to get the hash of this model
    if not IsModelInCdimage(ModelHash) then return end
    RequestModel(ModelHash) -- Request the model
    while not HasModelLoaded(ModelHash) do -- Waits for the model to load with a check so it does not get stuck in an infinite loop
    Citizen.Wait(10)
    end

    goldvan = CreateVehicle(Config.VanModel, vancoords, 88.04, false, false)

    if Config.Debug then print('Van is Spawned!') end

    CreateThread(function()
        while scoutvan do
            Wait(2500)
            
            if QBCore.Functions.GetClosestVehicle() == goldvan then

                if Config.Debug then print('Client is near the Gold Van Now!') end

                local ped = PlayerPedId()
                local dropoffcoords = Config.DropOffLocationVec3
                local pedcoords = GetEntityCoords(ped)
                local vandist = #(dropoffcoords - pedcoords)
            
                invan = true
                if not notified then
                    QBCore.Functions.Notify('I need to bring that van to the Foundry!', 'primary')
                    notified = true
                end

                SetNewWaypoint(1140.35, -2023.33) -- vector2(1140.35, -2023.33)
            
                CreateThread(function()
                    while invan or closetodrop do
                        Wait(1000)
                        if vandist < 6.0 and invan then
                            invan = false
                            closetodrop = true
                            if Config.Debug then
                                print('Close to Drop!')
                            end
                        elseif vandist < 6.0 and closetodrop then
                            CreateVanTarget()
                        elseif vandist > 6.0 and closetodrop then
                            closetodrop = false
                        end
                    end
                end)
            else
                if Config.Debug then
                    print('Vehicle is not the van!')
                end
            end
        end
    end)
end

function SpawnEnemies()
    local playerped = PlayerPedId()
    RequestModel(Config.PedHash)
    while not HasModelLoaded(Config.PedHash) do
        Citizen.Wait(0)
    end
    if Config.Debug then print("Attempting Spawn of Enemies!") end
    AddRelationshipGroup("Guards")
    for i, v in pairs(Config.Positions.npcs) do
        local ped = CreatePed(28, Config.PedHash, v.x, v.y, v.z - 1, 0.0, true, true)
        SetEntityHeading(ped, v.w)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedRelationshipGroupHash(ped, "Guards")
        SetPedAccuracy(ped, Config.AIAccuracy)
        SetEntityHealth(ped, Config.AIHealth)
        SetPedCombatAttributes(ped, Config.PedCombatAttributes, true)
        SetPedFleeAttributes(ped, 0, 0)
        GiveWeaponToPed(ped, Config.AIWeapon, math.random(35, 100), false, false)
        TaskCombatPed(ped, playerped, 0, 16)
    end
end

function CreateVanTarget()
    if not targetcreated then
        exports['qb-target']:AddTargetEntity(goldvan, { -- The specified entity number
        options = { -- This is your options table, in this table all the options will be specified for the target to accept
        { -- This is the first table with options, you can make as many options inside the options table as you want
            type = "client", -- This specifies the type of event the target has to trigger on click, this can be "client", "server", "command" or "qbcommand", this is OPTIONAL and will only work if the event is also specified
            event = "cdn:goldheist:dropgoods", -- This is the event it will trigger on click, this can be a client event, server event, command or qbcore registered command, NOTICE: Normal command can't have arguments passed through, QBCore registered ones can have arguments passed through
            icon = Config.VanLootIcon, -- This is the icon that will display next to this trigger option
            label = Config.VanLootLabel, -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
            canInteract = function() -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
                return closetodrop
            end,
        }
        },
            distance = 2.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
        })
        if Config.Debug then print('Created Target') end
        targetcreated = true
        QBCore.Functions.Notify('I should drop it here and grab the stuff!', 'primary')
    end
end

-- Events --

RegisterCommand('testGetJob', function ()
    TriggerEvent('cdn:goldheist:getjob')
end, false)

RegisterNetEvent('cdn:goldheist:getjob', function()
    TriggerServerEvent('cdn:goldheist:server:startjob')
end)

RegisterNetEvent('cdn:goldheist:startjob', function()
    local ped = PlayerPedId()
    -- CreateBlipGoldHeist('lfb', 'create')
    SetNewWaypoint(1362.83, 1144.2) -- vector2(1362.83, 1144.2)
    QBCore.Functions.Notify('I heard these people have some gold things! Go get it for me!', 'primary')
    getjob = true
    TriggerServerEvent('cdn:goldheist:setcooldown', "startcooldown")
    Wait(1)
    if Config.Debug then print('Starting Thread') end
    CreateThread(function()
        while getjob do
            Wait(1000)
            if Config.Debug then  print('Thread loop!') end
            local pedcoords = GetEntityCoords(ped)
            local lfbcoords = vector3(1369.55, 1147.91, 113.28)
            local distance = #(pedcoords - lfbcoords)

            if distance < 100 then
                if Config.Debug then print("Spawning Entities!") end
                SpawnEnemies() --- Spawn the Enemies
                SpawnVan() -- Spawn the Van
                QBCore.Functions.Notify('I see them there! This is the right spot!', 'success')
                getjob = false
            end
        end
    end)
end)

RegisterNetEvent('cdn:goldheist:dropgoods', function()
    TriggerServerEvent('cdn:goldheist:server:reward')
    closetodrop = false
    scoutvan = false
end)

RegisterNetEvent('cdn:goldheist:removevan', function()
    Wait(50000)
    DeleteEntity(goldvan)
    closetodrop = false
    invan = false
end)

RegisterNetEvent('cdn:goldheist:cl:reset', function()
    getjob = false
    invan = false
    closetodrop = false
    targetcreated = false
    scoutvan = false
    lfbblipcreated = false
    dropoffblipcreated = false
    if Config.Debug then print('Cooldown Finished; Variables Reset!') end
end)
