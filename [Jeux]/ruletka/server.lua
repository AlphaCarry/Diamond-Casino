ESX						= nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_roulette:removemoney')
AddEventHandler('esx_roulette:removemoney', function(amount)
		local amount = amount
		local _source = source
		local xPlayer = ESX.GetPlayerFromId(_source)
		xPlayer.removeInventoryItem('jeton', amount)
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_casino', function (account)
		account.addMoney(amount)
	end)
end)

RegisterServerEvent('esx_roulette:givemoney')
AddEventHandler('esx_roulette:givemoney', function(action, amount)
	local aciton = aciton
	local amount = amount
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if action == 'black' or action == 'red' then
		local win = amount*2
		xPlayer.addInventoryItem('jeton', win)
	elseif action == 'green' then
		local win = amount*14
		xPlayer.addInventoryItem('jeton', win)
	else
	end
end)

ESX.RegisterServerCallback('esx_roulette:check_money', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local quantity = xPlayer.getQuantity('jeton')
	cb(quantity)
end)