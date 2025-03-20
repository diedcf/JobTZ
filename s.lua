local WORKER_SKIN = 27
local COOLDOWN = 1000
local jobPickup = nil
local playerData = {}

function createJobPickup()
    jobPickup = createPickup(219.294, -151.418, 1.378, 3, 1275, 0)
    createBlipAttachedTo(jobPickup, 55, 2, 0, 0, 255, 255, 0, 200)
    
    -- Маркеры работы (исправлено)
    local startMarker = createMarker(228.5, -152.3, 0.578, "cylinder", 1.5, 255, 200, 0, 150)
    local finishMarker = createMarker(235.1, -148.9, 0.578, "cylinder", 1.5, 0, 255, 0, 150)
    
    -- Назначаем ID маркерам
    setElementID(startMarker, "work_start")
    setElementID(finishMarker, "work_finish")
    
    -- Обработчики событий
    addEventHandler("onPickupHit", jobPickup, onJobInteraction)
    addEventHandler("onMarkerHit", startMarker, onMarkerHit)
    addEventHandler("onMarkerHit", finishMarker, onMarkerHit)
end
addEventHandler("onResourceStart", resourceRoot, createJobPickup)


-- Обработка трудоустройства/увольнения
function onJobInteraction(player)
    if not isElement(player) or getElementType(player) ~= "player" then return end
    
	
	bindKey(player, "e", "down", function()
		local plyPos = Vector3(getElementPosition(player))
		local pickupPos = Vector3(getElementPosition(jobPickup))
		if getDistanceBetweenPoints3D(plyPos, pickupPos) < 1 then
			if not playerData[player] then
				-- Запуск работы
				triggerEvent("onJobStart", player)
			else
				-- Завершение работы
				triggerEvent("onJobQuit", player)
			end
		end
	end)
end

-- Событие: Начало работы
addEvent("onJobStart", true)
addEventHandler("onJobStart", root, function()
    if playerData[source] then return end
    
    playerData[source] = {
        originalSkin = getElementModel(source),
        box = nil,
        lastUse = 0,
        salary = 0
    }
    
    -- Смена скина
    setElementModel(source, WORKER_SKIN)
    outputChatBox("[РАБОТА] Вы начали работу!", source, 0, 255, 0)
end)

-- Событие: Завершение работы
addEvent("onJobQuit", true)
addEventHandler("onJobQuit", root, function()
    if not playerData[source] then return end
    
    -- Возврат скина и выплата
    setElementModel(source, playerData[source].originalSkin)
    givePlayerMoney(source, playerData[source].salary)
    outputChatBox("[РАБОТА] Вы получили $"..playerData[source].salary, source, 0, 255, 0)
    
    -- Удаление коробки
    if isElement(playerData[source].box) then
        destroyElement(playerData[source].box)
    end
    
    playerData[source] = nil
end)

-- Обработка маркеров работы
function onMarkerHit(hitElement)
    if getElementType(hitElement) ~= "player" or not playerData[hitElement] then return end
    local markerID = getElementID(source)
    local currentTime = getTickCount()
    
    -- Проверка кулдауна
    if currentTime - playerData[hitElement].lastUse < COOLDOWN then return end
    playerData[hitElement].lastUse = currentTime
    
    if markerID == "work_start" and not playerData[hitElement].box then
        -- Создание коробки
        local box = createObject(1271,0,0,-10)
        setElementCollisionsEnabled(box, false)
        playerData[hitElement].box = box
        triggerClientEvent(hitElement, "onClientAnimation", hitElement, "liftup")
        triggerClientEvent(hitElement, "onClientBoxAttach", hitElement, box, hitElement)
        
    elseif markerID == "work_finish" and playerData[hitElement].box then
        -- Удаление коробки и начисление оплаты
        destroyElement(playerData[hitElement].box)
        playerData[hitElement].box = nil
        playerData[hitElement].salary = playerData[hitElement].salary + 150
        triggerClientEvent(hitElement, "onClientAnimation", hitElement, "putdwn")
        triggerClientEvent(hitElement, "onClientBoxDetach", hitElement)
    end
end

-- Обработка выхода игрока
addEventHandler("onPlayerQuit", root, function()
    triggerEvent("onJobQuit", source)
	if playerData[source] then
        destroyElement(playerData[source])
        playerData[source] = nil
	end
end)