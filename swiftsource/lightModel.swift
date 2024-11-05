import os
import OpenGL.GL3
import simd

import TextureModule

class LightModel: BaseModel {
    var terrainMesh: Mesh
    var modelMatrix: float4x4 = matrix_identity_float4x4
    var positionMatrix: float4x4 = matrix_identity_float4x4
    var rotationMatrix: float4x4 = matrix_identity_float4x4
    var velocity: SIMD3<Float> = SIMD3<Float>()

    let dampingFactor: Float = 0.9

    init(mesh: Mesh, shaderName: String, texture: texture_t?, position: SIMD3<Float>, terrainMesh: Mesh) {
        self.terrainMesh = terrainMesh
        modelMatrix = float4x4.translation(position)
        positionMatrix = float4x4.translation(position)
        super.init(mesh: mesh, shaderName: shaderName, texture: texture)
    }

    func getGroundHeight(atX x: Double, z: Double, terrainScale: Double, terrainVerticalScale: Double) -> (height: Float, normal: SIMD3<Float>) {
        let xPos = x / terrainScale
        let zPos = z / terrainScale

        let x0 = Int(floor(xPos)) + 500
        let x1 = x0 + 1
        let z0 = Int(floor(zPos)) + 500
        let z1 = z0 + 1

        guard x0 >= 0, x1 < terrainMesh.vertices.count, z0 >= 0, z1 < terrainMesh.vertices.count else {
            return (0.0, SIMD3<Float>(0, 1, 0)) // Default normal pointing up
        }

        return (terrainMesh.vertices[z0 * 1000 + x0].position.y, terrainMesh.vertices[z0 * 1000 + x0].normal)

//        let h00 = terrainMesh[z0][x0]
//        let h10 = terrainMesh[z0][x1]
//        let h01 = terrainMesh[z1][x0]
//        let h11 = terrainMesh[z1][x1]
//
//        let dx = xPos - Double(x0)
//        let dz = zPos - Double(z0)
//
//        let h0 = lerp(a: h00, b: h10, t: dx)
//        let h1 = lerp(a: h01, b: h11, t: dx)
//        let height = lerp(a: h0, b: h1, t: dz)
//
//        //Logger.info("height: ", Float(height * terrainVerticalScale))
//        return Float(height * terrainVerticalScale)
    }

    func lerp(a: Double, b: Double, t: Double) -> Double {
        return a + (b - a) * t
    }

    func reflect(_ velocity: SIMD3<Float>, over normal: SIMD3<Float>) -> SIMD3<Float> {
        return velocity - 2 * dot(velocity, normal) * normal
    }

    override func updateMove(deltaTime: Float) {
        let position = SIMD3<Float>(
            modelMatrix.columns.3.x,
            modelMatrix.columns.3.y,
            modelMatrix.columns.3.z
        )

        let heightNormal = getGroundHeight(atX: Double(position.x), z: Double(position.z), terrainScale: 0.1, terrainVerticalScale: 1.0)

        if let leonMesh = mesh as? LeonMesh {
            
            if ((position.y < heightNormal.height + leonMesh.sphereParameters.radius) && (velocity.y < 0)) {
                velocity = reflect(velocity, over: heightNormal.normal) * dampingFactor
            }

            // Naive gravity
            velocity.y -= 0.001;
        }
        let translation = velocity
        positionMatrix = positionMatrix * float4x4.translation(translation)
        if let leonMesh = mesh as? LeonMesh {
            if ((positionMatrix.columns.3.y < heightNormal.height + leonMesh.sphereParameters.radius) && (abs(velocity.y) < 0.001)) {
                positionMatrix.columns.3.y = heightNormal.height + leonMesh.sphereParameters.radius;
            }
        }
        modelMatrix = positionMatrix * rotationMatrix
    }

    func resetMove() -> InstanceData {
        return InstanceData(
            modelMatrix: matrix_identity_float4x4,
            enable: false,
            enableExplode: false,
            velocity: SIMD3<Float>(),
            positionMatrix: matrix_identity_float4x4,
            rotationMatrix: matrix_identity_float4x4,
            timeAlive: 0)
    }

    override func draw() {
        mesh.draw()
    }
}

