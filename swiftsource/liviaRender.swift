import simd
import OpenGL.GL3

// C imports
import ShaderModule
import GraphicsModule
import TextureModule
import ImguiModule

// Main function
func liviaRender(window: OpaquePointer, width: Int32, height: Int32) {

    var dt: Float = 0.000001
    var lastFrameTime: Float = Float(glfwGetTime())
    var startTime: Float = Float(glfwGetTime())
    var updateTime: Float = Float(glfwGetTime())
    var renderTime: Float = Float(glfwGetTime())
    var title: String = ""

    let liviaTexture = texture("resources/livia.png", GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE0), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE))
    let leonTexture = texture("resources/leon.png", GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE0), GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE))
    let sheepTexture = texture("resources/sheep.jpg", GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE0), GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE))

    ResourceManager.shared.loadTexture(name: "liviaTexture", texture: liviaTexture)
    ResourceManager.shared.loadTexture(name: "leonTexture", texture: leonTexture)
    ResourceManager.shared.loadTexture(name: "sheepTexture", texture: sheepTexture)

    if let texture = ResourceManager.shared.getTexture(name: "leonTexture") {
        let leonSpereParameters = SphereParameters(radius: 0.2, latitudeBands: 20, longitudeBands: 20)
        let leonSphere = LeonMesh(sphere: leonSpereParameters)
        let leonModel = LeonModel(mesh: leonSphere, shaderName: "baseCube", texture: texture)
        leonModel.setupInstances()
        ResourceManager.shared.loadModel(name: "leonModel", model: leonModel)
    }
        
    if let texture = ResourceManager.shared.getTexture(name: "liviaTexture") {
        let liviaPyramid = generateFlatShadedPyramid()
        let liviaMesh = Mesh(vertices: liviaPyramid.vertices, indices: liviaPyramid.indices, maxInstanceCount: 1000)
        let liviaModel = LiviaModel(mesh: liviaMesh, shaderName: "baseCube", texture: texture)
        liviaModel.setupRandomInstances(randomPosition: true)
        ResourceManager.shared.loadModel(name: "liviaModel", model: liviaModel)
    }

    Logger.info("resource loading done");

    // Create the scene
    let scene = Scene()

    let gridVertices: [Vertex] = [
        Vertex(position: SIMD3<Float>(-1.0, -1.0, 0.0),   normal: SIMD3<Float>(),   texCoords: SIMD2<Float>()),
        Vertex(position: SIMD3<Float>( 1.0, -1.0, 0.0),   normal: SIMD3<Float>(),   texCoords: SIMD2<Float>()),
        Vertex(position: SIMD3<Float>(-1.0,  1.0, 0.0),   normal: SIMD3<Float>(),   texCoords: SIMD2<Float>()),
        Vertex(position: SIMD3<Float>( 1.0,  1.0, 0.0),   normal: SIMD3<Float>(),   texCoords: SIMD2<Float>()),
    ]
    let gridMesh = Mesh(vertices: gridVertices, indices: [], maxInstanceCount: 1)
    scene.grid = gridMesh

    let renderer = Renderer(width: width, height: height, scene: scene)
    renderer.shaderManager.loadShader(name: "baseCube", vertexPath: "resources/shader/baseCube.vert", geometryPath: nil, fragmentPath: "resources/shader/baseCube.frag")
    renderer.shaderManager.loadShader(name: "lightShader", vertexPath: "resources/shader/lightShader.vert", geometryPath: nil, fragmentPath: "resources/shader/lightShader.frag")
    renderer.shaderManager.loadShader(name: "objectShader", vertexPath: "resources/shader/objectShader.vert", geometryPath: nil, fragmentPath: "resources/shader/objectShader.frag")
    renderer.shaderManager.loadShader(name: "normalShader", vertexPath: "resources/shader/normalShader.vert", geometryPath: "resources/shader/normalShader.geom", fragmentPath: "resources/shader/normalShader.frag")
    renderer.shaderManager.loadShader(name: "infiniteGridShader", vertexPath: "resources/shader/infiniteGrid.vert", geometryPath: nil, fragmentPath: "resources/shader/infiniteGrid.frag")

    var totalFrames: Int = 0
    let TARGET_FPS: Float = 60.0

    // Initialize ImGui
    if ImGuiWrapper_Init(window) {
        print("ImGui initialized successfully.")
    } else {
        print("Failed to initialize ImGui.")
        return
    }

    var stats: stats_t = stats_t(numLivia: 0, numLeon: 0, fps: 0.0, updateTime: 0.0, renderTime: 0.0, updateTimeHigh: 0.0, renderTimeHigh: 0.0)

    // Main render loop
    while glfwWindowShouldClose(window) == 0 {
        startTime = Float(glfwGetTime())
        renderer.inputManager.processInput(window: window)
        renderer.update(deltaTime: dt)
        updateTime = Float(glfwGetTime())
        renderer.render()
        renderTime = Float(glfwGetTime())

        if let leonModel = renderer.scene.models[0] as? LeonModel {
            stats.numLeon = Int32(leonModel.activeInstances)
        }
        if let liviaModel = renderer.scene.models[1] as? LiviaModel {
            stats.numLivia = Int32(liviaModel.activeInstances)
        }
        stats.fps = 1.0 / dt
        stats.updateTime = updateTime - startTime
        stats.updateTimeHigh = stats.updateTimeHigh > stats.updateTime ? stats.updateTimeHigh : stats.updateTime
        stats.renderTime = renderTime - updateTime
        stats.renderTimeHigh = stats.renderTimeHigh > stats.renderTime ? stats.renderTimeHigh : stats.renderTime

        ImGuiWrapper_Render(stats)

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
