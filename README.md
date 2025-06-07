📦 Paycheck Script Update: ox_lib ➝ qb-menu + interact
This update replaces ox_lib's context menus and targeting system with qb-menu and a custom exports.interact handler. Below are the key changes:

🔁 Replaced ox_lib with qb-menu
Removed all usage of lib.registerContext() and lib.showContext() (ox_lib context menu).

Now uses qb-menu to show pay check menu

qb-menu is opened using exports['qb-menu']:openMenu({ ... }).

🎯 Targeting/Interaction Change
Removed ox_target and qb-target support.

Now uses a unified exports.interact:AddInteraction() system.

This system allows defining a location, interaction range, and multiple menu options (like "Collect Paycheck").

If you don't have the same map you can change the Vector3 cords in the cl_paycheck.lua 

Hope you guys enjoy

dependencies:
    'qb-core',
    'oxmysql',
    'ox_lib',
    'qb-menu',
    'qb-input',
    'progressbar', 
    'interact'

# QBCore Install.

**IF USING THE LATEST QBCORE UPDATE THAT MOVED SOCIETY FUNDS TO QB-BANKING, Go to qb-core/server/functions.lua and replace PaycheckInterval() code with mine below.**

```lua
function PaycheckInterval()
    if next(QBCore.Players) then
        for _, Player in pairs(QBCore.Players) do
            if Player then
                local payment = QBShared.Jobs[Player.PlayerData.job.name]['grades'][tostring(Player.PlayerData.job.grade.level)].payment
                if not payment then payment = Player.PlayerData.job.payment end
                if Player.PlayerData.job and payment > 0 and (QBShared.Jobs[Player.PlayerData.job.name].offDutyPay or Player.PlayerData.job.onduty) then
                    if QBCore.Config.Money.PayCheckSociety then
                        local account = exports['qb-banking']:GetAccountBalance(Player.PlayerData.job.name)
                        if account ~= 0 then -- Checks if player is employed by a society
                            if account < payment then -- Checks if company has enough money to pay society
                                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('error.company_too_poor'), 'error')
                            else
                                exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, payment)
                                exports['qb-banking']:RemoveMoney(Player.PlayerData.job.name, payment, 'Employee Paycheck')
                                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                            end
                        else
                            exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, payment)
                            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                        end
                    else
                        exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, payment)
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                    end
                end
            end
        end
    end
    SetTimeout(QBCore.Config.Money.PayCheckTimeOut * (60 * 1000), PaycheckInterval)
end
```

**IF STILL USING QB-MANAGEMENT TO HANDLE SOCIETY FUNDS, Go to qb-core/server/functions.lua and replace PaycheckInterval() code with mine below.**

```lua
function PaycheckInterval()
    if next(QBCore.Players) then
        for _, Player in pairs(QBCore.Players) do
            if Player then
                local payment = QBShared.Jobs[Player.PlayerData.job.name]['grades'][tostring(Player.PlayerData.job.grade.level)].payment
                if not payment then payment = Player.PlayerData.job.payment end
                if Player.PlayerData.job and payment > 0 and (QBShared.Jobs[Player.PlayerData.job.name].offDutyPay or Player.PlayerData.job.onduty) then
                    if QBCore.Config.Money.PayCheckSociety then
                        local account = exports['qb-management']:GetAccount(Player.PlayerData.job.name)
                        if account ~= 0 then -- Checks if player is employed by a society
                            if account < payment then -- Checks if company has enough money to pay society
                                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('error.company_too_poor'), 'error')
                            else
                                exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, payment)
                                exports['qb-management']:RemoveMoney(Player.PlayerData.job.name, payment)
                                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                            end
                        else
                            exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, payment)
                            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                        end
                    else
                        exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, payment)
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                    end
                end
            end
        end
    end
    SetTimeout(QBCore.Config.Money.PayCheckTimeOut * (60 * 1000), PaycheckInterval)
end

# Export

The export below can be used to insert money into the paycheck rather than adding it into a player's bank/cash. You must implement these yourself.

Example: QBCore

```lua
local Player = QBCore.Functions.GetPlayer(source)
local amount = 450
exports.randol_paycheck:AddToPaycheck(Player.PlayerData.citizenid, amount)
```

Example: ESX

```lua
local xPlayer = ESX.GetPlayerFromId(source)
local amount = 450
exports.randol_paycheck:AddToPaycheck(xPlayer.identifier, amount)
```
