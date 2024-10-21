import Foundation
import simd

func radians(fromDegrees degrees: Float) -> Float {
    return degrees * (.pi / 180.0)
}

extension float4x4 {
    // Rotation around an arbitrary axis
    init(rotationAngle angle: Float, axis: SIMD3<Float>) {
        let normalizedAxis = normalize(axis)
        let x = normalizedAxis.x
        let y = normalizedAxis.y
        let z = normalizedAxis.z
        let c = cos(angle)
        let s = sin(angle)
        let mc = 1 - c

        self.init(columns: (
            SIMD4<Float>(c + x * x * mc,     x * y * mc - z * s,  x * z * mc + y * s,  0),
            SIMD4<Float>(y * x * mc + z * s, c + y * y * mc,      y * z * mc - x * s,  0),
            SIMD4<Float>(z * x * mc - y * s, z * y * mc + x * s,  c + z * z * mc,      0),
            SIMD4<Float>(0,                  0,                   0,                   1)
        ))
    }

    // Translation matrix
    static func translation(_ t: SIMD3<Float>) -> float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.3 = SIMD4<Float>(t.x, t.y, t.z, 1)
        return matrix
    }

    static func lookAt(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> float4x4 {
        let f = normalize(center - eye)
        let s = normalize(cross(f, up))
        let u = cross(s, f)

        var result = matrix_identity_float4x4
        result.columns.0 = SIMD4<Float>(s.x, u.x, -f.x, 0)
        result.columns.1 = SIMD4<Float>(s.y, u.y, -f.y, 0)
        result.columns.2 = SIMD4<Float>(s.z, u.z, -f.z, 0)
        result.columns.3 = SIMD4<Float>(-dot(s, eye), -dot(u, eye), dot(f, eye), 1)
        return result
    }

    // Perspective projection matrix
    static func perspective(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> float4x4 {
        let ys = 1 / tan(fovy * 0.5)
        let xs = ys / aspectRatio
        let zs = farZ / (nearZ - farZ)
        return float4x4(columns: (
            SIMD4<Float>(xs,  0,   0,         0),
            SIMD4<Float>(0,   ys,  0,         0),
            SIMD4<Float>(0,   0,   zs,       -1),
            SIMD4<Float>(0,   0,   zs * nearZ, 0)
        ))
    }
}
