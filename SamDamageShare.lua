local _
local LGS = LibStub("LibGroupSocket")
local chat = LibChatMessage("SamDamageShare", "SDS")
local SDSSavedVariables = {}
local AUIhidden = false

--stat object
Stat = {}

function Stat.new(name, value)
    newStat = {}
    newStat.name = name
    newStat.value = value
    return newStat
end

--stat list object
StatList = {}

function StatList.new()
    newStatList = {}
    newStatList.content = {}
    return newStatList
end

function StatList.getValue(list, name)
    for _,element in pairs(list.content) do
        if element.name == name then
            return element.value
        end
    end

    return 0;
end

function StatList.editList(list, stat)
    --chat:Print("---------------------------") 

    if #(list.content) == 0 then
        table.insert(list.content, stat)
        --chat:Print("NEW "..stat.name..stat.value) 
    else
        --remove old element
        for i=#(list.content),1,-1 do
            if list.content[i].name == stat.name then
                table.remove(list.content,i)
                --chat:Print("REMOVE"..stat.name..stat.value) 
            end
        end
    
        --insertion sort new element
        if #(list.content) == 0 then
            table.insert(list.content, stat)
            --chat:Print("APPEND"..stat.name..stat.value) 
        else
            inserted = false

            for i=#(list.content),1,-1 do
                if stat.value <= list.content[i].value then
                    --chat:Print("INSERT"..stat.name..stat.value..list.content[i].name..list.content[i].value) 
                    list.content[i+1] = stat
                    inserted = true
                    break
                else
                    list.content[i+1] = list.content[i]
                    --chat:Print("SKIP"..stat.name..stat.value..list.content[i].name..list.content[i].value)
                end
            end

            if not inserted then
                list.content[1] = stat
                --chat:Print("PREPEND"..stat.name..stat.value) 
            end
        end
    end
end


function numWithCommas(n)
  return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,")
                                :gsub(",(%-?)$","%1"):reverse()
end

--damage counter
local SamDamageShare = {}
SamDamageShare.name = "SamDamageShare"
local wm = GetWindowManager()

--update ui
function newBar(stat, position, max)
    if(SamDamageShare.ui.bars[position]) then
        SamDamageShare.ui.bars[position]:SetHidden(false)
        SamDamageShare.ui.namelabels[position]:SetHidden(false)
        SamDamageShare.ui.damlabels[position]:SetHidden(false)

        if(stat.name == SDSSavedVariables.fightInfo.name) then
            SamDamageShare.ui.bars[position]:SetColor(220/255,0/255,0/255,170/255)
        else
            SamDamageShare.ui.bars[position]:SetColor(150/255,19/255,19/255,170/255)
        end

        SamDamageShare.ui.bars[position]:SetMinMax(0, max)
        SamDamageShare.ui.bars[position]:SetValue(stat.value)
        SamDamageShare.ui.namelabels[position]:SetText(stat.name)
        SamDamageShare.ui.damlabels[position]:SetText(numWithCommas(stat.value))

    else
        SDSbar = wm:CreateControl(position.."bar", SDSTlwBg, CT_STATUSBAR)
        if(stat.name == SDSSavedVariables.fightInfo.name) then
            SDSbar:SetColor(220/255,0/255,0/255,170/255)
        else
            SDSbar:SetColor(150/255,19/255,19/255,170/255)
        end

        SDSbar:SetScale(1)
        SDSbar:SetDrawLayer(1)
        SDSbar:SetMinMax(0, max)
        SDSbar:SetValue(stat.value)
        --TOPLEFT TOPRIGHT BOTTOMLEFT BOTTOMRIGHT TOP BOTTOM LEFT RIGHT CENTER
        SDSbar:SetAnchor(TOPLEFT, SDSTlwBlockSep, TOPLEFT, 8,10+35*(position-1))
        SDSbar:SetDimensions(300, 25)

        SDSnamelabel = wm:CreateControl(position.."namelabel", SDSTlwBg, CT_LABEL)
        SDSnamelabel:SetColor(1,1,1,1)
        SDSnamelabel:SetFont("GDSFontGameBig")
        SDSnamelabel:SetScale(1)
        SDSnamelabel:SetDrawLayer(1)
        SDSnamelabel:SetText(stat.name)
        SDSnamelabel:SetAnchor(BOTTOMLEFT, SDSbar, BOTTOMLEFT, 5,0)
        SDSnamelabel:SetDimensions(200, 25)

        SDSdamlabel = wm:CreateControl(position.."damlabel", SDSTlwBg, CT_LABEL)
        SDSdamlabel:SetColor(1,1,1,1)
        SDSdamlabel:SetFont("GDSFontGameBig")
        SDSdamlabel:SetScale(1)
        SDSdamlabel:SetDrawLayer(1)
        SDSdamlabel:SetText(numWithCommas(stat.value))
        SDSdamlabel:SetAnchor(TOPRIGHT, SDSTlwBlockSep, TOPRIGHT, -20,10+35*(position-1))
        SDSdamlabel:SetHorizontalAlignment(-1)

        SamDamageShare.ui.bars[position] = SDSbar
        SamDamageShare.ui.namelabels[position] = SDSnamelabel
        SamDamageShare.ui.damlabels[position] = SDSdamlabel
    end
