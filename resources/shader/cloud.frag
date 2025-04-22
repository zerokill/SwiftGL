#version 330 core

uniform sampler3D tex0;
uniform sampler2D noiseTexture;
uniform vec3 cameraPos;
uniform vec3 lightPos;
uniform mat4 model;
uniform float uTime;

smooth in vec3 vUV;

out vec4 FragColor;

//constants
const int MAX_SAMPLES = 300;    //total samples for each ray march step
const float PI = 3.14159265359;
const float PHASEG = 0.8;

const vec3 texMin = vec3(0);    //minimum texture access coordinate
const vec3 texMax = vec3(1);    //maximum texture access coordinate

// precompute once
float phaseHG(float cosTheta, float g) {
    float denom = 4.0 * PI * pow(1.0 - g*g, 1.5);
    return (1.0 - g*g) / (denom * pow(1.0 + g*g - 2.0*g*cosTheta, 1.5));
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


float sampleDensity(vec3 p) {
    float raw   = texture(tex0, p).r;
    float noise = fbm(p);
    float d     = clamp(raw + noise * 0.5 - 0.5, 0.0, 1.0);
    return d;
}

float sdSphere(vec3 p, float radius) {
  return length(p) - radius;
}

float scene(vec3 p) {
  float distance = sdSphere(p - 0.5, 0.5);

  float f = fbm(p);

  return -distance + f;
}

vec4 raymarchMau2(vec3 rayOrigin) {
    const int NUM_STEPS = 50;
    const int NUM_LIGHT_STEPS = 20;

    float tStep = 1.0/float(NUM_STEPS);

    vec3 localCameraPos = vec3(inverse(model) * vec4(cameraPos, 1.0));
    vec3 localSunPos = vec3(inverse(model) * vec4(lightPos, 1.0));
    vec3 rayDirection = normalize((vUV-vec3(0.5)) - localCameraPos);
    vec3 rayStep = rayDirection * tStep;

    vec3 lightRayOrigin = vec3(0.0);
    vec3 lightDir = vec3(0.0);

    float transmittance = 1.0;
    const float DARKNESS_THRESHOLD = 0.10;

    float density = 0.0;
    float transmission = 0.0;
    float lightAccumulation = 0.0;
    float finalLight = 0.0;

    for (int i = 0; i < NUM_STEPS; i++) {
        rayOrigin += rayStep;

        // Bail when outside [0,1]^3
        if (any(lessThan(rayOrigin, texMin)) ||
            any(greaterThan(rayOrigin, texMax)))
            break;

//        float d = sampleDensity(rayOrigin);
        float d = scene(rayOrigin);
        if (d < 0.001) continue;        // empty space skip

        // ------- Shadow pass ---------
        float lightT = 1.0;
        vec3  lightPosStep = rayOrigin;
        vec3  lightDir = normalize(localSunPos - rayOrigin);
        for (int j = 0; j < NUM_LIGHT_STEPS; ++j)
        {
            lightPosStep += lightDir * 0.1;          // light step size

            if (any(lessThan(lightPosStep, texMin)) ||
                any(greaterThan(lightPosStep, texMax)))
                break;

            float ld = sampleDensity(lightPosStep);
            lightT *= exp(-ld * 2.0);                // extinction
            if (lightT < 0.01) break;               // early shadow exit
        }

        // Phase-based scattering
        float cosTheta = dot(rayDirection, lightDir);
        float phase    = phaseHG(cosTheta, PHASEG);
        float shaded   = phase * lightT;

        // ------- Accumulate color -------
        finalLight    += d * shaded * transmittance;
        transmittance *= exp(-d * 2.0);

        if (transmittance < 0.01) break;             // early primary exit

    }

    return vec4(vec3(finalLight), 1.0 - transmittance);

}


vec4 raymarchMau3(vec3 rayOrigin) {
    const int NUM_STEPS = 100;
    const float MARCH_SIZE = 0.08;

    float tStep = 1.0/float(NUM_STEPS);

    vec3 localCameraPos = vec3(inverse(model) * vec4(cameraPos, 1.0));
    vec3 rayDirection = normalize((vUV-vec3(0.5)) - localCameraPos);
    vec3 rayStep = rayDirection * tStep;


    vec4 res = vec4(0.0);


    for (int i = 0; i < NUM_STEPS; i++) {
        float density = scene(rayOrigin);

        if (density > 0.0)
        {
            vec4 color = vec4(mix(vec3(1.0,1.0,1.0), vec3(0.0, 0.0, 0.0), density), density );
            color.rgb *= color.a;
            res += color*(1.0-res.a);
        }


        rayOrigin += rayStep;


    }

    return res;

}


void main() {
    vec3 dataPos = vUV;

    FragColor = raymarchMau3(dataPos);
}
