-- Credit to Starship/Spaceship from AJ for providing original concept.
sArena.Trinkets = CreateFrame("Frame", nil, sArena)

sArena.Defaults.Trinkets = {
	enabled = true,
		scale = 1,
		alwaysShow = true,
}

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
	[21] = "None"
}

local overallCooldownRaces = {
	[1] = "Human",
	[2] = "Scourge"
}

local raceIcons = {
	Human = "Interface\\Icons\\spell_shadow_charm",
	Scourge = "Interface\\Icons\\spell_shadow_raisedead",
	Naga = "Interface\\Icons\\spell_frost_frostarmor02",
	Vulpera = "Interface\\Icons\\spell_sandbolt",
	Goblin = "Interface\\Icons\\ability_racial_rocketjump",
	Draenei = "Interface\\Icons\\Spell_Holy_HolyProtection",
	Orc = "Interface\\Icons\\Racial_Orc_BerserkerStrength",
	Queldo = "Interface\\Icons\\Spell_Arcane_ArcaneResilience",
	BloodElf = "Interface\\Icons\\Spell_Shadow_teleport",
	Tauren = "Interface\\Icons\\ability_warstomp",
	Troll = "Interface\\Icons\\racial_troll_berserk",
	NightElf = "Interface\\Icons\\Ability_Ambush",
	Pandaren = "Interface\\Icons\\Ability_racial_quiveringpain",
	Dwarf = "Interface\\Icons\\Spell_Shadow_UnholyStrength",
	Gnome = "Interface\\Icons\\Ability_Rogue_Trip",
	Worgen = "Interface\\Icons\\Abilityracial_darkflight",
	Nightborne = "Interface\\Icons\\spell_arcane_arcane01_nightborne",
	VoidElf = "Interface\\Icons\\ability_priest_voidentropy",
	DarkIronDwarf = "Interface\\Icons\\inv_hammer_unique_sulfuras",
	Eredar = "Interface\\Icons\\spell_warlock_demonicportal_green",
	None = "Interface\\Icons\\inv_misc_questionmark"
}

function sArena.Trinkets:Initialize()
	if ( not sArenaDB.Trinkets ) then
		sArenaDB.Trinkets = CopyTable(sArena.Defaults.Trinkets)
	end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]

		self:CreateIcon(ArenaFrame, i)
		
		ArenaFrame:SetScript("OnShow",
			function(self)
				local raceRU, raceEU = UnitRace("arena"..self:GetID())
				local race = "None"
				
				if tContains(races, raceEU) then
					race = raceEU
				end
				
				sArena.Trinkets["arena"..self:GetID().."Race"].Icon.Texture:SetTexture(raceIcons[race])
			end
		)
	end
end
hooksecurefunc(sArena, "Initialize", function() sArena.Trinkets:Initialize() end)

function sArena.Trinkets:CreateIcon(frame, arenaIndex)
	local trinket = CreateFrame("Cooldown", nil, frame)
	trinket.point = "arena"..arenaIndex
	
	trinket.cooldown = 0
	trinket.starttime = 0
	
	trinket:SetFrameLevel(frame:GetFrameLevel() + 3)
	if sArenaDB.Trinkets.point then
		trinket:SetPoint(sArenaDB.Trinkets.point, frame, sArenaDB.Trinkets.x, sArenaDB.Trinkets.y)
	else
		trinket:SetPoint("LEFT", frame, "RIGHT", 0, 0)
	end
	trinket:SetSize(18, 18)
	trinket:SetScale(sArenaDB.Trinkets.scale)
	
	trinket.Icon = CreateFrame("Frame", nil, trinket)
	trinket.Icon:SetFrameLevel(trinket:GetFrameLevel() - 1)
	trinket.Icon:SetAllPoints()
	trinket.Icon.Texture = trinket.Icon:CreateTexture(nil, "BORDER")
	trinket.Icon.Texture:SetAllPoints()
	trinket.Icon.Texture:SetTexture(UnitFactionGroup('player') == "Horde" and "Interface\\Icons\\inv_jewelry_trinketpvp_02" or "Interface\\Icons\\inv_jewelry_trinketpvp_01")
	
	trinket:RegisterForDrag("LeftButton")
	trinket:SetScript("OnDragStart", function(s) s:StartMoving() end)
	trinket:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() self:DragStop(s) end)
	
	if ( not sArenaDB.Trinkets.enabled ) then trinket.Icon:Hide() end
	
	local id = frame:GetID()
	
	self:CreateRaceIcon(frame, arenaIndex, trinket)
	
	self:AlwaysShow(sArenaDB.Trinkets.alwaysShow, trinket)
	
	self["arena"..id] = trinket
end