end

function updateUI()
    local max
    if SamDamageShare.fightInfo.damageOut.content[1] then max = SamDamageShare.fightInfo.damageOut.content[1].value else max = 0 end
    local damageOutList = SamDamageShare.fightInfo.damageOut.content

    for i=1, #damageOutList do
        newBar(damageOutList[i], i, max)
    end

    for i=#damageOutList+1, #SamDamageShare.ui.bars do
        SamDamageShare.ui.bars[i]:SetHidden(true)
        SamDamageShare.ui.namelabels[i]:SetHidden(true)
        SamDamageShare.ui.damlabels[i]:SetHidden(true)
    end

    updateAUI()
end

function onHUDmoved()
    local x, y = SDSTlw:GetScreenRect()

    SDSSavedVariables.hud.x = x
    SDSSavedVariables.hud.y = y

    local ax, ay = SDSADVTlw:GetScreenRect()

    SDSSavedVariables.advhud.x = ax
    SDSSavedVariables.advhud.y = ay
end

function newAUIBar(user, position, maxdo, maxho, maxdi)
    if(SamDamageShare.aui.namelabels[position]) then
        SamDamageShare.aui.namelabels[position]:SetHidden(false)
        SamDamageShare.aui.damagebars[position]:SetHidden(false)
        SamDamageShare.aui.damagelabels[position]:SetHidden(false)
        SamDamageShare.aui.healingbars[position]:SetHidden(false)
        SamDamageShare.aui.healinglabels[position]:SetHidden(false)
        SamDamageShare.aui.tankingbars[position]:SetHidden(false)
        SamDamageShare.aui.tankinglabels[position]:SetHidden(false)
        SamDamageShare.aui.healedbars[position]:SetHidden(false)
        SamDamageShare.aui.healedlabels[position]:SetHidden(false)

        SamDamageShare.aui.namelabels[position]:SetText(user)
        SamDamageShare.aui.damagelabels[position]:SetText(numWithCommas(StatList.getValue(SamDamageShare.fightInfo.damageOut,user)))
        SamDamageShare.aui.healinglabels[position]:SetText(numWithCommas(StatList.getValue(SamDamageShare.fightInfo.healOut,user)))
        SamDamageShare.aui.tankinglabels[position]:SetText(numWithCommas(StatList.getValue(SamDamageShare.fightInfo.damageIn,user)))
        SamDamageShare.aui.healedlabels[position]:SetText(numWithCommas(StatList.getValue(SamDamageShare.fightInfo.healIn,user)))

        SamDamageShare.aui.damagebars[position]:SetMinMax(0, maxdo)
        SamDamageShare.aui.healingbars[position]:SetMinMax(0, maxho)
        SamDamageShare.aui.tankingbars[position]:SetMinMax(0, maxdi)
        SamDamageShare.aui.healedbars[position]:SetMinMax(0, maxdi)

        SamDamageShare.aui.damagebars[position]:SetValue(StatList.getValue(SamDamageShare.fightInfo.damageOut,user))
        SamDamageShare.aui.healingbars[position]:SetValue(StatList.getValue(SamDamageShare.fightInfo.healOut,user))
        SamDamageShare.aui.tankingbars[position]:SetValue(StatList.getValue(SamDamageShare.fightInfo.damageIn,user))
        SamDamageShare.aui.healedbars[position]:SetValue(StatList.getValue(SamDamageShare.fightInfo.healIn,user))

        SamDamageShare.aui.damagebars[position]:SetAnchor(TOPRIGHT, SDSADVTlwBlockSep, TOPRIGHT, -(330+300*(StatList.getValue(SamDamageShare.fightInfo.damageOut,user)/maxdo)),10+35*(position-1))

        if(user == SDSSavedVariables.fightInfo.name) then
            SamDamageShare.aui.damagebars[position]:SetColor(220/255,0/255,0/255,170/255)
            SamDamageShare.aui.healingbars[position]:SetColor(0/255,220/255,0/255,170/255)
            SamDamageShare.aui.tankingbars[position]:SetColor(220/255,0/255,0/255,170/255)
            SamDamageShare.aui.healedbars[position]:SetColor(0/255,220/255,0/255,170/255)
        else
            SamDamageShare.aui.damagebars[position]:SetColor(150/255,19/255,19/255,170/255)
            SamDamageShare.aui.healingbars[position]:SetColor(19/255,150/255,19/255,170/255)
            SamDamageShare.aui.tankingbars[position]:SetColor(150/255,19/255,19/255,170/255)
            SamDamageShare.aui.healedbars[position]:SetColor(19/255,150/255,19/255,170/255)
        end

    else
        SDSAUInamelabel = wm:CreateControl("AUI"..position.."namelabel", SDSADVTlwBg, CT_LABEL)
        
        SDSAUIdamagebar = wm:CreateControl("AUI"..position.."damagebar", SDSADVTlwBg, CT_STATUSBAR)
        SDSAUIdamagelabel = wm:CreateControl("AUI"..position.."damagelabel", SDSADVTlwBg, CT_LABEL)

        SDSAUIhealingbar = wm:CreateControl("AUI"..position.."healingbar", SDSADVTlwBg, CT_STATUSBAR)
        SDSAUIhealinglabel = wm:CreateControl("AUI"..position.."healinglabel", SDSADVTlwBg, CT_LABEL)

        SDSAUItankingbar = wm:CreateControl("AUI"..position.."tankingbar", SDSADVTlwBg, CT_STATUSBAR)
        SDSAUItankinglabel = wm:CreateControl("AUI"..position.."tankinglabel", SDSADVTlwBg, CT_LABEL)

        SDSAUIhealedbar = wm:CreateControl("AUI"..position.."healedbar", SDSADVTlwBg, CT_STATUSBAR)
        SDSAUIhealedlabel = wm:CreateControl("AUI"..position.."healedlabel", SDSADVTlwBg, CT_LABEL)


        if(user == SDSSavedVariables.fightInfo.name) then
            SDSAUIdamagebar:SetColor(220/255,0/255,0/255,170/255)
            SDSAUIhealingbar:SetColor(0/255,220/255,0/255,170/255)
            SDSAUItankingbar:SetColor(220/255,0/255,0/255,170/255)
            SDSAUIhealedbar:SetColor(0/255,220/255,0/255,170/255)
        else
            SDSAUIdamagebar:SetColor(150/255,19/255,19/255,170/255)
            SDSAUIhealingbar:SetColor(19/255,150/255,19/255,170/255)
            SDSAUItankingbar:SetColor(150/255,19/255,19/255,170/255)
            SDSAUIhealedbar:SetColor(19/255,150/255,19/255,170/255)
        end

        SDSAUInamelabel:SetScale(1)
        SDSAUIdamagebar:SetScale(1)
        SDSAUIdamagelabel:SetScale(1)
        SDSAUIhealingbar:SetScale(1)
        SDSAUIhealinglabel:SetScale(1)
        SDSAUItankingbar:SetScale(1)
        SDSAUItankinglabel:SetScale(1)
        SDSAUIhealedbar:SetScale(1)
        SDSAUIhealedlabel:SetScale(1)

        SDSAUInamelabel:SetDrawLayer(1)
        SDSAUIdamagebar:SetDrawLayer(1)
        SDSAUIdamagelabel:SetDrawLayer(1)
        SDSAUIhealingbar:SetDrawLayer(1)
        SDSAUIhealinglabel:SetDrawLayer(1)
        SDSAUItankingbar:SetDrawLayer(1)
        SDSAUItankinglabel:SetDrawLayer(1)
        SDSAUIhealedbar:SetDrawLayer(1)
        SDSAUIhealedlabel:SetDrawLayer(1)

        SDSAUInamelabel:SetAnchor(TOPLEFT, SDSADVTlwBlockSep, TOPLEFT, 5,10+35*(position-1))
        SDSAUIdamagebar:SetAnchor(TOPRIGHT, SDSADVTlwBlockSep, TOPRIGHT, -(330+300*(StatList.getValue(SamDamageShare.fightInfo.damageOut,user)/maxdo)),10+35*(position-1))
        SDSAUIdamagelabel:SetAnchor(TOPRIGHT, SDSADVTlwBlockSep, TOPRIGHT, -635,10+35*(position-1))
        SDSAUIhealingbar:SetAnchor(TOPLEFT, SDSADVTlwBlockSep, TOPLEFT, 510,10+35*(position-1))
        SDSAUIhealinglabel:SetAnchor(TOPLEFT, SDSADVTlwBlockSep, TOPLEFT, 515,10+35*(position-1))
        SDSAUItankingbar:SetAnchor(TOPLEFT, SDSADVTlwBlockSep, TOPLEFT, 830,10+35*(position-1))
        SDSAUItankinglabel:SetAnchor(TOPLEFT, SDSADVTlwBlockSep, TOPLEFT, 835,10+35*(position-1))
        SDSAUIhealedbar:SetAnchor(TOPLEFT, SDSADVTlwBlockSep, TOPLEFT, 830,15+10+35*(position-1))
        SDSAUIhealedlabel:SetAnchor(TOPRIGHT, SDSADVTlwBlockSep, TOPRIGHT, -5,10+35*(position-1))

        SDSAUInamelabel:SetFont("GDSFontGameBig")
        SDSAUIdamagelabel:SetFont("GDSFontGameBig")
        SDSAUIhealinglabel:SetFont("GDSFontGameBig")
        SDSAUItankinglabel:SetFont("GDSFontGameBig")
        SDSAUIhealedlabel:SetFont("GDSFontGameBig")

        SDSAUInamelabel:SetText(user)
        SDSAUIdamagelabel:SetText(numWithCommas(StatList.getValue(SamDamageShare.fightInfo.damageOut,user)))
        SDSAUIhealinglabel:SetText(numWithCommas(StatList.getValue(SamDamageShare.fightInfo.healOut,user)))
        SDSAUItankinglabel:SetText(numWithCommas(StatList.getValue(SamDamageShare.fightInfo.damageIn,user)))
        SDSAUIhealedlabel:SetText(numWithCommas(StatList.getValue(SamDamageShare.fightInfo.healIn,user)))

        SDSAUInamelabel:SetDimensions(200, 25)
        SDSAUIdamagebar:SetDimensions(300, 25)
        SDSAUIhealingbar:SetDimensions(300, 25)
        SDSAUItankingbar:SetDimensions(300, 10)
        SDSAUIhealedbar:SetDimensions(300, 10)

        SDSAUIdamagebar:SetMinMax(0, maxdo)
        SDSAUIhealingbar:SetMinMax(0, maxho)
        SDSAUItankingbar:SetMinMax(0, maxdi)
        SDSAUIhealedbar:SetMinMax(0, maxdi)

        SDSAUIdamagebar:SetValue(StatList.getValue(SamDamageShare.fightInfo.damageOut,user))
        SDSAUIhealingbar:SetValue(StatList.getValue(SamDamageShare.fightInfo.healOut,user))
        SDSAUItankingbar:SetValue(StatList.getValue(SamDamageShare.fightInfo.damageIn,user))
        SDSAUIhealedbar:SetValue(StatList.getValue(SamDamageShare.fightInfo.healIn,user))

        SamDamageShare.aui.namelabels[position] = SDSAUInamelabel
        SamDamageShare.aui.damagebars[position] = SDSAUIdamagebar
        SamDamageShare.aui.damagelabels[position] = SDSAUIdamagelabel
        SamDamageShare.aui.healingbars[position] = SDSAUIhealingbar
        SamDamageShare.aui.healinglabels[position] = SDSAUIhealinglabel
        SamDamageShare.aui.tankingbars[position] = SDSAUItankingbar
        SamDamageShare.aui.tankinglabels[position] = SDSAUItankinglabel
        SamDamageShare.aui.healedbars[position] = SDSAUIhealedbar
        SamDamageShare.aui.healedlabels[position] = SDSAUIhealedlabel
    end
