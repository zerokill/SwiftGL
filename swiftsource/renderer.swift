import simd
import OpenGL.GL3

import TextureModule
import ShaderModule
import ImguiModule

class Renderer {
    var shaderManager: ShaderManager
    var camera: Camera
    var inputManager: InputManager
    var width: Int32
    var height: Int32

    var scene: Scene
    var guiElements: [GuiModel] = []

    var rotation_x: Float = 0.0
    var rotation_y: Float = 0.0
    var time: Float = 0.0
    var cloudConfig: cloud_config_t = cloud_config_t(
        coverage: 0.50, densityScale: 0.25, absorption: 0.4, darkness: 0.15,
        phaseG: 0.35, scatterStrength: 6.0, tiling: 1.0, detailWeight: 0.35,
        windSpeed: 0.02, windDirX: 1.0, windDirZ: 0.3, evolveSpeed: 0.015,
        steps: 64, lightSteps: 8, noiseOctaves: 6, noisePeriod: 4.0,
        noiseSeed: 1, regenerate: false, skyLayer: true,
        cloudBase: 200.0, cloudTop: 350.0, worldNoiseScale: 400.0,
        halfRes: true)

    // Half-res cloud pass: clouds render into this (logical-size, i.e. half
    // the retina framebuffer) and get composited full-screen afterwards.
    var cloudFramebuffer: Framebuffer
    var depthResolveFramebuffer: DepthFramebuffer
    var cloudCompositeQuad: GuiMesh
    // Set to false if the MSAA depth blit turns out not to work; clouds then
    // skip depth occlusion instead of failing every frame.
    var depthResolveWorks = true

    init(width: Int32, height: Int32, scene: Scene) {
        camera = Camera(position: SIMD3(0.0, 10.0, 0.0), target: SIMD3(0.0, 0.0, 0.0), worldUp: SIMD3(0.0, 1.0, 0.0))
        inputManager = InputManager()
        shaderManager = ShaderManager()
        self.width = width
        self.height = height

        self.scene = scene

        cloudFramebuffer = Framebuffer(internalFormat: GL_RGBA16F, width: width, height: height, withDepthBuffer: false)
        depthResolveFramebuffer = DepthFramebuffer(width: width * 2, height: height * 2)
        cloudCompositeQuad = GuiMesh(x: -1.0, y: -1.0, width: 2.0, height: 2.0)

        setupOpenGL()
    }

    func setupOpenGL() {
        glEnable(GLenum(GL_DEPTH_TEST))
        glEnable(GLenum(GL_MULTISAMPLE));
        glEnable(GLenum(GL_CULL_FACE))
        glCullFace(GLenum(GL_BACK))
        glFrontFace(GLenum(GL_CCW))
        glEnable(GLenum(GL_CLIP_DISTANCE0))

        // FIXME: Trying to disable washed out look
        glDisable(GLenum(GL_FRAMEBUFFER_SRGB))
    }

    func render() {
        ImGuiWrapper_Text(String(format: "test"))
        renderReflection()
        renderRefraction()
//        renderHdr()
        renderScene(plane: SIMD4<Float>(0.0, 1.0, 0.0, 10000))
        renderWater()
        renderLight()
        renderCloud()

//        renderGui()
    }

