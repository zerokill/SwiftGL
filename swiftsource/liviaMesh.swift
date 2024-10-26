import simd
import OpenGL.GL3

let liviaVertices: [Vertex] = [
    Vertex(position: SIMD3<Float>(-0.5, 0.0,  0.5),   normal: SIMD3<Float>(0.83, 0.70, 0.44),   texCoords: SIMD2<Float>(0.0 , 0.0)),
    Vertex(position: SIMD3<Float>(-0.5, 0.0, -0.5),   normal: SIMD3<Float>(0.83, 0.70, 0.44),   texCoords: SIMD2<Float>(2.5 , 0.0)),
    Vertex(position: SIMD3<Float>( 0.5, 0.0, -0.5),   normal: SIMD3<Float>(0.83, 0.70, 0.44),   texCoords: SIMD2<Float>(0.0 , 0.0)),
    Vertex(position: SIMD3<Float>( 0.5, 0.0,  0.5),   normal: SIMD3<Float>(0.83, 0.70, 0.44),   texCoords: SIMD2<Float>(2.5 , 0.0)),
    Vertex(position: SIMD3<Float>( 0.0, 0.8,  0.0),   normal: SIMD3<Float>(0.92, 0.86, 0.76),   texCoords: SIMD2<Float>(1.25, 2.5))
]

// Indices for vertices order
let liviaIndices: [GLuint] = [
    0, 1, 2,
    0, 2, 3,
    0, 4, 1,
    1, 4, 2,
    2, 4, 3,
    3, 4, 0
]

//let liviaVertices: [Vertex] = [
//    // Base Face (two triangles)
//    // Positions         // Normals           // Texture Coords
//    // Triangle 1
//    Vertex(position: SIMD3<Float>(-1.0, 0.0, -1.0),   normal: SIMD3<Float>(  0.0, -1.0,  0.0),     texCoords: SIMD2<Float>(0.0, 0.0)),  // Vertex 0
//    Vertex(position: SIMD3<Float>( 1.0, 0.0, -1.0),   normal: SIMD3<Float>(  0.0, -1.0,  0.0),     texCoords: SIMD2<Float>(1.0, 0.0)),  // Vertex 1
//    Vertex(position: SIMD3<Float>( 1.0, 0.0,  1.0),   normal: SIMD3<Float>(  0.0, -1.0,  0.0),     texCoords: SIMD2<Float>(1.0, 1.0)),  // Vertex 2
//
//    // Triangle 2
//    Vertex(position: SIMD3<Float>(-1.0, 0.0, -1.0),   normal: SIMD3<Float>(  0.0, -1.0,  0.0),     texCoords: SIMD2<Float>(0.0, 0.0)),  // Vertex 0
//    Vertex(position: SIMD3<Float>( 1.0, 0.0,  1.0),   normal: SIMD3<Float>(  0.0, -1.0,  0.0),     texCoords: SIMD2<Float>(1.0, 1.0)),  // Vertex 2
//    Vertex(position: SIMD3<Float>(-1.0, 0.0,  1.0),   normal: SIMD3<Float>(  0.0, -1.0,  0.0),     texCoords: SIMD2<Float>(0.0, 1.0)),  // Vertex 3
//
//    // Side Face 1
//    Vertex(position: SIMD3<Float>(-1.0, 0.0, -1.0),   normal: SIMD3<Float>(  0.0, -0.7071,  0.7071), texCoords: SIMD2<Float>(0.0, 0.0)),  // Vertex 4
//    Vertex(position: SIMD3<Float>( 1.0, 0.0, -1.0),   normal: SIMD3<Float>(  0.0, -0.7071,  0.7071), texCoords: SIMD2<Float>(1.0, 0.0)),  // Vertex 5
//    Vertex(position: SIMD3<Float>( 0.0, 1.0,  0.0),   normal: SIMD3<Float>(  0.0, -0.7071,  0.7071), texCoords: SIMD2<Float>(0.5, 1.0)),  // Vertex 6
//
//    // Side Face 2
//    Vertex(position: SIMD3<Float>( 1.0, 0.0, -1.0),   normal: SIMD3<Float>( -0.7071, -0.7071,  0.0),  texCoords: SIMD2<Float>(0.0, 0.0)),  // Vertex 7
//    Vertex(position: SIMD3<Float>( 1.0, 0.0,  1.0),   normal: SIMD3<Float>( -0.7071, -0.7071,  0.0),  texCoords: SIMD2<Float>(1.0, 0.0)),  // Vertex 8
//    Vertex(position: SIMD3<Float>( 0.0, 1.0,  0.0),   normal: SIMD3<Float>( -0.7071, -0.7071,  0.0),  texCoords: SIMD2<Float>(0.5, 1.0)),  // Vertex 9
//
//    // Side Face 3
//    Vertex(position: SIMD3<Float>( 1.0, 0.0,  1.0),   normal: SIMD3<Float>(  0.0, -0.7071, -0.7071), texCoords: SIMD2<Float>(0.0, 0.0)),  // Vertex10
//    Vertex(position: SIMD3<Float>(-1.0, 0.0,  1.0),   normal: SIMD3<Float>(  0.0, -0.7071, -0.7071), texCoords: SIMD2<Float>(1.0, 0.0)),  // Vertex11
//    Vertex(position: SIMD3<Float>( 0.0, 1.0,  0.0),   normal: SIMD3<Float>(  0.0, -0.7071, -0.7071), texCoords: SIMD2<Float>(0.5, 1.0)),  // Vertex12
//
//    // Side Face 4
//    Vertex(position: SIMD3<Float>(-1.0, 0.0,  1.0),   normal: SIMD3<Float>(  0.7071, -0.7071,  0.0), texCoords: SIMD2<Float>(0.0, 0.0)),  // Vertex13
//    Vertex(position: SIMD3<Float>(-1.0, 0.0, -1.0),   normal: SIMD3<Float>(  0.7071, -0.7071,  0.0), texCoords: SIMD2<Float>(1.0, 0.0)),  // Vertex14
//    Vertex(position: SIMD3<Float>( 0.0, 1.0,  0.0),   normal: SIMD3<Float>(  0.7071, -0.7071,  0.0), texCoords: SIMD2<Float>(0.5, 1.0))   // Vertex15
//]
//
//let liviaIndices: [GLuint] = [
//    // Base Face
//    0,  1,  2,   // Triangle 1
//    3,  4,  5,   // Triangle 2
//
//    // Side Faces
//    6,  7,  8,   // Side Face 1
//    9, 10, 11,   // Side Face 2
//   12, 13, 14,   // Side Face 3
//   15, 16, 17    // Side Face 4
//]