end


local AUIsortBy = "name"
local AUIinverted = false

function updateAUI()
    local userList = {}

    if AUIsortBy == "name" then
        damageOutList = SamDamageShare.fightInfo.damageOut.content

        for _,element in pairs(damageOutList) do
            if not AUIinverted then
                --insertion sort new element
                if #(userList) == 0 then   
                    table.insert(userList, element.name)
                else
                    inserted = false

                    for i=#(userList),1,-1 do
                        if element.name >= userList[i] then
                            userList[i+1] = element.name
                            inserted = true
                            break
                        else
                            userList[i+1] = userList[i]
                        end
                    end

                    if not inserted then
                        userList[1] = element.name
                    end
                end

            else
                --insertion sort new element
                if #(userList) == 0 then   
                    table.insert(userList, element.name)
                else
                    inserted = false

                    for i=#(userList),1,-1 do
                        if element.name <= userList[i] then
                            userList[i+1] = element.name
                            inserted = true
                            break
                        else
                            userList[i+1] = userList[i]
                        end
                    end

                    if not inserted then
                        userList[1] = element.name
                    end
                end
            end
        end

    elseif AUIsortBy == "damage" then
        damageOutList = SamDamageShare.fightInfo.damageOut.content

        for i,element in pairs(damageOutList) do
            if AUIinverted then
                userList[#damageOutList-(i-1)] = element.name
            else
                userList[i] = element.name
            end
        end

    elseif AUIsortBy == "healing" then
        healOutList = SamDamageShare.fightInfo.healOut.content

        for i,element in pairs(healOutList) do
            if AUIinverted then
                userList[#healOutList-(i-1)] = element.name
            else
                userList[i] = element.name
            end
        end

    elseif AUIsortBy == "tanking" then
        damageInList = SamDamageShare.fightInfo.damageIn.content

        for i,element in pairs(damageInList) do
            if AUIinverted then
                userList[#damageInList-(i-1)] = element.name
            else
                userList[i] = element.name
            end
        end

    elseif AUIsortBy == "healed" then
        healInList = SamDamageShare.fightInfo.healIn.content

        for i,element in pairs(healInList) do
            if AUIinverted then
                userList[#healInList-(i-1)] = element.name
            else
                userList[i] = element.name
            end
        end

    end
    
    local maxdo
    local maxho
    local maxdi

    if SamDamageShare.fightInfo.damageOut.content[1] then maxdo = SamDamageShare.fightInfo.damageOut.content[1].value else maxdo = 0 end
    if SamDamageShare.fightInfo.healOut.content[1] then maxho = SamDamageShare.fightInfo.healOut.content[1].value  else maxho = 0 end
    if SamDamageShare.fightInfo.damageIn.content[1] then maxdi = SamDamageShare.fightInfo.damageIn.content[1].value  else maxdi = 0 end

    for i=1, #userList do
        newAUIBar(userList[i], i, maxdo, maxho, maxdi)
    end

    if #SamDamageShare.aui.namelabels <= #userList then return end
    for i=#userList+1, #SamDamageShare.aui.namelabels do
        SamDamageShare.aui.namelabels[i]:SetHidden(true)
        SamDamageShare.aui.damagebars[i]:SetHidden(true)
        SamDamageShare.aui.damagelabels[i]:SetHidden(true)
        SamDamageShare.aui.healingbars[i]:SetHidden(true)
        SamDamageShare.aui.healinglabels[i]:SetHidden(true)
        SamDamageShare.aui.tankingbars[i]:SetHidden(true)
        SamDamageShare.aui.tankinglabels[i]:SetHidden(true)
        SamDamageShare.aui.healedbars[i]:SetHidden(true)
        SamDamageShare.aui.healedlabels[i]:SetHidden(true)
    end

end


local lastSendTime = 0
local lastSentValues = {}
local messageHandler = {}

function messageHandler.TriggerSend()
    local now = GetGameTimeMilliseconds()
	
    if (now - lastSendTime) < SDSSavedVariables.timeout then return end
    
    error = {}
    table.insert(error, (SDSSavedVariables.fightInfo.damageOut-lastSentValues.damageOut) / (SDSSavedVariables.fightInfo.damageOut+1))
    table.insert(error, (SDSSavedVariables.fightInfo.damageIn-lastSentValues.damageIn) / (SDSSavedVariables.fightInfo.damageIn+1))
    table.insert(error, (SDSSavedVariables.fightInfo.healOut-lastSentValues.healOut) / (SDSSavedVariables.fightInfo.healOut+1))
    table.insert(error, (SDSSavedVariables.fightInfo.healIn-lastSentValues.healIn) / (SDSSavedVariables.fightInfo.healIn+1))

    lastSentValues.damageOut = lastSentValues.damageOut * 0.99
    lastSentValues.damageIn = lastSentValues.damageIn * 0.99
    lastSentValues.healOut = lastSentValues.healOut * 0.99
    lastSentValues.healIn = lastSentValues.healIn * 0.99

    smallest = error[1]
    smallestPos = 1

    for i=2, 4 do
        if (error[i] > smallest) then
            smallest = error[i]
            smallestPos = i
        end
    end

    if (smallestPos == 1) then
        messageHandler.Send(false,false,false,false,SDSSavedVariables.fightInfo.damageOut)
        --chat:Print("do\n"..error[1].."\n"..error[2].."\n"..error[3].."\n"..error[4])
    elseif (smallestPos == 2) then
        messageHandler.Send(false,true,false,false,SDSSavedVariables.fightInfo.damageIn)
        --chat:Print("di\n"..error[1].."\n"..error[2].."\n"..error[3].."\n"..error[4])
    elseif (smallestPos == 3) then
        messageHandler.Send(true,false,false,false,SDSSavedVariables.fightInfo.healOut)
        --chat:Print("ho\n"..error[1].."\n"..error[2].."\n"..error[3].."\n"..error[4])
    elseif (smallestPos == 4) then
        messageHandler.Send(true,true,false,false,SDSSavedVariables.fightInfo.healIn)
        --chat:Print("hi\n"..error[1].."\n"..error[2].."\n"..error[3].."\n"..error[4])
    end

end

local function IntToBits(value, length, bits) -- bits is optional, will be used to attach new bits to it
	
	local bits = bits or {}
	local offset = #bits
	
    for i = length, 1, -1 do
	
		local bit = math.fmod(value, 2)
		
        bits[i + offset] = (bit == 1)
		
        value = (value - bit) / 2
		
    end
	
	return bits
end

local function BitsToInt(bits, length) -- length is optional, if used it will return the remaining bits
	
	local length = length or #bits
	local value = 0
	
    for i = 1, length do
	
		local bit = (table.remove(bits, 1) and 1) or 0
		value = value + bit * 2 ^ (length - i)
    
	end
	
	return value, bits
	
end

function messageHandler.Send(healDamage, inOut, unused1, unused2, value)	
	local data = {}
	local index, bitIndex = 1, 1 

    --4 bit control nibble
	index, bitIndex = LGS:WriteBit(data, index, bitIndex, healDamage)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, inOut)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, unused1)
    index, bitIndex = LGS:WriteBit(data, index, bitIndex, unused2)
    
    exponent = 0;
    limit = math.pow(2,16)

    while value >= limit do
        value = value / 2
        exponent = exponent + 1
    end

    exponentBits = {}
    exponentBits = IntToBits(exponent, 4, exponentBits)

    bits = {}
    bits = IntToBits(value, 16, bits)

    --4 bit exponent
    for i=1,4 do
        index, bitIndex = LGS:WriteBit(data, index, bitIndex, exponentBits[i])      
    end

    --16 bit mantissa
    for i=1, 16 do
        index, bitIndex = LGS:WriteBit(data, index, bitIndex, bits[i])
    end

    --send data
    if LGS:Send(22, data) then	
		lastSendTime = GetGameTimeMilliseconds()
		
        if healDamage then
            if inOut then
                lastSentValues.healIn = SDSSavedVariables.fightInfo.healIn
            else
                lastSentValues.healOut = SDSSavedVariables.fightInfo.healOut
            end
        else
            if inOut then
                lastSentValues.damageIn = SDSSavedVariables.fightInfo.damageIn
            else
                lastSentValues.damageOut = SDSSavedVariables.fightInfo.damageOut
            end
        end
	end
end

local function OnData(unitTag, data, isSelf)
    if isSelf then return end

	-- Read Flags
	local index = 1 
    local bitIndex = 1
    
    local healDamage = false
    local inOut = false
    local unused1 = false
    local unused2 = false
    
    --read control nibble
    healDamage, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    inOut, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    unused1, index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    unused2, index, bitIndex = LGS:ReadBit(data, index, bitIndex)

    if unused1 or unused2 then return end
        
    --4 bit exponent
	local exponentBits = {}
	for i=1, 4 do
        exponentBits[i], index, bitIndex = LGS:ReadBit(data, index, bitIndex)
        --if exponentBits[i] then chat:Print("in 2 1") else chat:Print("in 2 0") end
    end
    
    --16 bit mantissa
    local bits = {}
    for i=1, 16 do
        bits[i], index, bitIndex = LGS:ReadBit(data, index, bitIndex)
    end

    local exponent = BitsToInt(exponentBits)
    --chat:Print("in 10 "..exponent) 
    
    local value = BitsToInt(bits) * math.pow(2,exponent)
    
    if healDamage then
        if inOut then
            StatList.editList(SamDamageShare.fightInfo.healIn, Stat.new(GetUnitName(unitTag), value))
        else
            StatList.editList(SamDamageShare.fightInfo.healOut, Stat.new(GetUnitName(unitTag), value))
        end
    else
        if inOut then
            StatList.editList(SamDamageShare.fightInfo.damageIn, Stat.new(GetUnitName(unitTag), value))
        else
            StatList.editList(SamDamageShare.fightInfo.damageOut, Stat.new(GetUnitName(unitTag), value))
            updateUI()
        end
    end

    messageHandler.TriggerSend()
end




damageTypes = {
    [ACTION_RESULT_DAMAGE] = true,
	[ACTION_RESULT_DOT_TICK] = true,		
	[ACTION_RESULT_BLOCKED_DAMAGE] = true,
	[ACTION_RESULT_DAMAGE_SHIELDED] = true,
	[ACTION_RESULT_CRITICAL_DAMAGE] = true,	
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true
}

healTypes = {
	[ACTION_RESULT_HOT_TICK] = true,
	[ACTION_RESULT_HEAL] = true,
	[ACTION_RESULT_CRITICAL_HEAL] = true,
	[ACTION_RESULT_HOT_TICK_CRITICAL] = true
}

function SamDamageShare.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if sourceType == COMBAT_UNIT_TYPE_PLAYER and damageTypes[result] then
        SDSSavedVariables.fightInfo.name = string.sub(sourceName,1,-4)
        SDSSavedVariables.fightInfo.damageOut = SDSSavedVariables.fightInfo.damageOut + hitValue
        --StatList.editList(SamDamageShare.fightInfo.damageOut, Stat.new(sourceName, SDSSavedVariables.fightInfo.damageOut))
        StatList.editList(SamDamageShare.fightInfo.damageOut, Stat.new(string.sub(sourceName,1,-4), SDSSavedVariables.fightInfo.damageOut))
        updateUI()

    elseif sourceType == COMBAT_UNIT_TYPE_PLAYER_PET and damageTypes[result] then
        SDSSavedVariables.fightInfo.damageOut = SDSSavedVariables.fightInfo.damageOut + hitValue

    elseif targetType == COMBAT_UNIT_TYPE_PLAYER and damageTypes[result] then
        SDSSavedVariables.fightInfo.name = string.sub(targetName,1,-4)
        SDSSavedVariables.fightInfo.damageIn = SDSSavedVariables.fightInfo.damageIn + hitValue
        --StatList.editList(SamDamageShare.fightInfo.damageIn, Stat.new(targetName, SDSSavedVariables.fightInfo.damageIn))
        StatList.editList(SamDamageShare.fightInfo.damageIn, Stat.new(string.sub(targetName,1,-4), SDSSavedVariables.fightInfo.damageIn))
        updateUI()

    elseif targetType == COMBAT_UNIT_TYPE_PLAYER_PET and damageTypes[result] then
        SDSSavedVariables.fightInfo.damageIn = SDSSavedVariables.fightInfo.damageIn + hitValue

    elseif sourceType == COMBAT_UNIT_TYPE_PLAYER and healTypes[result] and string.sub(sourceName,1,-4) == SDSSavedVariables.fightInfo.name then
        SDSSavedVariables.fightInfo.healOut = SDSSavedVariables.fightInfo.healOut + hitValue
        --StatList.editList(SamDamageShare.fightInfo.healOut, Stat.new(sourceName, SDSSavedVariables.fightInfo.healOut))
        StatList.editList(SamDamageShare.fightInfo.healOut, Stat.new(string.sub(sourceName,1,-4), SDSSavedVariables.fightInfo.healOut))
        updateUI()

    elseif sourceType == COMBAT_UNIT_TYPE_PLAYER_PET and healTypes[result] and string.sub(sourceName,1,-4) == SDSSavedVariables.fightInfo.name then
        SDSSavedVariables.fightInfo.healOut = SDSSavedVariables.fightInfo.healOut + hitValue
    end
    if targetType == COMBAT_UNIT_TYPE_PLAYER and healTypes[result] and string.sub(targetName,1,-4) == SDSSavedVariables.fightInfo.name then
        SDSSavedVariables.fightInfo.healIn = SDSSavedVariables.fightInfo.healIn + hitValue
        --StatList.editList(SamDamageShare.fightInfo.healIn, Stat.new(targetName, SDSSavedVariables.fightInfo.healIn))
        StatList.editList(SamDamageShare.fightInfo.healIn, Stat.new(string.sub(targetName,1,-4), SDSSavedVariables.fightInfo.healIn))
        updateUI()

    elseif targetType == COMBAT_UNIT_TYPE_PLAYER_PET and healTypes[result] and string.sub(targetName,1,-4) == SDSSavedVariables.fightInfo.name then
        SDSSavedVariables.fightInfo.healIn = SDSSavedVariables.fightInfo.healIn + hitValue

    end
    
    messageHandler.TriggerSend()
end

function SamDamageShare.reset()
    lastSentValues.damageOut = -1
    lastSentValues.damageIn = -1
    lastSentValues.healOut = -1
    lastSentValues.healIn = -1

    SamDamageShare.fightInfo = {}

    SamDamageShare.fightInfo.damageOut = StatList.new()
    SamDamageShare.fightInfo.damageIn = StatList.new()
    SamDamageShare.fightInfo.healOut = StatList.new()
    SamDamageShare.fightInfo.healIn = StatList.new()
end

local defaults = {
    hud = {
        x = 10,
        y = 10
    },
    advhud = {
        y = 10,
        x = 10
    },
    timeout = 1000,
    fightInfo = {
        damageOut = 0,
        damageIn = 0,
        healOut = 0,
        healIn = 0,
        name = "",
    },
    locked = false,
}

--initialise the addon
function SamDamageShare:Initialise()
    SamDamageShare.ui = {}
    SamDamageShare.ui.bars = {}
    SamDamageShare.ui.namelabels = {}
    SamDamageShare.ui.damlabels = {}

    SamDamageShare.aui = {}
    SamDamageShare.aui.namelabels = {}
    SamDamageShare.aui.damagebars = {}
    SamDamageShare.aui.damagelabels = {}
    SamDamageShare.aui.healingbars = {}
    SamDamageShare.aui.healinglabels = {}
    SamDamageShare.aui.tankingbars = {}
    SamDamageShare.aui.tankinglabels = {}
    SamDamageShare.aui.healedbars = {}
    SamDamageShare.aui.healedlabels = {}

    function SDSclicked()
        chat:Print("clicked")
    end
    SDSADVTlwNameLabel:SetHandler("OnClicked", SDSclicked)

    SDSSavedVariables = ZO_SavedVars:NewAccountWide("SDSSavedVariables", 1, nil, defaults)

    SamDamageShare.reset()
    
    SDSTlw:ClearAnchors()
    SDSTlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SDSSavedVariables.hud.x, SDSSavedVariables.hud.y)
    SDSADVTlw:ClearAnchors()
    SDSADVTlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SDSSavedVariables.advhud.x, SDSSavedVariables.advhud.y)


    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, self.OnCombatEvent)

    --on ui change
    SDSTlw:SetHandler("OnMoveStop", onHUDmoved)
    SDSADVTlw:SetHandler("OnMoveStop", onHUDmoved)

    --register group ping listener
    LGS.cm:RegisterCallback(22, OnData)

    lock()
    toggleUI()
