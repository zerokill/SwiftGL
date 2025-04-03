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

    init(width: Int32, height: Int32, scene: Scene) {
        camera = Camera(position: SIMD3(0.0, 10.0, 0.0), target: SIMD3(0.0, 0.0, 0.0), worldUp: SIMD3(0.0, 1.0, 0.0))
        inputManager = InputManager()
        shaderManager = ShaderManager()
        self.width = width
        self.height = height

        self.scene = scene

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

    func render(deltaTime: Float) {
        ImGuiWrapper_Text(String(format: "test"))
        renderReflection()
        renderRefraction()
//        renderHdr()
        renderScene(plane: SIMD4<Float>(0.0, 1.0, 0.0, 10000))
        renderWater()
        renderLight()
        renderCloud(deltaTime: deltaTime)

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

    func renderCloud(deltaTime: Float) {
        shaderManager.use(shaderName: "cloud2Shader")
        shaderManager.setUniform("model",           value: scene.cloud.modelMatrix)
        shaderManager.setUniform("view",            value: camera.viewMatrix)
        shaderManager.setUniform("proj",            value: camera.projectionMatrix)
        shaderManager.setUniform("tex0",            value: GLuint(0))
        shaderManager.setUniform("noiseTexture",    value: GLuint(1))
        shaderManager.setUniform("cameraPos",       value: camera.position)
        shaderManager.setUniform("uTime",           value: deltaTime)
        if let light = scene.light {
            let position = SIMD3<Float>(
                light.modelMatrix.columns.3.x,
                light.modelMatrix.columns.3.y,
                light.modelMatrix.columns.3.z
            )
            shaderManager.setUniform("lightPos",    value: position)
            shaderManager.setUniform("lightColor",  value: light.lightColor)
        }
        scene.cloud.draw()

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

        scene.update(deltaTime: deltaTime, input: inputManager, camera: camera, config: config)

        camera.move(delta: inputManager.deltaPosition)
        camera.rotate(yaw: inputManager.deltaYaw, pitch: inputManager.deltaPitch)

        let aspectRatio = Float(width) / Float(height)
        camera.update(aspectRatio: aspectRatio)
    }
}
