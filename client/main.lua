local QBCore = exports['qb-core']:GetCoreObject()
local currentTrailer = nil
local isMenuOpen = false

-- Create Blips
CreateThread(function()
    -- Shop Blip
    local shopBlip = AddBlipForCoord(Config.ShopLocation.x, Config.ShopLocation.y, Config.ShopLocation.z)
    SetBlipSprite(shopBlip, Config.ShopBlipSettings.sprite)
    SetBlipDisplay(shopBlip, Config.ShopBlipSettings.display)
    SetBlipScale(shopBlip, Config.ShopBlipSettings.scale)
    SetBlipColour(shopBlip, Config.ShopBlipSettings.color)
    SetBlipAsShortRange(shopBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.ShopBlipSettings.title)
    EndTextCommandSetBlipName(shopBlip)
    
    -- Garage Blip
    local garageBlip = AddBlipForCoord(Config.GarageLocation.x, Config.GarageLocation.y, Config.GarageLocation.z)
    SetBlipSprite(garageBlip, Config.GarageBlipSettings.sprite)
    SetBlipDisplay(garageBlip, Config.GarageBlipSettings.display)
    SetBlipScale(garageBlip, Config.GarageBlipSettings.scale)
    SetBlipColour(garageBlip, Config.GarageBlipSettings.color)
    SetBlipAsShortRange(garageBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.GarageBlipSettings.title)
    EndTextCommandSetBlipName(garageBlip)
end)

-- Shop Menu
RegisterNetEvent('qb-trailers:client:openShop')
AddEventHandler('qb-trailers:client:openShop', function()
    local ShopMenu = {
        {
            header = "Trailer Shop",
            isMenuHeader = true
        }
    }
    
    for _, trailer in pairs(Config.Trailers) do
        ShopMenu[#ShopMenu+1] = {
            header = trailer.name,
            txt = "Price: $"..trailer.price,
            params = {
                event = "qb-trailers:client:buyTrailer",
                args = {
                    model = trailer.model
                }
            }
        }
    end
    
    exports['qb-menu']:openMenu(ShopMenu)
end)

-- Buy Trailer
RegisterNetEvent('qb-trailers:client:buyTrailer')
AddEventHandler('qb-trailers:client:buyTrailer', function(data)
    QBCore.Functions.TriggerCallback('qb-trailers:server:buyTrailer', function(success, message)
        if success then
            QBCore.Functions.Notify('Successfully purchased trailer!', 'success')
            -- Spawn the trailer here
            SpawnTrailer(data.model, message)
        else
            QBCore.Functions.Notify(message, 'error')
        end
    end, data.model)
end)

-- Spawn Trailer Function
function SpawnTrailer(model, plate)
    local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, 0.0)
    QBCore.Functions.SpawnVehicle(model, function(vehicle)
        SetVehicleNumberPlateText(vehicle, plate)
        SetEntityAsMissionEntity(vehicle, true, true)
        currentTrailer = vehicle
    end, coords, true)
end

-- Modified Store Trailer function to show notification if no trailer is found
-- Modified Store Trailer function to handle parked status
RegisterNetEvent('qb-trailers:client:storeTrailer')
AddEventHandler('qb-trailers:client:storeTrailer', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local vehicles = QBCore.Functions.GetVehicles()
    local trailerFound = false
    
    for _, vehicle in pairs(vehicles) do
        if DoesEntityExist(vehicle) and GetEntityType(vehicle) == 2 then
            local vehicleClass = GetVehicleClass(vehicle)
            if vehicleClass == 11 then
                local trailerCoords = GetEntityCoords(vehicle)
                local distance = #(coords - trailerCoords)
                
                if distance < Config.ParkingRadius then
                    if IsEntityAttachedToAnyVehicle(vehicle) then
                        QBCore.Functions.Notify('Please detach the trailer first!', 'error')
                        trailerFound = true
                        break
                    else
                        local plate = GetVehicleNumberPlateText(vehicle)
                        QBCore.Functions.TriggerCallback('qb-trailers:server:checkTrailerOwnership', function(owned)
                            if owned then
                                -- Let player choose to store or park
                                exports['qb-menu']:openMenu({
                                    {
                                        header = "Trailer Storage Options",
                                        txt = "Choose how to store your trailer",
                                        isMenuHeader = true
                                    },
                                    {
                                        header = "Store in Garage",
                                        txt = "Store your trailer in the garage (can be retrieved later)",
                                        params = {
                                            event = "qb-trailers:client:confirmStore",
                                            args = {
                                                vehicle = vehicle,
                                                plate = plate,
                                                stored = true
                                            }
                                        }
                                    },
                                    -- {
                                    --     header = "Park Here",
                                    --     txt = "Park your trailer at this location",
                                    --     params = {
                                    --         event = "qb-trailers:client:confirmStore",
                                    --         args = {
                                    --             vehicle = vehicle,
                                    --             plate = plate,
                                    --             stored = false
                                    --         }
                                    --     }
                                    -- }
                                })
                            else
                                QBCore.Functions.Notify('You don\'t own this trailer!', 'error')
                            end
                        end, plate)
                        trailerFound = true
                        break
                    end
                end
            end
        end
    end
    
    if not trailerFound then
        QBCore.Functions.Notify('No trailer found nearby!', 'error')
    end
end)

