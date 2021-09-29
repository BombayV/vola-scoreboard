-- All players
local playerData = {}

-- Functions
local function getLicense(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)

    for _, v in pairs(identifiers) do
        if string.match(v, 'license:') then
            return v
        end
    end
    return false
end

local function savePlayerData(playerId, time, player)
    if playerId then
        if player then
            if not time then time = os.time() end
            MySQL.Async.execute('UPDATE time_played SET time=@time WHERE license=@license', {
                ['license'] = player.identifier,
                ['time'] = player.Time().currentTime(time)
            }, function(result)
                if not result then
                    print(GetCurrentResourceName()..': Error saving data for player ' .. tostring(playerId))
                end
            end)
        end
    end
end

local function getTime(playerId)
    local p = promise.new()
    local license = getLicense(playerId)
    MySQL.Async.fetchScalar('SELECT time FROM time_played WHERE license = @license', {
        ['license'] = license
    }, function(result)
        if result then
            return p:resolve({currentTime = result})
        else
            MySQL.Async.execute('INSERT INTO time_played (license) VALUES (@license)', {
                ['license'] = license
            })
            return p:resolve({currentTime = 0})
        end
    end)
    local resp = Citizen.Await(p)
    return resp.currentTime
end

function formatTime(seconds)
    if not seconds then return 0 end
    local status = {
        hours = 0,
        minutes = 0
    }
    status.hours = ("%02.f"):format(math.floor(seconds / 3600))
    status.minutes = ("%02.f"):format(math.floor(seconds / 60 - (status.hours * 60)))
    return status
end

-- Events
RegisterNetEvent('vola:getPlayers', function()
    local source <const> = source
    if not playerData[source] then
        return print('Scoreboard needs to be refreshed. Tell an admin to use /restartScoreboard')
    end
    local currentPlayers = {}
    local time = os.time()
    for _, v in pairs(GetPlayers()) do
        local player = playerData[tonumber(v)]
        currentPlayers[v] = {playersName = player.getName(), playersTime = player.Time().displayed(time)}
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

-- Save player on drop
AddEventHandler('playerDropped', function()
	local playerId <const> = source
	local player = playerData[playerId]
    local time = os.time()

	if player then
        savePlayerData(playerId, time, player)
		playerData[tonumber(playerId)] = nil
	end
end)

-- Command
RegisterCommand('restartScoreboard', function(source)
    local playerId <const> = source
    local actualTime =  os.time()
    local players = GetPlayers()
    for i=0, #players do
        local time = getTime(players[i])
        playerData[tonumber(players[i])] = playerStatus(players[i], getLicense(players[i]), time, actualTime)
    end
end, false) -- False, everyone can use it

RegisterCommand('saveScore', function(source)
    local playerId <const> = source
    local player = playerData[playerId]
    if getLicense(playerId) then
        savePlayerData(playerId, time, player)
	end
end)