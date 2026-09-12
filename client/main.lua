-- FiveM Vehicle Lock Script
-- Main Client File

local lockOpen = false
local lockedVehicles = {}

-- U Taste zum Abschließen/Entsperren
Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        -- U Taste zum Abschließen/Entsperren
        if IsControlJustReleased(0, 303) then -- U Taste
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle ~= 0 then
                ToggleVehicleLock(vehicle)
            end
        end
    end
end)

function ToggleVehicleLock(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local locked = lockedVehicles[plate] or false
    
    if locked then
        UnlockVehicle(vehicle, plate)
    else
        LockVehicle(vehicle, plate)
    end
end

function LockVehicle(vehicle, plate)
    SmashVehicleWindow(vehicle, 0)
    SmashVehicleWindow(vehicle, 1)
    SmashVehicleWindow(vehicle, 2)
    SmashVehicleWindow(vehicle, 3)
    
    SetVehicleDoorsShut(vehicle, false)
    SetVehicleEngineHealth(vehicle, GetVehicleEngineHealth(vehicle))
    
    -- Sound abspielen
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
    
    lockedVehicles[plate] = true
    
    -- In Datenbank speichern
    TriggerServerEvent('vehicleLock:saveVehicle', plate, true)
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"🔒 Auto", "Fahrzeug abgeschlossen! (Platte: " .. plate .. ")"}
    })
end

function UnlockVehicle(vehicle, plate)
    SetVehicleDoorsShut(vehicle, false)
    
    -- Sound abspielen
    PlaySoundFrontend(-1, "CANCEL_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
    
    lockedVehicles[plate] = false
    
    -- In Datenbank speichern
    TriggerServerEvent('vehicleLock:saveVehicle', plate, false)
    
    TriggerEvent('chat:addMessage', {
        color = {255, 150, 0},
        multiline = true,
        args = {"🔓 Auto", "Fahrzeug entsperrt! (Platte: " .. plate .. ")"}
    })
end

-- Gesperrte Fahrzeuge vom Server laden
RegisterNetEvent('vehicleLock:receiveLockedVehicles')
AddEventHandler('vehicleLock:receiveLockedVehicles', function(vehicles)
    lockedVehicles = vehicles
    if vehicles and next(vehicles) then
        TriggerEvent('chat:addMessage', {
            color = {0, 150, 255},
            multiline = true,
            args = {"Auto", "Fahrzeug-Status geladen!"}
        })
    end
end)

-- Export
exports('toggleVehicleLock', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 then
        ToggleVehicleLock(vehicle)
    end
end)

-- Beim Spawnen laden
Citizen.CreateThread(function()
    Wait(1000)
    TriggerServerEvent('vehicleLock:loadVehicles')
end)
