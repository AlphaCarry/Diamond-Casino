ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.pos.blip.position.x, Config.pos.blip.position.y, Config.pos.blip.position.z)
    SetBlipAsShortRange(blip, true)
    SetBlipSprite(blip, 617)
    SetBlipColour(blip, 3)
    SetBlipScale(blip, 0.6)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName("Diamond Casino")
    EndTextCommandSetBlipName(blip)
end)

local Items = {}      -- Oyuncunun sahip olduğu eşya (arama sırasında doldurulur)
local Armes = {}    -- Oyuncunun sahip olduğu silahlar (arama sırasında yeniden doldurulur)
local ArgentSale = {}  -- Oyuncunun sahip olduğu kirli para (arama sırasında dolar)
local ArgentCash = {}
local IsHandcuffed, DragStatus = false, {}
DragStatus.IsDragged          = false

local PlayerData = {}

local function MarquerJoueur()
	local ped = GetPlayerPed(ESX.Game.GetClosestPlayer())
	local pos = GetEntityCoords(ped)
	local target, distance = ESX.Game.GetClosestPlayer()
	if distance <= 4.0 then
	DrawMarker(2, pos.x, pos.y, pos.z+1.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 255, 0, 170, 0, 1, 2, 1, nil, nil, 0)
end
end


local function getPlayerInv(player)
Items = {}
Armes = {}
ArgentSale = {}
ArgentCash = {}

ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
	for i=1, #data.accounts, 1 do
		if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
			table.insert(ArgentSale, {
				label    = ESX.Math.Round(data.accounts[i].money),
				value    = 'black_money',
				itemType = 'item_account',
				amount   = data.accounts[i].money
			})

			break
		end
	end

	for i=1, #data.weapons, 1 do
		table.insert(Armes, {
			label    = ESX.GetWeaponLabel(data.weapons[i].name),
			value    = data.weapons[i].name,
			right    = data.weapons[i].ammo,
			itemType = 'item_weapon',
			amount   = data.weapons[i].ammo
		})
	end

	for i=1, #data.inventory, 1 do
		if data.inventory[i].count > 0 then
			table.insert(Items, {
				label    = data.inventory[i].label,
				right    = data.inventory[i].count,
				value    = data.inventory[i].name,
				itemType = 'item_standard',
				amount   = data.inventory[i].count
			})
		end
	end
end, GetPlayerServerId(player))
end

local societycasinomoney = nil

menuf7tahbg = false
RMenu.Add('Casinof6', 'main', RageUI.CreateMenu("Casino", "Etkileşime Geç"))
RMenu.Add('Casinof6', 'fouiller', RageUI.CreateMenu("Casino", "Etkileşime Geç"))
RMenu:Get('Casinof6', 'main').Closed = function()
    menuf7tahbg = false
end

