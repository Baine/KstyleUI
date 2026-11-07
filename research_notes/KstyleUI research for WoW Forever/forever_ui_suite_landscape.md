# Complete-UI suites for WoW Forever (wowf, Interface 16001, game type `camelot`): the landscape as of 2026-11-06

Researcher notes for the KstyleUI report. Local sources are read-only copies under `/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/` (this client folder reports flavor `wow_classic_beta`). They are linked as `file://` URLs. The local EllesmereUI copy is v9.6.1 (2026-10-19). The live version is v9.7.8 (2026-11-06), so local details can be about three weeks behind.

Source caveats:
- **Reddit:** Reddit (r/WowUI, r/classicwow, r/wow) could not be read. WebFetch and WebSearch both refuse reddit.com, and the Claude in Chrome extension was not connected. Community sentiment therefore comes from GitHub issue trackers, guide sites and forum-adjacent reporting.
- **Third-party guide sites:** mmonster.co, timesaver.gg, conquestcapped.com and similar sites are SEO or boosting-service guide sites. mmonster.co says it sells WoW Forever boosting. Treat their numbers as secondary.

---

## 0. Technical baseline: what "Forever support" means for an addon (context for every suite below)

### Takeaway
WoW Forever is the 12.1 retail engine running vanilla content, and its client reports TOC 16001. A retail suite adds Forever support by adding `16001` to its `## Interface:` line and gating anything vanilla lacks. Gating works through `AllowLoadGameType` (`standard` = retail, `camelot` = Forever) and runtime checks. Porting a Classic Era codebase does not work.

