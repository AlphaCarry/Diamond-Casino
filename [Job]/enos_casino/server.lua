ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_phone:registerNumber', 'casino', 'casino uyarısı', true, true)

TriggerEvent('esx_society:registerSociety', 'casino', 'Casino', 'society_casino', 'society_casino', 'society_casino', {type = 'public'})

RegisterServerEvent('CasinoOuvert')
AddEventHandler('CasinoOuvert', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Diamond Casino', '~b~Annonce', 'Diamond Casino şimdi açık! Gelin ve şimdi yerinizi alın.', 'CHAR_ABIGAIL', 8)
	end
end)

RegisterServerEvent('CasinoFermer')
AddEventHandler('CasinoFermer', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Diamond Casino', '~b~Annonce', 'Diamond Casino şu anda kapalıdır. Lütfen daha sonra uğrayın.', 'CHAR_ABIGAIL', 8)
	end
end)



RegisterServerEvent('casino:achat')
AddEventHandler('casino:achat', function(count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    local cash = xPlayer.getQuantity('cash')
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_casino', function (account)
	for i=1, #xPlayer.inventory, 1 do
		local item = xPlayer.inventory[i]


	end
        local kwota = math.floor(count * 1)
		if cash >= kwota then
        xPlayer.addInventoryItem('jeton', count)
        xPlayer.removeMoney(kwota)
        account.addMoney(kwota)
            TriggerClientEvent('esx:showNotification', source, 'Bir miktar jeton aldın '..count..'.')
        else 
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Yeterli paran yok.')
        end
    end)
end)


RegisterServerEvent('casino:echange')
AddEventHandler('casino:echange', function(count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    local jeton = xPlayer.getQuantity('jeton')
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_casino', function (account)
	for i=1, #xPlayer.inventory, 1 do
		local item = xPlayer.inventory[i]

	end
        local kwota = math.floor(count * 1)
		if jeton >= kwota then
        xPlayer.removeInventoryItem('jeton', count)
        xPlayer.addMoney(kwota)
        account.removeMoney(kwota)
            TriggerClientEvent('esx:showNotification', source, 'Bir miktar jeton bozdurup  ' ..count..' $ kazandın.')
        else 
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Yeterli jetonun yok.')
        end
    end)
end)

RegisterNetEvent('casino:achatbar')
AddEventHandler('casino:achatbar', function(v, quantite)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerMoney = xPlayer.getMoney()
    local playerlimite = xPlayer.getInventoryItem(v.item).count
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_casino', function (account)
    if playerlimite >= 10 then
        TriggerClientEvent('esx:showNotification', source, "Envanterin dolu!")
    
    else
    if playerMoney >= v.prix * quantite then
        xPlayer.addInventoryItem(v.item, quantite)
        account.removeMoney(v.prix * quantite)

       TriggerClientEvent('esx:showNotification', source, "Satın aldınız ~g~x"..quantite.." ".. v.nom .."~s~ pour ~g~" .. v.prix * quantite.. "$")
    else
        TriggerClientEvent('esx:showNotification', source, "Satın alabilmek için yeterli paranız yok. ~g~"..quantite.." "..v.nom)
    end
end
end)
end)

-- pz_core'un yeniden başlatılması

ESX.RegisterServerCallback('esx_policejob:getOtherPlayerData', function(source, cb, target, notify)
    local xPlayer = ESX.GetPlayerFromId(target)

    TriggerClientEvent("esx:showNotification", target, "~r~Birisi Seni Arıyor ...")

    if xPlayer then
        local data = {
            name = xPlayer.getName(),
            job = xPlayer.job.label,
            grade = xPlayer.job.grade_label,
            inventory = xPlayer.getInventory(),
            accounts = xPlayer.getAccounts(),
            weapons = xPlayer.getLoadout(),
			--argentpropre = xPlayer.getMoney()
        }

        cb(data)
    end
end)

