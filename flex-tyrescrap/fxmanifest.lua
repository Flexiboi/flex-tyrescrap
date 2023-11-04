fx_version "bodacious"
game "gta5"
lua54 "yes"

author "flexiboi"
description "Flex-portableworkbench"
version "1.0.0"

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'config.lua',
}

server_scripts {
	'locales/nl.lua',
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
	'locales/nl.lua',
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/CircleZone.lua',
	'client/main.lua',
}

dependencies {
	'qb-core'
}