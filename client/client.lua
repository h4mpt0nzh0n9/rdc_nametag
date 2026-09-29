local RSGCore = exports['rsg-core']:GetCoreObject()

local activatedNameTag = {}
local activePlayers = {}

local function setName(sv_id, name)
    local targetTag = activatedNameTag[sv_id]
    if targetTag == nil then return end
    SetMpGamerTagName(targetTag, name)
end
RegisterNetEvent('rdc_nametag:Client:updateName')
AddEventHandler('rdc_nametag:Client:updateName', setName)

local function splitMessage(message, count)

    local len, isOverflow, offset = utf8.len(message), false, nil

    if len > count then
        isOverflow = true
        offset = utf8.offset(message, count + 1) - 1 end
    if not isOverflow then message = string.format("'%s'", message)
    else message = string.format("'%s...'", string.sub(message, 1, offset)) end
    return message
end

local expireTimes = {}
local function setText(sv_id, text)
    local targetTag = activatedNameTag[sv_id]
    if targetTag == nil then return end

    local expireTime = GetGameTimer() + 5000
    expireTimes[sv_id] = expireTime

    CreateThread(function()
        local message = splitMessage(text, 16 * 2)
        SetMpGamerTagNamePosse(targetTag, message)

        while GetGameTimer() < expireTimes[sv_id] do Wait(100) end
        if expireTimes[sv_id] == expireTime then
            SetMpGamerTagNamePosse(targetTag, '')
        end
    end)
end
RegisterNetEvent('rdc_nametag:Client:updateText')
AddEventHandler('rdc_nametag:Client:updateText', setText)


local function toggleTyping(sv_id, toggle)
    
    if type(toggle) ~= "boolean" then return end
    local targetTag = activatedNameTag[sv_id]
    if targetTag == nil then return end

    if toggle then SetMpGamerTagBigText(targetTag, "[...]")
    else SetMpGamerTagBigText(targetTag, "") end
end
RegisterNetEvent('rdc_nametag:Client:toggleTyping')
AddEventHandler('rdc_nametag:Client:toggleTyping', toggleTyping)

local function drawText3d(x, y, z, text, colour, bgalpha)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    if not onScreen then return end

    local scale = 0.7
    SetTextScale(0.0, 0.35 * scale)
    if type(colour) == 'table' then
        if #(colour) == 4 then
            SetTextColor(colour[1], colour[2], colour[3], colour[4])
        elseif #(colour) == 3 then
            SetTextColor(colour[1], colour[2], colour[3], 255)
        else
            SetTextColor(255, 255, 255, 255)
        end
    end
    SetTextDropshadow(2, 0, 0, 0, 255)

    local lineCount = select(2, string.gsub(text, "~n~", "")) + 1
    local textLength = #text - (bgalpha ~= 0 and 3 or 0)
    local textWidth  = (0.005 * textLength / lineCount * scale) + (0.01 * scale)
    local textHeight = 0.03 * lineCount * scale
    local offsetY    = _y + textHeight / 2.2

    DrawRect(_x, offsetY, textWidth, textHeight, 0, 0, 0, bgalpha)

    Citizen.InvokeNative(0xADA9255D, 1)
    Citizen.InvokeNative(0xBE5261939FBECB8C, true)
    Citizen.InvokeNative(0xd79334a4bb99bad1,
        Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", text, Citizen.ResultAsLong()), _x, _y)
end

local expireTimes_ = {}
local function displayAction(sv_id, text, colour, duration)

    local playerIdx = GetPlayerFromServerId(sv_id)
    local isActive, message = NetworkIsPlayerActive(playerIdx), splitMessage(text, 16 * 2)
    if not isActive then return end

    expireTimes_[sv_id] = {} Wait(100)
    local expireTime = GetGameTimer() + duration
    expireTimes_[sv_id] = expireTime

    local entity = GetPlayerPed(playerIdx)
    local boneIndex = GetEntityBoneIndexByName(entity, "SKEL_HEAD")
    if not DoesEntityExist(entity) then return end

    CreateThread(function()
    
        local playerPed = PlayerPedId()
        repeat
            local coords, coords_ = GetEntityCoords(playerPed), GetWorldPositionOfEntityBone(entity, boneIndex)
            local distance = #(coords - coords_)
            if distance > 15.0 then break end
            drawText3d(coords_.x, coords_.y, coords_.z + 0.3, text, colour, 1)
            Wait(0)
        until GetGameTimer() > expireTimes_[sv_id]
    end)
end
RegisterNetEvent('rdc_nametag:Client:displayAction')
AddEventHandler('rdc_nametag:Client:displayAction', displayAction)

Citizen.CreateThread(function()

    local isLoggedIn = false
    while not isLoggedIn do
        isLoggedIn = LocalPlayer.state.isLoggedIn
        Wait(1000)
    end

    while true do
        
        activePlayers = GetActivePlayers()
        for _, v in ipairs(activePlayers) do
            local sv_id = GetPlayerServerId(v)

            if activatedNameTag[sv_id] == nil then
                TriggerServerEvent('rdc_nametag:Server:updateName', sv_id)
                activatedNameTag[sv_id] = CreateMpGamerTag(v, "LOADING CHARACTER", false, false, "DEFAULT", 0)
            end
        end

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for k, _ in pairs(activatedNameTag) do
            local cl_id = GetPlayerFromServerId(k)
            local entity = GetPlayerPed(cl_id)

            if not DoesEntityExist(entity) then
                RemoveMpGamerTag(activatedNameTag[k])
                activatedNameTag[k] = nil
            else
                local coords_ = GetEntityCoords(entity)
                local distance = #(coords - coords_)

                if distance < 15.0 then SetMpGamerTagVisibility(activatedNameTag[k], 3)
                else SetMpGamerTagVisibility(activatedNameTag[k], 0) end
            end

            local coords_ = GetEntityCoords(entity)
            local distance = #(coords - coords_)

            if distance < 15.0 then SetMpGamerTagVisibility(activatedNameTag[k], 3)
            else SetMpGamerTagVisibility(activatedNameTag[k], 0) end
        end
        Wait(500)
    end
end)