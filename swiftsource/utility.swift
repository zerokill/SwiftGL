import simd

extension float4x4 {
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

//    static func perspective(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> float4x4 {
//        let ys = 1 / tan(fovy * 0.5)
//        let xs = ys / aspectRatio
//        let zs = farZ / (nearZ - farZ)
//
//        var result = float4x4()
//        result.columns = (
//            SIMD4<Float>(xs,  0,   0,   0),
//            SIMD4<Float>(0,   ys,  0,   0),
//            SIMD4<Float>(0,   0,   zs, -1),
//            SIMD4<Float>(0,   0,   zs * nearZ,  0)
//        )
//        return result
//    }
}

//func radians(fromDegrees degrees: Float) -> Float {
//    return degrees * (.pi / 180.0)
//}