### Cited Findings
- Forever uses interface 16001, Classic Era uses 11509 and Midnight uses 120105. Forever runs on the Mainline modern UI/API (`C_Item`, `C_Spell`, `C_Traits`), and Classic Era addons do not load. — [ForeverMeta guide, 2026-10-23](https://forevermeta.me/en/guides/wow-forever-addons-interface)
- Forever addons use `## Interface: 16001` or a `_Forever.toc`/`_Camelot.toc` suffix. `_Classic.toc` does not apply. "Load out of date AddOns" force-loads older addons. Midnight-style "secret values" hide many combat values from addons. — [ForeverMeta](https://forevermeta.me/en/guides/wow-forever-addons-interface)
- EllesmereUI's client gate explains it: "WoW Forever (Blizzard game type 'camelot'): the 12.1 engine with vanilla content, reporting a 1.60+ toc (16001)". It detects Forever with `iface >= 16000 and iface < 20000` and sets `EUI_CLIENT_FOREVER`. — [EllesmereUI_ClientGate.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_ClientGate.lua)
- EllesmereUI deliberately gates on the TOC number, "never on WOW_PROJECT_ID (the gate reads the toc number, the one signal every Forever build reports the same way)". It also notes that GCD reference spell 61304 reports nothing on Forever, so it uses Classic's 29515. — [EllesmereUI_Lite.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_Lite.lua)
- Three TOC patterns are visible locally:
  - Whole retail-only addons use `## AllowLoadGameType: standard`, so they are excluded on Forever. Examples are EllesmereUI Friends, Group Finder and Mythic+ Tools. — [EllesmereUIFriends.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIFriends/EllesmereUIFriends.toc)
  - Forever-only addons use a `_Camelot.toc` file with `## Interface: 16001` and `## AllowLoadGameType: camelot`. — [EllesmereUIForeverEssentials_Camelot.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIForeverEssentials/EllesmereUIForeverEssentials_Camelot.toc); [WaypointUI_Camelot.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/WaypointUI/WaypointUI_Camelot.toc)
  - Per-file directives inside one TOC, for example `Libs\LibKeystone\LibKeystone.lua [AllowLoadGameType standard]`. — [EllesmereUI.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI.toc)
- NaowhUI loads `Game\[Game]\!load.xml [AllowLoadGameType standard, camelot]` and has sibling folders `Game/Standard`, `Game/Camelot` and `Game/Shared`. This is a per-game-type code tree selected from the TOC. — [NaowhUI.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI/NaowhUI.toc)
- **Raid frames and secret values:** a 2026-09-18 test found click-casting raid frames (Grid2, HealBot, Clique) broken by secret health values. The guide says in-game testing is still needed. — [ForeverMeta](https://forevermeta.me/en/guides/wow-forever-addons-interface)
- **WeakAuras:** the WeakAuras team stopped Midnight support. The forks are "weeks old" and have limits, for example combat log triggers not firing. — [ForeverMeta](https://forevermeta.me/en/guides/wow-forever-addons-interface)
- **Blizzard policy:** at the 2026-09-17 developer Q&A, Blizzard said addons that customise the interface stay allowed. — [mmonster addons list (via search snippet)](https://mmonster.co/wow-forever/guides/addons)
- **Launch date:** Forever went live on 4 November 2026. — [nihil.gg](https://nihil.gg); [timesaver.gg launch list](https://timesaver.gg/blog/wow-forever-addons-save-beta-ui-before-launch)

### Inferences
- A KstyleUI built as a retail-engine addon with a Forever TOC gets the modern rendering toolkit: mask textures, AnimationGroups, atlas art and Edit Mode. A suite built on Classic Era APIs would not load at all. The same constraint applies to every competitor, so no suite has an engine advantage.
- Secret values limit what any suite can show in combat, for example numeric health on raid frames. Visual polish competes inside the same data limits, which favors suites that invest in presentation over data density.

### Gaps
- No official Blizzard developer documentation on `camelot` TOC rules was fetched. The rules above come from addon source and guide sites.

---

## 1. NihilUI (https://www.curseforge.com/wow/addons/nihilui)

### Takeaway
NihilUI is a brand-new standalone full UI replacement for Retail and WoW Forever, not a profile pack. It was created around 2026-11-05 by "diemans"/"Dieman" and had 69 downloads at v0.2.2. Its look is minimalist and centre-screen, and its full installer and profiles are paywalled behind Patreon. It is too new for meaningful popularity or sentiment data.

### Cited Findings
- **Project facts:** Author/owner "diemans", CurseForge project 1773397, All Rights Reserved. 69 downloads. Created "1 day ago" as of 2026-11-06. Latest file NihilUI 0.2.2, released 2026-11-06. — [CurseForge NihilUI](https://www.curseforge.com/wow/addons/nihilui)
- **Positioning:** it describes itself as "a fast, minimal interface for Retail and WoW Forever" and is marked "Built for WoW Forever". Flavors listed are Retail 12.1.7/12.1.5 and WoW Forever 1.60.1. — [CurseForge NihilUI](https://www.curseforge.com/wow/addons/nihilui)
- **Modules:**
  - Unit frames for player, target, focus, pet and boss, with heal prediction and cast bars.
  - Nameplates colour-coded by mob type, with threat alarms.
  - Raid and party frames laid out by role, with HoTs and dispels for healers.
  - Action bars: three centred bars, mouseover side bars and proc glows.
  - A "Cooldown HUD" built from Cooldown Manager spells and buffs.
  - Damage meter, chat, bags, minimap and tooltips.
  - A "dock" showing stats and XP.
  - "Pixel-perfect scaling, with Blizzard's windows kept readable".
  — [CurseForge NihilUI](https://www.curseforge.com/wow/addons/nihilui)
- **Standalone status:** it requires no other addons. Optional addons are BigWigs, LittleWigs and Naowh Forever. The page does not mention ElvUI, Plater or Details. Users are told to turn off other full UI replacements. — [CurseForge NihilUI](https://www.curseforge.com/wow/addons/nihilui)
- **Commands:** `/nihil`, `/nihil unlock`, `/nihil export`/`import` (one string), `/nihil profiles|save|use`, `/nihil reset` and `/rl`. — [CurseForge NihilUI](https://www.curseforge.com/wow/addons/nihilui)
- **Visual design:**
  - Action bars sit "in the middle of the screen, just under the character, with the player frame beside them". Health, power and cast bars wrap close around the bars.
  - Tracked buffs sit "in one thin row above", and effects such as enrage run as "slim strips below".
  - The site gives no specifics on colours, fonts, borders or animation.
  — [nihil.gg](https://nihil.gg)
- **Screenshots:** three CurseForge images (`media-hero-forever.jpg`, `media-forever.jpg`, `media-retail-2.jpg`) have no captions. The site's hero shot is captioned "in game on Retail · the same layout runs on WoW Forever". — [CurseForge](https://www.curseforge.com/wow/addons/nihilui); [nihil.gg](https://nihil.gg)
- **Performance claims:** health/threat update 0.0095 ms with 0 KB garbage over 20,000 events, and a per-event ceiling of 0.02 ms "enforced by tests". — [nihil.gg](https://nihil.gg)
- **Monetisation:**
  - The addon is free. Patreon supporters get the installer (`/nihil install`) with:
    - Forever and Retail profiles tuned for 1440p (1080p and 4K "coming").
    - Cooldown Manager layouts for all 40 retail specs.
    - Edit Mode and BigWigs/LittleWigs configurations, plus Naowh Forever setup.
  - The installer adds its Edit Mode layouts beside the user's own.
  - Supporter copies run up to 35 days, with a 7-day grace period. Membership is checked every 6 hours, and each copy is tied to one BattleTag.
  — [nihil.gg](https://nihil.gg); [CurseForge](https://www.curseforge.com/wow/addons/nihilui)
- **Possible Naowh link:** CurseForge lists "Naowh Forever" under "More from diemans". — [CurseForge NihilUI](https://www.curseforge.com/wow/addons/nihilui)
- **Update cadence:** the project was 1 day old and already on 0.2.2, with an update "2 hours ago". — [CurseForge NihilUI](https://www.curseforge.com/wow/addons/nihilui)

### Inferences
- NihilUI's pitch is minimal design, performance numbers and a centred combat HUD. It does not compete on polish or flair, so it is not a Narcissus-style competitor.
- The "More from diemans" listing suggests diemans is a member of the Naowh Forever CurseForge project. NihilUI may therefore come from the same circle as Naowh, which would explain the optional Naowh Forever integration. This is unconfirmed.
- Paywalling the installer and layouts (not the code) is a monetisation model a KstyleUI could study. It also invites friction: BattleTag binding and 6-hourly checks.

### Gaps
- No description of the actual screenshots, colour palette or typography. The images could not be viewed.
- No user comments existed or were visible, so there is no sentiment data.
- Not listed on Wago in the sources found. Not checked on GitHub.
- An early web search returned only "ElvUI_NihilistzscheUI", an unrelated ElvUI plugin last updated 2025, so NihilUI has almost no web footprint yet. — [CurseForge ElvUI_NihilistzscheUI](https://www.curseforge.com/wow/addons/elvui_nihilistzscheui)

---

## 2. EllesmereUI: modules, architecture, config, media, Forever handling

### Takeaway
EllesmereUI is the de facto modern suite on Forever. It is a 23-addon modular suite, about 9.5M CurseForge downloads, with near-daily releases. It has its own framework (no Ace3), its own options window, a powerful Unlock Mode, four selectable "looks" (one is a Forever-specific bronze look), and a Forever-only "Forever Essentials" addon. It is one codebase for retail 12.x and Forever 16001.

### Cited Findings
- **Popularity and cadence:**
  - CurseForge reports 9,509,211 downloads. The project was created about 8 months before 2026-11-06. The latest file is v9.7.8 (2026-11-06), tagged Retail and Forever. — [CurseForge EllesmereUI](https://www.curseforge.com/wow/addons/ellesmereui)
  - mmonster lists 6.1M (suites table) and 7M (EllesmereUI page). These are older or conflicting counts. Changelog points: 9.7.3 (Nov 2), 9.7.6 (Nov 5), 9.7.8 (Nov 6). — [mmonster UI](https://mmonster.co/wow-forever/guides/addons/ui); [mmonster EllesmereUI](https://mmonster.co/wow-forever/guides/addons/ellesmereui)
  - GitHub EllesmereGaming/EllesmereUI was created 2026-03-06. It has 267 stars, 351 forks and 450 open issues, last pushed 2026-11-06. — [GitHub API: EllesmereGaming/EllesmereUI](https://github.com/EllesmereGaming/EllesmereUI)
- **Module list (local TOCs, v9.6.1):**
  - Core framework: EllesmereUI.
  - Feature addons: Action Bars, AuraBuff Reminders, Bags (grid/list/compact, bank, categories), Blizzard Skins+, Chat, Cooldown Manager, Damage Meters, DataBars, Minimap, Nameplates, Quality of Life, Quest Tracker, Quickdraw (hold-key radial action menu), Raid & Party Frames, Resource Bars, Unit Frames.
  - Load-on-demand: Locales and Options.
  - Forever-only: Forever Essentials.
  - Retail-only, excluded on Forever: Friends, Group Finder, Mythic+ Tools.
  — [AddOns folder (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/)
- **CurseForge module list:** Action Bars, Unit Frames, Nameplates, Party/Raid Frames, Cooldown Manager, Resource Bars, AuraBuff Reminders, Blizz UI Element Reskins, Cursor Effects, QoL, Mythic+ Timer, Skyriding HUD, Minimap, Friends List, Chat, Quest Tracker, Damage Meter, Bags, Data Bars and Party Mode. It claims a "Modern Visual Design" and CPU minimisation "to a borderline obsessive degree", and calls Unlock Mode "the most advanced unlock system in WoW". — [CurseForge EllesmereUI](https://www.curseforge.com/wow/addons/ellesmereui)
- **Forever Essentials (local TOC):**
  - Spell uprank, classic spellbook and talents, junk items, simplified stats, gathering skill.
  - Map fade, active stance/form icon, map reveal, map travel markers, quest rewards.
  - Flight timer, zone levels on the world map, threat data/feed/meter, fishing, pet summon, loot feed and macro manager.
  — [EllesmereUIForeverEssentials_Camelot.toc and folder (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIForeverEssentials/)
  - A standalone build exists: "EllesmereUI: Standalone Forever Essentials" v9.7.6-forever. — [CurseForge file](https://www.curseforge.com/wow/addons/ellesmereui-forever-essentials/files/9450400)
- **Icy Veins coverage:** Icy Veins reported that Forever Essentials adds a threat meter, flight timer, heal prediction on unit frames and faction indicators. This comes from a search-result snippet only; the page returned HTTP 403. — [Icy Veins](https://www.icy-veins.com/wow-forever/news/wow-forever-players-can-now-build-their-perfect-ui-with-ellesmereui/)
- **Forever-specific code paths (local):**
  - Damage Meters ships `ForeverThreat`.
  - Chat ships `EllesmereUIChat_Forever.lua`, the "WoW Forever look... bronze panel frames, tabs and sidebar kit".
  - Blizzard Skins ships Forever-only skins for the character sheet with a stats sidebar, the friends list, the vanilla LFG window, the bag bar and the "Progress Legacy window (LegacySystemFrame)".
  — [EllesmereUIChat.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIChat/EllesmereUIChat.toc); [EllesmereUIBlizzardSkin.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIBlizzardSkin/EllesmereUIBlizzardSkin.toc)
  - About 50 `IS_FOREVER` branches exist in the core alone (spec overrides, unlock mode, style cards). — local grep of [EllesmereUI/](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/)
- **Changelog items for Forever (v9.6.x):** Swing Timer follows the Resource Bars style on Forever. AuraBuff Reminders gained Forever spell groups. Quest Tracker (Forever) gained a quest-filter header button. — [EllesmereUI CHANGELOG.md (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/CHANGELOG.md)
- **Architecture: no Ace3.** `EllesmereUI_Lite.lua` is a "Lightweight replacement for AceAddon-3.0, AceEvent-3.0, and AceDB-3.0... Reads existing AceDB SavedVariables format". Bundled libraries are LibStub, CallbackHandler, LibDataBroker, LibSharedMedia, LibDeflate (for profile strings), plus LibKeystone and LibSpecialization (retail only). — [EllesmereUI.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI.toc); [EllesmereUI_Lite.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_Lite.lua)
- **Architecture: custom options window.** `EllesmereUI_Panel.lua` is "the options panel shell: main frame, sidebar, header, tabs, content area, inline search, module registration". The page builders live in the load-on-demand `EllesmereUIOptions` addon. The panel scales 75–200% in 5% steps. The core also has GlobalSearch, VideoGuides and PatchNotesPopup files. — [EllesmereUI_Panel.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_Panel.lua); [EllesmereUIOptions.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIOptions/EllesmereUIOptions.toc)
- **Architecture: suite registration.** Each child TOC uses `## Group: EllesmereUI` and `## Category:` so the client's addon list groups the suite. All children depend on the core. — [e.g. EllesmereUIActionBars.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIActionBars/EllesmereUIActionBars.toc)
- **Extensibility:** the core ships `PLUGINS_API.md` and `SKINNING_API.md`. NaowhUI_EUI's changelog references "a plugin API that only exists from 9.3.5". The third-party "EUI Tweaks" puts its options inside the EllesmereUI panel as "Tweaks+" (per search snippet). — [EllesmereUI folder (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/); [NaowhUI_EUI CHANGELOG (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI_EUI/CHANGELOG.md); [CurseForge EUI Tweaks](https://www.curseforge.com/wow/addons/eui-tweaks)
- **Shared visual primitives (local):**
  - PixelPerfect.
  - RoundedCorners: "Shared rounded corners for bar frames (unit frames, power bars, raid and party cells, swing timer, nameplates)", radius 0–16, which applies only to the Solid, Glow and Shadow border styles.
  - Glows.
  - ClassicArt, which redraws the vanilla cast-bar border as a nine-slice "round any bar".
  - RetailAtlas, Colors and Fonts.
  — [EllesmereUI_RoundedCorners.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_RoundedCorners.lua); [EllesmereUI_ClassicArt.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_ClassicArt.lua)
- **Media:** the core `media/` holds 838 files (620 .tga, 176 .png, 21 .ttf/.TTF, 5 .otf, plus sounds). It covers borders, rounded, backgrounds, portraits, icons, micromenu, cursor rings and unlock-mode banners. 23 fonts are shipped, including Expressway, Gotham Narrow, Poppins, FiraSans, Barlow Condensed, Cinzel Decorative, Russo One, Exo and "Avant Garde Naowh". — [EllesmereUI/media (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/media/)
- **Four looks:** `EllesmereUI_StyleCards.lua` defines the look cards "EllesmereUI Style, Blizzard Style, Classic WoW UI". "The WoW Forever client adds a fourth pick card, WoW Forever". The EllesmereUI card keeps "the stock #0CD29D teal". — [EllesmereUI_StyleCards.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_StyleCards.lua)
- **Forever look details:** bronze tabs "warm while" active, "square bronze plates with tan glyphs", and every piece "framed by the bronze line of Forever's micro menu box". There is a "Heavy Bronze" variant with rim, dark line and inner shadow. — [EllesmereUIChat_Forever.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIChat/EllesmereUIChat_Forever.lua)
  - mmonster: the "WoW Forever style" copies Forever's default look, with gryphon or wyvern action-bar art, a day/night orb on the minimap and round level badges. — [mmonster EllesmereUI](https://mmonster.co/wow-forever/guides/addons/ellesmereui)
  - A "soft bronze options theme is the default on Forever" (per search snippet). — [vanilla.games (snippet)](https://vanilla.games/blog/ellesmereui-wow-forever/)
- **Screenshots:** mmonster's EllesmereUI screenshots are all "Captured in Retail":
  - Unlock Mode drag, with frames shown as boxes.
  - Raid frame settings with a live preview.
  - Frame-to-frame anchoring.
  - The settings window on the nameplate page.
  - A reskinned character sheet and friends list.
  - Minimap, quest tracker and chat "in the EllesmereUI style".
  CurseForge's 10 screenshots have filename-only captions. — [mmonster EllesmereUI](https://mmonster.co/wow-forever/guides/addons/ellesmereui); [CurseForge](https://www.curseforge.com/wow/addons/ellesmereui)
- **Animation use is light:** 13 `CreateAnimationGroup` calls in the core, 2 in Unit Frames, 3 in Action Bars and 4 each in Blizzard Skin and Chat. `CreateMaskTexture` is used 15 times in the core, mainly for rounding. — local grep of [AddOns](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/)

### Inferences
- EllesmereUI sets the bar on breadth, performance, configurability and Forever-specific utility. Its visual identity is flat, teal-accented and pixel-perfect, with optional rounding. Its Forever default deliberately imitates Blizzard's bronze Forever art rather than inventing a new look.
- Its options window is custom, with search, live previews and video guides. This is the UX baseline a new suite must match or beat; an Ace3 AceConfig dialog would look dated beside it.
- Motion is a minor part of its design language. That leaves room for a suite whose differentiator is animation and transitions.

### Gaps
- The changes between local v9.6.1 and live v9.7.8 were not diffed.
- Wago listing stats were not retrieved; the TOC has `X-Wago-ID: ZKbxbRN1`.
- No first-hand screenshots of the Forever look were viewed.

---

## 3. NaowhUI / NaowhUI_EUI / Naowh Forever: profile pack plus companion, built on EllesmereUI

### Takeaway
On Forever the Naowh stack is not a standalone UI. It has three parts:
- **NaowhUI**, an Ace3-based installer that imports Naowh's profiles into EllesmereUI, BigWigs, Blizzard Edit Mode and Naowh Forever, with per-class layouts.
- **NaowhUI_EUI**, an EllesmereUI plugin that adds a NaowhUI options category and overrides.
- **Naowh Forever**, a large Forever-only companion addon (BiS, dungeon journal, professions, training planner, threat meter, top bar and QoL) in its own shared window.

### Cited Findings
- **NaowhUI basics:**
  - v20261015.04 (2026-10-15). Interface `120105, 16001`. Depends on NaowhUI_Media. Bundles AceAddon, AceConfig, AceConsole, AceDB, AceDBOptions, AceGUI and AceLocale.
  - Per-game-type code trees `Game/Standard` and `Game/Camelot`.
  — [NaowhUI.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI/NaowhUI.toc); [NaowhUI/Libs (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI/Libs/)
  - The changelog links to github.com/naowh-gaming/NaowhUI, but that repo returned 404 (private or moved). — [NaowhUI CHANGELOG (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI/CHANGELOG.md)
- **Camelot installer data:**
  - `Data/AddOns/EllesmereUI.lua` (about 237 KB of profile data), `BigWigs.lua`, `Blizzard_EditMode.lua` and `NaowhForever.lua`.
  - `Data/Classes/` holds one file each for the nine vanilla classes.
  - Shared setup also covers `Blizzard_CooldownViewer`. On retail it covers EXBoss, NaowhSmartReminders and NorthernSkyRaidTools.
  — [NaowhUI/Game (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI/Game/)
- **Installer UI:** the strings show a paged wizard with Prev/Next, up to 4 option buttons per page, a "List of installations in queue", "Enable EllesmereUI to unlock this step", "Enable BigWigs…", "Enable Naowh Forever…", "Enable the Cooldown Manager…", "Click on the button below to setup your Class Layout" and "Installation Complete". A Forever-specific top logo `LogoTopCamelot.tga` is used. — [Installer.lua strings (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI/Game/Camelot/Modules/Installer/Installer.lua)
- **NaowhUI_Media:** 247 files. Textures include NaowhGradient, NaowhReverseGradient, NaowhMouseover and NaowhTarget. It also ships fonts and many callout sounds (Spike, DodgeInc, Orbs…). — [NaowhUI_Media (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI_Media/)
- **NaowhUI_EUI:**
  - v1.2.1, "Naowh's curated companion for EllesmereUI. Injects a NaowhUI category and overrides".
  - Modules: ActionBars, BlizzardSkin, CDM, Frames, Icons, MythicTimer, Nameplates, Portals, Skyriding and TopBar. QoL trackers include Co-Tank, Moonfire and others.
  - 1.1.8 merged the old separate "NaowhUI_EUI_Forever" addon. "Portals, skyriding, action bar, M+ timer and QoL features stay off on Forever."
  - 1.2.1: "WoW Forever: the Blizz UI page and skin are off there".
  - Top bar: "off on WoW Forever, where Naowh Forever has its own".
  — [NaowhUI_EUI.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI_EUI/NaowhUI_EUI.toc); [NaowhUI_EUI CHANGELOG (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI_EUI/CHANGELOG.md)
- **Naowh Forever:**
  - v1.1.34, Interface 16001 only, described as "Naowh's Forever companion: the window every module shares".
  - Sub-addons: BiS (with character and inspect panels, stat weights, "Naowh Score"), Combat (consumable bar, swing timer, threat meter, PvP, AuraBuffs, gear sets, blessings), Discovery (+ load-on-demand data), Dungeon Journal, Journeys data, Locales, Professions, QoL (including Top Bar), SearchIndex, Training planner, and Utilities (instance tracker, journeys, macros, group inspect, action bar sets).
  - "Every module starts off… anything you leave off costs nothing, not even a registered event."
  — [NaowhForever README (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/README.md); [NaowhForever_*.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/)
  - Libraries: LibCustomGlow, LibDBIcon, LibDeflate, LibSerialize and LibSharedMedia. It registers an AddonCompartment entry. — [NaowhForever.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/NaowhForever.toc)
- **Naowh Forever cadence and distribution:**
  - The 1.1.34 changelog adds boat/zeppelin timers, Patreon "supporter badges" (Epic/Legendary) and website action-bar layout import.
  - GitHub naowh-gaming/NaowhForever was created 2026-10-02 and has 14 stars, 21 forks and 23 open issues, last pushed 2026-11-06.
  - It is distributed via GitHub Releases, Discord discord.gg/naowh and naowh.gg.
  — [NaowhForever CHANGELOG (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/CHANGELOG.md); [GitHub naowh-gaming/NaowhForever](https://github.com/naowh-gaming/NaowhForever)
- **Gradient use:** Naowh Forever uses `SetGradient` 19 times and `CreateAnimationGroup` 12 times in its core, and 10 animation groups in QoL. That is more motion and gradient use than EllesmereUI's core. — local grep of [NaowhForever (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/)

### Inferences
- "NaowhUI on Forever" in practice means: EllesmereUI (rendering), plus Naowh profile strings and class layouts (installer), plus Naowh Forever (content and utility window), plus BigWigs. Naowh shows that a well-known creator can ship a "complete UI" as curation and integration on top of someone else's suite rather than as a new renderer.
- Naowh Forever's "one shared window for everything" pattern (BiS, journal, professions, training) is a Forever-specific differentiator: guide-like content for vanilla levelling and gearing that retail suites lack.
- Historically NaowhUI was an ElvUI profile pack on retail. Its move onto EllesmereUI shows where creator momentum has gone. This history comes from training knowledge and was not re-verified in this session.

### Gaps
- No download or popularity numbers for NaowhUI or Naowh Forever. CurseForge and Wago pages were not fetched, and the NaowhUI GitHub repo is 404.
- Whether NaowhUI on Forever offers role-based (DPS/healer/tank) layouts. The Camelot data is per class; no role keys were found in a quick grep.
- naowh.gg was not fetched.

---

## 4. Other suites with Forever support

### Takeaway
By launch week most major suites shipped Forever builds:
- ElvUI 16.00/16.01, SpartanUI 9.0.x, GW2 UI, LuckyoneUI and EllesmereUI.
- New Forever-native suites: ForeverUI (role-adaptive, about 28K downloads) and NihilUI (brand-new).
- Several "classic look" restorers: ClassicUI Forever, Classic UI (Forever) and Forevermore.
- Profile packs: OakUI on EllesmereUI.

No Forever status was found for Tukui (standalone), LUI or KkthnxUI.

### Cited Findings
- **ElvUI:**
  - 16.00 (2026-10-13): "This release also adds initial support for the upcoming WoW: Forever game version". 16.01 (2026-11-03): "Gamepad support on Forever", plus EnemyManaRegen (mp5) on Forever. — [ElvUI CHANGELOG.md (GitHub)](https://raw.githubusercontent.com/tukui-org/ElvUI/main/CHANGELOG.md)
  - Download from tukui.org or GitHub, not CurseForge. Retail profile strings "can load, but expect missing frames and plugins". — [wowforeveraddons.com, updated 2026-11-02](https://wowforeveraddons.com/articles/elvui-wow-forever)
  - GitHub tukui-org/ElvUI has 714 stars, last pushed 2026-11-06. — [GitHub](https://github.com/tukui-org/ElvUI)
  - **Conflict:** mmonster still lists ElvUI as "In development… newest release lists no Forever version" (15.26, Aug 29). That is stale against the official changelog. — [mmonster UI](https://mmonster.co/wow-forever/guides/addons/ui)
- **ForeverUI (Solindius / "ForeverUI Team"):**
  - Forever-only (1.60.1). 28,086 downloads, created about 1 month before 2026-11-06. v1.0.3 released 2026-11-06. 445 comments, 29 gallery images. All Rights Reserved. Single all-in-one addon (HealForever and TankForever were rolled in; QuestForever is standalone).
  - Features:
    - Role-specific raid/party layouts with click-casting.
    - Healer HoT timers and dispel highlights; tank threat and aggro borders.
    - A 12-type damage meter "designed to work in combat on Forever" with death logs.
    - 8 action bars; unit frames including boss frames; cast bars with interrupt highlights.
    - ForeverAuras (shareable as text) and QuestForever map/minimap guidance.
    - Loot advice, nameplates, bags and bank, and QoL toggles.
    - `/fui move`; profiles per character and per situation (solo/group/dungeon/raid); controller-friendly.
  - Style: "Flat and dark by default, with an optional bronze theme. Rounded or square corners are selectable."
  - Onboarding: a first-login questionnaire including starting role. Changing spec prompts a role switch.
  - Quirk: it stores essentials in character macros "FUI Save 1, 2…" because the beta client didn't reload some settings.
  — [CurseForge ForeverUI](https://www.curseforge.com/wow/addons/foreverui)
  - mmonster's figure of 16K is an older count. — [mmonster UI](https://mmonster.co/wow-forever/guides/addons/ui)
- **SpartanUI:**
  - 9.0.0 (2026-10-13): "a new chat system called Messenger and full support for WoW Forever, including new looks". It added "Painted nameplates for the Voyager, Grove and Observatory looks" and "All-new nameplates with ready-made styles and a live preview".
  - 9.0.1 and 9.0.2 (2026-11-04) fixed Forever minimap, tooltip and zone-bar placement, and added new painted looks Shard and Lamina.
  - Other named looks include Arcane, Fel, War, Classic, Midnight, Grid, flat, Modern Flat, Healer Grid, Classic Dark and Transparent.
  — [SpartanUI GitHub releases](https://github.com/spartanui-wow/SpartanUI/releases)
  - mmonster: 5.2M downloads, "Artwork combined with unit frames, bars and minimap options". — [mmonster UI](https://mmonster.co/wow-forever/guides/addons/ui)
- **GW2 UI:**
  - 2,723,731 downloads. 12.1.5 released 2026-11-05. Flavors include Retail, Forever, MoP Classic, Titan Reforged Classic and Classic.
  - "Hand-painted art and clean frames… inspired by Guild Wars 2, with smooth animations", contrasted with a "spreadsheet" look.
  - Modules: health globe, class powers, dynamic HUD, bars, cast bars, micro bar, all unit and group frames, quest dialogs and tracker, hero panel, bags and bank, loot rolls, minimap, world map, chat, tooltips, Blizzard skins, toasts, AFK screen and spec-based profiles.
  - "On Forever, GW2 UI switches to its own gamepad layout automatically."
  — [CurseForge GW2 UI](https://www.curseforge.com/wow/addons/gw2-ui)
- **LuckyoneUI:** 2.1M downloads, 4.27 released Nov 4. An "ElvUI-based interface that also runs standalone, with a bundled damage meter". — [mmonster UI](https://mmonster.co/wow-forever/guides/addons/ui)
  - The CurseForge title is "LuckyoneUI + Damage Meter & Quality of Life", and it is listed for all WoW versions including Forever (per search snippet). — [CurseForge LuckyoneUI](https://www.curseforge.com/wow/addons/luckyoneui)
- **OakUI (EllesmereUI edition):** a one-click profile installer with layouts for EllesmereUI. 84.3K downloads, 2.7.10 released Oct 30. — [mmonster UI](https://mmonster.co/wow-forever/guides/addons/ui)
- **MelloUI:** an "old-school RPG reskin, voiced quest givers, route arrow, updated map". 7.7K downloads, 2.1.8 released Nov 6. — [mmonster UI](https://mmonster.co/wow-forever/guides/addons/ui)
- **Classic-look restorers:**
  - ClassicUI Forever: gryphon action bar, classic unit frames, round minimap, old windows. 95.6K downloads, 0.46.0 released Nov 6.
  - Classic UI (Forever): 25.4K downloads.
  - Forevermore Classic UI: keeps Edit Mode working. 5.8K downloads.
  — [mmonster UI](https://mmonster.co/wow-forever/guides/addons/ui)
- **Single-purpose replacements with Forever builds** (download counts are cross-flavor lifetime totals):
  - Plater, 102.4M.
  - Platynator, 16.8M.
  - Threat Plates, 39.3M.
  - Bartender4, 81.9M.
  - Dominos, 22.8M.
  - Grid2, 15.4M.
  - HealBot, 86M.
  - BetterBlizzFrames and BetterBlizzPlates.
  - Quartz Redux.
  - Z-Perl Forever ports.
  - ControllerForever, which provides gamepad layouts.
  — [mmonster UI](https://mmonster.co/wow-forever/guides/addons/ui)
- **Missing from the guides:** Shadowed Unit Frames has no Forever build, and AdiBags has no Forever version (use BetterBags or Baganator). — [search summary of Forever guide sites](https://theforeverguides.com/addons/elvui/)

### Inferences
- The field splits four ways:
  - Big established suites ported to Forever: ElvUI, SpartanUI, GW2 UI, EllesmereUI.
  - Forever-native suites: ForeverUI, NihilUI.
  - Profile packs or installers on EllesmereUI or ElvUI: NaowhUI, OakUI, LuckyoneUI.
  - Classic-art restorers.
- EllesmereUI is the gravitational centre for creator profile packs. ElvUI arrived late (initial support 3 weeks before launch, gamepad on launch eve).
- Gamepad support is an emerging table-stakes item on Forever. ElvUI 16.01, GW2 UI's auto gamepad layout, ControllerForever and ForeverUI's controller note all treat it as such, and EllesmereUI has open gamepad-taint bugs (section 7).

### Gaps
- **Tukui (standalone), LUI, KkthnxUI:** no Forever status found in any source; the searches returned nothing.
- **ElvUI and Narcissus:** whether ElvUI Forever ships its full module set (skins, databars) is unverified. Narcissus's own Forever availability was not checked.
- **Popularity data:** Wago download stats were not retrieved for any suite. Download counts mix all flavors, so they cannot separate Forever-specific usage.

---

## 5. Module matrix

### Takeaway
Every serious suite covers the core combat HUD: unit, raid and party frames, nameplates, action bars, cast bars, plus chat, minimap and bags. On Forever, the differentiators are:
- Forever-specific utility: threat meter, swing timer, spell rank and flight helpers, quest and BiS content.
- A built-in damage meter.
- Blizzard window skinning depth.
- Gamepad support.
- Onboarding: style pickers and role or class installers.
- Art direction.

### Cited Findings
Legend: ● = stated by the source. ◐ = partial or indirect. ? = not stated (unknown, not "absent"). ✕ = explicitly absent or off. Sources per column:
- **EUI:** local TOCs and files plus [CurseForge](https://www.curseforge.com/wow/addons/ellesmereui).
- **Naowh stack:** EUI plus the [NaowhForever README (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/README.md) and [NaowhUI installer (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI/Game/).
- **NihilUI:** [CurseForge](https://www.curseforge.com/wow/addons/nihilui).
- **ForeverUI:** [CurseForge](https://www.curseforge.com/wow/addons/foreverui) and [mmonster](https://mmonster.co/wow-forever/guides/addons/ui).
- **ElvUI:** [mmonster](https://mmonster.co/wow-forever/guides/addons/ui) and the [ElvUI changelog](https://raw.githubusercontent.com/tukui-org/ElvUI/main/CHANGELOG.md). Its other modules are not verified for Forever.
- **SpartanUI:** [releases](https://github.com/spartanui-wow/SpartanUI/releases).
- **GW2 UI:** [CurseForge](https://www.curseforge.com/wow/addons/gw2-ui).

| Module | EllesmereUI (+Forever Essentials) | Naowh stack (NaowhUI installer + NaowhUI_EUI + Naowh Forever, on EUI) | NihilUI | ForeverUI | ElvUI 16.x | SpartanUI 9.x | GW2 UI |
|---|---|---|---|---|---|---|---|
| Unit frames | ● | ● (EUI) | ● | ● | ● | ● | ● |
| Raid/party frames | ● | ● (EUI) | ● role layout | ● role layouts + click-cast | ? | ● | ● |
| Nameplates | ● | ● (EUI + Naowh overrides) | ● threat alarms | ● | ● | ● painted styles | ? |
| Action bars | ● | ● (EUI; Naowh bar-set import) | ● 3 centred + mouseover | ● 8 bars | ● | ● | ● |
| Cooldown manager | ● CDM replacement | ● (EUI) | ● Cooldown HUD | ◐ ForeverAuras | ? | ? | ? |
| Auras / buff reminders | ● AuraBuff Reminders | ● (+ Naowh Buffs & Reminders) | ◐ thin buff row | ● Buff Watch | ? | ? | ? |
| Cast bars | ◐ (classic cast-bar art; unit frames) | ● (EUI) | ● | ● interrupt highlights | ? | ? | ● |
| Resource bars / swing timer | ● (swing timer on Forever) | ● (+ Naowh Swing Timer) | ◐ around bars | ? | ? | ? | ● class powers |
| Threat meter | ● ForeverThreat | ● Naowh Threat Meter | ◐ plate threat alarms | ● per-frame threat | ? | ? | ? |
| Minimap | ● (square options) | ● (EUI) | ● | ? | ? | ● art ring | ● |
| Chat | ● (bronze Forever kit) | ● (EUI) | ● | ● (mmonster) | ● | ● Messenger | ● |
| Bags | ● grid/list/compact | ● (EUI) | ● | ● | ● | ? | ● |
| Bank | ● | ● | ? | ● | ? | ? | ● |
| Tooltips | ● (skin, anchor, visibility) | ● | ● | ? | ? | ● | ● |
| Quest tracker | ● | ● (+ Naowh Quest List) | ? | ● QuestForever | ? | ? | ● |
| Data bars / info bar | ● DataBars blocks | ● (+ Naowh Top Bar) | ● dock | ? | ? | ● info bars | ? |
| Micro menu | ● (DataBars MicroMenu block) | ● | ? | ? | ? | ? | ● micro bar |
| Loot | ◐ loot feed | ● QoL loot | ? | ● loot advice | ? | ● loot rolls | ● loot rolls |
| Character pane | ● Forever character sheet + stats | ● Naowh BiS character panel | ? | ? | ? | ? | ● hero panel |
| World map | ◐ map reveal, fade, zone levels | ● dungeon maps in journal | ? | ◐ quest markers | ? | ? | ● |
| Damage meter | ● | ● (EUI) | ● | ● 12 types | ✕ (not stated; LuckyoneUI bundles one) | ? | ? |
| Boss-mods integration | ✕ | ● BigWigs profile via installer | ● BigWigs/LittleWigs (Patreon installer) | ◐ pull timer | ? | ? | ◐ boss timers |
| Blizzard window skinning | ● window packs (incl. Forever LFG, Legacy) | ◐ (Naowh's Blizz skin off on Forever) | ◐ "windows kept readable" | ? | ? | ? | ● |
| Install wizard / profiles | ● module picker + style picker; profile export | ● paged installer + class layouts | ● (Patreon) installer; `/nihil export` | ● questionnaire; per-situation profiles | ● (ElvUI installer, retail-known) | ● setup | ● spec profiles |
| Gamepad | ◐ (open taint bugs) | ? | ? | ● | ● 16.01 | ? | ● auto layout |
| Forever-specific extras | ● uprank, flight timer, classic spellbook/talents, junk, fishing, map reveal | ● BiS, journal, training planner, professions, blessings, macros | ? | ● QuestForever | ◐ mp5 | ? | ? |

### Inferences
- **Table stakes** for a "complete UI" on Forever: unit, raid and party frames; nameplates; action bars; cast bars; minimap; chat; bags and bank; tooltips; movers or unlock mode; profile import/export; an install wizard. Every credible suite covers these.
- **Rising table stakes, Forever-specific:**
  - A threat meter (vanilla tanking, no Blizzard threat UI parity).
  - A swing timer.
  - A damage meter that works under secret values.
  - Gamepad compatibility.
  - Spell-rank and uprank handling.
- **Differentiators:**
  - Art direction: SpartanUI and GW2 UI painted art, EllesmereUI's four looks, ForeverUI's bronze option.
  - Depth of Blizzard window reskins, for example the Forever character sheet, LFG and Legacy windows.
  - Content tooling: Naowh's BiS, journal and training planner; ForeverUI's quest guidance.
  - Onboarding quality.
  - Performance claims: NihilUI's ms figures, EllesmereUI's "obsessive" CPU focus.

### Gaps
- Many "?" cells are unknown rather than absent. ElvUI's and SpartanUI's full Forever module lists were not obtained from primary pages.

---

## 6. Onboarding: installers, profile strings, role layouts

### Takeaway
The patterns are:
1. EllesmereUI's two-step first-install: pick modules, reload, then pick a visual "look" from mock cards.
2. Creator installers that import a whole curated setup across several addons: NaowhUI, OakUI and NihilUI's Patreon installer.
3. ForeverUI's questionnaire with role-first layouts.
4. Profile strings: ElvUI, EllesmereUI and NihilUI `/nihil export`.

Role-based (healer/tank/DPS) layouts are explicit only in ForeverUI and NihilUI. Naowh is per class.

### Cited Findings
- **EllesmereUI first install:** a "One-time popup on first install that lets the user pick which EUI addons to keep enabled", laid out in three columns (Core / QoL / UI Reskin) with Check All / Uncheck All. — [EllesmereUI_FirstInstall.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_FirstInstall.lua)
  - On the next login, a style picker "offers the three looks side by side, each with a mock of what it means". On Forever it offers four, and WoW Forever is the default there. Choosing a card sets every module's style flags and reloads. — [EllesmereUI_StyleChoicePopup.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_StyleChoicePopup.lua)
  - A one-time popup announced window skinning to existing users and offered to disable it. — [EllesmereUI_WindowSkinsPopup.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_WindowSkinsPopup.lua)
  - An Uninstall step records game settings EUI changes "so Uninstall EUI can put them back". — [EllesmereUI.toc (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI.toc)
  - Profile exports can carry the whole Cooldown Manager setup for chosen specs. Imports choose modules and merge onto the current profile (per CurseForge notes via search snippet). — [CurseForge EllesmereUI files](https://www.curseforge.com/wow/addons/ellesmereui/files/8339632)
  - Community presets on the website can be imported. — [mmonster EllesmereUI](https://mmonster.co/wow-forever/guides/addons/ellesmereui)
  - A French guide advises importing via `/eui` and preferring Forever-made codes (per search snippet). — [playnews.gg](https://www.playnews.gg/guides/interface-wow-forever-comment-importer-un-profil-elvui-ou-un-code-d-ui)
- **NaowhUI:** a paged installer (Prev/Next, option buttons, an install queue, steps locked until the target addon is enabled) that writes EllesmereUI, BigWigs, Edit Mode and Naowh Forever profiles plus a "Class Layout". — [NaowhUI Installer.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI/Game/Camelot/Modules/Installer/Installer.lua)
- **OakUI:** a "One-click profile installer with layouts for EllesmereUI". — [mmonster UI](https://mmonster.co/wow-forever/guides/addons/ui)
- **NihilUI:**
  - The free addon "works once you enter the world".
  - Patreon `/nihil install` sets the profile, Edit Mode layout, CDM layouts per class, BigWigs/LittleWigs and Naowh Forever.
  - Its layouts are added beside the user's Edit Mode layouts, so the user can switch back.
  - "Each class and spec has tank, healer, and DPS setups". Profiles are 1440p only for now.
  — [nihil.gg](https://nihil.gg); [CurseForge](https://www.curseforge.com/wow/addons/nihilui)
- **ForeverUI:** a first-login "short setup questionnaire, including which role the frames start in". Each role has its own grid, click bindings, keybinds and layout. Spec change prompts a role switch. `/fui only heal|tank|dps`. `/fui backup` and `/fui restore`. — [CurseForge ForeverUI](https://www.curseforge.com/wow/addons/foreverui)
- **ElvUI:** export the current profile, create a new profile, import the string and `/reload`. Retail strings partly work. Only import strings from trusted people. — [wowforeveraddons.com](https://wowforeveraddons.com/articles/elvui-wow-forever)
- **GW2 UI:** "Move HUD mode, specialization-based profiles, in-game changelog". Every module can be disabled, and the Blizzard default takes its place. — [CurseForge GW2 UI](https://www.curseforge.com/wow/addons/gw2-ui)
- **Naowh Forever:** website-built action bar layouts import with `/nf ab <name>`, and spells not yet learned are placed when learned. — [NaowhForever README and CHANGELOG (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/CHANGELOG.md)

### Inferences
- The best current onboarding (EllesmereUI) is functional and visual: it uses mock cards. No source describes a cinematic or animated first-run experience. A Narcissus-grade onboarding with animated previews and transitions would be new.
- Resolution-specific profiles (NihilUI 1440p only) and role-first versus class-first layouts are open design choices. ForeverUI's role-first plus per-situation profiles is the most player-centric approach found.

### Gaps
- No user feedback was found on how smooth any installer is in practice.

---

## 7. Community sentiment: complaints and requests

### Takeaway
Direct Reddit and Discord sentiment could not be gathered. The best proxy is the open bug trackers. EllesmereUI's Forever issues are dominated by functional breakage: taint and secret-value errors with the gamepad UI, action-bar paging and possess bars, quest tracker and chat-tab bugs, and bag-option bugs. Accessibility requests also recur (font sizes, low vision). Visual-polish complaints are rare in the trackers; players mainly ask for things to work and to be adjustable.

### Cited Findings
- **EllesmereUI Forever bugs (GitHub, Sep–Nov 2026):**
  - "Forever BUG: Action Bar 1 does not swap to possessed/transformed creature bars" (5 comments).
  - "[Forever] … buttons activate on mouse-down" when dragging.
  - "Forever: ActionBars taints Blizzard_GamepadActionBars (secret value errors)… ADDON_ACTION_BLOCKED in combat".
  - "Forever: Nameplates taints the gamepad focus path".
  - "UnitFrames and RaidFrames menu does not open in gamepad ui on forever".
  - "Forever: Action Bar 1 keybinds cast the wrong spell in combat".
  - "Rogue Stealth Action Bar Paging Not Working".
  - "Druid… Power Bar Disappears after PowerShifting".
  - "Mark of the Wild reminder never clears when rank 2+ is applied".
  - "chat tab refresh dies on the protected alerting table (whisper flashes stop working)".
  — [GitHub issues: EllesmereUI "forever"](https://github.com/EllesmereGaming/EllesmereUI/issues?q=forever)
- **EllesmereUI launch-week bugs (Nov 4–6):**
  - "Chat Menu: BROKEN on EVERY tab except 1st".
  - "Quest Tracker: UNTRACK is broken" and "RESIZE and GROW DIRECTION are broken".
  - "Bags: Slot Size / Slot Spacing DOESN'T WORK in List mode" and "Icon Zoom does NOT work".
  - "Lua Errors from Chat".
  — [GitHub issues: EllesmereUI](https://github.com/EllesmereGaming/EllesmereUI/issues)
- **Accessibility and visual requests:**
  - "Accessibility: WoW Forever character sheet for people with low vision".
  - "Accessibility: Chat history/copy font size, and smoother chat scrolling".
  - "Power bar text size adjustment (accessibility)".
  - "Accessibility: Merchant list skin font and size".
  - "WoW Forever Professions UI: Recipe Icons have clutter".
  - "FOREVER - Bottom Info Bar Does Not Fill the Full Screen Width".
  - "Combo points cant be colored individually".
  - "[Feature] Minimap: Player Arrow Size/Style".
  - "Party pet styling".
  — [GitHub issues: EllesmereUI](https://github.com/EllesmereGaming/EllesmereUI/issues)
- **Forever-mechanic gaps:** "Pet Happiness", "No Soul Shard in data bar", "Keyring button", "Bag 5 = Reagent Bag", "New action bar hiding mode for gamepads" and "power bar on enemy nameplates (Forever)". — [GitHub issues: EllesmereUI](https://github.com/EllesmereGaming/EllesmereUI/issues?q=forever)
- **Naowh Forever requests:**
  - "Remove worldmap darkness for unexplored areas".
  - "Add enemies cooldowns above char portrait/nameplate".
  - "Racials for action-bars".
  - "(feature request) Audio Switcher & Interaction Blockers".
  - "Quest tracker: faction filter inverted".
  - "Baganator Compatibility for Bag Marks" (closed).
  — [GitHub issues: NaowhForever](https://github.com/naowh-gaming/NaowhForever/issues)
- **Wider community controversy:**
  - Paid addons are "the controversy of the moment on the official forums". A thread on the paid levelling addon Journey passed 600 replies, and Blizzard had not replied as of 2026-10-23. — [ForeverMeta](https://forevermeta.me/en/guides/wow-forever-addons-interface)
  - Relevant to NihilUI's Patreon-gated installer and Naowh's patron badges.
- **Raid frames:** click-cast raid frames were broken by secret values in a Sept 18 test. — [ForeverMeta](https://forevermeta.me/en/guides/wow-forever-addons-interface)
- **Older general sentiment** (pre-Forever and flagged as old): ElvUI is "a full interface replacement with a modern look that removes the default fantasy styling" (PC Gamer 2024, via search summary). Older forum threads recommend ElvUI, KkthnxUI and AzeriteUI. — [PC Gamer (2024)](https://www.pcgamer.com/wow-addons/); [MMO-Champion (older)](https://www.mmo-champion.com/threads/2581562-Top-5-UI-s-for-WoW)

### Inferences
- Reliability on Forever's quirks (gamepad UI taint, vanilla stances and stealth paging, rank-based buffs, pet happiness, keyring) is where existing suites visibly struggle. A new suite that is beautiful and robust on these edge cases would stand out on both axes.
- Accessibility requests (scalable fonts, low-vision character sheet) suggest a design system with type scale and contrast tokens. That fits an "elegant" suite.
- Monetisation is contentious on Forever. Gating core functionality is risky; cosmetic or supporter extras appear more tolerated, but this is unverified.

### Gaps
- **No Reddit:** no r/WowUI, r/classicwow or r/wow sentiment. The domain is blocked to the fetch tools and the Chrome extension was not connected. A follow-up with the Chrome extension connected should search r/WowUI for "Forever", "EllesmereUI" and "NaowhUI".
- **No CurseForge comments:** ForeverUI's 445 comments were not rendered by WebFetch. EllesmereUI's CurseForge page showed no comments.
- **No Discord or Wago:** no Discord announcements and no Wago comments were gathered.
- **Icy Veins:** the "Set Up Your WoW Forever UI Before Launch With These 9 Addons" article was not fetched (Icy Veins returns 403). — [Icy Veins](https://www.icy-veins.com/wow-forever/news/set-up-your-wow-forever-ui-before-launch-with-these-9-addons/)

---

## 8. Visual style survey and the visual-quality gap

### Takeaway
Forever UIs cluster into three aesthetics:
1. **Flat-modern minimal:** ElvUI, EllesmereUI's own style, NihilUI, ForeverUI's dark default.
2. **Blizzard/vanilla art mimicry:** EllesmereUI's default Forever bronze look, ForeverUI's bronze option, ClassicUI Forever, Forevermore.
3. **Painted fantasy themes:** SpartanUI's many looks, GW2 UI's hand-painted art "with smooth animations".

None is described as cinematic, animated or typographically led in the way Narcissus is. Animation is used sparingly across the suites inspected. A modern, flashy and elegant suite is an open position.

### Cited Findings
- **EllesmereUI style:**
  - Teal accent #0CD29D. Pixel-perfect layout. Optional rounded corners (radius 0–16) only with Solid, Glow or Shadow border styles.
  - Gradient and fade textures (`gradient-lr.tga`, `fade.tga`), pill-shaped elements (`pill-fill`, `pill-border`) and a "rainbow-border".
  — [StyleCards (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_StyleCards.lua); [RoundedCorners (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_RoundedCorners.lua); [media (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/media/)
- **EllesmereUI Forever look:** bronze panel frames, warm bronze tabs, "square bronze plates with tan glyphs", and a "Heavy Bronze" variant with rim and inner shadow. — [EllesmereUIChat_Forever.lua (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIChat/EllesmereUIChat_Forever.lua)
  - Gryphon or wyvern action-bar art, a day/night minimap orb and round level badges. — [mmonster EllesmereUI](https://mmonster.co/wow-forever/guides/addons/ellesmereui)
- **EllesmereUI's other looks:** Blizzard Style uses retail gryphon end caps. Classic WoW UI redraws the vanilla cast-bar sheet as a nine-slice. — [StyleCards (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_StyleCards.lua); [ClassicArt (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_ClassicArt.lua)
- **ForeverUI:** "Flat and dark by default, with an optional bronze theme. Rounded or square corners are selectable." — [CurseForge ForeverUI](https://www.curseforge.com/wow/addons/foreverui)
- **NihilUI:** minimal, with centred bars, "thin rows" and "slim strips". — [nihil.gg](https://nihil.gg)
- **SpartanUI:** painted looks (Voyager, Grove, Observatory, Shard, Lamina, Arcane, Fel, War, Classic…) and "Painted nameplates". — [SpartanUI releases](https://github.com/spartanui-wow/SpartanUI/releases)
- **GW2 UI:** "Hand-painted art and clean frames… inspired by Guild Wars 2, with smooth animations", contrasted with a "spreadsheet" look. — [CurseForge GW2 UI](https://www.curseforge.com/wow/addons/gw2-ui)
- **ElvUI:** "a modern look that removes the default fantasy styling" (2024 source, flagged as old). — [PC Gamer (2024)](https://www.pcgamer.com/wow-addons/)
- **Classic restorers:** ClassicUI Forever has a gryphon bar, classic frames, a round minimap and old windows. MelloUI is an "old-school RPG reskin" with voiced quest givers. — [mmonster UI](https://mmonster.co/wow-forever/guides/addons/ui)
- **Motion usage (local code counts):** EllesmereUI core has 13 `CreateAnimationGroup` calls, Unit Frames 2, Action Bars 3 and Chat 4. Naowh Forever core has 12, plus 19 `SetGradient` calls. NaowhUI (installer) has 2. — local grep of [AddOns (local)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/)

### Inferences
- **What reads dated:**
  - Flat dark boxes with 1px black borders and default fonts: the ElvUI and Tukui lineage, and ForeverUI's default.
  - Literal recreations of 2004 art: the classic restorers.
  - Heavy painted chrome that crowds the screen.
- **What reads modern:**
  - Generous spacing and pixel-perfect alignment; a single accent colour; rounded or pill shapes; soft shadows and glows rather than hard borders.
  - Curated typography: EllesmereUI ships 23 fonts, including geometric sans faces such as Poppins and Gotham.
  - Live previews in settings.
- **The gap:** no inspected or described suite combines all of the following:
  - Choreographed motion: enter and exit transitions, eased value changes, state-change flourishes.
  - Layered depth: glass or blur-like translucency, gradients, subtle parallax or 3D models.
  - Editorial typography.
  - A cohesive art direction carried across every Blizzard window.

  That combination is Narcissus's signature. EllesmereUI is the closest on cleanliness and coverage but is restrained and functional. GW2 UI is the closest on art and animation but is themed to Guild Wars 2 and is not elegant-minimal. A "Narcissus-grade" KstyleUI would differentiate on motion and art direction while matching EllesmereUI's coverage, performance and unlock or configuration UX.
- **Forever-specific risk:** any heavy animation must respect the secret-value and taint constraints that already break gamepad paths in EllesmereUI.

### Gaps
- **Screenshots and Narcissus:** no screenshots were viewed directly, so the style descriptions rely on code comments, alt text and store-page copy. Narcissus's own Forever availability and its specific techniques were not researched here; other researchers cover that.
- **ElvUI's Forever look:** not described by any 2026 source.
