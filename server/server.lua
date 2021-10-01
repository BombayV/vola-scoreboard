-- You can add as many groups as u like here
local allGroups = {
    {name = "Superadmin", group = "superadmin"},
    {name = "Admin", group = "admin"},
    {name = "Police", group = "police"},
    {name = "NHS", group = "ambulance"}
}

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

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
            exports['ghmattimysql']:execute('UPDATE time_played SET time=@time WHERE license=@license', {
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
    exports['ghmattimysql']:execute('SELECT time FROM time_played WHERE license = @license', {
        ['license'] = license
    }, function(result)
        if type(next(result)) ~= "nil" then
            return p:resolve({currentTime = result[1].time})
        else
            exports['ghmattimysql']:execute('INSERT INTO time_played (license) VALUES (@license)', {
                ['license'] = license
            })
            return p:resolve({currentTime = 0})
        end
    end)
    local resp = Citizen.Await(p)
    return resp.currentTime
end

local function getStatus(playerId)
    local user_id = vRP.getUserId({playerId})
    local groups = vRP.getUserGroups({user_id})
    if groups then
        for _, v in pairs(allGroups) do
            for k, e in pairs(groups) do
                if v.group == k then
                    return v.name
                end
            end
        end
    end
    return "Civilian"
end

local function getJobs()
    local status = {
        civilian = 0,
        police = 0,
        nhs = 0,
        admin = 0
    }

    for _, v in pairs(GetPlayers()) do
        local user_id = vRP.getUserId({tonumber(v)})
        local groups = vRP.getUserGroups({user_id})
        if groups.admin then
            status.admin = status.admin + 1
        elseif groups.police then
            status.police = status.police + 1
        elseif groups.nhs then
            status.nhs = status.nhs + 1
        elseif groups.civilian then
        status.civilian = status.civilian + 1
        end
    end
    return status
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
    local players = 'Players: ' .. #GetPlayers() .. ' / ' .. GetConvarInt('sv_maxclients', 32)
    local time = os.time()
    local runTime =  playerData[tonumber(source)].Time().displayed(time)
    for k, v in pairs(GetPlayers()) do
        local player = playerData[tonumber(v)]
        local status = getStatus(player.source)
        currentPlayers[k] = {playersId = player.source, playersName = player.getName(), playersTime = player.Time().displayed(time), playersJob = status}
    end
    TriggerClientEvent('vola:updatePlayers', source, currentPlayers, players, runTime, getJobs())
end)

RegisterNetEvent('vola:playerJoined', function()
    local playerId <const> = source
    if getLicense(playerId) then
        local time = getTime(playerId)
        local actualTime = os.time()
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
end, true) -- False, everyone can use it

RegisterCommand('saveScore', function(source)
    local playerId <const> = source
    local player = playerData[playerId]
    if getLicense(playerId) then
        savePlayerData(playerId, time, player)
	end
end)