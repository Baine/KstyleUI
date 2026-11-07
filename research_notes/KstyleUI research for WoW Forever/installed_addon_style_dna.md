# Installed-addon style DNA: Narcissus, WaypointUI, DialogueUI and Plumber (for KstyleUI)

Scope: a read-only audit of the copies installed under `/Applications/World of Warcraft/_forever_/Interface/AddOns/` (Narcissus 1.8.7 b, WaypointUI 1.7.5, DialogueUI 1.0.7 b, Plumber 1.9.7 c, per their `.toc` files), plus the CurseForge and GitHub licence pages. No addon Lua was executed. Textures were decoded with Pillow in a scratchpad virtualenv, plus a small custom decoder for BLP2 "encoding 3" (raw BGRA), which Pillow cannot read and which every WaypointUI `.blp` uses.

Link conventions:
- `A/` in link text means `/Applications/World of Warcraft/_forever_/Interface/AddOns/`. Each link is a `file://` URL to the exact file. Line numbers (`:L123`) come from `grep -n` and `sed -n` against the installed copy.
- `SHEET:` links point to the contact sheets and colour-stat TSVs I generated in the scratchpad. Each sheet shows every texture twice: composited on #111 (left) and on #808080 (right).
- Hex values marked "sampled" are 3×3 median pixels or 5-colour median-cut clusters from the texture files. Values marked "Lua" are converted from RGB constants in the code.

## Colour: what palettes do they use (backgrounds, accents, text, quality colours)?

