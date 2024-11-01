import TextureModule

class ResourceManager {
    static let shared = ResourceManager()
    
    private var models: [String: BaseModel] = [:]
    private var textures: [String: texture_t] = [:]
    
    private init() {}
    
    func loadModel(name: String, model: BaseModel) {
        // Load the model from the file
        models[name] = model
    }
    
    func loadTexture(name: String, texture: texture_t) {
        textures[name] = texture
    }
    
    func getModel(name: String) -> BaseModel? {
        return models[name]
    }
    
    func getTexture(name: String) -> texture_t? {
        return textures[name]
    }
    
    // Optional: methods to unload resources, clear cache, etc.
}

