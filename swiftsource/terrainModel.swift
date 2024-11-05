import OpenGL.GL3
import simd

class TerrainModel: BaseModel {

    override func draw() {
        mesh.drawPoints()
    }
}