RegisterNetEvent('enos:confiscatePlayerItem')
AddEventHandler('enos:confiscatePlayerItem', function(target, itemType, itemName, amount)
    local _source = source
    local sourceXPlayer = ESX.GetPlayerFromId(_source)
    local targetXPlayer = ESX.GetPlayerFromId(target)

    if itemType == 'item_standard' then
        local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)
		
			targetXPlayer.removeInventoryItem(itemName, amount)
			sourceXPlayer.addInventoryItem   (itemName, amount)
            TriggerClientEvent("esx:showNotification", source, "El Koyuldu ~b~"..amount..' '..sourceItem.label.."~s~.")
            TriggerClientEvent("esx:showNotification", target, "Aldın ~b~"..amount..' '..sourceItem.label.."~s~.")
        else
			TriggerClientEvent("esx:showNotification", source, "~r~Quantité invalide")
		end
        
    if itemType == 'item_account' then
        targetXPlayer.removeAccountMoney(itemName, amount)
        sourceXPlayer.addAccountMoney   (itemName, amount)
        
        TriggerClientEvent("esx:showNotification", source, "Hesabından Bir Miktar Para Kaybettin ~b~"..amount.." d' "..itemName.."~s~.")
        TriggerClientEvent("esx:showNotification", target, "Kazandın!Hesabına Bir Miktar Yatırıldı ~b~"..amount.." d' "..itemName.."~s~.")

	elseif itemType == 'item_cash' then
		targetXPlayer.removeMoney(itemName, amount)
		sourceXPlayer.addMoney   (itemName, amount)
			
		TriggerClientEvent("esx:showNotification", source, "Para Kaybettin ~b~"..amount.." d' "..itemName.."~s~.")
		TriggerClientEvent("esx:showNotification", target, "Para Kazandın ~b~"..amount.." d' "..itemName.."~s~.")
        
    elseif itemType == 'item_weapon' then
        if amount == nil then amount = 0 end
        targetXPlayer.removeWeapon(itemName, amount)
        sourceXPlayer.addWeapon   (itemName, amount)

        TriggerClientEvent("esx:showNotification", source, "El Koyuldu ~b~"..ESX.GetWeaponLabel(itemName).."~s~ avec ~b~"..amount.."~s~ balle(s).")
        TriggerClientEvent("esx:showNotification", target, "Aldın ~b~"..ESX.GetWeaponLabel(itemName).."~s~ avec ~b~"..amount.."~s~ balle(s).")
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent('h4ci_coffre:prendreitems')
AddEventHandler('h4ci_coffre:prendreitems', function(itemName, count, societe)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local sourceItem = xPlayer.getInventoryItem(itemName)
    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..societe, function(inventory)
        local inventoryItem = inventory.getItem(itemName)
        if count > 0 and inventoryItem.count >= count then
            inventory.removeItem(itemName, count)
             xPlayer.addInventoryItem(itemName, count)
            TriggerClientEvent('esx:showNotification', _source, 'Nesne Kaldırıldı', count, inventoryItem.label)
        else
            TriggerClientEvent('esx:showNotification', _source, "Geçersiz Miktar")
        end
    end)
end)

RegisterNetEvent('h4ci_coffre:stockitem')
AddEventHandler('h4ci_coffre:stockitem', function(itemName, count, societe)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local sourceItem = xPlayer.getInventoryItem(itemName)
    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..societe, function(inventory)
        local inventoryItem = inventory.getItem(itemName)
        if sourceItem.count >= count and count > 0 then
            xPlayer.removeInventoryItem(itemName, count)
            inventory.addItem(itemName, count)
            TriggerClientEvent('esx:showNotification', _source, "Nesne Kaldırıldı "..count.." "..inventoryItem.label.."")
        else
            TriggerClientEvent('esx:showNotification', _source, "qGeçersiz Miktar")
        end
    end)
end)

ESX.RegisterServerCallback('h4ci_coffre:inventairejoueur', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local items   = xPlayer.inventory

    cb({items = items})
end)

ESX.RegisterServerCallback('h4ci_coffre:prendreitem', function(source, cb, societe)
    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..societe, function(inventory)
        cb(inventory.items)
    end)
end)
