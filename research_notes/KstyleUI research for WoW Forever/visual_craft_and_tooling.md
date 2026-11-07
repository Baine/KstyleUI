# Visual craft, asset pipeline and developer tooling for a premium WoW Forever UI addon (Mac, 2026-11)

Research date: 2026-11-06. Scope: the Forever client only (product `wowf`, TOC Interface 16001, client build 1.60.1.70840).

How to read the sources:
- **Primary local evidence** (read-only inspection of `/Applications/World of Warcraft/_forever_`) is cited as `local:` with a path.
- **Blizzard's own UI source for this exact build.** Gethe/wow-ui-source has a `forever` branch whose head commit is titled "1.60.1 (70840)" (2026-11-06). That is the same build as the installed client. Blizzard's generated API docs and XML schema in that branch are the strongest source in these notes. The links below point at the `forever` branch.
- **warcraft.wiki.gg pages** are community-maintained and say their API section is under "extended maintenance". Some pages are thin or have copy errors (noted where seen).
- **Third-party "WoW Forever guide" sites** are new, partly speculative and sometimes conflict. They are used only where nothing better exists, and are flagged.

---

## 0. What the Forever client is, and where it differs from Retail

### Takeaway
Forever is a Mainline (Retail-architecture) client. Internally it is called "Camelot": it has its own project ID (`WOW_PROJECT_CAMELOT = 18`), its own TOC game type (`camelot`) and its own UI-source branch. It ships the 12.x widget API, including the secret-value machinery. So build against the Retail 12.x API, but gate Forever-specific code with `[AllowLoadGameType camelot]` and expect some Retail systems to be missing.