end
 
--event handeler function, called when the addon is loaded
function SamDamageShare.OnAddOnLoaded(event, addonName)
  --the event fires each time *any* addon loads - only initialise SamDamageShare
  if addonName == SamDamageShare.name then
    SamDamageShare:Initialise()
  end
end
 
--load the addon
EVENT_MANAGER:RegisterForEvent(SamDamageShare.name, EVENT_ADD_ON_LOADED, SamDamageShare.OnAddOnLoaded)

function toggleUI()
    AUIhidden = not AUIhidden
    SDSADVTlw:SetHidden(AUIhidden)
    SDSTlw:SetHidden(not AUIhidden)
    chat:Print("changed ui") 
end

function setDelay(delay)
    newDelay = delay or 1000
    SDSSavedVariables.timeout = newDelay
    chat:Print("delay has been set to "..SDSSavedVariables.timeout) 
end

function setDefaults()
    SDSSavedVariables = defaults
    chat:Print("reset to defaults") 
end

function sortBy(sortBy)
    if sortBy == AUIsortBy then
        AUIinverted = not AUIinverted
        chat:Print("now sorting by: "..sortBy)
        updateUI()
    elseif sortBy == "damage" or sortBy =="healing" or sortBy == "tanking" or sortBy == "healed" or sortBy ==  "name" then
        AUIsortBy = sortBy
        AUIinverted = false
        chat:Print("now sorting by: "..sortBy)
        updateUI()
    end 
