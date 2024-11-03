import OpenGL.GL3
import simd

class SkyboxModel: BaseModel {

    override func draw() {
        glDepthFunc(GLenum(GL_LEQUAL));  // change depth function so depth test passes when values are equal to depth buffer's content

        if let texture = self.texture {
            glBindTexture(texture.type, texture.ID)
        }
        mesh.draw()
        glDepthFunc(GLenum(GL_LESS));  // change depth function so depth test passes when values are equal to depth buffer's content
    }
}
