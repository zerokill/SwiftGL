import simd
import OpenGL.GL3
import CGLFW3
import ShaderModule
import GraphicsModule
import TextureModule
import Darwin.C

// Assume these custom types and functions are defined elsewhere:
// - vec3_t (a struct representing a 3D vector)
// - scale_pos_t (a struct containing 'scale' and 'position' of type vec3_t)
// - createShader (a function to create and compile shaders)
// - processInputSwift (a function to handle user input)
// - totalFrames and TARGET_FPS (global variables)

var totalFrames = 0

func shadertoySwift(window: OpaquePointer!, width: Int32, height: Int32) {
    // Create shader program
    let phongShader = createShader("resources/shader/baseVertex.glsl", "resources/shader/base.glsl")

    var dt: Float = 0.000001
    var lastFrameTime: Float = Float(glfwGetTime())

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

// Main function
func cubeShaderSwift(window: OpaquePointer, width: Int32, height: Int32) {
    // Initialize shader program
    let phongShader: GLuint = createShader("resources/shader/baseCube.vert", "resources/shader/baseCube.frag")

    var dt: Float = 0.000001
    var lastFrameTime: Float = Float(glfwGetTime())
    var title: String = ""

    // Initialize scale and position
    let VEC_INIT = vec3_t(x: 1.0, y: 1.0, z: 1.0)
    let VEC_CLEAR = vec3_t(x: 0.0, y: 0.0, z: 0.0)
    var scale_pos = scale_pos_t(scale: VEC_INIT, position: VEC_CLEAR)

    // Vertices coordinates
    let vertices: [GLfloat] = [
        //  Positions       //   Colors        // Texture Coords
        -0.5, 0.0,  0.5,   0.83, 0.70, 0.44,   0.0, 0.0,
        -0.5, 0.0, -0.5,   0.83, 0.70, 0.44,   5.0, 0.0,
         0.5, 0.0, -0.5,   0.83, 0.70, 0.44,   0.0, 0.0,
         0.5, 0.0,  0.5,   0.83, 0.70, 0.44,   5.0, 0.0,
         0.0, 0.8,  0.0,   0.92, 0.86, 0.76,   2.5, 5.0
    ]

    // Indices for vertices order
    let indices: [GLuint] = [
        0, 1, 2,
        0, 2, 3,
        0, 1, 4,
        1, 2, 4,
        2, 3, 4,
        3, 0, 4
    ]

    // Generate and bind VAO, VBO, and EBO
    var VBO: GLuint = 0
    var VAO: GLuint = 0
    var EBO: GLuint = 0

    glGenVertexArrays(1, &VAO)
    glGenBuffers(1, &VBO)
    glGenBuffers(1, &EBO)

    glBindVertexArray(VAO)

    // Bind and set VBO
    glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
    glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.count * MemoryLayout<GLfloat>.size, vertices, GLenum(GL_STATIC_DRAW))

    // Bind and set EBO
    glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), EBO)
    glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * MemoryLayout<GLuint>.size, indices, GLenum(GL_STATIC_DRAW))

    // Vertex attribute pointers
    let stride = GLsizei(8 * MemoryLayout<GLfloat>.size)

    // Position attribute
    glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, nil)
    glEnableVertexAttribArray(0)

    // Color attribute
    let colorOffset = UnsafeRawPointer(bitPattern: 3 * MemoryLayout<GLfloat>.size)
    glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, colorOffset)
    glEnableVertexAttribArray(1)

    // Texture coordinate attribute
    let texCoordOffset = UnsafeRawPointer(bitPattern: 6 * MemoryLayout<GLfloat>.size)
    glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, texCoordOffset)
    glEnableVertexAttribArray(2)

    glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    glBindVertexArray(0)
    glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)

    // Enable depth testing
    glEnable(GLenum(GL_DEPTH_TEST))

    // Load texture and set texture unit
    let popcat = texture("resources/livia.png", GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE0), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE))
    texUnit(popcat, phongShader, "tex0", 0)

    var rotation_x: Float = 0.0
    var rotation_y: Float = 0.0
    var totalFrames: Int = 0
    let TARGET_FPS: Float = 60.0

    // Main render loop
    while glfwWindowShouldClose(window) == 0 {
        processInputSwift(window:window, scalePos: &scale_pos)

        // Clear the color and depth buffers
        glClearColor(0.07, 0.13, 0.17, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))

        // Use the shader program
        glUseProgram(phongShader)

        // Initialize matrices
        var model = matrix_identity_float4x4
        var view = matrix_identity_float4x4
        var proj = matrix_identity_float4x4

        // Update rotations based on user input
        rotation_x = scale_pos.position.x * 50.0
        rotation_y = scale_pos.position.y * 50.0

        // Apply rotations to the model matrix
        let rotationXMatrix = float4x4(rotationAngle: radians(fromDegrees: rotation_x), axis: SIMD3<Float>(0, 1, 0))
        let rotationYMatrix = float4x4(rotationAngle: radians(fromDegrees: rotation_y), axis: SIMD3<Float>(1, 0, 0))
        model = model * rotationXMatrix * rotationYMatrix

        // Apply translation to the view matrix
        let translationMatrix = float4x4.translation(SIMD3<Float>(0.0, -0.5, -2.0))
        view = translationMatrix * view

        // Create the projection matrix
        let aspectRatio = Float(width) / Float(height)
        proj = float4x4.perspective(fovyRadians: radians(fromDegrees: 45.0), aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100.0)

        // Send matrices to the shader
        withUnsafePointer(to: &model) {
            $0.withMemoryRebound(to: Float.self, capacity: 16) { ptr in
                glUniformMatrix4fv(glGetUniformLocation(phongShader, "model"), 1, GLboolean(GL_FALSE), ptr)
            }
        }
        withUnsafePointer(to: &view) {
            $0.withMemoryRebound(to: Float.self, capacity: 16) { ptr in
                glUniformMatrix4fv(glGetUniformLocation(phongShader, "view"), 1, GLboolean(GL_FALSE), ptr)
            }
        }
        withUnsafePointer(to: &proj) {
            $0.withMemoryRebound(to: Float.self, capacity: 16) { ptr in
                glUniformMatrix4fv(glGetUniformLocation(phongShader, "proj"), 1, GLboolean(GL_FALSE), ptr)
            }
        }

        // Bind the texture
        glBindTexture(popcat.type, popcat.ID)

        // Set additional uniforms
        glUniform3f(glGetUniformLocation(phongShader, "uScale"), scale_pos.scale.x, scale_pos.scale.y, scale_pos.scale.z)
        glUniform3f(glGetUniformLocation(phongShader, "uPosition"), scale_pos.position.x, scale_pos.position.y, scale_pos.position.z)
        glUniform2f(glGetUniformLocation(phongShader, "iResolution"), GLfloat(width), GLfloat(height))
        glUniform1f(glGetUniformLocation(phongShader, "iTime"), GLfloat(glfwGetTime()))

        // Bind the VAO and draw the elements
        glBindVertexArray(VAO)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), nil)

        // Swap buffers and poll events
        glfwSwapBuffers(window)
        glfwPollEvents()

        // Update the window title every 60 frames
        if totalFrames % 60 == 0 {
            title = String(format: "FPS : %-4.0f rotation_x=%.2f rotation_y=%.2f", 1.0 / dt, rotation_x, rotation_y)
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

    // Clean up resources
    glDeleteVertexArrays(1, &VAO)
    glDeleteBuffers(1, &VBO)
    glDeleteBuffers(1, &EBO)
    glDeleteProgram(phongShader)
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
    scalePos.position.y = 0
    scalePos.position.x = 0
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
