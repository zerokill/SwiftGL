import OpenGL.GL3

class TerrainMesh: Mesh {
    init(x: Int, z: Int) {
        let (vertices, indices) = TerrainMesh.generateTerrain(x: x, z: z)
        super.init(vertices: vertices, indices: indices, maxInstanceCount: 1)
    }

    private static func generateTerrain(x: Int, z: Int) -> (vertices: [Vertex], indices: [GLuint]) {
        var vertices: [Vertex] = []

        for i in 0..<x {
            for j in 0..<z {
                vertices.append(Vertex( position: SIMD3<Float>(Float(i), 0, Float(j)), normal: SIMD3<Float>(), texCoords: SIMD2<Float>()))
            }
        }

        // Define the indices for the cube (two triangles per face)
        var indices: [GLuint] = []

//        Logger.info("TerrainMesh: ", vertices)

        return (vertices, indices)
    }
}
