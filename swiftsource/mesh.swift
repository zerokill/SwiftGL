import OpenGL.GL3

class Mesh {
//    var vertices: [Vertex]
//    var indices: [GLuint]
    var vertices: [GLfloat]
    var indices: [GLuint]
    private var VAO: GLuint = 0
    private var VBO: GLuint = 0
    private var EBO: GLuint = 0

    init(vertices: [GLfloat], indices: [GLuint]) {
        self.vertices = vertices
        self.indices = indices
        setupMesh()
    }

    deinit {
        glDeleteVertexArrays(1, &VAO)
        glDeleteBuffers(1, &VBO)
        glDeleteBuffers(1, &EBO)
    }

    private func setupMesh() {
        // Generate and bind buffers, set attribute pointers
        glGenVertexArrays(1, &VAO)
        glGenBuffers(1, &VBO)
        glGenBuffers(1, &EBO)

        glBindVertexArray(VAO)

        // Bind and set VBO
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.count * MemoryLayout<GLfloat>.size, vertices, GLenum(GL_STATIC_DRAW))

        // Bind and set EBO
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), EBO)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * MemoryLayout<GLuint>.size, indices, GLenum(GL_STATIC_DRAW))

        // Vertex attribute pointers
        let stride = GLsizei(8 * MemoryLayout<GLfloat>.size)

        // Position attribute
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, nil)
        glEnableVertexAttribArray(0)

        // Color attribute
        let colorOffset = UnsafeRawPointer(bitPattern: 3 * MemoryLayout<GLfloat>.size)
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, colorOffset)
        glEnableVertexAttribArray(1)

        // Texture coordinate attribute
        let texCoordOffset = UnsafeRawPointer(bitPattern: 6 * MemoryLayout<GLfloat>.size)
        glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, texCoordOffset)
        glEnableVertexAttribArray(2)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
    }

    func draw() {
        glBindVertexArray(VAO)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), nil)
        glBindVertexArray(0)
    }
}
