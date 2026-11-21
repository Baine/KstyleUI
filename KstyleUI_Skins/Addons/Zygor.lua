-- Zygor.lua: the Zygor switch: once Zygor Guides Viewer has loaded it restyles the guide window in the KstyleUI theme without touching Zygor's settings, and hangs the window in a card of its own on the story rail, its own mover in Layout Mode, re-placed after each step and after a layout change, out of combat, and kept out of Zygor's saved anchor while the rail holds it.
local _, ns = ...

local K = KstyleUI
local Widgets, Tokens, L = K.Widgets, K.Tokens, K.L

local MODULE = "Skins"
local KEY = "zygor"
local OWNER = "Skins.Zygor"
local ADDON = "ZygorGuidesViewerForever"
local RAIL = "rail"
local FIT = "fit"
local HOLDER = "KstyleUI_ZygorCard"
local DEFAULT_PRESET = "DPS"
local MOVED = 1
local MIN_WIDTH = 120
local WHITE = "Interface\\Buttons\\WHITE8X8"

local state = { z = nil, frame = nil, master = nil, holder = nil, placed = nil, original = nil, queued = false, hooked = false, held = false, patched = false, saved = nil }
local Place, Schedule, Restore, Fit

local function Log(message)
	K.DevTest.Log(MODULE, "zygor: " .. message)
end

local function IsTable(value)
	return type(value) == "table"
end

local function Plain(value)
	return type(value) == "number" and not Widgets.IsSecret(value) and value == value
end

local function Zygor()
	local z = rawget(_G, "ZygorGuidesViewer")
	if not IsTable(z) or not IsTable(z.Frame) then
		return nil
	end
	return z
end

local function On()
	return K.Modules.IsRunning(MODULE) and ns.Skins.IsOn(KEY) and ns.Skins.Setting(KEY, RAIL) == true
end

local function Preset()
	local Layout = K.Layout
	return Layout and type(Layout.Setting) == "function" and Layout.Setting("preset") or DEFAULT_PRESET
end

local function Shown()
	local z, quests, Setup = Zygor(), ns.Quests, K.Setup
	local Layouts = Setup and Setup.Layouts
	if not (z and z.Frame:IsShown() and On() and quests and type(quests.Active) == "function" and quests.Active() and Layouts and type(Layouts.Story) == "function") then
		return false
	end
	local _, rh = Setup.RootSize()
	local story = Layouts.Story(Preset(), rh, true, K.HudStyle.Current())
	return story ~= nil and not story.stacked
end

local function Spec(style)
	local Setup = K.Setup
	local Layouts = Setup and Setup.Layouts
	if not (Layouts and type(Layouts.Story) == "function") then
		return nil
	end
	local rw, rh = Setup.RootSize()
	local shown = Shown()
	local story = Layouts.Story(Preset(), rh, true, style, rw, shown) or Layouts.Story(DEFAULT_PRESET, rh, true, style, rw, shown)
	return story and story.guide
end

local function Remember(master, frame)
	if state.original then
		return
	end
	local function Points(region)
		local points = {}
		for i = 1, region:GetNumPoints() do
			points[i] = { region:GetPoint(i) }
		end
		return points
	end
	state.original = {
		points = Points(master),
		width = master:GetWidth(),
		height = master:GetHeight(),
		framePoints = Points(frame),
		frameWidth = frame:GetWidth(),
		frameHeight = frame:GetHeight(),
	}
end

local function Hold(on)
	state.held = on
end

local function Origin(region)
	return K.Scale.Origin() / Widgets.ScaleFactor(region)
end

local function Anchor(region, point, relativePoint, x, y)
	region:ClearAllPoints()
	if Widgets.Readability("snapEdges") then
		Widgets.Point(region, point, UIParent, relativePoint, x, y, true)
	else
		region:SetPoint(point, UIParent, relativePoint, x, y)
	end
end

