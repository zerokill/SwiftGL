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

    init(width: Int32, height: Int32, scene: Scene) {
        camera = Camera(position: SIMD3(0.0, 0.0, 3.0), target: SIMD3(0.0, 0.0, 0.0), up: SIMD3(0.0, 1.0, 0.0))
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
            shaderManager.setUniform("model", value: model.modelMatrix)
            shaderManager.setUniform("texture", value: model.texture.ID)
            model.draw()
        }
    }

    func update(deltaTime: Float) {
        // Update animations or other time-dependent features

        // Update rotations based on user input
        let rotation_x = (inputManager.scalePos.position.x * 50.0) + inputManager.scalePos.scale.x * 10 * deltaTime
        let rotation_y = (inputManager.scalePos.position.y * 50.0) + inputManager.scalePos.scale.x * 10 * deltaTime

        let liviaInc = 100

        if (inputManager.liviaAdd) {
            for _ in 1...liviaInc {
                let randomPosition = SIMD3<Float>( Float.random(in: -10.0...10.0), Float.random(in: -10.0...10.0), Float.random(in: -10.0...10.0))
                let model = Model(mesh: scene.models[0].mesh, shaderName: "basicShader", texture: scene.models[0].texture)
                // Apply translation to position the cube
                model.modelMatrix = float4x4.translation(randomPosition)

                // Apply random rotation
                let rotationXMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(0, 1, 0))
                let rotationYMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(1, 0, 0))
                model.modelMatrix = model.modelMatrix * rotationXMatrix * rotationYMatrix

                scene.models.append(model)
            }
        }

        if (inputManager.liviaDelete && scene.models.count > liviaInc) {
            scene.models.removeFirst(liviaInc)
        }

        for model in scene.models {
            // Apply rotations to the model matrix
            let rotationXMatrix = float4x4(rotationAngle: radians(fromDegrees: rotation_x), axis: SIMD3<Float>(0, 1, 0))
            let rotationYMatrix = float4x4(rotationAngle: radians(fromDegrees: rotation_y), axis: SIMD3<Float>(1, 0, 0))
            model.modelMatrix = model.modelMatrix * rotationXMatrix * rotationYMatrix
        }

        camera.move(delta: inputManager.deltaPosition)
        camera.rotate(yaw: inputManager.deltaYaw, pitch: inputManager.deltaPitch)

        let aspectRatio = Float(width) / Float(height)
        camera.update(aspectRatio: aspectRatio)
    }
}
