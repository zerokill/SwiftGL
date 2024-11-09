import OpenGL.GL3
import simd

class WaterModel: BaseModel {
    var modelMatrix: float4x4 = matrix_identity_float4x4
    var reflectionBuffer: Framebuffer
    var refractionBuffer: Framebuffer

    init(mesh: Mesh, shaderName: String) {
        self.reflectionBuffer = Framebuffer()
        self.refractionBuffer = Framebuffer()
        super.init(mesh: mesh, shaderName: shaderName, texture: nil)
    }

    override func draw() {
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(self.reflectionBuffer.texture.type, self.reflectionBuffer.texture.ID)
        glActiveTexture(GLenum(GL_TEXTURE0 + 1))
        glBindTexture(self.refractionBuffer.texture.type, self.refractionBuffer.texture.ID)
        mesh.draw()
        glActiveTexture(GLenum(GL_TEXTURE0))
    }
}


