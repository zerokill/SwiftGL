import OpenGL.GL3

class NormalMesh: Mesh {
    init(normalLines: [Vertex]) {
        self.vertices = normalLines
        self.indices = Array(0..<GLuint(normalLines.count))
        
        super.init(vertices: vertices, indices: indices, maxInstanceCount: 1)
    }
    
    override func setupMesh() {
        // Generate and bind VAO
        glGenVertexArrays(1, &VAO)
        glBindVertexArray(VAO)

        var vertexData: [GLfloat] = []
        for vertex in vertices {
            vertexData += [vertex.position.x, vertex.position.y, vertex.position.z]
            vertexData += [vertex.normal.x, vertex.normal.y, vertex.normal.z]
            vertexData += [vertex.texCoords.x, vertex.texCoords.y]
        }

        // Generate and bind VBO
        glGenBuffers(1, &VBO)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertexData.count * MemoryLayout<GLfloat>.size, vertexData, GLenum(GL_STATIC_DRAW))
        
        // Generate and bind EBO
        glGenBuffers(1, &EBO)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), EBO)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count, indices, GLenum(GL_STATIC_DRAW))
        
        // Define vertex attributes
        let stride = GLsizei(MemoryLayout<Vertex>.stride)
        
        // Position attribute
        glEnableVertexAttribArray(0)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, UnsafeRawPointer(bitPattern: 0))
        
        // Disable other attributes (normals and texCoords are not needed for lines)
        glDisableVertexAttribArray(1)
        glDisableVertexAttribArray(2)
        
        // Unbind vao
        glBindVertexArray(0)
    }
}