function menuf7()
    if not menuf7tahbg then
        menuf7tahbg = true
        RageUI.Visible(RMenu:Get('Casinof6', 'main'), true)
    while menuf7tahbg do
        RageUI.IsVisible(RMenu:Get('Casinof6', 'main'), true, true, true, function()
        	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			RageUI.ButtonWithStyle('Kişiyi ara', nil, {RightLabel = "→"}, closestPlayer ~= -1 and closestDistance <= 3.0, function(_, a, s)
				if a then
					MarquerJoueur()
					if s then
					getPlayerInv(closestPlayer)
					ExecuteCommand("me fouille l'individu")
				end
			end
			end, RMenu:Get('Casinof6', 'fouiller'))
            RageUI.ButtonWithStyle("fatura ver",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local player, distance = ESX.Game.GetClosestPlayer()
                    local amount = KeyboardInput("Miktar", "", 9)
                    amount = tonumber(amount)
                    if player ~= -1 and distance <= 3.0 then
                    if amount == nil then
                        ESX.ShowNotification("~r~Problèmes~s~: Geçersiz Miktar")
                    else
                        TaskStartScenarioInPlace(PlayerPedId(), 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
                        Wait(5000)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_casino', ('casino'), amount)
                        Wait(100)
                        ESX.ShowNotification("~r~Fatura Gönderildi/Kesildi")
                      end
                    else
                      ESX.ShowNotification("~r~Problèmes~s~: Yakınında kimse yok")
                    end
                end
            end)
    
            RageUI.ButtonWithStyle("Annonces d'ouverture",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then       
                    TriggerServerEvent('CasinoOuvert')
                end
            end)
    
            RageUI.ButtonWithStyle("Annonces de fermeture",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then      
                    TriggerServerEvent('CasinoFermer')
                end
            end)
        end, function()
        end)
        RageUI.IsVisible(RMenu:Get("Casinof6",'fouiller'),true,true,true,function() -- Arama menüsü (pz_core / Modified'den esinlenilmiştir)
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            RageUI.Separator("↓ ~g~Argent Sale ~s~↓")
            for k,v  in pairs(ArgentSale) do
                RageUI.ButtonWithStyle("Argent sale :", nil, {RightLabel = "~g~"..v.label.."$"}, true, function(_, _, s)
                    if s then
                        local combien = KeyboardInput("Combien ?", '' , '', 8)
                        if tonumber(combien) > v.amount then
                            RageUI.Popup({message = "Geçersiz miktar"})
                        else
                            TriggerServerEvent('enos:confiscatePlayerItem', GetPlayerServerId(closestPlayer), v.itemType, v.value, tonumber(combien))
                        end
                        RageUI.GoBack()
                    end
                end)
            end
            RageUI.Separator("↓ ~g~Objets ~s~↓")
            for k,v  in pairs(Items) do
                RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "~g~x"..v.right}, true, function(_, _, s)
                    if s then
                        local combien = KeyboardInput("Combien ?", '' , '', 8)
                        if tonumber(combien) > v.amount then
                            RageUI.Popup({message = "Geçersiz miktar"})
                        else
                            TriggerServerEvent('enos:confiscatePlayerItem', GetPlayerServerId(closestPlayer), v.itemType, v.value, tonumber(combien))
                        end
                        RageUI.GoBack()
                    end
                end)
            end
                RageUI.Separator("↓ ~g~Armes ~s~↓")
                for k,v  in pairs(Armes) do
                    RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "avec ~g~"..v.right.. " ~s~balle(s)"}, true, function(_, _, s)
                        if s then
                            local combien = KeyboardInput("Combien ?", '' , '', 8)
                            if tonumber(combien) > v.amount then
                                RageUI.Popup({message = "Geçersiz miktar"})
                            else
                                TriggerServerEvent('enos:confiscatePlayerItem', GetPlayerServerId(closestPlayer), v.itemType, v.value, tonumber(combien))
                            end
                            RageUI.GoBack()
                        end
                    end)
                end
            end, function() 
            end)
            Wait(0)
        end
    else
        menuf7tahbg = false
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'vendeur' then 
            if IsControlJustPressed(0, 167) then
                menuf7()
            end
        end 
    end
end)

-----------------------------------------------------------------------------

-------garage

garagebrrr = false

RMenu.Add('garage', 'main', RageUI.CreateMenu("Garage", "Casino"))
RMenu:Get('garage', 'main').Closed = function()
    garagebrrr = false
end

function garageenos()
    if not garagebrrr then
        garagebrrr = true
        RageUI.Visible(RMenu:Get('garage', 'main'), true)
    while garagebrrr do
        RageUI.IsVisible(RMenu:Get('garage', 'main'), true, true, true, function() 
            RageUI.ButtonWithStyle("arabayı park et", "Arabayı koy.", {RightLabel = "→→"},true, function(Hovered, Active, Selected)
            if (Selected) then   
            local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
            if dist4 < 4 then
                TriggerServerEvent('ddx_vehiclelock:deletekeyjobs', 'no')
                DeleteEntity(veh)
                end 
            end
        end) 
        RageUI.ButtonWithStyle("Baller", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
            if (Selected) then
            Wait(1)  
            spawnCar('baller6')
            end
        end)
        RageUI.ButtonWithStyle("Cognoscenti", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
            if (Selected) then
            Wait(1)  
            spawnCar("cognoscenti")
            end
        end)
        RageUI.ButtonWithStyle("Superd", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
            if (Selected) then
            Wait(1)  
            spawnCar("superd")
            end
        end)
        end, function()
        end)
        Wait(0)
        end
    else
    garagebrrr = false
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
            local plyCoords3 = GetEntityCoords(PlayerPedId(), false)
            local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.garage.position.x, Config.pos.garage.position.y, Config.pos.garage.position.z)
                if ESX.PlayerData.job and ESX.PlayerData.job.name == 'casino' or ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'casino' then 
                if dist3 <= 15.0 then
                DrawMarker(6,  Config.pos.garage.position.x, Config.pos.garage.position.y, Config.pos.garage.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 255, 255, 255 , 155)
                end
                if dist3 <= 3.0 then  
                ESX.ShowHelpNotification("Tıkla ve [~b~E~w~] garaja gir")
                if IsControlJustPressed(1,51) then           
                    garageenos()
                end   
            end
        end 
    end
