
     --[[ STANLEY DEVELOPMENT STUDIOS ]]--
--[[ https://discord.com/invite/uCKZJed3Gq ]]--


RegisterNetEvent('sv:gbounce:IsPlayerAllowed')
AddEventHandler('sv:gbounce:IsPlayerAllowed', function()
    local playerId = source
    if IsPlayerAceAllowed(tostring(playerId), "command.gbounce") then
        TriggerClientEvent("cl:gbounce:Toggle", tostring(playerId))
    else
        TriggerClientEvent('cl:gbounce:Notify', tostring(playerId), "~r~You do not have the necessary permissions to use this command!")
    end 
end)