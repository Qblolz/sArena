local AddonName = ...
sArena = CreateFrame("Frame", nil, UIParent)
sArena:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
local BackdropLayout = { bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = { left = 0, right = 0, top = 0, bottom = 0 } }

sArena.AddonName = AddonName

sArena:SetSize(200, 16)
sArena:SetBackdrop(BackdropLayout)
sArena:SetBackdropColor(0, 0, 0, .8)
sArena:SetClampedToScreen(true)
sArena:EnableMouse(true)
sArena:SetMovable(true)
sArena:RegisterForDrag("LeftButton")
sArena:Hide()

sArena.Title = sArena:CreateFontString(nil, "BACKGROUND")
sArena.Title:SetFontObject("GameFontHighlight")
sArena.Title:SetText(AddonName .. " (Click to drag)")
sArena.Title:SetPoint("CENTER", 0, 0)

sArena.Frame = CreateFrame("Frame", nil, UIParent)
sArena.Frame:SetSize(200, 1)
sArena.Frame:SetPoint("TOPLEFT", sArena, "BOTTOMLEFT", 0, 0)
sArena.Frame:SetPoint("TOPRIGHT", sArena, "BOTTOMRIGHT", 0, 0)

sArena:SetParent(sArena.Frame)

sArena.Defaults = {
	firstrun = true,
	version = 7,
	position = {},
	lock = false,
	scale = 1.4,
	padding = -20
}

function sArena:Initialize()
	self.OptionsPanel:Initialize()
	
	self:SetPoint(sArenaDB.position.point or "RIGHT", _G["UIParent"], sArenaDB.position.relativePoint or "RIGHT", sArenaDB.position.x or -100, sArenaDB.position.y or 100)
	self.Frame:SetScale(sArenaDB.scale)
	
	if ( not sArenaDB.lock ) then
		self:Show()
	end
	
	local _
	self:SetScript("OnDragStart", function(s) s:StartMoving() end)
	self:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() sArenaDB.position.point, _, sArenaDB.position.relativePoint, sArenaDB.position.x, sArenaDB.position.y = s:GetPoint() end)
	
	-- Blizzard removed this feature from the options panel and SHOW_PARTY_BACKGROUND is always 0, but the CVar showPartyBackground still persists between sessions.
	ArenaEnemyBackground:SetParent(self.Frame) -- ArenaEnemyBackground functions with both variables(see Blizzard_ArenaUI.lua). What the hell?
	UpdateArenaEnemyBackground(GetCVarBool("showPartyBackground"))
	local ParentFrameMove = nil
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		ArenaFrame:SetParent(self.Frame)
		ArenaEnemyFrame_UpdatePlayer(ArenaFrame, true)
		
		local ArenaFrameCastBar = _G["ArenaEnemyFrame"..i.."CastingBar"];
		ArenaFrameCastBar:SetScale(tonumber(sArenaDB.CastingBars.scale))
		ArenaFrameCastBar:SetPoint("RIGHT", tonumber(sArenaDB.CastingBars.x), tonumber(sArenaDB.CastingBars.y))
		if(tonumber(sArenaDB.CastingBars.width) > 0) then
			ArenaFrameCastBar:SetWidth(tonumber(sArenaDB.CastingBars.width))
		end
		
		local ArenaPetFrame = _G["ArenaEnemyFrame"..i.."PetFrame"]
		ArenaPetFrame:SetParent(self.Frame)
		
		if ( i == 1 ) then
			ParentFrameMove = _G["ArenaEnemyFrame1"]
			ArenaFrame:ClearAllPoints()
			ArenaFrame:SetPoint("TOP", self.Frame, "BOTTOM", 0, -8)
		else
			ArenaFrame:ClearAllPoints()
			ArenaFrame:SetPoint("TOP", ParentFrameMove, "BOTTOM", 0, sArenaDB.padding)
			ParentFrameMove = ArenaFrame
		end
	end
	
	--self:Test(3)
end

function sArena:CombatLockdown()
	if ( InCombatLockdown() ) then
		print("sArena: Must leave combat before doing that!")
		return true
	end
end

function sArena:HideArenaEnemyFrames()
	if ( self:CombatLockdown() ) then return end
	
	ArenaEnemyBackground:Hide()
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		ArenaEnemyFrame_OnEvent(ArenaFrame, "ARENA_OPPONENT_UPDATE", ArenaFrame.unit, "cleared")
		_G["ArenaEnemyFrame"..i.."PetFrame"]:Hide()
		_G["ArenaEnemyFrame"..i.."CastingBar"]:Hide()
		ArenaEnemyFrame_UpdatePlayer(ArenaFrame)
	end
end

function sArena:Test(numOpps)
	if ( self:CombatLockdown() ) then return end
	if ( not numOpps or not (numOpps > 0 and numOpps < 6) ) then return end
	
	self:HideArenaEnemyFrames()
	
	local showArenaEnemyPets = (SHOW_ARENA_ENEMY_PETS == "1")
	local instanceType = select(2, IsInInstance())
	local factionGroup = UnitFactionGroup('player')
	
	for i = 1, numOpps do
		local ArenaFrame = _G["ArenaEnemyFrame"..i]
		
		if ( i == 1 ) then
			ParentFrameMove = _G["ArenaEnemyFrame1"]
			ArenaFrame:ClearAllPoints()
			ArenaFrame:SetPoint("TOP", self.Frame, "BOTTOM", 0, -8)
		else
			ArenaFrame:ClearAllPoints()
			ArenaFrame:SetPoint("TOP", ParentFrameMove, "BOTTOM", 0, sArenaDB.padding)
			ParentFrameMove = ArenaFrame
		end
		
		ArenaEnemyFrame_SetMysteryPlayer(ArenaFrame)
		
		if ( showArenaEnemyPets ) then
			_G["ArenaEnemyFrame"..i.."PetFrame"]:Show()
			_G["ArenaEnemyFrame"..i.."PetFramePortrait"]:SetTexture("Interface\\CharacterFrame\\TempPortrait")
		end
	end
	
	if ( GetCVarBool("showPartyBackground") or SHOW_PARTY_BACKGROUND == "1" ) then
		ArenaEnemyBackground:Show()
		ArenaEnemyBackground:SetPoint("BOTTOMLEFT", "ArenaEnemyFrame"..numOpps.."PetFrame", "BOTTOMLEFT", -15, -10)
	end
end

function sArena:ADDON_LOADED(arg1)
	if ( arg1 == AddonName ) then
		if ( not sArenaDB or sArenaDB.version < sArena.Defaults.version ) then
			sArenaDB = CopyTable(sArena.Defaults)
		end
		if ( not IsAddOnLoaded("Blizzard_ArenaUI") ) then
			LoadAddOn("Blizzard_ArenaUI")
		end
		self:Initialize()
		if ( sArenaDB.firstrun ) then
			sArenaDB.firstrun = false
			self:Test(3)
			print("Looks like this is your first time running this version of sArena! Type /sarena for options.")
		end
	end
end
sArena:RegisterEvent("ADDON_LOADED")
