import simd
import OpenGL.GL3

// C imports
import ShaderModule
import GraphicsModule
import TextureModule

// Main function
func liviaRender(window: OpaquePointer, width: Int32, height: Int32) {

    var dt: Float = 0.000001
    var lastFrameTime: Float = Float(glfwGetTime())
    var title: String = ""

    let liviaMesh = Mesh(vertices: liviaVertices, indices: liviaIndices)

    let liviaTexture = texture("resources/livia.png", GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE0), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE))
    let liviaTexture2 = texture("resources/livia2.png", GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE0), GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE))

    // Create the scene
    let scene = Scene()

    // Positions for the cubes
    let liviaPositionsTextures: [(SIMD3<Float>, texture_t)] = [
        ( SIMD3( 0.0,  0.0,    0.0 ), liviaTexture2 ),
        ( SIMD3( 2.0,  5.0,  -15.0 ), liviaTexture2 ),
        ( SIMD3(-1.5, -2.2,   -2.5 ), liviaTexture2 ),
        ( SIMD3(-3.8, -2.0,  -12.3 ), liviaTexture2 ),
        ( SIMD3( 2.4, -0.4,   -3.5 ), liviaTexture2 ),
        ( SIMD3(-1.7,  3.0,   -7.5 ), liviaTexture  ),
        ( SIMD3( 1.3, -2.0,   -2.5 ), liviaTexture  ),
        ( SIMD3( 1.5,  2.0,   -2.5 ), liviaTexture  ),
        ( SIMD3( 1.5,  0.2,   -1.5 ), liviaTexture  ),
        ( SIMD3(-1.3,  1.0,   -1.5 ), liviaTexture  ),
    ]

    // Create a model for each cube position
    for positionTexture in liviaPositionsTextures {
        let model = Model(mesh: liviaMesh, shaderName: "basicShader", texture: positionTexture.1)
        // Apply translation to position the cube
        model.modelMatrix = float4x4.translation(positionTexture.0)

        // Apply random rotation
        let rotationXMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(0, 1, 0))
        let rotationYMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(1, 0, 0))
        model.modelMatrix = model.modelMatrix * rotationXMatrix * rotationYMatrix

        scene.models.append(model)
    }

    let renderer = Renderer(width: width, height: height, scene: scene)
    renderer.shaderManager.loadShader(name: "basicShader", vertexPath: "resources/shader/baseCube.vert", fragmentPath: "resources/shader/baseCube.frag")

    var totalFrames: Int = 0
    let TARGET_FPS: Float = 60.0

    // Main render loop
    while glfwWindowShouldClose(window) == 0 {
        renderer.inputManager.processInput(window: window)
        renderer.update(deltaTime: dt)
        renderer.render()

        // Swap buffers and poll events
        glfwSwapBuffers(window)
        glfwPollEvents()

        // Update the window title every 60 frames
        if totalFrames % 60 == 0 {
            title = String(format: "FPS : %-4.0f", 1.0 / dt)
            glfwSetWindowTitle(window, title)
        }

        // Frame timing
        dt = Float(glfwGetTime()) - lastFrameTime
        while dt < 1.0 / TARGET_FPS {
            dt = Float(glfwGetTime()) - lastFrameTime
        }
        lastFrameTime = Float(glfwGetTime())
        totalFrames += 1
    }
}
