import simd
import OpenGL.GL3

import TextureModule
import ShaderModule

class Renderer {
    var shaderManager: ShaderManager
//    var camera: Camera
//    var inputManager: InputManager
//    var phongShader: GLuint
    var rotation_x: Float
    var rotation_y: Float
    var width: Int32
    var height: Int32

    var view: simd_float4x4
    var proj: simd_float4x4

    init(width: Int32, height: Int32) {
//        camera = Camera(position: SIMD3(0.0, 0.0, 3.0), target: SIMD3(0.0, 0.0, 0.0), up: SIMD3(0.0, 1.0, 0.0))
//        inputManager = InputManager()
        shaderManager = ShaderManager()
        self.width = width
        self.height = height

        // TODO: Why do we need to init everything?
        self.rotation_x = 0
        self.rotation_y = 0
        self.view = matrix_identity_float4x4
        self.proj = matrix_identity_float4x4

        setupOpenGL()
    }

    func setupOpenGL() {
        glEnable(GLenum(GL_DEPTH_TEST))
    }

    func render(scene: Scene) {
        // Clear the color and depth buffers
        glClearColor(0.07, 0.13, 0.17, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))


//        camera.update()

        shaderManager.use(shaderName: "basicShader")
        shaderManager.setUniform("view", value: view)
        shaderManager.setUniform("proj", value: proj)

        for model in scene.models {
            shaderManager.use(shaderName: model.shaderName)
            shaderManager.setUniform("model", value: model.modelMatrix)
            shaderManager.setUniform("texture", value: model.texture.ID)
            model.draw()
        }
    }

    func update(scene: Scene, deltaTime: Float, scale_pos: scale_pos_t) {
        view = matrix_identity_float4x4
        proj = matrix_identity_float4x4

        // Update animations or other time-dependent features

        // Update rotations based on user input
        rotation_x = (scale_pos.position.x * 50.0) + scale_pos.scale.x * 10 * deltaTime
        rotation_y = (scale_pos.position.y * 50.0) + scale_pos.scale.x * 10 * deltaTime

        for model in scene.models {
            // Apply rotations to the model matrix
            let rotationXMatrix = float4x4(rotationAngle: radians(fromDegrees: rotation_x), axis: SIMD3<Float>(0, 1, 0))
            let rotationYMatrix = float4x4(rotationAngle: radians(fromDegrees: rotation_y), axis: SIMD3<Float>(1, 0, 0))
            model.modelMatrix = model.modelMatrix * rotationXMatrix * rotationYMatrix
        }

        // Apply translation to the view matrix
        let translationMatrix = float4x4.translation(SIMD3<Float>(0.0, -0.5, -2.0))
        view = translationMatrix * view

        // Create the projection matrix
        let aspectRatio = Float(width) / Float(height)
        proj = float4x4.perspective(fovyRadians: radians(fromDegrees: 45.0), aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100.0)
    }
}
