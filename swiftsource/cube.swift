import OpenGL.GL3

// Cube vertices
let cubeVertices: [Vertex] = [
    // Positions          // Normals           // Texture Coords
    // Front face
    Vertex(position: SIMD3(-0.5, -0.5,  0.5), normal: SIMD3(0, 0, 1), texCoords: SIMD2(0, 0)),
    Vertex(position: SIMD3( 0.5, -0.5,  0.5), normal: SIMD3(0, 0, 1), texCoords: SIMD2(1, 0)),
    Vertex(position: SIMD3( 0.5,  0.5,  0.5), normal: SIMD3(0, 0, 1), texCoords: SIMD2(1, 1)),
    Vertex(position: SIMD3(-0.5,  0.5,  0.5), normal: SIMD3(0, 0, 1), texCoords: SIMD2(0, 1)),
    // Back face
    Vertex(position: SIMD3(-0.5, -0.5, -0.5), normal: SIMD3(0, 0, -1), texCoords: SIMD2(1, 0)),
    Vertex(position: SIMD3( 0.5, -0.5, -0.5), normal: SIMD3(0, 0, -1), texCoords: SIMD2(0, 0)),
    Vertex(position: SIMD3( 0.5,  0.5, -0.5), normal: SIMD3(0, 0, -1), texCoords: SIMD2(0, 1)),
    Vertex(position: SIMD3(-0.5,  0.5, -0.5), normal: SIMD3(0, 0, -1), texCoords: SIMD2(1, 1)),
    // Left face
    Vertex(position: SIMD3(-0.5, -0.5, -0.5), normal: SIMD3(-1, 0, 0), texCoords: SIMD2(0, 0)),
    Vertex(position: SIMD3(-0.5, -0.5,  0.5), normal: SIMD3(-1, 0, 0), texCoords: SIMD2(1, 0)),
    Vertex(position: SIMD3(-0.5,  0.5,  0.5), normal: SIMD3(-1, 0, 0), texCoords: SIMD2(1, 1)),
    Vertex(position: SIMD3(-0.5,  0.5, -0.5), normal: SIMD3(-1, 0, 0), texCoords: SIMD2(0, 1)),
    // Right face
    Vertex(position: SIMD3(0.5, -0.5, -0.5), normal: SIMD3(1, 0, 0), texCoords: SIMD2(1, 0)),
    Vertex(position: SIMD3(0.5, -0.5,  0.5), normal: SIMD3(1, 0, 0), texCoords: SIMD2(0, 0)),
    Vertex(position: SIMD3(0.5,  0.5,  0.5), normal: SIMD3(1, 0, 0), texCoords: SIMD2(0, 1)),
    Vertex(position: SIMD3(0.5,  0.5, -0.5), normal: SIMD3(1, 0, 0), texCoords: SIMD2(1, 1)),
    // Top face
    Vertex(position: SIMD3(-0.5, 0.5,  0.5), normal: SIMD3(0, 1, 0), texCoords: SIMD2(0, 1)),
    Vertex(position: SIMD3( 0.5, 0.5,  0.5), normal: SIMD3(0, 1, 0), texCoords: SIMD2(1, 1)),
    Vertex(position: SIMD3( 0.5, 0.5, -0.5), normal: SIMD3(0, 1, 0), texCoords: SIMD2(1, 0)),
    Vertex(position: SIMD3(-0.5, 0.5, -0.5), normal: SIMD3(0, 1, 0), texCoords: SIMD2(0, 0)),
    // Bottom face
    Vertex(position: SIMD3(-0.5, -0.5,  0.5), normal: SIMD3(0, -1, 0), texCoords: SIMD2(1, 1)),
    Vertex(position: SIMD3( 0.5, -0.5,  0.5), normal: SIMD3(0, -1, 0), texCoords: SIMD2(0, 1)),
    Vertex(position: SIMD3( 0.5, -0.5, -0.5), normal: SIMD3(0, -1, 0), texCoords: SIMD2(0, 0)),
    Vertex(position: SIMD3(-0.5, -0.5, -0.5), normal: SIMD3(0, -1, 0), texCoords: SIMD2(1, 0)),
]

let cubeIndices: [GLuint] = [
    // Front face
    0, 1, 2,
    2, 3, 0,
    // Back face
    4, 5, 6,
    6, 7, 4,
    // Left face
    8, 9, 10,
    10, 11, 8,
    // Right face
    12, 13, 14,
    14, 15, 12,
    // Top face
    16, 17, 18,
    18, 19, 16,
    // Bottom face
    20, 21, 22,
    22, 23, 20,
]

