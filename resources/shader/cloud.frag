#version 330 core

uniform sampler3D tex0;
uniform sampler2D noiseTexture;
uniform vec3 cameraPos;
uniform vec3 lightPos;
uniform vec3 lightColor;
uniform mat4 model;
uniform float uTime;

smooth in vec3 vUV;

out vec4 FragColor;

//constants
const int MAX_SAMPLES = 300;    //total samples for each ray march step
const vec3 texMin = vec3(0);    //minimum texture access coordinate
const vec3 texMax = vec3(1);    //maximum texture access coordinate

#define absorptionCoef 1
#define scatteringCoef 4
#define extinctionCoef (absorptionCoef + scatteringCoef)
#define PI 3.14159265359

const vec3 AABBMax = vec3(1.0, 1.0, 1.0);
const vec3 AABBMin = vec3(-1.0, -1.0, -1.0);

float sdSphere(vec3 p, float radius) {
    return length(p) - radius;
}

float noise(vec3 x ) {
  vec3 p = floor(x);
  vec3 f = fract(x);
  f = f*f*(3.0-2.0*f);

  vec2 uv = (p.xy+vec2(37.0,239.0)*p.z) + f.xy;
  vec2 tex = texture(noiseTexture,(uv)/256.0).yx;

  return mix( tex.x, tex.y, f.z ) * 2.0 - 1.0;
}

float fbm(vec3 p) {
  vec3 q = p + uTime * 0.5 * vec3(1.0, -0.2, -1.0);
  float g = noise(q);

  float f = 0.0;
  float scale = 0.5;
  float factor = 2.02;

  for (int i = 0; i < 6; i++) {
      f += scale * noise(q);
      q *= factor;
      factor += 0.21;
      scale *= 0.5;
  }

  return f;
}

float scene(vec3 p) {
  float distance = sdSphere(p, 1.0);

  float f = fbm(p);

  return -distance + f;
}


bool AABBIntersect(vec3 rayOrigin, vec3 rayDir, vec3 boxMin, vec3 boxMax, out vec3 near, out vec3 far)
{
    mat4 invModel = inverse(model);
    rayOrigin = (invModel * vec4(rayOrigin, 1.0)).xyz;
    rayDir = (invModel * vec4(rayDir, 0.0)).xyz;
    vec3 invDir = 1.0 / rayDir;
    vec3 t0s = (boxMin - rayOrigin) * invDir;
    vec3 t1s = (boxMax - rayOrigin) * invDir;
    vec3 tsmaller = min(t0s, t1s);
    vec3 tbigger = max(t0s, t1s);
    float tmin = max(max(tsmaller.x, tsmaller.y), tsmaller.z);
    float tmax = min(min(tbigger.x, tbigger.y), tbigger.z);
    near = (model * vec4(rayOrigin + rayDir * tmin, 1.0)).xyz;
    far = (model * vec4(rayOrigin + rayDir * tmax, 1.0)).xyz;
    return tmax > tmin;
}

float hgPhase(float g, float cosTheta)
{
	float numer = 1.0f - g * g;
	float denom = 1.0f + g * g + 2.0f * g * cosTheta;
	return numer / (4.0f * PI * denom * sqrt(denom));
}

float dualLobPhase(float g0, float g1, float w, float cosTheta)
{
	return mix(hgPhase(g0, cosTheta), hgPhase(g1, cosTheta), w);
}

float getTransmittanceLight(vec3 pos, vec3 lightDir, vec3 lightPos)
{
    const int NUM_LIGHT_STEPS = 30;
    float stepSize = length((model * vec4(AABBMax, 1.0) - model * vec4(AABBMin, 1.0)).xyz) / NUM_LIGHT_STEPS / 2;

    float transmittance = 1;
    vec3 lightRayOrigin = pos;
    for(int i = 0; i < NUM_LIGHT_STEPS; i++)
    {
        lightRayOrigin += lightDir*stepSize;

        if (dot(sign(lightRayOrigin-texMin),sign(texMax-lightRayOrigin)) < 3.0) {
            break;
        }

        float density = texture(tex0, lightRayOrigin).r;
        transmittance *= exp(-density * extinctionCoef * stepSize);
    }
    return 2 * transmittance * (1 - transmittance * transmittance);
}


vec3 calculateLightVolume(vec3 pos, vec3 viewDir, vec3 lightDir) {
    vec3 result = vec3(0.3);

    float phase = dualLobPhase(0.5, -0.5, 0.3, dot(lightDir, viewDir));
    float transmittance = getTransmittanceLight(pos, lightDir, lightPos);
    float intensity = 2.0;

    result = phase * transmittance * intensity * lightColor;

    return result;
}

