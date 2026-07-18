import OpenGL.GL3

import TextureModule

// Generates tileable 3D noise textures on the GPU. macOS caps OpenGL at 4.1
// (no compute shaders), so each Z slice of the 3D texture is attached to a
// framebuffer with glFramebufferTextureLayer and filled by a fullscreen
// fragment-shader pass.
class NoiseTextureGenerator {

    static func generate(size: Int,
                         shaderManager: ShaderManager,
                         octaves: Int32,
                         period: Float,
                         seed: GLuint,
                         displayWidth: Int32,
                         displayHeight: Int32) -> texture_t {
        var texture = texture_t()
        texture.type = GLenum(GL_TEXTURE_3D)

        glGenTextures(1, &texture.ID)
        glBindTexture(texture.type, texture.ID)
        glTexImage3D(texture.type, 0, GL_RG8, GLsizei(size), GLsizei(size), GLsizei(size), 0, GLenum(GL_RG), GLenum(GL_UNSIGNED_BYTE), nil)

        glTexParameteri(texture.type, GLenum(GL_TEXTURE_WRAP_S), GLint(GL_REPEAT))
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_WRAP_T), GLint(GL_REPEAT))
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_WRAP_R), GLint(GL_REPEAT))
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(texture.type, GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)

        var framebuffer: GLuint = 0
        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)

        glDisable(GLenum(GL_DEPTH_TEST))
        glDisable(GLenum(GL_CULL_FACE))
        glViewport(0, 0, GLsizei(size), GLsizei(size))

        let quad = GuiMesh(x: -1.0, y: -1.0, width: 2.0, height: 2.0)

        shaderManager.use(shaderName: "noise3dShader")
        shaderManager.setUniform("uPeriod", value: period)
        shaderManager.setUniform("uOctaves", value: octaves)
        shaderManager.setUniform("uSeed", value: seed)

        for z in 0..<size {
            glFramebufferTextureLayer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), texture.ID, 0, GLint(z))
            if z == 0 && glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE {
                Logger.error("Noise framebuffer not complete")
                break
            }
            shaderManager.setUniform("uSlice", value: (Float(z) + 0.5) / Float(size))
            quad.draw()
        }

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
        glDeleteFramebuffers(1, &framebuffer)

        glEnable(GLenum(GL_DEPTH_TEST))
        glEnable(GLenum(GL_CULL_FACE))
        glViewport(0, 0, displayWidth * 2, displayHeight * 2)

        return texture
    }
}
