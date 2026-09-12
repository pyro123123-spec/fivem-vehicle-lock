-- FiveM Vehicle Lock Script
-- Lock Handler

function SetVehicleLocked(vehicle, locked)
    if locked then
        SmashVehicleWindow(vehicle, 0)
        SmashVehicleWindow(vehicle, 1)
        SmashVehicleWindow(vehicle, 2)
        SmashVehicleWindow(vehicle, 3)
        SetVehicleDoorsShut(vehicle, false)
    else
        SetVehicleDoorsShut(vehicle, false)
    end
end

function IsVehicleLocked(vehicle)
    return GetVehicleDoorLockStatus(vehicle) == 2
end

-- Export
exports('setVehicleLocked', function(vehicle, locked)
    SetVehicleLocked(vehicle, locked)
end)

exports('isVehicleLocked', function(vehicle)
    return IsVehicleLocked(vehicle)
end)
