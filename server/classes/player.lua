function playerStatus(playerId, identifier, time, actualTime, playerName)
    local self = {}
    self.source = playerId
    self.identifier = identifier
    self.time = tonumber(time)
    self.actualTime = tonumber(actualTime)
    self.name = playerName

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

        this.currentTime = function(currentTime)
            if not currentTime then return false end
            local localTime = tonumber(currentTime - this.total())
            return (localTime + self.time)
        end

        this.displayed = function(currentTime)
            local time = formatTime(this.currentTime(currentTime))
            local minutes = time.minutes
            local hours = time.hours
            return ("%sHRS %sM"):format(hours, minutes)
        end

        return this
    end

    return self
end