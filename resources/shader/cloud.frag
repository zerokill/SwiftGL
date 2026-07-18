#version 330 core

uniform sampler3D tex0;
uniform vec3 cameraPos;
uniform vec3 lightPos;
uniform vec3 lightColor;
uniform mat4 invModel;

uniform float uCoverage;      // 0..1, fraction of noise range that becomes cloud
uniform float uDensityScale;  // density multiplier
uniform float uAbsorption;    // extinction coefficient multiplier
uniform float uDarkness;      // minimum shadow term (darkness threshold)
uniform float uPhaseG;        // Henyey-Greenstein anisotropy
uniform float uScatterStrength; // in-scatter multiplier (~4*pi keeps clouds white)
uniform float uTiling;        // noise repetitions across the volume
uniform float uDetailWeight;  // how strongly detail noise erodes the base
uniform int   uSteps;         // view ray steps
uniform int   uLightSteps;    // sun ray steps
uniform float uTime;
uniform vec3  uWindDir;
uniform float uWindSpeed;     // drift, in volume widths per second
uniform float uEvolveSpeed;   // extra scroll on the detail channel

smooth in vec3 vUV;

out vec4 FragColor;

const float PI = 3.14159265;

// Slab-method intersection of a ray with the [0,1]^3 box.
// Returns (tEnter, tExit); the ray misses if tExit <= max(tEnter, 0).
vec2 intersectBox(vec3 ro, vec3 rd) {
    vec3 inv = 1.0 / rd;
    vec3 t0 = (vec3(0.0) - ro) * inv;
    vec3 t1 = (vec3(1.0) - ro) * inv;
    vec3 tmin = min(t0, t1);
    vec3 tmax = max(t0, t1);
    return vec2(max(max(tmin.x, tmin.y), tmin.z),
                min(min(tmax.x, tmax.y), tmax.z));
}

float remap(float v, float oldMin, float oldMax, float newMin, float newMax) {
    return newMin + (v - oldMin) / (oldMax - oldMin) * (newMax - newMin);
}

float sampleDensity(vec3 p) {
    // Base drifts with the wind; detail drifts faster plus a slow vertical
    // scroll, so shapes evolve instead of just translating (GL_REPEAT keeps
    // both seamless).
    vec3 basePos = p * uTiling + uWindDir * (uWindSpeed * uTime);
    vec3 detailPos = p * uTiling + uWindDir * (uWindSpeed * uTime * 1.6)
                   + vec3(0.0, uEvolveSpeed * uTime, 0.0);
    float base = texture(tex0, basePos).r;
    float detail = texture(tex0, detailPos).g;
    // High-frequency detail erodes the low-frequency base shape
    float n = clamp(remap(base, uDetailWeight * detail, 1.0, 0.0, 1.0), 0.0, 1.0);
    float d = clamp(n - (1.0 - uCoverage), 0.0, 1.0);
    return d * uDensityScale;
}

float hgPhase(float cosTheta, float g) {
    float g2 = g * g;
    return (1.0 - g2) / (4.0 * PI * pow(1.0 + g2 - 2.0 * g * cosTheta, 1.5));
}

// Beer's-law march from p toward the sun, in the same UVW space.
float lightMarch(vec3 p, vec3 sunDir) {
    float tExit = intersectBox(p, sunDir).y;
    float stepLen = tExit / float(uLightSteps);
    float opticalDepth = 0.0;
    for (int j = 0; j < uLightSteps; j++) {
        vec3 q = p + sunDir * ((float(j) + 0.5) * stepLen);
        opticalDepth += sampleDensity(q) * stepLen;
    }
    float transmit = exp(-opticalDepth * uAbsorption);
    return uDarkness + transmit * (1.0 - uDarkness);
}

void main() {
    // Everything happens in UVW space: local cube (-0.5..0.5) shifted to 0..1,
    // which is also the texture sampling space.
    vec3 camUVW = (invModel * vec4(cameraPos, 1.0)).xyz + 0.5;
    vec3 sunUVW = (invModel * vec4(lightPos, 1.0)).xyz + 0.5;

    vec3 rd = normalize(vUV - camUVW);
    vec2 hit = intersectBox(camUVW, rd);
    float tStart = max(hit.x, 0.0);
    float tEnd = hit.y;
    if (tEnd <= tStart) {
        discard;
    }

    float stepLen = (tEnd - tStart) / float(uSteps);
    float T = 1.0;
    vec3 color = vec3(0.0);

    for (int i = 0; i < uSteps; i++) {
        vec3 p = camUVW + rd * (tStart + (float(i) + 0.5) * stepLen);
        float d = sampleDensity(p);
        if (d > 1e-4) {
            vec3 sunDir = normalize(sunUVW - p);
            float lightEnergy = lightMarch(p, sunDir);
            float phase = hgPhase(dot(rd, sunDir), uPhaseG);
            color += T * lightEnergy * phase * uScatterStrength * d * stepLen * lightColor;
            T *= exp(-d * uAbsorption * stepLen);
            if (T < 0.01) {
                break;
            }
        }
    }

    // Premultiplied alpha, composited with glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)
    FragColor = vec4(color, 1.0 - T);
}
