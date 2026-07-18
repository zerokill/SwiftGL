# chatGPTGL

Native macOS OpenGL playground written in Swift. Despite the name there is no web/JS involved — it's a GLFW window with an OpenGL 3.3 core context, Swift application code, a thin C interop layer, and a Dear ImGui overlay. A hobby/experiment project: a procedural terrain with water, a skybox, instanced flying pyramids ("livia") and spheres ("leon"), a day/night sun, and a volumetric cloud layer.

## Build & run

- Build: `make` (`build.sh` is stale — ignore it; `app` and the `.o` files are untracked build products).
- Run: `./app --graphics -p 1` (without `-p 1` it logs "Unknown program" and exits; `-p 2/3` are shadertoy/grid experiments). Optional `-w`/`-h`/`-f` for size/fullscreen.
- ImGui submodule lives at `csrc/imgui` (`git submodule update --init` on fresh clones).

## Verification tips

- Shaders are compiled at startup and `fatalError` on failure — if the app survives launch, all GLSL compiled.
- App stdout is block-buffered when redirected; run under `script -q <log> ./app ...` for live logs.
- To screenshot the window headlessly: find the window ID via a small Swift `CGWindowListCopyWindowInfo` tool (owner name is "app"), then `screencapture -x -o -l <id> out.png`. Full-screen `screencapture` may catch the wallpaper instead.
- Scene lighting varies run to run: the sun (spawned with key **8**) orbits on a day/night cycle and tints everything from white to orange to dark blue.

## Architecture

- `swiftsource/main.swift` → `graphics.swift` (`runGraphics`) → `liviaRender.swift`: resource loading, shader registration, main loop.
- `renderer.swift`: per-frame pass order — water reflection/refraction FBOs, main scene (skybox, terrain, instanced models), water, light, clouds last. An HDR/tonemap path exists but is commented out.
- `scene.swift` holds terrain/water/cloud/light; `mesh.swift` is the VAO/VBO/EBO + instancing base; `shaderManager.swift`/`shader.swift` wrap GLSL programs; `framebuffer.swift` is a fixed 1280×720 FBO helper.
- C interop via `modules/module.modulemap`: `ShaderModule`, `TextureModule`, `GraphicsModule`, `ImguiModule` (`csrc/wrapper/cimgui_wrapper.h` is the header Swift sees; implementation in `imgui_wrapper.cpp`).
- ImGui pattern: a `*_config_t` struct + `ImGuiWrapper_*Config()` function returning slider state each frame (see `config_t` for terrain, `cloud_config_t` for clouds), consumed in the main loop.
- Shaders live in `resources/shader/*.vert|frag|geom` and are loaded from the working directory at runtime — editing a shader needs no rebuild, just restart.

## Gotchas

- macOS caps OpenGL at 4.1: **no compute shaders**. GPU generation of 3D textures is done by attaching each Z slice with `glFramebufferTextureLayer` and running fullscreen fragment passes (see `noiseGenerator.swift`).
- `Shader.setUniform` has a `GLuint` overload that calls `glUniform1ui` — **never use it for samplers** (silently fails); pass `Int32` so `glUniform1i` is used. Some older call sites (skybox, models) still use the GLuint form and rely on defaulting to unit 0.
- If a program declares samplers of **different types** (e.g. `sampler3D` + `sampler2D`), assign every sampler its own unit even when it's unused this frame: two sampler types both defaulting to unit 0 make the whole draw call `GL_INVALID_OPERATION` — GL drops it **silently** (this no-op'd the entire cloud pass once).
- `GL_CLIP_DISTANCE0` is enabled globally in `setupOpenGL` (for the water clip planes). Every vertex shader must write `gl_ClipDistance[0]` (declare `out float gl_ClipDistance[1];`, write `1.0` if unused) — leaving it unwritten is undefined behavior.
- The camera far plane is **1000** (`camera.swift`). Any large volume/sky geometry that extends past it gets frustum-clipped, leaving straight-edged holes with *no fragments at all* — invisible to any fragment-shader logic. Clamp clip z in the vertex shader (`clipPos.z = min(clipPos.z, clipPos.w * 0.9999)`) like `cloud.vert` does. This was the "box in the sky" cloud artifact; full post-mortem in `CLOUD_FINDINGS.md`.
- Viewport convention is retina-doubled: `glViewport(0, 0, displayWidth*2, displayHeight*2)` after unbinding FBOs.
- The default framebuffer is 4×MSAA (GLFW hint) — relevant if you ever try depth blits from it.
- `GL_CULL_FACE`/`GL_BACK` and depth test are global state set once in `Renderer.setupOpenGL`; passes that need different state must set and restore it themselves.

