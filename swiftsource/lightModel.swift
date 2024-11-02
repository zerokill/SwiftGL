import os
import OpenGL.GL3
import simd

import TextureModule

class LightModel: BaseModel {
    var instances: [InstanceData] = []
    var modelMatrix: float4x4 = matrix_identity_float4x4
    var positionMatrix: float4x4 = matrix_identity_float4x4
    var rotationMatrix: float4x4 = matrix_identity_float4x4
    var velocity: SIMD3<Float> = SIMD3<Float>()

    let dampingFactor: Float = 0.9

    init(mesh: Mesh, shaderName: String, texture: texture_t?, position: SIMD3<Float>) {
        modelMatrix = float4x4.translation(position)
        positionMatrix = float4x4.translation(position)
        super.init(mesh: mesh, shaderName: shaderName, texture: texture)
    }

    override func updateMove(deltaTime: Float) {
        let position = SIMD3<Float>(
            modelMatrix.columns.3.x,
            modelMatrix.columns.3.y,
            modelMatrix.columns.3.z
        )

        if let leonMesh = mesh as? LeonMesh {
            if ((position.y < leonMesh.sphereParameters.radius) && (velocity.y < 0)) {
                velocity.y = -velocity.y // Bounce up if we go below 0
                velocity *= dampingFactor;
            }

            // Naive gravity
            velocity.y -= 0.001;
        }
        let translation = velocity
        positionMatrix = positionMatrix * float4x4.translation(translation)
        if let leonMesh = mesh as? LeonMesh {
            if ((positionMatrix.columns.3.y < leonMesh.sphereParameters.radius) && (abs(velocity.y) < 0.001)) {
                positionMatrix.columns.3.y = leonMesh.sphereParameters.radius;
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