local function Assert()
	local placed, master, frame = state.placed, state.master, state.frame
	if not (placed and master and frame) then
		return
	end
	master:SetClampedToScreen(false)
	master:SetClampRectInsets(0, 0, 0, 0)
	if placed.up then
		Anchor(master, "BOTTOMLEFT", "BOTTOMLEFT", placed.left, placed.bottom)
	else
		Anchor(master, "TOPLEFT", "BOTTOMLEFT", placed.left, placed.top)
	end
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:ClearAllPoints()
	frame:SetPoint(placed.up and "BOTTOMLEFT" or "TOPLEFT", master, placed.up and "BOTTOMLEFT" or "TOPLEFT")
	frame:SetWidth(placed.width)
	frame:SetHeight(placed.height)
end

function Fit()
	local placed, frame = state.placed, state.frame
	if not (placed and frame) then
		return
	end
	local height = placed.room
	if ns.Skins.Setting(KEY, FIT) == true then
		local natural = frame:GetHeight()
		if Plain(natural) and natural < height then
			height = natural
		end
	end
	if Plain(height) and height > 0 then
		local z = state.z
		local profile = IsTable(z) and IsTable(z.db) and z.db.profile
		local full = IsTable(profile) and profile.fullheight
		frame:SetHeight(height)
		if IsTable(profile) then
			profile.fullheight = full
		end
	end
end

local function Live()
	local Layout = K.Layout
	local spec = state.holder and Spec(K.HudStyle.Current())
	if spec and Layout and type(Layout.SetLive) == "function" then
		Layout.SetLive(spec.key, On())
	end
end

local function Strayed(master, frame)
	local placed = state.placed
	local point, relative, _, x, y = master:GetPoint(1)
	if point ~= (placed.up and "BOTTOMLEFT" or "TOPLEFT") or relative ~= UIParent or not (Plain(x) and Plain(y)) then
		return true
	end
	local want = placed.up and placed.bottom or placed.top
	if math.abs(x - placed.left) > MOVED or math.abs(y - want) > MOVED then
		return true
	end
	local width = frame:GetWidth()
	return Plain(width) and math.abs(width - placed.width) > MOVED
end

function Schedule()
	if state.queued or not On() then
		return
	end
	state.queued = true
	C_Timer.After(0, function()
		K.Combat.Queue(Place)
	end)
end

local function Holder(spec)
	if not state.holder then
		local holder = CreateFrame("Frame", HOLDER, K.Scale.Root())
		holder:EnableMouse(false)
		state.holder = holder
	end
	if spec then
		state.holder:SetSize(spec.width, spec.height)
	end
	return state.holder
end

local function Register(spec)
	if state.holder and spec then
		Widgets.Place(state.holder, spec.key, { anchor = spec.anchor, x = spec.x, y = spec.y }, { label = L["Zygor guide"], module = MODULE })
	end
end

function Place()
	state.queued = false
	if not On() then
		return false
	end
	if not ns.Guide.Is(KEY) then
		Restore()
		return false
	end
	local z = Zygor()
	local frame = z and z.Frame
	local master = frame and frame:GetParent()
	local spec = Spec(K.HudStyle.Current())
	local story = K.Setup.Story(Preset(), true, Shown())
	local band = story and story.guide
	if not (master and spec and band) then
		return false
	end
	if state.placed and Strayed(master, frame) then
		state.placed = nil
		Restore()
		K.Options.Write(MODULE, KEY .. "." .. RAIL, false)
		Log("the player moved the guide; the story rail lets it be")
		K.Print(L["KstyleUI leaves the Zygor guide where you put it. Turn Story rail back on in the Zygor skin's settings."])
		return false
	end
	Remember(master, frame)
	Hold(true)
	state.z, state.frame, state.master = z, frame, master
	Holder(spec)
	Register(spec)
	local scale = Widgets.ScaleFactor(master)
	local resizeup = IsTable(z.db) and IsTable(z.db.profile) and z.db.profile.resizeup
	state.placed = {
		left = band.left / scale + Origin(master),
		top = band.top / scale,
		bottom = band.bottom / scale,
		width = math.max(MIN_WIDTH, (band.right - band.left) / scale),
		room = (band.top - band.bottom) / scale,
		height = (band.top - band.bottom) / scale,
		up = resizeup == true,
	}
	Assert()
	if z.ResizeFrame then
		K.Call(z.ResizeFrame, z)
	end
	Fit()
	Live()
	return true
