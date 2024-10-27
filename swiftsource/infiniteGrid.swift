import simd
import OpenGL.GL3
import CGLFW3
import ShaderModule
import GraphicsModule
import TextureModule
import Darwin.C

// Assume these custom types and functions are defined elsewhere:
// - SIMD3<Float> (a struct representing a 3D vector)
// - scale_pos_t (a struct containing 'scale' and 'position' of type SIMD3<Float>)
// - createShader (a function to create and compile shaders)
// - processInputSwift (a function to handle user input)
// - totalFrames and TARGET_FPS (global variables)

func infiniteGrid(window: OpaquePointer!, width: Int32, height: Int32) {
    // Create shader program
    let phongShader = createShader("resources/shader/baseVertex.glsl", "resources/shader/base.glsl")
//    let phongShader = createShader("resources/shader/infiniteGrid.vert", "resources/shader/infiniteGrid.frag")

    var dt: Float = 0.000001
    var lastFrameTime: Float = Float(glfwGetTime())

    // Initialize vectors
    let VEC_INIT = SIMD3<Float>(x: 1.0, y: 1.0, z: 1.0)
    let VEC_CLEAR = SIMD3<Float>(x: 0.0, y: 0.0, z: 0.0)
    var scale_pos = scale_pos_t(scale: VEC_INIT, position: VEC_CLEAR)

    let vertices: [GLfloat] = [
        -1.0, -1.0, 0.0, // Bottom-left vertex
         1.0, -1.0, 0.0, // Bottom-right vertex
        -1.0,  1.0, 0.0, // Top-left vertex
         1.0,  1.0, 0.0  // Top-right vertex
    ]

    var quadVBO: GLuint = 0
    var quadVAO: GLuint = 0
    glGenVertexArrays(1, &quadVAO)
    glGenBuffers(1, &quadVBO)

    glBindVertexArray(quadVAO)
    glBindBuffer(GLenum(GL_ARRAY_BUFFER), quadVBO)
    glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.count * MemoryLayout<GLfloat>.size, vertices, GLenum(GL_STATIC_DRAW))
    glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(3 * MemoryLayout<GLfloat>.size), nil)
    glEnableVertexAttribArray(0)

    // Main loop
    while glfwWindowShouldClose(window) == GLFW_FALSE {
        processInputSwift(window:window, scalePos: &scale_pos)

        glClearColor(0.0, 0.0, 0.0, 1.0)

        var depthFuncValue: GLint = 0
        glGetIntegerv(GLenum(GL_DEPTH_FUNC), &depthFuncValue)
        glClearDepth(depthFuncValue == GL_LESS ? 1.0 : 0.0)

        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))

        // Render here
        glUseProgram(phongShader)

        // Set uniforms
        let scaleLocation = glGetUniformLocation(phongShader, "uScale")
        withUnsafePointer(to: &scale_pos.scale.x) {
            $0.withMemoryRebound(to: GLfloat.self, capacity: 3) {
                glUniform3fv(scaleLocation, 1, $0)
            }
        }

        let positionLocation = glGetUniformLocation(phongShader, "uPosition")
        withUnsafePointer(to: &scale_pos.position.x) {
            $0.withMemoryRebound(to: GLfloat.self, capacity: 3) {
                glUniform3fv(positionLocation, 1, $0)
            }
        }

        glUniform3f(glGetUniformLocation(phongShader, "gCameraWorldPos"), 0.0, 0.0, 0.0)
        glUniform2f(glGetUniformLocation(phongShader, "iResolution"), GLfloat(width), GLfloat(height))
        glUniform1f(glGetUniformLocation(phongShader, "iTime"), GLfloat(glfwGetTime()))

        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)

        if totalFrames % 60 == 0 {
            let fps = 1.0 / dt
            let version = String(cString: glGetString(GLenum(GL_VERSION)))
            let titleString = "FPS: \(Int(fps)) \(version)"
            glfwSetWindowTitle(window, titleString)
        }

        glfwSwapBuffers(window)
        glfwPollEvents()

        // Timing
        dt = Float(glfwGetTime()) - lastFrameTime
        while dt < 1.0 / Float(TARGET_FPS) {
            dt = Float(glfwGetTime()) - lastFrameTime
        }
        lastFrameTime = Float(glfwGetTime())
        totalFrames += 1
    }

    glfwTerminate()
}
