local QBCore = exports['qb-core']:GetCoreObject()
local startcooldown = false
local rewardcooldown = false

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        -- Whenever the resource restarts set cooldowns to false
        startcooldown = false
        rewardcooldown = false
        TriggerClientEvent('cdn:goldheist:cl:reset', -1)
    end
end)

CreateThread(function()
    while true do
        Wait(2500)
        if startcooldown and rewardcooldown then
            Wait(Config.HeistCooldown)
            startcooldown = false
            rewardcooldown = false
            TriggerClientEvent('cdn:goldheist:cl:reset', -1)
        end
    end
end)

RegisterNetEvent('cdn:goldheist:server:startjob', function()
    local src = source
    if not startcooldown then
        TriggerClientEvent('cdn:goldheist:startjob', src)
    else
        TriggerClientEvent('QBCore:Notify', src, "I don't have any jobs right now!", 'error')
    end
end)

RegisterNetEvent('cdn:goldheist:server:reward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local RewardLabel = QBCore.Shared.Items[Config.Reward].label
    if not rewardcooldown then
        Player.Functions.AddItem(Config.Reward, Config.RewardAmount, false)
        TriggerClientEvent('QBCore:Notify', src, "You grabbed "..Config.RewardAmount.." "..RewardLabel.."es from the van!", 'success')
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Reward], 'add')
        TriggerClientEvent('cdn:goldheist:removevan', src) 
        rewardcooldown = true
    else
        TriggerClientEvent('QBCore:Notify', src, "Someone already grabbed everything!", 'error')
    end
end)

RegisterNetEvent('cdn:goldheist:setcooldown', function(cooldowntype)
    if cooldowntype == "startcooldown" then
        startcooldown = true
    elseif cooldowntype == "rewardcooldown" then
        rewardcooldown = true
    else
        print('Majow Ewwow: Cooldown type does not exist!')
    end
end)
