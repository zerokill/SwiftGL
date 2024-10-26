import OpenGL.GL3
import simd

struct SphereParameters {
    var radius: Float
    var latitudeBands: Int
    var longitudeBands: Int
}

class LeonMesh: Mesh {

    // Initialize Mesh with sphere parameters
    init(sphere: SphereParameters) {
        let (vertices, indices) = LeonMesh.generateSphere(parameters: sphere)
        super.init(vertices: vertices, indices: indices, maxInstanceCount: 10000)
    }

    private static func generateSphere(parameters: SphereParameters) -> ([Vertex], [GLuint]) {
        var vertices: [Vertex] = []
        var indices: [GLuint] = []

        let latitudeBands = parameters.latitudeBands
        let longitudeBands = parameters.longitudeBands
        let radius = parameters.radius
        
        for lat in 0...latitudeBands {
            let theta = Float(lat) * Float.pi / Float(latitudeBands)
            let sinTheta = sin(theta)
            let cosTheta = cos(theta)
            
            for lon in 0...longitudeBands {
                let phi = Float(lon) * 2.0 * Float.pi / Float(longitudeBands)
                let sinPhi = sin(phi)
                let cosPhi = cos(phi)
                
                let x = cosPhi * sinTheta
                let y = cosTheta
                let z = sinPhi * sinTheta
                let u = 1.0 - (Float(lon) / Float(longitudeBands))
                let v = 1.0 - (Float(lat) / Float(latitudeBands))
                
                let vertex = Vertex(
                    position: [x * radius, y * radius, z * radius],
                    normal: [x, y, z],
                    texCoords: [u, v]
                )
                vertices.append(vertex)
            }
        }
        
        for lat in 0..<latitudeBands {
            for lon in 0..<longitudeBands {
                let first = (lat * (longitudeBands + 1)) + lon
                let second = first + longitudeBands + 1
                
                indices.append(GLuint(first))
                indices.append(GLuint(second))
                indices.append(GLuint(first + 1))
                
                indices.append(GLuint(second))
                indices.append(GLuint(second + 1))
                indices.append(GLuint(first + 1))
            }
        }
        
        return (vertices, indices)
    }

}