### Cited Findings
- The installed client logs itself as "World of Warcraft Retail ARM64 1.60.1.70840" and runs on Metal ("Metal Device Create Successful", `GxApi "MTL"`) on an Apple M5 Max — local: `_forever_/Logs/gx.log`, `_forever_/WTF/Config.wtf`.
- `.build.info` lists Product `wowf`, Version `1.60.1.70840`. The `.flavor.info` file says `wowf` — local: `/Applications/World of Warcraft/.build.info`, `_forever_/.flavor.info`.
- Blizzard's Forever UI source defines `WOW_PROJECT_CAMELOT = 18; WOW_PROJECT_ID = WOW_PROJECT_CAMELOT;`, alongside `WOW_PROJECT_MAINLINE = 1` and `WOW_PROJECT_CLASSIC = 2` — [Blizzard_ProjectConstants/Camelot/ProjectConstants.lua (forever branch)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ProjectConstants/Camelot/ProjectConstants.lua)
- TOC game types listed by the wiki are `standard, forever, camelot, mists, cata, wrath, tbc, vanilla, plunderstorm, wowhack`. The `mainline` family covers standard, forever, camelot, plunderstorm and wowhack. The Interface value for Forever is `16001`, and Retail is `120105` (test `120107`) — [warcraft.wiki.gg TOC format](https://warcraft.wiki.gg/wiki/TOC_format)
- Real Forever-compatible addons gate files with game-type conditions:
  - BugSack: `forever.lua [ExcludeLoadGameType standard, classic][AllowLoadGameType camelot]`, and that file sets `addonTable.isForever = true`.
  - Plumber: `## X-GameType: Camelot [AllowLoadGameType camelot]` and per-module conditions.
  - local: `_forever_/Interface/AddOns/BugSack/BugSack.toc`, `.../BugSack/forever.lua`, `.../Plumber/Plumber.toc`
- The installed addons declare multi-client Interface lines that include 16001:
  - DialogueUI: `120107, 120105, 50504, 20506, 11509, 16001`
  - Narcissus: `120105, 16001`
  - BugSack/BugGrabber: a list including `16001` and `120107`
  - local: the respective `.toc` files
- A third-party guide reports that Blizzard said Forever shares Mainline's UI architecture including "the vast majority of APIs available in 12.1.5". The same guide reports secret values on Forever (for example player `UnitHealth`), `CombatLogGetCurrentEventInfo` being unavailable, and `WOW_PROJECT_ID` returning 18 on beta build 70338. It warns many claims are "reported/unverified" — [wowforeverguides.com developer guide (updated 2026-10-13)](https://wowforeverguides.com/addons/developers)
- The Forever API docs carry 12.x secret-value annotations on texture methods. For example `SetSVG` has `SecretArguments = "AllowedWhenTainted"`, and `SetSpriteSheetCell` arguments are marked `ConditionalSecret` / `NeverSecret` — [SimpleTextureBaseAPIDocumentation.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleTextureBaseAPIDocumentation.lua)
- oUF's changelog includes Forever-specific fixes, which shows real Retail/Forever divergences: "stagger: Stock bar doesn't exist in Forever", "blizzard: Fix pvp sound in Forever", "Only load for Retail and Forever" — [oUF releases](https://github.com/oUF-wow/oUF/releases)
- The AddOns folder is `_forever_/Interface/AddOns`. Beta-era guides pointed at `_classic_beta_`, and the installed launcher still has a `_classic_beta_` folder too — local: `/Applications/World of Warcraft/`; conflicting guide path in [wowforeverguides.com](https://wowforeverguides.com/addons/developers)
- The client has Edit Mode and the Cooldown Manager. It writes `Logs/EditMode.log`, `WTF/Account/.../edit-mode-cache-account.txt` and a per-character `cooldownmanager.txt` — local: `_forever_/Logs`, `_forever_/WTF`

### Inferences
- Detect Forever with TOC conditions (`[AllowLoadGameType camelot]`) or `WOW_PROJECT_ID == WOW_PROJECT_CAMELOT`. Don't use the interface number. The BigWigs packager README uses the same TOC pattern (see section 8).
- Any visual that depends on combat numbers (health text, aura timers) must go through secret-safe paths (`StatusBar:SetValue`, `Cooldown:SetCooldownFromDurationObject`, curves). Purely decorative rendering (textures, masks, animations, fonts) is unaffected.

### Gaps
- No official Blizzard developer document lists Forever-vs-Retail API differences. Diff the `forever` and `live` branches of wow-ui-source for a precise list.

---

## 1. Textures: formats, constraints, filtering, atlases, sheets

### Takeaway
Addons can load BLP, JPEG, PNG and TGA. Dimensions must be powers of two. PNG paths must include the `.png` extension. `SetTexture` and `SetAtlas` take a filter mode (`LINEAR` by default, `TRILINEAR`, `NEAREST`). Addons cannot register real atlases: there is no registration API. Use one power-of-two sheet plus a Lua table of texcoords, `SetSpriteSheetCell`, or the native texture-slice (9-slice) API.

### Cited Findings
- Formats and constraints:
  - "Custom images must be in BLP, JPEG, PNG, or TGA format with power-of-two dimensions (e.g. 16x16, 8x32, 256x64)."
  - TGA can be "8bpp grayscale, 24bpp RGB, or 32 bpp RGBA; RLE is supported".
  - "PNG files must explicitly include the '.png' extension".
  - PNG support was added in 10.0.7 (2023-03-21).
  - Since 9.0.1, new files under `Interface/AddOns` need only a `/reload`, not a client restart.
  - `filterMode` was added in 8.0.1.
  - Source: [warcraft.wiki.gg TextureBase:SetTexture](https://warcraft.wiki.gg/wiki/API_TextureBase_SetTexture)
- `SetTexture([textureAsset [, wrapModeHorizontal [, wrapModeVertical [, filterMode]]]])`:
  - Wrap modes are `CLAMP` (default), `CLAMPTOWHITE`, `CLAMPTOBLACK`, `CLAMPTOBLACKADDITIVE`, `REPEAT` and `MIRROR`.
  - Wrap modes apply only when `SetHorizTile`/`SetVertTile` tiling is on.
  - Filter modes are `LINEAR` (default, bilinear), `TRILINEAR` ("also sampling mipmaps") and `NEAREST`.
  - Textures load asynchronously, and `GetSize()` returns 0,0 until loaded.
  - The return value "always appears to return true", so it cannot detect a bad path.
  - Source: [warcraft.wiki.gg SetTexture](https://warcraft.wiki.gg/wiki/API_TextureBase_SetTexture)
- On the Forever build, `SetAtlas` takes `(atlas, useAtlasSize=false, filterMode, resetTexCoords, wrapModeHorizontal, wrapModeVertical)` — [SimpleTextureBaseAPIDocumentation.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleTextureBaseAPIDocumentation.lua)
- The `C_Texture` namespace on Forever exposes only atlas getters: `GetAtlasInfo`, `GetAtlasExists`, `GetAtlasID`, `GetAtlasElementID`, `GetAtlasElements`, plus `GetFilenameFromFileDataID`, title-icon and URL-texture functions. There is no atlas registration function — [TextureUtilsDocumentation.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/TextureUtilsDocumentation.lua)
- Sprite sheets and slicing on the Forever build:
  - `SetSpriteSheetCell(cell, numRows, numColumns [, cellWidth, cellHeight])`
  - `SetTextureSliceMargins(left, top, right, bottom)` and `SetTextureSliceMode(mode)`, with `Enum.UITextureSliceMode` = `Stretched (0)` / `Tiled (1)`. This is native 9-slice on a single texture.
  - `SetTexCoord(left, right, top, bottom)`
  - Sources: [SimpleTextureBaseAPIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleTextureBaseAPIDocumentation.lua), [UITextureConstantsDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/UITextureConstantsDocumentation.lua)
- **SVG.** `TextureBase:SetSVG(svgAsset)` and `ClearSVG()` exist in the Forever API. The argument type is `FileAsset`. No Blizzard UI code in the branch calls `SetSVG` — [SimpleTextureBaseAPIDocumentation.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleTextureBaseAPIDocumentation.lua); the wiki lists it without a description — [warcraft.wiki.gg UIOBJECT Texture](https://warcraft.wiki.gg/wiki/UIOBJECT_Texture)
- Plumber, which supports Forever, ships PNGs referenced with the extension, for example `Interface/AddOns/Plumber/Art/Frame/QueueStatusEye.png`. The sampled files are power-of-two RGBA: 256², 512² and 1024². Across the installed addons there are 748 BLP, 964 TGA, 306 PNG and 1428 JPG files — local: `_forever_/Interface/AddOns/Plumber/Modules/QueueStatus.lua`, `sips` on `Plumber/Art/...`
- Plumber and Narcissus turn off pixel snapping on art textures: `texture:SetTexelSnappingBias(0); texture:SetSnapToPixelGrid(false)` — local: grep of `_forever_/Interface/AddOns/{Plumber,Narcissus}`

### Inferences
- Use PNG (RGBA, straight alpha, power of two) as the default art format. It is the simplest pipeline and is proven on Forever by Plumber. Convert to BLP (DXT5 + mipmaps) only if VRAM or size matters, or if you minify art heavily and want `TRILINEAR`.
- A "custom atlas" is a Lua table such as `Atlas["panel-corner"] = {file, w, h, l, r, t, b}` plus a helper that calls `SetTexture(file)` and `SetTexCoord(...)`. Pack sheets at 1024 or 2048 with 2–4 px transparent padding between cells, so bilinear filtering doesn't bleed neighbouring cells.
- Use `NEAREST` only for deliberately pixel-art or 1:1 hairline textures. Use `LINEAR` for anything scaled or animated.
- `SetSVG` could give resolution-independent icons and borders on Retina, but it is undocumented and unused by Blizzard. Treat it as experimental until tested in-game.

### Gaps
- Maximum texture dimension is not documented. 1024² is proven locally, and 2048/4096 are commonly assumed, but I found no source.
- Whether PNG/TGA get automatic mipmaps (which matters for `TRILINEAR`) is undocumented.
- Whether non-power-of-two images are now accepted on 12.x/Forever: the wiki still says power-of-two. I did not test NPOT.
- `SetSVG`: the supported SVG subset, whether addon-path `.svg` files load, and the rasterisation resolution are all unknown. This needs an in-game test.

---

## 2. Premium visual techniques

### Takeaway
The Forever widget API has everything needed for a crisp, modern look:
- Mask textures for circles and rounded shapes.
- `SetGradient` with `ColorMixin` colours.
- Five blend modes.
- Desaturation.
- Per-texture pixel-snapping control.
- Native 9-slice (`SetTextureSliceMargins`) and `NineSliceUtil` layouts.
- Radial progress bars with feathered edges.
- Vertex offsets for skewed shapes.
- A highly customisable Cooldown swipe.

There is no blur or backdrop-filter. "Frosted glass" must be faked with pre-blurred or noise textures and translucent gradients.

### Cited Findings
- Mask API: `AddMaskTexture(mask)`, `RemoveMaskTexture`, `GetMaskTexture(index)`, `GetNumMaskTextures`, `SetMask(file)` — [warcraft.wiki.gg UIOBJECT Texture](https://warcraft.wiki.gg/wiki/UIOBJECT_Texture)
- Blizzard's own masks in the Forever source:
  - `Interface\CharacterFrame\TempPortraitAlphaMask` (circle), declared as `<MaskTexture file="Interface\CharacterFrame\TempPortraitAlphaMask" hWrapMode="CLAMPTOBLACKADDITIVE" vWrapMode="CLAMPTOBLACKADDITIVE">`.
  - Atlas masks `SquareMask`, `TransparentSquareMask` and `UI-HUD-ActionBar-IconFrame-Mask`.
  - Source: grep of [wow-ui-source forever branch](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns)
- Plumber builds masks in Lua with `frame:CreateMaskTexture(nil, "ARTWORK")` then `icon:AddMaskTexture(mask)` — local: `_forever_/Interface/AddOns/Plumber` (grep)
- `SetGradient(orientation, minColor, maxColor)` takes `colorRGBA` objects with `Mixin = "ColorMixin"`, so pass `CreateColor(r,g,b,a)`. Raw numbers are not accepted — [SimpleTextureBaseAPIDocumentation.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleTextureBaseAPIDocumentation.lua)
- The blend modes (`ALPHAMODE` in the UI schema) are `DISABLE`, `BLEND`, `ALPHAKEY`, `ADD` and `MOD` — [UI.xsd (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_SharedXML/UI.xsd)
- Desaturation: `SetDesaturated([bool])` and `SetDesaturation(0..1)` — [warcraft.wiki.gg UIOBJECT Texture](https://warcraft.wiki.gg/wiki/UIOBJECT_Texture)
- Pixel snapping:
  - `SetSnapToPixelGrid(snap)` defaults to `false` in the Forever docs. `SetTexelSnappingBias(bias)` takes a `normalizedValue` (0–1).
  - Blizzard's `NineSliceUtil.DisableSharpening(container)` sets `piece:SetTexelSnappingBias(0); piece:SetSnapToPixelGrid(false)` on every piece. Tooltips call it in `SharedTooltip_OnLoad`.
  - Sources: [SimpleTextureBaseAPIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleTextureBaseAPIDocumentation.lua), [NineSlice.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_SharedXML/NineSlice.lua), [SharedTooltipTemplates.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_SharedXML/SharedTooltipTemplates.lua)
  - A wiki comment says a bias above zero implies snapping is on, and that a higher bias picks a single texel instead of blending neighbours (sharper) — [warcraft.wiki.gg SetTexelSnappingBias](https://warcraft.wiki.gg/wiki/API:TextureBase_SetTexelSnappingBias), [SetSnapToPixelGrid](https://warcraft.wiki.gg/wiki/API:TextureBase_SetSnapToPixelGrid)
- `/texelvis` (`/tvis`) opens a `TexelSnappingVisualizer`, but it is registered only `if IsGMClient()`. Addon authors can't use it — [SlashCommands.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ChatFrameBase/Shared/SlashCommands.lua)
- NineSlice: `NineSliceUtil.ApplyLayout(container, userLayout, textureKit)`, `ApplyLayoutByName`, `GetLayout`, `AddLayout(layoutName, layout)`, `ApplyUniqueCornersLayout`, `ApplyIdenticalCornersLayout`, `DisableSharpening` and `UpdateCornerCropping`. `Backdrop.lua` is also present (BackdropTemplate) — [NineSlice.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_SharedXML/NineSlice.lua)
- Radial progress on any texture:
  - `SetRadialProgressBarPercent`, `...Reverse`, `...StartOffset`, `...EndOffset` and `...Feather`, described as "Sets the feather/blur amount applied to the radial progress bar edge (higher = more gradual falloff)".
  - There is a matching `RadialProgress` animation type with `SetFromPercent` / `SetToPercent`.
  - Sources: [SimpleTextureBaseAPIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleTextureBaseAPIDocumentation.lua), [SimpleAnimRadialProgressAPIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleAnimRadialProgressAPIDocumentation.lua)
- Vertex offsets: `SetVertexOffset(vertexIndex, offsetX, offsetY)` and `ClearVertexOffsets()` move individual quad corners, which gives skewed or parallelogram shapes. `SetRotation(radians [, normalizedRotationPoint])` is also available — [warcraft.wiki.gg UIOBJECT Texture](https://warcraft.wiki.gg/wiki/UIOBJECT_Texture)
- Cooldown frame methods on Forever:
  - `SetSwipeTexture`, `SetSwipeColor`, `SetEdgeTexture`, `SetEdgeColor`, `SetEdgeScale`, `SetUseCircularEdge`, `SetBlingTexture`, `SetDrawBling`, `SetDrawEdge`, `SetDrawSwipe`, `SetReverse`, `SetRotation`, `SetTexCoordRange`, `SetCountdownFont`, `SetCountdownFormatter`, `SetHideCountdownNumbers`.
  - Secret-aware setters: `SetCooldownFromDurationObject`, `SetCooldownFromExpirationTime`, `SetCooldownUNIX`, `SetUseAuraDisplayTime`.
  - Source: [FrameAPICooldownDocumentation.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/FrameAPICooldownDocumentation.lua)
- 3D accents: Forever ships API docs for ModelScene frames and actors, CharacterModelBase, DressUpModel, TabardModel and SimpleModel / ModelFFX — [Blizzard_APIDocumentationGenerated (forever)](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated)
- The only "blur" in the Forever API docs is the radial-progress feather (plus a CooldownViewer constant). There is no general blur, backdrop-filter or shader API for addons — grep of [Blizzard_APIDocumentationGenerated (forever)](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated)
- LibCustomGlow (MIT) is the common library for button glows, pixel glows and autocast shine. Its master TOC lists `## Interface: 120001, 120000` — [LibCustomGlow repo](https://github.com/Stanzilla/LibCustomGlow), [TOC](https://raw.githubusercontent.com/Stanzilla/LibCustomGlow/master/LibCustomGlow-1.0.toc)

### Inferences
- **Crisp 1px lines and hairlines.**
  1. Use `SetColorTexture`, or a white 8×8 texture tinted with `SetVertexColor`.
  2. Size and position it with `PixelUtil.SetSize` / `PixelUtil.SetPoint` (section 4).
  3. Call `SetSnapToPixelGrid(false)` and `SetTexelSnappingBias(0)` on art that must not be "sharpened". That is Blizzard's `DisableSharpening` pattern.
  4. Alternatively, for 1px rules, keep snapping on and make sure the size is a whole number of physical pixels.
  - Test both on Retina, because snapping behaviour differs by effective scale.
- **Rounded panels.** Either use a 9-slice of an anti-aliased rounded-rect PNG (`SetTextureSliceMargins` + `Stretched`), or put a rounded-rect `MaskTexture` over a gradient texture. Masks clip children textures only on that texture, so put the mask on each layer that needs it.
- **Glows and drop shadows.** Use pre-rendered soft-edge PNGs: a 64×64 or 128×128 radial or edge falloff, 9-sliced around the frame, with `ADD` blend for glows and `BLEND` with black vertex colour for shadows. Animate with Alpha or Scale animations rather than regenerating anything.
- **Frosted glass.**
  1. Lay a dark translucent gradient (`SetGradient` with alpha in `CreateColor`).
  2. Add a very low-alpha tiled noise texture (`SetHorizTile`/`SetVertTile` + `REPEAT`).
  3. Add a 1px top highlight line and an inner-glow 9-slice.
  - True background blur is not possible.
- **Animated ring meters.** Radial progress plus feather replaces the old "two half-circle textures + masks" trick.
- **Cooldowns.** For a premium style, set a custom swipe texture with `SetUseCircularEdge(true)` and a custom edge texture.
- LibCustomGlow does not list 16001 in its TOC. That is harmless when embedded, but test it on Forever before relying on it, or hand-roll glows with FlipBook / Alpha animations.

### Gaps
- No primary source on mask-channel semantics: whether masks use the alpha channel or luminance, and whether mask textures must be power-of-two. Blizzard's mask files suggest alpha masks, but this is unconfirmed.
- No source on the performance cost of many masks or radial textures on Metal.
- ModelScene usage specifics (camera, actors) for Forever were not researched in depth.

---

## 3. Animation

### Takeaway
Prefer engine-driven AnimationGroups, which run in C. Forever supports Alpha, Translation, TranslationLine, Scale, ScaleLine, Rotation, Path (with control points), FlipBook, VertexColor, TextureCoordTranslation and RadialProgress. Smoothing is `NONE`/`IN`/`OUT`/`IN_OUT`/`OUT_IN`, and looping is `NONE`/`REPEAT`/`BOUNCE`. Use `OnUpdate` tweens only for things AnimationGroups can't express, such as eased width or value changes, and make them allocation-free.

### Cited Findings
- Animation type docs present in the Forever build: `SimpleAnimAlpha`, `SimpleAnimTranslation`, `SimpleAnimTranslationLine`, `SimpleAnimScale`, `SimpleAnimScaleLine`, `SimpleAnimRotation`, `SimpleAnimPath`, `SimpleAnimFlipBook`, `SimpleAnimVertexColor`, `SimpleAnimTextureCoordTranslation`, `SimpleAnimRadialProgress` — [Blizzard_APIDocumentationGenerated (forever)](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated)
- Enum values in the schema:
  - `ANIMSMOOTHTYPE`: `NONE, IN, OUT, IN_OUT, OUT_IN`
  - `ANIMLOOPTYPE`: `NONE, REPEAT, BOUNCE`
  - `ANIMCURVETYPE` (Path): `NONE, SMOOTH`
  - Source: [UI.xsd (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_SharedXML/UI.xsd)
- Animation base methods: `SetDuration`, `SetStartDelay`, `SetEndDelay`, `SetOrder`, `SetSmoothing(weights: SmoothingType)`, `SetSmoothProgress`, `SetTarget`/`SetTargetKey`/`SetChildKey`, `Play`/`Pause`/`Stop`/`Restart`.
- AnimationGroup methods: `CreateAnimation`, `SetLooping`, `GetLoopState`, `SetToFinalAlpha`, `SetAnimationSpeedMultiplier`, `Finish`, `IsPendingFinish`, `IsReverse`, `SetPlaying`.
- Sources: [SimpleAnimAPIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleAnimAPIDocumentation.lua), [SimpleAnimGroupAPIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleAnimGroupAPIDocumentation.lua). The wiki's Animation page has copy errors in descriptions, for example `SetSmoothProgress` described as "Sets the smoothing type" — [warcraft.wiki.gg UIOBJECT Animation](https://warcraft.wiki.gg/wiki/UIOBJECT_Animation)
- FlipBook: `SetFlipBookRows`, `SetFlipBookColumns`, `SetFlipBookFrames`, `SetFlipBookFrameWidth`, `SetFlipBookFrameHeight` — [SimpleAnimFlipBookAPIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleAnimFlipBookAPIDocumentation.lua)
- `FontString:SetScaleAnimationMode(mode)` takes `Enum.FontStringScaleAnimationMode`:
  - `FontSize` (0): "small jumps between different font heights…"
  - `Vertex` (1): "Scaling is smoother, but if used on non-slug fonts may cause significant pixelation of the font text"
  - Sources: [UISharedDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/UISharedDocumentation.lua), [SimpleFontStringAPIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleFontStringAPIDocumentation.lua)
- Curve objects:
  - `C_CurveUtil.CreateCurve()` and `CreateColorCurve()` return objects with `AddPoint`, `SetPoints`, `Evaluate`, and so on.
  - `Enum.LuaCurveType` is `Linear`, `Step`, `Cosine` ("cosine smoothing") and `Cubic` ("requires a minimum of four points").
  - Sources: [CurveUtilDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/CurveUtilDocumentation.lua), [LuaCurveObjectConstantsDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/LuaCurveObjectConstantsDocumentation.lua), [LuaCurveObjectAPIDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/LuaCurveObjectAPIDocumentation.lua)

### Inferences
- Use Translation + Alpha with `OUT` smoothing for panel entrances. Use `IN_OUT` for loops. Use `BOUNCE` loops with an Alpha animation for "breathing" glows. Use `SetToFinalAlpha(true)` so a fade-out stays hidden.
- To scale-animate text, use a slug-flagged font plus `SetScaleAnimationMode(Enum.FontStringScaleAnimationMode.Vertex)`.
- **Custom easing in `OnUpdate`:**
  - Precompute the easing as a pure function, such as cubic-bezier or `outQuint`.
  - Keep per-tween state in a reused table, not a new closure per frame.
  - Unregister `OnUpdate` (`SetScript("OnUpdate", nil)`) when finished.
  - Never build strings or tables per frame.
  - `C_CurveUtil` curves (`Cubic`) can be authored once and `Evaluate(t)`'d as data-driven easing curves. Their 12.x purpose is likely secret-value mapping, which is unverified.
- Throttle non-visual updates (text refresh) to around 10–20 Hz with an elapsed accumulator. Let AnimationGroups do per-frame visual work.

### Gaps
- No measured performance data (CPU ms per AnimationGroup vs `OnUpdate`) for 12.x/Forever. Profile in-game with `/etrace` and the addon CPU profiler.
- No primary source on what `SetSmoothProgress` does exactly.

---

## 4. Pixel-perfect scaling (including Mac Retina)

### Takeaway
1 UI unit equals 1 physical pixel when the effective scale is `768 / physicalHeight`. Blizzard's own `PixelUtil` uses exactly `768.0 / select(2, GetPhysicalScreenSize())`. The settings slider only allows a uiScale of 0.65–1.15. Any display taller than about 1181 physical px therefore needs a scale below the slider minimum. That includes 1440p (0.533), 4K (0.356) and this Mac's 3456×2234 backbuffer (0.344). So set the scale on your own root frame, or on `UIParent`, from code. Snap sizes and offsets with `PixelUtil`.

### Cited Findings
- `PixelUtil.GetPixelToUIUnitFactor()` returns `768.0 / physicalHeight`, where the height comes from `GetPhysicalScreenSize()`.
- `PixelUtil.GetNearestPixelSize(uiUnitSize, layoutScale, minPixels)` rounds to whole physical pixels.
- Helpers include `PixelUtil.SetWidth`, `SetHeight`, `SetSize`, `SetPoint(... minOffsetXPixels, minOffsetYPixels)`, `ConvertPixelsToUI`, `ConvertPixelsToUIForRegion` and `SetRoundLayoutToNearestPixelRecursively(frame, enabled)`.
- Source: [PixelUtil.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_SharedXML/PixelUtil.lua)
- Blizzard's UI Scale slider: `local minValue, maxValue, step = .65, 1.15, .01;` on the `uiscale` CVar, gated by `useUiScale` — [Graphics.lua settings (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_SettingsDefinitions_Shared/Graphics.lua)
- What the wiki says about scale:
  - The screen is 768 units tall, and region size in pixels = `region:GetEffectiveScale() * screenHeight / 768`.
  - For pixel-perfect UI set `uiScale` to `768/vRes`. For screens taller than 1200 px this falls below 0.64, "which the game ignores". The workaround is `UIParent:SetScale(...)`, for example `0.5333` at 1440p.
  - Default Retail scale at 2560×1440 is 0.64.
  - The wiki's 0.64 figure differs from the 0.65 slider minimum in the Forever source.
  - Source: [warcraft.wiki.gg UI scaling](https://warcraft.wiki.gg/wiki/UI_scaling)
- This Mac's client reports a monitor "Size(1728x1117)" at 120 Hz. The render target is "864x559(3456x2234 @ 50.0%)", so the physical backbuffer is 3456×2234 and the 3D world renders at 50% — local: `_forever_/Logs/gx.log`

### Inferences
- Recommended pattern for a non-total-conversion addon (avoids touching `UIParent`):

  ```lua
  local function PixelPerfectScale(root)
    local _, h = GetPhysicalScreenSize()
    root:SetScale((768 / h) / UIParent:GetEffectiveScale())
  end
  ```

  - Call it on `PLAYER_LOGIN`, `UI_SCALE_CHANGED` and `DISPLAY_SIZE_CHANGED`. After that, 1 unit inside `root` equals 1 physical pixel.
  - Design in pixels, so a 1px border is `1`.
  - On Retina (≈0.34 effective scale) everything is physically tiny. Offer a user "UI density" multiplier of 1×/2×, which keeps lines on whole pixels, rather than arbitrary fractional scales.
- If `GetPhysicalScreenSize()` returns 1728×1117 (points) on macOS instead of 3456×2234, the factor would be about 0.688. Then "1 unit" equals 2 device pixels, and hairlines would be 2 device px. Verify with `/dump GetPhysicalScreenSize()`.
- Ultrawide displays only change width. The height-based formula still holds.
- Art should be authored at 2× the intended on-screen unit size, so it is sharp on Retina at density 2×.

### Gaps
- I could not verify what `GetPhysicalScreenSize()` returns on macOS Retina for Forever. Test this in-game; it determines the whole scaling strategy.
- Whether calling `UIParent:SetScale` from an addon taints anything in 12.x/Forever was not verified.

---

## 5. Fonts: shipping custom fonts, flags, Slug, and font picks

### Takeaway
Addons can ship TTF and OTF fonts and set them with `SetFont(path, size, flags)`. The flags are `""`, `MONOCHROME`, `OUTLINE`, `THICKOUTLINE` and `SLUG`. The modern client includes the Slug GPU font renderer:
- The client's `Fonts` folder holds compiled `.slug` / `.slugo` files (magic `guls`).
- Blizzard enables Slug on specific fonts with the XML `slug="true"` attribute: nameplates and huge outlined system fonts.
- Addons opt in with the `SLUG` flag.

Slug gives smoother outlines and scale animations, but some fonts render incorrectly with it. Use Slug for large or animated text, and test small UI text both ways.

### Cited Findings
- Flags table: `""` (base), `MONOCHROME` (no antialiasing), `OUTLINE`, `THICKOUTLINE`, `SLUG` ("Font is rendered with the Slug library"). The `flags` parameter has not been optional since 10.0.0 — [warcraft.wiki.gg FontInstance:SetFont](https://warcraft.wiki.gg/wiki/API_FontInstance_SetFont)
- The Forever UI schema's `FontType` has `outline` (`NONE`/`NORMAL`/`THICK`), `monochrome`, `filter`, `canBeUserScaled` and `slug` (boolean, default false) attributes — [UI.xsd (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_SharedXML/UI.xsd)
- Blizzard sets `slug="true"` on 35 font members, for example `<Font font="Fonts\FRIZQT__.TTF" height="24" slug="true" outline="NORMAL"/>`. The font objects that use it are `SystemFont_NamePlate*`, `SystemFont_Huge1_Outline_Slug`, `SystemFont_Outline_Slug_Large2` and `SystemFont_Outline_Slug_Huge2` — [Blizzard_Fonts_Shared/Shared/Fonts.xml (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_Fonts_Shared/Shared/Fonts.xml)
- Local font files:
  - `_forever_/Fonts` holds `615960.slug`/`.slugo` (embedded name "Friz Quadrata TT"), `615965.slug` (32 MB, "AR Kaiti Medium B5"), plus `override_*.slug`/`.slugo` files written at session times.
  - All start with the magic bytes `guls` (that is, "slug").
  - local: `xxd`/`strings` on `_forever_/Fonts/*`
- A 2022 WoWUIBugs report (10.0) found `OUTLINE` looking as thick as `THICKOUTLINE`. A commenter explained Slug is a GPU renderer with its own format and that WoW creates a separate `.slugo` cache for each outlined font. Setting CVar `UseSlug 0` fixed the test case. I saw this through a search summary, not a full read — [Stanzilla/WoWUIBugs #286](https://github.com/Stanzilla/WoWUIBugs/issues/286)
- Plumber's 1.9.2f changelog says it "Reverted a recent change to the text outline rendering method due to compatibility issues", and adds "While the switch to Slug rendering provided sharper outlines, it caused rendering problems with certain fonts." — local: `_forever_/Interface/AddOns/Plumber/Modules/ControlCenter/Changelog/enUS.lua`
- BuffReminders merged "render outlined text through the client's Slug path" ("Add Slug to WoW's font style for a nicer outline") on 2026-10-17 — [BuffReminders PR #94](https://github.com/zerbiniandrea/BuffReminders/pull/94). Another addon, Noodle_SlugBridge, converts addon fonts using OUTLINE/THICKOUTLINE to Slug outline (search snippet only) — [CurseForge Noodle_SlugBridge](https://www.curseforge.com/wow/addons/noodleslugbridge)
- Forever-compatible addons ship both TTF and OTF. Narcissus includes `SemplicitaPro-Semibold.otf`, `NotoSansCJKsc-Regular.otf`, `OpenSans-*.ttf` and `SourceSansPro-*.ttf`. Plumber ships `Lato-Bold.ttf` — local: `_forever_/Interface/AddOns/*/Font(s)/`
- Forever's Font API also has `CreateFontFamily(name, members)`. Members take `alphabet`, `file`, `height` and `flags: TBFFlags`, which is used for per-alphabet fallbacks such as Latin/Cyrillic/CJK. `GetFontInfo(fontObject)` returns `outline` and `shadow` info — [FontDocumentation.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/FontDocumentation.lua)
- All of the following have an `OFL.txt` in the `ofl/` tree of the google/fonts repo (HTTP 200 checked 2026-11-06), so they are SIL Open Font License 1.1:
  - [Inter](https://github.com/google/fonts/blob/main/ofl/inter/OFL.txt)
  - [Manrope](https://github.com/google/fonts/blob/main/ofl/manrope/OFL.txt)
  - [Sora](https://github.com/google/fonts/blob/main/ofl/sora/OFL.txt)
  - [Outfit](https://github.com/google/fonts/blob/main/ofl/outfit/OFL.txt)
  - [Space Grotesk](https://github.com/google/fonts/blob/main/ofl/spacegrotesk/OFL.txt)
  - [IBM Plex Sans](https://github.com/google/fonts/blob/main/ofl/ibmplexsans/OFL.txt)
  - [Cinzel](https://github.com/google/fonts/blob/main/ofl/cinzel/OFL.txt)
  - [Marcellus](https://github.com/google/fonts/blob/main/ofl/marcellus/OFL.txt)
  - [Jost](https://github.com/google/fonts/blob/main/ofl/jost/OFL.txt)
  - [Urbanist](https://github.com/google/fonts/blob/main/ofl/urbanist/OFL.txt)
  - [Plus Jakarta Sans](https://github.com/google/fonts/blob/main/ofl/plusjakartasans/OFL.txt)
  - [Geist](https://github.com/google/fonts/blob/main/ofl/geist/OFL.txt)

### Inferences
- **Suggested "luxury tech" set** (the small-size behaviour is my judgement, not sourced):
  1. **Inter** for body and numbers. It was built for screens, has tabular figures and holds up at 10–12 px.
  2. **Manrope** for headings and labels. It is a refined geometric grotesk.
  3. **Sora** or **Space Grotesk** as a tech accent for numbers, timers and big stats.
  4. **IBM Plex Sans** as an alternative body font with good small-size hinting.
  5. **Cinzel** or **Marcellus** for very sparing, letter-spaced all-caps titles, to add a "luxury" note that still feels Warcraft-adjacent.
  6. **Geist** as a crisp neutral alternative.
  - Ship static instances (Regular/Medium/SemiBold) rather than variable fonts. Variable-axis support in the WoW font loader is unverified.
  - Bundle the OFL.txt file with each font.
- **Slug policy.**
  - Use `"SLUG"` (or `"OUTLINE, SLUG"`) for large display numbers, text you animate with Vertex scale mode, and outlined text over the 3D world.
  - Keep small body text on the default rasteriser unless in-game A/B testing shows Slug is equal or better.
  - Slug renders from outlines with no hinting, so very small text may look softer. That is a plausible reason, though unconfirmed, for the "problems with certain fonts".
- The `override_*.slug(o)` files are most likely Slug compilations of addon or user override fonts generated at load time. The filename is a hash. This is inferred from the timestamps and the WoWUIBugs `.slugo` explanation. So a custom TTF/OTF flagged `SLUG` gets compiled on first use and costs a one-time load hitch.
- Register fonts with LibSharedMedia (section 6) so users can swap them.

### Gaps
- No official Blizzard documentation of Slug for addons: the supported combinations (`SLUG` with `MONOCHROME`?), the cost of first-time compilation, or which glyph features fail.
- I did not confirm whether `CreateFont` + `SetFont(..., "SLUG")` on an addon-shipped OTF works on Forever without issues. This needs an in-game test.
- Whether variable fonts load is unverified.
- Fontshare fonts such as Satoshi and General Sans use Fontshare's own licence, not OFL. I did not check their redistribution terms, so they were excluded.

---

## 6. Integration APIs: Settings, Addon Compartment, Edit Mode, slash commands, SavedVariables, LibSharedMedia

### Takeaway
All the Retail integration surfaces exist on Forever:
- The Settings API, with canvas or vertical layouts.
- The Addon Compartment, through TOC directives or `AddonCompartmentFrame:RegisterAddon`.
- Edit Mode, through LibEditMode, which has a 16001 build.
- Slash commands, including a newer `RegisterNewSlashCommand` helper.
- TOC-declared SavedVariables.

### Cited Findings
- Settings functions in the Forever source:
  - Categories: `CreateCategory`, `RegisterCategory`, `RegisterAddOnCategory`, `OpenToCategory`, `RegisterVerticalLayoutCategory`/`Subcategory`, `RegisterCanvasLayoutCategory`/`Subcategory`, `RegisterInitializer`.
  - Settings: `RegisterAddOnSetting`, `RegisterProxySetting`, `RegisterCVarSetting`, `CreateCheckbox`, `CreateSlider`, `CreateDropdown`, `CreateColorSwatch`, `CreateSliderOptions`, `CreateControlTextContainer`, and initializer helpers.
  - Source: [Blizzard_Settings_Shared (forever)](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_Settings_Shared)
- The wiki guide covers canvas layout (your own frame) and vertical layout (auto-generated controls, `layout:AddInitializer`, section headers) — [warcraft.wiki.gg Creating a settings menu](https://warcraft.wiki.gg/wiki/Creating_a_settings_menu), [Settings API](https://warcraft.wiki.gg/wiki/Settings_API)
- A 10.0-era report said `RegisterProxySetting` tainted and blocked spellcasting. The workaround was `Settings.RegisterAddOnSetting` with a value-changed callback. The same thread says `CreateDropDownTextContainer` was renamed `CreateControlTextContainer` — [WoWInterface thread](https://wowinterface.com/forums/showthread.php?p=341406). LibSettings is a lighter-weight wrapper — [seblindfors/LibSettings](https://github.com/seblindfors/LibSettings)
- Addon Compartment TOC directives:
  - `AddonCompartmentFunc` ("required for automatic registration")
  - `AddonCompartmentFuncOnEnter` / `OnLeave`
  - `IconTexture` / `IconAtlas`
  - Source: [warcraft.wiki.gg TOC format](https://warcraft.wiki.gg/wiki/TOC_format)
  - The Forever source has `AddonCompartmentMixin:RegisterAddon(addonData)` — [Blizzard_Minimap/Mainline/AddonCompartment.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_Minimap/Mainline/AddonCompartment.lua)
  - DialogueUI uses `## AddonCompartmentFunc: DialogueUI_ShowSettingsFrame` on Forever — local: `DialogueUI.toc`
- LibEditMode:
  - It integrates addon frames into Blizzard's Edit Mode "with feature parity" and "limits method reuse to reduce taint" — [p3lim-wow/LibEditMode](https://github.com/p3lim-wow/LibEditMode)
  - Release 19 (2026-11-03) has TOC `## Interface: 120105, 120107, 16001, 20506, 50504` — [LibEditMode.toc](https://raw.githubusercontent.com/p3lim-wow/LibEditMode/master/LibEditMode.toc), [releases](https://github.com/p3lim-wow/LibEditMode/releases)
- Slash commands: the Forever source adds `RegisterNewSlashCommand(callback, command, commandAlias)` next to the classic `SLASH_X1` + `SlashCmdList` pattern — [SlashCommandsRegistry.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ChatFrameBase/Shared/SlashCommandsRegistry.lua)
- SavedVariables:
  - `## SavedVariables` is stored in `WTF\[account]\SavedVariables\MyAddOn.lua`, and `## SavedVariablesPerCharacter` per character — [warcraft.wiki.gg TOC format](https://warcraft.wiki.gg/wiki/TOC_format)
  - The data is only available from `ADDON_LOADED`.
  - A beta bug (fixed in build 70009, per an unverified report) failed to restore SavedVariables — [wowforeverguides.com](https://wowforeverguides.com/addons/developers)
- LibSharedMedia-3.0 is "License: LGPL v2.1" in its file header. BugSack embeds it on Forever alongside LibDBIcon-1.0, LibDataBroker-1.1, CallbackHandler-1.0 and LibStub — local: `_forever_/Interface/AddOns/BugSack/Libs/`

### Inferences
- For a premium addon, use a **canvas layout** category that hosts your own fully styled config frame. That is the only way to match your visual style. Optionally add a small vertical-layout subcategory for searchable basic toggles.
- Register the compartment entry through the TOC, which costs nothing.
- Integrate movable frames through LibEditMode, so users position them in Blizzard's Edit Mode rather than a custom "unlock" mode.
- For profiles, AceDB-3.0 (section 7) is still the standard. A hand-rolled `{profiles = {}, profileKeys = {}}` table works for a single addon.
- `LSM:Register("font", "KstyleUI Inter", [[Interface\AddOns\KstyleUI\Media\Fonts\Inter-Regular.ttf]])`, and the same for `statusbar`/`border`/`background`, makes your media available to other addons.

### Gaps
- I did not verify the LibEditMode API surface (AddFrame / AddFrameSettings and the setting types) beyond the README. Read its wiki.
- I found no Forever-specific report on Settings API taint in 12.x/Forever.

---

## 7. Libraries and licences (2026)

### Takeaway
The standard stack works on Forever:
- LibStub (public domain)
- CallbackHandler
- Ace3 (BSD-style)
- LibSharedMedia-3.0 (LGPL 2.1)
- LibDBIcon / LibDataBroker
- LibEditMode (custom licence: embedding allowed, standalone redistribution not)
- oUF (MIT), which explicitly supports Forever with secret scrubbing
- LibCustomGlow (MIT), whose TOC doesn't list 16001

### Cited Findings
- oUF:
  - Its TOC has `## Interface: 120105, 120107, 16001`, `## AllowLoadGameType: standard, camelot` and `## X-oUF: oUF`. Licence is MIT.
  - Release 14.2.1 (2026-11-03) includes "core: Scrub secrets" and "stagger: Stock bar doesn't exist in Forever".
  - Release 14.1.1 (2026-09-28) says "Only load for Retail and Forever".
  - Sources: [oUF.toc](https://raw.githubusercontent.com/oUF-wow/oUF/master/oUF.toc), [oUF repo](https://github.com/oUF-wow/oUF), [oUF releases](https://github.com/oUF-wow/oUF/releases)
- LibEditMode licence: "All rights reserved". Use, modification and derivatives are permitted if the name isn't reused. It may be aggregated into a WoW AddOn unmodified. "This software may not be distributed standalone… without specific prior written permission" — [LibEditMode LICENSE.txt](https://raw.githubusercontent.com/p3lim-wow/LibEditMode/master/LICENSE.txt)
- Ace3: "Copyright (c) 2007, Ace3 Development Team. All rights reserved. Redistribution and use in source and binary forms, with or without…" (BSD-style). The repo was last pushed 2026-10-28 — [Ace3 LICENSE.txt](https://raw.githubusercontent.com/WoWUIDev/Ace3/master/LICENSE.txt), [WoWUIDev/Ace3](https://github.com/WoWUIDev/Ace3)
- LibStub: "LibStub is hereby placed in the Public Domain" — local: `BugSack/Libs/LibStub/LibStub.lua`
- LibSharedMedia-3.0: LGPL v2.1 — local: `BugSack/Libs/LibSharedMedia-3.0/LibSharedMedia-3.0.lua`
- LibCustomGlow: MIT. Last pushed 2026-07-17, TOC Interface `120001, 120000` — [GitHub API/LibCustomGlow](https://github.com/Stanzilla/LibCustomGlow)
- Under Midnight's restrictions, the client withholds certain combat data (health, names, auras, casts) in encounters, M+ and rated PvP. Addons can pass these values to widgets but can't do maths on them. Some unit-frame addons were abandoned as a result, for example Shadowed Unit Frames — [PeaversUnitFrames](https://www.curseforge.com/wow/addons/peaversunitframes), [SimpleFrame](https://www.curseforge.com/wow/addons/simple-frame), [Shadowed Unit Frames](https://www.wowace.com/projects/shadowed-unit-frames?page=11)

### Inferences
- For a visual-first UI suite, embed: LibStub, CallbackHandler-1.0, AceDB-3.0 (profiles), LibSharedMedia-3.0, LibDBIcon-1.0 (optional; the compartment may be enough), LibEditMode, and oUF if you build unit frames.
- Hand-roll glows rather than depending on LibCustomGlow until it is confirmed on 16001.
- LGPL and BSD libraries are fine to embed unmodified. Keep their licence files.
- Don't vendor LibEditMode outside an addon package.

### Gaps
- CallbackHandler-1.0's licence was not confirmed. The local file header had no licence line.
- LibDBIcon / LibDataBroker licences were not checked.

---

## 8. Tooling on macOS: conversion, lint, tests, packaging, debugging

### Takeaway
On a Mac the pipeline is:
1. Author PNG.
2. Optionally convert to BLP with Pillow (BLP writing since 9.1.0, BLP2 by default) or `blp2any`.
3. Lint with luacheck using a WoW std, and get API autocomplete from Ketho's VS Code WoW API extension.
4. Unit-test pure Lua with busted, and use wowless (pre-alpha, Docker) for headless FrameXML smoke tests.
5. Package with the BigWigs packager, which has had Forever support since v2.6.0, and upload to CurseForge/Wago/WoWI using API tokens.
6. Debug in-game with `/reload`, `/fstack`, `/etrace`, `/tinspect`, `/dump`, `/api`, plus BugSack/BugGrabber. Both are already installed and support 16001.

### Cited Findings
- **Pillow.** The 9.1.0 release (2022-04-01) "Added BLP saving": "`blp_version` can be used to specify whether the image should be saved as BLP1 or BLP2… By default, BLP2 will be used." — [Pillow 9.1.0 release notes](https://pillow.readthedocs.io/en/stable/releasenotes/9.1.0.html). According to a mirror of the 9.3.0 notes, BLP1 data may use JPEG compression — [mirror of Pillow release notes](https://git.akarpov.ru/python-pillow/Pillow/src/commit/c16737d589144e4ee5f0c239b90ad0935a0dfe6a/docs/releasenotes/9.1.0.rst)
- **blp2any** (JuicyPixels-blp, BSD-3):
  - Converts between BLP and PNG/JPEG/TIFF/GIF/BMP.
  - Has macOS Apple Silicon binaries from 0.5.0.0.
  - `-b dxt1|dxt3|dxt5|bgra` writes BLP2, and `--blp2` writes paletted BLP2.
  - This comes from a search summary; I did not test it.
  - Sources: [JuicyPixels-blp on Hackage](https://hackage-content.haskell.org/package/JuicyPixels-blp-0.5.0.0), [Stackage](https://www.stackage.org/nightly-2026-10-21/package/JuicyPixels-blp-1.0.0.0)
- BLPConverter (Kanma) converts BLP to PNG/TGA only — [suuphoenix/BLPConverter README](https://github.com/suuphoenix/BLPConverter/blob/master/README)
- **luacheck** (MIT; last pushed 2026-07-31):
  - The config is a Lua file with `globals`, `read_globals`, std composition (`std = "lua51+wow"`) and per-path `files[...]` overrides — [luacheck config docs](https://github.com/lunarmodules/luacheck/blob/0.25.0/docsrc/config.rst)
  - A community WoW boilerplate defines `stds.wow`, ignores unused `self`/`event`, and allows globals prefixed with the addon name — [LenweSaralonde .luacheckrc gist](https://gist.github.com/LenweSaralonde/13a217b5d7186f9218ae62736e2bff90)
  - BigWigs' Capping is a real-world example — [Capping .luacheckrc](https://www.github.com/BigWigsMods/Capping/blob/master/.luacheckrc)
- **Ketho/vscode-wow-api**: "VS Code extension for World of Warcraft AddOns", MIT, last pushed 2026-10-03. It provides LuaLS type annotations for the WoW API — [Ketho/vscode-wow-api](https://github.com/Ketho/vscode-wow-api)
- **busted**: MIT, last pushed 2026-08-25 — [lunarmodules/busted](https://github.com/lunarmodules/busted)
- **wowless**:
  - "A headless WoW client Lua and FrameXML interpreter. Intended for addon testing." "Still pre-alpha… errors are almost certainly still in Wowless."
  - "Development is currently only supported via Docker".
  - Run with `bin/run.sh wow --addondir path/to/AddonName`.
  - It downloads the retail client's Lua/XML.
  - Its runtime is elune, a taint-aware Lua 5.1 fork.
  - Last pushed 2026-11-05.
  - Source: [wowless/wowless README](https://github.com/wowless/wowless)
  - WoWUnit is an in-game unit-test framework — [Jaliborc/WoWUnit](https://github.com/Jaliborc/WoWUnit)
- **BigWigs packager**:
  - v2.6.0 added "WoW Forever support (#202)" and "Allow splitting a TOC with no retail interface version".
  - v2.7.0 (2026-11-05) says "Don't allow Forever interface versions in `Classic` toc files" and "Allow Forever interface versions in `Mainline` toc files", and added "zip" externals and retries for Wago/WoWI uploads.
  - The README documents: `.pkgmeta` keys (`externals`, `ignore`, `manual-changelog`, `enable-toc-creation`, `embedded-libraries`); TOC keys `X-Curse-Project-ID`, `X-WoWI-ID`, `X-Wago-ID`; env vars `CF_API_TOKEN` and `WAGO_API_TOKEN`; and the example `ForeverOnly.lua [AllowLoadGameType camelot][ExcludeLoadGameType standard, classic]`.
  - Sources: [packager releases](https://github.com/BigWigsMods/packager/releases), [packager README](https://github.com/BigWigsMods/packager/blob/master/README.md)
- **In-game debug commands** in the Forever source:
  - `FRAMESTACK` (`/fstack`, in a Mainline override), `EVENTTRACE` (`/etrace`), `TABLEINSPECT` (`/tinspect`), `DUMP` (`/dump`), `RELOAD` and `API`.
  - `/tinspect` checks `Kiosk.IsEnabled() or C_AddOns.GetScriptsDisallowedForBeta() or C_GameRules.IsGameRuleActive(Enum.GameRule.UserScriptsDisabled)` and does nothing if any of these is true.
  - Sources: [SlashCommands.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ChatFrameBase/Shared/SlashCommands.lua), [SlashCommandsOverrides.lua (Mainline)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ChatFrameBase/Mainline/SlashCommandsOverrides.lua)
- BugSack v12.1.9 and BugGrabber v12.1.1 are installed with Interface lines including 16001. BugSack has a Forever-only file — local: `_forever_/Interface/AddOns/BugSack/BugSack.toc`, `!BugGrabber/!BugGrabber.toc`
- The client writes many logs that help with rendering issues: `gx.log` (GPU, resolution), `EditMode.log`, `Client.log`, `DeveloperLog.log` — local: `_forever_/Logs/`

### Inferences
- **Mac setup.** Install Python and Pillow (`pip install pillow`, any version ≥ 9.1) and keep a scripted `png → blp` step optional. Then install luacheck through Homebrew/luarocks, busted, and the VS Code Lua extension with Ketho's WoW API.
- **Testing strategy.**
  - Keep layout maths, easing, colour/palette and profile-migration logic in pure-Lua modules with no WoW globals, and test them with busted.
  - Use wowless (Docker on Mac) only as a smoke test that the TOC/XML loads, given its pre-alpha state.
- Use a single TOC with `## Interface: 120107, 16001` (or Forever-only `16001`) plus `[AllowLoadGameType camelot]` lines. Upload via GitHub Actions with `BigWigsMods/packager` and secrets for `CF_API_TOKEN`/`WAGO_API_TOKEN`.
- Iteration loop: edit the file, then `/reload`. New art files no longer need a restart (9.0.1+). Use `/fstack` (Alt cycles) to inspect layers and `/etrace` to find chatty events.

### Gaps
- No up-to-date luacheck WoW std that includes 12.x/Forever globals was found. Generate one from `Blizzard_APIDocumentationGenerated` or from Ketho's annotations.
- I did not verify whether wowless can target the Forever (`camelot`) UI branch; it defaults to the Retail client code.
- `blp2any` output was not tested against the Forever client.

---

## 9. AI-generated UI art (Higgsfield / GPT Image / Nano Banana / Seedream): what to generate vs draw procedurally

### Takeaway
Use image models for **rich, irregular art**: ornamental corners, crests, emblems, textured backgrounds, icon sets, glow and particle sprites, and FlipBook frames. Then clean, key, palette-lock and downsample them locally into power-of-two PNGs. Do **everything geometric** procedurally in Lua or with tiny gradient textures: 1px lines, flat or gradient fills, rounded rects (mask + 9-slice), progress bars, shadows and glows from one soft falloff texture. Model transparency support is inconsistent, so plan on chroma-key or background-removal plus an alpha check.

### Cited Findings
- **Higgsfield session metadata.** The Higgsfield MCP server instructions available in this session describe:
  - `generate_image`, whose default model is listed as `gpt_image_2_6`, with "native GIF/SVG via output_format".
  - Dedicated `remove_background`, `upscale_image` and `outpaint_image` tools.
  - The higgsfield-generate skill lists "GPT Image 2.5 for image/design/text" and "Nano Banana 2 for cartoon characters" as defaults. Another skill uses Nano Banana Pro for renders and Seedream for focused edits.
  - Source: in-session Higgsfield tool and skill descriptions; no public URL. I could not query live model capabilities because `models_explore` returned "Authentication service unavailable" and then HTTP 503.
- One agent-skill guide says "RGBA mode alone does not prove transparency". It recommends checking alpha on a checkerboard or the target background, generating one asset per call (no sprite sheets unless requested), putting size/aspect in the prompt and verifying it, keeping labels and text out of the image, and reusing mirrored corners from one texture. It advises against silently chroma-keying — [tessl: codex-gpt-image-2-5-flare skill](https://tessl.io/registry/skills/github/MengTo/Skills/codex-gpt-image-2-5-flare)
- Community guides report conflicting claims (unverified, search summaries only):
  - Older gpt-image-1 had a `background: transparent` option.
  - gpt-image-2 reportedly lacks native alpha, with a fallback to gpt-image-1.5.
  - Chroma-key generation on #ff00ff or #00ff00, with the key colour kept out of the subject, is a common workaround.
  - Don't ask the model to draw a checkerboard, because it gets painted in.
  - Sources: [skillselion transparent-visual-assets](https://skillselion.com/skills/dwdestiny/codex-visual-asset-skills/transparent-visual-assets), [dev.to pixel-art sprites with transparent backgrounds](https://dev.to/om_prakash_3311f8a4576605/how-to-generate-real-pixel-art-sprites-via-api-with-transparent-backgrounds-keg), [GPT Image 2 for Game Development guide](https://combos.converge.ai/page/en-US/blog/gpt-image-2-game-development), [mcpservers green-screen-cutout-assets](https://mcpservers.org/fr/servers/act-chao/green-screen-cutout-assets-skill)
- In-client constraints the art must meet (from sections 1–4): power-of-two dimensions, RGBA PNG/TGA/BLP, `.png` extension in paths, `CLAMPTOBLACKADDITIVE` for masks, and 9-slice via `SetTextureSliceMargins` — [warcraft.wiki.gg SetTexture](https://warcraft.wiki.gg/wiki/API_TextureBase_SetTexture), [SimpleTextureBaseAPIDocumentation.lua (forever)](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleTextureBaseAPIDocumentation.lua)

### Inferences (practical pipeline; my recommendations, not sourced facts)
1. **Style lock.**
   - Write one style sheet prompt: palette hex codes, materials (for example "brushed titanium, smoked glass, champagne-gold hairline accents"), lighting direction, and line weight.
   - Generate a single "hero" reference such as a panel corner.
   - Pass it as an image reference to every later generation, so the set stays consistent.
   - Generate at 2048 or 1024 and keep the masters.
2. **Transparency.** Prompt "isolated on a flat pure #FF00FF background, no shadow, no text". Then key locally, or use Higgsfield `remove_background`. Defringe by unpremultiplying against the key colour and eroding 1px of alpha. Verify with a script that alpha has true 0 and 255 regions and no magenta-tinted semi-transparent edge pixels.
3. **9-slice-ready borders.** Generate a square frame with uniform border thickness and plain corners. Crop corners and a 1–4 px edge strip, then rebuild a clean 9-slice sheet, or use `SetTextureSliceMargins`. Mirror one corner to make all four, so they match exactly. Make edges tileable, or let them stretch only along one axis.
4. **Palette and colour correction.** Map the generated art to a fixed palette with a LUT or per-channel curves in Python (Pillow/NumPy). Better still, generate **greyscale or white art and tint it in-game with `SetVertexColor`/`SetGradient`**. Then one asset serves every theme and class colour, and file count stays small.
5. **Downsampling.** Resize masters with Lanczos, area-average or premultiplied-alpha resampling to the exact pixel size at your target density (for example a 64 px corner at 2× density). Pad to power of two. Sharpen lightly after downscaling, and never upscale in-game.
6. **Icons.** Generate on a consistent template, such as the same framing and rim light. Export at 64×64 or 128×128, and crop with a circular or rounded mask in-game rather than baking the mask in.
7. **What to keep procedural:**
   - Hairlines, dividers and focus rings: colour textures sized with PixelUtil.
   - Panel fills and gradients: `SetGradient` with `CreateColor`.
   - Rounded corners: mask or 9-slice of a tiny anti-aliased shape you draw yourself, for example with Pillow at 4× then downsampled.
   - Shadows and glows: one Gaussian falloff PNG, 9-sliced.
   - Progress rings: radial progress.
   - Shimmer: a TextureCoordTranslation over a gradient strip.
   - These are pixel-exact at any scale, themeable and tiny, while AI output tends to be slightly asymmetric and noisy at 1–2 px detail.
8. **What generated art is good for:** ornamental filigree and corner pieces, emblem or crest backgrounds, subtle material textures (brushed metal, carbon, marble, nebula), class or feature icons, and FlipBook frames for sparkles or energy (generate keyframes, then assemble a sheet for `SetFlipBook*`).
9. **Licensing hygiene.** Record the model, prompt, seed and date for every shipped asset in an `ART_PROVENANCE.md` or `.json`, and check each model's commercial-use terms before publishing on CurseForge/Wago.

### Gaps
- I could not confirm current Higgsfield model capabilities: which models support native transparent PNG output, maximum resolution, seed or reference controls, or commercial-use terms. The Higgsfield API was unavailable (auth error / 503) during this session. Check with `models_explore` (`action: get`) before building the pipeline.
- I found no authoritative source on gpt-image-2.x native alpha support. Community claims conflict. Check the official OpenAI image API docs.
- I found no WoW-specific study comparing AI-generated and hand-made UI textures at small sizes. The procedural-vs-generated split above is a reasoned recommendation, not a sourced finding.
