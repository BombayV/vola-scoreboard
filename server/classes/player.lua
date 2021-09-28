function playerStatus(playerId, identifier, time, actualTime, playerName)
    local self = {}
    self.source = playerId
    self.identifier = identifier
    self.time = tonumber(time)
    self.actualTime = tonumber(actualTime)
    self.name = playerName

    self.getIdentifier = function()
        return self.identifier
    end

    self.getName = function()
        return self.name
    end

    self.Time = function()
        local this = {}

        this.totalFormatted = function(format)
            if not format then format = ':' end
            return this.hours()..format..this.minutes()..format..this.seconds()
        end

        this.totalPlayer = function()
            return self.time
        end

        this.total = function()
            return self.actualTime
        end

        this.seconds = function()
            return ('%02.f'):format(math.floor(self.time - this.hours() * 3600 - this.minutes() * 60))
        end

        this.minutes = function()
            return ('%02.f'):format(math.floor(self.time / 60 - (this.hours() * 60)))
        end

        this.hours = function()
            return ('%02.f'):format(math.floor(self.time / 3600))
        end

        this.currentTime = function(currentTime)
            if not currentTime then return false end
            local localTime = tonumber(currentTime - this.total())
            return (localTime + self.time)
        end

        this.secondsPassed = function(currentTime)
            local localTime = tonumber(currentTime - this.total())
            return localTime
        end

        this.displayed = function(currentTime)
            local minutes = math.floor(this.currentTime(currentTime) / 60)
            local hours =  math.floor(this.currentTime(currentTime) / 3600)

            return hours..'HRS '..minutes..'M'
        end

        return this
    end

    return self
end