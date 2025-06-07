fx_version 'cerulean'
game 'gta5'

author 'Randolio'
description 'Paycheck System (Updated to use interact system)'

shared_scripts {
    '@ox_lib/init.lua', -- still needed for lib.callback, lib.points, lib.input, etc.
    'config.lua'
}

client_scripts {
    'bridge/client/**.lua',
    'cl_paycheck.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server/**.lua',
    'sv_paycheck.lua'
}

dependencies {
    'qb-core',
    'oxmysql',
    'ox_lib',
    'qb-menu',
    'qb-input',
    'progressbar', 
    'interact'
}

lua54 'yes'
