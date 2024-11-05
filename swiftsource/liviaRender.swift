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
    let skyTexture = textureCubeMap(images: [
            "resources/skybox/right.jpg",
            "resources/skybox/left.jpg",
            "resources/skybox/top.jpg",
            "resources/skybox/bottom.jpg",
            "resources/skybox/front.jpg",
            "resources/skybox/back.jpg",
        ],
        texType: GLenum(GL_TEXTURE_CUBE_MAP), slot: GLenum(GL_TEXTURE0), format: GLenum(GL_RGB), pixelType: GLenum(GL_UNSIGNED_BYTE))

    ResourceManager.shared.loadTexture(name: "liviaTexture", texture: liviaTexture)
    ResourceManager.shared.loadTexture(name: "leonTexture", texture: leonTexture)
    ResourceManager.shared.loadTexture(name: "sheepTexture", texture: sheepTexture)
    ResourceManager.shared.loadTexture(name: "skyboxTexture", texture: skyTexture)

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

    let objectSpereParameters = SphereParameters(radius: 0.2, latitudeBands: 20, longitudeBands: 20)
    let objectSphere = LeonMesh(sphere: objectSpereParameters)
    ResourceManager.shared.loadMesh(name: "objectSphere", mesh: objectSphere)

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

    if let texture = ResourceManager.shared.getTexture(name: "skyboxTexture") {
        let skyboxMesh = CubeMesh()
        let skyboxModel = SkyboxModel(mesh: skyboxMesh, shaderName: "skyboxShader", texture: texture)
        scene.skybox = skyboxModel
    }

    let terrainMesh = TerrainMesh(x: 100, z: 100)
    let terrainModel = TerrainModel(mesh: terrainMesh, shaderName: "terrainShader", texture: nil)
    scene.terrain = terrainModel

    let renderer = Renderer(width: width, height: height, scene: scene)
    renderer.shaderManager.loadShader(name: "baseCube", vertexPath: "resources/shader/baseCube.vert", geometryPath: nil, fragmentPath: "resources/shader/baseCube.frag")
    renderer.shaderManager.loadShader(name: "lightShader", vertexPath: "resources/shader/lightShader.vert", geometryPath: nil, fragmentPath: "resources/shader/lightShader.frag")
    renderer.shaderManager.loadShader(name: "objectShader", vertexPath: "resources/shader/objectShader.vert", geometryPath: nil, fragmentPath: "resources/shader/objectShader.frag")
    renderer.shaderManager.loadShader(name: "normalShader", vertexPath: "resources/shader/normalShader.vert", geometryPath: "resources/shader/normalShader.geom", fragmentPath: "resources/shader/normalShader.frag")
    renderer.shaderManager.loadShader(name: "infiniteGridShader", vertexPath: "resources/shader/infiniteGrid.vert", geometryPath: nil, fragmentPath: "resources/shader/infiniteGrid.frag")
    renderer.shaderManager.loadShader(name: "skyboxShader", vertexPath: "resources/shader/skybox.vert", geometryPath: nil, fragmentPath: "resources/shader/skybox.frag")
    renderer.shaderManager.loadShader(name: "terrainShader", vertexPath: "resources/shader/terrain.vert", geometryPath: nil, fragmentPath: "resources/shader/terrain.frag")

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

        stats.numLeon = 0
        stats.numLivia = 0
        for model in renderer.scene.models {
            if let leonModel = model as? LeonModel {
                stats.numLeon += Int32(leonModel.activeInstances)
            }
            if model as? LightModel != nil {
                stats.numLeon += 1
            }
            if let liviaModel = model as? LiviaModel {
                stats.numLivia += Int32(liviaModel.activeInstances)
            }
        }
        stats.fps = 1.0 / dt
        stats.updateTime = updateTime - startTime
        stats.updateTimeHigh = stats.updateTimeHigh > stats.updateTime ? stats.updateTimeHigh : stats.updateTime
        stats.renderTime = renderTime - updateTime
        stats.renderTimeHigh = stats.renderTimeHigh > stats.renderTime ? stats.renderTimeHigh : stats.renderTime

        ImGuiWrapper_RenderStart()
        ImGuiWrapper_Text(String(format: "FPS: %-4.0f",             1.0/dt))
        ImGuiWrapper_Text(String(format: "numLeon: %0d",            stats.numLeon))
        ImGuiWrapper_Text(String(format: "numLivia: %0d",           stats.numLivia))
        ImGuiWrapper_Text(String(format: "updateTime: %.4f",        stats.updateTime))
        ImGuiWrapper_Text(String(format: "updateTimeHigh: %.4f",    stats.updateTimeHigh))
        ImGuiWrapper_Text(String(format: "renderTime: %.4f",        stats.renderTime))
        ImGuiWrapper_Text(String(format: "renderTimeHigh: %.4f",    stats.renderTimeHigh))
        ImGuiWrapper_RenderEnd()

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
