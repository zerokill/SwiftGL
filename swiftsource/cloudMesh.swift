import OpenGL.GL3

class CloudMesh: Mesh {
    init() {
        let (vertices, indices) = CloudMesh.generateCube()
        super.init(vertices: vertices, indices: indices, maxInstanceCount: 1)
    }

    private static func generateCube() -> (vertices: [Vertex], indices: [GLuint]) {

        //unit cube vertices
        let vertices: [Vertex] = [
                                Vertex( position: SIMD3<Float>(-0.5,-0.5,-0.5), normal: SIMD3<Float>(), texCoords: SIMD2<Float>()),
                                Vertex( position: SIMD3<Float>( 0.5,-0.5,-0.5), normal: SIMD3<Float>(), texCoords: SIMD2<Float>()),
                                Vertex( position: SIMD3<Float>( 0.5, 0.5,-0.5), normal: SIMD3<Float>(), texCoords: SIMD2<Float>()),
                                Vertex( position: SIMD3<Float>(-0.5, 0.5,-0.5), normal: SIMD3<Float>(), texCoords: SIMD2<Float>()),
                                Vertex( position: SIMD3<Float>(-0.5,-0.5, 0.5), normal: SIMD3<Float>(), texCoords: SIMD2<Float>()),
                                Vertex( position: SIMD3<Float>( 0.5,-0.5, 0.5), normal: SIMD3<Float>(), texCoords: SIMD2<Float>()),
                                Vertex( position: SIMD3<Float>( 0.5, 0.5, 0.5), normal: SIMD3<Float>(), texCoords: SIMD2<Float>()),
                                Vertex( position: SIMD3<Float>(-0.5, 0.5, 0.5), normal: SIMD3<Float>(), texCoords: SIMD2<Float>())
                                ]

        //unit cube indices
        var indices: [GLuint] =  [0,5,4,
                                  5,0,1,
                                  3,7,6,
                                  3,6,2,
                                  7,4,6,
                                  6,4,5,
                                  2,1,3,
                                  3,1,0,
                                  3,0,7,
                                  7,0,4,
                                  6,5,2,
                                  2,5,1]

        Logger.info(indices)

        return (vertices, indices)
    }
}

