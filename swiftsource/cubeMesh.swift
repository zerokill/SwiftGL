import OpenGL.GL3

class CubeMesh: Mesh {
    init() {
        let (vertices, indices) = CubeMesh.generateCube()
        super.init(vertices: vertices, indices: indices, maxInstanceCount: 1)
    }

    private static func generateCube() -> (vertices: [Vertex], indices: [GLuint]) {
        // Define the size of the cube
        let size: Float = 1.0
        let halfSize = size
        
        // Define the 6 faces of the cube
        // Each face has 4 vertices (positions, normals, texCoords)
        let vertices: [Vertex] = [
            // Front face
            Vertex( position: SIMD3<Float>(-halfSize, -halfSize,  halfSize), normal: SIMD3<Float>(0.0, 0.0, 1.0), texCoords: SIMD2<Float>(0.0, 0.0)),
            Vertex( position: SIMD3<Float>( halfSize, -halfSize,  halfSize), normal: SIMD3<Float>(0.0, 0.0, 1.0), texCoords: SIMD2<Float>(1.0, 0.0)),
            Vertex( position: SIMD3<Float>( halfSize,  halfSize,  halfSize), normal: SIMD3<Float>(0.0, 0.0, 1.0), texCoords: SIMD2<Float>(1.0, 1.0)),
            Vertex( position: SIMD3<Float>(-halfSize,  halfSize,  halfSize), normal: SIMD3<Float>(0.0, 0.0, 1.0), texCoords: SIMD2<Float>(0.0, 1.0)),
            
            // Back face
            Vertex( position: SIMD3<Float>( halfSize, -halfSize, -halfSize), normal: SIMD3<Float>(0.0, 0.0, -1.0), texCoords: SIMD2<Float>(0.0, 0.0)),
            Vertex( position: SIMD3<Float>(-halfSize, -halfSize, -halfSize), normal: SIMD3<Float>(0.0, 0.0, -1.0), texCoords: SIMD2<Float>(1.0, 0.0)),
            Vertex( position: SIMD3<Float>(-halfSize,  halfSize, -halfSize), normal: SIMD3<Float>(0.0, 0.0, -1.0), texCoords: SIMD2<Float>(1.0, 1.0)),
            Vertex( position: SIMD3<Float>( halfSize,  halfSize, -halfSize), normal: SIMD3<Float>(0.0, 0.0, -1.0), texCoords: SIMD2<Float>(0.0, 1.0)),
            
            // Left face
            Vertex( position: SIMD3<Float>(-halfSize, -halfSize, -halfSize), normal: SIMD3<Float>(-1.0, 0.0, 0.0), texCoords: SIMD2<Float>(0.0, 0.0)),
            Vertex( position: SIMD3<Float>(-halfSize, -halfSize,  halfSize), normal: SIMD3<Float>(-1.0, 0.0, 0.0), texCoords: SIMD2<Float>(1.0, 0.0)),
            Vertex( position: SIMD3<Float>(-halfSize,  halfSize,  halfSize), normal: SIMD3<Float>(-1.0, 0.0, 0.0), texCoords: SIMD2<Float>(1.0, 1.0)),
            Vertex( position: SIMD3<Float>(-halfSize,  halfSize, -halfSize), normal: SIMD3<Float>(-1.0, 0.0, 0.0), texCoords: SIMD2<Float>(0.0, 1.0)),
            
            // Right face
            Vertex( position: SIMD3<Float>( halfSize, -halfSize,  halfSize), normal: SIMD3<Float>(1.0, 0.0, 0.0), texCoords: SIMD2<Float>(0.0, 0.0)),
            Vertex( position: SIMD3<Float>( halfSize, -halfSize, -halfSize), normal: SIMD3<Float>(1.0, 0.0, 0.0), texCoords: SIMD2<Float>(1.0, 0.0)),
            Vertex( position: SIMD3<Float>( halfSize,  halfSize, -halfSize), normal: SIMD3<Float>(1.0, 0.0, 0.0), texCoords: SIMD2<Float>(1.0, 1.0)),
            Vertex( position: SIMD3<Float>( halfSize,  halfSize,  halfSize), normal: SIMD3<Float>(1.0, 0.0, 0.0), texCoords: SIMD2<Float>(0.0, 1.0)),
            
            // Top face
            Vertex( position: SIMD3<Float>(-halfSize,  halfSize,  halfSize), normal: SIMD3<Float>(0.0, 1.0, 0.0), texCoords: SIMD2<Float>(0.0, 0.0)),
            Vertex( position: SIMD3<Float>( halfSize,  halfSize,  halfSize), normal: SIMD3<Float>(0.0, 1.0, 0.0), texCoords: SIMD2<Float>(1.0, 0.0)),
            Vertex( position: SIMD3<Float>( halfSize,  halfSize, -halfSize), normal: SIMD3<Float>(0.0, 1.0, 0.0), texCoords: SIMD2<Float>(1.0, 1.0)),
            Vertex( position: SIMD3<Float>(-halfSize,  halfSize, -halfSize), normal: SIMD3<Float>(0.0, 1.0, 0.0), texCoords: SIMD2<Float>(0.0, 1.0)),
            
            // Bottom face
            Vertex( position: SIMD3<Float>(-halfSize, -halfSize, -halfSize), normal: SIMD3<Float>(0.0, -1.0, 0.0), texCoords: SIMD2<Float>(0.0, 0.0)),
            Vertex( position: SIMD3<Float>( halfSize, -halfSize, -halfSize), normal: SIMD3<Float>(0.0, -1.0, 0.0), texCoords: SIMD2<Float>(1.0, 0.0)),
            Vertex( position: SIMD3<Float>( halfSize, -halfSize,  halfSize), normal: SIMD3<Float>(0.0, -1.0, 0.0), texCoords: SIMD2<Float>(1.0, 1.0)),
            Vertex( position: SIMD3<Float>(-halfSize, -halfSize,  halfSize), normal: SIMD3<Float>(0.0, -1.0, 0.0), texCoords: SIMD2<Float>(0.0, 1.0))
        ]
        
        // Define the indices for the cube (two triangles per face)
        var indices: [GLuint] = []
        
        for face in 0..<6 {
            let start = face * 4
            indices += [
                GLuint(start), GLuint(start + 2), GLuint(start + 1),
                GLuint(start), GLuint(start + 3), GLuint(start + 2)
            ]
        }

        Logger.info(indices)
        
        return (vertices, indices)
    }
}
