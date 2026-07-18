# Cloud rendering: findings from the 2026-07-18 session

## 0. RESOLVED — the box was far-plane clipping of the slab geometry

**Root cause (user-confirmed fixed):** the camera projection uses
`farZ = 1000` (`camera.swift`), and the cloud slab's geometry extends past it
(original 1900×1900 origin box: corners at ~1343; camera-following slab: walls
at a constant 1045). The GPU frustum-clips the slab's far triangles at the far
plane, so screen regions whose only covering geometry was a clipped face get
**no fragments at all** — a hole with straight clip-edge boundaries showing
the raw skybox. Because the far plane is camera-attached, the hole moved
weirdly with view tilt ("sticks to the screen"). No fragment-shader fix could
ever help: the shader never ran there.

**Fix (in `cloud.vert`):** clamp clip-space z so the slab always rasterizes —
`clipPos.z = min(clipPos.z, clipPos.w * 0.9999);` (the skybox trick). The
raymarch is world-space and doesn't use fragment depth, so nothing else
changes. In the full-res path the clamped depth still depth-tests against the
scene correctly (scene geometry is closer; skybox is at exactly 1.0).

**How it was pinned down** (after several wrong theories): a red debug marker
proved the scene-depth clamp wasn't removing the clouds; a green/purple
whole-shader tint proved the fragments never executed in the hole; a grep
cleared scissor/stencil/colormask; that left primitive-level clipping, and the
slab dimensions vs farZ=1000 matched exactly.

**Wrong theories, kept for the record:** slab-edge/fade geometry (§2–3 — real
but fainter effects; the slab-follow + curvature work is still worth keeping),
and undefined `gl_ClipDistance` (real UB, fixed, keep the fix — but it was not
this artifact).

Also applied while chasing this: camera-following slab sized `2.2 × fadeEnd`,
and fake planetary curvature in `sampleDensity` (`uCurveR = 3500`) so the deck
closes at the horizon — both keep the sky natural now that the far-plane clamp
lets the full slab rasterize.

Two workstreams happened in this session: (1) cloud performance optimization —
**successful, keep it**; (2) chasing a "box in the sky" visual artifact — root
cause identified but **not fixed satisfactorily**; the fixes attempted so far
made it *worse* in a new way (horizontal cloud cutoff across half the screen).
This file records what was learned so the next attempt doesn't re-derive it.

## 1. Performance work (verified good, unrelated to the artifact)

Measured worst case (camera pitched up, coverage 0.95, FPS cap removed):
**before ~27–36 FPS → after ~70–300 FPS.** Two tiers:

- `cloud.frag`: adaptive step count (fixed world-space step `uMaxRayDist/uSteps`,
  floor `uSteps/2`), march clamped to the fade distance, early discard for rays
  entering beyond the fade, HG phase + sun tint hoisted out of the loop, analytic
  along-ray distance instead of per-step `distance()`, base-noise-only early-out
  that skips the detail texture fetch (detail erosion can only reduce density),
  density epsilon raised 1e-5 → 1e-3.
- Half-res pass: clouds render into `Renderer.cloudFramebuffer` (logical-size
  RGBA16F, no depth) and composite full-screen via `cloudComposite.vert|frag`
  with premultiplied blending. Scene depth for occlusion comes from an MSAA
  `glBlitFramebuffer` resolve (default FB → `DepthFramebuffer`, DEPTH24_STENCIL8,
  identical rects, GL_NEAREST) — **works on this Mac**. ImGui checkbox
  "half-res clouds" toggles it. Depth-vis debugging confirmed the resolved depth
  and its UV mapping are pixel-correct (terrain/pyramid silhouettes align 1:1).

Bug found while verifying: a `sampler2D` uniform left at its default unit 0
alongside the `sampler3D` noise texture makes the **whole draw call silently
invalid** (GL_INVALID_OPERATION) — the cloud pass rendered nothing in the
full-res path until `uSceneDepth` was unconditionally assigned unit 1. This
gotcha is recorded in CLAUDE.md; don't regress it.

## 2. The "box in the sky" artifact — what it actually is

**User-visible symptom (original):** a crisp box/rectangle in the sky where the
volumetric clouds are absent, showing the skybox behind. Pre-dates the
performance work. Screenshot evidence: `Screenshot 2026-07-18 at 19.59.05.png`
(user Desktop) and session scratchpad `fs_6.png` / `crop6.png`.

**Root cause (confirmed by depth-vis + geometry):** the raymarch volume is a
finite slab (originally 1900×1900 XZ footprint, anchored at the world origin,
y 150–300). Two geometric consequences:

1. **Slab edges are reachable.** The terrain is far larger than the slab.
   Flying a few hundred units from the origin brings the slab's side/bottom-face
   edges inside the fade range (fade was 600–950); the bottom-face far edge is a
   straight world-space line → renders as a razor-straight cloud cutoff.
