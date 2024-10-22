
struct scale_pos_t {
    var scale: SIMD3<Float>
    var position: SIMD3<Float>
}

// Vertex structure remains the same
struct Vertex {
    var position: SIMD3<Float>
    var color: SIMD3<Float>
//    var normal: SIMD3<Float>
    var texCoords: SIMD2<Float>
}
