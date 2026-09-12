-- FiveM Vehicle Lock Script
-- Server File mit Datenbank Support

print("^2[Vehicle Lock] Server Script geladen!^7")

-- Datenbank initialisieren
local function initializeDatabase()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `vehicle_locks` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `plate` VARCHAR(50) NOT NULL UNIQUE,
            `owner_id` VARCHAR(50),
            `owner_name` VARCHAR(100),
            `locked` TINYINT DEFAULT 0,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX `plate_idx` (`plate`),
            INDEX `owner_idx` (`owner_id`)
        )
    ]])
    
    print("^3[Vehicle Lock] Datenbank Tabelle erstellt/aktualisiert!^7")
end

-- Starte Datenbank Init beim Server-Start
Citizen.CreateThread(function()
    Wait(1000)
    initializeDatabase()
end)

-- Fahrzeug-Status speichern
RegisterServerEvent('vehicleLock:saveVehicle')
AddEventHandler('vehicleLock:saveVehicle', function(plate, locked)
    local source = source
    local player = GetPlayer(source)
    
    if not player then return end
    
    local lockStatus = locked and 1 or 0
    
    MySQL.Async.execute(
        'INSERT INTO vehicle_locks (plate, owner_id, owner_name, locked) VALUES (@plate, @owner_id, @owner_name, @locked) ON DUPLICATE KEY UPDATE locked = @locked, updated_at = NOW()',
        {
            ['@plate'] = plate,
            ['@owner_id'] = player.identifier,
            ['@owner_name'] = player.name,
            ['@locked'] = lockStatus
        },
        function(rowsChanged)
            print("^2[Vehicle Lock] Fahrzeug " .. plate .. " Status aktualisiert: " .. (locked and "GESPERRT" or "ENTSPERRT") .. "^7")
        end
    )
end)

-- Alle Fahrzeug-Status laden
RegisterServerEvent('vehicleLock:loadVehicles')
AddEventHandler('vehicleLock:loadVehicles', function()
    local source = source
    
    MySQL.Async.fetchAll(
        'SELECT plate, locked FROM vehicle_locks WHERE locked = 1',
        {},
        function(results)
            local vehicles = {}
            
            if results then
                for i, row in ipairs(results) do
                    vehicles[row.plate] = (row.locked == 1)
                end
            end
            
            TriggerClientEvent('vehicleLock:receiveLockedVehicles', source, vehicles)
        end
    )
end)

-- Fahrzeug entsperren für neuen Besitzer
RegisterServerEvent('vehicleLock:transferVehicle')
AddEventHandler('vehicleLock:transferVehicle', function(plate, newOwnerId, newOwnerName)
    MySQL.Async.execute(
        'UPDATE vehicle_locks SET owner_id = @owner_id, owner_name = @owner_name, locked = 0 WHERE plate = @plate',
        {
            ['@plate'] = plate,
            ['@owner_id'] = newOwnerId,
            ['@owner_name'] = newOwnerName
        },
        function(rowsChanged)
            print("^3[Vehicle Lock] Fahrzeug " .. plate .. " zu " .. newOwnerName .. " übertragen!^7")
        end
    )
end)

-- Admin Command
RegisterCommand('vehiclelock', function(source, args, rawCommand)
    if source == 0 then
        print("Console - Befehle verfügbar:")
        print("/vehiclelock list - Zeige alle gesperrten Autos")
        print("/vehiclelock unlock <plate> - Entsperre ein Auto")
        print("/vehiclelock reset - Setze alle auf entsperrt")
        return
    end
    
    local subcommand = args[1]
    
    if subcommand == "list" then
        MySQL.Async.fetchAll(
            'SELECT plate, owner_name, locked FROM vehicle_locks WHERE locked = 1',
            {},
            function(results)
                local message = "^3=== Gesperrte Fahrzeuge ===^7\n"
                if results and #results > 0 then
                    for i, row in ipairs(results) do
                        message = message .. i .. ". " .. row.plate .. " (" .. row.owner_name .. ")\n"
                    end
                else
                    message = message .. "Keine Fahrzeuge gesperrt!"
                end
                TriggerClientEvent('chat:addMessage', source, {
                    color = {0, 150, 255},
                    multiline = true,
                    args = {"Fahrzeug Status", message}
                })
            end
        )
    elseif subcommand == "unlock" and args[2] then
        MySQL.Async.execute(
            'UPDATE vehicle_locks SET locked = 0 WHERE plate = @plate',
            {['@plate'] = string.upper(args[2])}
        )
    elseif subcommand == "reset" then
        MySQL.Async.execute('UPDATE vehicle_locks SET locked = 0')
    end
end)

-- Hilfsfunktion
function GetPlayer(source)
    local identifiers = GetPlayerIdentifiers(source)
    if not identifiers or #identifiers == 0 then return nil end
    return {
        identifier = identifiers[1],
        name = GetPlayerName(source),
        source = source
    }
end

print("^2[Vehicle Lock] Server bereit!^7")
