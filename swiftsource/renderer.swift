import simd
import OpenGL.GL3

import TextureModule
import ShaderModule

class Renderer {
    var shaderManager: ShaderManager
    var camera: Camera
    var inputManager: InputManager
    var width: Int32
    var height: Int32

    var scene: Scene

    var rotation_x: Float = 0.0
    var rotation_y: Float = 0.0

    init(width: Int32, height: Int32, scene: Scene) {
        camera = Camera(position: SIMD3(0.0, 0.0, 3.0), target: SIMD3(0.0, 0.0, 0.0), worldUp: SIMD3(0.0, 1.0, 0.0))
        inputManager = InputManager()
        shaderManager = ShaderManager()
        self.width = width
        self.height = height

        self.scene = scene

        setupOpenGL()
    }

    func setupOpenGL() {
        glEnable(GLenum(GL_DEPTH_TEST))
    }

    func render() {
        // Clear the color and depth buffers
        glClearColor(0.07, 0.13, 0.17, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        shaderManager.use(shaderName: "basicShader")
        shaderManager.setUniform("view", value: camera.viewMatrix)
        shaderManager.setUniform("proj", value: camera.projectionMatrix)

        for model in scene.models {
            shaderManager.use(shaderName: model.shaderName)
            shaderManager.setUniform("texture", value: model.texture.ID)
            if (inputManager.updateRotation) {
                shaderManager.setUniform("rotation_x", value: self.rotation_x)
                shaderManager.setUniform("rotation_y", value: self.rotation_y)
            }
            model.draw()
        }
    }

    func update(deltaTime: Float) {
        // Update animations or other time-dependent features

        // Update rotations based on user input
        rotation_x += deltaTime
        rotation_y += deltaTime

        if (inputManager.liviaMove && !inputManager.liviaMoved) {
            for model in scene.models {
                model.shootInstance(position: camera.position, direction: camera.front, enableExplode: true)
            }
        }
        if (inputManager.liviaResetMove) {
            for model in scene.models {
                model.resetAllInstances()
            }
        }

        for model in scene.models {

            model.updateMove(deltaTime: deltaTime, updateVelocity: inputManager.updateVelocity, updateRotation: inputManager.updateRotation)
        }

        camera.move(delta: inputManager.deltaPosition)
        camera.rotate(yaw: inputManager.deltaYaw, pitch: inputManager.deltaPitch)

        let aspectRatio = Float(width) / Float(height)
        camera.update(aspectRatio: aspectRatio)
    }
}
