import simd

class Camera {
    var position: SIMD3<Float>
    var front: SIMD3<Float>
    var up: SIMD3<Float>
    var right: SIMD3<Float>
    var worldUp: SIMD3<Float>

    var viewMatrix: float4x4
    var projectionMatrix: float4x4

    init(position: SIMD3<Float>, target: SIMD3<Float>, worldUp: SIMD3<Float>) {
        self.position = position
        self.front = normalize(target - position)
        self.worldUp = worldUp

        // Initialize right and up vectors
        self.right = normalize(cross(front, worldUp))
        self.up = normalize(cross(right, front))

        self.viewMatrix = float4x4.lookAt(eye: position, center: target, up: up)
        self.projectionMatrix = matrix_identity_float4x4
    }

    func updateViewMatrix() {
        let center = position + front
        viewMatrix = float4x4.lookAt(eye: position, center: center, up: up)
    }

    func updateProjectionMatrix(aspectRatio: Float) {
        let fovy = radians(fromDegrees: 45.0)
        projectionMatrix = float4x4.perspective(fovyRadians: fovy, aspectRatio: aspectRatio, nearZ: 1.0, farZ: 100.0)
    }

    func move(delta: SIMD3<Float>) {
        if (abs(delta.z) > 0.00001) {
            position += front * delta.z
        }
        if (abs(delta.x) > 0.00001) {
            position += right * delta.x
        }
        updateViewMatrix()
    }

    func rotate(yaw: Float, pitch: Float) {
        var newFront = SIMD3<Float>()
        newFront.x = cos(yaw) * cos(pitch)
        newFront.y = sin(pitch)
        newFront.z = sin(yaw) * cos(pitch)
        front = normalize(newFront)

        // Recalculate right and up vectors
        right = normalize(cross(front, worldUp))
        up = normalize(cross(right, front))

        updateViewMatrix()
    }

    func update(aspectRatio: Float) {
        // Update camera based on input
        updateViewMatrix()
        updateProjectionMatrix(aspectRatio: aspectRatio)
    }
}