function sArena.Trinkets:CreateRaceIcon(frame, arenaIndex, parentFrame)
	local raceFrame = CreateFrame("Cooldown", nil, frame)

	raceFrame.point = "arena"..arenaIndex
	raceFrame.isOverallCD = false
	
	raceFrame.cooldown = 0
	raceFrame.starttime = 0

	raceFrame:SetFrameLevel(frame:GetFrameLevel() + 3)
	raceFrame:SetPoint("LEFT", parentFrame, "RIGHT", 1, 0)

	raceFrame:SetSize(18, 18)
	raceFrame:SetScale(sArenaDB.Trinkets.scale)

	raceFrame.Icon = CreateFrame("Frame", nil, raceFrame)
	raceFrame.Icon:SetFrameLevel(raceFrame:GetFrameLevel() - 1)
	raceFrame.Icon:SetAllPoints()
	raceFrame.Icon.Texture = raceFrame.Icon:CreateTexture(nil, "BORDER")
	raceFrame.Icon.Texture:SetAllPoints()
	
	local raceRU, raceEU = UnitRace(raceFrame.point)
	local race = "None"

	if tContains(races, raceEU) then
		race = raceEU
	end
	
	raceFrame.Icon.Texture:SetTexture(raceIcons[race])
	
	self:AlwaysShow(sArenaDB.Trinkets.alwaysShow, raceFrame)
	
	local id = frame:GetID()
	
	self["arena"..id.."Race"] = raceFrame
end