-- Add new event for confirming storage option
RegisterNetEvent('qb-trailers:client:confirmStore')
AddEventHandler('qb-trailers:client:confirmStore', function(data)
    if data.stored then
        -- Store in garage
        TriggerServerEvent('qb-trailers:server:storeTrailer', data.plate)
        DeleteEntity(data.vehicle)
        QBCore.Functions.Notify('Trailer stored in garage!', 'success')
    else
        -- Park at location
        TriggerServerEvent('qb-trailers:server:parkTrailer', data.plate)
        QBCore.Functions.Notify('Trailer parked at this location!', 'success')
    end
end)


-- Modified garage menu with fixed event handling
RegisterNetEvent('qb-trailers:client:openGarage')
AddEventHandler('qb-trailers:client:openGarage', function()
    QBCore.Functions.TriggerCallback('qb-trailers:server:getTrailers', function(trailers)
        print("Opening garage menu with " .. #trailers .. " trailers") -- Debug log
        
        local GarageMenu = {
            {
                header = "🚛 Trailer Garage",
                isMenuHeader = true
            },
            {
                header = "💾 Store Nearby Trailer",
                txt = "Store your detached trailer",
                params = {
                    isServer = false,
                    event = "qb-trailers:client:storeTrailer"
                }
            }
        }

        if trailers and #trailers > 0 then
            -- Add stored trailers section
            local hasStoredTrailers = false
            local hasParkedTrailers = false

            for _, trailer in pairs(trailers) do
                local isStored = trailer.stored
                if type(isStored) == "string" then
                    isStored = isStored:lower() == "true" or isStored == "1"
                elseif type(isStored) == "number" then
                    isStored = isStored == 1
                end

                print("Processing trailer: " .. trailer.plate .. " - Stored: " .. tostring(isStored)) -- Debug log

                if isStored then
                    if not hasStoredTrailers then
                        GarageMenu[#GarageMenu+1] = {
                            header = "📍 Stored Trailers",
                            txt = "Trailers in storage",
                            isMenuHeader = true
                        }
                        hasStoredTrailers = true
                    end

                    local trailerName = GetTrailerNameByModel(trailer.trailer)
                    GarageMenu[#GarageMenu+1] = {
                        header = "🚛 " .. trailerName,
                        txt = "📝 Plate: " .. trailer.plate .. " (In Storage)",
                        params = {
                            isServer = false,
                            event = "qb-trailers:client:retrieveTrailer",
                            args = {
                                model = trailer.trailer,
                                plate = trailer.plate,
                                status = "stored"
                            }
                        }
                    }
                -- else
                --     if not hasParkedTrailers then
                --         GarageMenu[#GarageMenu+1] = {
                --             header = "🅿️ Parked Trailers",
                --             txt = "Trailers parked in the world",
                --             isMenuHeader = true
                --         }
                --         hasParkedTrailers = true
                --     end

                --     local trailerName = GetTrailerNameByModel(trailer.trailer)
                --     GarageMenu[#GarageMenu+1] = {
                --         header = "🚛 " .. trailerName,
                --         txt = "📝 Plate: " .. trailer.plate .. " (Parked)",
                --         params = {
                --             isServer = false,
                --             event = "qb-trailers:client:locateParkedTrailer",
                --             args = {
                --                 model = trailer.trailer,
                --                 plate = trailer.plate
                --             }
                --         }
                --     }
                end
            end
        else
            GarageMenu[#GarageMenu+1] = {
                header = "No Trailers Found",
                txt = "Purchase a trailer from the trailer shop!",
                isMenuHeader = true
            }
        end

        exports['qb-menu']:openMenu(GarageMenu)
    end)
end)

-- Modified retrieve trailer event with debug logging
RegisterNetEvent('qb-trailers:client:retrieveTrailer')
AddEventHandler('qb-trailers:client:retrieveTrailer', function(data)
    print("Retrieving trailer: " .. json.encode(data)) -- Debug log
    
    -- Check if we're too close to other vehicles
    local playerPed = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 8.0, 0.0)
    
    -- Check for vehicles in spawn area
    local clearArea = true
    local vehicles = QBCore.Functions.GetVehicles()
    for _, vehicle in pairs(vehicles) do
        local vehCoords = GetEntityCoords(vehicle)
        if #(coords - vehCoords) < 5.0 then
            clearArea = false
            break
        end
    end
    
    if not clearArea then
        QBCore.Functions.Notify('Spawn area is blocked by another vehicle!', 'error')
        return
    end

    QBCore.Functions.SpawnVehicle(data.model, function(vehicle)
        SetVehicleNumberPlateText(vehicle, data.plate)
        SetEntityAsMissionEntity(vehicle, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", data.plate)
        
        -- Update stored status in database
        TriggerServerEvent('qb-trailers:server:updateTrailerStatus', data.plate, 0)
        QBCore.Functions.Notify('Trailer retrieved successfully!', 'success')
        
        print("Trailer spawned successfully: " .. data.plate) -- Debug log
    end, coords, true)
end)

-- Add new event for locating parked trailers
RegisterNetEvent('qb-trailers:client:locateParkedTrailer')
AddEventHandler('qb-trailers:client:locateParkedTrailer', function(data)
    -- First check if the trailer already exists in the world
    local found = false
    local vehicles = QBCore.Functions.GetVehicles()
    
    for _, vehicle in pairs(vehicles) do
        if DoesEntityExist(vehicle) and GetEntityType(vehicle) == 2 then
            local vehicleClass = GetVehicleClass(vehicle)
            if vehicleClass == 11 then -- Trailer class
                local plate = GetVehicleNumberPlateText(vehicle)
                if plate == data.plate then
                    found = true
                    -- Create a waypoint to the trailer
                    local coords = GetEntityCoords(vehicle)
                    SetNewWaypoint(coords.x, coords.y)
                    QBCore.Functions.Notify('Waypoint set to your parked trailer!', 'success')
                    break
                end
            end
        end
    end

    if not found then
        -- If trailer not found in world, ask if player wants to spawn it
        exports['qb-menu']:openMenu({
            {
                header = "Trailer Not Found",
                txt = "Your trailer is not in the world. Would you like to spawn it?",
                isMenuHeader = true
            },
            {
                header = "Spawn Trailer",
                txt = "Spawn your trailer at your location",
                params = {
                    event = "qb-trailers:client:spawnParkedTrailer",
                    args = {
                        model = data.model,
                        plate = data.plate
                    }
                }
            },
            {
                header = "← Go Back",
                txt = "Return to garage menu",
                params = {
                    event = "qb-trailers:client:openGarage"
                }
            }
        })
    end
end)

-- Add new event for spawning parked trailers
RegisterNetEvent('qb-trailers:client:spawnParkedTrailer')
AddEventHandler('qb-trailers:client:spawnParkedTrailer', function(data)
    local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, 0.0)
    
    QBCore.Functions.SpawnVehicle(data.model, function(vehicle)
        SetVehicleNumberPlateText(vehicle, data.plate)
        SetEntityAsMissionEntity(vehicle, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", data.plate)
        -- Keep the stored status as false since it's spawned as parked
        QBCore.Functions.Notify('Trailer spawned successfully!', 'success')
    end, coords, true)
end)



-- Helper function to get trailer name
function GetTrailerNameByModel(model)
    for _, trailer in pairs(Config.Trailers) do
        if trailer.model == model then
            return trailer.name
        end
    end
    return "Unknown Trailer"
end

-- Check for shop and garage zones
CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local shopDist = #(coords - Config.ShopLocation)
        local garageDist = #(coords - Config.GarageLocation)
        
        if shopDist < 3.0 then
            DrawText3D(Config.ShopLocation.x, Config.ShopLocation.y, Config.ShopLocation.z, '[E] Open Trailer Shop')
            if IsControlJustReleased(0, 38) then -- E key
                TriggerEvent('qb-trailers:client:openShop')
            end
        end
        
        if garageDist < 3.0 then
            DrawText3D(Config.GarageLocation.x, Config.GarageLocation.y, Config.GarageLocation.z, '[E] Open Trailer Garage')
            if IsControlJustReleased(0, 38) then -- E key
                TriggerEvent('qb-trailers:client:openGarage')
            end
        end
    end
end)

-- Add temporary debug command
RegisterCommand('debugtrailer', function()
    print("Debug: Current location - " .. json.encode(GetEntityCoords(PlayerPedId())))
    QBCore.Functions.TriggerCallback('qb-trailers:server:getTrailers', function(trailers)
        print("Debug: Available trailers - " .. json.encode(trailers))
    end)
end)

-- 3D Text Function
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end