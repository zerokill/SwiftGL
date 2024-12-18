import OpenGL.GL3
import simd

import TextureModule

class WaterModel: BaseModel {
    var modelMatrix: float4x4 = matrix_identity_float4x4
    var reflectionBuffer: Framebuffer
    var refractionBuffer: Framebuffer
    var dudvMap: texture_t
    var normalMap: texture_t

    var moveFactor: Float

    let WAVE_SPEED: Float = 0.05

    init(mesh: Mesh, shaderName: String, dudvMap: texture_t, normalMap: texture_t) {
        self.reflectionBuffer = Framebuffer()
        self.refractionBuffer = Framebuffer()
        self.dudvMap = dudvMap
        self.normalMap = normalMap

        self.moveFactor = 0.0

        super.init(mesh: mesh, shaderName: shaderName, texture: nil)
    }

    override func draw() {
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(self.reflectionBuffer.texture.type, self.reflectionBuffer.texture.ID)
        glActiveTexture(GLenum(GL_TEXTURE0 + 1))
        glBindTexture(self.refractionBuffer.texture.type, self.refractionBuffer.texture.ID)
        glActiveTexture(GLenum(GL_TEXTURE0 + 2))
        glBindTexture(self.dudvMap.type, self.dudvMap.ID)
        glActiveTexture(GLenum(GL_TEXTURE0 + 3))
        glBindTexture(self.normalMap.type, self.normalMap.ID)

        mesh.draw()

        glActiveTexture(GLenum(GL_TEXTURE0))
        glDisable(GLenum(GL_BLEND))
    }
}