## Volumetric clouds (added 2026-07-18 by Claude)

Raymarched volumetric cumulus, staged in commits `4f9596b`..HEAD. Files: `resources/shader/cloud.vert|frag`, `noise3d.vert|frag`, `swiftsource/cloudModel.swift`, `cloudMesh.swift`, `noiseGenerator.swift`, cloud parts of `renderer.swift` (`renderCloud()`) and the `cloud_config_t` ImGui panel.

- Geometry: a unit cube scaled into a sky slab that **follows the camera in x/z** (footprint `2.2 × fadeEnd`; the noise is world-anchored so the volume moves seamlessly), bottom extended below `cloudBase` by the curvature drop; its clip-space z is clamped in `cloud.vert` so the far plane never clips it (see Gotchas). Fake planetary curvature (`uCurveR`) sinks the deck with distance so it closes at the horizon. An ImGui checkbox switches to a small debug box at (10,10,0). Front faces are culled so the volume renders with the camera inside; depth test on, depth write off; premultiplied-alpha blending (`GL_ONE, GL_ONE_MINUS_SRC_ALPHA`).
- Raymarch (`cloud.frag`): slab ray/box intersection in 0..1 UVW space, but sampling/lighting/distances are world-space. Front-to-back accumulation with Beer's law, Henyey-Greenstein phase for the silver lining, per-fragment start jitter against banding, early exit at T<0.01, distance fade before the far plane.
- Noise: tileable periodic-Perlin FBM baked into a 128³ `GL_RG8` 3D texture on the GPU (R = base shape, G = detail that erodes the base via remap). CPU Perlin (`perlinNoise.swift`) is only the pre-shader-load fallback. B channel is reserved for future Worley erosion.
- Animation: base scrolls with wind; detail scrolls 1.6× faster plus a slow vertical drift so shapes evolve.
- Sun: **directional** — direction derived from the scene light's offset to its orbit center (`LightModel.positionMatrix`), not its position (the orbiting sphere sits mostly below the cloud layer and is useless as a point light). Falls back to a fixed white sun when no light is spawned.
- Performance (reworked 2026-07-18): the march uses a fixed world-space step size (`uMaxRayDist / uSteps`), so short rays straight up take ~10 steps instead of 64; the march is clamped to the fade distance; phase/sun tint are hoisted out of the loop; empty base samples skip the detail fetch. By default the cloud pass renders at **half resolution** into `Renderer.cloudFramebuffer` and is composited full-screen (`cloudComposite.vert|frag`, premultiplied blend) — toggle with the "half-res clouds" ImGui checkbox. Scene depth for occlusion comes from an MSAA `glBlitFramebuffer` resolve into `DepthFramebuffer` (formats must match: `DEPTH24_STENCIL8`, identical rects, `GL_NEAREST`); if the blit ever errors, clouds just skip depth occlusion (`depthResolveWorks`). Worst case measured (camera up, coverage 0.95, uncapped): old path ~30 FPS → new ~70–300 FPS.
- All parameters live-tune in the ImGui "Clouds" header; "Regenerate noise" rebuilds the 3D texture with current octaves/period/seed.

## Open ideas

- Worley erosion in the noise B channel for crisper cauliflower edges.
- Quarter-res cloud pass option (half-res is implemented; the composite path generalizes).
- Re-enable the HDR/tonemap path (`renderHdr` + `gui.frag` ACES) so bright cloud highlights stop clipping.