function sArena.Trinkets:Test(numOpps)
	if ( sArena:CombatLockdown() or not sArenaDB.Trinkets.enabled ) then return end
	for i = 1, numOpps do
		self["arena"..i].Icon:Show()
		self["arena"..i]:SetCooldown(GetTime(), 120)
		self["arena"..i]:EnableMouse(true)
		self["arena"..i]:SetMovable(true)
		
		self["arena"..i.."Race"].Icon:Show()
		self["arena"..i.."Race"]:SetCooldown(GetTime(), 45)
		self["arena"..i.."Race"].Icon.Texture:SetTexture(raceIcons[races[ math.random(#races)]])
	end
end
hooksecurefunc(sArena, "Test", function(obj, arg1) sArena.Trinkets:Test(arg1) end)

function sArena.Trinkets:HideTrinkets()
	for i = 1, MAX_ARENA_ENEMIES do
		self["arena"..i].Icon:Hide()
		self["arena"..i]:Hide()
		self["arena"..i]:SetCooldown(0, 0)
		self["arena"..i]:EnableMouse(false)
		self["arena"..i]:SetMovable(false)
		
		self["arena"..i.."Race"].Icon:Hide()
		self["arena"..i.."Race"]:Hide()
		self["arena"..i.."Race"]:SetCooldown(0, 0)
	end
end

function sArena.Trinkets:DragStop(s)
	-- Zork/Rothar's hack to maintain relativity: Super Cool.
	local sX, sY = s:GetCenter()
	local pX, pY = s:GetParent():GetCenter()
	local scale = s:GetScale()
	sX, sY = floor(sX*scale), floor(sY*scale)
	pX, pY = floor(pX), floor(pY)
	local fX, fY = floor((pX-sX)*(-1)), floor((pY-sY)*(-1))
	
	for i = 1, MAX_ARENA_ENEMIES do
		self["arena"..i]:ClearAllPoints()
		self["arena"..i]:SetPoint("CENTER",self["arena"..i]:GetParent(),fX/scale,fY/scale)
	end
	
	local _
	sArenaDB.Trinkets.point, _, _, sArenaDB.Trinkets.x, sArenaDB.Trinkets.y = s:GetPoint()
end

function sArena.Trinkets:Scale(scale)
	for i = 1, MAX_ARENA_ENEMIES do
		self["arena"..i]:SetScale(scale)
		self["arena"..i.."Race"]:SetScale(scale)
		if ( sArenaDB.Trinkets.alwaysShow ) then
			self["arena"..i].Icon:SetScale(scale)
			self["arena"..i.."Race"].Icon:SetScale(scale)
		else
			self["arena"..i].Icon:SetScale(1)
			self["arena"..i.."Race"].Icon:SetScale(1)
		end
	end
end

function sArena.Trinkets:AlwaysShow(alwaysShow, ...)
	local trinket = ...
	if ( trinket ) then
		if ( alwaysShow ) then
			trinket.Icon:SetParent(trinket:GetParent())
			trinket.Icon:SetScale(sArenaDB.Trinkets.scale)
		else
			trinket.Icon:SetParent(trinket)
			trinket.Icon:SetScale(1)
		end
		trinket.Icon:SetFrameLevel(trinket:GetFrameLevel() - 1)
	else
		for i = 1, MAX_ARENA_ENEMIES do
			trinket = self["arena"..i]
			if ( alwaysShow ) then
				trinket.Icon:SetParent(trinket:GetParent())
				trinket.Icon:SetScale(sArenaDB.Trinkets.scale)
			else
				trinket.Icon:SetParent(trinket)
				trinket.Icon:SetScale(1)
			end
			trinket.Icon:SetFrameLevel(trinket:GetFrameLevel() - 1)
		end
	end
end

sArena.Trinkets:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

function sArena.Trinkets:UNIT_SPELLCAST_SUCCEEDED(unitID, spell)
	if not sArena.Trinkets[unitID] then return end
	
	if spell == GetSpellInfo(42292) then
		self[unitID].cooldown = tonumber(120)
		self[unitID].starttime = GetTime()
		CooldownFrame_SetTimer(self[unitID], GetTime(), 120, 1)
		
		local raceRU, raceEU = UnitRace(unitID)
		if tContains(overallCooldownRaces, raceEU) then
			self[unitID.."Race"].isOverallCD = true
		end
		
		if self[unitID.."Race"].isOverallCD and isNeedStart(self[unitID.."Race"],45) then
			CooldownFrame_SetTimer(self[unitID.."Race"], GetTime(), 45, 1)
		end
	elseif spell == GetSpellInfo(7744) or spell == GetSpellInfo(59752) then
		self[unitID.."Race"].cooldown = tonumber(120)
		self[unitID.."Race"].starttime = GetTime()
		CooldownFrame_SetTimer(self[unitID.."Race"], GetTime(), 120, 1)
		
		if isNeedStart(self[unitID],45) then
			CooldownFrame_SetTimer(self[unitID], GetTime(), 45, 1)
		end
	elseif spell == GetSpellInfo(28880) or spell == GetSpellInfo(59542) or spell == GetSpellInfo(59543) or spell == GetSpellInfo(59544) or spell == GetSpellInfo(59545) or spell == GetSpellInfo(59547) or spell == GetSpellInfo(59548) or spell == GetSpellInfo(26297) or spell == GetSpellInfo(308725) then
		self[unitID.."Race"].cooldown = tonumber(180)
		self[unitID.."Race"].starttime = GetTime()
		CooldownFrame_SetTimer(self[unitID.."Race"], GetTime(), 180, 1)
	elseif spell == GetSpellInfo(20572) or spell == GetSpellInfo(33697) or spell == GetSpellInfo(90110) or spell == GetSpellInfo(33702) or spell == GetSpellInfo(90108) or spell == GetSpellInfo(28730) or spell == GetSpellInfo(25046) or spell == GetSpellInfo(50613) or spell == GetSpellInfo(20594) or spell == GetSpellInfo(58984) or spell == GetSpellInfo(20549) or spell == GetSpellInfo(90115) or spell == GetSpellInfo(90113) or spell == GetSpellInfo(90101) or spell == GetSpellInfo(308932) then
		self[unitID.."Race"].cooldown = tonumber(120)
		self[unitID.."Race"].starttime = GetTime()
		CooldownFrame_SetTimer(self[unitID.."Race"], GetTime(), 120, 1)
	elseif spell == GetSpellInfo(20589) or spell == GetSpellInfo(316465) then
		self[unitID.."Race"].cooldown = tonumber(60)
		self[unitID.."Race"].starttime = GetTime()
		CooldownFrame_SetTimer(self[unitID.."Race"], GetTime(), 60, 1)
	elseif spell == GetSpellInfo(310773) then
		self[unitID.."Race"].cooldown = tonumber(45)
		self[unitID.."Race"].starttime = GetTime()
		CooldownFrame_SetTimer(self[unitID.."Race"], GetTime(), 45, 1)
	elseif spell == GetSpellInfo(310787) or spell == GetSpellInfo(316161) then
		self[unitID.."Race"].cooldown = tonumber(90)
		self[unitID.."Race"].starttime = GetTime()
		CooldownFrame_SetTimer(self[unitID.."Race"], GetTime(), 90, 1)
	end
end

function isNeedStart(frame, sentCD)
	cooldown = tonumber(sentCD);
	activeCooldown = frame.cooldown
	endTimeCooldown = frame.starttime + activeCooldown
	diff = endTimeCooldown - GetTime()
	if diff < cooldown then
		return true
	end
	
	if diff > cooldown then
		return false
	end
end

function sArena.Trinkets:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())
	if ( sArenaDB.Trinkets.enabled and instanceType == "arena" ) then
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		for i = 1, MAX_ARENA_ENEMIES do
			self["arena"..i]:SetCooldown(0, 0)
			self["arena"..i.."Race"]:SetCooldown(0, 0)
		end
	elseif ( self:IsEventRegistered("UNIT_SPELLCAST_SUCCEEDED") ) then
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
end
sArena.Trinkets:RegisterEvent("PLAYER_ENTERING_WORLD")
