#version 330 core

uniform sampler3D tex0;
uniform vec3 cameraPos;
uniform mat4 model;

smooth in vec3 vUV;

out vec4 FragColor;

//constants
const int MAX_SAMPLES = 300;    //total samples for each ray march step
const vec3 texMin = vec3(0);    //minimum texture access coordinate
const vec3 texMax = vec3(1);    //maximum texture access coordinate

// Ray marching parameters
const vec3 STEP_SIZE = vec3(1.0/256.0, 1.0/256.0, 1.0/256.0);

void main() {
    float totalDensity = 0.0;

    vec3 dataPos = vUV;

    vec3 localCameraPos = vec3(inverse(model) * vec4(cameraPos, 1.0));

    vec3 geomDir = normalize((vUV-vec3(0.5)) - localCameraPos);

    vec3 dirStep = geomDir * STEP_SIZE;

    bool stop = false;

    float stepDensity;

    for (int i = 0; i < MAX_SAMPLES; i++) {
        dataPos = dataPos + dirStep;


        stop = dot(sign(dataPos-texMin),sign(texMax-dataPos)) < 3.0;

        if (stop)
            break;

        float sample = texture(tex0, dataPos).r;

        stepDensity = clamp(sample - 0.5, 0.0, 1.0);

        totalDensity += stepDensity;

        if (totalDensity >= 1.0) {
            break;
        }
    }

    vec3 cloudColor = vec3(1.0);
    FragColor = vec4(cloudColor, totalDensity);
}


