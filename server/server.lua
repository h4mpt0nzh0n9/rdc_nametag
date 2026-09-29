local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterServerEvent('rdc_nametag:Server:updateName', function(sv_id)
    local name = exports['rdc_main']:GetCharacterName(sv_id)
    if name == nil then name = " " end
    
    local pos = string.find(name, "MASK_")
    if pos ~= nil then 
        name = name 
    elseif pos == nil then
        name = name .. " " .."(".. sv_id ..")"
    end
    TriggerClientEvent('rdc_nametag:Client:updateName', -1, sv_id, name)
end)

RegisterServerEvent('rdc_nametag:Server:updateText', function(sv_id, message)
    TriggerClientEvent('rdc_nametag:Client:updateText', -1, sv_id, message)
end)

RegisterServerEvent('rdc_nametag:Server:toggleTyping', function(sv_id, toggle)
    TriggerClientEvent('rdc_nametag:Client:toggleTyping', -1, sv_id, toggle)
end)