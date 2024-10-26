import os
import OpenGL.GL3
import simd

import TextureModule

class Model: Renderable {
    var mesh: Mesh
    var shaderName: String
    var texture: texture_t

    var instances: [InstanceData] = []
    var activeInstances: Int = 0

    init(mesh: Mesh, shaderName: String, texture: texture_t) {
        self.mesh = mesh
        self.shaderName = shaderName
        self.texture = texture
    }

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
                let randomPosition = SIMD3<Float>( Float.random(in: -50.0...50.0), Float.random(in: -50.0...50.0), Float.random(in: -50.0...50.0))
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

    func shootInstance(position: SIMD3<Float>, direction: SIMD3<Float>, enableExplode: Bool) {
//        Logger.debug("shootInstance", position, direction)
        instances[activeInstances].enable = true
        instances[activeInstances].enableExplode = enableExplode
        instances[activeInstances].modelMatrix = float4x4.translation(position)
        instances[activeInstances].velocity = direction * 0.10

        instances[activeInstances].positionMatrix = float4x4.translation(position)

        // Random initial rotation
        let rotationXMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(0, 1, 0))
        let rotationYMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(1, 0, 0))
        instances[activeInstances].rotationMatrix = rotationXMatrix * rotationYMatrix
        instances[activeInstances].timeAlive = 0
        activeInstances += 1
    }

    func updateMove(deltaTime: Float, updateVelocity: Bool, updateRotation: Bool) {
        for i in instances.indices {
            if instances[i].timeAlive >= 0 {
                instances[i].timeAlive += deltaTime
            }

            // Update translation based on velocity and delta time
            if (updateVelocity) {
                let translation = instances[i].velocity
                instances[i].positionMatrix = instances[i].positionMatrix * float4x4.translation(translation)
                instances[i].modelMatrix = instances[i].positionMatrix * instances[i].rotationMatrix
            }

            if (instances[i].timeAlive > 4 && instances[i].enable) {
                instances[i].enable = false
                let position = SIMD3<Float>(
                    instances[i].modelMatrix.columns.3.x,
                    instances[i].modelMatrix.columns.3.y,
                    instances[i].modelMatrix.columns.3.z
                )

                if (instances[i].enableExplode) {
                    for _ in 1...100 {
                        let direction = SIMD3<Float>(x: Float.random(in: -10..<10), y: Float.random(in: -10..<10), z: Float.random(in: -10..<10))
                        shootInstance(position: position, direction: direction, enableExplode: false)
                    }
                }

                activeInstances -= 1
                instances.swapAt(i, activeInstances)    // Efficient removal. Swap is simpler then delete (O(n))
            }
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

    func draw() {
        glBindTexture(texture.type, texture.ID)
        mesh.drawInstances(count: activeInstances)
    }
}

