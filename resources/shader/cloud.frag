#version 330 core

uniform sampler3D tex0;
uniform vec3 cameraPos;
uniform vec3 lightPos;
uniform mat4 model;

smooth in vec3 vUV;

out vec4 FragColor;

//constants
const int MAX_SAMPLES = 300;    //total samples for each ray march step
const vec3 texMin = vec3(0);    //minimum texture access coordinate
const vec3 texMax = vec3(1);    //maximum texture access coordinate

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

    float transmittance = 1.5;
    const float DARKNESS_THRESHOLD = 0.10;

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

        float sampleDensity = texture(tex0, rayOrigin).r;

        // Compute density
        float stepDensity = clamp(sampleDensity - 0.5, 0.0, 1.0);

        density += stepDensity;

        lightRayOrigin = rayOrigin;
        for (int j = 0; j < NUM_LIGHT_STEPS; j++) {
            const vec3 LIGHT_STEP_SIZE = vec3(1.0/10, 1.0/10, 1.0/10);
            lightRayOrigin += lightDir*(LIGHT_STEP_SIZE);

            if (dot(sign(lightRayOrigin-texMin),sign(texMax-lightRayOrigin)) < 3.0) {
                break;
            }

            float lightDensity = texture(tex0, lightRayOrigin).r;
            float stepLightDensity = clamp(lightDensity - 0.5, 0.0, 1.0);

            lightAccumulation += stepLightDensity;
        }

        float lightTransmission = exp(-lightAccumulation);

        float shadow = DARKNESS_THRESHOLD + lightTransmission * (1.0 - DARKNESS_THRESHOLD);

        finalLight += density*transmittance*shadow;

        transmittance *= exp(-density*0.5);
    }

    transmission = exp(-density);

    return vec4(vec3(finalLight), 1-transmission);
}


void main() {
    vec3 dataPos = vUV;

    FragColor = raymarchMau2(dataPos);
}
