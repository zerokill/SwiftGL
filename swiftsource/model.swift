import OpenGL.GL3
import simd

class Model: Renderable {
    var mesh: Mesh
    var shaderName: String
    var textureName: String
    var modelMatrix: float4x4

    init(mesh: Mesh, shaderName: String, textureName: String) {
        self.mesh = mesh
        self.shaderName = shaderName
        self.textureName = textureName
        self.modelMatrix = matrix_identity_float4x4
    }

    func draw() {
        mesh.draw()
    }
}

