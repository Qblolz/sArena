-- Tekkub from WoWI/GitHub made this so easy!

sArena.OptionsPanel = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
sArena.OptionsPanel.name = sArena.AddonName
sArena.OptionsPanel:Hide()

function sArena.OptionsPanel:Initialize()
	local Title, SubTitle = LibStub("tekKonfig-Heading").new(self, sArena.AddonName, "Improved arena frames")

	local ClearButton = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", -16, -16)
	ClearButton:SetSize(56, 22)
	ClearButton:SetText("Clear")
	ClearButton.tiptext = "Hides any testing frames that are visible"
	ClearButton:SetScript("OnClick", function(s) sArena:HideArenaEnemyFrames() end)

	local Test5Button = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", ClearButton, "TOPLEFT", -25, 0)
	Test5Button:SetSize(56, 22)
	Test5Button:SetText("Test 5")
	Test5Button.tiptext = "Displays 5 test frames"
	Test5Button:SetScript("OnClick", function(s) sArena:Test(5) end)

	local Test3Button = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", Test5Button, "TOPLEFT", -5, 0)
	Test3Button:SetSize(56, 22)
	Test3Button:SetText("Test 3")
	Test3Button.tiptext = "Displays 3 test frames"
	Test3Button:SetScript("OnClick", function(s) sArena:Test(3) end)

	local Test2Button = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", Test3Button, "TOPLEFT", -5, 0)
	Test2Button:SetSize(56, 22)
	Test2Button:SetText("Test 2")
	Test2Button.tiptext = "Displays 2 test frames"
	Test2Button:SetScript("OnClick", function(s) sArena:Test(2) end)

	local LockButton = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", Test2Button, "TOPLEFT", -25, 0)
	LockButton:SetSize(56, 22)
	LockButton:SetText(sArenaDB.lock and "Unlock" or "Lock")
	LockButton.tiptext = "Hides title bar and prevents dragging"
	LockButton:SetScript("OnClick", function(s)
		if sArena:CombatLockdown() then return end

		sArenaDB.lock = not sArenaDB.lock
		LockButton:SetText(sArenaDB.lock and "Unlock" or "Lock")
		
		if sArenaDB.lock then
			sArena:Hide()
		else
			sArena:Show()
		end
	end)

	local ScaleText = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	ScaleText:SetText("Frame Scale: ")
	ScaleText:SetPoint("TOPLEFT", SubTitle, "BOTTOMLEFT", 0, 0)

	local backdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = {left = 0, right = 0, top = 0, bottom = 0},
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8
	}

	local ScaleEditBox = CreateFrame("EditBox", nil, self)
	ScaleEditBox:SetPoint("TOPLEFT", ScaleText, "TOPRIGHT", 4, 2)
	ScaleEditBox:SetSize(55, 20)
	ScaleEditBox:SetFontObject(GameFontHighlight)
	ScaleEditBox:SetTextInsets(4,4,2,2)
	ScaleEditBox:SetBackdrop(backdrop)
	ScaleEditBox:SetBackdropColor(0,0,0,.4)
	ScaleEditBox:SetAutoFocus(false)
	ScaleEditBox:SetText(sArenaDB.scale)
	ScaleEditBox:SetScript("OnEditFocusLost", function() 
		if sArena:CombatLockdown() then
			ScaleEditBox:SetText(sArenaDB.scale)
			return
		end
		
		if type(tonumber(ScaleEditBox:GetText())) == "number" and tonumber(ScaleEditBox:GetText()) > 0 then
			sArenaDB.scale = ScaleEditBox:GetText()
			sArena.Frame:SetScale(sArenaDB.scale)
		else
			ScaleEditBox:SetText(sArenaDB.scale)
		end
	end)
	ScaleEditBox:SetScript("OnEscapePressed", ScaleEditBox.ClearFocus)
	ScaleEditBox:SetScript("OnEnterPressed", ScaleEditBox.ClearFocus)
	ScaleEditBox.tiptext = "Sets the scale of the arena frames. Numbers between 0.5 and 2 recommended."
	ScaleEditBox:SetScript("OnEnter", ClearButton:GetScript("OnEnter"))
	ScaleEditBox:SetScript("OnLeave", ClearButton:GetScript("OnLeave"))
	
	local PaddingText = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	PaddingText:SetText("Frame padding: ")
	PaddingText:SetPoint("LEFT", ScaleEditBox, 60, 2)
	
	local PaddingEditBox = CreateFrame("EditBox", nil, self)
	PaddingEditBox:SetPoint("TOPLEFT", PaddingText, "TOPRIGHT", 4, 2)
	PaddingEditBox:SetSize(55, 20)
	PaddingEditBox:SetFontObject(GameFontHighlight)
	PaddingEditBox:SetTextInsets(4,4,2,2)
	PaddingEditBox:SetBackdrop(backdrop)
	PaddingEditBox:SetBackdropColor(0,0,0,.4)
	PaddingEditBox:SetAutoFocus(false)
	PaddingEditBox:SetText(tonumber(sArenaDB.padding))
	PaddingEditBox:SetScript("OnEditFocusLost", function() 
		if sArena:CombatLockdown() then
			PaddingEditBox:SetText(tonumber(sArenaDB.padding))
			return
		end
		
		if type(tonumber(PaddingEditBox:GetText())) == "number" and tonumber(ScaleEditBox:GetText()) >= 0 then
			sArenaDB.padding = PaddingEditBox:GetText()
			local ParentFrameMove = _G["ArenaEnemyFrame1"]
			for i = 2, MAX_ARENA_ENEMIES do
				local ArenaFrame = _G["ArenaEnemyFrame"..i]
				ArenaFrame:ClearAllPoints()
				ArenaFrame:SetPoint("TOP", ParentFrameMove, "BOTTOM", 0, sArenaDB.padding)
				ParentFrameMove = ArenaFrame
			end
		else
			PaddingEditBox:SetText(sArenaDB.padding)
		end
	end)
	PaddingEditBox:SetScript("OnEscapePressed", PaddingEditBox.ClearFocus)
	PaddingEditBox:SetScript("OnEnterPressed", PaddingEditBox.ClearFocus)
	PaddingEditBox.tiptext = "Sets the padding of the arena frames. Numbers between 0.5 and 2 recommended."
	PaddingEditBox:SetScript("OnEnter", ClearButton:GetScript("OnEnter"))
	PaddingEditBox:SetScript("OnLeave", ClearButton:GetScript("OnLeave"))
	
	local CastingBarsFrame = LibStub("tekKonfig-Group").new(self, "CastingBars", "TOPLEFT", ScaleText, "BOTTOMLEFT", 0, -32)
	CastingBarsFrame:SetPoint("RIGHT", self, -16, 0)
	CastingBarsFrame:SetHeight(80)
	CastingBarsFrame:SetFrameLevel(3)
	
	local CastingBarsScaleText = CastingBarsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	CastingBarsScaleText:SetText("Bars Scale: ")
	CastingBarsScaleText:SetPoint("TOPLEFT", CastingBarsFrame, "TOPLEFT", 10, -12)
	
	local CastingBarsScaleEditBox = CreateFrame("EditBox", nil, self)
	CastingBarsScaleEditBox:SetPoint("LEFT", CastingBarsScaleText, "RIGHT", 4, -1)
	CastingBarsScaleEditBox:SetSize(55, 20)
	CastingBarsScaleEditBox:SetFontObject(GameFontHighlight)
	CastingBarsScaleEditBox:SetTextInsets(4,4,2,2)
	CastingBarsScaleEditBox:SetBackdrop(backdrop)
	CastingBarsScaleEditBox:SetBackdropColor(0,0,0,.4)
	CastingBarsScaleEditBox:SetAutoFocus(false)
	CastingBarsScaleEditBox:SetText(sArenaDB.CastingBars.scale)
	CastingBarsScaleEditBox:SetScript("OnEditFocusLost", function() 
		if sArena:CombatLockdown() then
			CastingBarsScaleEditBox:SetText(sArenaDB.CastingBars.scale)
			return
		end
		
		if type(tonumber(CastingBarsScaleEditBox:GetText())) == "number" and tonumber(CastingBarsScaleEditBox:GetText()) > 0 then
			sArenaDB.CastingBars.scale = CastingBarsScaleEditBox:GetText()
			sArena.CastingBars:Scale(sArenaDB.CastingBars.scale)
		else
			CastingBarsScaleEditBox:SetText(sArenaDB.CastingBars.scale)
		end
	end)
	CastingBarsScaleEditBox:SetScript("OnEscapePressed", CastingBarsScaleEditBox.ClearFocus)
	CastingBarsScaleEditBox:SetScript("OnEnterPressed", CastingBarsScaleEditBox.ClearFocus)
	CastingBarsScaleEditBox.tiptext = "Sets the scale of the casting bars."
	CastingBarsScaleEditBox:SetScript("OnEnter", ClearButton:GetScript("OnEnter"))
	CastingBarsScaleEditBox:SetScript("OnLeave", ClearButton:GetScript("OnLeave"))
	
	local CastingBarsWidthText = CastingBarsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	CastingBarsWidthText:SetText("Bars width: ")
	CastingBarsWidthText:SetPoint("RIGHT", CastingBarsScaleEditBox, "RIGHT", 80, 0)
	
	local CastingBarsWidthEditBox = CreateFrame("EditBox", nil, self)
	CastingBarsWidthEditBox:SetPoint("LEFT", CastingBarsWidthText, "RIGHT", 4, -1)
	CastingBarsWidthEditBox:SetSize(75, 20)
	CastingBarsWidthEditBox:SetFontObject(GameFontHighlight)
	CastingBarsWidthEditBox:SetTextInsets(4,4,2,2)
	CastingBarsWidthEditBox:SetBackdrop(backdrop)
	CastingBarsWidthEditBox:SetBackdropColor(0,0,0,.4)
	CastingBarsWidthEditBox:SetAutoFocus(false)
	CastingBarsWidthEditBox:SetText(sArenaDB.CastingBars.width)
	CastingBarsWidthEditBox:SetScript("OnEditFocusLost", function() 
		if sArena:CombatLockdown() then
			CastingBarsWidthEditBox:SetText(sArenaDB.CastingBars.width)
			return
		end
		
		if type(tonumber(CastingBarsWidthEditBox:GetText())) == "number" and tonumber(CastingBarsWidthEditBox:GetText()) > 0 then
			sArenaDB.CastingBars.width = CastingBarsWidthEditBox:GetText()
			sArena.CastingBars:ConfigureWidth(sArenaDB.CastingBars.width)
		else
			CastingBarsWidthEditBox:SetText(sArenaDB.CastingBars.width)
		end
	end)
	CastingBarsWidthEditBox:SetScript("OnEscapePressed", CastingBarsWidthEditBox.ClearFocus)
	CastingBarsWidthEditBox:SetScript("OnEnterPressed", CastingBarsWidthEditBox.ClearFocus)
	CastingBarsWidthEditBox.tiptext = "Sets the width of the casting bars."
	CastingBarsWidthEditBox:SetScript("OnEnter", ClearButton:GetScript("OnEnter"))
	CastingBarsWidthEditBox:SetScript("OnLeave", ClearButton:GetScript("OnLeave"))
	
	local CastingBarsXOffsetText = CastingBarsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	CastingBarsXOffsetText:SetText("X/Y Offset: ")
	CastingBarsXOffsetText:SetPoint("BOTTOMLEFT", CastingBarsScaleText, "BOTTOMLEFT", 0, -32)
	
	local CastingBarsXOffsetEditBox = CreateFrame("EditBox", nil, self)
	CastingBarsXOffsetEditBox:SetPoint("LEFT", CastingBarsXOffsetText, "RIGHT", 4, 0)
	CastingBarsXOffsetEditBox:SetSize(75, 20)
	CastingBarsXOffsetEditBox:SetFontObject(GameFontHighlight)
	CastingBarsXOffsetEditBox:SetTextInsets(4,4,2,2)
	CastingBarsXOffsetEditBox:SetBackdrop(backdrop)
	CastingBarsXOffsetEditBox:SetBackdropColor(0,0,0,.4)
	CastingBarsXOffsetEditBox:SetAutoFocus(false)
	CastingBarsXOffsetEditBox:SetText(sArenaDB.CastingBars.x)
	CastingBarsXOffsetEditBox:SetScript("OnEditFocusLost", function() 
		if sArena:CombatLockdown() then
			CastingBarsXOffsetEditBox:SetText(sArenaDB.CastingBars.x)
			return
		end
		
		if type(tonumber(CastingBarsXOffsetEditBox:GetText())) == "number" then
			sArenaDB.CastingBars.x = CastingBarsXOffsetEditBox:GetText()
			sArena.CastingBars:ConfigurePoints(sArenaDB.CastingBars.x,sArenaDB.CastingBars.y)
		else
			CastingBarsXOffsetEditBox:SetText(sArenaDB.CastingBars.x)
		end
	end)
	CastingBarsXOffsetEditBox:SetScript("OnEscapePressed", CastingBarsXOffsetEditBox.ClearFocus)
	CastingBarsXOffsetEditBox:SetScript("OnEnterPressed", CastingBarsXOffsetEditBox.ClearFocus)
	CastingBarsXOffsetEditBox.tiptext = "Sets the x offset of the casting bars."
	CastingBarsXOffsetEditBox:SetScript("OnEnter", ClearButton:GetScript("OnEnter"))
	CastingBarsXOffsetEditBox:SetScript("OnLeave", ClearButton:GetScript("OnLeave"))
	
	local CastingBarsYOffsetEditBox = CreateFrame("EditBox", nil, self)
	CastingBarsYOffsetEditBox:SetPoint("LEFT", CastingBarsXOffsetEditBox, "RIGHT", 4, 0)
	CastingBarsYOffsetEditBox:SetSize(75, 20)
	CastingBarsYOffsetEditBox:SetFontObject(GameFontHighlight)
	CastingBarsYOffsetEditBox:SetTextInsets(4,4,2,2)
	CastingBarsYOffsetEditBox:SetBackdrop(backdrop)
	CastingBarsYOffsetEditBox:SetBackdropColor(0,0,0,.4)
	CastingBarsYOffsetEditBox:SetAutoFocus(false)
	CastingBarsYOffsetEditBox:SetText(sArenaDB.CastingBars.y)
	CastingBarsYOffsetEditBox:SetScript("OnEditFocusLost", function() 
		if sArena:CombatLockdown() then
			CastingBarsYOffsetEditBox:SetText(sArenaDB.CastingBars.y)
			return
		end
		
		if type(tonumber(CastingBarsYOffsetEditBox:GetText())) == "number" then
			sArenaDB.CastingBars.y = CastingBarsYOffsetEditBox:GetText()
			sArena.CastingBars:ConfigurePoints(sArenaDB.CastingBars.x,sArenaDB.CastingBars.y)
		else
			CastingBarsYOffsetEditBox:SetText(sArenaDB.CastingBars.y)
		end
	end)
	CastingBarsYOffsetEditBox:SetScript("OnEscapePressed", CastingBarsYOffsetEditBox.ClearFocus)
	CastingBarsYOffsetEditBox:SetScript("OnEnterPressed", CastingBarsYOffsetEditBox.ClearFocus)
	CastingBarsYOffsetEditBox.tiptext = "Sets the y offset of the casting bars."
	CastingBarsYOffsetEditBox:SetScript("OnEnter", ClearButton:GetScript("OnEnter"))
	CastingBarsYOffsetEditBox:SetScript("OnLeave", ClearButton:GetScript("OnLeave"))
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	local TrinketsFrame = LibStub("tekKonfig-Group").new(self, "Trinkets", "TOPLEFT", CastingBarsFrame, "BOTTOMLEFT", 0, -32)
	TrinketsFrame:SetPoint("RIGHT", self, -96, 0)
	TrinketsFrame:SetHeight(80)
	TrinketsFrame:SetFrameLevel(3)
	
	local TrinketsEnableCheckbox = LibStub("tekKonfig-Checkbox").new(self, nil, "Enable", "TOPLEFT", TrinketsFrame, 8, -8)
	TrinketsEnableCheckbox.tiptext = "Displays a cooldown icon when an enemy uses their PvP trinket."
	TrinketsEnableCheckbox:SetHitRectInsets(0, -40, 0, 0)
	TrinketsEnableCheckbox:SetChecked(sArenaDB.Trinkets.enabled and true or false)
	TrinketsEnableCheckbox:SetScript("OnClick", function()
		sArenaDB.Trinkets.enabled = TrinketsEnableCheckbox:GetChecked() and true or false
		sArena.Trinkets:HideTrinkets()
		sArena.Trinkets:Test(5)
		sArena.Trinkets:PLAYER_ENTERING_WORLD()
	end)
	
	local TrinketsAlwaysShowCheckbox = LibStub("tekKonfig-Checkbox").new(self, nil, "Always Show", "LEFT", TrinketsEnableCheckbox, "RIGHT", 45, 0)
	TrinketsAlwaysShowCheckbox.tiptext = "Always show trinket icons, regardless of whether they are on cooldown"
	TrinketsAlwaysShowCheckbox:SetChecked(sArenaDB.Trinkets.alwaysShow and true or false)
	TrinketsAlwaysShowCheckbox:SetScript("OnClick", function()
		sArenaDB.Trinkets.alwaysShow = TrinketsAlwaysShowCheckbox:GetChecked() and true or false
		sArena.Trinkets:AlwaysShow(sArenaDB.Trinkets.alwaysShow)
	end)
	
	local TrinketsIconScaleText = TrinketsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	TrinketsIconScaleText:SetText("Icon Scale: ")
	TrinketsIconScaleText:SetPoint("TOPLEFT", TrinketsEnableCheckbox, "BOTTOMLEFT", 6, -8)
	
	local TrinketsIconScaleEditBox = CreateFrame("EditBox", nil, self)
	TrinketsIconScaleEditBox:SetPoint("LEFT", TrinketsIconScaleText, "RIGHT", 4, -1)
	TrinketsIconScaleEditBox:SetSize(35, 20)
	TrinketsIconScaleEditBox:SetFontObject(GameFontHighlight)
	TrinketsIconScaleEditBox:SetTextInsets(4,4,2,2)
	TrinketsIconScaleEditBox:SetBackdrop(backdrop)
	TrinketsIconScaleEditBox:SetBackdropColor(0,0,0,.4)
	TrinketsIconScaleEditBox:SetAutoFocus(false)
	TrinketsIconScaleEditBox:SetText(sArenaDB.Trinkets.scale)
	TrinketsIconScaleEditBox:SetScript("OnEditFocusLost", function() 
		if sArena:CombatLockdown() then
			TrinketsIconScaleEditBox:SetText(sArenaDB.Trinkets.scale)
			return
		end
		
		if type(tonumber(TrinketsIconScaleEditBox:GetText())) == "number" and tonumber(TrinketsIconScaleEditBox:GetText()) > 0 then
			sArenaDB.Trinkets.scale = TrinketsIconScaleEditBox:GetText()
			sArena.Trinkets:Scale(sArenaDB.Trinkets.scale)
		else
			TrinketsIconScaleEditBox:SetText(sArenaDB.Trinkets.scale)
		end
	end)
	TrinketsIconScaleEditBox:SetScript("OnEscapePressed", TrinketsIconScaleEditBox.ClearFocus)
	TrinketsIconScaleEditBox:SetScript("OnEnterPressed", TrinketsIconScaleEditBox.ClearFocus)
	TrinketsIconScaleEditBox.tiptext = "Sets the scale of the trinket icons."
	TrinketsIconScaleEditBox:SetScript("OnEnter", ClearButton:GetScript("OnEnter"))
	TrinketsIconScaleEditBox:SetScript("OnLeave", ClearButton:GetScript("OnLeave"))
end

InterfaceOptions_AddCategory(sArena.OptionsPanel)
SLASH_sArena1 = "/sarena"
SlashCmdList[sArena.AddonName] = function() InterfaceOptionsFrame_OpenToCategory(sArena.OptionsPanel) end
