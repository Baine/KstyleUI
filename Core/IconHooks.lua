-- IconHooks.lua: shows the custom icon set on Blizzard's spellbook icons by watching their textures with Icons.Watch.
local _, ns = ...

local MODULE, ADDON = "Icons", "Blizzard_PlayerSpells"
local hooked = false

local function log(message)
	ns.DevTest.Log(MODULE, message)
end

local function watchItem(item)
	local button = type(item) == "table" and item.Button
	if type(button) == "table" then
		ns.Icons.Watch(button.Icon)
	end
end

local function watchPage(paged)
	paged:ForEachFrame(watchItem)
end

local function hook()
	hooked = true
	local frame = _G.PlayerSpellsFrame
	local book = type(frame) == "table" and frame.SpellBookFrame
	local paged = type(book) == "table" and book.PagedSpellsFrame
	if type(paged) ~= "table" or type(paged.ForEachFrame) ~= "function" or type(paged.DisplayViewsForCurrentPage) ~= "function" or type(hooksecurefunc) ~= "function" then
		log("spellbook: its spell pages are missing; Blizzard's icons stay")
		return
	end
	watchPage(paged)
	hooksecurefunc(paged, "DisplayViewsForCurrentPage", watchPage)
	log("spellbook: watching its spell icons")
end

local function onAddonLoaded(_, name)
	if name == ADDON then
		ns.Events.Unregister(MODULE, "ADDON_LOADED")
		hook()
	end
end

ns.Callbacks.Register("ModuleChanged", "IconHooks", function(_, name, running)
	if name ~= MODULE or not running or hooked then
		return
	end
	local AddOns = C_AddOns
	if AddOns and type(AddOns.IsAddOnLoaded) == "function" and AddOns.IsAddOnLoaded(ADDON) then
		hook()
	else
		ns.Events.Register(MODULE, "ADDON_LOADED", onAddonLoaded)
		log("spellbook: waits for Blizzard_PlayerSpells to load")
	end
end)
