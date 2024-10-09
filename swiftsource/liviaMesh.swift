import OpenGL.GL3

// Vertices coordinates
let liviaVertices: [GLfloat] = [
    //  Positions       //   Colors        // Texture Coords
    -0.5, 0.0,  0.5,   0.83, 0.70, 0.44,   0.0, 0.0,
    -0.5, 0.0, -0.5,   0.83, 0.70, 0.44,   5.0, 0.0,
     0.5, 0.0, -0.5,   0.83, 0.70, 0.44,   0.0, 0.0,
     0.5, 0.0,  0.5,   0.83, 0.70, 0.44,   5.0, 0.0,
     0.0, 0.8,  0.0,   0.92, 0.86, 0.76,   2.5, 5.0
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

