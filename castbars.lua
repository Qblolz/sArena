sArena.CastingBars = CreateFrame("Frame", nil, sArena)

sArena.Defaults.CastingBars = {
	scale = 1.3,
	width = 100,
	x = -80,
	y = -2,
}

_ArenaFrameCastBarMixin = {}

function Mixin(object, ...)
    local mixins = {...}
	
    for _, mixin in pairs(mixins) do
        for k,v in pairs(mixin) do
            object[k] = v
        end
    end

    return object
end

function sArena.CastingBars:Initialize()
	if ( not sArenaDB.CastingBars ) then
		sArena.Defaults.width = ArenaFrameCastBar:GetWidth()
		point, relativeTo, relativePoint, xOfs, yOfs = ArenaFrameCastBar:GetPoint()
		sArena.Defaults.x = tostring(xOfs)
		sArena.Defaults.y = tostring(yOfs)
		sArenaDB.CastingBars = CopyTable(sArena.Defaults.CastingBars)
	end
	
	for i = 1, MAX_ARENA_ENEMIES do
		local ArenaFrameCastBar = _G["ArenaEnemyFrame"..i.."CastingBar"];

        Mixin(ArenaFrameCastBar, _ArenaFrameCastBarMixin)

		self["arenaCastBar"..i] = ArenaFrameCastBar
		self:Configure(ArenaFrameCastBar)
	end
end
hooksecurefunc(sArena, "Initialize", function() sArena.CastingBars:Initialize() end)

function sArena.CastingBars:Configure(frame)
	frame:SetScale(sArenaDB.CastingBars.scale)
end

function sArena.CastingBars:ConfigureWidth(width)
	for i = 1, MAX_ARENA_ENEMIES do
		self["arenaCastBar"..i]:SetWidth(tonumber(width))
	end
end

function sArena.CastingBars:ConfigurePoints(x,y)
	for i = 1, MAX_ARENA_ENEMIES do
		self["arenaCastBar"..i]:SetPoint("RIGHT", tonumber(x), tonumber(y))
	end
end

function _ArenaFrameCastBarMixin:Test()
    local selfName = self:GetName()
    local barSpark = _G[selfName.."Spark"]
    local barText = _G[selfName.."Text"]
    local barIcon = _G[selfName.."Icon"]

    self:SetStatusBarColor(1.0, 0.7, 0.0)

    if ( barSpark ) then
        barSpark:Show()
    end

    if ( barText ) then
        barText:SetText("Spell Name")
    end
    if ( barIcon ) then
        barIcon:SetTexture(GetMacroIconInfo(math.random(1, GetNumMacroIcons())))
    end

    self.value = 1
    self.maxValue = 100
    self.holdTime = 0
    self.casting = 1
    self.castID = 1
    self.channeling = nil
    self.fadeOut = nil

    self:SetMinMaxValues(0, self.maxValue)
    self:SetValue(self.value)
    self:SetAlpha(1.0)

    self:Show()
end

function sArena.CastingBars:Test(numOpps)
	if ( sArena:CombatLockdown()) then
        return
    end

	for i = 1, numOpps do
        self["arenaCastBar"..i]:Test()
	end
end

hooksecurefunc(sArena, "Test", function(_, arg1)
    sArena.CastingBars:Test(arg1)
end)

function sArena.CastingBars:Scale(scale)
	for i = 1, MAX_ARENA_ENEMIES do
		self["arenaCastBar"..i]:SetScale(scale)
	end
end
sArena.Trinkets:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)