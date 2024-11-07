import OpenGL.GL3
import simd

class WaterModel: BaseModel {
    var modelMatrix: float4x4 = matrix_identity_float4x4

    override func draw() {
        mesh.draw()
    }
}


