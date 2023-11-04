local QBCore = exports['qb-core']:GetCoreObject()
local Tyres = {}
local isHoldingTyre, tyreprop = false, nil

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('flex-tyrescrap:server:GetConfig', function(cfg)
        Config = cfg
    end)
end)

RegisterNetEvent('flex-tyrescrap:client:syncConf', function(cfg)
    Config = cfg
end)

exports['qb-target']:AddTargetModel(Config.TyreProp, {
    options = {
        {
            icon = "fas fa-hands",
            label = Lang:t("info.take"),
            action = function()
                local ped = PlayerPedId()
                local animDict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@"
                QBCore.Functions.RequestAnimDict(animDict)
                TaskPlayAnim(ped, animDict, "weed_crouch_checkingleaves_idle_01_inspector", 5.0, 5.0, -1, 0, 0.0, false, false, false)
                QBCore.Functions.Progressbar("taketyres", Lang:t("info.takingtyres"), Config.TakeTime * 1000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = nil,
                    anim = nil,
                    flags = nil,
                    task = nil,
                }, {}, {},function()
                    ClearPedTasks(ped)
                    for k, v in pairs(Config.TyreLocs) do
                        QBCore.Functions.FaceToPos(v.loc.x, v.loc.y, v.loc.z)
                        local pos = GetEntityCoords(ped)
                        local loc = vec3(v.loc.x, v.loc.y, v.loc.z)
                        local tyreloc = #(loc - pos)
                        if tyreloc < 4 then
                            if v.amount > 0 then
                                TriggerServerEvent('flex-tyrescrap:server:setTyreAmount', k, loc)
                                animDict = 'anim@heists@box_carry@'
                                QBCore.Functions.RequestAnimDict(animDict)
                                TaskPlayAnim(ped, "anim@heists@box_carry@", "idle" ,2.0, 2.0, -1, 51, 0, false, false, false)
                                tyreprop = CreateObject(joaat(Config.TyreProp), pos.x, pos.y, pos.z + 0.2, true, true, true)
                                SetEntityCollision(tyreprop, false, false)
                                AttachEntityToEntity(tyreprop, ped, GetPedBoneIndex(ped, 60309), Config.TyreHoldPos.xPos, Config.TyreHoldPos.yPos, Config.TyreHoldPos.zPos, Config.TyreHoldPos.xRot, Config.TyreHoldPos.yRot, Config.TyreHoldPos.zRot, true, true, false, true, 1, true)    
                                isHoldingTyre = true
                                pickedUpTyre()
                                QBCore.Functions.Notify(Lang:t("success.placeintrunk"), "success", 4500)
                                TriggerServerEvent('flex-tyrescrap:server:getTyre')
                            else
                                QBCore.Functions.Notify(Lang:t("error.notyres"), "error", 4500)
                            end
                        end
                    end
                end, function()
                    ClearPedTasks(ped)
                    QBCore.Functions.Notify(Lang:t("error.stoppedtaking"), "error", 4500)
                end)
            end,
            canInteract = function ()
                return not isHoldingTyre
            end,
        },
    },
    distance = 1.3,
})

RegisterNetEvent('flex-tyrescrap:client:setTyreAmount', function(tyre, loc)
    Config.TyreLocs[tyre].amount = Config.TyreLocs[tyre].amount -1
    if Config.TyreLocs[tyre].amount <= 1 then
        if DoesEntityExist(Tyres['tyre'..tyre]) then
            DeleteEntity(Tyres['tyre'..tyre])
        end
    end
end)

function IsBackEngine(vehModel)
    if Config.BackEngineVehicles[vehModel] then return true else return false end
end

function pickedUpTyre()
    CreateThread(function()
        while isHoldingTyre do
            Citizen.Wait(500)
            if isHoldingTyre then
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local vehicle = QBCore.Functions.GetClosestVehicle()
                if vehicle ~= 0 and vehicle ~= nil then
                    local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
                    if (IsBackEngine(GetEntityModel(vehicle))) then
                        trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, 2.5, 0)
                    end
                    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, trunkpos) < 2.0) and not IsPedInAnyVehicle(PlayerPed) then
                        if not QBCore.Functions.HasItem(Config.TyreItem, 1) then
                            local closestObject, closestDistance = QBCore.Functions.GetClosestObject(pos)
                            if GetEntityModel(closestObject) == GetHashKey(Config.TyreProp) then
                                if DoesEntityExist(closestObject) then
                                    DeleteEntity(closestObject)
                                end
                            end
                            isHoldingTyre = false
                        end
                    else
                        CurrentVehicle = nil
                    end
                else
                    CurrentVehicle = nil
                end
            else
                break
            end
        end
    end)
end

RegisterNetEvent('flex-tyrescrap:client:spawntyres', function()
    for k, v in pairs(Config.TyreLocs) do
        local loc = vec3(v.loc.x, v.loc.y, v.loc.z)
        local closestObject, closestDistance = QBCore.Functions.GetClosestObject(loc)
        if GetEntityModel(closestObject) ~= GetHashKey(Config.TyreProp) then
            Tyres['tyre'..k] = CreateObjectNoOffset(Config.TyreProp, v.loc.x, v.loc.y, v.loc.z, 1, 0, 1)
            SetEntityHeading(Tyres['tyre'..k], v.loc.w)
            FreezeEntityPosition(Tyres['tyre'..k], true)
            PlaceObjectOnGroundProperly(Tyres['tyre'..k])
        end
    end
end)

AddEventHandler('onResourceStop', function(resource) if resource ~= GetCurrentResourceName() then return end
    exports['qb-target']:RemoveTargetModel(Config.TyreProp)
    for k, v in pairs(Tyres) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerEvent('flex-tyrescrap:client:spawntyres')
        QBCore.Functions.TriggerCallback('flex-tyrescrap:server:GetConfig', function(cfg)
            Config = cfg
        end)
    end
end)