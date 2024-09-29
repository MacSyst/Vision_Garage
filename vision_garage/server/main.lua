SetConvarServerInfo('tags', 'Vision-Scripts')

RegisterServerEvent('vision_garage:updateOwnedVehicle')
AddEventHandler('vision_garage:updateOwnedVehicle', function(stored, parking, Impound, data, spawn)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.update('UPDATE owned_vehicles SET `stored` = @stored, `vehicle` = @vehicle WHERE `plate` = @plate AND `owner` = @identifier',
    {
        ['@identifier'] = xPlayer.identifier,
        ['@vehicle']    = json.encode(data.vehicleProps),
        ['@plate']      = data.vehicleProps.plate,
        ['@stored']     = stored
    })

    if stored then
        xPlayer.showNotification(TranslateCap('veh_stored'))
    else
        local vehicleProps = data.vehicleProps
        local vehicleModel = vehicleProps.model
        
        ESX.OneSync.SpawnVehicle(vehicleModel, spawn, data.spawnPoint.heading, vehicleProps, function(vehicle)
            local vehicleEntity = NetworkGetEntityFromNetworkId(vehicle)
            Wait(300)
            TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicleEntity, -1)
        end)
    end

    if Vision.DiscordNotify then
        local webhook = Vision.Webhook
        local name = GetPlayerName(source)
        local steam = GetPlayerIdentifier(source, 0)
        local discord = GetPlayerIdentifier(source, 1)
        local id = source
        local vehicleProps = data.vehicleProps
        local plate = vehicleProps.plate
        local model = vehicleProps.model

        local VisionMessage = {
            embeds = {{
                title = "Vision - Garage",
                description = "A player's vehicle status was updated in the garage.",
                fields = {
                    {name = "Player:", value = "```[" .. id .. "] " .. name .. "```"},
                    {name = "Plate:", value = "```" .. plate .. "```"},
                    {name = "Model:", value = "```" .. model .. "```"},
                    {name = "Parked:", value = "```" .. (stored and "Yes" or "No") .. "```"},
                    {name = "Steam:", value = "```" .. steam .. "```"},
                    {name = "Discord:", value = "```" .. discord .. "```"}
                },
                footer = {
                    text = "Vision - Garage | Made by Kugelspitzer",
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                color = 0x6f249e
            }}
        }

        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode(VisionMessage), {['Content-Type'] = 'application/json'})
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        MySQL.query('SELECT owner, plate FROM owned_vehicles', {}, function(results)
            for _, vehicle in ipairs(results) do
                MySQL.update('UPDATE owned_vehicles SET `stored` = 1 WHERE `owner` = @owner AND `plate` = @plate', {
                    ['@owner'] = vehicle.owner,
                    ['@plate'] = vehicle.plate
                })
            end
        end)
    end
end)

RegisterCommand('rac', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getGroup() == 'admin' then
        MySQL.query('SELECT owner, plate FROM owned_vehicles', {}, function(results)
            for _, vehicle in ipairs(results) do
                MySQL.update('UPDATE owned_vehicles SET `stored` = 1 WHERE `owner` = @owner AND `plate` = @plate', {
                    ['@owner'] = vehicle.owner,
                    ['@plate'] = vehicle.plate
                })
            end

            xPlayer.showNotification("All vehicles have been updated to stored status.")
        end)
    else
        xPlayer.showNotification("You do not have permission to execute this command.")
    end
end, false)

ESX.RegisterServerCallback('vision_garage:getVehiclesInParking', function(source, cb, parking)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `stored` = 1',
    {
        ['@identifier'] = xPlayer.identifier
    }, function(result)

        local vehicles = {}
        for i = 1, #result, 1 do
            table.insert(vehicles, {
                vehicle = json.decode(result[i].vehicle),
                plate   = result[i].plate
            })
        end

        cb(vehicles)
    end)
end)

ESX.RegisterServerCallback('vision_garage:checkVehicleOwner', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.query('SELECT COUNT(*) as count FROM `owned_vehicles` WHERE `owner` = @identifier AND `plate` = @plate',
    {
        ['@identifier'] = xPlayer.identifier,
        ['@plate']     = plate
    }, function(result)

        if tonumber(result[1].count) > 0 then
            return cb(true)
        else
            return cb(false)
        end
    end)
end)

ESX.RegisterServerCallback('vision_garage:checkMoney', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    cb(xPlayer.getMoney() >= amount)
end)
