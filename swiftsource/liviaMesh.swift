import OpenGL.GL3

// Vertices coordinates
let liviaVertices: [Vertex] = [
    Vertex(position: SIMD3<Float>(-0.5, 0.0,  0.5),   color: SIMD3<Float>(0.83, 0.70, 0.44),   texCoords: SIMD2<Float>(0.0 , 0.0)),
    Vertex(position: SIMD3<Float>(-0.5, 0.0, -0.5),   color: SIMD3<Float>(0.83, 0.70, 0.44),   texCoords: SIMD2<Float>(2.5 , 0.0)),
    Vertex(position: SIMD3<Float>( 0.5, 0.0, -0.5),   color: SIMD3<Float>(0.83, 0.70, 0.44),   texCoords: SIMD2<Float>(0.0 , 0.0)),
    Vertex(position: SIMD3<Float>( 0.5, 0.0,  0.5),   color: SIMD3<Float>(0.83, 0.70, 0.44),   texCoords: SIMD2<Float>(2.5 , 0.0)),
    Vertex(position: SIMD3<Float>( 0.0, 0.8,  0.0),   color: SIMD3<Float>(0.92, 0.86, 0.76),   texCoords: SIMD2<Float>(1.25, 2.5))
]

// Indices for vertices order
let liviaIndices: [GLuint] = [
    0, 1, 2,
    0, 2, 3,
    0, 1, 4,
    1, 2, 4,
    2, 3, 4,
    3, 0, 4
]

