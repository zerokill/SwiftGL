struct vec3_t {
    var x: Float
    var y: Float
    var z: Float
}

struct scale_pos_t {
    var scale: vec3_t
    var position: vec3_t
}

// Vertex structure remains the same
struct Vertex {
    var position: SIMD3<Float>
    var normal: SIMD3<Float>
    var texCoords: SIMD2<Float>
}
