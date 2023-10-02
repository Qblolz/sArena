local addonName, addon = ...
local module = addon:CreateModule("Trinkets")

module.defaultSettings = {
	x = -74,
	y = -3,
	size = 18,
	hideCountdownNumbers = false,
}

module.optionsTable = {
	size = {
		order = 1,
		type = "range",
		name = "Size",
		min = 10,
		max = 128,
		step = 1,
		bigStep = 2,
		set = module.UpdateSettings,
	}
}

function TRINKET_UNIT_SPELLCAST_SUCCEEDED(self, ...)
	local _, event, sourceGUID, sourceName, _, destGUID, destName, _, spellId, spellName, _, _, _, _, _ = select(1,...)

	if UnitGUID(self.unit) ~= sourceGUID then return end
	if event ~= "SPELL_CAST_SUCCESS" then return end
	
	--if "Qb" ~= sourceName then return end
	
	local arenaFrame = self:GetParent()
	local racial = arenaFrame.racial
	
	-- default trinket
	if spellId == 42292 then 
		self.time = tonumber(120)
		self.starttime = GetTime()
		CooldownFrame_SetTimer(self.cooldown, GetTime(), 120, 1)

		local overallTime;

		for key = 1, 40 do
			local _, _, icon, _, _, duration, expirationTime, _, _, _, spellID = UnitAura(self.unit, key, "HARMFUL")

			if spellID ~= nil and addon.overallCooldown[spellID] then
				overallTime = addon.overallCooldown[spellID]
			end
		end

		if overallTime == nil then return end

		if overallTime and addon:isNeedStart(racial, overallTime) then
			racial.time = tonumber(overallTime)
			racial.starttime = GetTime()
			CooldownFrame_SetTimer(racial.cooldown, GetTime(), overallTime, 1)
		end
	end
end


function module:OnEvent(event, ...)
	if event == "UNIT_AURA" then
		return;
	end

	for i = 1, MAX_ARENA_ENEMIES do
		local CC = nil
		local arenaFrame = _G["ArenaEnemyFrame"..i]
		
		if (arenaFrame["CC"] == nil) then
			CC = CreateFrame("Frame", nil, arenaFrame, "sArenaIconTemplate")
			CC.unit = arenaFrame.unit
			CC.time = 0
			CC.starttime = 0
			CC:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			CC:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
			CC.COMBAT_LOG_EVENT_UNFILTERED = TRINKET_UNIT_SPELLCAST_SUCCEEDED
			arenaFrame.CC = CC
		else
			CC = arenaFrame.CC
		end
		
		CC.cooldown:SetCooldown(0, 0)
		
		if event == "ADDON_LOADED" then
			CC:SetMovable(true)
			addon:SetupDrag(self, true, CC)

			CC:SetFrameLevel(4)

			CC.cooldown:ClearAllPoints()
			CC.cooldown:SetPoint("TOPLEFT", 1, -1)
			CC.cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
			
			CC.Icon:SetTexture(UnitFactionGroup('player') == "Horde" and "Interface\\Icons\\inv_jewelry_trinketpvp_02" or "Interface\\Icons\\inv_jewelry_trinketpvp_01")
		elseif event == "TEST_MODE" then
			if addon.testMode then
				CC:EnableMouse(true)
				CC.cooldown:SetCooldown(GetTime(), random(45,120))
			else
				CC:EnableMouse(false)
				CC.cooldown:Hide()
			end
		elseif event == "UPDATE_SETTINGS" then
			CC:ClearAllPoints()
			CC:SetPoint("CENTER", self.db.x, self.db.y)
			CC:SetSize(self.db.size, self.db.size)
		end
	end

	if event == "ADDON_LOADED" then
		self:OnEvent("UPDATE_SETTINGS")
	end
end