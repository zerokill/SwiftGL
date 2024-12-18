import OpenGL.GL3
import simd

struct InstanceData {
    var modelMatrix: simd_float4x4

    var enable: Bool
    var enableExplode: Bool

    var velocity: SIMD3<Float>
    var positionMatrix: simd_float4x4
    var rotationMatrix: simd_float4x4

    var timeAlive: Float
}

class Mesh {
    var vertices: [Vertex]
    var indices: [GLuint]
    var maxInstanceCount: Int

    var VAO: GLuint = 0
    var VBO: GLuint = 0
    var EBO: GLuint = 0
    var instanceVBO: GLuint = 0

    init(vertices: [Vertex], indices: [GLuint], maxInstanceCount: Int) {
        self.vertices = vertices
        self.indices = indices
        self.maxInstanceCount = maxInstanceCount
        setupMesh()
    }

    deinit {
        glDeleteVertexArrays(1, &VAO)
        glDeleteBuffers(1, &VBO)
        glDeleteBuffers(1, &EBO)
    }

    func setupMesh() {
        // Generate and bind buffers, set attribute pointers
        glGenVertexArrays(1, &VAO)
        glGenBuffers(1, &VBO)
        glGenBuffers(1, &EBO)

        glBindVertexArray(VAO)

        // Flatten vertex data
        var vertexData: [GLfloat] = []
        for vertex in vertices {
            vertexData += [vertex.position.x, vertex.position.y, vertex.position.z]
            vertexData += [vertex.normal.x, vertex.normal.y, vertex.normal.z]
            vertexData += [vertex.texCoords.x, vertex.texCoords.y]
        }

        // Bind and set VBO
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertexData.count * MemoryLayout<GLfloat>.size, vertexData, GLenum(GL_STATIC_DRAW))

        // Bind and set EBO
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), EBO)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * MemoryLayout<GLuint>.size, indices, GLenum(GL_STATIC_DRAW))

        // Vertex attribute pointers
        let stride = GLsizei(8 * MemoryLayout<GLfloat>.size)

        // Position attribute
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, nil)
        glEnableVertexAttribArray(0)

        // Normal attribute
        let normalOffset = UnsafeRawPointer(bitPattern: 3 * MemoryLayout<GLfloat>.size)
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, normalOffset)
        glEnableVertexAttribArray(1)

        // Texture coordinate attribute
        let texCoordOffset = UnsafeRawPointer(bitPattern: 6 * MemoryLayout<GLfloat>.size)
        glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), stride, texCoordOffset)
        glEnableVertexAttribArray(2)

        glGenBuffers(1, &instanceVBO)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), instanceVBO)
        glBufferData(GLenum(GL_ARRAY_BUFFER), maxInstanceCount * MemoryLayout<InstanceData>.stride, nil, GLenum(GL_DYNAMIC_DRAW))

        let vec4Size = MemoryLayout<SIMD4<Float>>.stride
        for i in 0..<4 {
            glEnableVertexAttribArray(3 + GLuint(i))
            glVertexAttribPointer(3 + GLuint(i), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<InstanceData>.stride), UnsafeRawPointer(bitPattern: i * vec4Size))
            glVertexAttribDivisor(3 + GLuint(i), 1) // Advance per instance
        }

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
    }

    func updateInstanceData(_ instances: [InstanceData]) {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), instanceVBO)
        glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, instances.count * MemoryLayout<InstanceData>.stride, instances)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }

    func drawInstances(count: Int) {
        glBindVertexArray(VAO)
        glDrawElementsInstanced(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), nil, GLsizei(count))
        glBindVertexArray(0)
    }

    func draw() {
        glBindVertexArray(VAO)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), nil)
        glBindVertexArray(0)
    }

    func drawPoints() {
        glBindVertexArray(VAO)
        glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(vertices.count))
        glBindVertexArray(0)
    }

    func draw2() {
        glBindVertexArray(VAO)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 24)
        glBindVertexArray(0)
    }
}