end)

function spawnCar(car)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Wait(0)
    end
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local vehicle = CreateVehicle(car, Config.spawn.spawnvoiture.position.x, Config.spawn.spawnvoiture.position.y, Config.spawn.spawnvoiture.position.z, Config.spawn.spawnvoiture.position.h, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleMaxMods(vehicle)
    SetPedIntoVehicle(PlayerPedId(),vehicle,-1) 
    TriggerServerEvent('ddx_vehiclelock:givekey', 'no', GetVehicleNumberPlateText(vehicle))
end

function SetVehicleMaxMods(vehicle)
    local props = {
      modEngine       = 2,
      modBrakes       = 2,
      modTransmission = 2,
      modSuspension   = 3,
      modTurbo        = true,
    }
    ESX.Game.SetVehicleProperties(vehicle, props)
    SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
    SetVehicleCustomSecondaryColour(vehicle, 0, 0, 0)
  end


-----------------------------------------------------------------------------

tahlesfou = false
RMenu.Add('cshop', 'main', RageUI.CreateMenu("Casino", "~b~Ana Sayfa"))
RMenu:Get('cshop', 'main').Closed = function()
    tahlesfou = false
end

function echangecas()
    if not tahlesfou then
        tahlesfou = true
        RageUI.Visible(RMenu:Get('cshop', 'main'), true)
    while tahlesfou do
        RageUI.IsVisible(RMenu:Get('cshop', 'main'), true, true, true, function()
            RageUI.ButtonWithStyle("Jeton satın al", nil, {RightLabel = "→"}, true,function(h,a,s)
                if s then
                    local quantity = KeyboardInput("Miktar", "", 15)
                    if quantity == nil then
                        RageUI.Popup({message = "~r~Geçersiz miktar"})
                    else
                    TriggerServerEvent('casino:achat', quantity)		
                    end
                end
            end) 
            RageUI.ButtonWithStyle("Jeton ile değiştir", nil, {RightLabel = "→"}, true,function(h,a,s)
                if s then
                    local quantity = KeyboardInput("Miktar", "", 15)
                    if quantity == nil then
                        RageUI.Popup({message = "~r~Geçersiz miktar"})
                    else
                        TriggerServerEvent('casino:echange', quantity)
                    end
                end
            end) 
        end, function()
        end)
            Wait(0)
        end
    else
        tahlesfou = false
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
            local plyCoords = GetEntityCoords(PlayerPedId(), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Config.pos.echangejeton.position.x, Config.pos.echangejeton.position.y, Config.pos.echangejeton.position.z)
            if dist <= 15.0 then
                DrawMarker(6,  Config.pos.echangejeton.position.x, Config.pos.echangejeton.position.y, Config.pos.echangejeton.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 255, 255, 255, 155)
            end
            if dist <= 1.0 then
                ESX.ShowHelpNotification("Hostes ile [~b~E~w~] konuşmak için basın")
                if IsControlJustPressed(1,51) then
                    echangecas()
            end   
        end
    end
end)

------------------------------------------

zebileboss = false
RMenu.Add('bossmenu', 'main', RageUI.CreateMenu("Actions Patron", "Casino"))
RMenu:Get('bossmenu', 'main').Closed = function()
    zebileboss = false
end