### Takeaway
The four addons share one palette philosophy: near-black, slightly warm or slightly cool neutral surfaces (#0d0d0d to #2b2b2b, usually 80–92% opaque), off-white text that is never pure white at rest (#ababab to #e0e0e0, brightening to #ebebeb or #ffffff on hover), and one restrained accent family per surface. The accents are bronze and copper (Plumber), parchment and brick (DialogueUI Brown), warm gold (WaypointUI tabs) and quality hues (Narcissus). Peterodox's addons share a brightened item-quality palette (Rare #699eff, Epic #b953ff), and Narcissus tints UI chrome by the player's current zone.

### Cited Findings

#### Evidence: contact sheets and scripts (view these with an image viewer)
- Narcissus: [narci_shapes_masks.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_shapes_masks.png), [narci_borders_buttons.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_borders_buttons.png), [narci_frames_tooltip.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_frames_tooltip.png), [narci_settings.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_settings.png), [narci_itemborder_jpg_masks.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_itemborder_jpg_masks.png)
- WaypointUI: [wui_frames_primitives.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/WaypointUI/wui_frames_primitives.png), [wui_icons.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/WaypointUI/wui_icons.png), [wui_atlases_large.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/WaypointUI/wui_atlases_large.png), [wui_common_atlas.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/WaypointUI/wui_common_atlas.png)
- DialogueUI: [dui_theme_dark.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/DialogueUI/dui_theme_dark.png), [dui_theme_brown.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/DialogueUI/dui_theme_brown.png), [dui_shared_parchment_book.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/DialogueUI/dui_shared_parchment_book.png), [dui_parchment_atlases.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/DialogueUI/dui_parchment_atlases.png), [dui_keys_icons.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/DialogueUI/dui_keys_icons.png)
- Plumber: [plumber_frame.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Plumber/plumber_frame.png), [plumber_button_shapes.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Plumber/plumber_button_shapes.png), [plumber_controlcenter_loot_landing.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Plumber/plumber_controlcenter_loot_landing.png), [plumber_settings_atlases.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Plumber/plumber_settings_atlases.png)
- Cross-addon: [corner_geometry_zoom.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/corner_geometry_zoom.png) shows nearest-neighbour zooms of panel corners.
- Each sheet `X.png` has a sibling `X_stats.tsv` with per-texture size, alpha profile, mean colour and 5 dominant colours, for example [narci_borders_buttons_stats.tsv](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_borders_buttons_stats.tsv).
- Scripts, all run with `python -I`, are in `/private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/scripts/`: `art_audit.py` (sheets and stats, plus the BLP2 raw decoder), `bigview.py` (large atlases), `sample.py` (pixel sampler), `corner.py` and `cornerzoom.py` (corner geometry), and `font_meta.py` (font name-table licence metadata).

#### Narcissus (Lua constants)
- Text colours (Lua) in `Narci_FontColor`: Brown #d9cdb4, DarkGrey #6b6b6b, LightGrey #b8b8b8, White #e0e0e0, Good #7cc576, Bad #ff5050, Corrupt #946dd1. Presets `green` = #7cc576 and `red` = #ff5050 — [A/Narcissus/NarciDB/Color.lua:L11-32](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/NarciDB/Color.lua)
- Custom (brightened) quality colours: Poor #9d9d9d, Common #ffffff, Uncommon #1eff00, Rare #699eff (a comment notes Blizzard's #0070dd), Epic #b953ff (Blizzard #a335ee), Legendary #ff8000, Artifact #e6cc80, Heirloom #00ccff — [A/Narcissus/NarciDB/Color.lua:L34-45](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/NarciDB/Color.lua)
- Zone-reactive theme colour, `MapColors[uiMapID]`. The default is #4e4e4e; examples are Orgrimmar #791f23, Zuldazar #31b06b, Zereth Mortis #89daf7, Oribos #4c566d, Bastion #c5b9ac, Ardenweald #39429a, Maldraxxus #196155 and Revendreth #306099. `UIColorThemeUtil:SetWidgetColor` applies the colour to textures as is, and to FontStrings after a per-channel `sqrt()` brighten — [A/Narcissus/NarciDB/Color.lua:L171-352](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/NarciDB/Color.lua)
- Settings label tiers (Lua): highlight 0.92 = #ebebeb, normal 0.67 = #ababab, disabled 0.40 = #666666. These apply to both text and border vertex colour — [A/Narcissus/SettingsFrame.lua:L47-66](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.lua)
- Settings fallback background is `SetColorTexture(0.05,0.05,0.05,0.8)`, which is #0d0d0d at 80% (L2333). The key-binding field background is #ebebeb (L2897), and on success it turns green, 0.35/0.61/0.38 = #599c61 (L3128) — [A/Narcissus/SettingsFrame.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.lua)
- Category-tinted widget tooltips: backgrounds Mog #301947, Emote #473719, HideTexts #482019, TopQuality #193c47, Camera #253c35, Preferences #333333. Headers Mog #ac73ee, Emote #e0c238, HideTexts #cc5252, TopQuality #60b6d8, Camera #81caa5. Each pairs a dark desaturated background with a bright header in the same hue — [A/Narcissus/Widgets/WidgetTooltip.lua:L24-40](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Widgets/WidgetTooltip.lua)

#### Narcissus (sampled from textures)
- Settings panel fill `FrameBackground.tga` sampled #141414 at 100% alpha. `FrameBorder.tga` rim sampled #404040, stepping to #2a2a2a and #303030 inward (inner bevel). Dark tooltip fill `TooltipDefaultDarkLayout.tga` sampled #11151f at 92% (a cool blue-black). `NineSlicePhotoModePopup.tga` sampled #2b2b2b — [A/Narcissus/Art/SettingsFrame/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Art/SettingsFrame/), [A/Narcissus/Art/Tooltip/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Art/Tooltip/); SHEET: [narci_settings_stats.tsv](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_settings_stats.tsv)
- The hexagonal quality borders have lit-edge colours (sampled dominant clusters) of Rare #2570bb, Epic #8c2cbe, Legendary #cb742a, Uncommon #12a30b, Heirloom #5bacc3 and Artifact #c1ad73. Each is paired with a darker shadow tone of the same hue (Rare #042650, Epic #450070, Legendary #532806) to give a bevelled metal look — [A/Narcissus/Art/Border/HexagonBorder-*.tga](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Art/Border/); SHEET: [narci_borders_buttons.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_borders_buttons.png)
- Icon highlights: `OuterGlow.tga` is solid #ffd100 (Blizzard gold) with a soft alpha glow, `InnerGlow.tga` is #fde990, and `Rect-Highlight.tga` is #d5f1ff (icy white) — [A/Narcissus/Art/IconHighlight/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Art/IconHighlight/)

#### DialogueUI
- `ThemeUtil` named colours (Lua): DarkBrown #302b21, LightBrown #805c3d, Ivory #dddbbf, Brick #6a2e2a, DarkModeGrey90 #e6e6e6, Grey70 #b3b3b3, Grey50 #808080, DarkModeGold #fffacc, DarkModeGoldDim #cbc895, WarningRed #ff2020, BrightGreen #80db80. Each Font object maps to a {Brown, Dark} pair; for example, paragraph text is DarkBrown or Grey70, and quest options are Ivory or DarkModeGold — [A/DialogueUI/Code/Utility/ThemeUtil.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Utility/ThemeUtil.lua)
- For legibility, the code rewrites inline colour codes in quest text: on parchment, red codes become `|cff9B2020`, and on the dark theme, pure blue becomes `|cff0078FF` — [A/DialogueUI/Code/Utility/ThemeUtil.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Utility/ThemeUtil.lua)
- Sampled textures, Brown theme: parchment centre #cba174 (clusters #cea77a, #b58a5e, with #523924 burnt edges), option plates red #603525, blue #2c4a54, grey #7d6f5f, hollow #aa7e54, dividers #734929. Dark theme: option plates red #7b1816, blue #15436c, grey #4d4438; dividers #1e1e1e; tooltip #111112 — SHEET: [dui_theme_brown_stats.tsv](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/DialogueUI/dui_theme_brown_stats.tsv), [dui_theme_dark_stats.tsv](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/DialogueUI/dui_theme_dark_stats.tsv)
- Option hover highlights use ADD blending with tints: red {0.62,0,0} = #9e0000, blue {0,0.3,0.4} = #004c66, grey #3b3b3b. Gossip options use a BLEND highlight texture instead — [A/DialogueUI/Code/Dialogue/UITemplates.lua:L847-851](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Dialogue/UITemplates.lua)

#### Plumber
- Settings text colours (Lua): Normal #d7c0a3 (warm parchment beige), Highlight #ffffff, NonInteractable #947c66, Disabled #808080, Readable #a39d93 — [A/Plumber/Modules/ControlCenter/SettingsPanelNew.lua (Def table, top of file)](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/ControlCenter/SettingsPanelNew.lua)
- Swatches: SelectionBlue #0c69d8, SmoothGreen #7cc576 (the same green as Narcissus "Good"), WarningRed #d4641c. The quality overrides carry the comment "use the color in Narcissus": Common 0.92 (#ebebeb), Rare #699eff, Epic #b953ff — [A/Plumber/API.lua:L296-330](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/API.lua)
- Sampled `SettingsPanel.png` atlas: the sidebar is a vertical leather gradient from #0f0b08 (top) through #171210 to #20130f (bottom, faint red-brown). The copper bevel line is #64513e over #342a20 and #251e17. The filter-button face runs from #dfa63c (amber) to #9f4925 (rust). The header plate is #120e0b. The minimised-frame background in code is (0.067,0.040,0.024,0.8) = #110a06 at 80% — [A/Plumber/Art/ControlCenter/SettingsPanel.png](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Art/ControlCenter/SettingsPanel.png); SHEET: [plumber_settings_atlases.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Plumber/plumber_settings_atlases.png)
- Generic frames: `CommonFrameWithHeader.tga` body #1f1e21 at 80%, header band #34302d to #443f3b, bevel highlight line about #5c5953 (sampled) — [A/Plumber/Art/Frame/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Art/Frame/); SHEET: [plumber_frame.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Plumber/plumber_frame.png)
- Loot glow colours by quality (Lua): {0.8,0.8,0.8}, {0,1,0}, {0,0.5,1}, {0.5,0,1}, {1,0.5,0}. Spike colours: Rare {0.5,0.8,1}, Epic {0.83,0.5,1} — [A/Plumber/Modules/LootUI/MiscWidgets.lua:L294-307](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/LootUI/MiscWidgets.lua)

#### WaypointUI
- Context colours (Lua): Other #fff1b4, NormalQuest RGB (255,255,156) = #ffff9c, Repeatable #9ecff5, Important #f9c4ff, Incomplete #c8c8c8. The parallel HEX table disagrees for two entries (NormalQuest `|cffFFEC9C`, Incomplete `|cffE1E1E1`) — [A/WaypointUI/Preload.lua:L30-44](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Preload.lua)
- All in-world art is white or greyscale and tinted at runtime: `Primitives/Box`, `Circle` and `Gradient-*` are pure #f8fcf8 alpha shapes, and `Waypoint.blp` (a 1024² atlas) is greyscale — [A/WaypointUI/Art/Primitives/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Art/Primitives/); SHEET: [wui_frames_primitives_stats.tsv](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/WaypointUI/wui_frames_primitives_stats.tsv)
- Settings: the selected tab has a gold rim #856d00 over a #36290f fill (sampled `TabButton.blp`). Widget containers are #3f3f3f and #323232. The common button atlas has red primary #a81719 and grey #313131. The divider is grey 142.5 at 24% alpha. Menu rows go from 125-grey at 0% to 25% (hover) and 17.5% (pressed); text is white at 75%, or 100% on hover — [A/WaypointUI/Art/Settings/TabButton.blp](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Art/Settings/TabButton.blp), [A/WaypointUI/packages/uic-common/src/selection-menu.lua:L27-32](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/packages/uic-common/src/selection-menu.lua), [A/WaypointUI/Code/Settings/Settings_UI.lua:L20](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Code/Settings/Settings_UI.lua)

### Inferences
- A shared "family" palette for KstyleUI could be:
  - Surface 0 (page) #0d0d0d at 80–92%.
  - Surface 1 (panel) #141414 to #1f1e21.
  - Surface 2 (raised or header) #2b2b2b to #34302d.
  - Bevel line #404040 (neutral) or #5c5953 (warm).
  - Text tiers #666666, #ababab, #ebebeb, with #ffffff only on hover.
  - A warm accent (#d7c0a3 text, #dfa63c to #9f4925 controls), a gold accent (#ffd100 glows, #856d00 rims), and a cool accent for selection (#0c69d8 or #60b6d8).
  - Success #7cc576 and danger #ff5050.
  - Quality: use the Narcissus and Plumber brightened set.
  All of these values are evidenced above; the grouping is my synthesis.
- WaypointUI's white-primitive approach (author art once in white, tint per context) is the most flexible base for a full UI suite that needs user-chosen accents.

### Gaps
- I did not sample every texture's colour; per-texture dominant colours are in the `_stats.tsv` files for everything in the sheets.
- In-game, rendered colours also depend on vertex colours, alpha and blend modes set at runtime, which static sampling cannot capture.

## Typography: which fonts ship, at what sizes, outlines and shadows, and under what licences?

### Takeaway
Narcissus is the typographic standout. It uses Source Sans Pro Semibold at small sizes (9–14 px) with a soft 0.6 px drop shadow instead of an outline, Semplicita Pro Semibold for "capped" headings, and wide letter-spacing (2) on tiny labels. DialogueUI uses a serif storybook stack (a bundled copy of Friz Quadrata at 8–18 px, plus Trajan Pro 3 for book titles). Plumber and WaypointUI mostly use Blizzard's own Friz Quadrata (`GameFontNormal`) with a 1 px shadow; Plumber adds Lato Bold for a 48 px clock. Only the OFL and Apache fonts (Source Sans Pro, Noto Sans, Open Sans, Junicode, Lato) are redistributable. Fremont, Semplicita Pro, Friz Quadrata, Arial Narrow and Trajan Pro are commercial.

### Cited Findings
- Narcissus base family `NarciFontNormal10` is SourceSansPro-Semibold at **11 px** (roman), with a shadow at offset (0.6, −0.6) in black. CJK uses NotoSansCJKsc-Medium at 10 px; Russian uses NotoSans-Medium — [A/Narcissus/Font/FontSettings.xml:L3-53](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Font/FontSettings.xml)
- Narcissus roman faces by family (from FontSettings.xml): Normal9 → SSP Semibold 10; Thin12 → SSP Regular 12; Medium9 → Semplicita Semibold 9; Medium12 → SSP Semibold 12; Capped12 and Capped16 → Semplicita Semibold 12 and 16; PlayerInfo → SSP Semibold 13; Medium24 → Semplicita Semibold 24; **MenuFont → SSP Semibold 14**; Fremont14/12/10/8 → Fremont; IndicatorTiny → SSP Semibold 9; numbers → SSP Semibold 12, 18 and 24 (with `outline="NORMAL"` variants). Font-file use counts: NotoSansCJKsc-Medium 69, SSP Semibold 23, NotoSans-Medium 21, Fremont 9, Semplicita 6 — [A/Narcissus/Font/FontSettings.xml](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Font/FontSettings.xml)
- Narcissus tiny UI labels use `spacing="2"` (tracking) with colours Pastel Brown #d9cdb4, NonInteractive #6b6b6b, DisabledButton #a6a6a6 and Pastel White #e0e0e0. `NarciRuneFont` is Junicode at 7 px — [A/Narcissus/Font/FontSettings.xml:L1092-1170](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Font/FontSettings.xml)
- DialogueUI families `DUIFontFamily_Serif_18/16/12/10/8` use its bundled `frizqt__.ttf` (Cyrillic: `frizqt___cyr.ttf`; Korean and Chinese fall back to the game's `Fonts\2002.TTF`, `ARKai_T`, `blei00d`). `DUIFontFamily_Trajan_18` is TrajanPro3SemiBold for book titles. `DUIFont_ItemCount` is ARIALN 10 px with an outline. Outlined variants exist at 12 and 10 px. Alert and chat fonts add a black shadow — [A/DialogueUI/Fonts.xml](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Fonts.xml)
- Plumber's settings panel uses `GameFontNormal` (Blizzard Friz) with its own colour table. `PlumberFont_Clock48` is Lato-Bold at 48 px with an outline, colour #ffd100. The shared family is FRIZQT 16 px with a (1, −1) black shadow — [A/Plumber/Modules/Shared/SharedFonts.xml:L1-70](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/Shared/SharedFonts.xml), [A/Plumber/Modules/ControlCenter/ControlCenter.xml](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/ControlCenter/ControlCenter.xml)
- WaypointUI creates `WUIFooterFont` (8 px) and `WUIPinpointFont` (10 px) from `GameFontNormal:GetFont()`, with a (1, −1) black shadow and no outline. Users can override the face through a `fontPath` setting, which triggers a full re-render — [A/WaypointUI/Fonts.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Fonts.lua), [A/WaypointUI/Code/Settings/Settings.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Code/Settings/Settings.lua)
- Font licences, read from each font's OpenType name table with fontTools (script `font_meta.py`) and from bundled licence files:
  - Source Sans Pro Regular, Semibold and Bold: SIL OFL 1.1, Adobe, Reserved Font Name "Source".
  - Noto Sans Regular and Medium: OFL 1.1, Google.
  - Open Sans Bold, BoldItalic, SemiBold and SemiBoldItalic: Apache 2.0.
  - Junicode: OFL 1.1, Peter S. Baker.
  - Lato Bold (Plumber): OFL 1.1, Reserved Font Name "Lato".
  - Fremont: "© SoftMaker Software GmbH", embedding flag fsType=4 (restricted). It ships next to `Fremont-License.txt`, which is the **Fontspring Desktop EULA**.
  - Semplicita Pro Semibold: "© 2011 Canada Type … All rights reserved".
  - DialogueUI fonts: Friz Quadrata TT "© 1997 ITC. All rights reserved", fsType=4; FrizQuadrataCTT "© ParaGraph … All Rights Reserved"; Arial Narrow, Monotype licence notice; Trajan Pro 3, copyright field "extracted by PdfGrabber".
  — [A/Narcissus/Font/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Font/), [A/Narcissus/Font/LICENSE_OFL.txt](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Font/LICENSE_OFL.txt), [A/Narcissus/Font/OpenSans-Apache License.txt](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Font/OpenSans-Apache%20License.txt), [A/Narcissus/Font/Fremont-License.txt](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Font/Fremont-License.txt), [A/DialogueUI/Fonts/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Fonts/), [A/Plumber/Fonts/Lato-Bold.ttf](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Fonts/Lato-Bold.ttf)
- DialogueUI's `Fonts/Log.txt` records that the authors edited Trajan Pro 3 (the 0xA0 no-break space was missing and was replaced with a standard space) — [A/DialogueUI/Fonts/Log.txt](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Fonts/Log.txt)

### Inferences
- For KstyleUI, the safe type stack that matches the family look is Source Sans Pro (or its successor Source Sans 3) Semibold for UI text and numerals, with Noto Sans and Noto Sans CJK for other locales. All are OFL, so KstyleUI can bundle its own copies obtained from the upstream foundries, not copied from Narcissus. The "Source" Reserved Font Name means a modified build must be renamed.
- Typographic recipe: 9–11 px labels, 12–14 px menus, 16 px headings and 18–24 px numerals. Use a soft (0.6, −0.6) black shadow instead of `OUTLINE` on dark surfaces. Reserve `OUTLINE` for text drawn over the 3D world or over busy art. Add tracking of 2 on all-caps micro-labels.
- For a display or heading face like Semplicita, choose an OFL alternative; this is a design decision, and no source here names one. For an optional serif "lore" mode, reference the game's own `Fonts\FRIZQT__.TTF` by path instead of bundling it.

### Gaps
- I did not read the name tables of the 16 MB Noto Sans CJK `.otf` files. Noto CJK is OFL upstream, but I did not verify this specific copy.
- Trajan Pro 3 has no licence metadata and an "extracted by PdfGrabber" provenance, so its legal status in DialogueUI is unclear. Treat it as non-redistributable.

## Surfaces and shapes: panel style, borders, corners, dividers, glows, shadows, masks, NineSlice, pixel-perfect lines

### Takeaway
None of the four addons draws flat 1 px boxes. Their panels are hand-authored textures with these traits:
- **45° chamfered corners**, not round ones, with chamfers of about 5–8 UI px.
- A **double-line bevel**: a dark outer line, a light hairline, then a dark inner line.
- A subtly textured or gradient fill: leather, noise, parchment or vignette.
- **Soft shadow corners that extend outside the frame**.

They are built with custom nine-slice and three-slice code (corner pieces centred on the frame's corners, at a 0.25/0.75 texture split) rather than Blizzard's `BackdropTemplate`. Masks (`MaskTexture`) carry much of the "premium" feel: hexagon item slots, brush-stroke reveals, JPG art with separate alpha masks, and soft circular masks.

### Cited Findings
- Corner geometry (measured with `corner.py` and verified visually in `corner_geometry_zoom.png`):
  - Narcissus `SettingsFrame/FrameBackground.tga`: the top row starts 15 texture px in and the diagonal starts 8 px in, which is a clean 45° chamfer. The texture is 2 px per UI unit, so the chamfer is about 7–8 UI px.
  - Plumber `NineSlice_GenericBox.tga`: chamfer about 7 px, with a light bevel line.
  - WaypointUI `Settings/Widget-Container.blp`: chamfer about 5 px.
  - Narcissus `NineSliceRectR6.tga` is the exception: a true small rounded corner, as its name says.
  — SHEET: [corner_geometry_zoom.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/corner_geometry_zoom.png); textures at [A/Narcissus/Art/SettingsFrame/FrameBackground.tga](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Art/SettingsFrame/FrameBackground.tga), [A/Plumber/Art/Frame/NineSlice_GenericBox.tga](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Art/Frame/NineSlice_GenericBox.tga), [A/WaypointUI/Art/Settings/Widget-Container.blp](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Art/Settings/Widget-Container.blp)
- Chamfer is a named, reusable shape across the family. Narcissus has `NineSliceChamfer8`, `GenericChamferedBorder`, `GenericChamferedBackground` and `ChamferedBevelBorderThick`. Plumber has `Art/BasicShape/Mask-Chamfer.tga` and an octagon `Mask-Hexagon.tga`. WaypointUI's in-world context plate (top-left of `Waypoint.blp`) and its `ItemSlot.blp` and `Mask-ItemSlot.blp` are octagonal — [A/Narcissus/Art/Frames/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Art/Frames/), [A/Plumber/Art/BasicShape/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Art/BasicShape/), [A/WaypointUI/Art/Shared/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Art/Shared/); SHEETs: [narci_frames_tooltip.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_frames_tooltip.png), [wui_atlases_large.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/WaypointUI/wui_atlases_large.png)
- Narcissus `NineSliceUtil.TextureData` is a registry of slice layouts: `rectR6` (corner 4), `shadowR6`, `shadowR12`, `shadowR0`, `shadowLargeR0`, `shadowHugeR0` (corners 8, 16 and 20, with `offsetRatio` 0.6667 so the shadows spill outward), `phantom` (24), `photoModePopup` (16), `chatBubbleBlack` and `chatBubbleWhite`, `settingsBackground` and `settingsBorder` (32, `pixelPerfect`, `useCenterForAlignment`), and `genericChamferedBorder` and `genericChamferedBackground`. Textures load with `"LINEAR"` filtering. `DisableSharpening` sets `SetTexelSnappingBias(0)` and `SetSnapToPixelGrid(false)` — [A/Narcissus/Widgets/NineSliceUtil.lua:L1-200](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Widgets/NineSliceUtil.lua)
- The Narcissus settings window stacks a background slice and a separate border slice (`NineSliceUtil.SetUp(f.BorderFrame, "settingsBorder")` and `(f.BackgroundFrame, "settingsBackground")`) — [A/Narcissus/SettingsFrame.lua:L1192-1193, L2140-2141](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.lua)
- In Plumber's `SliceFrameMixin`, nine-slice corner pieces are anchored by their **CENTER** to the frame's corners, so half of each corner sits outside the frame. The texture splits at 0.25/0.75, the default corner size is `16 * scale`, and there are helpers for `SetColor`, `SetDisableSharpening` and `CoverParent(paddingH, paddingV)` — [A/Plumber/Modules/Shared/SharedWidgets.lua:L124-260](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/Shared/SharedWidgets.lua)
- Pixel-perfect sizing: Narcissus computes one physical pixel as `768 / SCREEN_HEIGHT / effectiveScale`. `AddPixelPerfectTexture(frame, tex, pxW, pxH)` resizes registered lines when the frame is shown, and `SetFramePointPixelPerfect` snaps anchor offsets to whole pixels — [A/Narcissus/NarciDB/NarciAPI.lua:L2573-2632](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/NarciDB/NarciAPI.lua)
- Narcissus item slots are **opaque JPG colour art plus a separate alpha mask**. `SetBorderTexture` loads `Art/ItemBorder-Dark/JPG/<Quality>.jpg` and attaches a `MaskTexture` from `Art/ItemBorder-Dark/Mask/<Shape>.tga` with `CLAMPTOBLACKADDITIVE`. Masks include RegularHeavy, RegularSolid, Heart, Runeforge and a set of named variants — [A/Narcissus/Widgets/ItemBorder.lua:L6-102](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Widgets/ItemBorder.lua); SHEET: [narci_itemborder_jpg_masks.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_itemborder_jpg_masks.png)
- Glows and shadows as textures: Narcissus has `HexagonHighlight.tga` (a white hexagon with a wide soft glow), `DropShadow.tga`, `Shadow-Inner-Thin.tga`, `NineSliceShadowR*`, `Circle-InnerShadow-8.tga`, and `Vignetting-Left`, `-Right` and `-Circular` (256² soft black gradients). Plumber has `ThreeSliceFrameGlowDispersive.tga`, `SubtitleShadow_NineSlice.tga`, `NameplateTextShadow.tga` and `GenericTextDropShadow.tga`. Text sits on a blurred black pill to stay legible over the world — [A/Narcissus/Art/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Art/), [A/Plumber/Art/Frame/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Art/Frame/); SHEETs: [narci_shapes_masks.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_shapes_masks.png), [plumber_frame.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Plumber/plumber_frame.png)
- Dividers are textures, never 1 px colour lines. Narcissus uses `Tooltip/Divider.tga` and `SettingsFrame/DividerVertical.tga`. Plumber's `Divider_Gradient_Horizontal.tga` has a bright centre fading to transparent ends; it also has `Divider_DropShadow_Vertical.tga` and builds dividers from the settings atlas (`CreateDivider`, 24 px tall, texcoords 416–672 × 16–64). DialogueUI uses `Settings-Divider-H` and `-V` per theme — [A/Plumber/Modules/ControlCenter/SettingsPanelNew.lua (CreateDivider)](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/ControlCenter/SettingsPanelNew.lua); SHEET: [plumber_frame.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Plumber/plumber_frame.png)
- DialogueUI surfaces are painted: parchment with burnt edges (1024×2048 atlas), torn-edge felt option plates, and brush-stroke masks (`BrushFrame-Mask-TopLeft` and `-BottomRight`, `QuestPopup-Brush-Mask`). Faint watermark emblems (`ParchmentDecor/*`: Alliance, Horde, Dalaran, TWW-*) are tinted #ad7241 at 80% with BLEND on Brown, and grey 0.2 with ADD on Dark — [A/DialogueUI/Art/Theme_Shared/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Art/Theme_Shared/), [A/DialogueUI/Code/Settings/Settings.lua:L198-253](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Settings/Settings.lua); SHEET: [dui_shared_parchment_book.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/DialogueUI/dui_shared_parchment_book.png)
- Plumber's settings atlas packs controls into one 1024² sheet, addressed by texcoords in code (`SetTexCoord(obj, x1/1024, …)`). It holds bronze-bevelled chamfered inputs, amber and rust filter buttons, a leather sidebar, and a copper-framed preview box with orange corner accents. `SkinObjects` recursively applies the sheet, with `TRILINEAR` filtering for objects that are scaled — [A/Plumber/Modules/ControlCenter/SettingsPanelNew.lua (SkinObjects, SetTexCoord)](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/ControlCenter/SettingsPanelNew.lua); SHEET: [plumber_settings_atlases.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Plumber/plumber_settings_atlases.png)
- WaypointUI's in-world waypoint is a vertical light beam: a soft white streak in `Waypoint.blp`, revealed by a radial `Mask-Beam` that scales from 1 to 50, plus a scrolling `Mask-BeamFX` band. It sits under a diamond marker and an octagonal context plate. The diamond is the brand motif (logo, map pin) — [A/WaypointUI/Art/Waypoint/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Art/Waypoint/), [A/WaypointUI/Code/Waypoint/Waypoint.lua:L257-312](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Code/Waypoint/Waypoint.lua); SHEET: [wui_atlases_large.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/WaypointUI/wui_atlases_large.png)
- Usage counts across the code (`grep`). Narcissus: 102 `<MaskTexture>` in XML and 93 ADD blends. Plumber: 21 XML masks, 10 `CreateMaskTexture` and 75 ADD blends. DialogueUI: 7 masks and 11 ADD blends. Blizzard `BackdropTemplate` or `SetBackdrop` appears 8× in Narcissus, 0× in Plumber and DialogueUI, and 4× in WaypointUI — [A/Narcissus](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/), [A/Plumber](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/), [A/DialogueUI](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/), [A/WaypointUI](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/)

### Inferences
- KstyleUI shape language should be:
  - Panels: 45° chamfer of 6–8 px, never round.
  - Small chips and tooltips: a 3–4 px chamfer, or the R6 rounded corner for organic elements.
  - Borders: a double-line bevel (outer #000 at about 60%, hairline #404040 or #5c5953, inner shadow).
  - Fill: #141414 to #1f1e21 at 80–92%, with a very faint vertical gradient or noise.
  - Shadows: soft, extending 8–20 px outside via centre-anchored corner slices.
  - Item and icon slots: masked hexagons or octagons.
- Ship greyscale and white slice art and colour it with `SetVertexColor` (WaypointUI's approach). Keep heavy colour art as JPG plus a mask (Narcissus's approach) to save texture memory.

### Gaps
- I did not measure the exact UI-unit chamfer for every slice. It depends on the cornerSize-to-texcoord ratio set in code for each layout.
- WaypointUI's `ui-kit` renderer (`src/renderer/src/processes/background.lua`) handles slicing internally; I did not read its implementation line by line.

## Motion: animation systems, easing functions, durations, fade, slide and scale patterns, hover and press feedback, open and close

### Takeaway
The Peterodox addons (Narcissus, Plumber, DialogueUI) ship one identical Penner-style easing module: `linear`, `outSine`, `inOutSine`, `outQuart`, `outQuint`, `inQuad`, with the signature `(t, b, e, d)`. They drive most motion through hand-written `OnUpdate` tweens (568, 594 and 264 `SetScript("OnUpdate")` calls). XML AnimationGroups cover fire-and-forget effects. WaypointUI has its own chainable tween engine, `UIAnim.Animate():property():easing():duration():from():to()`, with 33 easings and a single pooled `OnUpdate`. Typical durations are 0.15–0.25 s for hover and fade, 0.35–0.5 s for panels and content, and 0.8 s for large cinematic slides. Panels open with a short fade plus an 8–24 px rise and a 2 px overshoot, and close fast or instantly.

### Cited Findings
- The shared easing implementations are identical in Narcissus (credited as derived from LibEasing and Penner's BSD equations), Plumber and DialogueUI. DialogueUI adds `none` and `noChange` — [A/Narcissus/API/Easing.lua:L44-69](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/API/Easing.lua), [A/Plumber/API.lua:L1601-1642](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/API.lua), [A/DialogueUI/API.lua:L901-950](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/API.lua)
  - `outSine(t,b,e,d) = (e-b)*sin(t/d*π/2)+b`
  - `inOutSine = -(e-b)/2*(cos(π*t/d)-1)+b`
  - `outQuart: t=t/d-1; (b-e)*(t^4-1)+b`
  - `outQuint: t=t/d; (b-e)*((1-t)^5-1)+b`
- WaypointUI `UIAnim_Easing` takes normalised `f(t)` and provides Linear; Sine, Quad, Cubic, Quart, Quint, Expo, Circ, Back, Elastic and Bounce in In, Out and InOut forms; and SmoothStep and SmootherStep. The engine uses `MIN_TICK = 1/60`, pools instances (up to 100), and runs one `OnUpdate` frame that removes itself when idle. Properties are Alpha, Width, Height, PosX, PosY, Scale and Rotation; looping is Reset or Yoyo — [A/WaypointUI/packages/ui-anim/src/easing.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/packages/ui-anim/src/easing.lua), [A/WaypointUI/packages/ui-anim/src/enum.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/packages/ui-anim/src/enum.lua), [A/WaypointUI/packages/ui-anim/src/engine.lua:L17-75](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/packages/ui-anim/src/engine.lua)
- Duration statistics (`grep` of XML `duration=` and Lua `:duration()`):
  - Narcissus XML (282 AnimationGroups): 0.2 s ×95, 0.25 ×85, 0.5 ×67, 0.15 ×65, 0.1 ×51, 1 ×46. Smoothing OUT ×81, IN_OUT ×37, IN ×3.
  - Plumber XML: 0.5 ×16, 0.25 ×14, 0.2 ×7. Smoothing IN ×14, OUT ×13.
  - DialogueUI: 0.25 s ×18.
  - WaypointUI `:duration`: 0.5 ×14, 0.175 ×8, 0.375 ×7. Easings Linear ×27, QuartInOut ×6, ExpoOut ×4, ExpoIn ×3.
  — [A/Narcissus](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/), [A/Plumber](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/), [A/DialogueUI](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/), [A/WaypointUI](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/)
- Narcissus settings window opening (`FlyIn`): alpha 0→1 over 0.25 s; a Translation snaps the frame to −24 px; then a Path (`curve="SMOOTH"`, 0.4 s) moves it through +26 to +24, a 2 px overshoot and settle. Closing is an instant `Hide()` — [A/Narcissus/SettingsFrame.xml:L592-600](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.xml), [A/Narcissus/SettingsFrame.lua:L2346-2385](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.lua)
- Narcissus character-sheet entrance: left and right vignettes slide 100 px over 0.8 s with OUT smoothing at alpha 0.5. Side lines slide in from `toX − 120` with `outSine` over `DURATION_TRANSLATION = 0.8` (0.4 in the faster mode). `UIParent` fades out at rate 2 per second (0.5 s), throttled to 0.08 s updates "to mitigate the impact on FPS" — [A/Narcissus/Narcissus.xml:L811-870](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Narcissus.xml), [A/Narcissus/Main.lua:L19, L336-402](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Main.lua), [A/Narcissus/API/UIParentFade.lua:L13-15](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/API/UIParentFade.lua)
- `NarciFadeUI.Fade(frame, duration, toAlpha)` is one shared driver. Duration is proportional to the remaining alpha distance (`fullDuration * |alpha − toAlpha|`), so interrupted fades never jump. It can auto-hide at alpha 0 — [A/Narcissus/NarciDB/FadeFrame.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/NarciDB/FadeFrame.lua)
- Hover nudge (DialogueUI and Plumber loot): on hover, button content slides **8 px** right with `outQuart` over **0.25 s** and slides back the same way on leave. Pressing moves the content **1 px** down (`pushOffsetY = -1`) — [A/DialogueUI/Code/Dialogue/UITemplates.lua:L39-44, L296-357](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Dialogue/UITemplates.lua), [A/Plumber/Modules/LootUI/ItemFrame.lua:L22-64](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/LootUI/ItemFrame.lua)
- Plumber loot list: rows fade in at `alpha += 8*elapsed` (0.125 s), staggered by `n*0.1 + 0.25` s. Looted rows slide right at 128 px/s while fading at `5*elapsed` (0.2 s) — [A/Plumber/Modules/LootUI/MainFrame.lua:L548-640, L1021](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/LootUI/MainFrame.lua), [A/Plumber/Modules/LootUI/ItemFrame.lua:L50-64](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/LootUI/ItemFrame.lua)
- DialogueUI content refresh: `FadeFrame(ContentFrame, 0.35, 1, 0)` plus the `IG_QUEST_LIST_OPEN` sound. A sheen sweeps across reward choices: after a 0.25 s delay, it fades in over 0.2 s, translates +140 px over 0.6 s (OUT), and fades out over 0.45 s after 0.1 s. An attention pulse scales 0.9 (0.75 s) then 1.11 (0.25 s, OUT), twice. A hint arrow slides +10 px over 1.0 s (OUT) — [A/DialogueUI/Code/Dialogue/DialogueUI.lua:L1046-1053](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Dialogue/DialogueUI.lua), [A/DialogueUI/Code/Dialogue/DialogueUI.xml:L275-278](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Dialogue/DialogueUI.xml), [A/DialogueUI/Code/Widget/WidgetManager.xml:L60-63, L189](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Widget/WidgetManager.xml)
- WaypointUI waypoint: fades over 0.175 s (Linear). The intro is a 1 s alpha fade, the context icon scaling 2.25→1 (ExpoIn, 0.5 s), and the beam mask scaling 1→50 (ExpoIn, 0.5 s, 0.175 s delay). The outro is a 0.25 s fade with the beam mask scaling back. Hover uses QuartInOut. Pinpoint intro: PosY −57.5→0 (ExpoInOut, 1 s). Prompt: alpha 0.325 s plus PosY −15→0 with **ElasticOut** over 1.25 s; outro QuintInOut 0.375 s. Dropdown menu: ExpoOut 0.5 s, 7 px rise. Text caret blinks with a 0.1 s Yoyo and a 0.5 s hold — [A/WaypointUI/Code/Waypoint/Waypoint.lua:L246-312, L480-493](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Code/Waypoint/Waypoint.lua), [A/WaypointUI/packages/uic-common/src/prompt.lua:L126-134](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/packages/uic-common/src/prompt.lua), [A/WaypointUI/packages/uic-common/src/selection-menu.lua:L205-206, L355-364](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/packages/uic-common/src/selection-menu.lua), [A/WaypointUI/packages/uic-common/src/input.lua:L71](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/packages/uic-common/src/input.lua)
- Narcissus collapsible settings sidebar: width animates with `inOutSine` over 0.5 s — [A/Narcissus/SettingsFrame.lua:L2414-2440](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.lua)

### Inferences
- A KstyleUI motion token set grounded in these numbers:

  | Token | Duration | Easing | Use |
  |---|---|---|---|
  | `fast` | 0.15 s | linear | alpha |
  | `hover` | 0.20–0.25 s | outQuart | 8 px content nudge |
  | `press` | instant | none | 1 px down |
  | `panelIn` | 0.25 s alpha + 0.4 s rise | outQuart or smooth path | 24 px rise with 2 px overshoot |
  | `panelOut` | 0.15 s | linear | fade, or instant |
  | `content` | 0.35 s | linear | fade |
  | `list` | 0.125 s per item | linear | 0.1 s stagger |
  | `cinematic` | 0.8 s | outSine | large slides |
  | `attention` | 0.6 s | out | sheen sweep with a 0.25 s delay |

- Use one module-level driver (WaypointUI-style pooled engine, or Narcissus's `FadeFrame`) instead of one `OnUpdate` per widget. Use distance-proportional durations so reversals feel natural.

### Gaps
- I did not catalogue every AnimationGroup in Narcissus (282 of them); the statistics above summarise them.
- I could not observe the live feel of any animation, because nothing was run in-game.

## Interaction polish: hover states, tooltips, sounds, keyboard and gamepad, scroll behaviour, empty states

### Takeaway
Polish comes from small, consistent rules:
- Hover brightens text one tier and slides content 8 px.
- One shared highlight frame is re-parented to the hovered row and faded in.
- Tooltips use 8 px padding with 2 px line spacing and 4 px paragraph spacing.
- Scrolling is smoothed (an exponential approach), with a rubber-band bounce at the ends.
- Sounds are few, soft and contextual, mostly stock SOUNDKIT checkbox sounds plus bespoke paper sounds in DialogueUI.
- Keyboard and gamepad are first-class in DialogueUI, Narcissus (a GamePad module) and WaypointUI (an input-handler package).

### Cited Findings
- Shared moving highlight: Plumber's `MainFrame:HighlightButton(button)` re-parents one `CategoryHighlight` to the hovered button and fades it in at `alpha += 5*elapsed` (0.2 s). DialogueUI's `SetParentHighlightTexture` does the same for option buttons, switching texture and blend mode per option type — [A/Plumber/Modules/ControlCenter/SettingsPanelNew.lua:L795-933](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/ControlCenter/SettingsPanelNew.lua), [A/DialogueUI/Code/Dialogue/UITemplates.lua:L847-870](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Dialogue/UITemplates.lua)
- Narcissus settings hover sets label and border to tier 3 (#ebebeb); leave restores tier 2 (#ababab). Child options of a disabled parent dim to alpha 0.25 and are disabled — [A/Narcissus/SettingsFrame.lua:L150-190](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.lua)
- Tooltips:
  - Narcissus: `TOOLTIP_PADDING = 8`, `SPACING_NEW_LINE = 4`, `SPACING_INTERNAL = 2`, background `Tooltip/TooltipDefaultDarkLayout`, fade object via `NarciFadeUI`. Coin icons are inline `|T` atlas slices.
  - Plumber: same padding (8) on a `Tooltip_Brown` nine-slice.
  — [A/Narcissus/Widgets/UIFrameTooltip.lua:L21-78, L345-352](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Widgets/UIFrameTooltip.lua), [A/Plumber/Modules/Shared/SharedTooltip.lua:L39-63](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/Shared/SharedTooltip.lua)
- Smooth scroll (Narcissus `NarciAPI.CreateSmoothScroll`): each frame moves `max(|value−target| * speed * elapsed*60, minOffset)`, with `SetSpeedMultiplier(0.14)`, a step of half the view height, Shift for acceleration, and optional drag-swipe. Hitting either end plays a 0.4 s Path bounce through −6, +2 and 0 px. DialogueUI's equivalent uses `SCROLL_BLEND_SPEED = 0.15` — [A/Narcissus/NarciDB/ScrollFrame.lua:L1-60, L380-473](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/NarciDB/ScrollFrame.lua), [A/DialogueUI/Code/Scroll/Scroll_EasySmooth.lua:L7](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Scroll/Scroll_EasySmooth.lua)
- Sounds (counted with `grep`):
  - Narcissus: `IG_MAINMENU_OPTION_CHECKBOX_ON` and `_OFF` (6× each), `IG_MAINMENU_OPEN` and `_CLOSE`, `ACHIEVEMENT_MENU_CLOSE`, `UI_TRANSMOG_ITEM_CLICK`.
  - Plumber: checkbox on and off, `UI_EXPANSION_LANDING_PAGE_OPEN` and `_CLOSE`, the `UI_CLASS_TALENT_*` family.
  - WaypointUI: routes through a `Sound.PlaySound(layer, id)` wrapper with layers "UI" and "Main", and uses `UI_MAP_WAYPOINT_*` kits plus `U_CHAT_SCROLL_BUTTON` or `SCROLLBAR_STEP` for range and scroll ticks.
  - DialogueUI: ships `paper-collect-1.mp3` (option click), `paper-collect-2.mp3` (option enter) and `page-turn-1.mp3` (quest text) behind a name→file table, and briefly mutes target-lost and UI open/close sounds during NPC interaction.
  — [A/DialogueUI/Code/Sound.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Sound.lua), [A/WaypointUI/packages/uic-common/src/range.lua:L91](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/packages/uic-common/src/range.lua), [A/WaypointUI/Code/Waypoint/Waypoint.lua:L1001-1014](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Code/Waypoint/Waypoint.lua)
- WaypointUI remaps three sound kits to bundled `.ogg` files (89712 → `SPELL_PR_Artifact_LightsWrath_Cast_05.ogg`, 17318 → `LFG_DungeonReady.ogg`, 13827 → `Glyph_MajorCreate.ogg`); the filenames match Blizzard game sounds — [A/WaypointUI/Preload.lua:L48-50](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Preload.lua), [A/WaypointUI/Sound/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Sound/)
- Keyboard and gamepad:
  - DialogueUI maps PAD1 to confirm, PAD2 to cancel and PAD4 to alt; the D-pad to up and down; PADMENU and PADFORWARD to settings. It toggles `SetPropagateKeyboardInput` so unhandled keys reach the game. It uses Tab to cycle rewards, has a "SwipeEmulator", and ships Xbox, PlayStation and Switch glyph sets (`PS-PAD*`, `XBOX-PAD*`, `SWITCH-PAD*`) per theme.
  - Narcissus settings has an opt-in `GAMEPAD_ENABLED` path (`OnGamePadButtonDown`).
  - WaypointUI has an `input-handler` package (`EnableGamePadButton`, capture).
  — [A/DialogueUI/Code/Dialogue/KeyboardControl.lua:L11-13, L150-360](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Dialogue/KeyboardControl.lua), [A/Narcissus/SettingsFrame.lua:L3027-3104](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.lua), [A/WaypointUI/packages/input-handler/src/handler.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/packages/input-handler/src/handler.lua); SHEET: [dui_theme_dark.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/DialogueUI/dui_theme_dark.png)
- Empty state: Plumber's search menu uses `SetNoContentAlert(L["Search No Matches"])`, which reuses Blizzard's localised `CLUB_FINDER_APPLICANT_LIST_NO_MATCHING_SPECS` string — [A/Plumber/Modules/ExpansionLandingPage/TrackerTab.lua:L932](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/ExpansionLandingPage/TrackerTab.lua), [A/Plumber/Locales/enUS.lua:L733](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Locales/enUS.lua)
- New-feature markers: Narcissus `NewFeatureDiamond.png` (cyan #16e8ed diamond) and Plumber `NewFeatureTag` (a blue-white sparkle, with a large or small-dot variant) sit to the left of setting labels — [A/Narcissus/SettingsFrame.lua:L1590](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.lua), [A/Plumber/Modules/ControlCenter/SettingsPanelNew.lua (CreateNewFeatureMark)](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/ControlCenter/SettingsPanelNew.lua)

### Inferences
- KstyleUI should adopt these rules:
  - A single shared highlight per list.
  - Three text tiers with hover = +1 tier.
  - 8 px tooltip padding with 2/4 px line rhythm.
  - Smooth scroll at a 0.14–0.15 blend with a rubber-band at the ends.
  - At most one sound per meaningful action, routed through a wrapper with a master toggle.
  - Gamepad glyph sets, with key propagation handled.

### Gaps
- I found few explicit empty-state designs beyond Plumber's "No Matches" alert; the other addons rarely have empty lists.
- I did not audit focus rings or the keyboard tab order in the settings UIs.

## Architecture: how each addon organises its UI code, and which files and functions to emulate

### Takeaway
Peterodox's addons (Narcissus, Plumber, DialogueUI) use an imperative "mixin + factory + texture atlas" style:
- Module-local `Def` and `Schematic` tables hold layout constants.
- `CreateXxx(parent)` factories return frames mixed with a `XxxMixin`.
- Atlases are addressed by texcoords.
- `ThemeUtil` swaps texture paths, and named Font objects are recoloured.
- UI is built lazily on first open.

AdaptiveX's WaypointUI uses a declarative component framework. Packages include `ui-kit` (builder-chained props, Percentage, Fill and Fit sizing, layout stacks, an element-id registry), `react` (observable variables), `ui-anim`, `uic-common` and `module-registry`, wired through `env.modules:New/Import/Await`.

### Cited Findings
- Plumber widget factories, all `addon.CreateXxx`: `CreateNineSliceFrame` (L246), `CreateThreeSliceFrame` (L259), `CreateCheckbox` (L472), `CreateCategoryDivider` (L573), `CreateHeaderFrame` (L620), `CreateCommonFrame` (L687), `CreateExpandCollapseButton` (L729), `CreateMoneyDisplay` (L1056), `CreateTimerFrame` (L2446), `CreateTinyStatusBar` (L2552), `CreateRedButton` (L2806), `CreateMetalProgressBar` (L3070), `CreateTextDropShadow` (L3172), `CreateHotkeyIcon` (L3262), `CreateArc` (L3585), `CreateSlider` (L4502), `CreateDropdownFrame` (L4651), `CreateUIPanelButton` (L4757), `CreateKeybindButton` (L4932), `CreateRadialProgressBar` (L5071) — [A/Plumber/Modules/Shared/SharedWidgets.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/Shared/SharedWidgets.lua)
- The Plumber settings panel is driven by a `Def` constants table (`ButtonSize = 28`, `WidgetGap = 14`, `PageHeight = 576`, `CategoryGap = 40`, `TabButtonHeight = 40`, colour tokens). `CreateUI()` runs once on the first `ShowUI` and is then set to nil (lazy build). There is a module registry in `SettingsPanelRegistry.lua` — [A/Plumber/Modules/ControlCenter/SettingsPanelNew.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/ControlCenter/SettingsPanelNew.lua), [A/Plumber/Modules/ControlCenter/SettingsPanelRegistry.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/ControlCenter/SettingsPanelRegistry.lua)
- DialogueUI theme architecture: `ThemeUtil:SetThemeByID(1|2)` swaps `TEXTURE_PATH` between `Art/Theme_Brown/` and `Art/Theme_Dark/`. These folders contain identically named files (59 each). It recolours every Font object listed in `FONT_OBJECT_COLOR`, calls `LoadTheme()` on registered UIs, and fires the `ThemeChanged` callback. `DUIGenericTitledFrameMixin:SetTheme` and the per-UI `LoadTheme` re-skin widget pools with `ProcessAllObjects` — [A/DialogueUI/Code/Utility/ThemeUtil.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Utility/ThemeUtil.lua), [A/DialogueUI/Code/SharedUITemplates/GenericFrame.lua:L22-77](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/SharedUITemplates/GenericFrame.lua), [A/DialogueUI/Code/Settings/Settings.lua:L198-253](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Settings/Settings.lua)
- DialogueUI layout: a `Schematic` table maps child paths (for example `"FrontFrame.Header"`) to size, anchor and offset, scaled by `FRAME_SIZE_MULTIPLIER`. `CalculateBestFrameHeight()` sets the frame height to **0.618 × viewport height** — [A/DialogueUI/Code/Dialogue/DialogueUI.lua (lines ~98-125)](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Dialogue/DialogueUI.lua)
- Narcissus utility layer: `NarciAPI.NineSliceUtil` (`SetUp`, `SetUpBackdrop`, `SetUpBorder`, `SetBackdropColor`, `TileFrame`, `CreateNineSlice`), `NarciAPI.AddPixelPerfectTexture`, `NarciAPI.CreateSmoothScroll`, `NarciFadeUI.Fade` and `addon.EasingFunctions` — [A/Narcissus/Widgets/NineSliceUtil.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Widgets/NineSliceUtil.lua), [A/Narcissus/NarciDB/NarciAPI.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/NarciDB/NarciAPI.lua), [A/Narcissus/NarciDB/ScrollFrame.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/NarciDB/ScrollFrame.lua), [A/Narcissus/NarciDB/FadeFrame.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/NarciDB/FadeFrame.lua)
- WaypointUI package set: `callback-registry`, `cvar-util`, `generic-enum` (1,403 lines of Blizzard colour enums), `input-handler`, `lazy-timer`, `module-registry`, `pool`, `react`, `saved-variables`, `slash-command`, `sound`, `struct`, `ui-anim` (1,258 lines), `ui-font`, `ui-kit` (34 files, 5,655 lines), `uic-common` (button, check-button, color-input, input, prompt, range, scroll-bar, selection-menu, binding-button) and `uic-sharedmixin`. A `React.New(default)` variable has `:Set`, `:Get` and `:OnChange` — [A/WaypointUI/packages/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/packages/), [A/WaypointUI/packages/react/index.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/packages/react/index.lua)
- WaypointUI declarative UI example: `Frame(name, { children })` with chained `:id()`, `:point()`, `:size(UIKit.Define.Percentage{value=100, operator="-", delta=75})`, `:background(UIDEF.Divider)`, `:backgroundColor(Color_RGBA{…})`, `LayoutVertical(...):layoutSpacing(3)`, `:_Render()`, and `UIKit.GetElementById(id, scope)`. `ui-kit` primitives are frame, hit-rect, input, layout-grid, layout-horizontal, layout-vertical, lazy-scroll-container, linear-slider, list, model-scene, scroll-bar, scroll-container(-edge), secure-button and text — [A/WaypointUI/Code/Settings/Settings_UI.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Code/Settings/Settings_UI.lua), [A/WaypointUI/packages/ui-kit/src/primitives/public/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/packages/ui-kit/src/primitives/public/)
- WaypointUI texture definitions are data: `UIKit.Define.Texture_Atlas{ path, inset, sliceMode }` is called with `{left, top, right, bottom, scale}`, and `Texture_NineSlice{ path, inset = 14, scale = 0.5, sliceMode = Stretched }` — [A/WaypointUI/Code/Settings/Settings_Preload.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Code/Settings/Settings_Preload.lua)

### Inferences
- For a full UI suite (many frames, user-configurable), KstyleUI benefits from WaypointUI's ideas: declarative layout, observable settings that re-render, pooled animation, and data-defined texture atlases. From Peterodox it should take the pragmatic helpers: easing table, proportional fade, smooth scroll, pixel-perfect helper, centre-anchored nine-slice with 0.25/0.75 coordinates, shared highlight, and lazy `CreateUI`. Write this architecture from scratch; do not copy code (see Licensing).
- A theme should be a table of {texture-path root, colour tokens, Font-object colour map}, with a `ThemeChanged` callback, as DialogueUI does. This allows "Dark", "Warm" and "Zone-tinted" variants.

### Gaps
- I did not trace WaypointUI's renderer (`ui-kit/src/renderer/*`) or its tag manager in depth. Its performance characteristics are unknown.

## Settings UIs: how each addon's own settings panel looks and works

### Takeaway
All four have bespoke settings UIs rather than plain Blizzard widgets. Common layout: a left category rail (180–260 px), a scrolling centre column, and (in Plumber and Narcissus) a right-hand **live preview** image or description pane. Common features: search, new-feature badges, changelog or credits, and smooth scroll. Plumber uses golden-ratio proportions with a warm leather-and-bronze skin. Narcissus uses a minimal near-black chamfered panel with grey text tiers. WaypointUI embeds a dark, Blizzard-modern-styled panel inside the native Settings window. DialogueUI themes its settings to match parchment or dark.

### Cited Findings
- **Plumber "Control Center"**:
  - Size: `PageHeight = 576`; width = `576/0.85` split as side rails `(1−0.618)` and a centre column `0.618`, giving about 259 + 419 + 259 = 937 × 576.
  - Components: search box plus a 28 px square filter button at the top of the left rail (`WidgetGap = 14`); category buttons 28 px tall; centre entries `centralSectionWidth − 2×28` wide; a feature-preview image in the right rail (`ShowFeaturePreview`); tab buttons 40 px tall (modules or changelog).
  - Can minimise to a 256×64 "Return to module list" plate framed with the `ExpansionBorder_TWW` slice.
  - Can run standalone or embedded in Blizzard settings (`mode = "blizzard"`).
  — [A/Plumber/Modules/ControlCenter/SettingsPanelNew.lua:L1120-1310, L2150-2253](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/ControlCenter/SettingsPanelNew.lua); SHEET: [plumber_settings_atlases.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Plumber/plumber_settings_atlases.png)
- **Narcissus settings**:
  - Size: default 720 × 450; left category column 180 px, collapsible with an `inOutSine` 0.5 s width animation; content max width 394; padding H18 and V12; `WIDGET_GAP = 16`; category offset 64.
  - Look: chamfered #141414 body with a #404040 bevel border (nine-slice pair).
  - Content: preview images per option (`Preview-*.png`: tooltip, paper-doll widget, quest-card theme, translation on nameplate or tooltip), Website-CurseForge and Wago buttons, a credits list, and a key-binding capture field.
  - Behaviour: smooth scroll, `ScrollToWidget`; FlyIn animation; anchors either centred or into Blizzard Interface Options.
  — [A/Narcissus/SettingsFrame.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.lua), [A/Narcissus/SettingsFrame.xml](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.xml); SHEET: [narci_settings.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_settings.png)
- Narcissus settings controls: checkbox and radio art with three states in one strip (`Checkbox.tga`, `Radio.tga`); a slider with a diamond thumb and node ticks (`Slider.tga`, `Thumb.tga`); a keybinding three-slice; a reset button with an IN_OUT rotation; an "open new window" arrow — [A/Narcissus/SettingsFrame.lua:L200-216, L643-663, L2614-2620, L2889-2897](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.lua)
- **WaypointUI settings**:
  - Hosting: registered with `Settings.RegisterCanvasLayoutCategory(anchor, NAME)` so it lives inside Blizzard's Settings window. It is sized to the canvas plus an 8 px inset (ElvUI-aware) and built on first show.
  - Layout: a 212 px sidebar of tabs with a footer area; a 2 px divider at 24% alpha; content is `100% − 212` wide.
  - Schema: declarative `Settings_Schema.SCHEMA` entries with `widgetType`, `key`, `set`, `disableWhen`, `showWhen`, `indent` and `children`. Widget types are Title, Container, Text, Range, Button, CheckButton, SelectionMenu, ColorInput and Input. Descriptions can carry images.
  - Theming: tabs use a gold-rimmed `TabButton` atlas at scale 0.6; widgets sit on chamfered `Widget-Container` panels.
  — [A/WaypointUI/Code/Settings/Settings.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Code/Settings/Settings.lua), [A/WaypointUI/Code/Settings/Settings_Schema.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Code/Settings/Settings_Schema.lua), [A/WaypointUI/Code/Settings/Settings_UI.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Code/Settings/Settings_UI.lua), [A/WaypointUI/Code/Settings/Settings_Preload.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Code/Settings/Settings_Preload.lua)
- **DialogueUI settings**: themed with per-theme atlases (`Settings-Divider-H` and `-V`, `Settings-PreviewBorder`, `Settings-TabButton-Selection`, `Settings-ButtonHighlight`, `Settings-CloseButton`, `Settings-Checkbox`, `Settings-ArrowOption`, `Settings-Keybinding`), with a Dalaran watermark decor. Widgets are pooled (checkbox, arrow-option, keybinding, hotkey). The UI shows gamepad device glyphs — [A/DialogueUI/Code/Settings/Settings.lua:L198-260](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Settings/Settings.lua); SHEETs: [dui_theme_dark.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/DialogueUI/dui_theme_dark.png), [dui_theme_brown.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/DialogueUI/dui_theme_brown.png)

### Inferences
- A KstyleUI config UI should combine:
  - A standalone, movable panel that also registers into Blizzard Settings (Narcissus, Plumber and WaypointUI all support embedding).
  - A search box plus filter button on the left rail.
  - Schema-driven option definitions with `showWhen` and `disableWhen` (WaypointUI).
  - Live preview images or descriptions on the right (Plumber and Narcissus).
  - New-feature badges and a changelog tab.
  - Golden-ratio column proportions.
  - Lazy construction.

### Gaps
- I did not see these panels rendered in-game. Exact pixel layouts at different UI scales are inferred from code constants.

## Licensing: may their textures, fonts or code be reused, redistributed, or only referenced?

### Takeaway
The four addons are licensed differently, and none of the installed copies includes a top-level LICENSE file:
- **Narcissus**: artwork CC BY-NC-SA 4.0, source code MPL 2.0.
- **Plumber**: GPLv3 on CurseForge.
- **WaypointUI**: GPLv3 on CurseForge, but the GitHub repo shows no LICENSE file.
- **DialogueUI**: All Rights Reserved.

All of them bundle third-party assets (Blizzard art and sounds, commercial fonts) that their licences cannot cover. Given the brief's constraint, KstyleUI should **reference and re-create, not copy**.

### Cited Findings
- Narcissus licence page: "The artworks within Narcissus addon is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License" and "The source code of Narcissus is licensed under the Mozilla Public License 2.0" — [CurseForge: Narcissus licence](https://www.curseforge.com/wow/addons/narcissus/license). The GitHub repository lists MPL-2.0 — [GitHub: Peterodox/Narcissus](https://github.com/Peterodox/Narcissus). The project page shows "Custom License", project ID 311718, by Peterodox with contributor Raenore — [CurseForge: Narcissus](https://www.curseforge.com/wow/addons/narcissus)
- Plumber is listed as "GNU General Public License version 3 (GPLv3)", with source at github.com/Peterodox/Plumber — [CurseForge: Plumber](https://www.curseforge.com/wow/addons/plumber), [CurseForge: Plumber licence](https://www.curseforge.com/wow/addons/plumber/license)
- DialogueUI: "All Rights Reserved unless otherwise explicitly stated", project ID 989270, with source at github.com/Peterodox/YUI-Dialogue — [CurseForge: DialogueUI licence](https://www.curseforge.com/wow/addons/dialogueui/license), [CurseForge: DialogueUI](https://www.curseforge.com/wow/addons/dialogueui)
- WaypointUI (Waypoint UI) is listed as GPLv3, project ID 1275146, by AdaptiveX, with source at github.com/Adaptvx/Waypoint-UI — [CurseForge: WaypointUI](https://www.curseforge.com/wow/addons/waypointui). The GitHub page showed no LICENSE file and no licence in the About sidebar (the file listing was truncated) — [GitHub: Adaptvx/Waypoint-UI](https://github.com/Adaptvx/Waypoint-UI)
- Installed copies: a `find` for `*licen*`, `readme*`, `*.md` and `*.txt` found only the Narcissus font licences (`LICENSE_OFL.txt`, `OpenSans-Apache License.txt`, `Fremont-License.txt`), `Art/Modules/TalentTree/ClassBackground/Readme.txt` and DialogueUI notes. No addon has a top-level LICENSE — [A/Narcissus/Font/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Font/)
- Bundled third-party content:
  - DialogueUI's `Art/GameAssets/Manifest.txt` says "This folder contains only Blizzard Assets" — [A/DialogueUI/Art/GameAssets/Manifest.txt](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Art/GameAssets/Manifest.txt)
  - WaypointUI bundles `.ogg` files named after Blizzard sound files — [A/WaypointUI/Sound/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/WaypointUI/Sound/)
  - Font licences are listed in the Typography section (Fremont: Fontspring Desktop EULA; Semplicita: Canada Type, all rights reserved; Friz, Arial Narrow and Trajan: commercial).
- The Narcissus easing file reproduces Robert Penner's BSD licence notice ("Open source under the BSD License") — [A/Narcissus/API/Easing.lua:L1-30](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/API/Easing.lua)

### Inferences
These are general licence readings, not legal advice.
- Narcissus art (CC BY-NC-SA) could be reused only with attribution, non-commercially, and with KstyleUI's derived art under the same licence.
- Narcissus code (MPL 2.0) is file-level copyleft: copied files would stay MPL, and the rest of KstyleUI could use a different licence.
- Plumber and WaypointUI (GPLv3) would make KstyleUI GPLv3 if their code or art were incorporated.
- DialogueUI cannot be reused at all.
- Blizzard assets and the commercial fonts (Fremont, Semplicita, Friz, Arial Narrow, Trajan) must not be redistributed by KstyleUI in any case. Game fonts and textures can be referenced by their in-game paths without shipping them.
- Penner's easing equations are BSD-licensed and widely re-implemented. KstyleUI can write its own implementation of these standard formulas, citing Penner.
- Recommended stance (matches the brief): describe and reproduce the *look* with original art. Bundle only OFL or Apache fonts obtained from upstream.

### Gaps
- I did not read the full LICENSE file text in the Narcissus or Plumber GitHub repos (WebFetch returned only the labels). I also did not check the licence of github.com/Peterodox/YUI-Dialogue.
- WaypointUI's licensing is inconsistent (GPLv3 on CurseForge, no visible LICENSE on GitHub). Treat it as unclear.

## What concretely makes these feel "10/10" compared with typical flat WoW UI suites?

### Takeaway
They feel premium because every surface is designed rather than generated: chamfered and bevelled art, soft outward shadows, masked shapes, and texture or gradient fills. Motion is short, eased and interruptible. The type system is tuned, with semi-bold sans at small sizes, soft shadows and tiered greys. Details recur deliberately: the shared hover highlight, the 8 px hover nudge, the 1 px press, the rubber-band scroll, sheens, contextual colour, gamepad glyphs and live previews in settings. A flat suite uses 1 px solid borders, a uniform #1a1a1a fill, outlined pixel fonts and no motion. The difference is in depth, curvature, light and time.

### Cited Findings
- Depth and light are textures, not code-drawn lines: soft corner shadows (`NineSliceShadowR*`), inner shadows, vignettes, ADD-blend glows and sheens. Narcissus alone uses 93 ADD blends and 102 XML masks — [A/Narcissus/Art/Frames/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Art/Frames/), [A/Narcissus/Art/Vignetting/](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Art/Vignetting/); SHEET: [narci_shapes_masks.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_shapes_masks.png)
- Shape identity recurs per addon: the Narcissus hexagon (item borders in nine quality and themed variants, hexagon masks and highlights), the WaypointUI diamond (logo, pin, beam tip), and Plumber's chamfered bronze plates and metal hexagon three-slices (`ThreeSlice_Metal_Hexagon*.tga`) — SHEETs: [narci_borders_buttons.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Narcissus/narci_borders_buttons.png), [wui_icons.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/WaypointUI/wui_icons.png), [plumber_frame.png](file:///private/tmp/claude-501/-Users-lee/1c722721-459a-44d5-9d89-4921154ab7a5/scratchpad/art_audit/Plumber/plumber_frame.png)
- Context-aware colour: Narcissus tints chrome by zone (`MapColors`), and DialogueUI swaps whole themes and rewrites inline text colours for contrast — [A/Narcissus/NarciDB/Color.lua:L171-352](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/NarciDB/Color.lua), [A/DialogueUI/Code/Utility/ThemeUtil.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Utility/ThemeUtil.lua)
- Proportion is considered: DialogueUI sets frame height to 0.618 of the viewport, and Plumber's centre column takes 0.618 of the width — [A/DialogueUI/Code/Dialogue/DialogueUI.lua](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Dialogue/DialogueUI.lua), [A/Plumber/Modules/ControlCenter/SettingsPanelNew.lua:L1121-1128](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Plumber/Modules/ControlCenter/SettingsPanelNew.lua)
- Crispness is engineered: pixel-size math (`768/SCREEN_HEIGHT/scale`), `SetSnapToPixelGrid(false)` and `SetTexelSnappingBias(0)` on scaled art, and TRILINEAR filtering for scaled icons — [A/Narcissus/NarciDB/NarciAPI.lua:L2573-2632](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/NarciDB/NarciAPI.lua), [A/Narcissus/Widgets/NineSliceUtil.lua:L7-10](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/Widgets/NineSliceUtil.lua)
- Motion is everywhere but brief and interruptible (see Motion). Examples are the 0.25 s FlyIn with a 2 px overshoot, the 0.25 s outQuart hover nudge, the 0.4 s rubber-band and 0.1 s staggers — [A/Narcissus/SettingsFrame.xml:L592-600](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/SettingsFrame.xml), [A/DialogueUI/Code/Dialogue/UITemplates.lua:L39-44](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/DialogueUI/Code/Dialogue/UITemplates.lua), [A/Narcissus/NarciDB/ScrollFrame.lua:L437-470](file:///Applications/World%20of%20Warcraft/_forever_/Interface/AddOns/Narcissus/NarciDB/ScrollFrame.lua)

### Inferences
- **KstyleUI style DNA (synthesised from the evidence above; reproduce with original assets):**
  1. *Palette*:
     - Surfaces #0d0d0d (80%), #141414 and #1f1e21 (80–92%).
     - Raised surfaces #2b2b2b to #34302d. Bevel hairline #404040 (cool) or #5c5953 (warm).
     - Text #666666, #ababab, #ebebeb, and #fff on hover. Warm label #d7c0a3.
     - Accent gold #ffd100 (glow) and #856d00 (rim). Copper #dfa63c to #9f4925. Selection blue #0c69d8.
     - Success #7cc576, danger #ff5050.
     - Quality: Narcissus-bright set (Rare #699eff, Epic #b953ff).
  2. *Type*: Source Sans 3 Semibold. 11 px body, 14 px menu, 16 px headings, 18–24 px numerals. Shadow (0.6, −0.6) black, no outline on panels. Tracking of 2 on caps micro-labels. Noto Sans and Noto CJK fallbacks.
  3. *Shape*: 45° chamfer of 6–8 px on panels and 3–4 px on chips. Double-line bevel. Soft outer shadow 8–20 px via centre-anchored corner slices (0.25/0.75 texcoord split). One signature motif for slots and markers; choose something other than the Narcissus hexagon or the WaypointUI diamond to avoid looking derivative.
  4. *Light*: ADD-blend glows and sheens (0.6 s sweep), vignettes for full-screen modes, gradient-faded dividers.
  5. *Motion tokens*: see the Motion section table. Use a single pooled tween driver with distance-proportional durations.
  6. *Interaction*:
     - A shared highlight per list.
     - Hover +1 text tier.
     - 8 px tooltip padding with 2/4 px line rhythm.
     - Smooth scroll at a 0.14 blend with a rubber-band.
     - Sparse SOUNDKIT feedback (checkbox on and off, open and close).
     - Gamepad glyphs and key propagation.
  7. *Settings*: search plus filter, category rail, schema-driven options with `showWhen` and `disableWhen`, live preview pane, new-feature badges, changelog, lazy build, and both standalone and Blizzard-Settings hosting.
  8. *Theming*: theme = {texture root, colour tokens, Font-object colour map}, with a `ThemeChanged` callback. Ship greyscale art tinted by tokens, and optionally offer a zone-reactive accent.
- No source here measures ElvUI. The contrast with "ElvUI-style flat boxes" (1 px borders, solid fills, outlined fonts, little motion) is my characterisation of common practice, not a sourced finding.

### Gaps
- No in-game screenshots were captured, so "feel" judgements rely on the art, the code constants and the contact sheets.
- I made no direct comparison against ElvUI's own source or textures.
