# QB Trailers - Advanced Trailer Management System

A comprehensive trailer management system for QB-Core Framework that allows players to buy, store, and park trailers with persistent positioning using AdvancedParking integration.

## Features

- 🚛 Buy various types of trailers from a configured shop
- 🎮 Easy-to-use menu interface for all trailer operations
- 🔐 Secure ownership system with database integration
- 📦 Integration with QB-Inventory for trailer storage
- ⚡ Optimized performance and server sync

## Dependencies

- [QB-Core Framework](https://github.com/qbcore-framework/qb-core)
- [QB-Menu](https://github.com/qbcore-framework/qb-menu)
- [QB-Inventory](https://github.com/qbcore-framework/qb-inventory)
- [OX MySQL](https://github.com/overextended/oxmysql)

## Installation

1. **Download the Resource**
   ```bash
   cd resources
   git clone [repository-url] [qb-trailers]
   ```

2. **Import Database**
   ```sql
   CREATE TABLE IF NOT EXISTS `player_trailers` (
       `id` int(11) NOT NULL AUTO_INCREMENT,
       `citizenid` varchar(50) DEFAULT NULL,
       `trailer` varchar(50) DEFAULT NULL,
       `plate` varchar(50) DEFAULT NULL,
       `stored` boolean DEFAULT TRUE,
       PRIMARY KEY (`id`),
       KEY `citizenid` (`citizenid`),
       KEY `plate` (`plate`)
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
   ```

3. **Install Dependencies**
   - Ensure all required dependencies are installed and up to date
   - Configure AdvancedParking according to their documentation

4. **Resource Configuration**
   - Add to server.cfg:
   ```cfg
   ensure qb-trailers
   ```

## Configuration

Edit the `config.lua` file to customize:

```lua
Config = {
    ShopLocation = vector3(-1731.39, -2898.87, 13.94),
    GarageLocation = vector3(-1741.39, -2908.87, 13.94),
    ParkingRadius = 5.0,
    DetachRadius = 10.0,
    
    Trailers = {
        {
            name = "Boat Trailer",
            model = "boattrailer",
            price = 15000,
            spawnCode = "boattrailer"
        },
        -- Add more trailers as needed
    }
}
```

## Usage

### For Players

1. **Buying a Trailer**
   - Visit the trailer shop location
   - Press `E` to open the shop menu
   - Select and purchase desired trailer

2. **Storing Trailers**
   - Drive to the garage location
   - Detach the trailer
   - Press `E` to open the garage menu
   - Select "Store Nearby Trailer"

3. **Retrieving Trailers**
   - Visit the garage location
   - Press `E` to open the garage menu
   - Select your stored trailer to spawn it
   - For parked trailers, select to view their location

#### Events
```lua
-- Client-side events
TriggerEvent('qb-trailers:client:openShop')
TriggerEvent('qb-trailers:client:openGarage')

-- Server-side events
TriggerServerEvent('qb-trailers:server:purchaseTrailer', model)
TriggerServerEvent('qb-trailers:server:storeTrailer', plate)
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- Author: ScienceDestroy
- Created: 2025-02-17
- Framework: QB-Core

## Support

For support, please:
1. Check existing documentation
2. Review closed issues
3. Open a new issue with detailed information about your problem

## Changelog

### [1.0.0] - 2025-02-17
- Initial release
- Basic trailer management system
- QB-Core framework integration

---
⭐ Found this useful? Drop a star on GitHub!
