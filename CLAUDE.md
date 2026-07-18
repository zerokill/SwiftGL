# chatGPTGL

Native macOS OpenGL playground written in Swift. Despite the name there is no web/JS involved — it's a GLFW window with an OpenGL 3.3 core context, Swift application code, a thin C interop layer, and a Dear ImGui overlay. A hobby/experiment project: a procedural terrain with water, a skybox, instanced flying pyramids ("livia") and spheres ("leon"), a day/night sun, and a volumetric cloud layer.

## Build & run

- Build: `make` (the `app` binary and `csrc/wrapper/imgui_wrapper.o` are checked into git; `build.sh` is stale — ignore it).
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
- Viewport convention is retina-doubled: `glViewport(0, 0, displayWidth*2, displayHeight*2)` after unbinding FBOs.
- The default framebuffer is 4×MSAA (GLFW hint) — relevant if you ever try depth blits from it.
- `GL_CULL_FACE`/`GL_BACK` and depth test are global state set once in `Renderer.setupOpenGL`; passes that need different state must set and restore it themselves.

## Volumetric clouds (added 2026-07-18 by Claude)

Raymarched volumetric cumulus, staged in commits `4f9596b`..HEAD. Files: `resources/shader/cloud.vert|frag`, `noise3d.vert|frag`, `swiftsource/cloudModel.swift`, `cloudMesh.swift`, `noiseGenerator.swift`, cloud parts of `renderer.swift` (`renderCloud()`) and the `cloud_config_t` ImGui panel.

- Geometry: a unit cube scaled into a 1900×(top−base)×1900 sky slab (default y 150–300); an ImGui checkbox switches to a small debug box at (10,10,0). Front faces are culled so the volume renders with the camera inside; depth test on, depth write off; premultiplied-alpha blending (`GL_ONE, GL_ONE_MINUS_SRC_ALPHA`).
- Raymarch (`cloud.frag`): slab ray/box intersection in 0..1 UVW space, but sampling/lighting/distances are world-space. Front-to-back accumulation with Beer's law, Henyey-Greenstein phase for the silver lining, per-fragment start jitter against banding, early exit at T<0.01, distance fade before the far plane.
- Noise: tileable periodic-Perlin FBM baked into a 128³ `GL_RG8` 3D texture on the GPU (R = base shape, G = detail that erodes the base via remap). CPU Perlin (`perlinNoise.swift`) is only the pre-shader-load fallback. B channel is reserved for future Worley erosion.
- Animation: base scrolls with wind; detail scrolls 1.6× faster plus a slow vertical drift so shapes evolve.
- Sun: **directional** — direction derived from the scene light's offset to its orbit center (`LightModel.positionMatrix`), not its position (the orbiting sphere sits mostly below the cloud layer and is useless as a point light). Falls back to a fixed white sun when no light is spawned.
- Performance: sun march uses a cheap base-only density and early-exits when opaque; defaults 64 view / 8 light steps hold 60 FPS. If it ever gets slow again, the next step is a half-res cloud pass + composite (mind the MSAA depth blit).
- All parameters live-tune in the ImGui "Clouds" header; "Regenerate noise" rebuilds the 3D texture with current octaves/period/seed.

## Open ideas

- Worley erosion in the noise B channel for crisper cauliflower edges.
- Half-res cloud pass composited full-screen (perf headroom).
- Re-enable the HDR/tonemap path (`renderHdr` + `gui.frag` ACES) so bright cloud highlights stop clipping.