end

function Restore()
	state.placed = nil
	local z, master, frame, original = state.z, state.master, state.frame, state.original
	Hold(false)
	if not (z and master and frame) then
		return
	end
	state.original = nil
	master:SetClampedToScreen(true)
	master:ClearAllPoints()
	if original then
		for _, point in ipairs(original.points) do
			master:SetPoint(unpack(point))
		end
		if Plain(original.width) and Plain(original.height) then
			master:SetSize(original.width, original.height)
		end
		frame:ClearAllPoints()
		for _, point in ipairs(original.framePoints) do
			frame:SetPoint(unpack(point))
		end
		if Plain(original.frameWidth) and Plain(original.frameHeight) then
			frame:SetSize(original.frameWidth, original.frameHeight)
		end
	end
	if type(z.ResizeFrame) == "function" then
		K.Call(z.ResizeFrame, z)
	end
	Live()
end

local function Patch(z)
	if state.patched then
		return
	end
	state.patched = true
	local F = z.F
	if IsTable(F) and type(F.SaveFrameAnchor) == "function" then
		local save = F.SaveFrameAnchor
		F.SaveFrameAnchor = function(frame, name, context)
			if state.held and name == "frame_anchor" then
				return
			end
			return save(frame, name, context)
		end
	end
	if IsTable(F) and type(F.SetFrameAnchor) == "function" then
		local set = F.SetFrameAnchor
		F.SetFrameAnchor = function(frame, anchor)
			if state.held then
				return
			end
			return set(frame, anchor)
		end
	end
	if type(z.ResizeFrame) == "function" then
		hooksecurefunc(z, "ResizeFrame", function()
			Fit()
		end)
	end
	if type(z.ReanchorFrame) == "function" then
		hooksecurefunc(z, "ReanchorFrame", function()
			Assert()
		end)
	end
	if type(z.SetFrameScale) == "function" then
		hooksecurefunc(z, "SetFrameScale", function()
			Schedule()
		end)
	end
end

local function Flat()
	return { bgFile = WHITE, tile = true, tileSize = 16, insets = { left = 0, right = 0, top = 0, bottom = 0 } }
end

local function Card()
	return { bgFile = WHITE, edgeFile = WHITE, tile = true, tileSize = 16, edgeSize = 1, insets = { left = 1, right = 1, top = 1, bottom = 1 } }
end

local function Color(name)
	local r, g, b, a = Tokens.Color(name)
	return { r, g, b, a }
end

local function Clear()
	return { 0, 0, 0, 0 }
end

local function Paint(z)
	local style = z.CurrentSkinStyle
	if not IsTable(style) then
		return
	end
	state.saved = state.saved or {}
	local function Set(name, value)
		if state.saved[name] == nil then
			state.saved[name] = { style[name] }
		end
		style[name] = value
	end
	Set("WindowBackdrop", Card())
	Set("WindowBackdropFlipped", Card())
	Set("WindowBackdropColor", Color("surface"))
	Set("WindowBackdropBorderColor", Color("edgeInner"))
	Set("WindowBottomBackdrop", Card())
	Set("WindowBottomBackdropColor", Color("surface"))
	Set("WindowBottomBackdropBorderColor", Color("edgeInner"))
	Set("TabBackdrop", Flat())
	Set("TabBackdropColor", Clear())
	Set("SystemBarBackdropColor", Clear())
	Set("SystemBarBackdropBorderColor", Clear())
	Set("StepBackdropColor", Clear())
	Set("StepBackdropBorderColor", Clear())
	Set("StepBackdropPersistentBorder", false)
	Set("ProgressBarBackdrop", Flat())
	Set("ProgressBarBackdropColor", Color("surface"))
	Set("ProgressBarBackdropBorderColor", Clear())
	Set("ProgressBarTextureFile", WHITE)
	Set("ProgressBarTextureColor", Color("accent"))
	Set("ProgressBarDecorUse", 0)
	Set("StepFontSizeMod", 1)
	local path = ns.Style.Font("body")
	if type(path) == "string" then
		z.Font = path
	end
	if type(z.ApplySkin) == "function" then
		K.Call(z.ApplySkin, z)
	end
