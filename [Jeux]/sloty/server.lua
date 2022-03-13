ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("esx_slots:BetsAndMoney")
AddEventHandler("esx_slots:BetsAndMoney", function(bets)
    local _source   = source
    local xPlayer   = ESX.GetPlayerFromId(_source)
	local xItem = xPlayer.getQuantity('jeton')
        if xPlayer.getQuantity('jeton') < 10 then
            TriggerClientEvent('esx:showNotification', _source, "Oynamak için üstünde en az 10 jeton olması lazım.")
        else
            MySQL.Sync.execute("UPDATE users SET jeton=@jeton WHERE identifier=@identifier",{['@identifier'] = xPlayer.identifier, ['@jeton'] = xItem})
            TriggerClientEvent("esx_slots:UpdateSlots", _source, xItem)
            xPlayer.removeInventoryItem('jeton', xItem)
            TriggerEvent('esx_addonaccount:getSharedAccount', 'society_casino', function (account)
        end)
    end
end)

RegisterServerEvent("esx_slots:updateCoins")
AddEventHandler("esx_slots:updateCoins", function(bets)
    local _source   = source
    local xPlayer   = ESX.GetPlayerFromId(_source)
    if xPlayer then
        MySQL.Sync.execute("UPDATE users SET jeton=@jeton WHERE identifier=@identifier",{['@identifier'] = xPlayer.identifier, ['@jeton'] = bets})
    end
end)

RegisterServerEvent("esx_slots:PayOutRewards")
AddEventHandler("esx_slots:PayOutRewards", function(amount)
    local _source   = source
    local xPlayer   = ESX.GetPlayerFromId(_source)
    if xPlayer then
        amount = math.floor(tonumber(amount))
        if amount > 0 then
            xPlayer.addInventoryItem('jeton', amount)
        end
        MySQL.Sync.execute("UPDATE users SET jeton=0 WHERE identifier=@identifier",{['@identifier'] = xPlayer.identifier})
    end
end)

RegisterServerEvent("route68_kasyno:getJoinChips")
AddEventHandler("route68_kasyno:getJoinChips", function()
    local _source   = source
    local xPlayer   = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.identifier
    MySQL.Async.fetchAll('SELECT jeton FROM users WHERE @identifier=identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
            local jeton = result[1].jeton
            if jeton > 0 then
                TriggerClientEvent('pNotify:SendNotification', _source, {text = ' '..tostring(jeton)..' jetonunuz var çünkü bahis esnasında oyundan ayrıldınız.'})
                xPlayer.addInventoryItem('jeton', jeton)
                MySQL.Sync.execute("UPDATE users SET jeton=0 WHERE identifier=@identifier",{['@identifier'] = xPlayer.identifier})
            end
		end
	end)
end)