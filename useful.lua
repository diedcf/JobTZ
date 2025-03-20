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