end

function invert()
    AUIinverted = not AUIinverted
    chat:Print("inverted")
    updateUI()
end

function lock()
    SDSTlw:SetMovable(not SDSSavedVariables.locked)
    SDSADVTlw:SetMovable(not SDSSavedVariables.locked)
    SDSTlw:SetMouseEnabled(not SDSSavedVariables.locked)
    SDSADVTlw:SetMouseEnabled(not SDSSavedVariables.locked)
end

function toggleLock()
    SDSSavedVariables.locked = not SDSSavedVariables.locked
    lock()
    if SDSSavedVariables.locked then chat:Print("locked")
    else chat:Print("unlocked") end
end

function resetValues()
    SamDamageShare.reset()

    SDSSavedVariables.fightInfo.name = ""
    
    SDSSavedVariables.fightInfo.damageOut = 0
    SDSSavedVariables.fightInfo.damageIn = 0
    SDSSavedVariables.fightInfo.healOut = 0
    SDSSavedVariables.fightInfo.healIn = 0
end

SLASH_COMMANDS["/ui"] = toggleUI
SLASH_COMMANDS["/sdsui"] = toggleUI
SLASH_COMMANDS["/sdsreset"] = resetValues
SLASH_COMMANDS["/sdsupdate"] = updateUI
SLASH_COMMANDS["/sdsdelay"] = setDelay
SLASH_COMMANDS["/sdsdefaults"] = setDefaults
SLASH_COMMANDS["/sdslock"] = toggleLock

SLASH_COMMANDS["/sdsinvert"] = invert
SLASH_COMMANDS["/sdssortby"] = sortBy
--SLASH_COMMANDS["/sdssortbyname"] = sortBy("name")
--SLASH_COMMANDS["/sdssortbydamage"] = sortBy("damage")
--SLASH_COMMANDS["/sdssortbyhealing"] = sortBy("healing")
--SLASH_COMMANDS["/sdssortbytanking"] = sortBy("tanking")
--SLASH_COMMANDS["/sdssortbyhealed"] = sortBy("healed")