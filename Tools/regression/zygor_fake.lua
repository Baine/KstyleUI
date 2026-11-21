-- zygor_fake.lua: Zygor Guides Viewer's guide window, its skin table and its anchor save (ZygorGuidesViewerForever: MasterFrame.xml, Skins/Default/Skin.lua, Functions.lua 2237-2254), enough for the story rail to move it.
local Fake = {}

function Fake.Install(env, opts)
	opts = opts or {}
	env._loaded.ZygorGuidesViewerForever = true
	local master = env.CreateFrame("Frame", "ZygorGuidesViewerFrameMaster", env.UIParent)
	master:SetSize(40, 40)
	master:SetPoint("CENTER", env.UIParent, "CENTER", 0, 0)
	master:SetClampedToScreen(true)
	local frame = env.CreateFrame("Frame", "ZygorGuidesViewerFrame", master)
	frame:SetSize(320, 100)
	frame:SetPoint("TOPLEFT", master, "TOPLEFT", 0, 0)
	local profile = { resizeup = opts.resizeup == true, fixedheight = false, showcountsteps = 1, framescale = 1, frame_anchor = { "CENTER", "CENTER", 0, 0 } }
	local handlers = {}
	local style = { WindowBackdropColor = { 1, 0, 0, 1 }, StepFontSizeMod = 1 }
	local fake = { master = master, frame = frame, profile = profile, style = style, natural = opts.natural or 240, applied = 0, saves = 0, sets = 0 }
	local z = {
		Frame = frame,
		db = { profile = profile },
		Font = "Fonts\\FRIZQT__.TTF",
		CurrentSkinStyle = style,
		F = {},
	}
	env.ZygorGuidesViewer = z

	function z.F.SaveFrameAnchor(region, name, context)
		fake.saves = fake.saves + 1
		if not (region and name) then
			return
		end
		local context2 = context or profile
		local point = { region:GetPoint(1) }
		point[2] = nil
		context2[name] = point
	end

	function z.F.SetFrameAnchor(region, data)
		fake.sets = fake.sets + 1
		if not (region and data) then
			return
		end
		region:ClearAllPoints()
		region:SetPoint(data[1], env.UIParent, data[2], data[3], data[4])
	end

	-- The window sizes itself to its steps unless the player pinned the height (ZygorGuidesViewer.lua 2970-2971).
	function z:ResizeFrame()
		if profile.fixedheight then
			return
		end
		frame:SetHeight(fake.natural + 91.5)
	end

	function z:ReanchorFrame()
		frame:ClearAllPoints()
		frame:SetPoint(profile.resizeup and "BOTTOMLEFT" or "TOPLEFT", master, profile.resizeup and "BOTTOMLEFT" or "TOPLEFT", 0, 0)
		frame:SetClampRectInsets(0, 0, profile.resizeup and 0 or -68, profile.resizeup and 68 or 0)
	end

	function z:SetFrameScale()
		frame:SetScale(profile.framescale)
	end

	function z:ApplySkin()
		fake.applied = fake.applied + 1
	end

	function z:AddMessageHandler(event, fn)
		handlers[event] = handlers[event] or {}
		table.insert(handlers[event], fn)
	end

	function z:SendMessage(event, ...)
		for _, fn in ipairs(handlers[event] or {}) do
			fn(...)
		end
	end

	-- The client's own behaviour the rail must survive: any size change saves the height, and every show resaves the anchor.
	frame:SetScript("OnSizeChanged", function(self, width, height)
		if profile.fixedheight or profile.showcountsteps == 0 then
			profile.fullheight = height
		end
	end)

	function fake.Show()
		frame:Show()
		z:ReanchorFrame()
		z:ResizeFrame()
		z.F.SaveFrameAnchor(master, "frame_anchor")
		z:SendMessage("ZGV_FRAME_VISIBILITY", true)
	end

	function fake.Hide()
		frame:Hide()
		z:SendMessage("ZGV_FRAME_VISIBILITY", false)
	end

	function fake.Step()
		z:SendMessage("ZGV_STEP_CHANGED")
	end

	env._zygor = fake
	return fake
end

return Fake
