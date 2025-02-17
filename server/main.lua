local QBCore = exports['qb-core']:GetCoreObject()

-- Database initialization
CreateTable = [[
    CREATE TABLE IF NOT EXISTS player_trailers (
        id INTEGER PRIMARY KEY AUTO_INCREMENT,
        citizenid VARCHAR(50),
        trailer VARCHAR(50),
        plate VARCHAR(50),
        stored BOOLEAN DEFAULT 1
    )
]]

MySQL.Sync.execute(CreateTable)

-- Buy trailer
QBCore.Functions.CreateCallback('qb-trailers:server:buyTrailer', function(source, cb, trailerModel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local trailer = nil
    
    for _, v in pairs(Config.Trailers) do
        if v.model == trailerModel then
            trailer = v
            break
        end
    end
    
    if not trailer then
        cb(false, "Invalid trailer model")
        return
    end
    
    if Player.PlayerData.money.cash >= trailer.price then
        Player.Functions.RemoveMoney('cash', trailer.price)
        
        local plate = GeneratePlate()
        MySQL.Async.insert('INSERT INTO player_trailers (citizenid, trailer, plate) VALUES (?, ?, ?)',
            {Player.PlayerData.citizenid, trailer.model, plate},
            function(id)
                if id then
                    cb(true, plate)
                else
                    cb(false, "Database error")
                end
            end
        )
    else
        cb(false, "Not enough money")
    end
end)

QBCore.Functions.CreateCallback('qb-trailers:server:checkTrailerOwnership', function(source, cb, plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    MySQL.Async.fetchAll('SELECT * FROM player_trailers WHERE plate = ? AND citizenid = ?',
        {plate, Player.PlayerData.citizenid},
        function(result)
            cb(result and #result > 0)
        end
    )
end)

RegisterServerEvent('qb-trailers:server:storeTrailer')
AddEventHandler('qb-trailers:server:storeTrailer', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    MySQL.Async.execute('UPDATE player_trailers SET stored = ? WHERE plate = ? AND citizenid = ?',
        {true, plate, Player.PlayerData.citizenid})
end)

-- Modified update trailer status event
RegisterServerEvent('qb-trailers:server:updateTrailerStatus')
AddEventHandler('qb-trailers:server:updateTrailerStatus', function(plate, status)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        print("Updating trailer status - Plate: " .. plate .. ", New Status: " .. tostring(status))
        
        MySQL.Async.execute('UPDATE player_trailers SET stored = ? WHERE plate = ? AND citizenid = ?',
            {status, plate, Player.PlayerData.citizenid},
            function(rowsChanged)
                print("Updated " .. rowsChanged .. " rows in database")
            end
        )
    end
end)

RegisterServerEvent('qb-trailers:server:updateTrailerStatus')
AddEventHandler('qb-trailers:server:updateTrailerStatus', function(plate, status)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        MySQL.Async.execute('UPDATE player_trailers SET stored = ? WHERE plate = ? AND citizenid = ?',
            {status, plate, Player.PlayerData.citizenid},
            function(rowsChanged)
                if rowsChanged > 0 then
                    print("Updated trailer status: " .. plate .. " to " .. status)
                end
            end
        )
    end
end)

-- Modified get trailers callback with additional debug logging
QBCore.Functions.CreateCallback('qb-trailers:server:getTrailers', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        print("Error: Player not found for source " .. source)
        cb({})
        return
    end

    local citizenid = Player.PlayerData.citizenid
    print("Fetching trailers for citizenid: " .. citizenid)

    MySQL.Async.fetchAll('SELECT * FROM player_trailers WHERE citizenid = ?', {citizenid}, 
        function(results)
            print("Found " .. #results .. " trailers for player")
            if results then
                for k, v in pairs(results) do
                    print(string.format("Trailer %d: Model=%s, Plate=%s, Stored=%s", 
                        k, v.trailer, v.plate, tostring(v.stored)))
                end
            end
            cb(results or {})
        end
    )
end)

-- Generate unique plate
function GeneratePlate()
    local plate = "TR"..math.random(10000, 99999)
    -- Add check to ensure plate is unique
    return plate
end