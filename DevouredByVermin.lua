local Addon = CreateFrame("FRAME", "BloodwormTracker");


local wormsTable = {};

local bloodwormsHP = UnitHealthMax("player")*0.35;

local function getAmountHeal(bloodwormGUID)
	5179	14798
	5382	15378

end


Addon:SetScript("OnEvent", function(self, event, ...)
	--theres no need to check the event, because there is only one to track
	local time, type, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, spellName, _, auraType, numStack = ...;
	if(type == "SPELL_SUMMON" and sourceName == UnitName("player") and destName == "Bloodworm") then
		wormsTable[destGUID] = 0 ;
		print("A bloodworm has poped up");
	elseif(type == "SPELL_AURA_APPLIED_DOSE" and sourceName == "Bloodworm" and spellID == 81277) then
		wormsTable[destGUID] = wormsTable[destGUID] + 1;
		print("The stack is " .. numStack);
--	elseif(type == "SPELL_AURA_APPLIED" and sourceName == "Bloodworm" and spellID == 81277) then
--		--this condition might not be necessary, it only triggers when the worm spawns
--		print("Buff applied");
	elseif(type == "SPELL_AURA_REMOVED" and sourceName == "Bloodworm" and spellID == 81277) then
		table.remove(wormsTable, destGUID);
		print("PUFF, Mega-Heal");
	end
end)

Addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

