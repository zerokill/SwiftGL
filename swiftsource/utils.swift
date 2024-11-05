import simd
import OpenGL.GL3

func calculateNormals(vertices: [Vertex], indices: [GLuint]) -> [SIMD3<Float>] {
    var normals = [SIMD3<Float>](repeating: SIMD3<Float>(0, 0, 0), count: vertices.count)

    // Iterate over each face defined by indices (triangles)
    for i in stride(from: 0, to: indices.count, by: 3) {
        let index0 = Int(indices[i])
        let index1 = Int(indices[i + 1])
        let index2 = Int(indices[i + 2])

        let v0 = vertices[index0].position
        let v1 = vertices[index1].position
        let v2 = vertices[index2].position

        // Calculate the two edge vectors of the triangle
        let edge1 = v1 - v0
        let edge2 = v2 - v0

        // Compute the face normal using the cross product
        let normal = normalize(cross(edge1, edge2))

        // Accumulate the normal for each vertex of the face
        normals[index0] += normal
        normals[index1] += normal
        normals[index2] += normal
    }

    // Normalize the accumulated normals for each vertex
    for i in 0..<normals.count {
        normals[i] = normalize(normals[i])
    }

    return normals
}

func generateNormalLines(from vertices: [Vertex], normalLength: Float) -> [Vertex] {
    var normalLines: [Vertex] = []

    for vertex in vertices {
        let startPoint = vertex.position
        let endPoint = vertex.position + normalize(vertex.normal) * normalLength

        // Line start vertex (position, normal is irrelevant here)
        let startVertex = Vertex(
            position: startPoint,
            normal: SIMD3<Float>(0.0, 0.0, 0.0), // Placeholder
            texCoords: SIMD2<Float>(0.0, 0.0)  // Placeholder
        )

        // Line end vertex (position, normal is irrelevant here)
        let endVertex = Vertex(
            position: endPoint,
            normal: SIMD3<Float>(0.0, 0.0, 0.0), // Placeholder
            texCoords: SIMD2<Float>(0.0, 0.0)  // Placeholder
        )

        normalLines += [startVertex, endVertex]
    }

    return normalLines
}

func getViewMatrixWithoutTranslation(from originalViewMatrix: simd_float4x4) -> simd_float4x4 {
    // Extract the 3x3 rotation matrix
    // Extract the rotational part of the matrix (upper-left 3x3)
    let rotationMatrix = simd_float3x3(
        SIMD3<Float>(originalViewMatrix.columns.0.x, originalViewMatrix.columns.0.y, originalViewMatrix.columns.0.z),
        SIMD3<Float>(originalViewMatrix.columns.1.x, originalViewMatrix.columns.1.y, originalViewMatrix.columns.1.z),
        SIMD3<Float>(originalViewMatrix.columns.2.x, originalViewMatrix.columns.2.y, originalViewMatrix.columns.2.z)
    )
    
    // Construct a new 4x4 matrix with zero translation
    let rotationOnlyViewMatrix = simd_float4x4(
        SIMD4<Float>(rotationMatrix.columns.0, 0.0),
        SIMD4<Float>(rotationMatrix.columns.1, 0.0),
        SIMD4<Float>(rotationMatrix.columns.2, 0.0),
        SIMD4<Float>(0.0, 0.0, 0.0, 1.0)
    )
    
    return rotationOnlyViewMatrix
}

func reflect(_ velocity: SIMD3<Float>, over normal: SIMD3<Float>) -> SIMD3<Float> {
    return velocity - 2 * dot(velocity, normal) * normal
}


