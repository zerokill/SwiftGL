#version 330 core

uniform sampler3D tex0;
uniform vec3 cameraPos;
uniform vec3 lightPos;

in vec3 normal;
in vec3 fragPos;

out vec4 FragColor;

// Ray marching parameters
const int MAX_STEPS = 64;
const float MAX_DISTANCE = 100.0;
const float STEP_SIZE = MAX_DISTANCE / float(MAX_STEPS);

void main() {

    vec3 rayOrigin = cameraPos;
    vec3 rayDirection = normalize(fragPos - cameraPos);

    float totalDensity = 0.0;
    float stepDensity;
    vec3 position;

    vec3 volumeMin = vec3(-5.0, -5.0, -5.0);
    vec3 volumeMax = vec3(5.0, 5.0, 5.0);
    vec3 volumeSize = volumeMax - volumeMin;

    for (int i = 0; i < MAX_STEPS; i++) {
        float distance = float(i) * STEP_SIZE;
        position = rayOrigin + rayDirection * distance;
        position.z += 5.0;
        position.y -= 5.0;
        position.x -= 5.0;

        // Sample noise texture
        float noiseValue = texture(tex0, position * 0.010).r;

        if (noiseValue > 0.1) {
            totalDensity = 1.0;
            break;
        }
    }

    // Compute lighting
    vec3 lightDir = normalize(lightPos - fragPos);
    float lightIntensity = max(dot(rayDirection, lightDir), 0.0);

    // Final color
    vec3 cloudColor = vec3(1.0) * lightIntensity;
    FragColor = vec4(cloudColor, totalDensity);
}


