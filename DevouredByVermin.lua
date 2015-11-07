local Addon = CreateFrame("FRAME", "BloodwormTracker");

local wormsTable = {};
local bloodwormsHP = UnitHealthMax("player")*0.35;



local function getAmountHeal(bloodwormGUID)
	return wormsTable[bloodwormGUID] * 0.10 * bloodwormsHP;
end


local function createFrameIcon()
	local frame = CreateFrame("FRAME", nil, UIParent);
	frame:SetSize(32, 32);
	frame:SetPoint("CENTER", UIParent, "CENTER");
    
    frame.icon = frame:CreateTexture("IconTexture", "BACKGROUND")
    frame.icon:SetWidth(32)
    frame.icon:SetHeight(32)
    frame.icon:SetPoint("TOPLEFT", 0, 0)
    frame.icon:SetTexture("Interface\\ICONS\\Spell_DeathKnight_BloodBoil.png");
    
    frame.stack = frame:CreateFontString("IconStack", "OVERLAY", "GameFontNormal")
    frame.stack:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE");
    frame.stack:SetPoint("CENTER", 0, 0)
    
    frame:EnableMouse(true)
    frame:SetMovable(true);
    
    frame:SetScript("OnMouseDown", function(self, button)
    	if(IsAltKeyDown() and button == "LeftButton") then
    		self:StartMoving();
    	end
    end)
    frame:SetScript("OnMouseUp", function(self, button)
		self:StopMovingOrSizing();
    end)
    
    frame:Show();
    
    return frame;
end


Addon:SetScript("OnEvent", function(self, event, ...)
	--theres no need to check the event, because there is only one to track
	local time, type, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, spellName, _, auraType, numStack = ...;
	if(type == "SPELL_SUMMON" and sourceName == UnitName("player") and destName == "Bloodworm") then
		destGUID = tostring(destGUID);
		print("A bloodworm has poped up");
		local frame = createFrameIcon();
		wormsTable[destGUID] = { stack = 0, frame = frame };
	elseif(type == "SPELL_AURA_APPLIED_DOSE" and sourceName == "Bloodworm" and spellID == 81277) then
		destGUID = tostring(destGUID);
		wormsTable[destGUID]["stack"] = numStack;
		wormsTable[destGUID]["frame"].stack:SetText(numStack);
		print("The stack is " .. numStack);
	elseif(type == "SPELL_AURA_REMOVED" and sourceName == "Bloodworm" and spellID == 81277) then
		destGUID = tostring(destGUID);
		wormsTable[destGUID]["frame"]:Hide();
		wormsTable[destGUID] = nil;
		print("PUFF, Mega-Heal");
	end
end)

Addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

