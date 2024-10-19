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

    func setupInstances() {
        let count = mesh.maxInstanceCount

        instances.reserveCapacity(count)
        for _ in 0..<count {
            instances.append(resetMove())
        }
        mesh.updateInstanceData(instances)
    }

    func shootInstance(position: SIMD3<Float>, direction: SIMD3<Float>) {
        instances[activeInstances].modelMatrix = float4x4.translation(position)
        instances[activeInstances].velocity = direction * 0.05

        instances[activeInstances].positionMatrix = float4x4.translation(position)

        let rotationXMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(0, 1, 0))
        let rotationYMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(1, 0, 0))
        instances[activeInstances].rotationMatrix = rotationXMatrix * rotationYMatrix
        activeInstances += 1
    }

    func updateMove(updateVelocity: Bool, updateRotation: Bool) {
        let count = mesh.maxInstanceCount
        for i in 0..<count {    // TODO: why cant i loop over the instances?
            // Update translation based on velocity and delta time
            if (updateVelocity) {
                let translation = instances[i].velocity
                instances[i].positionMatrix = instances[i].positionMatrix * float4x4.translation(translation)
                instances[i].modelMatrix = instances[i].positionMatrix * instances[i].rotationMatrix
            }
        }
        mesh.updateInstanceData(instances)
    }

    func resetAllInstances() {
        let count = mesh.maxInstanceCount
        for i in 0..<count {    // TODO: why cant i loop over the instances?
            instances[i] = resetMove()
        }
    }

    func resetMove() -> InstanceData {
        return InstanceData(modelMatrix: matrix_identity_float4x4, velocity: SIMD3<Float>(), positionMatrix: matrix_identity_float4x4, rotationMatrix: matrix_identity_float4x4)
    }

    func draw() {
        glBindTexture(texture.type, texture.ID)
        mesh.drawInstances(count: activeInstances)
    }
}

