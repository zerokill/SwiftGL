#version 330 core

uniform sampler3D tex0;
uniform sampler2D uSceneDepth; // resolved scene depth (half-res pass only)
uniform vec3 cameraPos;
uniform vec3 uSunDir;   // world-space direction TO the sun (directional light)
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
uniform int   uSteps;           // view ray steps (upper bound; short rays use fewer)
uniform int   uLightSteps;      // sun ray steps
uniform float uTime;
uniform vec3  uWindDir;
uniform float uWindSpeed;       // drift, in noise-texture repeats per second
uniform float uEvolveSpeed;     // extra scroll on the detail channel
uniform float uWorldNoiseScale; // world units per noise-texture repeat
uniform float uCloudBase;       // world-space bottom of the cloud layer
uniform float uCloudTop;        // world-space top of the cloud layer
uniform float uFadeStart;       // distance fade begin (world units from camera)
uniform float uFadeEnd;         // fully faded here
uniform float uLightMarchDist;  // world-space length of the sun march
uniform float uMaxRayDist;      // longest useful ray; uSteps are budgeted over this
uniform int   uUseDepth;        // 1 = clamp the march against uSceneDepth
uniform vec2  uCloudPassSize;   // pixel size of the pass, for gl_FragCoord -> UV
uniform vec3  uCamForward;      // camera forward, to turn eye depth into ray distance
uniform float uNear;
uniform float uFar;
uniform float uCurveR;          // fake planet radius: deck sinks d^2/2R with distance

smooth in vec3 vUV;
smooth in vec3 vWorldPos;

out vec4 FragColor;

const float PI = 3.14159265;
const float DENSITY_EPS = 1e-3; // below this the step contributes nothing visible

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

// Cumulus height shaping: flat-ish rounded bottoms, billowy falloff on top.
// The sample height is bent down with camera distance (fake planetary
// curvature) so the deck closes at the horizon instead of ending at the
// slab's bottom edge with a straight-line gap against the sky.
float heightShape(float y, float distCam) {
    float yEff = y + distCam * distCam / (2.0 * uCurveR);
    float h = clamp((yEff - uCloudBase) / (uCloudTop - uCloudBase), 0.0, 1.0);
    return smoothstep(0.0, 0.08, h) * (1.0 - smoothstep(0.35, 1.0, h));
}

// Density sampled by world position, so the anisotropic slab scale never
// stretches the noise. Base drifts with the wind; detail drifts faster plus
// a slow vertical scroll so shapes evolve instead of just translating.
float sampleDensity(vec3 worldP, float distCam) {
    float shape = heightShape(worldP.y, distCam);
    if (shape <= 0.0) {
        return 0.0;
    }

    vec3 uvw = worldP / uWorldNoiseScale;
    vec3 basePos = uvw * uTiling + uWindDir * (uWindSpeed * uTime);
    float base = texture(tex0, basePos).r;
    // Detail erosion only ever lowers density (remap output <= base), so an
    // empty base sample can skip the second texture fetch entirely.
    if (base <= 1.0 - uCoverage) {
        return 0.0;
    }

    vec3 detailPos = uvw * uTiling + uWindDir * (uWindSpeed * uTime * 1.6)
                   + vec3(0.0, uEvolveSpeed * uTime, 0.0);
    float detail = texture(tex0, detailPos).g;
    float n = clamp(remap(base, uDetailWeight * detail, 1.0, 0.0, 1.0), 0.0, 1.0);

    float d = clamp(n - (1.0 - uCoverage), 0.0, 1.0) * shape;
    return d * uDensityScale;
}

float hgPhase(float cosTheta, float g) {
    float g2 = g * g;
    return (1.0 - g2) / (4.0 * PI * pow(1.0 + g2 - 2.0 * g * cosTheta, 1.5));
}

// Cheaper density for the sun march: base shape only, no detail erosion.
// Shadows are low-frequency, so the missing detail is invisible but halves
// the texture fetches in the hottest loop.
float sampleDensityCheap(vec3 worldP, float distCam) {
    vec3 uvw = worldP / uWorldNoiseScale;
    vec3 basePos = uvw * uTiling + uWindDir * (uWindSpeed * uTime);
    float base = texture(tex0, basePos).r;

    float d = clamp(base - (1.0 - uCoverage), 0.0, 1.0) * heightShape(worldP.y, distCam);
    return d * uDensityScale;
}

// Beer's-law march toward the sun over a fixed world-space distance; the
// height shape zeroes density outside the layer, so no bounds test needed.
// distCam: the view-sample's camera distance; the sun march is short (~80
// world units) so the curvature drop barely changes along it.
float lightMarch(vec3 worldP, vec3 sunDir, float distCam) {
    float stepLen = uLightMarchDist / float(uLightSteps);
    float opticalDepth = 0.0;
    for (int j = 0; j < uLightSteps; j++) {
        vec3 q = worldP + sunDir * ((float(j) + 0.5) * stepLen);
        opticalDepth += sampleDensityCheap(q, distCam) * stepLen;
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

    // Everything past the fade (or behind scene geometry) is invisible, so
    // clamp the march to the visible interval - measured from the camera.
    float distStart = tStart * uvwToWorld;
    float distEnd = min(tEnd * uvwToWorld, uFadeEnd * 1.05);
    if (uUseDepth == 1) {
        float depth = texture(uSceneDepth, gl_FragCoord.xy / uCloudPassSize).r;
        float ndcZ = depth * 2.0 - 1.0;
        float eyeZ = 2.0 * uNear * uFar / (uFar + uNear - ndcZ * (uFar - uNear));
        float sceneDist = eyeZ / max(dot(worldRd, uCamForward), 1e-3);
        distEnd = min(distEnd, sceneDist);
    }
    if (distEnd <= distStart) {
        discard;
    }
    float worldSegLen = distEnd - distStart;

    // Fixed world-space sample density: uSteps are budgeted over the longest
    // useful ray, so a short ray straight up takes proportionally fewer steps
    // instead of oversampling 64x.
    float targetStep = uMaxRayDist / float(uSteps);
    int steps = clamp(int(ceil(worldSegLen / targetStep)), 8, uSteps);
    float stepWorld = worldSegLen / float(steps);
    float stepUVW = stepWorld / uvwToWorld;

    // Per-fragment jitter of the march start hides step banding
    float jitter = hash12(gl_FragCoord.xy);

    // Phase and sun tint are constant along the ray
    vec3 sunTerm = hgPhase(dot(worldRd, uSunDir), uPhaseG) * uScatterStrength * lightColor;

    float T = 1.0;
    vec3 color = vec3(0.0);

    for (int i = 0; i < uSteps; i++) {
        if (i >= steps) {
            break;
        }
        vec3 p = camUVW + rd * (tStart + (float(i) + jitter) * stepUVW);
        vec3 worldP = (model * vec4(p - 0.5, 1.0)).xyz;
        float distCam = distStart + (float(i) + jitter) * stepWorld;
        float d = sampleDensity(worldP, distCam);
        if (d > DENSITY_EPS) {
            d *= 1.0 - smoothstep(uFadeStart, uFadeEnd, distCam);
        }
        if (d > DENSITY_EPS) {
            float lightEnergy = lightMarch(worldP, uSunDir, distCam);
            color += T * lightEnergy * d * stepWorld * sunTerm;
            T *= exp(-d * uAbsorption * stepWorld);
            if (T < 0.01) {
                break;
            }
        }
    }

    // Premultiplied alpha, composited with glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)
    FragColor = vec4(color, 1.0 - T);
}
