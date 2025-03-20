local FADE_DISTANCE = 30
local jobText = "Какая-то работа\nНажмите [E]"
local pickupElement = nil
local boxes = {}
local blipElement = nil

addEventHandler("onClientResourceStart", resourceRoot, function()
    pickupElement = getElementsByType("pickup")[1]
    blipElement = getAttachedElements(pickupElement) and getAttachedElements(pickupElement)[1] or nil
end)

addEventHandler("onClientRender", root, function()
    if not isElement(pickupElement) or not isElement(blipElement) then return end
		
    local blipPos = Vector3(getElementPosition(pickupElement))
    blipPos.z = blipPos.z + 0.5
	
    local screenPos = Vector3(getScreenFromWorldPosition(blipPos))
    if not screenPos then return end
	
    local playerPos = Vector3(getElementPosition(localPlayer))
    local distance = getDistanceBetweenPoints2D(Vector3(playerPos), Vector3(blipPos))
    local alpha = math.max(0, 255 - (distance/FADE_DISTANCE)*255)
    
    dxDrawText(jobText, 
        screenPos.x, screenPos.y - 40,
        screenPos.x, screenPos.y,
        tocolor(255, 255, 255, alpha),
        1.2,
        "default-bold", "center", "bottom")	
	
	for player, box in pairs(boxes) do
        if isElement(player) and isElement(box) then
            local attached, x, y, z = getElementAttachedPosition(box)
            if attached then
                setElementPosition(box, x, y, z)
            end
        end
    end
end)

-- Получение коробок от сервера
addEvent("onClientBoxAttach", true)
addEventHandler("onClientBoxAttach", root, function(box, player)
    if not isElement(box) then return end
    boxes[player] = box
    attachElementToBone(box, player, 12, 0.2, -0.2, 0.3, 0, 0, 90)
end)

addEvent("onClientBoxDetach", true)
addEventHandler("onClientBoxDetach", root, function(player)
    if boxes[player] then
        destroyElement(boxes[player])
        boxes[player] = nil
    end
end)

addEvent("onClientAnimation", true)
addEventHandler("onClientAnimation", localPlayer, function(animType)
    if animType == "liftup" then
        setPedAnimation(localPlayer, "CARRY", "liftup", 1500, false, false, false, false)
    elseif animType == "putdwn" then
        setPedAnimation(localPlayer, "CARRY", "putdwn", 1500, false, false, false, false)
    end
end)



-- Useful functions
function attachElementToBone(element, ped, bone, offX, offY, offZ, offrx, offry, offrz)
	if isElementOnScreen(ped) then
        local boneMat = getElementBoneMatrix(ped, bone)
        local sroll, croll, spitch, cpitch, syaw, cyaw = math.sin(offrz), math.cos(offrz), math.sin(offry), math.cos(offry), math.sin(offrx), math.cos(offrx)
        local rotMat = {
            {sroll * spitch * syaw + croll * cyaw,
            sroll * cpitch,
            sroll * spitch * cyaw - croll * syaw},
            {croll * spitch * syaw - sroll * cyaw,
            croll * cpitch,
            croll * spitch * cyaw + sroll * syaw},
            {cpitch * syaw,
            -spitch,
            cpitch * cyaw}
        }
        local finalMatrix = {
            {boneMat[2][1] * rotMat[1][2] + boneMat[1][1] * rotMat[1][1] + rotMat[1][3] * boneMat[3][1],
            boneMat[3][2] * rotMat[1][3] + boneMat[1][2] * rotMat[1][1] + boneMat[2][2] * rotMat[1][2],-- right
            boneMat[2][3] * rotMat[1][2] + boneMat[3][3] * rotMat[1][3] + rotMat[1][1] * boneMat[1][3],
            0},
            {rotMat[2][3] * boneMat[3][1] + boneMat[2][1] * rotMat[2][2] + rotMat[2][1] * boneMat[1][1],
            boneMat[3][2] * rotMat[2][3] + boneMat[2][2] * rotMat[2][2] + boneMat[1][2] * rotMat[2][1],-- front 
            rotMat[2][1] * boneMat[1][3] + boneMat[3][3] * rotMat[2][3] + boneMat[2][3] * rotMat[2][2],
            0},
            {boneMat[2][1] * rotMat[3][2] + rotMat[3][3] * boneMat[3][1] + rotMat[3][1] * boneMat[1][1],
            boneMat[3][2] * rotMat[3][3] + boneMat[2][2] * rotMat[3][2] + rotMat[3][1] * boneMat[1][2],-- up
            rotMat[3][1] * boneMat[1][3] + boneMat[3][3] * rotMat[3][3] + boneMat[2][3] * rotMat[3][2],
            0},
            {offX * boneMat[1][1] + offY * boneMat[2][1] + offZ * boneMat[3][1] + boneMat[4][1],
            offX * boneMat[1][2] + offY * boneMat[2][2] + offZ * boneMat[3][2] + boneMat[4][2],-- pos
            offX * boneMat[1][3] + offY * boneMat[2][3] + offZ * boneMat[3][3] + boneMat[4][3],
            1}
        }
        setElementMatrix(element, finalMatrix)
        return true
    else
        setElementPosition(element, 0, 0, -1000)
        return false
    end
end