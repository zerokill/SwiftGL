import OpenGL.GL3
import simd

import TextureModule

class Framebuffer {
    var framebuffer: GLuint = 0
    var texture: texture_t = texture_t()
    var depthBuffer: GLuint = 0
    let width: GLsizei = 1280
    let height: GLsizei = 720

    init() {
        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)

        texture.type = GLenum(GL_TEXTURE_2D)

        // Create texture to render to
        glGenTextures(1, &texture.ID)
        glBindTexture(texture.type, texture.ID)
        glTexImage2D(texture.type, 0, GL_RGB, width, height, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), nil)
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), texture.type, texture.ID, 0)

        // Create depth buffer
        glGenRenderbuffers(1, &depthBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthBuffer)
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH24_STENCIL8), width, height)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_STENCIL_ATTACHMENT), GLenum(GL_RENDERBUFFER), depthBuffer)

        // Check framebuffer status
        if glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE {
            print("Reflection framebuffer not complete!")
        }

        Logger.info("fbo Texture: ", texture.ID)

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }

    func bindFramebuffer() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.framebuffer)
        glViewport(0, 0, self.width, self.height)
    }

    func unbindFramebuffer(displayWidth: Int32, displayHeight: Int32) {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
        glViewport(0, 0, displayWidth*2, displayHeight*2)
    }

}
