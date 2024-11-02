import TextureModule

class ResourceManager {
    static let shared = ResourceManager()
    
    private var meshes: [String: Mesh] = [:]
    private var models: [String: BaseModel] = [:]
    private var textures: [String: texture_t] = [:]
    
    private init() {}
    
    func loadMesh(name: String, mesh: Mesh) {
        // Load the model from the file
        meshes[name] = mesh
    }
    
    func loadModel(name: String, model: BaseModel) {
        // Load the model from the file
        models[name] = model
    }
    
    func loadTexture(name: String, texture: texture_t) {
        textures[name] = texture
    }
    
    func getMesh(name: String) -> Mesh? {
        return meshes[name]
    }
    
    func getModel(name: String) -> BaseModel? {
        return models[name]
    }
    
    func getTexture(name: String) -> texture_t? {
        return textures[name]
    }
    
    // Optional: methods to unload resources, clear cache, etc.
}

