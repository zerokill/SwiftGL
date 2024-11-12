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
    var lightColor: SIMD3<Float> = SIMD3<Float>()

    let dampingFactor: Float = 0.9

    init(mesh: Mesh, shaderName: String, texture: texture_t?, position: SIMD3<Float>, terrainMesh: Mesh) {
        self.terrainMesh = terrainMesh
        modelMatrix = float4x4.translation(position)
        positionMatrix = float4x4.translation(position)
        super.init(mesh: mesh, shaderName: shaderName, texture: texture)
    }

    func interpolateSunlightColor(position: Float) -> SIMD3<Float> {
        // Define the colors at midday and sunset using SIMD3<Float>
        let middayColor = SIMD3<Float>(1.0, 1.0, 0.9)    // Bright white light
        let sunsetColor = SIMD3<Float>(1.0, 0.5, 0.0)    // Orange light

        // Interpolate between the two colors
        let interpolatedColor = mix(sunsetColor, middayColor, t: position)

        return interpolatedColor
    }

    override func updateMove(deltaTime: Float) {
        let translation = SIMD3<Float>(100.0, 0.0, 0.0)
        let scale = SIMD3<Float>(10.0, 10.0, 10.0)
        let rotationZMatrix = float4x4(rotationAngle: radians(fromDegrees: -deltaTime*10), axis: SIMD3<Float>(0, 0, 1))
        rotationMatrix *= rotationZMatrix
        modelMatrix = positionMatrix * rotationMatrix * float4x4.translation(translation) * float4x4.scale(scale)

        let maxSunHeight: Float = 100.0  // Maximum height of the sun
        let minSunHeight: Float = 0.0    // Minimum height of the sun

        let position = SIMD3<Float>(
            modelMatrix.columns.3.x,
            modelMatrix.columns.3.y,
            modelMatrix.columns.3.z
        )

        // Normalize the position
        var normalizedPosition = (position.y - minSunHeight) / (maxSunHeight - minSunHeight)

        // Clamp the value between 0 and 1 to avoid unexpected results
        normalizedPosition = max(0.0, min(normalizedPosition, 1.0))

        lightColor = interpolateSunlightColor(position: normalizedPosition)
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

