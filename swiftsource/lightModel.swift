import os
import OpenGL.GL3
import simd

class LightModel: BaseModel {
    var instances: [InstanceData] = []
    var activeInstances: Int = 0

    let dampingFactor: Float = 0.9

    func setupInstances(randomPosition: Bool = false) {
        let count = mesh.maxInstanceCount

        instances.reserveCapacity(count)
        for _ in 0..<count {
            instances.append(resetMove())
        }
        mesh.updateInstanceData(instances)
    }

    func addInstance(position: SIMD3<Float>) {
        instances[activeInstances].modelMatrix = float4x4.translation(position)
        instances[activeInstances].positionMatrix = float4x4.translation(position)
        activeInstances += 1
    }

    override func updateMove(deltaTime: Float) {
        for i in instances.indices {
            let position = SIMD3<Float>(
                instances[i].modelMatrix.columns.3.x,
                instances[i].modelMatrix.columns.3.y,
                instances[i].modelMatrix.columns.3.z
            )

            if let leonMesh = mesh as? LeonMesh {
                if ((position.y < leonMesh.sphereParameters.radius) && (instances[i].velocity.y < 0)) {
                    instances[i].velocity.y = -instances[i].velocity.y // Bounce up if we go below 0
                    instances[i].velocity *= dampingFactor;
                }

                // Naive gravity
                instances[i].velocity.y -= 0.001;
            }
            let translation = instances[i].velocity
            instances[i].positionMatrix = instances[i].positionMatrix * float4x4.translation(translation)
            if let leonMesh = mesh as? LeonMesh {
                if ((instances[i].positionMatrix.columns.3.y < leonMesh.sphereParameters.radius) && (abs(instances[i].velocity.y) < 0.001)) {
                    instances[i].positionMatrix.columns.3.y = leonMesh.sphereParameters.radius;
                }
            }
            instances[i].modelMatrix = instances[i].positionMatrix * instances[i].rotationMatrix
        }
        mesh.updateInstanceData(instances)
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
        mesh.drawInstances(count: activeInstances)
    }
}

