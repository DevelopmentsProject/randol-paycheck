local Config = require('config')
local PC_PED, initZone

local function InputWithdraw(amount)
    local withdrawMenu = {
        {
            header = "Withdraw From Paycheck",
            isMenuHeader = true
        },
        {
            header = "Withdraw to Cash",
            txt = ("Current: $%s"):format(amount),
            params = {
                event = "randol_paycheck:client:withdrawChoice",
                args = {
                    accountType = "cash",
                    amount = amount
                }
            }
        },
        {
            header = "Withdraw to Bank",
            txt = ("Current: $%s"):format(amount),
            params = {
                event = "randol_paycheck:client:withdrawChoice",
                args = {
                    accountType = "bank",
                    amount = amount
                }
            }
        },
        {
            header = "Close",
            params = { event = "" }
        }
    }
    exports['qb-menu']:openMenu(withdrawMenu)
end

RegisterNetEvent("randol_paycheck:client:withdrawChoice", function(data)
    local accountType = data.accountType
    local amount = data.amount

    local input = exports['qb-input']:ShowInput({
        header = "Withdraw Amount",
        submitText = "Withdraw",
        inputs = {
            {
                text = "Amount",
                name = "withdrawAmount",
                type = "number",
                isRequired = true
            }
        }
    })

    if input and input.withdrawAmount then
        local amt = tonumber(input.withdrawAmount)
        if amt and amt > 0 and amt <= amount then
            local success = lib.callback.await('randol_paycheck:server:withdraw', false, amt, accountType)
            if success then
                lib.playAnim(cache.ped, 'friends@laf@ig_5', 'nephew', 8.0, -8.0, -1, 49, 0, false, false, false)
                Wait(2000)
                ClearPedTasks(cache.ped)
            end
        else
            DoNotification('Invalid amount.', 'error')
        end
    end
end)

local function viewPaycheck()
    local paycheckAmount = lib.callback.await('randol_paycheck:server:checkPaycheck', true)
    local viewMenu = {
        {
            header = ("Paycheck: $%s"):format(paycheckAmount),
            isMenuHeader = true
        },
        {
            header = "Withdraw",
            txt = "Withdraw money from your paycheck",
            params = {
                event = "randol_paycheck:client:openWithdraw",
                args = {
                    amount = paycheckAmount
                }
            }
        },
        {
            header = "Close",
            params = { event = "" }
        }
    }
    exports['qb-menu']:openMenu(viewMenu)
end

RegisterNetEvent("randol_paycheck:client:openWithdraw", function(data)
    InputWithdraw(tonumber(data.amount))
end)

exports.interact:AddInteraction({
    coords = vector3(-1307.78, -820.98, 17.17),
    name = 'paycheckStation',
    distance = 3.5,
    interactDst = 1.5,
    options = {
        {
            label = 'Collect Paycheck',
            event = 'randol_paycheck:client:openPaycheckMenu',
        }
    }
})

RegisterNetEvent("randol_paycheck:client:openPaycheckMenu", viewPaycheck)

local function removePed()
    if not DoesEntityExist(PC_PED) then return end
    DeleteEntity(PC_PED)
    PC_PED = nil
end

local function spawnPed()
    lib.requestModel(Config.model, 10000)
    PC_PED = CreatePed(0, Config.model, Config.coords, false, false)
    SetEntityAsMissionEntity(PC_PED)
    SetPedFleeAttributes(PC_PED, 0, 0)
    SetBlockingOfNonTemporaryEvents(PC_PED, true)
    SetEntityInvincible(PC_PED, true)
    FreezeEntityPosition(PC_PED, true)
    SetPedDefaultComponentVariation(PC_PED)
    SetModelAsNoLongerNeeded(Config.model)
    lib.playAnim(PC_PED, 'mp_prison_break', 'hack_loop', 8.0, -8.0, -1, 1, 0.0, 0, 0, 0)
end

local function paycheckZone()
    initZone = lib.points.new({ coords = Config.coords.xyz, distance = 50, onEnter = spawnPed, onExit = removePed })
end

function OnPlayerLoaded()
    paycheckZone()
end

function OnPlayerUnload()
    if initZone then initZone:remove() end
    removePed()
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if initZone then initZone:remove() end
        removePed()
    end
end)

RegisterNetEvent('randol_paycheck:client:openPaycheckMenu', function()
    viewPaycheck()
end)
