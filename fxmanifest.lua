fx_version 'cerulean'

game 'gta5'

lua54 'yes'

description 'A scoreboard made for vola'

version '1.0.0'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts{
    '@mysql-async/lib/MySQL.lua',
    'server/classes/player.lua',
    'server/server.lua'
}