function boss()
    if not zebileboss then
        zebileboss = true
        RageUI.Visible(RMenu:Get('bossmenu', 'main'), true)
    while zebileboss do
        RageUI.IsVisible(RMenu:Get('bossmenu', 'main'), true, true, true, function()
            if societycasinomoney ~= nil then
                RageUI.ButtonWithStyle("Şirket parası :", nil, {RightLabel = "$" .. societycasinomoney}, true, function()
                end)
            end
        RageUI.ButtonWithStyle("Şirket parasını çek",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
            if Selected then
                local amount = KeyboardInput("Miktar", "", 9)
                amount = tonumber(amount)
            if amount == nil then
                ESX.ShowNotification('Geçersiz miktar')
            else
                TriggerServerEvent('esx_society:withdrawMoney', 'casino', amount)
                end
                RefreshcasinoMoney()
            end
        end)

        RageUI.ButtonWithStyle("Şirket hesabına yatırın",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
            if Selected then
                local amount = KeyboardInput("Miktar", "", 9)
                amount = tonumber(amount)
                    if amount == nil then
                        ESX.ShowNotification('Geçersiz miktar')
                    else
                        TriggerServerEvent('esx_society:depositMoney', 'casino', amount)
                    end
                    RefreshcasinoMoney()
                end
            end) 

        RageUI.ButtonWithStyle("Şirket yönetimine eriş",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
            if Selected then
                aboss()
                RageUI.CloseAll()
            end
        end)

        end, function()
        end)
            Wait(0)
        end
    else
        zebileboss = false
    end
end

---------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'casino' and ESX.PlayerData.job.grade_name == 'boss' then 
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Config.pos.boss.position.x, Config.pos.boss.position.y, Config.pos.boss.position.z)
            if dist <= 15.0 then
                DrawMarker(6, Config.pos.boss.position.x, Config.pos.boss.position.y, Config.pos.boss.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 255, 255, 255, 155)
            end
        if dist <= 1.0 then
            ESX.ShowHelpNotification("Patron İşlemlerine ~INPUT_TALK~ Erişmek İçin Tıklayın")
                if IsControlJustPressed(1,51) then
                    RefreshcasinoMoney()
                    boss()
                end
            end
        end
    end
end)

function aboss()
    TriggerEvent('esx_society:openBossMenu', 'casino', function(data, menu)
        menu.close()
    end, {wash = false})
end

function RefreshcasinoMoney()
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
        ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
            UpdateSocietycasinoMoney(money)
        end, ESX.PlayerData.job.name)
    end
end

function UpdateSocietycasinoMoney(money)
    societycasinomoney = ESX.Math.GroupDigits(money)
end

------------------------------------------

zebilebar = false
RMenu.Add('barcasino', 'main', RageUI.CreateMenu("Bar", "Casino"))
RMenu:Get('barcasino', 'main').Closed = function()
    zebilebar = false
end

function bar()
    if not zebilebar then
        zebilebar = true
        RageUI.Visible(RMenu:Get('barcasino', 'main'), true)
    while zebilebar do
        RageUI.IsVisible(RMenu:Get('barcasino', 'main'), true, true, true, function()    
         
        for k, v in pairs(Config.baritem) do
            RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = " ~g~$"..v.prix},true, function(Hovered, Active, Selected)
                if (Selected) then  
                local quantite = 1    
                local item = v.item
                local prix = v.prix
                local nom = v.nom    
                TriggerServerEvent('casino:achatbar', v, quantite)
            end
            end)

        end
    end, function()
    end)
        Wait(0)
    end
else
    zebilebar = false
end
end

Citizen.CreateThread(function()
        while true do
        Citizen.Wait(0)
        local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
        local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, Config.pos.bar.position.x, Config.pos.bar.position.y, Config.pos.bar.position.z)
        if jobdist <= 15.0 then
            DrawMarker(6, Config.pos.bar.position.x, Config.pos.bar.position.y, Config.pos.bar.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 255, 255, 255, 155)
        end
        if jobdist <= 1.0 then
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'casino' then  
                ESX.ShowHelpNotification("Bar eylemlerine [~b~E~w~] erişmek için basın")
                if IsControlJustPressed(1,51) then
                    bar()
                end   
            end
        end 
    end
end)


------------------------------------------

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
		local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.coffre.position.x, Config.pos.coffre.position.y, Config.pos.coffre.position.z)
        if dist3 <= 15.0 then
            DrawMarker(6, Config.pos.coffre.position.x, Config.pos.coffre.position.y, Config.pos.coffre.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 255, 255, 255, 155)
        end
		if dist3 <= 1.0 then
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'casino' then  
				ESX.ShowHelpNotification("Kasaya [~b~E~w~] erişmek için basın")
				if IsControlJustPressed(1,51) then
					coffrenom = "casino"
					coffrezebieny(coffrenom)
				end   
			end
		end 
	end
