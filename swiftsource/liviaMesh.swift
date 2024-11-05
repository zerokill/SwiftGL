import simd
import OpenGL.GL3

func generateFlatShadedPyramid() -> (vertices: [Vertex], indices: [GLuint]) {
    // Define the size of the pyramid
    let baseSize: Float = 1.0
    let height: Float = 0.8

    let halfWidth = baseSize / 2

    // Define the positions
    let positions = [
        SIMD3(-halfWidth, 0.0,  halfWidth), // 0
        SIMD3(-halfWidth, 0.0, -halfWidth), // 1
        SIMD3( halfWidth, 0.0, -halfWidth), // 2
        SIMD3( halfWidth, 0.0,  halfWidth), // 3
        SIMD3(0.0, height, 0.0)             // 4
    ]

    // Define the faces (each face has its own vertices)
    let faceIndices = [
        [0, 1, 2],  // Base triangle 1
        [0, 2, 3],  // Base triangle 2
        [0, 4, 1],  // Side face 1
        [1, 4, 2],  // Side face 2
        [2, 4, 3],  // Side face 3
        [3, 4, 0]   // Side face 4
    ]

    // Initialize arrays
    var vertices: [Vertex] = []
    var indices: [GLuint] = []
    var index: GLuint = 0

    for face in faceIndices {
        let v0 = positions[face[0]]
        let v1 = positions[face[1]]
        let v2 = positions[face[2]]

        let edge1 = v1 - v0
        let edge2 = v2 - v0

        let normal = normalize(cross(edge1, edge2))

        // Create vertices with the same normal for flat shading
        vertices.append(Vertex(position: v0, normal: normal, texCoords: SIMD2(0.0, 0.0)))
        vertices.append(Vertex(position: v1, normal: normal, texCoords: SIMD2(1.0, 0.0)))
        vertices.append(Vertex(position: v2, normal: normal, texCoords: SIMD2(0.5, 1.0)))

        indices.append(index)
        indices.append(index + 1)
        indices.append(index + 2)

        index += 3
    }

    return (vertices, indices)
}
