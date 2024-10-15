import OpenGL.GL3
import simd

import TextureModule

class Model: Renderable {
    var mesh: Mesh
    var shaderName: String
    var modelMatrix: float4x4
    var texture: texture_t

    var instances: [InstanceData] = []
    var activeInstances: Int = 0

    init(mesh: Mesh, shaderName: String, texture: texture_t) {
        self.mesh = mesh
        self.shaderName = shaderName
        self.modelMatrix = matrix_identity_float4x4
        self.texture = texture
    }

    func setupInstances() {
        let count = mesh.maxInstanceCount

        instances.reserveCapacity(count)
        for _ in 0..<count {
            let randomPosition = SIMD3<Float>( Float.random(in: -10.0...10.0), Float.random(in: -10.0...10.0), Float.random(in: -10.0...10.0))
            let rotationXMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(0, 1, 0))
            let rotationYMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(1, 0, 0))
            let modelMatrix = float4x4.translation(randomPosition) * rotationXMatrix * rotationYMatrix

            instances.append(InstanceData(modelMatrix: modelMatrix))
        }
        mesh.updateInstanceData(instances)
    }


    func draw() {
        glBindTexture(texture.type, texture.ID)
        mesh.drawInstances(count: activeInstances)
    }
}

