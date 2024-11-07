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

    override func updateMove(deltaTime: Float) {
        let translation = SIMD3<Float>(10.0, 0.0, 0.0)
        let rotationXMatrix = float4x4(rotationAngle: radians(fromDegrees: deltaTime*10), axis: SIMD3<Float>(0, 1, 0))
        rotationMatrix *= rotationXMatrix
        modelMatrix = positionMatrix * rotationMatrix * float4x4.translation(translation)
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

