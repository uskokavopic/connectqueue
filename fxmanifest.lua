fx_version 'cerulean'
game 'gta5'

author 'Uskokavopic'
description 'Queue + Points + Discord Tiers + Tebex QPoints + Schedule'
version '1.0.0'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

shared_script 'config.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

client_script 'client/client.lua'
