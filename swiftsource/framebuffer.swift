import OpenGL.GL3
import simd

import TextureModule

class Framebuffer {
    var framebuffer: GLuint = 0
    var texture: texture_t = texture_t()
    var depthBuffer: GLuint = 0
    let width: GLsizei
    let height: GLsizei

    init(internalFormat: Int32 = GL_RGBA16F, width: GLsizei = 1280, height: GLsizei = 720, withDepthBuffer: Bool = true) {
        self.width = width
        self.height = height

        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)

        texture.type = GLenum(GL_TEXTURE_2D)

        // Create texture to render to
        glGenTextures(1, &texture.ID)
        glBindTexture(texture.type, texture.ID)
        glTexImage2D(texture.type, 0, internalFormat, width, height, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), nil)
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), texture.type, texture.ID, 0)

        if withDepthBuffer {
            glGenRenderbuffers(1, &depthBuffer)
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthBuffer)
            glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH24_STENCIL8), width, height)
            glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_STENCIL_ATTACHMENT), GLenum(GL_RENDERBUFFER), depthBuffer)
        }

        // Check framebuffer status
        if glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE {
            print("Framebuffer not complete!")
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

// Depth-only FBO used as the resolve target when blitting the multisampled
// default framebuffer's depth into a sampleable texture. The format matches
// the default framebuffer (DEPTH24_STENCIL8) because multisample depth blits
// require identical formats.
class DepthFramebuffer {
    var framebuffer: GLuint = 0
    var texture: texture_t = texture_t()
    let width: GLsizei
    let height: GLsizei

    init(width: GLsizei, height: GLsizei) {
        self.width = width
        self.height = height

        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)

        texture.type = GLenum(GL_TEXTURE_2D)
        glGenTextures(1, &texture.ID)
        glBindTexture(texture.type, texture.ID)
        glTexImage2D(texture.type, 0, GL_DEPTH24_STENCIL8, width, height, 0, GLenum(GL_DEPTH_STENCIL), GLenum(GL_UNSIGNED_INT_24_8), nil)
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_STENCIL_ATTACHMENT), texture.type, texture.ID, 0)

        // No color attachment
        glDrawBuffer(GLenum(GL_NONE))
        glReadBuffer(GLenum(GL_NONE))

        if glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE {
            print("Depth resolve framebuffer not complete!")
        }

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }
}
