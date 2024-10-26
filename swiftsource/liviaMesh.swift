import simd
import OpenGL.GL3

func generatePyramid() -> (vertices: [Vertex], indices: [GLuint]) {
    // Define the size of the pyramid
    let baseSize: Float = 1.0
    let height: Float = 1.5

    // Half size for convenience
    let halfBase = baseSize / 2.0

    // Define the five unique vertices of the pyramid
    let baseVertices = [
        Vertex(
            position: SIMD3<Float>(-halfBase, 0.0,  halfBase),
            normal: SIMD3<Float>(0.0, -1.0, 0.0),
            texCoords: SIMD2<Float>(0.0, 0.0)
        ),
        Vertex(
            position: SIMD3<Float>( halfBase, 0.0,  halfBase),
            normal: SIMD3<Float>(0.0, -1.0, 0.0),
            texCoords: SIMD2<Float>(1.0, 0.0)
        ),
        Vertex(
            position: SIMD3<Float>( halfBase, 0.0, -halfBase),
            normal: SIMD3<Float>(0.0, -1.0, 0.0),
            texCoords: SIMD2<Float>(1.0, 1.0)
        ),
        Vertex(
            position: SIMD3<Float>(-halfBase, 0.0, -halfBase),
            normal: SIMD3<Float>(0.0, -1.0, 0.0),
            texCoords: SIMD2<Float>(0.0, 1.0)
        )
    ]

    // Apex of the pyramid
    let apex = Vertex(
        position: SIMD3<Float>(0.0, height, 0.0),
        normal: SIMD3<Float>(0.0, 1.0, 0.0), // Placeholder; will be recalculated per face
        texCoords: SIMD2<Float>(0.5, 1.0)
    )

    // Initialize arrays
    var vertices: [Vertex] = []
    var indices: [GLuint] = []

    // Add base vertices
    vertices += baseVertices

    // Add apex vertices for each face to have distinct normals
    // This allows for flat shading where each face has its own normal
    let numberOfSides = 4
    for _ in 0..<numberOfSides {
        vertices.append(apex)
    }

    // Base indices (two triangles)
    indices += [
        0, 1, 2,
        0, 2, 3
    ]

    // Side indices
    for i in 0..<numberOfSides {
        let apexIndex = 4 + i
        let nextIndex = (i + 1) % numberOfSides
        indices += [
            GLuint(i),
            GLuint(nextIndex),
            GLuint(apexIndex)
        ]
    }

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
