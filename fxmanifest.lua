fx_version 'cerulean'
game 'gta5'

author 'Uskokavopic'
description 'Queue + points + Discord tiers + Tebex QPoints + schedule'
version '1.0.0'

shared_script 'config.lua'

-- oxmysql lib MUST be loaded before server.lua
server_script '@oxmysql/lib/MySQL.lua'
server_script 'server/server.lua'

client_script 'client/client.lua'
