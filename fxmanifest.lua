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

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/fonts/*.ttf',
    'html/css/*.css',
    'html/img/*.png',
    'html/js/*.js'
}