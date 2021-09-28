local playerData = {}

local function getLicense(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)

    for _, v in pairs(identifiers) do
        if string.match(v, 'license:') then
            return v
        end
    end
    return false
end

RegisterNetEvent('vola:getPlayers', function()
    local source <const> = source
    if not playerData[source] then
        return print('Scoreboard needs to be refreshed. Use /restartScoreboard')
    end
    local currentPlayers = {}
    local time = os.time()
    for _, v in pairs(GetPlayers()) do
        local player = playerData[tonumber(v)]
        currentPlayers[v] = {playersName = player.name, playersStatus = 'Police', playersTime = player.Time().displayed(time)}
    end
    TriggerClientEvent('vola:updatePlayers', source, currentPlayers)
end)

RegisterNetEvent('vola:playerJoined', function()
    local playerId <const> = source
    if getLicense(playerId) then
        local time = getTime(playerId)
        local actualTime =  os.time()
        playerData[tonumber(playerId)] = playerStatus(playerId, getLicense(playerId), time, actualTime, GetPlayerName(playerId))
    end
end)

AddEventHandler('playerDropped', function()
	local playerId <const> = source
	local player = playerData[playerId]
    local time = os.time()

	if player then
        savePlayerData(playerId, time, player)
		playerData[tonumber(playerId)] = nil
	end
end)

function savePlayerData(playerId, time, player)
    if playerId then
        if player then
            if not time then time = os.time() end
            MySQL.Async.execute('INSERT INTO time_played (license, time) VALUES (@identifier, @time)', {
                ['identifier'] = identifier,
                ['time'] = player.Time().currentTime(time)
            }, function(result)
                print(result)
            end)
        end
    end
end

function getTime(playerId)
    local p = promise.new()
    local license = getLicense(playerId)
    MySQL.Async.fetchScalar('SELECT time FROM time_played WHERE license = @license', {
        ['license'] = license
    }, function(result)
        if result then
            return p:resolve({currentTime = result})
        else
            MySQL.Async.execute('INSERT INTO time_played (license) VALUES (@identifier)', {
                ['identifier'] = license
            })
            return p:resolve({currentTime = 0})
        end
    end)
    local resp = Citizen.Await(p)
    return resp.currentTime
end

RegisterCommand('restartScoreboard', function(source)
    local playerId <const> = source
    local actualTime =  os.time()
    local players = GetPlayers()
    for i=0, #players do
        local time = getTime(players[i])
        playerData[tonumber(players[i])] = playerStatus(players[i], getLicense(players[i]), time, actualTime)
    end
end)