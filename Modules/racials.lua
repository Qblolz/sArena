local addonName, addon = ...
local module = addon:CreateModule("Racials")

local races = {
	[1] = "Human",
	[2] = "Scourge",
	[3] = "Tauren",
	[4] = "BloodElf",
	[5] = "Naga",
	[6] = "Queldo",
	[7] = "Pandaren",
	[8] = "Orc",
	[9] = "Troll",
	[10] = "NightElf",
	[11] = "Draenei",
	[12] = "Vulpera",
	[13] = "Gnome",
	[14] = "Dwarf",
	[15] = "Worgen",
	[16] = "Nightborne",
	[17] = "VoidElf",
	[18] = "Goblin",
	[19] = "DarkIronDwarf",
	[20] = "Eredar",
	[21] = "ZandalariTroll",
	[22] = "Lightforged",
	[22] = "Dracthyr",
	[23] = "None"
}

raceIcons = {
	Human = {
		id = 316231,
		icon = select(3, GetSpellInfo(316231)),
		cd = 120,
	},
	Scourge = {
		id = 316380,
		icon = select(3, GetSpellInfo(316380)),
		cd = 120,
	},
	Naga = {
		id = 316413,
		icon = select(3, GetSpellInfo(316413)),
		cd = 90,
	},
	Vulpera = {
		id = 316455,
		icon = select(3, GetSpellInfo(316455)),
		cd = 90,
	},
	Goblin = {
		id = 316393,
		icon = select(3, GetSpellInfo(316393)),
		cd = 120,
	},
	Draenei = {
		id = 316279,
		icon = select(3, GetSpellInfo(316279)),
		cd = 120,
	},
	Orc = {
		id = 316372,
		icon = select(3, GetSpellInfo(316372)),
		cd = 90,
	},
	Queldo = {
		id = 316294,
		icon = select(3, GetSpellInfo(316294)),
		cd = 90,
	},
	BloodElf = { --синд
		id = 316418,
		alt = {["316421"] = 1, ["302387"] = 1, ["316419"] = 1, ["316420"] = 1},
		icon = select(3, GetSpellInfo(316418)),
		cd = 90,
	},
	Tauren = {
		id = 316386,
		icon = select(3, GetSpellInfo(316386)),
		cd = 90,
	},
	Troll = {
		id = 316405,
		icon = select(3, GetSpellInfo(316405)),
		cd = 90,
	},
	NightElf = {
		id = 316254,
		icon = select(3, GetSpellInfo(316254)),
		cd = 120,
	},
	Pandaren = {
		id = 316443,
		icon = select(3, GetSpellInfo(316443)),
		cd = 90,
	},
	Dwarf = {
		id = 316243,
		icon = select(3, GetSpellInfo(316243)),
		cd = 120,
	},
	Gnome = {
		id = 316271,
		icon = select(3, GetSpellInfo(316271)),
		cd = 120,
	},
	Worgen = {
		id = 316289,
		icon = select(3, GetSpellInfo(316289)),
		cd = 90,
	},
	Nightborne = {
		id = 316431,
		icon = select(3, GetSpellInfo(316431)),
		cd = 30,
	},
	VoidElf = {
		id = 316367,
		icon = select(3, GetSpellInfo(316367)),
		cd = 90,
	},
	DarkIronDwarf = {
		id = 316161,
		icon = select(3, GetSpellInfo(316161)),
		cd = 90,
	},
	Eredar = {
		id = 316465,
		icon = select(3, GetSpellInfo(316465)),
		cd = 60,
	},
	ZandalariTroll = {
		id = 310810,
		icon = select(3, GetSpellInfo(310810)),
		cd = 120,
	},
	Lightforged = {
		id = 319322,
		icon = select(3, GetSpellInfo(319322)),
		cd = 90,
	},
	Dracthyr = {
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
	
	--if "Qb" ~= sourceName then return end
	
	local arenaFrame = self:GetParent()
	local trinket = arenaFrame.CC
	local isRun = false
	
	for race, raceData in pairs(raceIcons) do
		if spellId == raceData.id or (raceData.alt and raceData.alt[tostring(spellId)]) then
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