    func renderReflection() {
        self.scene.water.reflectionBuffer.bindFramebuffer()
        // Clear the color and depth buffers
        glClearColor(0.07, 0.13, 0.17, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        let cameraPos = camera.position

        let distance = cameraPos.y * 2
        camera.position.y -= distance
        camera.rotate(yaw: inputManager.deltaYaw, pitch: -inputManager.deltaPitch)
        camera.updateViewMatrix()

        renderScene(plane: SIMD4<Float>(0.0, 1.0, 0.0, 0.0))
        renderLight()

        camera.position = cameraPos
        camera.rotate(yaw: inputManager.deltaYaw, pitch: inputManager.deltaPitch)
        camera.updateViewMatrix()

        self.scene.water.reflectionBuffer.unbindFramebuffer(displayWidth: width, displayHeight: height)
    }

    func renderRefraction() {
        self.scene.water.refractionBuffer.bindFramebuffer()
        // Clear the color and depth buffers
        glClearColor(0.07, 0.13, 0.17, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        shaderManager.setUniform("plane",       value: SIMD4<Float>(0.0, -1.0, 0.0, 0.0));

        renderScene(plane: SIMD4<Float>(0.0, -1.0, 0.0, 0.0))
        renderLight()

        self.scene.water.refractionBuffer.unbindFramebuffer(displayWidth: width, displayHeight: height)
    }

    func renderHdr() {
        self.scene.hdrFramebuffer.bindFramebuffer()
        // Clear the color and depth buffers
        glClearColor(0.07, 0.13, 0.17, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glDisable(GLenum(GL_BLEND))

        renderScene(plane: SIMD4<Float>(0.0, 1.0, 0.0, 10000))
        renderLight()
        renderWater()

        self.scene.hdrFramebuffer.unbindFramebuffer(displayWidth: width, displayHeight: height)
    }

    func renderWater() {
        shaderManager.use(shaderName: "waterShader")
        shaderManager.setUniform("model", value: scene.water.modelMatrix)
        shaderManager.setUniform("view", value: camera.viewMatrix)
        shaderManager.setUniform("proj", value: camera.projectionMatrix)
        shaderManager.setUniform("reflectionTexture", value: Int32(0))
        shaderManager.setUniform("refractionTexture", value: Int32(1))
        shaderManager.setUniform("dudvMap",           value: Int32(2))
        shaderManager.setUniform("normalMap",         value: Int32(3))
        shaderManager.setUniform("moveFactor",        value: scene.water.moveFactor)
        shaderManager.setUniform("cameraPos",         value: camera.position)
        if let light = scene.light {
            let position = SIMD3<Float>(
                light.modelMatrix.columns.3.x,
                light.modelMatrix.columns.3.y,
                light.modelMatrix.columns.3.z
            )
            shaderManager.setUniform("lightPos",      value: position)
            shaderManager.setUniform("lightColor",    value: light.lightColor)
        }
        scene.water.draw()
    }

    func renderCloud() {
        // Sky mode: a horizon-spanning slab between cloudBase and cloudTop.
        // Box mode: the original small debug volume at (10,10,0).
        let cloudBase: Float
        let cloudTop: Float
        let worldNoiseScale: Float
        let fadeStart: Float
        let fadeEnd: Float
        let lightMarchDist: Float
        let maxRayDist: Float   // longest useful ray; uSteps are budgeted over it
        let curveR: Float       // fake planet radius for the horizon curvature
        if cloudConfig.skyLayer {
            cloudBase = cloudConfig.cloudBase
            cloudTop = max(cloudConfig.cloudTop, cloudConfig.cloudBase + 10.0)
            worldNoiseScale = cloudConfig.worldNoiseScale
            fadeStart = 600.0
            fadeEnd = 950.0
            lightMarchDist = 80.0
            maxRayDist = fadeEnd * 1.05
            curveR = 3500.0
            // The slab is only the raymarch bounding volume (noise is sampled
            // in world space), so it follows the camera in x/z: there is
            // always cloud volume out to the fade in every direction and its
            // edges can never be approached. The bottom sits exactly at the
            // layer base, so clouds never reach below it; the curvature only
            // thins the distant deck from above instead of sinking it.
            let slabBottom = cloudBase
            let slabSize = 2.2 * fadeEnd
            scene.cloud.modelMatrix = float4x4.translation(SIMD3<Float>(camera.position.x, (slabBottom + cloudTop) * 0.5, camera.position.z))
                * float4x4.scale(SIMD3<Float>(slabSize, cloudTop - slabBottom, slabSize))
        } else {
            cloudBase = 8.0
            cloudTop = 12.0
            worldNoiseScale = 8.0
            fadeStart = 1e6
            fadeEnd = 2e6
            lightMarchDist = 5.0
            maxRayDist = 8.0    // ~the debug box diagonal: full step density
            curveR = 1e9        // effectively flat for the debug box
            scene.cloud.modelMatrix = float4x4.translation(SIMD3<Float>(10.0, 10.0, 0.0))
                * float4x4.scale(SIMD3<Float>(4.0, 2.0, 4.0))
        }

        // The half-res path needs the scene depth as a texture; resolve the
        // multisampled default framebuffer's depth before leaving it.
        let useHalfRes = cloudConfig.halfRes
        let useDepth = useHalfRes && resolveSceneDepth()

        shaderManager.use(shaderName: "cloudShader")
        shaderManager.setUniform("model", value: scene.cloud.modelMatrix)
        shaderManager.setUniform("invModel", value: scene.cloud.modelMatrix.inverse)
        shaderManager.setUniform("uCloudBase",       value: cloudBase)
        shaderManager.setUniform("uCloudTop",        value: cloudTop)
        shaderManager.setUniform("uWorldNoiseScale", value: worldNoiseScale)
        shaderManager.setUniform("uFadeStart",       value: fadeStart)
        shaderManager.setUniform("uFadeEnd",         value: fadeEnd)
        shaderManager.setUniform("uLightMarchDist",  value: lightMarchDist)
        shaderManager.setUniform("uMaxRayDist",      value: maxRayDist)
        shaderManager.setUniform("uCurveR",          value: curveR)
        shaderManager.setUniform("uUseDepth",        value: Int32(useDepth ? 1 : 0))
        // Always keep uSceneDepth on unit 1: a sampler2D left at its default
        // (unit 0, where the sampler3D noise lives) makes the whole draw call
        // invalid, even when the uUseDepth branch never samples it.
        shaderManager.setUniform("uSceneDepth",      value: Int32(1))
        if useDepth {
            shaderManager.setUniform("uCloudPassSize", value: SIMD2<Float>(Float(cloudFramebuffer.width), Float(cloudFramebuffer.height)))
            shaderManager.setUniform("uCamForward",  value: camera.front)
            shaderManager.setUniform("uNear",        value: Float(0.1))
            shaderManager.setUniform("uFar",         value: Float(1000.0))
            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(GLenum(GL_TEXTURE_2D), depthResolveFramebuffer.texture.ID)
            glActiveTexture(GLenum(GL_TEXTURE0))
        }
        shaderManager.setUniform("view", value: camera.viewMatrix)
        shaderManager.setUniform("proj", value: camera.projectionMatrix)
        shaderManager.setUniform("tex0", value: Int32(0))
        shaderManager.setUniform("cameraPos", value: camera.position)

        var windDir = SIMD3<Float>(cloudConfig.windDirX, 0.0, cloudConfig.windDirZ)
        windDir = length(windDir) > 1e-4 ? normalize(windDir) : SIMD3<Float>(1.0, 0.0, 0.0)

        shaderManager.setUniform("uCoverage",        value: cloudConfig.coverage)
        shaderManager.setUniform("uDensityScale",    value: cloudConfig.densityScale)
        shaderManager.setUniform("uAbsorption",      value: cloudConfig.absorption)
        shaderManager.setUniform("uDarkness",        value: cloudConfig.darkness)
        shaderManager.setUniform("uPhaseG",          value: cloudConfig.phaseG)
        shaderManager.setUniform("uScatterStrength", value: cloudConfig.scatterStrength)
        shaderManager.setUniform("uTiling",          value: cloudConfig.tiling)
        shaderManager.setUniform("uDetailWeight",    value: cloudConfig.detailWeight)
        shaderManager.setUniform("uSteps",           value: cloudConfig.steps)
        shaderManager.setUniform("uLightSteps",      value: cloudConfig.lightSteps)
        shaderManager.setUniform("uTime",            value: time)
        shaderManager.setUniform("uWindDir",         value: windDir)
        shaderManager.setUniform("uWindSpeed",       value: cloudConfig.windSpeed)
        shaderManager.setUniform("uEvolveSpeed",     value: cloudConfig.evolveSpeed)

        if let light = scene.light {
            // The scene light is a sphere orbiting its spawn point at ~100
            // units - useless as a positional sun for a 1900-unit cloud
            // layer. Its offset from the orbit center gives the celestial
            // direction instead, so the whole sky shares one sun direction.
            let position = SIMD3<Float>(
                light.modelMatrix.columns.3.x,
                light.modelMatrix.columns.3.y,
                light.modelMatrix.columns.3.z
            )
            let orbitCenter = SIMD3<Float>(
                light.positionMatrix.columns.3.x,
                light.positionMatrix.columns.3.y,
                light.positionMatrix.columns.3.z
            )
            let offset = position - orbitCenter
            let sunDir = length(offset) > 1e-3 ? normalize(offset) : SIMD3<Float>(0.0, 1.0, 0.0)
            shaderManager.setUniform("uSunDir",     value: sunDir)
            shaderManager.setUniform("lightColor",  value: light.lightColor)
        } else {
            // No light in the scene yet: fall back to a fixed daylight sun
            shaderManager.setUniform("uSunDir",     value: normalize(SIMD3<Float>(0.5, 0.7, 0.2)))
            shaderManager.setUniform("lightColor",  value: SIMD3<Float>(0.9, 0.9, 0.9))
        }

        if useHalfRes {
            cloudFramebuffer.bindFramebuffer()
            glClearColor(0.0, 0.0, 0.0, 0.0)
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            scene.cloud.draw()
            cloudFramebuffer.unbindFramebuffer(displayWidth: width, displayHeight: height)
            compositeClouds()
        } else {
            scene.cloud.draw()
        }
    }

    // Blit-resolves the multisampled default framebuffer's depth into a
    // sampleable texture. Returns false (and stops trying) if the driver
    // rejects the blit; clouds then simply skip depth occlusion.
    func resolveSceneDepth() -> Bool {
        if !depthResolveWorks {
            return false
        }
        while glGetError() != GLenum(GL_NO_ERROR) {}
        glBindFramebuffer(GLenum(GL_READ_FRAMEBUFFER), 0)
        glBindFramebuffer(GLenum(GL_DRAW_FRAMEBUFFER), depthResolveFramebuffer.framebuffer)
        let w = width * 2
        let h = height * 2
        glBlitFramebuffer(0, 0, w, h, 0, 0, w, h, GLbitfield(GL_DEPTH_BUFFER_BIT), GLenum(GL_NEAREST))
        let err = glGetError()
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
        if err != GLenum(GL_NO_ERROR) {
            depthResolveWorks = false
            Logger.info("Cloud depth resolve blit failed (GL error \(err)); cloud depth occlusion disabled")
            return false
        }
        return true
    }

    // Draws the half-res cloud texture over the scene. The cloud pass output
    // is premultiplied, so the same ONE / ONE_MINUS_SRC_ALPHA blend applies.
    func compositeClouds() {
        shaderManager.use(shaderName: "cloudCompositeShader")
        shaderManager.setUniform("uCloudTex", value: Int32(0))
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), cloudFramebuffer.texture.ID)

        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        glDisable(GLenum(GL_DEPTH_TEST))
        cloudCompositeQuad.draw()
        glEnable(GLenum(GL_DEPTH_TEST))
        glDisable(GLenum(GL_BLEND))
    }

    func renderScene(plane: SIMD4<Float>) {
        // Clear the color and depth buffers
        glClearColor(0.07, 0.13, 0.17, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        let viewMatrix = getViewMatrixWithoutTranslation(from: camera.viewMatrix)
        shaderManager.use(shaderName: "skyboxShader")
        shaderManager.setUniform("view",    value: viewMatrix)
        shaderManager.setUniform("proj",    value: camera.projectionMatrix)
        shaderManager.setUniform("skybox",  value: GLuint(0))
        scene.skybox?.draw()

        shaderManager.use(shaderName: "terrainShader")
        shaderManager.setUniform("view", value: camera.viewMatrix)
        shaderManager.setUniform("proj", value: camera.projectionMatrix)
        shaderManager.setUniform("visualizeNormals", value: inputManager.toggleNormal)
        shaderManager.setUniform("objectColor", value: SIMD3<Float>(1.0, 0.5, 0.31));
        if let light = scene.light {
            let position = SIMD3<Float>(
                light.modelMatrix.columns.3.x,
                light.modelMatrix.columns.3.y,
                light.modelMatrix.columns.3.z
            )
            shaderManager.setUniform("lightPos",    value: position)
            shaderManager.setUniform("lightColor",  value: light.lightColor)
        }
        shaderManager.setUniform("plane", value: plane)
        scene.terrain.draw()


        for model in scene.models {
            shaderManager.use(shaderName: model.shaderName)
            if let lightModel = model as? LightModel {
                shaderManager.setUniform("model", value: lightModel.modelMatrix)
            }
            if let objectModel = model as? ObjectModel {
                shaderManager.setUniform("model", value: objectModel.modelMatrix)
            }
            shaderManager.setUniform("view", value: camera.viewMatrix)
            shaderManager.setUniform("proj", value: camera.projectionMatrix)
            shaderManager.setUniform("tex0", value: GLuint(0))
            shaderManager.setUniform("visualizeNormals", value: inputManager.toggleNormal)
            shaderManager.setUniform("cameraPos", value: camera.position)
            if let light = scene.light {
                let position = SIMD3<Float>(
                    light.modelMatrix.columns.3.x,
                    light.modelMatrix.columns.3.y,
                    light.modelMatrix.columns.3.z
                )
                shaderManager.setUniform("lightPos",    value: position)
                shaderManager.setUniform("lightColor",  value: light.lightColor)
            }
            shaderManager.setUniform("rotation_x", value: self.rotation_x)
            shaderManager.setUniform("rotation_y", value: self.rotation_y)
            shaderManager.setUniform("plane", value: plane)
            model.draw()
        }

        if (inputManager.toggleNormal) {
            shaderManager.use(shaderName: "normalShader")
            shaderManager.setUniform("view", value: camera.viewMatrix)
            shaderManager.setUniform("proj", value: camera.projectionMatrix)
            shaderManager.setUniform("visualizeNormals", value: inputManager.toggleNormal)
            shaderManager.setUniform("rotation_x", value: self.rotation_x)
            shaderManager.setUniform("rotation_y", value: self.rotation_y)
            for model in scene.models {
                model.draw()
            }
        }


//        shaderManager.use(shaderName: "infiniteGridShader")
//        shaderManager.setUniform("view", value: camera.viewMatrix)
//        shaderManager.setUniform("proj", value: camera.projectionMatrix)
//        shaderManager.setUniform("cameraPos", value: camera.position)
//        scene.grid?.draw2()

    }

    func renderLight() {
        if let light = scene.light {
            shaderManager.use(shaderName: light.shaderName)
            shaderManager.setUniform("model",       value: light.modelMatrix)
            shaderManager.setUniform("view",        value: camera.viewMatrix)
            shaderManager.setUniform("proj",        value: camera.projectionMatrix)
            shaderManager.setUniform("lightColor",  value: light.lightColor)
            scene.light?.draw()
        }
    }

    func renderGui() {
        for gui in guiElements {
            shaderManager.use(shaderName: gui.shaderName)
            gui.draw()
        }

    }

    func update(deltaTime: Float, config: config_t) {
        // Update rotations based on user input
        rotation_x += deltaTime
        rotation_y += deltaTime
        time += deltaTime

        scene.update(deltaTime: deltaTime, input: inputManager, camera: camera, config: config)

        camera.move(delta: inputManager.deltaPosition)
        camera.rotate(yaw: inputManager.deltaYaw, pitch: inputManager.deltaPitch)

        let aspectRatio = Float(width) / Float(height)
        camera.update(aspectRatio: aspectRatio)
    }
}
