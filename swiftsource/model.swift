import OpenGL.GL3
import simd

import TextureModule

class Model: Renderable {
    var mesh: Mesh
    var shaderName: String
    var modelMatrix: float4x4
    var texture: texture_t

    init(mesh: Mesh, shaderName: String, texture: texture_t) {
        self.mesh = mesh
        self.shaderName = shaderName
        self.modelMatrix = matrix_identity_float4x4
        self.texture = texture
    }

    func draw() {
        glBindTexture(texture.type, texture.ID)
        mesh.draw()
    }
}