2. **Grazing-band compression.** For a camera *below* the deck, a ray's entry
   distance into the layer is ≈ `(cloudBase − camY)/sin(elevation)`. Near the
   horizon this changes ~110 units/degree, so the *entire* distance-fade range
   compresses into ~3° of screen elevation. A "gentle" distance fade therefore
   reads as a hard horizontal line ~8° above the horizon (with the 600–950
   fade). Same thing mirrored when the camera is *above* the deck (entry through
   the top face): a hard line just below eye level — i.e. "clouds cut off at
   half the screen" at zero pitch. The line is **camera-attached** (it's an
   angular feature), matching the user's "moves with the screen at half speed"
   observation.

The depth-occlusion path was investigated and cleared: a debug shader
visualizing the resolved depth showed exact 1:1 alignment.

## 3. Fixes attempted, in order, and their outcomes

1. **Slab follows the camera in x/z** (noise is world-anchored so the volume
   can move seamlessly). Removes consequence #1 (edges can never be
   approached). BUT it *universalized* consequence #2: the grazing band, which
   previously only appeared near slab edges, is now visible everywhere, always.
   User: "still there", then "now there is a cut of the clouds on half of the
   screen" — the half-screen cut **started with this change** per the user.
2. **Slab enlarged 1900 → 3100** so edges (~1550) sit past the fade end (950).
   Helped the edge case; did not address the grazing band.
3. **March end exactly at `uFadeEnd`** (removed the ×1.05 overshoot) so the
   alpha field is continuous at the early-discard boundary. Removed a faint
   secondary seam; did not address the band.
4. **Fade pushed out and widened** (600–950 → sliders defaulting 1000–3200),
   slab sized dynamically (`2.2 × fadeEnd`), step floor `uSteps/2` to protect
   overhead quality. Angular math says the vanish line moves to ~2.5° above the
   horizon with a ~5° ramp. Looked acceptable in a spawn-view screenshot
   (`farfade.png`), but the **user reports no improvement** at their viewpoint —
   likely because they fly *inside or above* the deck (mountain altitude,
   camera y ≈ 150–300+), where the deck-plane horizon cut at eye level is
   unaffected by distance-fade tuning.

## 4. Honest assessment & recommended direction

A finite slab + distance fade **cannot** produce a natural horizon for a camera
near or above deck height; the deck-plane horizon will always be an abrupt
angular feature. Real-sky approaches to evaluate next:

- **Fake planetary curvature**: when sampling, drop the effective sample height
  with distance (`y' = y + dist²/(2R)`, R ≈ a few thousand units). Distant
  clouds sink below the horizon and the deck visually closes at the horizon
  like a real sky. This is the standard fix (Horizon Zero Dawn / Frostbite
  style) and directly addresses both the below-deck band and the above-deck
  half-screen cut. Cheap: one extra term in `sampleDensity`.
- Alternatively/additionally, fade by **optical path/angle**, not just
  distance, so the transition width is constant in screen space.
- Keep: camera-following slab, slab sized from fade, march-ends-at-fade — these
  are correct regardless.

If rolling code back, **do not** roll back: the Tier-1 shader optimizations,
the half-res pass, the `uSceneDepth`-unit-1 fix, or the slab-follow (it's a
prerequisite for any of the horizon treatments above; the origin-anchored slab
only *hid* the band by having no clouds at all in most of the world).

## 5. Current state of the working tree (all uncommitted)

Modified: `resources/shader/cloud.frag` (Tier-1 opts + depth occlusion +
fade/step changes), `swiftsource/renderer.swift` (cloud FBO/depth resolve/
composite, camera-follow slab sized `2.2×fadeEnd`, config defaults),
`swiftsource/framebuffer.swift` (parameterized `Framebuffer`, new
`DepthFramebuffer`), `swiftsource/shader.swift` + `shaderManager.swift`
(SIMD2 uniform overload), `swiftsource/liviaRender.swift` (registers
`cloudCompositeShader`), `csrc/wrapper/cimgui_wrapper.h` + `imgui_wrapper.cpp`
(`halfRes`, `fadeStart`, `fadeEnd` in `cloud_config_t` + sliders), `CLAUDE.md`.
New: `resources/shader/cloudComposite.vert|frag`, this file.

## 6. Verification recipes that worked this session

- Benchmark rig: temporarily set `deltaPitch = 0.85` in `inputManager.swift`
  init, `TARGET_FPS = 2000` in `liviaRender.swift`, force coverage in
  `renderCloud()`; window title shows instantaneous FPS (noisy — sample ~8×).
  `osascript` keystrokes are not permitted; you cannot drive the camera
  externally.
- Depth debugging: shaders load from disk at launch — a temporary
  depth-visualization block in `cloud.frag` needs no rebuild, just restart.
- Screenshots: tiny Swift `CGWindowListCopyWindowInfo` tool (owner "app") +
  `screencapture -x -o -l <id>`; fails when the app is on another macOS Space —
  ask the user for a Desktop screenshot instead. App can't launch while the
  screen is locked ("Failed to get primary monitor").
