import CGLFW3
import simd

func cubeExample(window: OpaquePointer!, width: Int32, height: Int32) {
//    let renderer = Renderer()
//
//    renderer.shaderManager.loadShader(name: "basicShader", vertexPath: "resources/vertexShader.glsl", fragmentPath: "resources/fragmentShader.glsl")
//
//    // Create a single cube mesh
//    let cubeMesh = Mesh(vertices: cubeVertices, indices: cubeIndices)
//
//    // Create the scene
//    let scene = Scene()
//
//    // Array to hold all models in the scene
//    var models: [Model] = []
//
//    // Positions for the cubes
//    let cubePositions: [SIMD3<Float>] = [
//        SIMD3(0.0,  0.0,   0.0),
//        SIMD3(2.0,  5.0, -15.0),
//        SIMD3(-1.5, -2.2, -2.5),
//        SIMD3(-3.8, -2.0, -12.3),
//        SIMD3(2.4, -0.4, -3.5),
//        SIMD3(-1.7,  3.0, -7.5),
//        SIMD3(1.3, -2.0, -2.5),
//        SIMD3(1.5,  2.0, -2.5),
//        SIMD3(1.5,  0.2, -1.5),
//        SIMD3(-1.3,  1.0, -1.5),
//    ]
//
//    // Create a model for each cube position
//    for position in cubePositions {
//        let model = Model(mesh: cubeMesh, shaderName: "basicShader")
//        // Apply translation to position the cube
//        model.modelMatrix = float4x4.translation(position)
//        models.append(model)
//    }
//
////    // Example: Rotate each cube differently
////    for (index, model) in models.enumerated() {
////        let angle = Float(index) * radians(fromDegrees: 20.0)
////        let rotation = float4x4.rotation(radians: angle, axis: SIMD3<Float>(1.0, 0.3, 0.5))
////        model.modelMatrix = model.modelMatrix * rotation
////    }
//
//    var lastFrame = Float(glfwGetTime())
//
//    // Main render loop
//    while glfwWindowShouldClose(window) == GLFW_FALSE {
//        // Calculate deltaTime
//        let currentFrame = Float(glfwGetTime())
//        let deltaTime = currentFrame - lastFrame
//        lastFrame = currentFrame
//
//        // Process input
//        renderer.inputManager.processInput(window: window, camera: renderer.camera, deltaTime: deltaTime)
//
//        // Update scene (animations, physics, etc.)
//        renderer.update(deltaTime: deltaTime)
//
//        // Render the scene
//        renderer.render(scene: scene)
//
//        // Swap buffers and poll events
//        glfwSwapBuffers(window)
//        glfwPollEvents()
//    }
}
