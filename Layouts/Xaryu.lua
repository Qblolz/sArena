local addonName, addon = ...
local layout = addon:AddLayout("Xaryu", "Xaryu")

function layout:SetFrameStyle(frame, db)

	frame.name:ClearAllPoints()
	frame.classPortrait:ClearAllPoints()
	frame.healthbar:ClearAllPoints()
	frame.manabar:ClearAllPoints()
	frame.texture:ClearAllPoints()
	if frame.auraFrame then
		frame.auraFrame:ClearAllPoints()
	end
	
	addon.squareClassPortrait = nil
	
	frame:SetSize(db.width, db.height)
	frame.classPortrait:SetSize(db.height - 2, db.height - 2)
	frame.texture:Hide()
	frame.backgroundFrame:Show()
	frame.backgroundFrame:SetSize(db.width - 8, db.height - 2)
	frame.backgroundFrame:SetPoint("TOPLEFT", frame.healthbar, -2, 2)
	addon.squareClassPortrait = true

	if frame.auraFrame then
		local auraFrame = frame.auraFrame

		auraFrame:SetAllPoints(frame.classPortrait)
		auraFrame.texture:SetTexCoord(0, 1, 0, 1)
		auraFrame.cooldown:SetReverse(true)
	end

	frame.healthbar:SetWidth(db.width)
	frame.manabar:SetWidth(db.width)
	frame.manabar:SetHeight(db.powerBarHeight)

	frame.name:SetPoint("TOPLEFT", frame.healthbar, 0, 28)

	if db.mirroredFrames then
	
		frame.name:SetPoint("TOPLEFT", frame.healthbar, 0 - db.height, 12)
		frame.classPortrait:SetPoint("BOTTOMLEFT")

		frame.manabar:SetPoint("BOTTOMLEFT", frame.classPortrait, "BOTTOMRIGHT", 2, 2)
		frame.manabar:SetPoint("RIGHT", -11, 0)

		frame.healthbar:SetPoint("TOPLEFT", frame.classPortrait, "TOPRIGHT", 2, -2)
		frame.healthbar:SetPoint("BOTTOMRIGHT", frame.manabar, "TOPRIGHT")
		
		frame.backgroundFrame:SetPoint("TOPLEFT", frame.classPortrait, 0, 0)
	else
		frame.classPortrait:SetPoint("BOTTOMRIGHT", -11, 0)

		frame.manabar:SetPoint("BOTTOMRIGHT", frame.classPortrait, "BOTTOMLEFT", -2, 2)
		frame.manabar:SetPoint("LEFT")

		frame.healthbar:SetPoint("TOPRIGHT", frame.classPortrait, "TOPLEFT", -2, -2)
		frame.healthbar:SetPoint("BOTTOMLEFT", frame.manabar, "TOPLEFT")
	end
end