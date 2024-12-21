local camera = nil
local cameraPos <const> = vec4(-143.86, -630.12, 169.26, 233.25)
DisplayRadar(false)

local rebornData <const> = {
    spawn = vec4(-143.2, -634.67, 168.82, 276.61),
    laptop = vec4(-138.86, -633.92, 168.82, 7.29),

    ped = 'mp_m_freemode_01',
    name = 'Superrobo Conway',

    progress = 0,
    stealing = false,
    entity = nil
}

local requestModel = function(model)
    local hash <const> = joaat(model)
    RequestModel(hash)

    while not HasModelLoaded(hash) do
        Wait(0)
        print('esperando a que el ladrón spawnee')
    end

    return hash
end

local drawSuccessfulThief = function()
    local timer = 500

    CreateThread(function()
        while true do
            Wait(0)

            timer -= 1
            DrawText3D(GetPedBoneCoords(rebornData.entity, GetPedBoneIndex(rebornData.entity, 12844), 0.0, 0.0, 1.0), 'Desarrollo de GlobalRP finalizado!', 0.50, 8)

            if (timer <= 0) then
                print('robo completado')
                break
            end
        end
    end)
end

local spawnThief = function()
    if rebornData.entity and DoesEntityExist(rebornData.entity) then
        DeleteEntity(rebornData.entity)
    end

    local hash <const> = requestModel(rebornData.ped)
    local coords <const> = rebornData.spawn
    rebornData.entity = CreatePed(4, hash, coords.x, coords.y, coords.z, coords.w, false, false)
    SetEntityAsMissionEntity(rebornData.entity, true, true)
    SetEntityInvincible(rebornData.entity, true)
    SetPedMovementClipset(rebornData.entity, 'move_ped_crouched', 0.25)
    GiveWeaponToPed(rebornData.entity, `WEAPON_SMG`, 999, false, true)
    TaskGoToEntityWhileAimingAtEntity(rebornData.entity, PlayerPedId(), PlayerPedId(), 1.0, true, 1.0, 1.0, true, true, 0)

    CreateThread(function()
        while true do
            Wait(0)

            local ped <const> = PlayerPedId()
            local thiefCoords <const> = GetEntityCoords(rebornData.entity)
            local pedCoords <const> = GetEntityCoords(ped)
            local distance <const> = #(thiefCoords - pedCoords)

            if not rebornData.stealing then
                DrawText3D(GetPedBoneCoords(rebornData.entity, GetPedBoneIndex(rebornData.entity, 12844), 0.0, 0.0, 1.0), rebornData.name, 1.0, 8)
            else
                local progress <const> = math.floor(rebornData.progress / 100)
                if (progress >= 95) then
                    rebornData.progress += 1
                    DrawText3D(GetPedBoneCoords(rebornData.entity, GetPedBoneIndex(rebornData.entity, 12844), 0.0, 0.0, 1.0), 'Subiendo OrigenRP a GlobalRP...', 1.0, 8)

                    if progress >= 100 then
                        drawSuccessfulThief()
                        break
                    end
                else
                    rebornData.progress += 10
                    DrawText3D(GetPedBoneCoords(rebornData.entity, GetPedBoneIndex(rebornData.entity, 12844), 0.0, 0.0, 1.0), ('Progreso del robo: '..progress..'%'), 1.0, 8)
                end
            end

            if not IsPedFatallyInjured(ped) then
                DrawText3D(GetPedBoneCoords(ped, GetPedBoneIndex(ped, 12844), 0.0, 0.0, 1.0), 'DustZallax programando Origen', 0.85, 8)

                if distance <= 2.0 then
                    TaskCombatPed(rebornData.entity, ped, 0, 16)
                end
            elseif not rebornData.stealing and IsPedFatallyInjured(ped) then
                rebornData.stealing = true
                TaskGoStraightToCoord(rebornData.entity, rebornData.laptop.x, rebornData.laptop.y, rebornData.laptop.z, 1.0, -1, rebornData.laptop.w, 0.0)
            end
        end
    end)

    return print('ladrón spawneado correctamente tusabe keloke')
end

local createCamera = function()
    camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(camera, cameraPos.x, cameraPos.y, cameraPos.z)
    SetCamRot(camera, 0.0, 0.0, cameraPos.w, 2)
    RenderScriptCams(true, false, 0, true, true)
end

local startRobbery = function()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    createCamera()
    DoScreenFadeIn(1000)
    spawnThief()
end

DoScreenFadeIn(1000)

RegisterCommand('robar', function()
    return startRobbery()
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if rebornData.entity and DoesEntityExist(rebornData.entity) then
            DeleteEntity(rebornData.entity)
        end
    end
end)

--- robado de: https://github.com/ESX-Official/es_extended/blob/main/client/functions.lua
DrawText3D = function(coords, text, size, font)
	local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)

	local camCoords = GetGameplayCamCoords()
	local distance = #(vector - camCoords)

	if not size then size = 1 end
	if not font then font = 0 end

	local scale = (size / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	SetTextScale(0.0 * scale, 0.55 * scale)
	SetTextFont(font)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 255)
	SetTextEntry('STRING')
	SetTextCentre(true)
	AddTextComponentString(text)
    ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
	SetDrawOrigin(vector.xyz, 0)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end