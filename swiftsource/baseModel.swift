import TextureModule

class BaseModel {

    var mesh: Mesh
    var shaderName: String
    var texture: texture_t?

    init(mesh: Mesh, shaderName: String, texture: texture_t) {
        self.mesh = mesh
        self.shaderName = shaderName
        self.texture = texture
    }

    func updateMove(deltaTime: Float) {

    }

    func draw() {

    }
}
