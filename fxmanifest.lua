fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'FiveM Vehicle Lock Script - Auto mit Datenbank abschließen'
version '1.0.0'

lua54 'yes'

client_scripts {
    'client/main.lua',
    'client/lock.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

ui_page 'html/index.html'
