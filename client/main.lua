ESX = nil

local robbedRecently = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if IsControlJustPressed(0, 38) then
            local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId(-1))

            if aiming then
                local playerPed = GetPlayerPed(-1)
                local pCoords = GetEntityCoords(playerPed, true)
                local tCoords = GetEntityCoords(targetPed, true)

                if DoesEntityExist(targetPed) and IsEntityAPed(targetPed) then
                    if robbedRecently then
                        ESX.ShowNotification(_U('roubado_recentemente'))
                    elseif IsPedDeadOrDying(targetPed, true) then
                        ESX.ShowNotification(_U('alvo_morto'))
                    elseif GetDistanceBetweenCoords(pCoords.x, pCoords.y, pCoords.z, tCoords.x, tCoords.y, tCoords.z, true) >= Config.RobDistance then
                        ESX.ShowNotification(_U('alvo_longe_demais'))
                    else
                        robNpc(targetPed)
                    end
                end
            end
        end
    end
end)

function robNpc(targetPed)
    robbedRecently = true

    Citizen.CreateThread(function()
        local dict = 'random@mugging3'
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(10)
        end

        TaskStandStill(targetPed, Config.RobAnimationSeconds * 1000)
        FreezeEntityPosition(targetPed, true)
        TaskPlayAnim(targetPed, dict, 'handsup_standing_base', 8.0, -8, .01, 49, 0, 0, 0, 0)
        ESX.ShowNotification(_U('roubo_comecou'))

        Citizen.Wait(Config.RobAnimationSeconds * 1000)

        ESX.TriggerServerCallback('esx_roubarnpc:giveMoney', function(amount)
            FreezeEntityPosition(targetPed, false)
            ESX.ShowNotification(_U('roubo_concluido', amount))
        end)

        if Config.ShouldWaitBetweenRobbing then
            Citizen.Wait(math.random(Config.MinWaitSeconds, Config.MaxWaitSeconds) * 1000)
            ESX.ShowNotification(_U('pode_roubar_novamente'))
        end

        robbedRecently = false
    end)
end
