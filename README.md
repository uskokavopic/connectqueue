CONNECTQUEUE – QUEUE SYSTEM FOR FIVEM

(BODY + DISCORD TIERS + TEBEX QPOINTS + EARNED BODY)

==================================================

DESCRIPTION

CONNECTQUEUE is an advanced queue system for a FiveM server
built on deferrals.

Main goals:

server protection after restart (connect spam)

fair entry using a point system

motivate players to wait in queue

monetization via Discord Tiers and Tebex QPOINTS

Each player in queue has:

PAID points (Tier / Tebex / Manual / Grace)

EARNED points (automatically generated for everyone)

entry is based on TOTAL points

==================================================

HOW POINTS WORK

POINTS ARE MADE FROM 4 PARTS:

1) EARNED POINTS (FREE – every player)

Every player in queue gets points automatically

Example: +100 points every 30 seconds

Applies to EVERYONE (VIP and non-VIP)

2) DISCORD TIERS (subscription roles)

Tier roles on Discord

Each role has assigned points

Script always uses the HIGHEST tier

Example:
Tier1 = 3000
Tier2 = 5000
Tier3 = 7000
Tier4 = 10000

3) TEBEX QPOINTS (no role required)

Points purchased via Tebex

Stored in database

STACKABLE (example: 10000 + 7000 = 17000)

Have expiration (default 30 days)

4) GRACE POINTS

Temporary mega points after crash / reload

Protects players after game crash

Duration is configurable (example: 120 seconds)

TOTAL POINTS:
TOTAL = EARNED + PAID

Player can join server when:
TOTAL >= MinJoinPoints

==================================================

MAIN FEATURES

Queue when server is full (deferrals)

Shows:

queue position

waiting time

Earned points

Paid points

Total / Required

Anti connect-spam protection via point system

Earned points for EVERY player

Discord Tier roles (subscription)

Tebex QPOINTS without role (DB, stacking, expiration)

Priority system (VIP/Admin queue order)

Reserved slots (optional)

Grace time after crash

Anti-spam connection delay

Automatic queue count in server name

Clickable buttons in queue:

Tebex

Discord

Shop

==================================================

REQUIREMENTS

FiveM server

oxmysql (required for Tebex QPOINTS)

Discord bot + Bot Token (if using Discord Tiers)

Player Discord identifier (discord:xxxx)
if Config.RequireDiscord = true

==================================================

STARTING (server.cfg)

ensure oxmysql
ensure connectqueue

set sv_maxclients ""
set sv_debugqueue "false"
set sv_displayqueue "true"

allow admins to add QPOINTS

add_ace group.admin queue.addpoints allow

==================================================

DATABASE

Run SQL script:
sql/queue_qpoints.sql

Table:
queue_qpoints

identifier (PRIMARY KEY, e.g. discord:123456...)

points

expires_at (unix timestamp)

==================================================

RESOURCE STRUCTURE

connectqueue
├── fxmanifest.lua
├── config.lua
├── sql
│ └── queue_qpoints.sql
├── client
│ └── client.lua
└── server
└── server.lua

==================================================

INSTALLATION

Copy connectqueue folder into:
resources/

Run SQL script:
sql/queue_qpoints.sql

Add to server.cfg:
ensure oxmysql
ensure connectqueue

Restart server

==================================================

CONFIGURATION (config.lua)
1) EARNED POINTS (FREE)

Config.EarnInterval = 30 -- every 30 seconds
Config.EarnAmount = 100 -- +100 points
Config.MaxEarnedPoints = 3000 -- max earned (0 = unlimited)

2) REQUIRED POINTS (ANTI-SPAM)

Config.MinJoinPoints = 3000

Player must have at least this amount to join.

3) DISCORD TIERS

Config.RequireDiscord = true
Config.Discord.Enabled = true

Config.Discord.GuildId = "DISCORD_SERVER_ID"
Config.Discord.BotToken = "BOT_TOKEN"

Config.Discord.RolePoints = {
["ROLE_ID_TIER1"] = 3000,
["ROLE_ID_TIER2"] = 5000,
["ROLE_ID_TIER3"] = 7000,
["ROLE_ID_TIER4"] = 10000,
}

4) TEBEX QPOINTS

Config.QPoints.Enabled = true
Config.QPoints.UseIdentifier = "discord"
Config.QPoints.DefaultDurationDays = 30

Command:
queue_addpoints discord:123456789012345678 10000 30

5) PRIORITY (queue order)

Config.Priority = {
["discord:123456789012345678"] = 50
}

Higher number = higher queue priority.

6) RESERVED SLOTS

Config.ReservedSlots = 2
Config.ReservedMinPriority = 50

7) GRACE TIME

Config.GraceBoost.Enabled = true
Config.GraceBoost.DurationSeconds = 120
Config.GraceBoost.Points = 2000000

==================================================

ADMIN / COMMANDS

Add QPOINTS (Tebex / console / admin):

queue_addpoints discord:123456789012345678 7000 30

==================================================

NOTES

Recommended to enable OneSync

Not recommended to use with hardcap resource

Discord API is cached (prevents spam requests)

Suitable for RP and PVE servers

Earned points are added to EVERY player in queue

==================================================

END README
