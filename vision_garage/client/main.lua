local LastMarker, LastPart, thisGarage = nil, nil, nil
local next = next
local nearMarker, menuIsShowed = false, false
local vehiclesList = {}

if Vision.Debug then
    local filename = function()
        local str = debug.getinfo(2, "S").source:sub(2)
        return str:match("^.*/(.*).lua$") or str
    end
    print("^1[DEBUG]^0 ^3-^0 "..filename()..".lua^0 ^2Loaded^0!");
end

RegisterNetEvent('vision_garage:closemenu')
AddEventHandler('vision_garage:closemenu', function()
    menuIsShowed = false
    vehiclesList = {}

    SetNuiFocus(false)
    SendNUIMessage({
        hideAll = true
    })

    if not menuIsShowed and thisGarage then
        ESX.TextUI(TranslateCap('access_parking'))
    end
end)

RegisterNUICallback('escape', function(data, cb)
    TriggerEvent('vision_garage:closemenu')
    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    local spawnCoords = vector3(data.spawnPoint.x, data.spawnPoint.y, data.spawnPoint.z)
    if thisGarage then
        if ESX.Game.IsSpawnPointClear(spawnCoords, 2.5) then
            thisGarage = nil
            TriggerServerEvent('vision_garage:updateOwnedVehicle', false, nil, nil, data, spawnCoords)
            TriggerEvent('vision_garage:closemenu')

            ESX.ShowNotification(TranslateCap('veh_released'))
        else
            BeginTextCommandThefeedPost("STRING")
            AddTextComponentSubstringPlayerName("~r~"..TranslateCap('veh_blocked'))
            EndTextCommandThefeedPostTicker(true, true)
        end
    end

    cb('ok')
end)

CreateThread(function()
    for k, v in pairs(Vision.Garages) do
        local blip = AddBlipForCoord(v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z)

        SetBlipSprite(blip, v.Sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, v.Scale)
        SetBlipColour(blip, v.Colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(TranslateCap('parking_blip_name'))
        EndTextCommandSetBlipName(blip)
    end
end)

AddEventHandler('vision_garage:hasEnteredMarker', function(name, part)
    if part == 'EntryPoint' then
        local isInVehicle = IsPedInAnyVehicle(ESX.PlayerData.ped, false)
        local garage = Vision.Garages[name]
        thisGarage = garage

        if isInVehicle then
            ESX.TextUI(TranslateCap('park_veh'))
        else
            ESX.TextUI(TranslateCap('access_parking'))
        end
    end
end)

AddEventHandler('vision_garage:hasExitedMarker', function()
    thisGarage = nil
    ESX.HideUI()
    TriggerEvent('vision_garage:closemenu')
end)

CreateThread(function()
    while true do
        local sleep = 500

        local playerPed = ESX.PlayerData.ped
        local coords = GetEntityCoords(playerPed)

        for k, v in pairs(Vision.Garages) do
            if (#(coords - vector3(v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z)) < Vision.DrawDistance) then
                DrawMarker(Vision.Markers.EntryPoint.Type, v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z, 0.0, 0.0,
                    0.0, 0, 0.0, 0.0, Vision.Markers.EntryPoint.Size.x, Vision.Markers.EntryPoint.Size.y,
                    Vision.Markers.EntryPoint.Size.z, Vision.Markers.EntryPoint.Color.r,
                    Vision.Markers.EntryPoint.Color.g, Vision.Markers.EntryPoint.Color.b, 100, false, true, 2, false,
                    false, false, false)
                sleep = 0
                break
            end
        end

        if sleep == 0 then
            nearMarker = true
        else
            nearMarker = false
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        if nearMarker then
            local playerPed = ESX.PlayerData.ped
            local coords = GetEntityCoords(playerPed)
            local isInMarker = false
            local currentMarker = nil
            local currentPart = nil

            for k, v in pairs(Vision.Garages) do
                if (#(coords - vector3(v.EntryPoint.x, v.EntryPoint.y, v.EntryPoint.z)) < Vision.Markers.EntryPoint.Size.x) then
                    isInMarker = true
                    currentMarker = k
                    currentPart = 'EntryPoint'
                    local isInVehicle = IsPedInAnyVehicle(playerPed, false)

                    if not isInVehicle then
                        if IsControlJustReleased(0, 38) and not menuIsShowed then
                            ESX.TriggerServerCallback('vision_garage:getVehiclesInParking', function(vehicles)
                                if next(vehicles) then
                                    menuIsShowed = true

                                    for i = 1, #vehicles, 1 do
                                        table.insert(vehiclesList, {
                                            model = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model),
                                            plate = vehicles[i].plate,
                                            props = vehicles[i].vehicle
                                        })
                                    end

                                    local spawnPoint = {
                                        x = v.SpawnPoint.x,
                                        y = v.SpawnPoint.y,
                                        z = v.SpawnPoint.z,
                                        heading = v.SpawnPoint.heading
                                    }

                                    SendNUIMessage({
                                        showMenu = true,
                                        type = 'garage',
                                        vehiclesList = {json.encode(vehiclesList)},
                                        spawnPoint = spawnPoint,
                                        locales = {
                                            action = TranslateCap('veh_exit'),
                                            veh_model = TranslateCap('veh_model'),
                                            veh_plate = TranslateCap('veh_plate'),
                                            veh_condition = TranslateCap('veh_condition'),
                                            veh_action = TranslateCap('veh_action')
                                        }
                                    })

                                    SetNuiFocus(true, true)

                                    if menuIsShowed then
                                        ESX.HideUI()
                                    end
                                else
                                    menuIsShowed = true

                                    SendNUIMessage({
                                        showMenu = true,
                                        type = 'garage',
                                        locales = {
                                            action = TranslateCap('veh_exit'),
                                            veh_model = TranslateCap('veh_model'),
                                            veh_plate = TranslateCap('veh_plate'),
                                            veh_condition = TranslateCap('veh_condition'),
                                            veh_action = TranslateCap('veh_action'),
                                            no_veh_parking = TranslateCap('no_veh_parking')
                                        }
                                    })

                                    SetNuiFocus(true, true)

                                    if menuIsShowed then
                                        ESX.HideUI()
                                    end
                                end
                            end, currentMarker)
                        end
                    end

                    if isInVehicle then
                        if IsControlJustReleased(0, 38) then
                            local vehicle = GetVehiclePedIsIn(playerPed, false)
                            local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
                            ESX.TriggerServerCallback('vision_garage:checkVehicleOwner', function(owner)
                                if owner then
                                    ESX.Game.DeleteVehicle(vehicle)
                                    TriggerServerEvent('vision_garage:updateOwnedVehicle', true, currentMarker, nil, {vehicleProps = vehicleProps})
                                else

                                    ESX.ShowNotification(TranslateCap('not_owning_veh'), 'error')
                                    
                                end
                            end, vehicleProps.plate)
                        end
                    end
                    break
                end
            end

            if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastMarker ~= currentMarker or LastPart ~= currentPart)) then
                if LastMarker ~= currentMarker or LastPart ~= currentPart then
                    TriggerEvent('vision_garage:hasExitedMarker')
                end

                HasAlreadyEnteredMarker = true
                LastMarker = currentMarker
                LastPart = currentPart

                TriggerEvent('vision_garage:hasEnteredMarker', currentMarker, currentPart)
            end

            if not isInMarker and HasAlreadyEnteredMarker then
                HasAlreadyEnteredMarker = false

                TriggerEvent('vision_garage:hasExitedMarker')
            end

            Wait(0)
        else
            Wait(500)
        end
    end
end)
