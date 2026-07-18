#version 330 core

// Renders one Z slice of a tileable 3D Perlin-FBM texture.
// R = base FBM (low octaves), G = detail FBM (high octaves).

in vec2 texCoord;

out vec4 FragColor;

uniform float uSlice;   // slice z in 0..1 (= (z + 0.5) / size)
uniform float uPeriod;  // base lattice period in cells; every octave doubles it
uniform int   uOctaves; // total octaves, split between base (first 3) and detail
uniform uint  uSeed;

// PCG-style integer hash (Jarzynski & Olano)
uvec3 pcg3d(uvec3 v) {
    v = v * 1664525u + 1013904223u;
    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v ^= v >> 16u;
    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    return v;
}

// Gradient at an integer lattice corner, wrapped to the period so the
// noise tiles seamlessly under GL_REPEAT.
vec3 gradientAt(vec3 corner, float period, uint seed) {
    uvec3 cell = uvec3(ivec3(mod(corner, period)));
    uvec3 h = pcg3d(cell + uvec3(seed, seed * 747796405u + 1u, seed * 2891336453u + 1u));
    vec3 g = vec3(h) * (2.0 / 4294967295.0) - 1.0;
    return normalize(g + vec3(1e-5));
}

// Periodic gradient (Perlin) noise, output roughly in [-1, 1]
float perlin(vec3 p, float period, uint seed) {
    vec3 pi = floor(p);
    vec3 pf = p - pi;
    vec3 w = pf * pf * pf * (pf * (pf * 6.0 - 15.0) + 10.0);

    float n000 = dot(gradientAt(pi + vec3(0,0,0), period, seed), pf - vec3(0,0,0));
    float n100 = dot(gradientAt(pi + vec3(1,0,0), period, seed), pf - vec3(1,0,0));
    float n010 = dot(gradientAt(pi + vec3(0,1,0), period, seed), pf - vec3(0,1,0));
    float n110 = dot(gradientAt(pi + vec3(1,1,0), period, seed), pf - vec3(1,1,0));
    float n001 = dot(gradientAt(pi + vec3(0,0,1), period, seed), pf - vec3(0,0,1));
    float n101 = dot(gradientAt(pi + vec3(1,0,1), period, seed), pf - vec3(1,0,1));
    float n011 = dot(gradientAt(pi + vec3(0,1,1), period, seed), pf - vec3(0,1,1));
    float n111 = dot(gradientAt(pi + vec3(1,1,1), period, seed), pf - vec3(1,1,1));

    float nx00 = mix(n000, n100, w.x);
    float nx10 = mix(n010, n110, w.x);
    float nx01 = mix(n001, n101, w.x);
    float nx11 = mix(n011, n111, w.x);
    float nxy0 = mix(nx00, nx10, w.y);
    float nxy1 = mix(nx01, nx11, w.y);
    // ~1/0.7 compensates the sub-unit amplitude of gradient noise
    return mix(nxy0, nxy1, w.z) * 1.4;
}

// FBM over octaves [first, first+count), amplitudes normalized to sum to 1.
// Each octave's period is the base period doubled per octave, so every
// octave (and therefore the sum) tiles across the unit cube.
float fbm(vec3 p, int first, int count, uint seed) {
    float sum = 0.0;
    float ampSum = 0.0;
    for (int i = 0; i < count; i++) {
        int oct = first + i;
        float period = uPeriod * exp2(float(oct));
        float amp = exp2(-float(i));
        sum += amp * perlin(p * period, period, seed + uint(oct) * 101u);
        ampSum += amp;
    }
    return clamp((sum / ampSum) * 0.5 + 0.5, 0.0, 1.0);
}

void main() {
    vec3 p = vec3(texCoord, uSlice);

    int baseOctaves = min(3, uOctaves);
    int detailOctaves = max(uOctaves - baseOctaves, 1);

    float base = fbm(p, 0, baseOctaves, uSeed);
    float detail = fbm(p, baseOctaves, detailOctaves, uSeed);

    FragColor = vec4(base, detail, 0.0, 1.0);
}
