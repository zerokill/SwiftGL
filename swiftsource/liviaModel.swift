import os
import OpenGL.GL3
import simd

class LiviaModel: BaseModel {

    var instances: [InstanceData] = []
    var activeInstances: Int = 0

    let dampingFactor: Float = 0.8

    func setupInstances(randomPosition: Bool = false) {
        let count = mesh.maxInstanceCount

        instances.reserveCapacity(count)
        for _ in 0..<count {
            instances.append(resetMove())
        }
        mesh.updateInstanceData(instances)
    }

    func setupRandomInstances(randomPosition: Bool = false) {
        let count = mesh.maxInstanceCount

        instances.reserveCapacity(count)
        for _ in 0..<count {
            var instance = resetMove()
            if randomPosition {
                let randomPosition = SIMD3<Float>( Float.random(in: -50.0...50.0), Float.random(in: 0.0...50.0), Float.random(in: -50.0...50.0))
                let rotationXMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(0, 1, 0))
                let rotationYMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(1, 0, 0))
                instance.positionMatrix = float4x4.translation(randomPosition)
                instance.rotationMatrix = rotationXMatrix * rotationYMatrix
                instance.enable = true
                instance.timeAlive = -1
                activeInstances += 1
            }
            instances.append(instance)
        }
        mesh.updateInstanceData(instances)
    }

    func addInstance(position: SIMD3<Float>) {
//        Logger.debug("shootInstance", position, direction)
        instances[activeInstances].enable = true
        instances[activeInstances].enableExplode = false
        instances[activeInstances].modelMatrix = float4x4.translation(position)
        instances[activeInstances].positionMatrix = float4x4.translation(position)

        instances[activeInstances].timeAlive = -1
        activeInstances += 1
    }

    override func updateMove(deltaTime: Float) {
        for i in instances.indices {
            let position = SIMD3<Float>(
                instances[i].modelMatrix.columns.3.x,
                instances[i].modelMatrix.columns.3.y,
                instances[i].modelMatrix.columns.3.z
            )

            if instances[i].timeAlive >= 0 {
                instances[i].timeAlive += deltaTime
            }

            // Update translation based on velocity and delta time
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

    func resetAllInstances() {
        for i in instances.indices {
            instances[i] = resetMove()
        }
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
        if let texture = self.texture {
            glBindTexture(texture.type, texture.ID)
        }
        mesh.drawInstances(count: activeInstances)
    }
}


