Config = {}

-- Trailer Shop Location
Config.ShopLocation = vector3(-1731.39, -2898.87, 13.94) -- Change this to your desired location
Config.ShopBlipSettings = {
    sprite = 479,
    display = 4,
    scale = 0.7,
    color = 2,
    title = "Trailer Shop"
}

-- Trailer Garage Location
Config.GarageLocation = vector3(-1741.39, -2908.87, 13.94) -- Change this to your desired location
Config.GarageBlipSettings = {
    sprite = 524,
    display = 4,
    scale = 0.7,
    color = 3,
    title = "Trailer Garage"
}

-- Available Trailers
Config.Trailers = {
    {
        name = "Boat Trailer",
        model = "boattrailer",
        price = 15000,
        spawnCode = "boattrailer"
    },
    {
        name = "Car Trailer",
        model = "trailersmall",
        price = 20000,
        spawnCode = "trailersmall"
    },
    {
        name = "Large Trailer",
        model = "trailerlogs",
        price = 35000,
        spawnCode = "trailerlogs"
    },
}

-- Parking Settings
Config.ParkingRadius = 5.0 -- How close player needs to be to park trailer
Config.DetachRadius = 10.0 -- Maximum distance between vehicle and trailer when parking