func generatePyramid() -> (vertices: [Vertex], indices: [GLuint]) {
//    // Define the size of the pyramid
//    let baseSize: Float = 1.0
//    let height: Float = 1.5
//
//    // Half size for convenience
//    let halfBase = baseSize / 2.0
//
//    // Define the five unique vertices of the pyramid
//    let baseVertices = [
//        Vertex(
//            position: SIMD3<Float>(-halfBase, 0.0,  halfBase),
//            normal: SIMD3<Float>(0.0, -1.0, 0.0),
//            texCoords: SIMD2<Float>(0.0, 0.0)
//        ),
//        Vertex(
//            position: SIMD3<Float>( halfBase, 0.0,  halfBase),
//            normal: SIMD3<Float>(0.0, -1.0, 0.0),
//            texCoords: SIMD2<Float>(1.0, 0.0)
//        ),
//        Vertex(
//            position: SIMD3<Float>( halfBase, 0.0, -halfBase),
//            normal: SIMD3<Float>(0.0, -1.0, 0.0),
//            texCoords: SIMD2<Float>(1.0, 1.0)
//        ),
//        Vertex(
//            position: SIMD3<Float>(-halfBase, 0.0, -halfBase),
//            normal: SIMD3<Float>(0.0, -1.0, 0.0),
//            texCoords: SIMD2<Float>(0.0, 1.0)
//        )
//    ]
//
//    // Apex of the pyramid
//    let apex = Vertex(
//        position: SIMD3<Float>(0.0, height, 0.0),
//        normal: SIMD3<Float>(0.0, 1.0, 0.0), // Placeholder; will be recalculated per face
//        texCoords: SIMD2<Float>(0.5, 1.0)
//    )
//
//    // Initialize arrays
//    var vertices: [Vertex] = []
//    var indices: [GLuint] = []
//
//    // Add base vertices
//    vertices += baseVertices
//
//    // Add apex vertices for each face to have distinct normals
//    // This allows for flat shading where each face has its own normal
//    let numberOfSides = 4
//    for _ in 0..<numberOfSides {
//        vertices.append(apex)
//    }
//
//    // Base indices (two triangles)
//    indices += [
//        0, 1, 2,
//        0, 2, 3
//    ]
//
//    // Side indices
//    for i in 0..<numberOfSides {
//        let apexIndex = 4 + i
//        let nextIndex = (i + 1) % numberOfSides
//        indices += [
//            GLuint(i),
//            GLuint(nextIndex),
//            GLuint(apexIndex)
//        ]
//    }
//
    var vertices: [Vertex] = [
        Vertex(position: SIMD3<Float>(-0.5, 0.0,  0.5),   normal: SIMD3<Float>(0.83, 0.70, 0.44),   texCoords: SIMD2<Float>(0.0 , 0.0)),
        Vertex(position: SIMD3<Float>(-0.5, 0.0, -0.5),   normal: SIMD3<Float>(0.83, 0.70, 0.44),   texCoords: SIMD2<Float>(2.5 , 0.0)),
        Vertex(position: SIMD3<Float>( 0.5, 0.0, -0.5),   normal: SIMD3<Float>(0.83, 0.70, 0.44),   texCoords: SIMD2<Float>(0.0 , 0.0)),
        Vertex(position: SIMD3<Float>( 0.5, 0.0,  0.5),   normal: SIMD3<Float>(0.83, 0.70, 0.44),   texCoords: SIMD2<Float>(2.5 , 0.0)),
        Vertex(position: SIMD3<Float>( 0.0, 0.8,  0.0),   normal: SIMD3<Float>(0.92, 0.86, 0.76),   texCoords: SIMD2<Float>(1.25, 2.5))
    ]
    
    // Indices for vertices order
    let indices: [GLuint] = [
        0, 1, 2,
        0, 2, 3,
        0, 4, 1,
        1, 4, 2,
        2, 4, 3,
        3, 4, 0
    ]


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