end

local function Unpaint(z)
	local style, saved = z.CurrentSkinStyle, state.saved
	if not (IsTable(style) and saved) then
		return
	end
	for name, value in pairs(saved) do
		style[name] = value[1]
	end
	state.saved = nil
	if type(z.ApplySkin) == "function" then
		K.Call(z.ApplySkin, z)
	end
end

local function Hook(z)
	state.z = z
	Patch(z)
	if state.hooked then
		return
	end
	state.hooked = true
	if type(z.AddMessageHandler) == "function" then
		z:AddMessageHandler("ZGV_FRAME_VISIBILITY", function(visible)
			if visible then
				ns.Guide.Touch(KEY)
			end
			ns.Guide.Schedule()
		end)
		z:AddMessageHandler("ZGV_GUIDE_LOADED", Schedule)
		z:AddMessageHandler("ZGV_STEP_CHANGED", Schedule)
		z:AddMessageHandler("SKIN_UPDATED", function()
			K.Combat.Queue(function()
				local live = Zygor()
				if live then Paint(live) end
				Schedule()
			end)
		end)
	end
	K.Events.Register(OWNER, "PLAYER_ENTERING_WORLD", Schedule)
	K.Callbacks.Register("LayoutChanged", OWNER, Schedule)
	K.Callbacks.Register("SettingChanged", OWNER, function(_, module, key)
		if module == "Layout" and key == "preset" then
			Schedule()
		end
	end)
	if not state.tracked then
		state.tracked = { Restyle = Schedule }
		Widgets.Track(state.tracked)
	end
end

local function Start(z)
	Hook(z)
	Paint(z)
	K.Combat.Queue(Place)
end

ns.Guide.Add(KEY, {
	addon = ADDON,
	Enabled = function()
		return Zygor() ~= nil and ns.Skins.IsOn(KEY) and ns.Skins.Setting(KEY, RAIL) == true
	end,
	Visible = function()
		return Shown()
	end,
	Schedule = Schedule,
})

ns.Skins.Add({
	key = KEY,
	label = L["Zygor"],
	help = L["Gives Zygor Guides Viewer the KstyleUI theme and puts its guide on the story rail."],
	addon = ADDON,
	defaults = { rail = true, fit = true },
	rows = {
		{ type = "toggle", key = FIT, label = L["Fit guide to its steps"], help = L["Size the guide to its steps. Off stretches it over the story slot."] },
		{
			type = "toggle", key = RAIL, label = L["Story rail"],
			help = L["Puts the guide in its own card on the story rail. Drag the guide away to keep your spot."],
		},
	},
	Apply = function()
		local z = Zygor()
		if not z then
			return
		end
		Start(z)
	end,
	OnSwitch = function(_, on)
		local z = Zygor()
		if not z then
			return
		end
		if on then
			Start(z)
		else
			Restore()
			Unpaint(z)
		end
	end,
	OnSetting = function(_, field)
		if field == nil or field == RAIL then
			if On() then
				Schedule()
			else
				Restore()
			end
		elseif field == FIT then
			Schedule()
		end
	end,
})
