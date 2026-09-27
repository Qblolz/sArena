local addonName, addon = ...
local layout = addon:AddLayout("Flat", "Flat")

function layout:SetFrameStyle(frame, db)
	local _healthBarTexture = frame.healthbar:GetStatusBarTexture()
	local hb_r, hb_g, hb_b, hb_a = frame.healthbar:GetStatusBarColor()
	local _manaBarTexture = frame.manabar:GetStatusBarTexture()
	local mb_r, mb_g, mb_b, mb_a = frame.manabar:GetStatusBarColor()

	frame.name:ClearAllPoints()
	frame.classPortrait:ClearAllPoints()
	frame.healthbar:ClearAllPoints()
	frame.manabar:ClearAllPoints()
	frame.texture:ClearAllPoints()
	if frame.auraFrame then
		frame.auraFrame:ClearAllPoints()
	end

	local _maxHeight = (db.healthBarHeight + db.powerBarHeight)

	frame:SetSize(db.width, db.height)
	frame.classPortrait:SetSize(_maxHeight - 2, _maxHeight - 2)
	frame.texture:Hide()

	addon.squareClassPortrait = true
	
    frame.healthbar:SetStatusBarTexture("Interface\\AddOns\\sArena\\Media\\statusbar")
    frame.manabar:SetStatusBarTexture("Interface\\AddOns\\sArena\\Media\\statusbar")

	frame.healthbar:SetWidth(db.width - (_maxHeight + 2))
	frame.healthbar:SetHeight(db.healthBarHeight)
	frame.manabar:SetWidth(db.width - (_maxHeight + 2))
	frame.manabar:SetHeight(db.powerBarHeight)

	frame.backgroundFrame:Show()
	frame.backgroundFrame:SetSize(db.width + 2, _maxHeight + 6)

	if db.mirroredFrames then
		frame.classPortrait:SetPoint("TOPLEFT", 0, -2)
		frame.name:SetPoint("TOPLEFT", frame.classPortrait, 0, 18)
		frame.backgroundFrame:SetPoint("TOPLEFT", frame.classPortrait, -2, 4)
		frame.healthbar:SetPoint("TOPLEFT", frame.classPortrait, "TOPRIGHT", 2, 2)
		frame.manabar:SetPoint("TOPLEFT", frame.healthbar, "BOTTOMLEFT", 0, -2)
	else
		frame.healthbar:SetPoint("TOPLEFT")
		frame.name:SetPoint("TOPLEFT", frame.healthbar, 0, 16)
		frame.backgroundFrame:SetPoint("TOPLEFT", frame.healthbar, -2, 2)
		frame.classPortrait:SetPoint("TOPLEFT", frame.healthbar, "TOPRIGHT", 2, -2)
		frame.manabar:SetPoint("TOPLEFT", frame.healthbar, "BOTTOMLEFT", 0, -2)
	end

	frame.healthbar:SetStatusBarTexture(_healthBarTexture)
	frame.healthbar:SetStatusBarColor(hb_r, hb_g, hb_b, hb_a)

	frame.manabar:SetStatusBarTexture(_manaBarTexture)
	frame.manabar:SetStatusBarColor(mb_r, mb_g, mb_b, mb_a)
end