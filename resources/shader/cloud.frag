#version 330 core

uniform sampler3D tex0;
uniform vec3 cameraPos;
uniform vec3 lightPos;
uniform vec3 lightColor;
uniform mat4 model;
uniform mat4 invModel;

uniform float uCoverage;        // 0..1, fraction of noise range that becomes cloud
uniform float uDensityScale;    // extinction density per world unit
uniform float uAbsorption;      // extinction coefficient multiplier
uniform float uDarkness;        // minimum shadow term (darkness threshold)
uniform float uPhaseG;          // Henyey-Greenstein anisotropy
uniform float uScatterStrength; // in-scatter multiplier
uniform float uTiling;          // noise repetitions
uniform float uDetailWeight;    // how strongly detail noise erodes the base
uniform int   uSteps;           // view ray steps
uniform int   uLightSteps;      // sun ray steps
uniform float uTime;
uniform vec3  uWindDir;
uniform float uWindSpeed;       // drift, in noise-texture repeats per second
uniform float uEvolveSpeed;     // extra scroll on the detail channel
uniform float uWorldNoiseScale; // world units per noise-texture repeat
uniform float uCloudBase;       // world-space bottom of the cloud layer
uniform float uCloudTop;        // world-space top of the cloud layer
uniform float uFadeStart;      // distance fade begin (world units from camera)
uniform float uFadeEnd;        // fully faded here
uniform float uLightMarchDist;  // world-space length of the sun march

smooth in vec3 vUV;
smooth in vec3 vWorldPos;

out vec4 FragColor;

const float PI = 3.14159265;

// Slab-method intersection of a ray with the [0,1]^3 box.
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

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Density sampled by world position, so the anisotropic slab scale never
// stretches the noise. Base drifts with the wind; detail drifts faster plus
// a slow vertical scroll so shapes evolve instead of just translating.
float sampleDensity(vec3 worldP) {
    vec3 uvw = worldP / uWorldNoiseScale;
    vec3 basePos = uvw * uTiling + uWindDir * (uWindSpeed * uTime);
    vec3 detailPos = uvw * uTiling + uWindDir * (uWindSpeed * uTime * 1.6)
                   + vec3(0.0, uEvolveSpeed * uTime, 0.0);
    float base = texture(tex0, basePos).r;
    float detail = texture(tex0, detailPos).g;
    float n = clamp(remap(base, uDetailWeight * detail, 1.0, 0.0, 1.0), 0.0, 1.0);

    // Cumulus height shaping: flat-ish rounded bottoms, billowy falloff on top
    float h = clamp((worldP.y - uCloudBase) / (uCloudTop - uCloudBase), 0.0, 1.0);
    float heightShape = smoothstep(0.0, 0.08, h) * (1.0 - smoothstep(0.35, 1.0, h));

    float d = clamp(n - (1.0 - uCoverage), 0.0, 1.0) * heightShape;
    return d * uDensityScale;
}

float hgPhase(float cosTheta, float g) {
    float g2 = g * g;
    return (1.0 - g2) / (4.0 * PI * pow(1.0 + g2 - 2.0 * g * cosTheta, 1.5));
}

// Cheaper density for the sun march: base shape only, no detail erosion.
// Shadows are low-frequency, so the missing detail is invisible but halves
// the texture fetches in the hottest loop.
float sampleDensityCheap(vec3 worldP) {
    vec3 uvw = worldP / uWorldNoiseScale;
    vec3 basePos = uvw * uTiling + uWindDir * (uWindSpeed * uTime);
    float base = texture(tex0, basePos).r;

    float h = clamp((worldP.y - uCloudBase) / (uCloudTop - uCloudBase), 0.0, 1.0);
    float heightShape = smoothstep(0.0, 0.08, h) * (1.0 - smoothstep(0.35, 1.0, h));

    float d = clamp(base - (1.0 - uCoverage), 0.0, 1.0) * heightShape;
    return d * uDensityScale;
}

// Beer's-law march toward the sun over a fixed world-space distance; the
// height shape zeroes density outside the layer, so no bounds test needed.
float lightMarch(vec3 worldP, vec3 sunDir) {
    float stepLen = uLightMarchDist / float(uLightSteps);
    float opticalDepth = 0.0;
    for (int j = 0; j < uLightSteps; j++) {
        vec3 q = worldP + sunDir * ((float(j) + 0.5) * stepLen);
        opticalDepth += sampleDensityCheap(q) * stepLen;
        // Already essentially opaque toward the sun: transmit < e^-6
        if (opticalDepth * uAbsorption > 6.0) {
            break;
        }
    }
    float transmit = exp(-opticalDepth * uAbsorption);
    return uDarkness + transmit * (1.0 - uDarkness);
}

void main() {
    // Ray set up in UVW space (0..1 box coords) for the intersection, but all
    // distances, sampling and lighting are world-space.
    vec3 camUVW = (invModel * vec4(cameraPos, 1.0)).xyz + 0.5;
    vec3 rd = normalize(vUV - camUVW);
    vec2 hit = intersectBox(camUVW, rd);
    float tStart = max(hit.x, 0.0);
    float tEnd = hit.y;
    if (tEnd <= tStart) {
        discard;
    }

    // World-space length of one unit of UVW-space ray parameter
    float uvwToWorld = length(mat3(model) * rd);
    vec3 worldRd = normalize(mat3(model) * rd);

    // Clamp horizon rays: beyond the fade there is nothing to see anyway
    float worldSegLen = min((tEnd - tStart) * uvwToWorld, uFadeEnd * 1.05);
    float stepWorld = worldSegLen / float(uSteps);
    float stepUVW = stepWorld / uvwToWorld;

    // Per-fragment jitter of the march start hides step banding
    float jitter = hash12(gl_FragCoord.xy);

    float T = 1.0;
    vec3 color = vec3(0.0);

    for (int i = 0; i < uSteps; i++) {
        vec3 p = camUVW + rd * (tStart + (float(i) + jitter) * stepUVW);
        vec3 worldP = (model * vec4(p - 0.5, 1.0)).xyz;
        float d = sampleDensity(worldP);
        if (d > 1e-5) {
            float distCam = distance(worldP, cameraPos);
            d *= 1.0 - smoothstep(uFadeStart, uFadeEnd, distCam);
        }
        if (d > 1e-5) {
            vec3 sunDir = normalize(lightPos - worldP);
            float lightEnergy = lightMarch(worldP, sunDir);
            float phase = hgPhase(dot(worldRd, sunDir), uPhaseG);
            color += T * lightEnergy * phase * uScatterStrength * d * stepWorld * lightColor;
            T *= exp(-d * uAbsorption * stepWorld);
            if (T < 0.01) {
                break;
            }
        }
    }

    // Premultiplied alpha, composited with glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)
    FragColor = vec4(color, 1.0 - T);
}
