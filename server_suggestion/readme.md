# Server Suggestion (Alias FeedHook) (1.1)
This mod adds a new /suggestion command that sends this suggestion directly to discord with a webhook

# Features
- Send In-Game suggestions from players to discord with a webhook
- A 300 second cooldown is integrated between each use of the command to avoid unwanted spam from players
- Message sanitization to prevent mention abuse like @everyone or @here on discord

# Commands
`/suggestion <message>`: Send a suggestion message in a discord room defined with the webhook
Players without `shout` privs won't be able to execute the command

Example: `/suggestion Add a new sprint mod to the server, the one that we have is full of bugs!`

# Configuration
You can customize the message validation rules by modifying the value in the settings:
`maximum_characters`: Maximum length per suggestion (500) -- Helps avoid massive messages spam
`minimum_characters`: Minimum message per suggestion (25) -- Helps avoid small/unnecessary messages

# Installation / Requirements
1. Place the mod in your server mods file (`mods` or `worldmods`)
2. Add it to your `secure.http_mods` setting (conf)
3. Install aiohttp: `sudo apt install aiohttp`
4. Configure your discord webhook Url in the mod setting
5. Restart the server

# Warning / License
> This mod is distributed under the Creative Commons Attribution - NonCommercial - ShareAlike 4.0 International license.
Commercial use is prohibited.
No warranty is given as to the functionality or suitability of the mod in any particular environment.
Use at user's own risk.
See license.txt for full license information.
