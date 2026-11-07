# WoW Forever: product identity, client/API base, and authoritative addon API sources

Research date: 2026-11-06 (two days after Forever launched). "Local" sources are files on the user's Mac, read without changes. "Gethe forever branch" means `github.com/Gethe/wow-ui-source`, branch `forever`, commit `5987a8e230` ("1.60.1 (70840)", 2026-11-06). I shallow-cloned that branch into the scratchpad and grepped it. That build matches the installed client exactly.

## 1. What is WoW Forever? Dates, ruleset/content, relation to Retail/Classic, and the "camelot" game type

### Takeaway
World of Warcraft: Forever is a separate WoW branch, informally called "Classic+". It was announced at BlizzCon 2026 on 12 September 2026 and launched on 4 November 2026 (23:00 UTC; 5 November in European time zones). It is set in an expanded vanilla-era Azeroth with a level cap of 60. It runs beside Retail (Midnight) and Classic, and needs only a normal subscription. "Camelot" is its internal codename, and that name is still the game-type token in the shipped client. `forever` is accepted as an alias.

### Cited Findings
- Blizzard announced Forever at BlizzCon 2026 on 12 September 2026, as the final reveal of the opening ceremony. — [Wikipedia](https://en.wikipedia.org/wiki/World_of_Warcraft:_Forever); [Variety (BlizzCon)](https://variety.com/2026/digital/news/world-of-warcraft-forever-le-sserafim-blizzcon-1236940363/)
- Launch date: Variety says 4 November. The Warcraft Wiki lists "November 4/5, 23:00 UTC", and Heise reports it as playable "since Thursday" (5 November, European date). These describe the same moment in different time zones. — [Variety](https://variety.com/2026/gaming/news/world-of-warcraft-forever-release-november-1236859755/); [warcraft.wiki.gg: World of Warcraft: Forever](https://warcraft.wiki.gg/wiki/World_of_Warcraft:_Forever); [Heise](https://www.heise.de/en/news/Forever-Blizzard-takes-players-back-to-classic-World-of-Warcraft-11514117.html)
- Pre-launch timeline: beta from 17 September, stress test 21 October, end-of-beta event 22 October, name reservation 27 October. — [warcraft.wiki.gg: Forever](https://warcraft.wiki.gg/wiki/World_of_Warcraft:_Forever)
- The internal codename was "Camelot", and the community calls it "Classic+". The wiki describes Forever as "an alternative version" that keeps the 2004 core mechanics and look, as a standalone branch beside Retail and Classic and not in Retail's continuity. — [warcraft.wiki.gg: Forever](https://warcraft.wiki.gg/wiki/World_of_Warcraft:_Forever)
- Setting and content: the first year of WoW, after Warcraft III Reforged's *Forsaken Kingdom* and before *The Burning Crusade*. It adds 3 new zones, over 1,000 new quests, 9 new dungeons, 2 new raids and a new Skyborne race. — [Variety](https://variety.com/2026/gaming/news/world-of-warcraft-forever-release-november-1236859755/); [Wikipedia](https://en.wikipedia.org/wiki/World_of_Warcraft:_Forever)
- Rulesets: Normal, PvP, RP and RP-PvP at launch, plus Hardcore planned for winter 2026/27, each on one "mega-realm" per region. Design pillars: level cap 60 with no increases, no flying, no level scaling. Other features: dual spec from level 40, account-wide Collections (transmog, toys, mounts, pets), a "Legacy System" that replaces achievements, camping, and an SD/HD model toggle. Raids unlock on 9 December 2026. — [warcraft.wiki.gg: Forever](https://warcraft.wiki.gg/wiki/World_of_Warcraft:_Forever)
- Forever is included with a subscription or game time. The Skyborne race requires an optional upgrade pack (from about €30). — [Heise](https://www.heise.de/en/news/Forever-Blizzard-takes-players-back-to-classic-World-of-Warcraft-11514117.html); [warcraft.wiki.gg: Forever](https://warcraft.wiki.gg/wiki/World_of_Warcraft:_Forever)
- Blizzard's Discord post of 15 September 2026, "An Update On Secrets In WoW: Forever", calls Forever and Midnight two game types in the Mainline code family, "Camelot" and "Standard", and said Camelot would be renamed before launch. — [warcraft.wiki.gg: Patch 1.60.1/API changes/notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)
- The rename did not reach the code. In the live 1.60.1.70840 source, Blizzard's own TOCs still gate on `camelot`: 208 inline `[AllowLoadGameType camelot]` directives, 128 `[ExcludeLoadGameType camelot]`, and Forever-specific folders are named `Camelot/`. — Gethe forever branch, e.g. [Blizzard_ProjectConstants.toc](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ProjectConstants/Blizzard_ProjectConstants.toc) (my grep counts)
- Beta Changes 4 (build 70291, 8 October 2026): "Forever is now accepted as an alias for Camelot in TOC file suffixes". The alias also covers the `[Game]` variable and game-type folder lookup. — [warcraft.wiki.gg: API changes/notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)
- Valid AllowLoadGameType tokens per the TOC format page: game types `standard`, `forever`, `camelot`, `mists`, `cata`, `wrath`, `tbc`, `vanilla`, `plunderstorm`, `wowhack`; families `mainline` (standard, forever, camelot, plunderstorm, wowhack) and `classic` (vanilla, tbc, wrath, cata, mists). The page notes the Camelot value "may be changed to Forever in the future". — [warcraft.wiki.gg: TOC format](https://warcraft.wiki.gg/wiki/TOC_format)
- `wowhack` is the token for "Talebound" (`_WoWHack.toc`), and `plunderstorm` for Plunderstorm/WoW Labs. — [warcraft.wiki.gg: TOC format](https://warcraft.wiki.gg/wiki/TOC_format)

### Inferences
- `camelot` is in the `mainline` family, not `classic`. An addon gated `[AllowLoadGameType classic]` will not load in Forever, and one gated `mainline` will.
- Use `camelot` in AllowLoadGameType. Blizzard's own 70840 code uses it everywhere, and the `forever` alias is confirmed only for TOC suffixes, `[Game]` and folder lookup. The TOC format page also lists `forever` as an AllowLoadGameType value, so either probably works, but `camelot` is what Blizzard's code demonstrably uses.

### Gaps
- I did not fetch an official worldofwarcraft.blizzard.com launch or announcement article directly; the dates come from Variety, Wikipedia, Heise and the Warcraft Wiki. ForeverMeta cites official pages I did not open: [worldofwarcraft.blizzard.com/en-us/forever](https://worldofwarcraft.blizzard.com/en-us/forever) and the EU forum [WoW Forever Beta Development Notes](https://eu.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-updated-15-october/631316).
- No source says whether Blizzard still plans to rename `camelot` to `forever` in a future patch.

## 2. Client version and engine: 1.60.x numbering vs Retail 12.x; is the Lua API the modern Retail API?

### Takeaway
Forever runs the modern Mainline (Retail) client and UI, not the Classic Era 1.15 code base. The version number 1.60.1 is a branding choice. Blizzard says Forever shares "the vast majority of APIs available in 12.1.5", including Midnight's secret-value and addon restrictions. Forever = Retail 12.1.5 Mainline code + a `Camelot/` override layer + a few Forever-only systems.

### Cited Findings
- The installed client identifies itself as `World of Warcraft Retail ARM64 1.60.1.70840`. Product flavor is `wowf` and `agentUID` is `wowf`. — Local: `/Applications/World of Warcraft/_forever_/Logs/gx.log`, `/Applications/World of Warcraft/_forever_/.flavor.info`, `/Applications/World of Warcraft/_forever_/WTF/Config.wtf`
- Blizzard's patch server lists product `wowf` at `1.60.1.70840` (BuildId 70840) for us, eu, cn, kr and tw. — [us.version.battle.net/v2/products/wowf/versions](https://us.version.battle.net/v2/products/wowf/versions)
- The beta used the same version line under a different product: the user's `_classic_beta_` install (flavor `wow_classic_beta`) logged `World of Warcraft BetaRetail ARM64 1.60.1.70450` on 19 October 2026. — Local: `/Applications/World of Warcraft/_classic_beta_/Logs/gx.log`
- Blizzard's statement (Discord, 15 September 2026): "WoW Forever shares Mainline WoW's UI architecture, including the vast majority of APIs available in 12.1.5." Also: "The addon disarmament changes introduced in Midnight, including secrets, will also be active in Forever." And: "The AuraContainer/AuraButton changes introduced in 12.1.0 will be available as well." — [warcraft.wiki.gg: Patch 1.60.1/API changes/notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes); also reported by [Icy Veins](https://www.icy-veins.com/wow-forever/news/addons-in-wow-forever-blizzard-devs-just-addressed-the-big-question/)
- The wiki's API diff compares Forever against Retail, not Classic Era: "12.1.5 (69952) → 1.60.1 (70205)". It counts 176 global API functions added and 10 removed, and 471 FrameXML functions added and 1,041 removed. New namespaces include `C_BlizzCon2026`, `C_Flyout`, `C_GamepadTargeting` and `C_GamepadUI`. — [warcraft.wiki.gg: Patch 1.60.1/API changes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes)
- Forever-specific API: `C_GameRules.GetForeverExperiencePreset()`, `SetForeverExperiencePresetPreLogin` and `SetForeverExperiencePresetPostLogin`, with enum `ForeverExperiencePreset` = `Classic` (0) / `Enhanced` (1). Constant groups include `LevelConstsExposed_Camelot`, `LootConsts_Camelot`, `PetConsts_Camelot` and `QuestLogConstsMainlineCamelot`. `TraitConfigType.CamelotCombat` = 4 is a separate talent config type. — Gethe forever branch: [GameRulesDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/GameRulesDocumentation.lua), [TraitConstantsDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/TraitConstantsDocumentation.lua)
- The modern systems are present in Forever's 70840 source with full Mainline API docs: `Blizzard_EditMode`, `Blizzard_Settings`, `Blizzard_CooldownViewer`, `Blizzard_DamageMeter`, `Blizzard_PlayerSpells`, `Blizzard_Menu`, and secret-value docs (`SecretPredicatesDocumentation`, `SecretAspectConstantsDocumentation`, `RestrictedActionsDocumentation`). There are 643 generated documentation files. — Gethe forever branch, [Interface/AddOns](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns) (my listing)
- Restriction changes during the Forever beta: trial accounts cannot send addon messages. `FrameStrata` became a new secret aspect, so `GetFrameStrata` can return a secret. Lua `require` was renamed to `import`. `C_PvP.IsWarModeFeatureEnabled()` returns false. Creature and game-object GUIDs have obfuscated server and spawn IDs. New nameplate CVars: `nameplateMaxVerticalDistance` and `nameplateMaxVerticalDistanceAtMaxRange`. — [warcraft.wiki.gg: API changes/notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)
- Locally installed addons from the same authors share one code base between Retail and Forever: `Narcissus.toc` declares `## Interface: 120105, 16001`, and `Plumber.toc` and `DialogueUI.toc` list 120107/120105 and 16001 together. — Local: `/Applications/World of Warcraft/_forever_/Interface/AddOns/*/` TOC files
- Secondary: a fan guide says combat-log events do not reach addons and that addons cannot message other players inside instances. It attributes these to Midnight's restrictions, not to a direct Blizzard quote. — [ForeverMeta](https://forevermeta.me/en/guides/wow-forever-addons-interface) (fan site, treat as unverified)

### Inferences
- Write a Forever UI overhaul against the Retail 12.1.x API: C_ namespaces, mixins, `Settings` API, Edit Mode, Menu API and secret values. Classic Era APIs and FrameXML layouts do not apply, so ignore Classic Era guides.
- Expect Retail frame names with Forever-specific layouts. Many frames come from `Camelot/` override files, so their child regions and anchors can differ from Retail 12.1.5 (see section 7).
- "1.60.1" is a product number, not an engine generation. The binary is the Retail binary ("Retail ARM64"), and its code was branched from Retail 12.1.5 build 69952.

### Gaps
- I did not read the full API diff (263k characters) to list every removed API. For a specific function, check the Gethe forever branch or the in-game `/api` command directly.
- I found no Blizzard text confirming whether the combat log (`COMBAT_LOG_EVENT_UNFILTERED`) is fully blocked in Forever; only fan sites claim it.

## 3. Where the official (and best practical) API documentation for Forever lives

### Takeaway
Blizzard publishes no web API reference for Forever. The authoritative source is the client itself: `Blizzard_APIDocumentationGenerated` (browse it in game with `/api`) and the exported FrameXML. The best mirror is the Gethe/wow-ui-source `forever` branch, which tracks each live `wowf` build (currently 1.60.1.70840, the same build as the user's client). The warcraft.wiki.gg pages for TOC format, WOW_PROJECT_ID and Patch 1.60.1 API changes and notes are the best secondary references. Townlong Yak and wago.tools did not show Forever builds in my checks.

### Cited Findings
- Gethe/wow-ui-source has a `forever` branch; the other branches are automation, beta, classic_anniversary, classic_beta, classic_era(_ptr), classic(_ptr), classic_titan, live, ptr and ptr2. — [GitHub branches](https://github.com/Gethe/wow-ui-source/branches) (via the GitHub API)
- Recent commits on the forever branch: "Monitor wowf product" (2026-11-02), then "1.60.1 (70707)", "1.60.1 (70755)", "1.60.1 (70790)" (2026-11-04) and "1.60.1 (70840)" (2026-11-06). `version.txt` = `1.60.1.70840`. There are no Forever tags; tags exist only for Retail versions such as 12.1.5 and 12.1.7. — [Gethe forever branch](https://github.com/Gethe/wow-ui-source/tree/forever); [commits](https://github.com/Gethe/wow-ui-source/commits/forever)
- The forever branch holds 349 Blizzard addons, against 339 on `live` (12.1.5 build 70783), including `Blizzard_APIDocumentation` and `Blizzard_APIDocumentationGenerated`. The generated docs are the same data the in-game `/api` browser shows. — [Gethe forever branch, Blizzard_APIDocumentationGenerated](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated) (my listing)
- The Classic beta branch is not where Forever lives: `classic_beta` was last exported at 5.5.0 (Mists, July 2025), with "Disable cron-based export" on 2025-11-03. — [Gethe classic_beta commits](https://github.com/Gethe/wow-ui-source/commits/classic_beta)
- Warcraft Wiki reference pages that cover Forever:
  - [TOC format](https://warcraft.wiki.gg/wiki/TOC_format): Interface 16001, `_Forever` and `_Camelot` suffixes, game-type tokens.
  - [WOW_PROJECT_ID](https://warcraft.wiki.gg/wiki/WOW_PROJECT_ID): `WOW_PROJECT_CAMELOT` = 18.
  - [Patch 1.60.1/API changes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes): diff against 12.1.5.
  - [Patch 1.60.1/API changes/notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes): Blizzard's Discord dev notes and Beta Changes 4 and 5.
- Blizzard's developer communication for Forever ran through the WoW UI developer Discord (the 15 September 2026 post and the Beta Changes posts), which the Warcraft Wiki mirrors. ForeverMeta also cites EU forum "Development Notes" by Kaivax (24 September to 16 October 2026) and the [WoW Forever Beta Discussion forum](https://us.forums.blizzard.com/en/wow/c/in-development/wow-forever-beta-discussion/349). The only formal addon policy is the old [UI Add-On Development Policy](https://us.forums.blizzard.com/en/wow/t/ui-add-on-development-policy/24534). — [warcraft.wiki.gg: API changes/notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes); [ForeverMeta](https://forevermeta.me/en/guides/wow-forever-addons-interface)
- Townlong Yak: the `/framexml/live` page showed only Retail builds (70783 at 12.1.5, 70688 and 70424 at 12.1.7) in the part I could read, and curl requests to `/framexml/wowf` and `/framexml/forever` returned HTTP 403 (bot protection, not necessarily a missing page). — [Townlong Yak FrameXML](https://www.townlong-yak.com/framexml/live)
- The Warcraft Wiki's [Viewing Blizzard's interface code](https://warcraft.wiki.gg/wiki/Viewing_Blizzard%27s_interface_code) lists Gethe wow-ui-source, Gethe wow-ui-textures and Townlong Yak as alternatives to exporting from the client. That page was last edited in September 2024 and says nothing about Forever.

### Inferences
- Priority order for a Forever-only addon author:
  1. The in-game `/api` command and the client's own exported code (exact build).
  2. The Gethe `forever` branch (same build, greppable, includes `Camelot/` overrides).
  3. The Warcraft Wiki Patch 1.60.1 API changes and notes pages (what differs from 12.1.5 and why).
  4. Retail 12.1.5 documentation for anything Forever did not change.
- Comparing Gethe `forever` with `live` (12.1.5) is the fastest way to see what Forever changed in any Blizzard file.

### Gaps
- wago.tools: its build API returned only a `message` field (no data) to an anonymous request, so I could not confirm whether it lists `wowf` builds or DB2 tables. Check in a browser.
- Townlong Yak: not confirmed either way; check in a browser for a wowf or Forever build selector.
- I found no Blizzard developer or news article dedicated to Forever addon APIs. Blizzard's only addon guidance came through Discord posts that the wiki and press relay.

## 4. Exact WOW_PROJECT_ID and runtime detection of Forever

### Takeaway
`WOW_PROJECT_ID == WOW_PROJECT_CAMELOT`, where `WOW_PROJECT_CAMELOT = 18`. The constant is defined only when the `camelot` game type loads, so outside Forever it is nil. There is no `WOW_PROJECT_FOREVER`.

### Cited Findings
- `Interface/AddOns/Blizzard_ProjectConstants/Camelot/ProjectConstants.lua` contains exactly `WOW_PROJECT_CAMELOT = 18;` and `WOW_PROJECT_ID = WOW_PROJECT_CAMELOT;`. It loads through `Camelot\ProjectConstants.lua [AllowLoadGameType camelot]` in `Blizzard_ProjectConstants.toc`. — [Gethe forever: ProjectConstants.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ProjectConstants/Camelot/ProjectConstants.lua)
- In Blizzard's own glue code: "-- WOW_PROJECT_CAMELOT is only defined when the camelot game type is loaded. `local defaultProjectID = WOW_PROJECT_CAMELOT or WOW_PROJECT_MAINLINE;`" — [Gethe forever: GlueParent.lua (Mainline)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_GlueParent/Mainline/GlueParent.lua)
- The Warcraft Wiki table lists `WOW_PROJECT_CAMELOT` = 18 for "World of Warcraft: Forever", added in Patch 1.60.1 (2026-11-04). Other values: MAINLINE 1, CLASSIC 2, WOWLABS 3, BURNING_CRUSADE_CLASSIC 5, WRATH_CLASSIC 11, CATACLYSM_CLASSIC 14, MISTS_CLASSIC 19. The page carries an "out of date" flag, but the Gethe source confirms the value. — [warcraft.wiki.gg: WOW_PROJECT_ID](https://warcraft.wiki.gg/wiki/WOW_PROJECT_ID)
- Blizzard's own UI code never tests `WOW_PROJECT_ID == WOW_PROJECT_CAMELOT`. It selects Forever code at load time through TOC directives (`[AllowLoadGameType camelot]`, `[Game]\file.lua`). — Gethe forever branch (my grep: the only `WOW_PROJECT_ID ==` comparisons are 4 against `WOW_PROJECT_CLASSIC`)
- `C_GameRules.GetForeverExperiencePreset()` returns a nilable `ForeverExperiencePreset` (Classic 0 / Enhanced 1), which identifies the player's UI preset choice, not the flavor. — [Gethe forever: GameRulesDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/GameRulesDocumentation.lua)

### Inferences
- Recommended runtime check: `local IS_FOREVER = WOW_PROJECT_CAMELOT ~= nil and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT`. Do not write `WOW_PROJECT_ID == WOW_PROJECT_CAMELOT` alone: if both are nil outside Forever, `nil == nil` would be true. A hard-coded `WOW_PROJECT_ID == 18` also works.
- For a Forever-only addon, load-time gating is better than runtime checks. Ship only `AddonName_Camelot.toc` (or `_Forever.toc`) with `## Interface: 16001` and `## AllowLoadGameType: camelot`, as WaypointUI and EllesmereUI do.
- The "Classic" vs "Enhanced" experience preset (`C_GameRules.GetForeverExperiencePreset`) probably changes which default Blizzard UI layout is shown. A UI overhaul should read it and test both presets.

### Gaps
- I could not run the client, so I did not confirm what `GetBuildInfo()` returns in Forever. Presumably `"1.60.1", "70840", <date>, 16001`, given the Interface number, but this is unverified.
- The ForeverExperiencePreset values' exact effect on the default UI is not documented in the sources I read.

## 5. TOC format specifics for Forever

### Takeaway
Use `## Interface: 16001` and the suffix `_Camelot.toc` (or its alias `_Forever.toc`). For in-file gating, use `camelot`. Forever uses the Mainline AddOn List and addon compartment, so `Category`, `Group`, `IconTexture`, `IconAtlas`, `AddonCompartmentFunc` and the newer 12.x directives (`Bootstrap`, `RegionalTextLocale`) all apply.

### Cited Findings
- Interface numbers per the TOC format page: Forever `16001`; Midnight Standard `120105`; Midnight Standard Test `120107`; Vanilla `11509`; TBC `20506`; Wrath `30405`; Wrath (Titan Reforged) `38002`; Cata `40402`; Mists `50504`. — [warcraft.wiki.gg: TOC format](https://warcraft.wiki.gg/wiki/TOC_format)
- Locally, third-party Forever TOCs use `## Interface: 16001`: `WaypointUI_Camelot.toc` alone, `Narcissus.toc` as `120105, 16001`, BugSack as part of a multi-flavor list. The Forever beta addon `EllesmereUIForeverEssentials_Camelot.toc` uses `## Interface: 16001` and `## AllowLoadGameType: camelot`. — Local: `/Applications/World of Warcraft/_forever_/Interface/AddOns/WaypointUI/WaypointUI_Camelot.toc`; `/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIForeverEssentials/EllesmereUIForeverEssentials_Camelot.toc`
- Filename suffixes: game suffixes `_Forever.toc` and `_Camelot.toc` for Forever, and `_Standard.toc` for Midnight (added in 12.1.5). Family suffix `_Mainline.toc` also matches Forever because camelot is in the mainline family, but "Family suffixes have a lower priority" than game suffixes. `_Classic.toc` does not apply to Forever. — [warcraft.wiki.gg: TOC format](https://warcraft.wiki.gg/wiki/TOC_format); [ForeverMeta](https://forevermeta.me/en/guides/wow-forever-addons-interface)
- Patch 1.60.1 (Forever) added the Camelot game type, the `[Game]` variable value and the TOC suffix. Forever also inherits the 12.x TOC features: `Bootstrap` inline directive (12.1.0; listed for "Midnight and Forever"), `RegionalTextLocale` (12.1.7 PTR; "Midnight and Forever"), inline directives and variables (12.0.7), `ExcludeLoadGameType` (12.0.0), `AllowLoadTextLocale` (11.2.0), `AllowAddOnTableAccess` (11.1.7), and `LoadSavedVariablesFirst` with `AllowLoadGameType` usable by insecure addons (11.1.5). — [warcraft.wiki.gg: TOC format](https://warcraft.wiki.gg/wiki/TOC_format)
- `[Game]` and `[Family]` path variables resolve to `Camelot` and `Mainline` folders in Forever. Blizzard's Forever TOCs follow this pattern, e.g. `Blizzard_Minimap.toc`: `[Family]\Minimap.lua` then `[Game]\Minimap.lua [AllowLoadGameType camelot]`, and `[Family]\MinimapConstants.lua [AllowLoadGameType mainline] [ExcludeLoadGameType camelot]`. — Gethe forever branch: [Blizzard_Minimap.toc](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_Minimap/Blizzard_Minimap.toc)
- Forever's AddOn List reads `IconTexture`, `IconAtlas`, `Group` and `Category` (`Blizzard_AddOnList/AddonList.lua` lines 390–456). The addon compartment (`Blizzard_Minimap/Mainline/AddonCompartment.lua`) reads `AddonCompartmentFunc`, `AddonCompartmentFuncOnEnter` and `AddonCompartmentFuncOnLeave`, and Forever's `Camelot/AddonCompartment.lua` only extends `AddonCompartmentMixin:OnLoad` on top of it. — Gethe forever branch: [AddonList.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_AddOnList/AddonList.lua), [Camelot/AddonCompartment.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_Minimap/Camelot/AddonCompartment.lua)
- Directive semantics: `Category` sets the collapsible AddOn List header; `Group` "must be the name of the main addon"; `IconTexture` takes priority over `IconAtlas`; `AddonCompartmentFunc` is "required" for automatic compartment registration. — [warcraft.wiki.gg: TOC format](https://warcraft.wiki.gg/wiki/TOC_format)
- On CurseForge, authors tag Forever files with game version 1.60.1 (interface 16001). — [Timesaver](https://timesaver.gg/blog/wow-forever-addons-save-beta-ui-before-launch) (secondary)

### Inferences
- Minimal Forever-only TOC:
  ```
  ## Interface: 16001
  ## AllowLoadGameType: camelot
  ## Title: KstyleUI
  ## Category: ...
  ## IconTexture: ...
  ## AddonCompartmentFunc: KstyleUI_OnAddonCompartmentClick
  ## SavedVariables: ...
  ```
  Name the file `KstyleUI_Camelot.toc`, or `KstyleUI_Forever.toc` via the alias. A suffixed TOC alone is enough to keep the addon from loading in Retail; adding `AllowLoadGameType: camelot` is a second guard.
- Some third-party TOCs use `## X-GameType: Camelot [AllowLoadGameType camelot]`. That pattern sets an `X-` metadata value per flavor; it is not a required Forever field.

### Gaps
- I found no Forever-specific TOC fields beyond the Camelot game type, suffix and `[Game]` value.
- I did not confirm whether the client warns about "out of date" for TOCs listing 16001 alongside a Retail Interface number.

## 6. Exporting Forever's interface code locally (ExportInterfaceFiles, wow.export, CASC)

### Takeaway
The standard method should work for Forever because it is the Mainline client: launch with the console enabled, then at the login or character-select screen run `ExportInterfaceFiles code` (and `ExportInterfaceFiles art`). Files land in `BlizzardInterfaceCode` and `BlizzardInterfaceArt` inside the install folder (here `_forever_`). If you don't want to touch the install, the Gethe `forever` branch already holds the exported code for build 70840.

### Cited Findings
- "The ExportInterfaceFiles command only works from the actual console on the login and character selection screens." It does not work through `/console` or while logged into a character ("Unknown Command"). Output goes to "BlizzardInterfaceCode" and "BlizzardInterfaceArt" in the WoW directory. The console requires the `-console` launch flag (see the Console article). — [warcraft.wiki.gg: Viewing Blizzard's interface code](https://warcraft.wiki.gg/wiki/Viewing_Blizzard%27s_interface_code)
- The Gethe repo is produced from the client per product; the forever branch was set up with "Monitor wowf product" on 2026-11-02 and now has 5,169 entries at build 70840 (about 54 MB as a shallow clone). — [Gethe forever commits](https://github.com/Gethe/wow-ui-source/commits/forever) (my clone)
- The local `_forever_` folder has no `BlizzardInterfaceCode` folder yet; only `Cache`, `Fonts`, `Interface`, `Logs`, `Utils`, `WTF` and the app bundle exist. — Local: `/Applications/World of Warcraft/_forever_/`

### Inferences
- Exporting writes into `/Applications/World of Warcraft/_forever_/`. This task was read-only, so I did not run it. Using the Gethe `forever` branch avoids touching the install and matches the live build (70840).
- CASC tools such as wow.export and CascLib should be able to read product `wowf`, since it is a normal TACT product on Blizzard's CDN (`tpr/wow` path in `.build.info`). This is not verified.

### Gaps
- I found no source that explicitly confirms `ExportInterfaceFiles` works in the `wowf` client, nor any wow.export or CascLib notes about `wowf` support.
- I did not check how to pass `-console` to the macOS Battle.net launcher for this product.

## 7. Forever-specific UI differences vs Retail 12.x

### Takeaway
Forever loads most of the Retail UI, including Edit Mode, the Settings panel, the Cooldown Manager (`Blizzard_CooldownViewer`), the built-in Damage Meter, and the talents and spellbook frame (`Blizzard_PlayerSpells`). It reskins and overrides many core frames through `Camelot/` folders. It does not load Housing, Delves, Mythic+, Encounter Journal, the Retail Group Finder or PvP UI, Garrisons, Trading Post or the in-game shop. It adds Forever-only systems: Legacy System, Statistics, Swing Timer, a "Vanilla-style" group finder, and a full gamepad UI.

### Cited Findings
- Blizzard addons loaded in both Retail and Forever, by TOC gating: `Blizzard_CooldownViewer` (`AllowLoadGameType: standard, camelot`), `Blizzard_DamageMeter` (`standard, camelot`, plus `Camelot\DamageMeterEntryOverrides.lua`), and `Blizzard_EditMode`, `Blizzard_Settings`, `Blizzard_PlayerSpells`, `Blizzard_UnitFrame`, `Blizzard_NamePlates` and `Blizzard_ActionBar` (ungated, so all mainline game types). — Gethe forever branch, TOC files (my grep)
- Blizzard addons not loaded in Forever, by TOC gating:

  | Gating | Addons |
  |---|---|
  | `standard` only | All 17 `Blizzard_Housing*`, `Blizzard_HouseEditor` and `Blizzard_HouseList` addons; `Blizzard_DelvesDifficultyPicker`; `Blizzard_DelvesToast`; `Blizzard_EncounterTimeline`; `Blizzard_EncounterWarnings`; `Blizzard_ExpansionLandingPage`; `Blizzard_ClassTrial`; `Blizzard_PhotoSharing`; `Blizzard_RemixArtifactUI`; `Blizzard_GenericShoppingCart`; `Blizzard_RPE_TurnStrafe` |
  | `standard, mists` | `Blizzard_ChallengesUI` (Mythic+) |
  | `standard, wowlabs` | `Blizzard_AccountStore` |
  | `standard, classic` | `Blizzard_EncounterJournal` |
  | `ExcludeLoadGameType: camelot` | `Blizzard_GroupFinder`, `Blizzard_PVPUI`, `Blizzard_GarrisonUI`, `Blizzard_PerksProgram` (Trading Post), `Blizzard_ExpansionTrial` |

  — Gethe forever branch, TOC files (my grep)
- Forever-only Blizzard addons (`AllowLoadGameType: camelot`): `Blizzard_LegacySystem` (load on demand; depends on `Blizzard_SharedTalentUI`, `Blizzard_AchievementUI`, `Blizzard_LegacyChallengeTracker`), `Blizzard_Statistics`, `Blizzard_SwingTimer` (depends on `Blizzard_EditMode`, so it is an Edit Mode system), `Blizzard_Gamepad`, `Blizzard_GamepadActionBars` and `Blizzard_GamepadTargeting`. Also `Blizzard_GroupFinder_VanillaStyle` (`AllowLoadGameType: classic, camelot`, "A premade group finder with 'Vanilla flavored' functionality"). — Gethe forever branch: [Blizzard_LegacySystem.toc](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_LegacySystem/Blizzard_LegacySystem.toc), [Blizzard_SwingTimer.toc](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_SwingTimer/Blizzard_SwingTimer.toc), [Blizzard_GroupFinder_VanillaStyle.toc](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_GroupFinder_VanillaStyle/Blizzard_GroupFinder_VanillaStyle.toc)
- Addons present only on the forever branch vs live: `Blizzard_DeprecatedTransmog`, the `Blizzard_Gamepad*` suite (7 addons), `Blizzard_GroupFinder_VanillaStyle`, `Blizzard_LegacyChallengeTracker`, `Blizzard_LegacySystem`, `Blizzard_Statistics`, `Blizzard_StatusTrackingBar` and `Blizzard_SwingTimer`. Present only on live: `Blizzard_DeclensionFrameGlue`, `Blizzard_LevelUpDisplay`, `Blizzard_ReforgingUI`, `Blizzard_TalentUI`. — Gethe `forever` vs `live` trees (my diff)
- Blizzard addons with a `Camelot/` override folder include `Blizzard_UnitFrame` (PlayerFrame, TargetFrame, PetFrame, PartyMemberFrame, ComboFrame and combo-point bars), `Blizzard_ActionBar` (`MainMenuBarEndCaps.xml`, ActionButton overrides), `Blizzard_EditMode` (`EditModeManagerOverrides`, preset layouts, system templates), `Blizzard_Minimap`, `Blizzard_MicroMenu`, `Blizzard_MainMenuBarBagButtons`, `Blizzard_NamePlates`, `Blizzard_PlayerSpells` (ClassTalents, ClassSpecializations, SpellBook), `Blizzard_SharedTalentUI`, `Blizzard_ObjectiveTracker`, `Blizzard_ChatFrame`, `Blizzard_ChatFrameBase`, `Blizzard_WorldMap`, `Blizzard_Collections`, `Blizzard_AchievementUI`, `Blizzard_Professions`, `Blizzard_AuctionHouseUI`, `Blizzard_PersonalResourceDisplay`, `Blizzard_StatusTrackingBar`, `Blizzard_Settings_Shared`, `Blizzard_SettingsDefinitions_Frame`, `Blizzard_UIPanels_Game` and `Blizzard_FrameXML`, about 60 in total. — Gethe forever branch (my `find -name Camelot`)
- Beta Changes 5 (build 70425, 16 October 2026): the Forever player, target, pet, target-of-target, totem and focus frames and the minimap header were reskinned, and some child frames were reorganized. "Addons that skin or anchor to these frames may need to adjust things." Beta Changes 4: Edit Mode layouts are saved separately per UI type (mouse and keyboard vs gamepad). — [warcraft.wiki.gg: API changes/notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)
- The wiki's API diff lists FrameXML additions `LegacySystemFrame_LoadUI`, `ToggleLegacySystemUI`, `LFGVanilla_ShowFrame` and `LFGVanilla_ToggleFrame`, and API additions `C_EditMode.GetEditModeDefaultLayout`, `C_TransmogSets.HasAnyValidSets` and `C_TransmogCollection.HasAnyAppearance`. — [warcraft.wiki.gg: Patch 1.60.1/API changes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes)
- Gameplay-level: Retail-only housing decor is not in Forever, and there is no flying. — [warcraft.wiki.gg: Forever](https://warcraft.wiki.gg/wiki/World_of_Warcraft:_Forever)
- Secondary: Edit Mode offers "Modern" and "Classic" presets; the Cooldown Manager was enabled for all classes from 8 October (beta); the Damage Meter is enabled under Options → Advanced and readable through `C_DamageMeter` (used by Details!). Swing Timer and Equipment Manager are built in. — [ForeverMeta](https://forevermeta.me/en/guides/wow-forever-addons-interface) (fan site citing Kaivax's EU dev notes)
- The local Edit Mode log shows an account layout named "Naowh" containing `SwingTimerMainHandFrame` and `SwingTimerOffHandFrame` systems, and anchors to `MainActionBar`, `BagsBar` and `CompactRaidFrameManager`. This confirms Retail-style Edit Mode with a Forever Swing Timer system in the live client. — Local: `/Applications/World of Warcraft/_forever_/Logs/EditMode.log`
- The local client has an empty `Housing.log` (the Mainline binary creates it even though Housing UI addons are gated to `standard`). — Local: `/Applications/World of Warcraft/_forever_/Logs/Housing.log`

### Inferences
- A Forever UI overhaul should:
  - Target the `Camelot/` versions of unit frames, action bars, minimap, micro menu, bags, nameplates, talents and spellbook, not the Retail 12.1.5 versions. Diff `Camelot/` against `Mainline/` in the Gethe branch to find changed child-frame names and anchors.
  - Integrate with Edit Mode, including the Forever-only Swing Timer system and separate gamepad layouts.
  - Optionally restyle the Cooldown Manager and Damage Meter, which exist in Forever.
  - Skip Housing, Delves, M+, Encounter Journal, Retail LFG and PvP UI, Garrison and Trading Post.
  - Handle the Forever-only Legacy System, Statistics, Vanilla group finder and gamepad UI.
- The "Classic" vs "Enhanced" ForeverExperiencePreset and the "Modern" vs "Classic" Edit Mode presets mean the default layout can vary per player, so test both.
- Because Midnight's secret values apply (now including `FrameStrata` as a secret aspect), a reskin addon must avoid reading or doing arithmetic on secret unit values in combat. Use the display-only paths (StatusBar values, `SetText` with secrets, AuraContainer/AuraButton from 12.1.0) as in Retail 12.x.

### Gaps
- TOC gating shows what loads, not what the server enables. For example, Blizzard_CooldownViewer loads, but whether it is on by default is controlled by settings or CVars I did not verify.
- I did not diff each `Camelot/` file against `Mainline/`, so the exact frame-name and anchor changes per frame are not catalogued here.
- No primary Blizzard source on the Damage Meter or Cooldown Manager in Forever; only the fan-site summary of Kaivax's EU forum notes, which I did not open directly.
- The client's `.slug` and `.slugo` font files are not explained by any source I found. They are probably a new font or glyph format in the 12.x and 1.60 clients, but this is unverified.
