# WoW Forever (wowf / Interface 16001 / game type `camelot`): addon API restrictions and UI-replacement rules by module

Research date: 2026-11-06. Live Forever client on this machine: `1.60.1.70840`, product `wowf` ([.build.info](file:///Applications/World%20of%20Warcraft/.build.info)). Blizzard's own Forever UI source is mirrored at [Gethe/wow-ui-source, branch `forever`](https://github.com/Gethe/wow-ui-source/tree/forever), whose latest commit is "1.60.1 (70840)" dated 2026-11-06, the same build as the local client. Where these notes cite "Forever UI source", they mean that branch.

Local addon copies that were grepped read-only:
- EllesmereUI 9.6.1 suite and NaowhUI / NaowhForever 1.1.34 under `/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/`. Their TOCs list `16001`, so the same code runs on Forever.
- Narcissus, Plumber, WaypointUI and DialogueUI under `/Applications/World of Warcraft/_forever_/Interface/AddOns/`.

Local file links below use `file://` URLs.

---

## 1. Do Midnight-style restrictions (secret values, combat-restricted APIs, curves, duration objects) apply to Forever?

### Takeaway
Yes. Forever is a second game type inside the Mainline (12.1.x) code family. The full Midnight restriction system applies: secret values, secret aspects, restriction states, no combat log, and C_Secrets / C_RestrictedActions. Blizzard said so, and Blizzard's own Forever API docs flag `UnitHealth` as an unconditional secret return. There are a few Forever-specific differences: threat is readable, combo points are bound to the target and can be secret, a native swing timer API replaces combat-log swing timers, there is no Encounter Timeline, and WOW_PROJECT_ID detection is inconsistent.

### Cited Findings
- **Blizzard statement (WoW UI Discord, reported 17 Sep 2026).** Translated quotes: "WoW Forever shares the interface architecture of WoW's main branch ... including the vast majority of APIs available in version 12.1.5." "The addon restriction changes introduced in Midnight, including secret values, will also be active in Forever." "The AuraContainer/AuraButton changes introduced in 12.1.0 will also be available." Blizzard added that similar interface adjustments may come to both Standard and Forever later. — [GameWave, 17 Sep 2026](https://gamewave.fr/world-of-warcraft-forever/wow-forever-les-restrictions-d-addons-de-midnight-seront-aussi-appliquees/)
- **Wiki.** warcraft.wiki.gg (revision of 17 Oct 2026) calls Forever and Midnight "two game types within the Mainline code family". It confirms that the Midnight restrictions, including secrets, apply to Forever. — [warcraft.wiki.gg Patch 1.60.1/API changes/notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)
- **No forum blue post.** No Blizzard blue post on the forums gives a Forever-specific restriction list. Players asked on 16 Sep and 3 Oct and got no reply. The only official Forever statement is the Discord one. — [wowforevertierlist.com (updated 31 Oct 2026; fan site)](https://wowforevertierlist.com/addons/restrictions)
- **What a secret is.** In tainted (addon) code, a secret can be stored, passed to functions, checked with `type()` and concatenated. Arithmetic, comparisons, boolean tests on secret booleans, `#`, using a secret as a table key, and indexing a secret all raise an immediate Lua error. Untainted (Blizzard) code sees normal values. — [warcraft.wiki.gg Secret Values (edited 23 Sep 2026)](https://warcraft.wiki.gg/wiki/Secret_Values)
- **Secret aspects and anchors.** Passing a secret to a widget setter applies a "secret aspect" to that widget, and the matching getter then returns secrets. Examples: Text (`FontString:SetText`), BarValue (`StatusBar:SetValue` / `SetMinMaxValues`), Cooldown (`Cooldown:SetCooldown`), Alpha / VertexColor, Shown and Scale. Aspects can only be cleared with `FrameScriptObject:SetToDefaults()`. Secret anchoring spreads to frames anchored to a secret-anchored frame, and their position or size getters then return secrets. A "forbidden aspect" (`UntrustedScriptExecution`) blocks addon script handlers on an object. — [warcraft.wiki.gg Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values)
- **Restriction-state predicates.** The wiki lists SecretWhenInCombat, SecretInActivePvPMatch, SecretInChatMessagingLockdown, SecretOnRestrictedMaps (dungeons and raids), SecretWhenUnitIdentityRestricted, SecretWhenUnitComparisonRestricted, SecretWhenUnitHealthMaxRestricted (units that are not player-controlled), SecretWhenUnitPowerRestricted, SecretWhenUnitSpellCastRestricted (units other than player or pet), SecretWhenCooldownsRestricted, and others. — [warcraft.wiki.gg Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values)
- **Restriction types in the Forever build.** The Forever UI source documents `C_RestrictedActions.IsAddOnRestrictionActive`, `GetAddOnRestrictionState`, `CheckAllowProtectedFunctions` and `InCombatLockdown`. It also documents the events `ADDON_RESTRICTION_STATE_CHANGED`, `ADDON_ACTION_BLOCKED`, `ADDON_ACTION_FORBIDDEN` and `MACRO_ACTION_BLOCKED`. `Enum.AddOnRestrictionType` has six values: Combat, Encounter, ChallengeMode, PvPMatch, Map and Chat. — [Forever UI source: RestrictedActionsDocumentation.lua / RestrictedActionsConstantsDocumentation.lua](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated)
- **C_Secrets predicates in the Forever build.** CanCompareUnitTokens, GetPowerTypeSecrecy, GetSpellAuraSecrecy, GetSpellCastSecrecy, GetSpellCooldownSecrecy, HasSecretRestrictions, ShouldActionCooldownBeSecret, ShouldAurasBeSecret, ShouldCooldownsBeSecret, ShouldSpellAuraBeSecret, ShouldSpellBookItemCooldownBeSecret, ShouldSpellCooldownBeSecret, ShouldTotemSlotBeSecret, ShouldTotemSpellBeSecret, ShouldUnitAuraIndex/Instance/SlotBeSecret, ShouldUnitComparisonBeSecret, ShouldUnitHealthMaxBeSecret, ShouldUnitIdentityBeSecret, ShouldUnitPowerBeSecret, ShouldUnitPowerMaxBeSecret, ShouldUnitSpellCastBeSecret, ShouldUnitSpellCastingBeSecret, ShouldUnitStatsBeSecret, ShouldUnitThreatStateBeSecret and ShouldUnitThreatValuesBeSecret. — [Forever UI source: SecretPredicateAPIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SecretPredicateAPIDocumentation.lua)
- **Unit API secrecy flags in the Forever build.** `UnitHealth`, `UnitHealthMissing` and `UnitInRange` have `SecretReturns = true`, which means always secret to tainted code, in combat or not. `UnitHealthPercent` is also SecretReturns. `UnitHealthMax` is secret only when SecretWhenUnitHealthMaxRestricted applies. `UnitPower` and `GetComboPoints` are secret when SecretWhenUnitPowerRestricted applies. `UnitPowerMax` follows SecretWhenUnitPowerMaxRestricted. `UnitName` follows SecretWhenUnitNameIdentityRestricted, and `UnitClass` / `UnitGUID` follow SecretWhenUnitIdentityRestricted. `UnitCastingInfo` / `UnitChannelInfo` follow SecretWhenUnitSpellCastRestricted. `UnitIsUnit` follows SecretWhenUnitComparisonRestricted, `UnitDetailedThreatSituation` follows SecretWhenUnitThreatValuesRestricted, and `UnitThreatSituation` follows SecretWhenUnitThreatStateRestricted. — [Forever UI source: UnitDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua)
- **Combat log.** Registering COMBAT_LOG_EVENT or COMBAT_LOG_EVENT_UNFILTERED raises an error in 12.x. The wiki states Blizzard's goal as limiting "the ability for addons to perform complex logic and decision making based off combat information", and adds that the changes are "not intended to prevent 'look and feel' customization of UI elements." — [warcraft.wiki.gg Patch 12.0.0/API changes](https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes)
- **Forever beta (build 1.60.1.69913, Sep 2026).**
  - `UnitHealth` arithmetic failed: Grid2 threw "attempt to perform arithmetic on a secret number value (execution tainted by 'Grid2')".
  - Secure snippets failed with "RestrictedExecution.lua:79: attempt to call a nil value" because `loadstring_untainted` was missing. This broke action bar paging, secure group headers and click-casting.
  - `WOW_PROJECT_ID` returned 1 (Mainline).
  - GetItemInfo, GetSpellInfo, GetSpellBookItemName, GetNumTalentTabs, GetTalentInfo and GetNumSkillLines were removed in favour of C_Item, C_Spell and C_Traits.
  — [wowforeverbuilds.com, 18 Sep 2026 (fan site, beta-era)](https://wowforeverbuilds.com/news/what-the-wow-forever-beta-breaks-for-addons-secret-health-values-dead-secure-sni)
- **Secure snippets in the live build.** The live Forever source still calls `loadstring_untainted` at RestrictedExecution.lua line 79. — [Forever UI source: RestrictedExecution.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_RestrictedAddOnEnvironment/RestrictedExecution.lua)
- **Combo points (Forever-specific).**
  - Forever combo points "stack on one specific target at a time" and "the addon API considers them a secret value". The thread has no blue reply. The poster's edit says Blizzard will add combo points to the Personal Resource Display, but this is unverified. — [Blizzard forums, "Combo Points Are Secret Values", 17 Sep 2026](https://us.forums.blizzard.com/en/wow/t/combo-points-are-secret-values/2352853)
  - A fan site contradicts this and says combo points are not secret. — [wowforevertierlist.com](https://wowforevertierlist.com/addons/restrictions)
  - Local code agrees with the forum. EllesmereUI says "The count can read secret, so visibility never compares it in Lua". — [EUI_UnitFrames_ForeverExtras.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIUnitFrames/EUI_UnitFrames_ForeverExtras.lua)
- **Threat is readable on Forever (Forever-specific).** EllesmereUI: "Forever hands the threat API over readable (C_Secrets.ShouldUnitThreatValuesBeSecret is false there); a value that does come back secret skips that unit." — [EllesmereUIForeverEssentials_ThreatData.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIForeverEssentials/EllesmereUIForeverEssentials_ThreatData.lua)
- **Auras are hidden on Forever too.** An EllesmereUI Forever changelog entry reads: "Custom spell reminders no longer show for a buff you already have while the game is hiding aura details from addons." — [EUI__General_Options.lua (changelog entries flagged `forever = true`)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIOptions/EUI__General_Options.lua)
- **12.1 aura hard errors.** EllesmereUI notes that "12.1 build 68824 made aura access a hard-error API (RequiresUnitAuraAccess)", which throws "Auras cannot be accessed when secret while tainted". — [EllesmereUIUnitFrames.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIUnitFrames/EllesmereUIUnitFrames.lua). A second comment says the index scan "hard-errors under restrictions (M+/raid) even OOC; whitelisted lookups still work". — [EUI_AuraBuffReminders_Auras.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIAuraBuffReminders/EUI_AuraBuffReminders_Auras.lua)
- **Other 1.60.1 changes (Forever).**
  - A new `FrameStrata` secret aspect: GetFrameStrata can return a secret.
  - Creature, vehicle, pet and gameobject GUID server and spawn IDs are obfuscated.
  - Trial accounts cannot send addon messages.
  - EMOTE through SendChatMessage needs a hardware event outside instances.
  - Another way to read minimap rotation during encounters was closed.
  - `C_PvP.IsWarModeFeatureEnabled` returns false.
  — [warcraft.wiki.gg Patch 1.60.1/API changes/notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)
- **Forever client identity is reported inconsistently.**
  - EllesmereUI gates on the TOC number "never on WOW_PROJECT_ID (the gate reads the toc number, the one signal every Forever build reports the same way)". It sets `IS_FOREVER` when `16000 <= iface < 20000` and describes Forever as "the 12.1 engine with vanilla content". — [EllesmereUI_ClientGate.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_ClientGate.lua), [EllesmereUI_Lite.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_Lite.lua)
  - LibSpecialization uses `isForever = WOW_PROJECT_ID == 18`. — [LibSpecialization.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/Libs/LibSpecialization/LibSpecialization.lua)
  - NaowhUI uses `WOW_PROJECT_ID == WOW_PROJECT_CAMELOT`. — [NaowhUI Core.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI/Game/Shared/General/Core.lua)
  - Narcissus, Plumber and DialogueUI fall back to TOC metadata `X-GameType == "Camelot"`, with the comment "WOW_PROJECT_* may be nil" and the TODO "Camelot / WOW_PROJECT_CAMELOT will be renamed to Forever". — [Narcissus Initialization.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Initialization.lua)
  - ElvUI's oUF uses `oUF.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and not oUF.isForever`. — [ElvUI repo, ElvUI_Libraries/Game/Shared/oUF/init.lua](https://github.com/tukui-org/ElvUI)
- **TOC naming.** `Forever` is now an alias for `Camelot` in TOC suffixes (for example `MyAddon_Forever.toc`), in the `[Game]` variable and in folder lookup. — [warcraft.wiki.gg Patch 1.60.1/API changes/notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes). A shipping example is WaypointUI, which uses `WaypointUI_Camelot.toc` (Interface 16001) beside a Retail TOC. — [WaypointUI folder](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/)
- **Testing CVars.** These force restrictions for testing and are not saved: `addonCombatRestrictionsForced`, `addonMapRestrictionsForced`, `addonChatRestrictionsForced`, `addonEncounterRestrictionsForced`, `addonChallengeModeRestrictionsForced` and `addonPvPMatchRestrictionsForced`. — [warcraft.wiki.gg Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values)

### Inferences
- KstyleUI should treat Forever as "Retail 12.1.x restrictions plus vanilla content". Every unit or combat value must flow through display-only paths (widget setters, curves, duration objects), never through Lua logic.
- `UnitHealth` is always secret on Forever, even out of combat, so Lua can never compute health text such as "12.3k / 45%". Use `UnitHealthPercent(unit, usePredicted, curve)` with `AbbreviateNumbers`, or engine formatters (`C_StringUtil`).
- Detect Forever by the TOC number (`select(4, GetBuildInfo())` between 16000 and 19999) or by `X-GameType`, with `WOW_PROJECT_CAMELOT` only as a secondary check. Ship `KstyleUI_Forever.toc` with `## Interface: 16001`.
- The beta secure-snippet failure is very likely fixed on live. RestrictedExecution.lua still calls `loadstring_untainted`, and EllesmereUI 9.6.1 uses RegisterStateDriver (40 call sites), SecureGroupHeaderTemplate and WrapScript on Forever. Verify in game early anyway.

### Gaps
- Blizzard has published no Forever-specific restriction list or blue post. Behaviour comes from the Discord statement, the API docs and addon code.
- The "never secret" power types on Forever (which `GetPowerTypeSecrecy` reports) were not enumerated. Mana, rage and energy readability out of restricted contexts was not verified in game.
- No Blizzard confirmation was found on whether combo points will become non-secret or appear on the PRD.

---

## 2. Module-by-module: what a UI overhaul can do on Forever

### Takeaway
Every visible module can be restyled or replaced. Combat-data modules must use display-only APIs: StatusBar setters, curves, duration objects, AuraContainer and the Blizzard data viewers. Non-combat modules (bags, character pane, map, quest tracker, chat chrome, micro menu, data bars, settings) are mostly unaffected except by taint rules. Forever lacks some Retail systems: Encounter Timeline, Encounter Warnings, Extra Action Button, hero talents, multiple specs, premade group list and housing. It adds Forever-only ones: Swing Timer, Gamepad bars, Legacy/Statistics systems and a vanilla-style Group Finder.

### Cited Findings

**Which Blizzard systems load on Forever (AllowLoadGameType in the Forever UI source)**
- **Camelot-only:** Blizzard_SwingTimer, Blizzard_Gamepad, Blizzard_GamepadActionBars, Blizzard_GamepadTargeting, Blizzard_LegacySystem, Blizzard_LegacyChallengeTracker and Blizzard_Statistics.
- **`standard, camelot` (Retail and Forever):** Blizzard_CooldownViewer, Blizzard_DamageMeter, Blizzard_PVPMatch, Blizzard_StableUI and others. Blizzard_GroupFinder_VanillaStyle is `classic, camelot`.
- **`standard` only, so not on Forever:** Blizzard_EncounterTimeline, Blizzard_EncounterWarnings, the Delves UI, all Housing UIs, Remix UIs and Blizzard_ExpansionLandingPage.
- **No game-type restriction:** Blizzard_AuraContainer, Blizzard_ActionBar, Blizzard_BuffFrame, Blizzard_CompactRaidFrames, Blizzard_NamePlates, Blizzard_EditMode, Blizzard_ObjectiveTracker, Blizzard_Minimap, Blizzard_MicroMenu, Blizzard_MainMenuBarBagButtons, Blizzard_Settings, Blizzard_ChatFrame, Blizzard_GameTooltip, Blizzard_UnitFrame and Blizzard_WorldMap.
- **`mainline`:** Blizzard_PersonalResourceDisplay, Blizzard_ZoneAbility and Blizzard_Professions.
- Source: [Forever UI source TOCs, for example Blizzard_EncounterTimeline.toc `## AllowLoadGameType: standard`, Blizzard_DamageMeter.toc `standard, camelot`, Blizzard_SwingTimer.toc `camelot`](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns). The classification comes from fetching all 349 TOCs on the branch.

**Unit frames (player, target, focus, pet, ToT, party, boss)**
- **Construction.** EllesmereUI builds its own frames with `CreateFrame("Button", ..., "SecureUnitButtonTemplate, PingableUnitFrameTemplate")` and uses `RegisterUnitWatch` for show and hide. — [EUI_UnitFrames_Engine.lua (lines ~879-910)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIUnitFrames/EUI_UnitFrames_Engine.lua)
- **Health bar.** Secrets go straight into the widget: `element:SetMinMaxValues(0, UnitHealthMax(unit))` and then `SetValue(...)`. Dead or disconnected states come from plain booleans (`UnitIsDead`, `UnitIsConnected`). — [EUI_UnitFrames_Text.lua (lines ~87-101)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIUnitFrames/EUI_UnitFrames_Text.lua). The wiki confirms that StatusBar `SetValue` / `SetMinMaxValues` accept secrets and apply the BarValue aspect. — [warcraft.wiki.gg Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values)
- **Health text.** `UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)` with `string.format`, or `AbbreviateNumbers(UnitHealthPercent(unit, true, trimCurve), cfg)`. — [EUI_UnitFrames_Text.lua (lines ~415-424)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIUnitFrames/EUI_UnitFrames_Text.lua)
- **Absorbs and heal prediction.** EllesmereUI calls `CreateUnitHealPredictionCalculator` 10 times. RaidFrames are described as having "Secret-value-safe absorb shields". — local grep counts; [EllesmereUIRaidFrames.lua header](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIRaidFrames/EllesmereUIRaidFrames.lua)
- **Combo points.** Combo points can be secret, so EllesmereUI draws them with a "one-point StatusBar gate". It calls `SetMinMaxValues(i-1, i)` and `SetValue(count)` so the comparison happens on the C side, and uses a mask to show or hide each pip. Forever has no other class resource display. — [EUI_UnitFrames_ForeverExtras.lua (lines ~122-160)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIUnitFrames/EUI_UnitFrames_ForeverExtras.lua)
- **Forever unit frame art.** 1.60.1 reskinned the player, target, pet, target-of-target, totem and focus frames and the minimap header, and reorganized some child frames. — [warcraft.wiki.gg Patch 1.60.1 notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes). EllesmereUI has a separate "WoW Forever look" (bronze rim) that tracks this art. — [EUI__General_Options.lua changelog](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIOptions/EUI__General_Options.lua)

**Raid and party frames**
- **Construction.** EllesmereUI uses "Custom raid frames built on SecureGroupHeaderTemplate. 8 per-group headers (separated mode) + 1 combined header (flat mode)". Pet frames use `SecureGroupPetHeaderTemplate` and `SecureUnitButtonTemplate`. — [EllesmereUIRaidFrames.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIRaidFrames/EllesmereUIRaidFrames.lua), [EUI_RaidFrames_PetFrames.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIRaidFrames/EUI_RaidFrames_PetFrames.lua)
- **Limits.** Third-party raid frames cannot do arithmetic on health. That rules out deficit math, low-health thresholds in Lua and custom sorting by health. — [wowforeverbuilds.com (beta)](https://wowforeverbuilds.com/news/what-the-wow-forever-beta-breaks-for-addons-secret-health-values-dead-secure-sni). `UnitInRange` is SecretReturns, so range fading has to use `SetAlphaFromBoolean`-style APIs. — [Forever UnitDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua). EllesmereUI has 79 `SetAlphaFromBoolean` call sites (local grep).
- **Blizzard's stated position (Retail article, 23 Oct 2025, older).** Addons can still change "the look of almost everything you see in the User Interface", including raid frames, nameplates and action bars. They "will no longer be able to use that combat information to drive custom logic or make decisions for you." — [Blizzard news](https://worldofwarcraft.blizzard.com/en-us/news/24244638)

**Nameplates**
- **APIs used.** EllesmereUI styles nameplates through `C_NamePlate.GetNamePlateForUnit`, `C_NamePlate.GetNamePlates`, `C_NamePlate.SetNamePlateSize` and `C_NamePlateManager.SetNamePlateHitTestInsets`. Nameplate auras use AuraContainers (`EUI_Nameplates_AuraContainers.lua`). — local grep; [EllesmereUINameplates folder](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUINameplates/)
- **Forever-only CVars.** Non-target plates far above or below the player are hidden through `nameplateMaxVerticalDistance` and `nameplateMaxVerticalDistanceAtMaxRange` (0 disables the check). — [warcraft.wiki.gg Patch 1.60.1 notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)
- **Names.** Names of non-player units are secret in combat. EllesmereUI's `ForeverShortName` "passes a secret name through whole". — [EUI_UnitFrames_Text.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIUnitFrames/EUI_UnitFrames_Text.lua), [EUI_Nameplates_Layout.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUINameplates/EUI_Nameplates_Layout.lua)
- **Threat colouring.** Threat colours work on Forever because threat is readable there; EllesmereUI changelogs tank threat colours for Forever. — [EUI__General_Options.lua changelog](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIOptions/EUI__General_Options.lua). A fan site cites "threat-priority nameplate colouring" as a Midnight-restricted target. — [wowforevertierlist.com](https://wowforevertierlist.com/addons/restrictions)

**Cast bars**
- **Secrecy.** `UnitCastingInfo` and `UnitChannelInfo` are secret when SecretWhenUnitSpellCastRestricted applies (units other than player or pet). — [Forever UnitDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua), [warcraft.wiki.gg Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values)
- **12.0 signature changes.** `notInterruptible` became nilable and a `castBarID` return was added. StatusBar `SetValue` / `SetMinMaxValues` gained an interpolation argument. — [warcraft.wiki.gg Patch 12.0.0/API changes](https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes)
- **Hiding Blizzard's player cast bar.** EllesmereUI reparents `PlayerCastingBarFrame` to a hidden parent. It re-parks from a deferred OnUpdate, waits for `PLAYER_REGEN_ENABLED` in combat, and never reparents while `EditModeManagerFrame` is shown. It suppresses the Edit Mode `Selection` by alpha, writing nothing inside Edit Mode's secure `ShowSystemSelections` pass. — [EllesmereUI_SharedHelpers.lua (lines ~585-640)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_SharedHelpers.lua)

**Action bars (secure templates, skinning, keybind text, cooldown swipes)**
- **Construction.** EllesmereUI uses "Own secure action bar frames AND buttons (EABButton/ActionBarButtonTemplate), eliminating the taint surface from reusing Blizzard's protected buttons. Stance/Pet bars still reuse Blizzard buttons ... Keybinds: SetOverrideBindingClick for all bars. Paging: RegisterStateDriver + _childupdate-eab-page with explicit action attrs." — [EllesmereUIActionBars.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIActionBars/EllesmereUIActionBars.lua)
- **Disposing of stock bars.** The stock bars are reparented to a hidden dump frame because that "is safer than :Hide(), which can trigger taint chains in protected code paths". — [EUI_ActionBars_Disposal.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIActionBars/EUI_ActionBars_Disposal.lua)
- **Forever taint incident.** EllesmereUI: "Never on WoW Forever. Its UpdateAction reads the cast-animation fields (actionButtonCastType) ... our dispatch ... writes those fields onto every Blizzard button tainted: one episode left Blizzard's own seeding dispatch tainted for the session (blocked SetShown and rejected secret cooldowns in combat, the gamepad bars' class flyout)." — [EUI_ActionBars_Disposal.lua (lines ~189-206)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIActionBars/EUI_ActionBars_Disposal.lua). A matching changelog entry reads "Fixed combat errors from Blizzard's hidden action buttons and the gamepad bars (blocked actions and secret value errors on cooldowns)." — [EUI__General_Options.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIOptions/EUI__General_Options.lua)
- **Cooldowns.** Read with `C_ActionBar.GetActionCooldownDuration` / `C_Spell.GetSpellCooldownDuration` (57 call sites) and paint with `Cooldown:SetCooldownFromDurationObject` (40 call sites). Check `C_Secrets.ShouldCooldownsBeSecret` before any Lua comparison. — local grep; [EUI_ActionBars_Disposal.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIActionBars/EUI_ActionBars_Disposal.lua)
- **Forever differences.** "The Extra Action Button's mover and settings are gone, now that the game no longer has an Extra Action Button". With the Gamepad interface style, "the action bar extras for the spellbook, the macro window, Quick Keybind, the spell flyout and bar paging now step aside to avoid blocked-action errors". — [EUI__General_Options.lua changelog](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIOptions/EUI__General_Options.lua)
- **Global cooldown spell.** The GCD reference spell on Forever is 29515, not 61304: "Forever reports nothing on 61304". — [EllesmereUI_Lite.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_Lite.lua)

**Auras and buffs**
- **AuraContainer engine.** EllesmereUI's shared aura layer is "the 12.1 aura container system". It loads `Blizzard_AuraContainer` and calls `CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate")`. It then uses `AddAuraGroup`, `AddAuraSlot`, `SetAuraGroupFilterString`, `SetAuraGroupLayout`, `SetAuraGroupSortMethod`, `SetDurationCooldown`, `SetDurationText`, `SetDurationBar`, `SetCountdownFormatter` and `SetAuraProcessingPolicy`. The engine parses and lays out auras itself. — [EllesmereUI_AuraKit.lua (line ~1578)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_AuraKit.lua). Blizzard confirmed AuraContainer and AuraButton for Forever. — [GameWave](https://gamewave.fr/world-of-warcraft-forever/wow-forever-les-restrictions-d-addons-de-midnight-seront-aussi-appliquees/)
- **Restyling while auras are secret.** `AddMaskTexture` and repositioning are "denied while auras are secret, retried once the restriction lifts". Restyles are deferred when `C_Secrets.ShouldAurasBeSecret()` is true or when `pcall(C_UnitAuras.GetAuraDataByIndex, "player", 1, "HELPFUL")` fails. — [EllesmereUI_AuraKit.lua (lines ~318-336, 2317-2329)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_AuraKit.lua)
- **Aura content.** Aura list contents are secret; the lists and `UNIT_AURA` are not. — [wowforevertierlist.com (fan site, derived from Midnight docs)](https://wowforevertierlist.com/addons/restrictions). EllesmereUI's AuraBuff Reminders say they are "for out-of-combat buff and consumable reminders" and point to "the Cooldown Manager's Buffs bar for in-combat and rotational auras". — [EUI__General_Options.lua changelog](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIOptions/EUI__General_Options.lua)

**Cooldown Manager**
- **Forever has its own catalogue.** EllesmereUI refers to "every spell id Forever's Cooldown Manager catalogue lists". Its CDM module "Mirrors Blizzard CDM bars with custom styling ... Does NOT parse secret values". It uses `C_CooldownViewer.GetCooldownViewerCooldownInfo` (56 call sites) and `GetCooldownViewerCategorySet` (12). — [EllesmereUICooldownManager.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUICooldownManager/EllesmereUICooldownManager.lua), [EUI_CDM_Reconcile.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUICooldownManager/EUI_CDM_Reconcile.lua). Blizzard_CooldownViewer loads on `standard, camelot`. — [Forever UI source](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_CooldownViewer/Blizzard_CooldownViewer.toc)
- **Forever differences.** "WoW Forever reports one spec per class". Hero-tree glows are ignored ("no hero..."). There is no raid lust, Sated debuff or Time Spiral, and no combat potion presets. Forever racials differ. — [EllesmereUICooldownManager / options comments](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUICooldownManager/)

**Damage meter and threat**
- **Built-in meter.** Blizzard_DamageMeter loads on `standard, camelot`. — [Forever UI source](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_DamageMeter/Blizzard_DamageMeter.toc). NaowhForever has a "Default Damage Meter" reskin of the game's meter (`Blizzard_DamageMeter`, window `DamageMeterSessionWindow1`). — [NaowhForever_QoL/Combat/DamageMeterSkin.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever_QoL/Combat/DamageMeterSkin.lua). The fan site's claim that a built-in meter is "unconfirmed" is out of date. — contradicted source: [wowforevertierlist.com](https://wowforevertierlist.com/addons/restrictions)
- **Custom meter.** EllesmereUIDamageMeters draws its own meter from `C_DamageMeter.GetCombatSessionFromType`, `GetCombatSessionSourceFromType` / `FromID` and `GetAvailableCombatSessions`. It skips work while `C_RestrictedActions.IsAddOnRestrictionActive(Enum.AddOnRestrictionType.Combat)` is true. On Forever it adds a "Threat" meter type fed by Forever Essentials. — [EUI_DamageMeters_Format.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIDamageMeters/EUI_DamageMeters_Format.lua), [EllesmereUIDamageMeters_ForeverThreat.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIDamageMeters/EllesmereUIDamageMeters_ForeverThreat.lua)
- **Swing timer (Forever-only).** "Addons lost the combat log in 12.0 (no SWING_DAMAGE / SWING_MISSED) ... Forever instead ships a native timer (Blizzard_SwingTimer, AllowLoadGameType camelot)". The API is `PLAYER_SWING(swingDuration, swingType)`, `C_SwingTimer.EnableRangeCheck`, `PLAYER_SWING_RANGE_UPDATE` and `C_SwingTimer.IsTargetWithinSwingRange`. — [EUI_ResourceBars_SwingTimer.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIResourceBars/EUI_ResourceBars_SwingTimer.lua), [Forever SwingTimerDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SwingTimerDocumentation.lua)

**Boss mods and encounter timeline**
- **Not on Forever.** Blizzard_EncounterTimeline and Blizzard_EncounterWarnings are `AllowLoadGameType: standard`, so they do not load on Forever. — [Forever UI source](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_EncounterTimeline/Blizzard_EncounterTimeline.toc). No local Forever addon references `C_EncounterTimeline` (local grep).
- **Third-party boss mods.** DBM reportedly has a Forever core but no Forever boss modules. — [wowforevertierlist.com (fan site)](https://wowforevertierlist.com/addons/restrictions)

**Minimap**
- **Restrictions.** Minimap rotation values cannot be read during encounters (a further loophole was closed in 1.60.1). — [warcraft.wiki.gg Patch 1.60.1 notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)
- **Forever minimap UI.** Forever has a new minimap header bar and buttons, a day/night orb and an event link button. — [EUI__General_Options.lua changelog](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIOptions/EUI__General_Options.lua). ElvUI commit on 2026-11-06: "minimap: external event is also on forever (cn region)". — [ElvUI commits](https://github.com/tukui-org/ElvUI/commits/main)

**Chat**
- **Instances.** Incoming chat in instances can be secret (SecretInChatMessagingLockdown), and addon comms are restricted under `AddOnRestrictionType.Chat`. — [warcraft.wiki.gg Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values), [Forever RestrictedActionsConstantsDocumentation.lua](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated)
- **Secret messages.** NaowhForever notes that "A secret-tainted message is dropped silently by the chat display, and `tostring` on a secret returns a secret string". It adds that "Blizzard skips the name filter when a name is secret". — [NaowhForever Core/README.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/Core/README.md), [Core/Badges/README.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/Core/Badges/README.md)
- **ElvUI fix.** ElvUI commit on 2026-10-31: "chat: protect VoiceOverlay from secrets". — [ElvUI commits](https://github.com/tukui-org/ElvUI/commits/main)
- **Account limits.** Trial accounts cannot send addon messages. — [warcraft.wiki.gg Patch 1.60.1 notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)

**Tooltips**
- **Target line.** EllesmereUI's tooltip "Targeting:" line returns early when `C_Secrets.ShouldUnitIdentityBeSecret(unit.."target")` is true. — [EUI_BlizzardSkin_TooltipSkin.lua (line ~555)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIBlizzardSkin/EUI_BlizzardSkin_TooltipSkin.lua)
- **Hook taint.** Naowh reports that a hook inside the game's tooltip building "got the game's unit colouring reported as tainted". — [NaowhForever Core/Badges/README.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/Core/Badges/README.md)
- **Sizing.** "In restricted content a string's size can be secret". — [NaowhForever Core/README.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/Core/README.md)

**Bags and bank, character pane, inspect, micro menu, bag bar**
- **Bags.** EllesmereUIBags runs on Forever with only 2 `issecretvalue` hits, so this is effectively non-combat. — local grep
- **Character sheet.** The Forever character sheet skin checks `issecretvalue` on item quality and on frame size before using them. — [EllesmereUIBlizzardSkin_CharacterSheetForever.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIBlizzardSkin/EllesmereUIBlizzardSkin_CharacterSheetForever.lua)
- **Bag bar.** The Forever bag bar skin uses "Alpha and our own child frames only: nothing is hidden, reparented or hooked on show inside the BagsBar tree (Blizzard shows and hides it on the way to protected calls)". — [EllesmereUIBlizzardSkin_BagBarForever.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIBlizzardSkin/EllesmereUIBlizzardSkin_BagBarForever.lua)
- **Micro menu.** Under Blizzard Style, the micro menu and bag bar "no longer sit inside WoW Forever's bronze frame". — [EUI__General_Options.lua changelog](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIOptions/EUI__General_Options.lua)

**XP and reputation bars, loot**
- **Data bars.** EllesmereUIDataBars runs on Forever, with secret guards on 21 lines. — local grep
- **Loot feed.** The Forever loot feed reads values only when they are "a readable value of type kind (never a secret one)". — [EllesmereUIForeverEssentials_LootFeed.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIForeverEssentials/EllesmereUIForeverEssentials_LootFeed.lua)

**Group finder**
- **No premade list.** "No premade group list on WoW Forever: no hooks, no API". — [EllesmereUI_SignupHelpers.lua line 2](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_SignupHelpers.lua). Forever loads Blizzard_GroupFinder_VanillaStyle (`classic, camelot`). — [Forever UI source](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns)
- **Skinning.** EllesmereUI skins the Looking For Group window, including its new Voice Chat dropdown. — [EUI__General_Options.lua changelog](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIOptions/EUI__General_Options.lua)

**World map**
- **Waypoint taint.** "The game redraws the world map's waypoint pin inside every change to its waypoint, so while that map is open a change waits for it to close: made from addon code it would taint the pin and the game would block its Share." — [NaowhForever Core/README.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/Core/README.md)

**Edit Mode**
- **Gamepad layouts.** Edit Mode exists on Forever, and layouts are saved separately for mouse/keyboard and gamepad. Importing old layout strings no longer errors. — [warcraft.wiki.gg Patch 1.60.1 notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)
- **Importing layouts.** EllesmereUI imports layouts through the low-level `C_EditMode.GetLayouts` / `SaveLayouts` / `ConvertStringToLayoutInfo` / `SetActiveLayout`, not the manager's `MakeNewLayout`. The manager method errors until Edit Mode has been opened once in the session. EllesmereUI says "The CALLER must ReloadUI() immediately after a successful import so ... the addon taint introduced into Edit Mode is wiped. Must be out of combat." — [EllesmereUI_Profiles.lua (lines ~4680-4690)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_Profiles.lua)

**Settings panel and reload**
- **Settings registration.** Addon options register with `Settings.RegisterCanvasLayoutCategory` and `Settings.RegisterAddOnCategory` (local grep). — [EllesmereUI / NaowhForever code](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/)
- **Reload.** "The game blocks an addon's own reload, even from a click, but runs /reload from a secure macro button." Naowh places one secure button on UIParent over its Reload button and hides it when combat starts. — [NaowhForever Core/README.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/Core/README.md)

### Inferences
- KstyleUI should not plan these on Forever:
  - a boss timeline or warnings skin (the systems do not exist);
  - Lua-computed health or deficit text, or health-based sorting and thresholds;
  - combat-log parsing of any kind;
  - in-instance chat parsing or addon comms during restricted states;
  - auto-marking from GUIDs or names in instances;
  - Extra Action Button or zone-ability styling (Blizzard_ZoneAbility is `mainline`; unclear whether "mainline" includes camelot);
  - premade group finder hooks;
  - hero talent or multi-spec features.
- KstyleUI can plan these on Forever:
  - fully custom unit, party and raid frames on secure templates, with bars fed by secrets and curve-coloured health;
  - an AuraContainer-based aura display;
  - a CDM mirror or skin;
  - a damage meter skin or custom meter from C_DamageMeter;
  - threat displays (readable on Forever);
  - a swing timer from C_SwingTimer;
  - a nameplate restyle;
  - restyles of bags, chat, map, minimap, tooltip and character sheet;
  - Edit Mode layout presets, imported out of combat and followed by a reload.

### Gaps
- Whether "mainline" in AllowLoadGameType includes camelot was not verified. It affects Blizzard_PersonalResourceDisplay, Blizzard_ZoneAbility and Blizzard_Professions; EllesmereUI's changelog references Professions-adjacent windows on Forever, so likely yes.
- Not checked: the exact `C_DamageMeter` data types available on Forever (damage, healing, interrupts, deaths), and whether meter values are secret during combat on Forever.
- Not checked: the Forever bank UI (Warband bank, reagent bag) and the Forever quest tracker internals. EllesmereUIQuestTracker has only 2 secret hits.

---

## 3. Reskin Blizzard frames or replace them with addon frames? Taint pitfalls (Edit Mode, protected frames, InCombatLockdown)

### Takeaway
The 2026 consensus in the leading Forever-compatible suites is a hybrid:
- **Replace** combat HUD frames (unit, raid, party and nameplate visuals, action bars) with addon-owned secure frames.
- **Mirror or skin** the Blizzard data viewers (CDM, damage meter).
- **Reskin** non-combat windows using alpha changes and your own child frames.

Never write fields onto Blizzard frames. Never `:Hide()` or reparent protected frames synchronously, inside Edit Mode, or in combat. Never run setup code inside a Blizzard secure dispatch.

### Cited Findings
- **Replacement is about taint, not features.** EllesmereUI's own action bar buttons exist to eliminate "the taint surface from reusing Blizzard's protected buttons". — [EllesmereUIActionBars.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIActionBars/EllesmereUIActionBars.lua)
- **Edit Mode reparenting taint.** "Edit Mode's layout pass calls SetParent on managed containers (BossTargetFrameContainer->UIParent) every enter/exit, so that inline reparent runs in Blizzard's secure execution and taints secret-value reads (CompactUnitFrame compares, encounter warnings, SecureUtil arithmetic), poisoning party frames for the session. Fix: defer reparent to a timer and postpone while Edit Mode is open". — [EllesmereUIUnitFrames.lua (lines 23-29)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIUnitFrames/EllesmereUIUnitFrames.lua)
- **How EllesmereUI hides a Blizzard unit frame.** `UnregisterAllEvents()`, hide, reparent to a hidden parent, and add a `hooksecurefunc(frame,"SetParent")` that re-parks through `C_Timer.After(0, ...)`. It also unregisters events on the child bars (health, mana, cast, alt power, aura frames). — [EllesmereUIUnitFrames.lua (lines 60-90)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIUnitFrames/EllesmereUIUnitFrames.lua)
- **Do not reparent PlayerFrame-managed alt power bars.** "Reparenting PlayerFrame makes them descendants of an insecure frame" and leads to "Auras cannot be accessed when secret while tainted". "Fix: unregister events only (taint-clean, combat-legal) -- do NOT reparent". — [EllesmereUIUnitFrames.lua (lines ~93-105)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIUnitFrames/EllesmereUIUnitFrames.lua)
- **Never write fields onto Blizzard frames.** EllesmereUI stores per-frame state in a weak-keyed side table (`EllesmereUI._GetFFD(frame)`). Writing `actionButtonCastType` fields onto Blizzard buttons tainted Blizzard's dispatch for the session on Forever. — [EllesmereUI_SharedHelpers.lua (lines 15-20)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_SharedHelpers.lua), [EUI_ActionBars_Disposal.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIActionBars/EUI_ActionBars_Disposal.lua)
- **When to run secure setup.** Run it at `PLAYER_LOGIN`, synchronously, inside the loading-screen window: "the only window in which those secure operations are permitted while the player is in combat". "C_Timer callbacks do NOT run during the loading screen". Post-login `ADDON_LOADED` work is deferred one tick because it "can be dispatched from inside Blizzard's own SECURE executions" and stamps taint that "Edit Mode's enter/exit passes later read, erroring on 12.x secret values". — [EllesmereUI_Lite.lua (lines ~525-550)](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_Lite.lua)
- **Combat queue.** EllesmereUI queues protected work during combat (`EllesmereUI.NewCombatQueue`, `ns.CombatQueue.Defer(...)`) and re-runs it on `PLAYER_REGEN_ENABLED`. — [EllesmereUIUnitFrames.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIUnitFrames/EllesmereUIUnitFrames.lua), [EllesmereUI_SharedHelpers.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_SharedHelpers.lua)
- **Naowh window pitfalls.**
  - "a named addon frame in [UISpecialFrames] taints CloseAllWindows".
  - "`SetPropagateKeyboardInput` is protected, so in combat the keyboard is not taken".
  - A game menu button must go in through `MainMenuFrameMixin.AddButton`, not the menu's `AddButton`. Otherwise the gamepad-mode OnHide hits the protected `SetGamePadCursorControl`.
  - "A protected frame inside our windows would lock them in combat".
  — [NaowhForever Core/README.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/Core/README.md)
- **Gamepad on Forever.** `ns.GamepadOwnsPanels()` is true when Blizzard's gamepad handling (`ShowUIPanel`, game menu, bags calling the protected `SetGamePadCursorControl`) is active. "Opening or closing a Blizzard panel from addon code then gets forbidden". — [NaowhForever Core/README.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/Core/README.md). Forever ships camelot-only Blizzard_Gamepad, GamepadActionBars and GamepadTargeting. — [Forever UI source](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns)
- **Blizzard's intent.** Blizzard says the 12.0 restrictions are "not intended to prevent 'look and feel' customization of UI elements." — [warcraft.wiki.gg Patch 12.0.0/API changes](https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes)

### Inferences
- **Replace with secure frames:** player, target, focus, ToT, pet, party, raid and boss frames (SecureUnitButtonTemplate + RegisterUnitWatch; SecureGroupHeaderTemplate for groups) and action bars (own SecureActionButtonTemplate / ActionBarButtonTemplate buttons, SetOverrideBindingClick, RegisterStateDriver paging). Keep stance and pet bars as Blizzard buttons, restyled, as EllesmereUI does.
- **Mirror or skin:** the Cooldown Manager (read C_CooldownViewer, or skin the viewer frames) and the damage meter (skin DamageMeterSessionWindow1, or build from C_DamageMeter).
- **Reskin only (alpha, textures, own child frames; no hide or reparent inside protected trees):** bag bar, micro menu, character, inspect, LFG, talents, map, tooltips, chat chrome, objective tracker.
- **Add to KstyleUI AGENTS.md as rules:**
  1. Keep frame state in a side table; never `blizzFrame.myField = x`.
  2. Run hooks with `hooksecurefunc`, deferring writes with `C_Timer.After(0)`.
  3. Check `EditModeManagerFrame:IsShown()` before any SetParent.
  4. Wrap protected work in an `InCombatLockdown()` queue.
  5. Call `issecretvalue(v)` before any comparison, including `== nil`.

### Gaps
- No Blizzard documentation lists which Blizzard frames are safe to reparent on Forever. The guidance above comes from addon-author experience (EllesmereUI, Naowh).
- Not checked: whether `SecureActionButtonTemplate` behaviour differs between Forever and Retail (for example action-bar paging conditions for vanilla stances and forms).

---

## 4. How do modern full-UI addons that support Forever handle these restrictions?

### Takeaway
EllesmereUI (9.6.1), NaowhUI and NaowhForever (1.1.34), and ElvUI (v16.01) all support Forever with one codebase shared with Retail 12.1.x. They gate Forever-only content and art behind an `IS_FOREVER` flag and use the same secret-safe patterns on both clients: `issecretvalue` guards, curves, duration objects, AuraContainer and C_Secrets predicates. No information was found about NihilUI.

### Cited Findings
- **EllesmereUI TOCs.** `## Interface: 120000, 120001, 120005, 120007, 120100, 120105, 16001` (one code path). A Forever-only module ships as `EllesmereUIForeverEssentials_Camelot.toc` with `## Interface: 16001` and `## AllowLoadGameType: camelot`. — [EllesmereUI.toc](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI.toc), [EllesmereUIForeverEssentials_Camelot.toc](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIForeverEssentials/EllesmereUIForeverEssentials_Camelot.toc)
- **EllesmereUI grep counts** (the hit count is the number of matches across the folders):

  | Term | Hits |
  |---|---|
  | `issecretvalue` | 1,100+ across 23 folders (for example UnitFrames 159, CooldownManager 229, RaidFrames 124, Nameplates 90, DamageMeters 87) |
  | `C_CurveUtil` | about 116 |
  | `UnitHealthPercent` | 34 |
  | `C_CooldownViewer` | 112 |
  | `C_DamageMeter` | 86 |
  | `WOW_PROJECT` | 4 (library code only) |
  | `16001` | 3 |
  | `camelot` | 9 |

  — local grep of [EllesmereUI* folders](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/)
- **APIs used across EllesmereUI and Naowh:**
  - `C_CurveUtil.CreateCurve` (20 call sites), `CreateColorCurve` (21) and `EvaluateColorValueFromBoolean` (40);
  - `C_DurationUtil.CreateDuration` (11) and `CreateDurationTextBinding` (12);
  - `StatusBar:SetTimerDuration` (45) and `Cooldown:SetCooldownFromDurationObject` (40);
  - `SetAlphaFromBoolean` (79);
  - `C_StringUtil.CreateNumericRuleFormatter` (22) and `TruncateWhenZero` (10);
  - `AbbreviateNumbers` (132);
  - `canaccesstable` / `issecrettable` (29);
  - `C_Secrets.ShouldAurasBeSecret` (27) and `ShouldUnitStatsBeSecret` (8);
  - `CreateUnitHealPredictionCalculator` (10).
  — local grep
- **NaowhUI.** `NUI.forever = WOW_PROJECT_ID == WOW_PROJECT_CAMELOT`; TOC `## Interface: 120105, 16001`. NaowhUI_EUI is a companion that injects into EllesmereUI. — [NaowhUI Core.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI/Game/Shared/General/Core.lua), [NaowhUI_EUI.toc](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhUI_EUI/NaowhUI_EUI.toc)
- **NaowhForever patterns.**
  - Low-health alpha: `frame:SetAlpha(UnitHealthPercent("player", true, curve))`.
  - Sound threshold: `if issecretvalue(pct) then SetGlow(...) return end`, and only when the value is readable does it compare `pct < Low.Below()`.
  — [NaowhForever_Combat/AuraBuffs/UI/LowHealth.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever_Combat/AuraBuffs/UI/LowHealth.lua). Its changelog includes fixes such as "no more 'attempt to compare a secret string value' errors when nameplates..." and "Opening the options window no longer throws a secret boolean error". — [NaowhForever CHANGELOG.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/CHANGELOG.md)
- **ElvUI.**
  - TOC on `main`: `## Interface: 11509, 16001, 20506, 38002, 50504, 120100, 120105`.
  - Detection: `E.Forever = WOW_PROJECT_ID == WOW_PROJECT_CAMELOT` and `E.Modern = E.Retail or E.Forever`, with secret helpers `E.IsSecretValue` / `E.NotSecretUnit` coming from oUF.
  - Releases: v16.01 tagged 2026-11-03.
  - Recent Forever commits: "Skins: Forever update" (2026-10-30), "Skins: Forever fixes" (2026-10-29), "DT: add ammo on forever" (2026-11-05), "chat: protect VoiceOverlay from secrets" (2026-10-31).
  — [ElvUI repo](https://github.com/tukui-org/ElvUI), [ElvUI commits](https://github.com/tukui-org/ElvUI/commits/main)
- **Earlier conflicting press.** PlayNews said ElvUI 16.00 (13 Oct) added a first round of Forever support; GameWave (26 Oct 2026) said ElvUI would not run on Forever. The GitHub TOC and commits above settle this in favour of support. — [PlayNews](https://www.playnews.gg/guides/interface-wow-forever-comment-importer-un-profil-elvui-ou-un-code-d-ui) (search snippet only); contradicted: [GameWave Ellesmere article](https://gamewave.fr/world-of-warcraft-forever/wow-forever-ellesmere-l-addon-a-adopter-pour-remplacer-elvui/) (search snippet only)
- **Installed Forever addons.**
  - Narcissus, Plumber and DialogueUI detect Forever through `X-GameType == "Camelot"` or `WOW_PROJECT_CAMELOT`.
  - They guard with `issecretvalue` (Narcissus 6, Plumber 3, WaypointUI 3).
  - They use `C_Secrets.ShouldUnitIdentityBeSecret` (Narcissus PhotoMode; DialogueUI `API.ShouldUnitIdentityBeSecret`) and `C_Secrets.ShouldAurasBeSecret` (Plumber GossipFrameMedal; DialogueUI GossipData_Racing).
  - None uses C_CurveUtil, UnitHealthPercent, C_CooldownViewer or C_DamageMeter; they are non-combat UIs.
  - Narcissus notes "12.1.0 client doesn't recognize [AllowLoadGameType camelot] so this file is still loaded" (that is, on Retail 12.1.0).
  — [Narcissus Initialization.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Initialization.lua), [Plumber/API.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/API.lua), [DialogueUI/API.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/API.lua), [Narcissus Data_Camelot.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Modules/CharacterFrame/StatSheet/Data_Camelot.lua)
- **WeakAuras.** No Forever build as of 8 Oct 2026. — [wowforevertierlist.com](https://wowforevertierlist.com/addons/restrictions)

### Inferences
- The patterns worth copying for KstyleUI:
  - client gate on the TOC number;
  - an `IS_FOREVER` content gate;
  - one engine-side aura layer (AuraContainer);
  - one curve and duration helper library;
  - a side-table frame state store;
  - a combat queue;
  - deferring Blizzard-frame writes with `C_Timer.After(0)` and Edit Mode checks;
  - Forever-specific art kept separate from logic.
- Because ElvUI and EllesmereUI both support Forever, KstyleUI will compete on look and feel, not on access to data.

### Gaps
- NihilUI: no local copy and no web results found. Its Forever support and approach are unknown.
- The Icy Veins articles ("WoW Forever Players Can Now Build Their Perfect UI With EllesmereUI" and "Addons in WoW Forever? Blizzard Devs Just Addressed the Big Question") returned HTTP 403 and were not read.

---

## 5. New Blizzard APIs a skin can lean on

### Takeaway
Forever has the full 12.1.x display toolkit for secrets. It also has three Blizzard data viewers a skin can mirror (Cooldown Manager, Damage Meter, Forever-only Swing Timer) and the AuraContainer engine. There is no Encounter Timeline.

### Cited Findings
- **API documentation present in the Forever build:**
  - AuraContainerShared and AuraContainerUtil;
  - CooldownViewer and its constants;
  - CurveUtil and the LuaCurveObject / LuaColorCurveObject APIs;
  - DamageMeter and its constants;
  - DurationUtil, LuaDurationObject and DurationTextBinding;
  - NamePlate, NamePlateManager and FrameAPINamePlate;
  - RestrictedActions;
  - SecretAspectConstants, SecretPredicateAPI, SecretPredicates and SecretWrapperConstants;
  - StringUtil;
  - SwingTimer;
  - UnitAura;
  - EncounterTimeline docs, although its UI addon is `standard`-only.
  — [Forever UI source: Blizzard_APIDocumentationGenerated](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated)
- **Curves.** `C_CurveUtil.CreateCurve()` and `CreateColorCurve()` "let addons display secret values without inspecting them", for example green-to-red health colouring. — [warcraft.wiki.gg Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values)
- **Duration objects.** `C_DurationUtil.CreateDuration()` returns Duration objects that can compute on secret data and be passed to `StatusBar:SetTimerDuration()`. — [warcraft.wiki.gg Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values)
- **Widget methods added in 12.0.** `Region:SetAlphaFromBoolean`, `Region:SetVertexColorFromBoolean`, `StatusBar:SetTimerDuration` and `Cooldown:SetCooldownFromDurationObject`. Also UnitHealthPercent, UnitHealthMissing, CreateUnitHealPredictionCalculator, the C_DamageMeter.* and C_EncounterTimeline.* namespaces, and C_CooldownViewer.GetValidAlertTypes. — [warcraft.wiki.gg Patch 12.0.0/API changes](https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes)
- **Engine-driven animation.** EllesmereUI's swing timer has the engine animate the fill and write the remaining-time text: "PLAYER_SWING re-sets the row's C_DurationUtil duration object and arms the bar timer (SetTimerDuration) ... a duration text binding on the same duration object writes it through a tenths formatter". There is no Lua per frame. — [EUI_ResourceBars_SwingTimer.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIResourceBars/EUI_ResourceBars_SwingTimer.lua)
- **Blizzard addons referenced by EllesmereUI and Naowh** (useful skin targets): Blizzard_EditMode (18), Blizzard_WorldMap (18), Blizzard_GroupFinder (13), Blizzard_AuraContainer (9), Blizzard_CooldownViewer (8), Blizzard_ObjectiveTracker (6), Blizzard_CompactRaidFrameManager (6), Blizzard_NamePlateAuras, Blizzard_CustomAuraButton, Blizzard_AuraButton and Blizzard_DamageMeter. — local grep
- **Skinning API for third-party addons.** EllesmereUI exposes `EllesmereUI.RegisterSkin("MyAddon", function(S) S.Shell(...) S.Button(...) end)`, which other addons can call to match its theme. — [EllesmereUI/SKINNING_API.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/SKINNING_API.md)

### Inferences
- **Core toolkit for KstyleUI's combat modules:**
  - `UnitHealthPercent(unit, true, curve)` for text, and colour from a `C_CurveUtil` colour curve;
  - `StatusBar:SetMinMaxValues(0, UnitHealthMax(u))` and `SetValue(UnitHealth(u))`, passing secrets straight through;
  - `SetTimerDuration` for cast and swing bars;
  - `SetCooldownFromDurationObject` for action and aura swipes;
  - `SetAlphaFromBoolean` for range and visibility;
  - AuraContainer for buffs and debuffs;
  - `AbbreviateNumbers` / `C_StringUtil` formatters for numbers.
- **Data-viewer modules:** skin or mirror CDM (`C_CooldownViewer`), the Damage Meter (`C_DamageMeter` or DamageMeterSessionWindow1), the Swing Timer (`C_SwingTimer`, Forever-only), and threat (classic threat APIs, readable on Forever).

### Gaps
- Not inspected: the full method lists of the AuraContainer and DurationTextBinding objects in the Forever docs. Consult `AuraContainerSharedDocumentation.lua` and `DurationTextBindingObjectAPIDocumentation.lua` in the forever branch when designing.

---

## 6. Known forbidden or protected actions that would break a UI addon

### Takeaway
Forever has the standard secure-frame rules (no protected frame changes in combat) plus the 12.x restrictions. The extras: no combat log, secret comparisons raise errors, ReloadUI is blocked from addon code, and Edit Mode, gamepad and map secure paths taint easily.

### Cited Findings
- **Combat log events.** Registering `COMBAT_LOG_EVENT` or `COMBAT_LOG_EVENT_UNFILTERED` errors. — [warcraft.wiki.gg Patch 12.0.0/API changes](https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes)
- **Secret values.** Any arithmetic, comparison, boolean test, `#`, table-key use or indexing on a secret in addon code is an immediate Lua error. Comparing a secret even to nil fails ("comparing a secret, even to nil, is an error"). — [warcraft.wiki.gg Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values), [EllesmereUIForeverEssentials_ThreatData.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIForeverEssentials/EllesmereUIForeverEssentials_ThreatData.lua)
- **Forbidden tables.** Tables flagged as forbidden raise "attempted to index a forbidden table" when tainted code indexes them. Using a secret as a key from untainted code permanently flags the table. — [warcraft.wiki.gg Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values)
- **Secret anchoring.** Anchoring to a frame that holds secrets makes your anchors secret, so `GetPoint`, `GetWidth` and similar return secrets. `FrameStrata` can be a secret aspect on Forever. — [warcraft.wiki.gg Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values), [warcraft.wiki.gg Patch 1.60.1 notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)
- **ReloadUI.** Addon code cannot call it, even from a click; a secure macro button running `/reload` works. — [NaowhForever Core/README.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/Core/README.md)
- **Secure setup during combat.** `RegisterStateDriver`, `WrapScript`, protected `SetCVar` and hiding Edit Mode are only allowed in combat during the login or reload loading screen. Otherwise they produce an `ADDON_ACTION_BLOCKED` storm. — [EllesmereUI_Lite.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_Lite.lua)
- **`:Hide()` on protected stock frames** "can trigger taint chains in protected code paths"; reparent to a hidden frame instead. — [EUI_ActionBars_Disposal.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIActionBars/EUI_ActionBars_Disposal.lua)
- **SetParent during Edit Mode** runs Blizzard's synchronous layout handlers under addon taint and "poisons the manager's state". — [EllesmereUI_SharedHelpers.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_SharedHelpers.lua), [EllesmereUIUnitFrames.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUIUnitFrames/EllesmereUIUnitFrames.lua)
- **Edit Mode layout import** must happen out of combat and be followed by `ReloadUI()` to wipe the taint. — [EllesmereUI_Profiles.lua](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/EllesmereUI/EllesmereUI_Profiles.lua)
- **Windows and keyboard.** UISpecialFrames with a named addon frame taints CloseAllWindows. `SetPropagateKeyboardInput` is protected in combat. — [NaowhForever Core/README.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/Core/README.md)
- **Gamepad mode.** `SetGamePadCursorControl` is protected. Opening or closing Blizzard panels from addon code while gamepad handling is active is forbidden. — [NaowhForever Core/README.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/Core/README.md)
- **World map waypoint changes** while the map is open taint the pin and block Share. — [NaowhForever Core/README.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/Core/README.md)
- **Professions window in combat.** Closing, switching or moving it caused blocked-action errors until Naowh fixed them. — [NaowhForever CHANGELOG.md](file:///Applications/World%20of%20Warcraft/_classic_beta_/Interface/AddOns/NaowhForever/CHANGELOG.md)
- **Chat and comms.** Addon messages and chat sends are restricted under `AddOnRestrictionType.Chat` (in instances). EMOTE needs a hardware event outside instances. Trial accounts cannot send addon messages. — [Forever RestrictedActionsConstantsDocumentation.lua](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated), [warcraft.wiki.gg Patch 1.60.1 notes](https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes)
- **Blocked-action notification.** `C_RestrictedActions.CheckAllowProtectedFunctions(object, silent)` exists to test whether protected calls are allowed without signalling a blocked-action error. — [Forever RestrictedActionsDocumentation.lua](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated)

### Inferences
- KstyleUI needs these safeguards:
  - a central `Secret.Is(v)` guard and a "display-only" coding rule enforced by lint (for example, flag `<`, `>`, `+` on the results of unit or aura APIs);
  - a combat queue for every protected call;
  - an Edit Mode guard;
  - a secure macro button for reload;
  - an Escape handler of its own instead of UISpecialFrames.
- Test with `/console addonCombatRestrictionsForced 1` (and the Map, Encounter and Chat variants) to reproduce restricted states solo.

### Gaps
- Not compiled: a complete, authoritative list of Forever's protected functions. The live source (`forever` branch) is the place to check specific functions.
- Not determined: whether private auras or other Retail-only hidden aura systems exist on Forever.