vec4 raymarchMau3(vec3 rayOrigin) {
    const int NUM_STEPS = 50;

    const float STEP_SIZE = 1.0/NUM_STEPS;

    vec3 localCameraPos = vec3(inverse(model) * vec4(cameraPos, 1.0));
    vec3 localSunPos = vec3(inverse(model) * vec4(lightPos, 1.0));
    vec3 rayDirection = normalize((vUV-vec3(0.5)) - localCameraPos);

    vec3 lightDir;

    vec3 color = vec3(0.0);
    float transmittance = 1.0;

    float lightAccumulation = 0.0;

    vec3 near, far;
    if(!AABBIntersect(cameraPos, rayDirection, AABBMin, AABBMax, near, far))
    {
        discard;
    }

    float stepSize = length(far - near) / float(NUM_STEPS);


    for (int i = 0; i < NUM_STEPS; i++) {
        rayOrigin += rayDirection * stepSize;
        lightDir = normalize(localSunPos - rayOrigin);

        if (dot(sign(rayOrigin-texMin),sign(texMax-rayOrigin)) < 3.0) {
            break;
        }

//        float sampleDensity = texture(tex0, rayOrigin).r;
        float sampleDensity = scene(rayOrigin);
        transmittance *= exp(-sampleDensity*extinctionCoef*stepSize);

        vec3 inScattering = calculateLightVolume(rayOrigin, -rayDirection, lightDir);
        float outScattering = scatteringCoef * sampleDensity;
        vec3 currentLight = inScattering * outScattering;

        color += transmittance * currentLight;
    }

    return vec4(color, 1-transmittance);
}


vec4 raymarchMau2(vec3 rayOrigin) {
    const int NUM_STEPS = 50;
    const int NUM_LIGHT_STEPS = 20;

    const vec3 STEP_SIZE = vec3(1.0/NUM_STEPS, 1.0/NUM_STEPS, 1.0/NUM_STEPS);

    vec3 localCameraPos = vec3(inverse(model) * vec4(cameraPos, 1.0));
    vec3 localSunPos = vec3(inverse(model) * vec4(lightPos, 1.0));
    vec3 rayDirection = normalize((vUV-vec3(0.5)) - localCameraPos);
    vec3 rayStep = rayDirection * STEP_SIZE;

    vec3 lightRayOrigin = vec3(0.0);
    vec3 lightDir = vec3(0.0);

    float transmittance = 1.0;
    const float DARKNESS_THRESHOLD = 0.25;
    const float NOISE_THRESHOLD = 0.5;

    float density = 0.0;
    float transmission = 0.0;
    float lightAccumulation = 0.0;
    float finalLight = 0.0;

    for (int i = 0; i < NUM_STEPS; i++) {
        rayOrigin += rayDirection * STEP_SIZE;
        lightDir = normalize(localSunPos - rayOrigin);

        if (dot(sign(rayOrigin-texMin),sign(texMax-rayOrigin)) < 3.0) {
            break;
        }

        float sampleDensity = scene(rayOrigin);
//        float sampleDensity = texture(tex0, rayOrigin).r;
//
        // Compute density
        float stepDensity = clamp(sampleDensity - 0.5, 0.0, 1.0);

        density += stepDensity;

//        lightRayOrigin = rayOrigin;
//        for (int j = 0; j < NUM_LIGHT_STEPS; j++) {
//            const vec3 LIGHT_STEP_SIZE = vec3(1.0/10, 1.0/10, 1.0/10);
//            lightRayOrigin += lightDir*(LIGHT_STEP_SIZE);
//
//            if (dot(sign(lightRayOrigin-texMin),sign(texMax-lightRayOrigin)) < 3.0) {
//                break;
//            }
//
//            float lightDensity = texture(tex0, lightRayOrigin).r;
//            float stepLightDensity = clamp(lightDensity - 0.5, 0.0, 1.0);
//
//            lightAccumulation += stepLightDensity;
//        }
//
//        float lightTransmission = exp(-lightAccumulation);
//
//        float shadow = DARKNESS_THRESHOLD + lightTransmission * (1.0 - DARKNESS_THRESHOLD);
//
//        finalLight += density*transmittance*shadow;
//
//        transmittance *= exp(-density*0.5);
    }

    transmission = exp(-density);

    return vec4(vec3(1.0), 1-transmission);
}


void main() {
    vec3 dataPos = vUV;

    FragColor = raymarchMau3(dataPos);
}
