import simd
import OpenGL.GL3

class WaterMesh: Mesh {
    var noiseArray: [[Double]]

    init(width: Int, depth: Int, scale: Double, octaves: Int, persistence: Double, seed: UInt64) {
        noiseArray = generateFractalPerlinNoise2D(
            width: width,
            height: depth,
            scale: scale,
            octaves: octaves,
            persistence: persistence,
            seed: seed
        )

        let (vertices, indices) = WaterMesh.createPlane(width: 2, depth: 2, noiseArray: noiseArray)
        super.init(vertices: vertices, indices: indices, maxInstanceCount: 1)
    }

    private static func createPlane(width: Int, depth: Int, noiseArray: [[Double]]) -> (vertices: [Vertex], indices: [GLuint]) {
        // FIXME: THis function can be shared with the terrainmesh
        let worldScale: Float = 100.0

        var vertices: [Vertex] = []

        for z in 0..<depth {
            for x in 0..<width {
                vertices.append(Vertex( position: SIMD3<Float>(Float(x) * worldScale, 0.0, Float(z) * worldScale), normal: SIMD3<Float>(), texCoords: SIMD2<Float>(Float(x), Float(z))))
            }
        }

        Logger.info("vertices ", vertices)

        // Define the indices for the cube (two triangles per face)
        var indices: [GLuint] = []

        for z in 0..<depth - 1 {
            for x in 0..<width - 1 {
                let bottomLeft = z * width + x
                let topLeft = (z+1) * width + x
                let topRight = (z+1) * width + (x+1)
                let bottomRight = z * width + (x+1)

                // Top left triangle
                indices.append(GLuint(bottomLeft))
                indices.append(GLuint(topLeft))
                indices.append(GLuint(topRight))

                // Bottom right triangle
                indices.append(GLuint(bottomLeft))
                indices.append(GLuint(topRight))
                indices.append(GLuint(bottomRight))
            }
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
}
