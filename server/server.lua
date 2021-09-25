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
    local currentPlayers = {}
    local time = os.time()
    for _, v in pairs(GetPlayers()) do
        local player = playerData[tonumber(v)]
        currentPlayers[v] = {playersName = player.getName(), playersStatus = 'Police', playersTime = player.getTime().displayed(time)}
    end
    TriggerClientEvent('vola:updatePlayers', source, currentPlayers)
end)

AddEventHandler('playerConnecting', function()
    local playerId <const> = source
    if getLicense(source) then
        getTime(playerId)
    end
end)

AddEventHandler('playerDropped', function()
	local playerId <const> = source
	local player = playerData[playerId]

	if player then
		playerData[tonumber(playerId)] = nil
	end
end)

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

RegisterCommand('a', function(source)
    local a = os.time()
    print(playerData[source].getTime().totalFormatted())
end)

RegisterCommand('refreshData', function(source)
    local playerId <const> = source
    local time = getTime(playerId)
    local actualTime =  os.time()
    playerData[tonumber(playerId)] = playerStatus(playerId, getLicense(playerId), time, actualTime)
end)