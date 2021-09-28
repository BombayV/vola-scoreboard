local CreateThread = CreateThread
local Wait = Wait

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

CreateThread(function()
    while true do
        Wait(Config.UpdateTime * 1000)
        TriggerServerEvent('vola:getPlayers')
    end
end)

RegisterNetEvent('vola:updatePlayers', function(players)
    print(json.encode(players))
    --[[
    SendNUIMessage({
        action = 'updatePlayers',
        players = players
    })
    ]]
end)

RegisterCommand(Config.CommandName, function()
    if not IsEntityDead(PlayerPedId()) then
        SendNUIMessage({action = 'openScoreboard'})
    end
end)

RegisterKeyMapping(Config.CommandName, Config.CommandDescription, 'keyboard', Config.CommandKey)