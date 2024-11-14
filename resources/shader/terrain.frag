#version 330 core

out vec4 FragColor;

uniform bool visualizeNormals; // Toggle for normal visualization
uniform vec3 lightColor;
uniform vec3 lightPos;

uniform vec3 cameraPos;

in vec3 fragPos;
in vec3 normal;

const vec3 waterColor = vec3(0.0, 0.3, 0.6);
const vec3 sandColor = vec3(0.8, 0.7, 0.5);
const vec3 grassColor = vec3(0.1, 0.6, 0.2);
const vec3 rockColor = vec3(0.5, 0.5, 0.5);
const vec3 snowColor = vec3(1.0, 1.0, 1.0);
const float sandHeight = 0.5;
const float grassHeight = 2.0;
const float rockHeight = 4.0;
const float snowHeight = 5.0;

void main()
{
    float height = fragPos.y;
    vec3 color;

    if (height < 0.0)
    {
        color = waterColor;
    }
    else if (height < sandHeight)
    {
        color = sandColor;
    }
    else if (height < grassHeight)
    {
        float t = (height - sandHeight) / (grassHeight - sandHeight);
        color = mix(sandColor, grassColor, t);
    }
    else if (height < rockHeight)
    {
        float t = (height - grassHeight) / (rockHeight - grassHeight);
        color = mix(grassColor, rockColor, t);
    }
    else
    {
        float t = (height - rockHeight) / (snowHeight - rockHeight);
        color = mix(rockColor, snowColor, clamp(t, 0.0, 1.0));
    }

    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;

    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPos - fragPos);

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor * 0.5;

    vec3 result = (ambient + diffuse) * color;
    FragColor = vec4(result, 1.0);

    if (visualizeNormals) {
        vec3 color = normalize(normal) * 0.5 + 0.5;
        FragColor = vec4(color, 1.0);
    }

}

