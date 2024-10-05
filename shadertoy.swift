import OpenGL.GL3
import CGLFW3
import ShaderModule
import GraphicsModule
import Darwin.C

// Assume these custom types and functions are defined elsewhere:
// - vec3_t (a struct representing a 3D vector)
// - scale_pos_t (a struct containing 'scale' and 'position' of type vec3_t)
// - createShader (a function to create and compile shaders)
// - processInputSwift (a function to handle user input)
// - totalFrames and TARGET_FPS (global variables)

var totalFrames = 0

func shadertoy(window: OpaquePointer!, width: Int32, height: Int32) -> Int32 {
    // Create shader program
    let phongShader = createShader("src/shader/baseVertex.glsl", "src/shader/base.glsl")

    var dt: Float = 0.000001
    var lastFrameTime: Float = Float(glfwGetTime())

    var title = [CChar](repeating: 0, count: 100)

    // Initialize vectors
    let VEC_INIT = vec3_t(x: 1.0, y: 1.0, z: 1.0)
    let VEC_CLEAR = vec3_t(x: 0.0, y: 0.0, z: 0.0)
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
        processInputSwift(window: window, scalePos: &scale_pos)

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
    return 0
}


func processInputSwift(window: OpaquePointer!, scalePos: inout scale_pos_t) {
    if (glfwGetKey(window, Int32(GLFW_KEY_ESCAPE)) == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GLFW_TRUE)
    }
    if (glfwGetKey(window, Int32(GLFW_KEY_1)) == GLFW_PRESS) {
        glPolygonMode(GLenum(GL_FRONT_AND_BACK), GLenum(GL_LINE))
    }
    if (glfwGetKey(window, Int32(GLFW_KEY_2)) == GLFW_PRESS) {
        glPolygonMode(GLenum(GL_FRONT_AND_BACK), GLenum(GL_FILL))
    }
    if (glfwGetKey(window, Int32(GLFW_KEY_3)) == GLFW_PRESS) {
        scalePos.scale.x += 0.01
        scalePos.scale.y += 0.01
        scalePos.scale.z = 0
    }
    if (glfwGetKey(window, Int32(GLFW_KEY_4)) == GLFW_PRESS) {
        scalePos.scale.x -= 0.01
        scalePos.scale.y -= 0.01
        scalePos.scale.z = 0
    }
    if (glfwGetKey(window, Int32(GLFW_KEY_5)) == GLFW_PRESS) {
        scalePos.scale.x = 0.3
        scalePos.scale.y = 0.3
        scalePos.scale.z = 0
    }
    if (glfwGetKey(window, Int32(GLFW_KEY_UP)) == GLFW_PRESS) {
        scalePos.position.y += 0.01
    }
    if (glfwGetKey(window, Int32(GLFW_KEY_DOWN)) == GLFW_PRESS) {
        scalePos.position.y -= 0.01
    }
    if (glfwGetKey(window, Int32(GLFW_KEY_LEFT)) == GLFW_PRESS) {
        scalePos.position.x -= 0.01
    }
    if (glfwGetKey(window, Int32(GLFW_KEY_RIGHT)) == GLFW_PRESS) {
        scalePos.position.x += 0.01
    }
}
