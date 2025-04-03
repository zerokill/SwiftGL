import TextureModule

func textureCubeMap(images: [String], texType: GLenum, slot: GLenum, format: GLenum, pixelType: GLenum ) -> texture_t {
    var texture = texture_t()
    texture.type = texType
    
    var width: Int32 = 0
    var height: Int32 = 0
    var numChannels: Int32 = 0
    
    stbi_set_flip_vertically_on_load(0)
    
    glGenTextures(1, &texture.ID)
    glBindTexture(texType, texture.ID)

    for (index, imagePath) in images.enumerated() {
        guard let bytes = stbi_load(imagePath, &width, &height, &numChannels, 0) else {
            fatalError("Failed to load texture image")
        }
        glTexImage2D(GLenum(GL_TEXTURE_CUBE_MAP_POSITIVE_X + Int32(index)), 0, GL_RGB, width, height, 0, format, pixelType, bytes)

        stbi_image_free(bytes)
    }
    
    glTexParameteri(GLenum(GL_TEXTURE_CUBE_MAP), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR);
    glTexParameteri(GLenum(GL_TEXTURE_CUBE_MAP), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR);
    glTexParameteri(GLenum(GL_TEXTURE_CUBE_MAP), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT);
    glTexParameteri(GLenum(GL_TEXTURE_CUBE_MAP), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT);
    glTexParameteri(GLenum(GL_TEXTURE_CUBE_MAP), GLenum(GL_TEXTURE_WRAP_R), GL_REPEAT);
    
    return texture
}