end)


coffreharchouma = false
RMenu.Add('coffreenypapi', 'main', RageUI.CreateMenu("Stockage", " "))
RMenu.Add('coffreenypapi', 'coffreprendre', RageUI.CreateSubMenu(RMenu:Get('coffreenypapi', 'main'), "Nesne al", " "))
RMenu.Add('coffreenypapi', 'coffredepot', RageUI.CreateSubMenu(RMenu:Get('coffreenypapi', 'main'), "Nesneyi bırak", " "))
RMenu.Add('coffreenypapi', 'armeprendre', RageUI.CreateSubMenu(RMenu:Get('coffreenypapi', 'main'), "Nesne al", " "))
RMenu.Add('coffreenypapi', 'armedepot', RageUI.CreateSubMenu(RMenu:Get('coffreenypapi', 'main'), "Nesneyi bırak", " "))
RMenu:Get('coffreenypapi', 'main').Closed = function()
coffreharchouma = false
end

function coffrezebieny(societezebi)
ESX.TriggerServerCallback('h4ci_coffre:inventairejoueur', function(inventory)
   inventaireducoffreeny = inventory.items
end)

ESX.TriggerServerCallback('h4ci_coffre:prendreitem', function(items)
	itemsducoffrebb = items
end, societezebi)

if not coffreharchouma then
	coffreharchouma = true
	
	RageUI.Visible(RMenu:Get('coffreenypapi', 'main'), true)
while coffreharchouma do

	RageUI.IsVisible(RMenu:Get('coffreenypapi', 'main'), true, true, true, function()

		RageUI.ButtonWithStyle("Prendre objet(s)", nil, {RightLabel = "→"},true, function()
		end, RMenu:Get('coffreenypapi', 'coffreprendre'))

		RageUI.ButtonWithStyle("Déposer objet(s)", nil, {RightLabel = "→"},true, function()
		end, RMenu:Get('coffreenypapi', 'coffredepot'))

		end, function()
		end)

	RageUI.IsVisible(RMenu:Get('coffreenypapi', 'coffreprendre'), true, true, true, function()

	for i=1, #itemsducoffrebb, 1 do
		RageUI.ButtonWithStyle("x"..itemsducoffrebb[i].count.." "..itemsducoffrebb[i].label, "Bu nesneyi almak için", {RightLabel = "→"},true, function(Hovered, Active, Selected)
		if (Selected) then   
		
		local Miktar = KeyboardInput('Buradan çekmek istediğiniz miktar', '', 2)
		Miktar = tonumber(Miktar)
		if not Miktar then
			ESX.ShowNotification('Geçersiz miktar')
		else
			TriggerServerEvent('h4ci_coffre:prendreitems', itemsducoffrebb[i].name, Miktar, societezebi)
			RageUI.CloseAll()
			coffreharchouma = false
		end

			end
		end)
	end

		end, function()
		end)


	RageUI.IsVisible(RMenu:Get('coffreenypapi', 'coffredepot'), true, true, true, function()

	for i=1, #inventaireducoffreeny, 1 do
		if inventaireducoffreeny[i].count > 0 then
		RageUI.ButtonWithStyle("x"..inventaireducoffreeny[i].count.." "..inventaireducoffreeny[i].label, "Bu nesneyi bırakmak için", {RightLabel = "→"},true, function(Hovered, Active, Selected)
		if (Selected) then   
		
		local Miktar = KeyboardInput('Buraya yatırmak istediğiniz miktar', '', 2)
		Miktar = tonumber(Miktar)
		if not Miktar then
			ESX.ShowNotification('Geçersiz miktar')
		else
			TriggerServerEvent('h4ci_coffre:stockitem', inventaireducoffreeny[i].name, Miktar, societezebi)
			RageUI.CloseAll()
			coffreharchouma = false
		end

			end
			end)
		end
	end

		end, function()
		end)
		Citizen.Wait(0)
	end
else
	coffreharchouma = false
end
end

---------------------------------------------------------

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Citizen.Wait(0)
    end   
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult() 
        Citizen.Wait(500) 
        blockinput = false
        return result 
    else
        Citizen.Wait(500) 
        blockinput = false 
        return nil 
    end
end