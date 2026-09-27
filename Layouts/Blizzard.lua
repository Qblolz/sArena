local addonName, addon = ...
local layout = addon:AddLayout("Blizz Arena", "|cff00b4ffBlizz|r Arena")

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
	
	frame:SetSize(112, 32)
	frame.classPortrait:SetSize(26, 26)
	frame.healthbar:SetSize(70, 8)
	frame.manabar:SetSize(70, 8)
	frame.texture:SetSize(102, 32)
	frame.texture:Show()
	frame.texture:SetPoint("TOPLEFT", 0, -2)
	frame.backgroundFrame:Hide()

	if frame.auraFrame then
		local auraFrame = frame.auraFrame

		auraFrame:SetPoint("CENTER", frame.classPortrait)
		auraFrame:SetSize(23, 23)
		auraFrame.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		auraFrame.cooldown:SetReverse(true)
	end

	if db.mirroredFrames then
		frame.name:SetPoint("BOTTOMLEFT", 32, 24)
		frame.classPortrait:SetPoint("TOPLEFT", 2, -5)
		frame.texture:SetTexCoord(0.796, 0, 0, 0.5)
		frame.healthbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 29, -11)
		frame.manabar:SetPoint("TOPLEFT", frame, "TOPLEFT", 29, -20)
	else
		frame.name:SetPoint("BOTTOMLEFT", 3, 24)
		frame.classPortrait:SetPoint("TOPRIGHT", -13, -5)
		frame.texture:SetTexCoord(0, 0.796, 0, 0.5)
		frame.healthbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -11)
		frame.manabar:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -20)
	end
end