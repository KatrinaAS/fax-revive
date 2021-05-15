--------------------------------
--- RP Revive, Made by FAXES ---
--------------------------------

--- Config ---
local featureColor = "~y~" -- Game color used as the button key colors.

--- Code ---
local isDead = false
local spawnPoints = {}

function createSpawnPoint(x1, y1, z, heading)
		local xValue = x1
		local yValue = y1

		local newObject = {
			x = xValue,
			y = yValue,
			z = z + 0.0001,
			heading = heading + 0.0001
		}
		table.insert(spawnPoints,newObject)
	end

createSpawnPoint(373.924,792.803,186.942,0)
createSpawnPoint(622.22, 21.21, 88.25,0)
createSpawnPoint(820.8, -1288.63, 27.1,0)
createSpawnPoint(430.49, -981.55, 30.71,0)
createSpawnPoint(375.94, -1612.47, 29.29,0)
createSpawnPoint(-558.06, -141.45, 38.42,0)
createSpawnPoint(-1092.91, -807.41, 19.28,0)
createSpawnPoint(-439.74, 6020.66, 31.49,0)
createSpawnPoint(1855.67, 3680.45, 32.21,0)
createSpawnPoint(2508.85, -385.35, 94.12,0)
createSpawnPoint(360.89,  -585.22, 28.83,0)
createSpawnPoint(294.68, -1447.17, 29.97,0)
createSpawnPoint(-498.41, -334.99, 34.5,0)
createSpawnPoint(-1035.11, -2734.43, 13.76,0)
createSpawnPoint(-244.28, 6329.45, 32.43,0)
	

AddEventHandler('playerSpawned', function()
    local src = source
end)



-- Turn off automatic respawn here instead of updating FiveM file.
AddEventHandler('onClientMapStart', function()
	Citizen.Trace("RPRevive: Disabling the autospawn.")
	exports.spawnmanager:spawnPlayer() -- Ensure player spawns into server.
	Citizen.Wait(2500)
	exports.spawnmanager:setAutoSpawn(false)
	Citizen.Trace("RPRevive: Autospawn is disabled.")
end)

function respawnPed(ped, coords)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false) 
	SetPlayerInvincible(ped, false) 
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
	ClearPedBloodDamage(ped)
end

function revivePed(ped)
	local playerPos = GetEntityCoords(ped, true)
	isDead = false
	timerCount = reviveWait
	NetworkResurrectLocalPlayer(playerPos, true, true, false)
	SetPlayerInvincible(ped, false)
	ClearPedBloodDamage(ped)
end

function ShowInfoRevive(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentSubstringPlayerName(text)
	DrawNotification(true, true)
end

function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

Citizen.CreateThread(function()
	local respawnCount = 0
	
	local playerIndex = NetworkGetPlayerIndex(-1) or 0
	math.randomseed(playerIndex)

		


    while true do
    Citizen.Wait(0)
		ped = GetPlayerPed(-1)
        if IsEntityDead(ped) then
			isDead = true
            SetPlayerInvincible(ped, true)
            SetEntityHealth(ped, 1)
            ShowInfoRevive('You are dead. Use' .. featureColor .. ' E ~w~to revive or'.. featureColor .. ' R ~w~to respawn.')
            if IsControlJustReleased(0, 38) and GetLastInputMethod(0) then
                revivePed(ped)
            elseif IsControlJustReleased(0, 45) and GetLastInputMethod( 0 ) then
				local playerPos = GetEntityCoords(ped, true)
				local closest=spawnPoints[1]
				local distancePoint=99999
				for i,point in ipairs(spawnPoints) do
					curDist=distance(point.x,point.y,playerPos.x,playerPos.y)
					if(curDist < distancePoint) then
						closest=point
						distancePoint=curDist
					end
				end
                local coords = closest
				respawnPed(ped, coords)
				isDead = false
				timerCount = reviveWait
				respawnCount = respawnCount + 1
				math.randomseed(playerIndex * respawnCount)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if isDead then
			timerCount = timerCount - 1
        end
        Citizen.Wait(1000)          
    end
end)
