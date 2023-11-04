local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback("flex-tyrescrap:server:GetConfig", function(source, cb)
    cb(Config)
end)

RegisterNetEvent('flex-tyrescrap:server:setTyreAmount', function(tyre, loc)
    Config.TyreLocs[tyre].amount = Config.TyreLocs[tyre].amount -1
    TriggerClientEvent('flex-tyrescrap:client:setTyreAmount', -1, tyre, loc)
end)

RegisterNetEvent("flex-tyrescrap:server:getTyre", function() 
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(Config.TyreItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.TyreItem], 'add')
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(Config.TyreLocs) do
            v.amount = math.random(3,7)
        end
        CreateThread(function()
            while true do
                Wait(1000 * 60 * Config.ResetTime)
                TriggerClientEvent('flex-tyrescrap:client:spawntyres', -1)
                for k, v in pairs(Config.TyreLocs) do
                    v.amount = math.random(3,7)
                    if k == #Config.TyreLocs then
                        TriggerClientEvent('flex-tyrescrap:client:syncConf', -1, Config)
                    end
                end
            end
        end)
    end
end)
