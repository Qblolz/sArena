local addonName, addon = ...
local module = addon:CreateModule("Racials")

local races = {
	[1] = "Human",
	[2] = "Scourge",
	[3] = "Tauren",
	[4] = "BloodElf",
	[5] = "Orc",
	[6] = "Troll",
	[7] = "NightElf",
	[8] = "Draenei",
	[9] = "Gnome",
	[10] = "Dwarf",
	[11] = "None"
}

raceIcons = {
	Human = {
		id = 59752,
		icon = select(3, GetSpellInfo(59752)),
		cd = 120,
	},
	Scourge = {
		id = 7744,
		icon = select(3, GetSpellInfo(7744)),
		cd = 120,
	},
	Draenei = {
		id = 28880,
		icon = select(3, GetSpellInfo(28880)),
		alt = {["59542"] = 1, ["59543"] = 1, ["59544"] = 1, ["59545"] = 1, ["59547"] = 1, ["59548"] = 1},
		cd = 120,
	},
	Orc = {
		id = 20572,
		icon = select(3, GetSpellInfo(20572)),
		alt = {["33697"] = 1, ["33702"] = 1},
		cd = 120,
	},
	BloodElf = { --синд
		id = 25046,
		alt = {["28730"] = 1, ["50613"] = 1},
		icon = select(3, GetSpellInfo(25046)),
		cd = 90,
	},
	Tauren = {
		id = 20549,
		icon = select(3, GetSpellInfo(20549)),
		cd = 90,
	},
	Troll = {
		id = 26297,
		icon = select(3, GetSpellInfo(26297)),
		cd = 180,
	},
	NightElf = {
		id = 58984,
		icon = select(3, GetSpellInfo(58984)),
		cd = 120,
	},
	Dwarf = {
		id = 20594,
		icon = select(3, GetSpellInfo(20594)),
		cd = 120,
	},
	Gnome = {
		id = 20589,
		icon = select(3, GetSpellInfo(20589)),
		cd = 105,
	},
	None = {
		id = nil,
		icon = "Interface\\Icons\\inv_misc_questionmark",
		cd = 0,
	},
}

module.defaultSettings = {
	x = -74,
	y = -19,
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

function RACIAL_UNIT_SPELLCAST_SUCCEEDED(self, ...)
	local _, event, sourceGUID, sourceName, _, destGUID, destName, _, spellId, spellName, _, _, _, _, _ = select(1,...)

	if UnitGUID(self.unit) ~= sourceGUID then return end
	if event ~= "SPELL_CAST_SUCCESS" then return end

	--if "Qb" ~= sourceName then return end

	local arenaFrame = self:GetParent()
	local trinket = arenaFrame.CC
	local isRun = false

	for race, raceData in pairs(raceIcons) do
		if spellId == raceData.id or (raceData.alt and raceData.alt[spellId]) then
			isRun = true
			self.time = tonumber(raceData.cd)
			self.starttime = GetTime()
			CooldownFrame_SetTimer(self.cooldown, GetTime(), raceData.cd, 1)
		end
	end

	local overallTime = addon.overallCooldown[select(2, UnitRace(self.unit))]
	if overallTime == nil or isRun == false then return end

	if overallTime and addon:isNeedStart(trinket, overallTime) then
		trinket.time = tonumber(overallTime)
		trinket.starttime = GetTime()
		CooldownFrame_SetTimer(trinket.cooldown, GetTime(), overallTime, 1)
	end
end

function module:OnEvent(event, ...)
	for i = 1, MAX_ARENA_ENEMIES do
		local CC = nil
		local arenaFrame = _G["ArenaEnemyFrame"..i]

		if (arenaFrame["racial"] == nil) then
			CC = CreateFrame("Frame", nil, arenaFrame, "sArenaIconTemplate")
			CC.unit = arenaFrame.unit
			CC.time = 0
			CC.starttime = 0
			CC:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			CC:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
			CC.COMBAT_LOG_EVENT_UNFILTERED = RACIAL_UNIT_SPELLCAST_SUCCEEDED
			arenaFrame.racial = CC
		else
			CC = arenaFrame.racial
		end

		CC.cooldown:SetCooldown(0, 0)

		if event == "ADDON_LOADED" then
			CC:SetMovable(true)
			addon:SetupDrag(self, true, CC)

			CC:SetFrameLevel(4)

			CC.cooldown:ClearAllPoints()
			CC.cooldown:SetPoint("TOPLEFT", 1, -1)
			CC.cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

			local _, race = UnitRace(CC.unit)

			local raceData = raceIcons[race]
			if raceData then
				CC.Icon:SetTexture(raceData.icon)
			end
		elseif event == "TEST_MODE" then
			if addon.testMode then
				CC:EnableMouse(true)
				CC.Icon:SetTexture(raceIcons[races[ math.random(#races - 1)]].icon)
				CC.cooldown:SetCooldown(GetTime(), random(30,120))
			else
				CC:EnableMouse(false)
				CC.Icon:SetTexture(nil)
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