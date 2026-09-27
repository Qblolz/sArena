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
	local _, event, _, sourceGUID, sourceName, sourceFlags, _, guid, destName, destFlags, _, spellId, spellName, _, auraType = CombatLogGetCurrentEventInfo()

	if UnitGUID(self.unit) ~= sourceGUID then return end
	if event ~= "SPELL_CAST_SUCCESS" then return end

	--if "Qb" ~= sourceName then return end

	local arenaFrame = self:GetParent()
	local racial = arenaFrame.racial

	-- default trinket
	if spellId == 42292 then
		self.time = tonumber(120)
		self.starttime = GetTime()
		CooldownFrame_Set(self.Cooldown, GetTime(), 120, 1)

		local overallTime = addon.overallCooldown[select(2, UnitRace(self.unit))]
		if overallTime == nil then return end

		if overallTime and addon:isNeedStart(racial, overallTime) then
			racial.time = tonumber(overallTime)
			racial.starttime = GetTime()
			CooldownFrame_Set(racial.Cooldown, GetTime(), overallTime, 1)
		end
	end
end


function module:OnEvent(event, ...)
	for i = 1, MAX_ARENA_ENEMIES do
		local TR = nil
		local arenaFrame = _G["ArenaEnemyFrame"..i]
		if arenaFrame.CC then
			arenaFrame.CC:Hide()
		end

		if (arenaFrame["TR"] == nil) then
			TR = CreateFrame("Frame", nil, arenaFrame, "sArenaIconTemplate")
			TR.unit = arenaFrame.unit
			TR.time = 0
			TR.starttime = 0
			TR:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			TR:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
			TR.COMBAT_LOG_EVENT_UNFILTERED = TRINKET_UNIT_SPELLCAST_SUCCEEDED
			arenaFrame.TR = TR
		else
			TR = arenaFrame.TR
		end

		TR.Cooldown:SetCooldown(0, 0)

		if (UnitFactionGroup('player') == "Horde") then
			TR.Icon:SetTexture("Interface\\Icons\\INV_Jewelry_Necklace_38")
		else
			TR.Icon:SetTexture("Interface\\Icons\\INV_Jewelry_Necklace_37")
		end
		
		if event == "ADDON_LOADED" then
			TR:SetMovable(true)
			addon:SetupDrag(self, true, TR)

			TR:SetFrameLevel(4)

			TR.Cooldown:ClearAllPoints()
			TR.Cooldown:SetPoint("TOPLEFT", 1, -1)
			TR.Cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
		elseif event == "TEST_MODE" then
			if addon.testMode then
				TR:EnableMouse(true)
				TR.Cooldown:SetCooldown(GetTime(), random(45,120))
				TR.Icon:Show()
			else
				TR:EnableMouse(false)
				TR.Cooldown:Hide()
				TR.Icon:Hide()
			end
		elseif event == "UPDATE_SETTINGS" then
			TR:ClearAllPoints()
			TR:SetPoint("CENTER", self.db.x, self.db.y)
			TR:SetSize(self.db.size, self.db.size)
		end
	end

	if event == "ADDON_LOADED" then
		self:OnEvent("UPDATE_SETTINGS")
	end
end
