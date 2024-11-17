import os
import OpenGL.GL3
import simd

import ImguiModule
import TextureModule

class LightModel: BaseModel {
    var terrainMesh: Mesh
    var modelMatrix: float4x4 = matrix_identity_float4x4
    var positionMatrix: float4x4 = matrix_identity_float4x4
    var rotationMatrix: float4x4 = matrix_identity_float4x4
    var velocity: SIMD3<Float> = SIMD3<Float>()
    var lightColor: SIMD3<Float> = SIMD3<Float>()

    init(mesh: Mesh, shaderName: String, texture: texture_t?, position: SIMD3<Float>, terrainMesh: Mesh) {
        self.terrainMesh = terrainMesh
        modelMatrix = float4x4.translation(position)
        positionMatrix = float4x4.translation(SIMD3<Float>(0.0, 100.0, 0.0))//float4x4.translation(position)
        super.init(mesh: mesh, shaderName: shaderName, texture: texture)
    }

    func interpolateSunlightColor(position: Float) -> SIMD3<Float> {
        let nightColor   = SIMD3<Float>(0.05, 0.05, 0.2)          // Dark blue
        let sunriseColor = SIMD3<Float>(1.0, 0.5, 0.0)   * 2.0    // Orange
        let dayColor     = SIMD3<Float>(1.0, 1.0, 1.0)   * 0.9    // White

        var color = SIMD3<Float>()

        ImGuiWrapper_Text(String(format: "lightPosition %f", position))

        if position < 0.5 {
            // Night to Sunrise
            let t = position / 0.5
            color = mix(nightColor, sunriseColor, t: t)
        } else {
            // Sunset to Night
            let t = (position - 0.5) / 0.5
            color = mix(sunriseColor, dayColor, t: t)
        }

        return color
    }

    override func updateMove(deltaTime: Float) {
        let translation = SIMD3<Float>(100.0, 0.0, 0.0)
        let scale = SIMD3<Float>(10.0, 10.0, 10.0)
        let rotationZMatrix = float4x4(rotationAngle: radians(fromDegrees: -deltaTime*10), axis: SIMD3<Float>(0, 0, 1))
//        rotationMatrix *= rotationZMatrix
        modelMatrix = positionMatrix * rotationMatrix * float4x4.translation(translation) * float4x4.scale(scale)

        let maxSunHeight: Float = 100.0  // Maximum height of the sun
        let minSunHeight: Float = -100.0 // Minimum height of the sun

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

