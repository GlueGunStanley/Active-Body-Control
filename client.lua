
     --[[ STANLEY DEVELOPMENT STUDIOS ]]--
--[[ https://discord.com/invite/uCKZJed3Gq ]]--


local toggledVehicles = {}
local previousVehicle = nil

RegisterNetEvent('cl:gbounce:Toggle')
AddEventHandler('cl:gbounce:Toggle', function()
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)
    local vehicleClass = GetVehicleClass(vehicle)

    if IsPedInAnyVehicle(player, false) then
        if (vehicleClass == 8 or vehicleClass == 13 or vehicleClass == 21) then
            TriggerEvent('cl:gbounce:Notify', "~r~You can't use that command with this vehicle!") 
            return
        end

        if (IsPedInAnyHeli(player) or IsPedInAnyPlane(player) or IsPedInAnyBoat(player)) then 
            TriggerEvent('cl:gbounce:Notify', "~r~You can't use that command with this vehicle!") 
            return 
        end

        -- If the player switches to a different vehicle, stop the bounce on the previous vehicle
        if previousVehicle ~= nil and previousVehicle ~= vehicle then
            SetVehicleSuspensionHeight(previousVehicle, 0.0)
            toggledVehicles[previousVehicle] = false
        end

        toggledVehicles[vehicle] = not toggledVehicles[vehicle]
        previousVehicle = vehicle

        if toggledVehicles[vehicle] then
            TriggerEvent('cl:gbounce:Notify', "~w~Bounce mode enabled.")
            if DoesEntityExist(vehicle) then
                Citizen.CreateThread(function()
                    BounceLoop(vehicle)
                end)
            else
                TriggerEvent('cl:gbounce:Notify', "~w~You must be in a vehicle to use this command!")
            end
        else
            -- Reset suspension height to 0 when toggling off
            if DoesEntityExist(vehicle) then
                SetVehicleSuspensionHeight(vehicle, 0.0)
                TriggerEvent('cl:gbounce:Notify', "~w~Bounce mode disabled.")
            end
        end
    else
        TriggerEvent('cl:gbounce:Notify', "~w~You must be in a vehicle to use this command!")
    end
end)

local minSuspensionHeight = 0.0   
local maxSuspensionHeight = -0.075  
local transitionDuration = 300      
local numSteps = 30                
local waitTime = transitionDuration / numSteps  

function BounceLoop(vehicle)
    local suspensionHeight = minSuspensionHeight   
    local stepSize = (maxSuspensionHeight - minSuspensionHeight) / numSteps  

    while toggledVehicles[vehicle] do
        if not DoesEntityExist(vehicle) then
            toggledVehicles[vehicle] = false
            return
        end

        for i = 1, numSteps do
            if not toggledVehicles[vehicle] then
                SetVehicleSuspensionHeight(vehicle, 0.0)
                return
            end
            
            Wait(waitTime)   
            
            suspensionHeight = suspensionHeight + stepSize
            
            SetVehicleSuspensionHeight(vehicle, suspensionHeight)
            
            if suspensionHeight <= maxSuspensionHeight or suspensionHeight >= minSuspensionHeight then
                stepSize = -stepSize  
            end
        end

        Wait(0)
    end

    SetVehicleSuspensionHeight(vehicle, 0.0)
end

function Lerp(a, b, t)
    return a + (b - a) * t
end

Citizen.CreateThread(function()
    local activated = false
    while Config.EnableKeyBind do
        Wait(0)
        if IsControlPressed(0, Config.KeyBind) and IsPedInAnyVehicle(PlayerPedId()) then
            if not activated then
                local timer = 0 
                local hold = (Config.HoldDuration * 1000) 
                activated = true
                while IsControlPressed(0, Config.KeyBind) do
                    Wait(0)
                    timer = timer + GetFrameTime() * 1000
                    if timer >= hold then
                        TriggerServerEvent('sv:gbounce:IsPlayerAllowed')
                        print("test")
                        break
                    end
                end
            end
        else
            activated = false
        end
    end
end)

AddEventHandler('cl:gbounce:Notify', function(message)
    PlaySoundFrontend(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", false)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end)

RegisterCommand("gbounce", function(source, args, rawCommand)
    TriggerEvent('chat:addSuggestion', '/gbounce', 'Bounce in style!', {{ name="/gbounce", help="Bounce in style!" }})
    if IsPedInAnyVehicle(PlayerPedId()) then
        TriggerEvent('cl:gbounce:Toggle')
    else
        TriggerEvent('cl:gbounce:Notify', "~w~You must be in a vehicle to use this command!")
    end
end, Config.RequirePerms)
