local Addon = CreateFrame("FRAME", "BloodwormTracker");

local wormsTable = {};
local wormsTableSize = 0;

local frameAnchor = nil;


local function getAmountHeal(stack)
	local heal = (stack * 0.10 * UnitHealthMax("player")*0.35)/1000;
	return math.floor(heal * 10 + 0.5) / 10;
end

local function reorderIcons()
	local i = 0;
	for guid, table in pairs(wormsTable) do
		table["frame"]:SetPoint("LEFT", frameAnchor, i*32, 0);
		i = i + 1;
	end
end

local function createFrameIcon(index)
	local frame = CreateFrame("FRAME", nil, UIParent);
	frame:SetSize(32, 32);
	frame:SetPoint("LEFT", frameAnchor, index*32, 0);

	frame.icon = frame:CreateTexture("IconTexture", "BACKGROUND")
	frame.icon:SetWidth(32)
	frame.icon:SetHeight(32)
	frame.icon:SetPoint("TOPLEFT", 0, 0)
	frame.icon:SetTexture("Interface\\ICONS\\Spell_DeathKnight_BloodBoil.png");

	frame.stack = frame:CreateFontString("IconStack", "OVERLAY", "GameFontNormal")
	frame.stack:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
	frame.stack:SetPoint("TOPRIGHT", 3, 0);

	frame.heal = frame:CreateFontString("IconHeal", "OVERLAY", "GameFontNormal")
	frame.heal:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
	frame.heal:SetTextColor(0, 1, 0.2, 1);
	frame.heal:SetPoint("CENTER", 0, 0);

	local total = 0;
	frame:SetScript("OnUpdate", function(self, elapsed)
		total = total + elapsed;
		if(total > 20) then
			frame:SetScript("OnUpdate", nil);
			frame:Hide();
			for guid, table in pairs(wormsTable) do
				if(self == table["frame"]) then
					wormsTable[guid] = nil;
					wormsTableSize = wormsTableSize - 1;
					reorderIcons();
				end
			end
		end
	end)

	frame:Show();

	return frame;
end

local function initFrameAnchor()
	frameAnchor = CreateFrame("FRAME", "DBVanchor", UIParent);
	frameAnchor:SetSize(32, 32);
	frameAnchor:SetPoint("CENTER", UIParent, "CENTER");

	frameAnchor.icon = frameAnchor:CreateTexture("IconTexture", "BACKGROUND");
	frameAnchor.icon:SetWidth(32)
	frameAnchor.icon:SetHeight(32)
	frameAnchor.icon:SetPoint("TOPLEFT", 0, 0)
	frameAnchor.icon:SetTexture("Interface\\ICONS\\Spell_DeathKnight_BloodBoil.png");


	frameAnchor:EnableMouse(true)
	frameAnchor:SetMovable(true);


	frameAnchor:SetScript("OnMouseDown", function(self, button)
		if(button == "LeftButton") then
			self:StartMoving();
		end
	end)
	frameAnchor:SetScript("OnMouseUp", function(self, button)
		self:StopMovingOrSizing();
		local point,_,relativePoint,x,y = self:GetPoint();
		DevouredByVerminSV[UnitName("player")] = { point, relativePoint, x, y };
	end)

	frameAnchor:Hide();
end





SLASH_DevouredByVermin1, SLASH_DevouredByVermin2 = "/devouredbyvermin", "/dbv";

function SlashCmd(cmd)
	if (cmd:match"unlock") then
		print("unlock")
		frameAnchor:Show();
	elseif (cmd:match"lock") then
		frameAnchor:Hide();
	end
end

SlashCmdList["DevouredByVermin"] = SlashCmd;

Addon:SetScript("OnEvent", function(self, event, ...)

		if(event == "VARIABLES_LOADED") then
			initFrameAnchor();
			if type(DevouredByVerminSV) ~= "table" then
				DevouredByVerminSV = {};
				local point, relativePoint, x, y = frameAnchor:GetPoint();
				DevouredByVerminSV[UnitName("player")] = { point, relativePoint, x, y};
			elseif(DevouredByVerminSV[UnitName("player")]) then
				local point, relativePoint, x, y = DevouredByVerminSV[UnitName("player")][1], DevouredByVerminSV[UnitName("player")][2], DevouredByVerminSV[UnitName("player")][3], DevouredByVerminSV[UnitName("player")][4];
				frameAnchor:SetPoint(point, UIParent, relativePoint, x, y);
			else
				local point, relativePoint, x, y = frameAnchor:GetPoint();
				DevouredByVerminSV[UnitName("player")] = { point, relativePoint, x, y};
			end
		else
			local time, type, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, spellName, _, auraType, numStack = ...;
			if(type == "SPELL_SUMMON" and sourceName == UnitName("player") and destName == "Bloodworm") then
				destGUID = tostring(destGUID);
				local frame = createFrameIcon(wormsTableSize);
				wormsTable[destGUID] = { stack = 0, frame = frame };
				wormsTableSize = wormsTableSize + 1;
			elseif(wormsTable[destGUID] and type == "SPELL_AURA_APPLIED_DOSE" and sourceName == "Bloodworm" and spellID == 81277) then
				destGUID = tostring(destGUID);
				wormsTable[destGUID]["stack"] = numStack;
				wormsTable[destGUID]["frame"].stack:SetText(numStack);
				wormsTable[destGUID]["frame"].heal:SetText(getAmountHeal(numStack) .. "k");
			elseif(wormsTable[destGUID] and type == "SPELL_INSTAKILL" and sourceName == "Bloodworm" and spellID == 81280) then
				destGUID = tostring(destGUID);
				wormsTable[destGUID]["frame"]:Hide();
				wormsTable[destGUID] = nil;
				wormsTableSize = wormsTableSize - 1;
				reorderIcons();
			end
		end
end)



Addon:RegisterEvent("VARIABLES_LOADED");
Addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

