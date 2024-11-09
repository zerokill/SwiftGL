import OpenGL.GL3
import simd

import TextureModule

class GuiModel: BaseModel {
    var modelMatrix: float4x4 = matrix_identity_float4x4

    override func draw() {
        if let texture = self.texture {
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(texture.type, texture.ID)
        }
        mesh.draw()
    }
}
