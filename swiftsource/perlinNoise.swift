import Foundation

// A custom random number generator for reproducibility
struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        // Xorshift algorithm
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

class PerlinNoise2D {
    private var permutation: [Int] = []

    init(seed: UInt64) {
        var generator = SeededGenerator(seed: seed)
        permutation = Array(0...255)
        permutation.shuffle(using: &generator)
        permutation += permutation // Extend the permutation array
    }

    func noise(x: Double, y: Double) -> Double {
        // Find unit grid cell containing point
        let xi = Int(floor(x)) & 255
        let yi = Int(floor(y)) & 255

        // Relative x, y of point in cell
        let xf = x - floor(x)
        let yf = y - floor(y)

        // Compute fade curves for each of x, y
        let u = fade(xf)
        let v = fade(yf)

        // Hash coordinates of the square corners
        let aa = permutation[permutation[xi] + yi]
        let ab = permutation[permutation[xi] + yi + 1]
        let ba = permutation[permutation[xi + 1] + yi]
        let bb = permutation[permutation[xi + 1] + yi + 1]

        // Add blended results from 4 corners
        let x1 = lerp(
            gradient(hash: aa, x: xf, y: yf),
            gradient(hash: ba, x: xf - 1, y: yf),
            t: u
        )
        let x2 = lerp(
            gradient(hash: ab, x: xf, y: yf - 1),
            gradient(hash: bb, x: xf - 1, y: yf - 1),
            t: u
        )

        return lerp(x1, x2, t: v)
    }

    private func fade(_ t: Double) -> Double {
        // 6t^5 - 15t^4 + 10t^3
        return t * t * t * (t * (t * 6 - 15) + 10)
    }

    private func lerp(_ a: Double, _ b: Double, t: Double) -> Double {
        return a + t * (b - a)
    }

    private func gradient(hash: Int, x: Double, y: Double) -> Double {
        // Convert low 4 bits of hash code into 8 gradient directions
        let h = hash & 7
        let u = h < 4 ? x : y
        let v = h < 4 ? y : x
        let first = ((h & 1) == 0) ? u : -u
        let second = ((h & 2) == 0) ? v : -v
        return first + second
    }
}

func generatePerlinNoise2D(width: Int, height: Int, scale: Double, seed: UInt64) -> [[Double]] {
    let perlin = PerlinNoise2D(seed: seed)
    var noise = Array(repeating: Array(repeating: 0.0, count: width), count: height)
    for y in 0..<height {
        for x in 0..<width {
            let nx = Double(x) / Double(width) * scale
            let ny = Double(y) / Double(height) * scale
            noise[y][x] = perlin.noise(x: nx, y: ny)
        }
    }
    return noise
}

func generateFractalPerlinNoise2D(width: Int, width_offset: Int, height: Int, height_offset: Int, scale: Double, octaves: Int, persistence: Double, seed: UInt64) -> [[Double]] {
    var totalNoise = Array(repeating: Array(repeating: 0.0, count: width), count: height)
    var amplitude = 1.0
    var maxAmplitude = 0.0
    var frequency = scale
    let perlin = PerlinNoise2D(seed: seed)

    for _ in 0..<octaves {
        for y in 0..<height {
            for x in 0..<width {
                let y_offset = y + height_offset
                let x_offset = x + width_offset
                let nx = Double(x_offset) / Double(width) * frequency
                let ny = Double(y_offset) / Double(height) * frequency
                totalNoise[y][x] += perlin.noise(x: nx, y: ny) * amplitude
            }
        }
        maxAmplitude += amplitude
        amplitude *= persistence
        frequency *= 2
    }

    // Normalize the result
    for y in 0..<height {
        for x in 0..<width {
            totalNoise[y][x] /= maxAmplitude
        }
    }

    return totalNoise
}

class PerlinNoise3D {
    private var permutation: [Int]

    init(seed: UInt32 = 0) {
        // Initialize the permutation array with a given seed
        var p = Array(0...255)
        p.shuffle()
        permutation = p + p // Extend the permutation array
    }

    private func fade(_ t: Float) -> Float {
        // Fade function as defined by Ken Perlin
        return t * t * t * (t * (t * 6 - 15) + 10)
    }

    private func lerp(_ t: Float, _ a: Float, _ b: Float) -> Float {
        // Linear interpolation
        return a + t * (b - a)
    }

    private func grad(_ hash: Int, _ x: Float, _ y: Float, _ z: Float) -> Float {
        // Convert lower 4 bits of hash code into 12 gradient directions
        let h = hash & 15
        let u = h < 8 ? x : y
        let v = h < 4 ? y : (h == 12 || h == 14 ? x : z)
        return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v)
    }

    func noise(x: Float, y: Float, z: Float) -> Float {
        // Calculate unit cube coordinates
        let xi = Int(floor(x)) & 255
        let yi = Int(floor(y)) & 255
        let zi = Int(floor(z)) & 255

        // Relative position in cube
        let xf = x - floor(x)
        let yf = y - floor(y)
        let zf = z - floor(z)

        // Fade curves
        let u = fade(xf)
        let v = fade(yf)
        let w = fade(zf)

        // Hash coordinates
        let aaa = permutation[permutation[permutation[xi] + yi] + zi]
        let aba = permutation[permutation[permutation[xi] + yi + 1] + zi]
        let aab = permutation[permutation[permutation[xi] + yi] + zi + 1]
        let abb = permutation[permutation[permutation[xi] + yi + 1] + zi + 1]
        let baa = permutation[permutation[permutation[xi + 1] + yi] + zi]
        let bba = permutation[permutation[permutation[xi + 1] + yi + 1] + zi]
        let bab = permutation[permutation[permutation[xi + 1] + yi] + zi + 1]
        let bbb = permutation[permutation[permutation[xi + 1] + yi + 1] + zi + 1]

        // Blend results from corners
        let x1 = lerp(u, grad(aaa, xf, yf, zf), grad(baa, xf - 1, yf, zf))
        let x2 = lerp(u, grad(aba, xf, yf - 1, zf), grad(bba, xf - 1, yf - 1, zf))
        let y1 = lerp(v, x1, x2)

        let x3 = lerp(u, grad(aab, xf, yf, zf - 1), grad(bab, xf - 1, yf, zf - 1))
        let x4 = lerp(u, grad(abb, xf, yf - 1, zf - 1), grad(bbb, xf - 1, yf - 1, zf - 1))
        let y2 = lerp(v, x3, x4)

        let result = lerp(w, y1, y2)

        return (result + 1) / 2 // Normalize to [0,1]
    }
}

// Helper struct for seeded randomization
struct RandomNumberGeneratorSeeded: RandomNumberGenerator {
    init(seed: UInt32) { srand48(Int(seed)) }
    mutating func next() -> UInt64 { return UInt64(drand48() * Double(UInt64.max)) }
}

