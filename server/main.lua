ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_roubarnpc:giveMoney', function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    local money = math.random(Config.MinMoney, Config.MaxMoney)
    xPlayer.addMoney(money)
    callback(money)
end)