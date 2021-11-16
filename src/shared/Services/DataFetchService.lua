--// System
local DataS = game:GetService("DataStoreService")
local StatStore = DataS:GetDataStore("StatStore")


--// Void
local Void = require(game.ReplicatedStorage.Void)
local Promise = require(Void.Util.Promise)
local DataFetchService = Void.CreateService{Name = "DataFetchService", Client = {}}

--//DBTable
local DBTable = {}

--// Supporting Functions

local function fetchValue(index)
    return Promise.new(function(Resolve, Reject, onCancel)
        
        local value

        local success, msg= pcall(function()
            value = StatStore:GetAsync(index)
        end)

        if success then
            print("Data Fetch Successful! :",value)
            Resolve(value)
        else
            Reject(value)
        end

    end)
end

local function setValue(index, value, isLocalSave)
    return Promise.new(function(Resolve, Reject, onCancel)

        local success, errorMessage = pcall(function()
            StatStore:SetAsync(index, value)
        end)

        if success then
            print("Data Set Successful! :",value)
            Resolve(value)
        else
            Reject(errorMessage)
        end

    end)
end

--// Main Functions
function DataFetchService:SetPlayerStat(plr, value, isLocal)
    return 
    Promise.retry(setValue, 5, plr.UserId, value)
    :catch(function(err)
        print("Data Set Failed! Error :",err) 
    end)
end

function DataFetchService:GetPlayerStat(plr)
    print("Trying to Fetch Stats for",plr.Name)
    return 
    Promise.retry(fetchValue, 5, plr.UserId)
    :catch(function(err)
        print("Data Fetch Failed! Error :",err) 
    end)
end

function DataFetchService:HandleLeavingPlayers(plr)
    setValue(plr.UserId, DBTable[plr.UserId], false)
end

--// Return
return DataFetchService