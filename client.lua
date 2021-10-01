local CreateThread = CreateThread
local Wait = Wait
local CreateThread = CreateThread

local firstSpawn = true

CreateThread(function()
	while firstSpawn do
		Wait(0)

		if NetworkIsPlayerActive(PlayerId()) then
            if firstSpawn then
			    TriggerServerEvent('vola:playerJoined')
                firstSpawn = false
            end
			break
		end
	end
end)

RegisterNetEvent('vola:updatePlayers', function(players, maxPlayers, runTime)
    SendNUIMessage({
        action = 'updatePlayers',
        players = players,
        maxPlayers = maxPlayers,
        runTime = runTime
    })
end)

RegisterCommand(Config.CommandName, function()
    if not IsEntityDead(PlayerPedId()) and not IsPauseMenuActive() then
        TriggerServerEvent('vola:getPlayers')
        SendNUIMessage({action = 'openScoreboard'})
        SetNuiFocus(1, 1)
    end
end)

RegisterKeyMapping(Config.CommandName, Config.CommandDescription, 'keyboard', Config.CommandKey)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(0, 0)
    cb({})
end)