local addonName, addon = ...
local module = addon:CreateModule("Racials")

local constellations = {
	[1] = 371796, -- Human
	[2] = 371804, -- Scourge
	[3] = 371805, -- Tauren
	[4] = 371788, -- BloodElf
	[5] = 371798, -- Naga
	[6] = 371803, -- Queldo
	[7] = 371802, -- Pandaren
	[8] = 371801, -- Orc
	[9] = 371806, -- Troll
	[10] = 371800, -- NightElf
	[11] = 371791, -- Draenei
	[12] = 371808, -- Vulpera
	[13] = 371794, -- Gnome
	[14] = 371792, -- Dwarf
	[15] = 371809, -- Worgen
	[16] = 371799, -- Nightborne
	[17] = 371807, -- VoidElf
	[18] = 371795, -- Goblin
	[19] = 371789, -- DarkIronDwarf
	[20] = 371793, -- Eredar
	[21] = 371810, -- ZandalariTroll
	[22] = 371797, -- Lightforged
	[22] = 371790, -- Dracthyr
	[23] = "None"
}

constellations2Spells = {
	[371796] = {
		id = 316231,
		icon = select(3, GetSpellInfo(316231)),
		cd = 120,
	},
	[371804] = {
		id = 316380,
		icon = select(3, GetSpellInfo(316380)),
		cd = 120,
	},
	[371798] = {
		id = 316413,
		icon = select(3, GetSpellInfo(316413)),
		cd = 90,
	},
	[371808] = {
		id = 316455,
		icon = select(3, GetSpellInfo(316455)),
		cd = 90,
	},
	[371795] = {
		id = 316393,
		icon = select(3, GetSpellInfo(316393)),
		cd = 120,
	},
	[371791] = {
		id = 316279,
		icon = select(3, GetSpellInfo(316279)),
		cd = 120,
	},
	[371801] = {
		id = 316372,
		icon = select(3, GetSpellInfo(316372)),
		cd = 90,
	},
	[371803] = {
		id = 316294,
		icon = select(3, GetSpellInfo(316294)),
		cd = 90,
	},
	[371788] = { --синд
		id = 316418,
		alt = {["316421"] = 1, ["302387"] = 1, ["316419"] = 1, ["316420"] = 1},
		icon = select(3, GetSpellInfo(316418)),
		cd = 90,
	},
	[371805] = {
		id = 316386,
		icon = select(3, GetSpellInfo(316386)),
		cd = 90,
	},
	[371806] = {
		id = 316405,
		icon = select(3, GetSpellInfo(316405)),
		cd = 90,
	},
	[371800] = {
		id = 316254,
		icon = select(3, GetSpellInfo(316254)),
		cd = 120,
	},
	[371802] = {
		id = 316443,
		icon = select(3, GetSpellInfo(316443)),
		cd = 120,
	},
	[371792] = {
		id = 316243,
		icon = select(3, GetSpellInfo(316243)),
		cd = 120,
	},
	[371794] = {
		id = 316271,
		icon = select(3, GetSpellInfo(316271)),
		cd = 120,
	},
	[371809] = {
		id = 316289,
		icon = select(3, GetSpellInfo(316289)),
		cd = 90,
	},
	[371799] = {
		id = 316431,
		icon = select(3, GetSpellInfo(316431)),
		cd = 30,
	},
	[371807] = {
		id = 316367,
		icon = select(3, GetSpellInfo(316367)),
		cd = 90,
	},
	[371789] = {
		id = 316161,
		icon = select(3, GetSpellInfo(316161)),
		cd = 90,
	},
	[371793] = {
		id = 316465,
		icon = select(3, GetSpellInfo(316465)),
		cd = 60,
	},
	[371810] = {
		id = 310810,
		icon = select(3, GetSpellInfo(310810)),
		cd = 90,
	},
	[371797] = {
		id = 319322,
		icon = select(3, GetSpellInfo(319322)),
		cd = 90,
	},
	[371790] = {
		id = 320552,
		icon = select(3, GetSpellInfo(320552)),
		cd = 120,
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
	
	local arenaFrame = self:GetParent()
	local trinket = arenaFrame.CC
	local isRun = false
	
	for race, raceData in pairs(constellations2Spells) do
		if spellId == raceData.id or (raceData.alt and raceData.alt[tostring(spellId)]) then
			isRun = true
			self.time = tonumber(raceData.cd)
			self.starttime = GetTime()
			CooldownFrame_SetTimer(self.cooldown, GetTime(), raceData.cd, 1)
		end
	end

	local overallTime = nil;

	for key = 1, 40 do
		local _, _, icon, _, _, duration, expirationTime, _, _, _, spellID = UnitAura(self.unit, key, "HARMFUL")

		if spellID ~= nil and addon.overallCooldown[spellID] then
			overallTime = addon.overallCooldown[spellID]
		end
	end

	if overallTime == nil or isRun == false then return end
	
	if overallTime and addon:isNeedStart(trinket, overallTime) then
		trinket.time = tonumber(overallTime)
		trinket.starttime = GetTime()
		CooldownFrame_SetTimer(trinket.cooldown, GetTime(), overallTime, 1)
	end
end

function module:OnEvent(event, ...)
	if event == "UNIT_AURA" then
		local __unit = select(1, ...)
		if not __unit:find("arena") then return end
	end

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
			arenaFrame.racial = CC
		else
			CC = arenaFrame.racial
		end

		CC.COMBAT_LOG_EVENT_UNFILTERED = RACIAL_UNIT_SPELLCAST_SUCCEEDED

		if event == "UNIT_AURA" then
			local raceData = addon.detectConstellation(CC.unit)

			if raceData then
				CC.Icon:SetTexture(raceData.icon)
			end
		else
			CC.cooldown:SetCooldown(0, 0)
		end

		if event == "ADDON_LOADED" then
			CC:SetMovable(true)
			addon:SetupDrag(self, true, CC)

			CC:SetFrameLevel(4)

			CC.cooldown:ClearAllPoints()
			CC.cooldown:SetPoint("TOPLEFT", 1, -1)
			CC.cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
		elseif event == "TEST_MODE" then
			if addon.testMode then
				CC:EnableMouse(true)
				local rndValue = math.random(#constellations - 1)
				CC.Icon:SetTexture(constellations2Spells[constellations[rndValue]].icon)
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
