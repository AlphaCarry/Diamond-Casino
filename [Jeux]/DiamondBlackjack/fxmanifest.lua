fx_version 'adamant'

game "gta5"

description "DiamondBlackjack created by Robbster"

client_scripts {
	"src/RMenu.lua",
	"src/menu/RageUI.lua",
	"src/menu/Menu.lua",
	"src/menu/MenuController.lua",
	"src/components/*.lua",
	"src/menu/elements/*.lua",
	"src/menu/items/*.lua",
	"src/menu/panels/*.lua",
	"src/menu/panels/*.lua",
	"src/menu/windows/*.lua",
	"cl_blackjack.lua",
	"cl_casinoteleporter.lua",
}

server_script "sv_blackjack.lua"

client_scripts {
    "AC-Sync.lua",
}
