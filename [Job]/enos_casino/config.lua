Config = {}

--les items au bar
Config.baritem = {
    {nom = "Bira", prix = 2, item = "beer"},   
    {nom = "Whisky", prix = 2, item = "whisky"},   
    {nom = "Vodka", prix = 2, item = "vodka"},       
    {nom = "Ice-tea", prix = 2, item = "icetea"},
    {nom = "Redbul", prix = 2, item = "redbul"},
    {nom = "Tekila", prix = 2, item = "tequila"},	
	{nom = "Şarap", prix = 2, item = "wine"},
	{nom = "Çikolaa", prix = 2, item = "chocolate"},
    {nom = "Coca-Cola", prix = 2, item = "cola"}  
}

Config.pos = {

    blip = { -- position du blips
        position = {x = 923.7822, y = 46.3247, z = 81.10634}
    },

    garage = {
		position = {x = 919.35, y = 40.15, z = 80.89}
	},

    echangejeton = { -- position du change jeton(s)
        position = {x = 1115.70,   y = 219.98,  z = -49.43}
    },

    bar = { -- position du menu coffre
        position = {x = 1110.75, y = 209.42, z = -49.44} 
    },

    coffre = { -- position du menu coffre
		position = {x = 1089.43, y = 221.21, z = -49.20} 
	},

    boss = { -- position du menu boss
        position = {x = 1086.88, y = 221.21, z = -49.20}
    }
}

Config.spawn = {
	spawnvoiture = {
		position = {x = 919.07, y = 46.80, z = 80.76, h = 326.64}
	},
}