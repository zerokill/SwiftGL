import simd

class Camera {
    var position: SIMD3<Float>
    var front: SIMD3<Float>
    var up: SIMD3<Float>
    var viewMatrix: float4x4
    var projectionMatrix: float4x4

    init(position: SIMD3<Float>, target: SIMD3<Float>, up: SIMD3<Float>) {
        self.position = position
        self.front = normalize(target - position)
        self.up = up
        self.viewMatrix = float4x4.lookAt(eye: position, center: target, up: up)
        self.projectionMatrix = matrix_identity_float4x4
    }

    func updateViewMatrix() {
        let center = position + front
        viewMatrix = float4x4.lookAt(eye: position, center: center, up: up)
    }

    func updateProjectionMatrix(aspectRatio: Float) {
        let fovy = radians(fromDegrees: 45.0)
        projectionMatrix = float4x4.perspective(fovyRadians: fovy, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100.0)
    }

    func move(delta: SIMD3<Float>) {
        position += delta
        updateViewMatrix()
    }

    func rotate(yaw: Float, pitch: Float) {
        var newFront = SIMD3<Float>()
        newFront.x = cos(yaw) * cos(pitch)
        newFront.y = sin(pitch)
        newFront.z = sin(yaw) * cos(pitch)
        front = normalize(newFront)
        updateViewMatrix()
    }

    func update() {
        // Update camera based on input
//        updateViewMatrix()
    }
}

