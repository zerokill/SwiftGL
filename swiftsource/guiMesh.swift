import simd
import OpenGL.GL3

class GuiMesh: Mesh {
    init(x: Float, y: Float, width: Float, height: Float) {
        let (vertices, indices) = GuiMesh.createPlane(x: x, y: y, width: width, height: height)
        super.init(vertices: vertices, indices: indices, maxInstanceCount: 1)
    }

    private static func createPlane(x: Float, y: Float, width: Float, height: Float) -> (vertices: [Vertex], indices: [GLuint]) {
        var vertices: [Vertex] = []

        vertices.append(Vertex( position: SIMD3<Float>(x,         y,          0.0), normal: SIMD3<Float>(), texCoords: SIMD2<Float>(0, 0)))
        vertices.append(Vertex( position: SIMD3<Float>(x,         y + height, 0.0), normal: SIMD3<Float>(), texCoords: SIMD2<Float>(0, 1)))
        vertices.append(Vertex( position: SIMD3<Float>(x + width, y,          0.0), normal: SIMD3<Float>(), texCoords: SIMD2<Float>(1, 0)))
        vertices.append(Vertex( position: SIMD3<Float>(x + width, y + height, 0.0), normal: SIMD3<Float>(), texCoords: SIMD2<Float>(1, 1)))

        Logger.info("gui: ", vertices)

        // Define the indices for the cube (two triangles per face)
        var indices: [GLuint] = []

        // Top left triangle
        indices.append(GLuint(0))
        indices.append(GLuint(2))
        indices.append(GLuint(3))

        // Bottom right triangle
        indices.append(GLuint(0))
        indices.append(GLuint(3))
        indices.append(GLuint(1))

        // Recalculate normals for each face
        // This ensures correct lighting for flat shading
        for i in 0..<indices.count/3 {
            let idx0 = Int(indices[i*3])
            let idx1 = Int(indices[i*3 + 1])
            let idx2 = Int(indices[i*3 + 2])

            let v0 = vertices[idx0].position
            let v1 = vertices[idx1].position
            let v2 = vertices[idx2].position

            // Calculate the normal using cross product
            let edge1 = v1 - v0
            let edge2 = v2 - v0
            let faceNormal = normalize(cross(edge1, edge2))

            // Assign the normal to each vertex of the face
            vertices[idx0].normal = faceNormal
            vertices[idx1].normal = faceNormal
            vertices[idx2].normal = faceNormal
        }

        return (vertices, indices)
    }
}

