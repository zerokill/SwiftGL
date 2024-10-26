#version 330 core

out vec4 FragColor;

uniform bool visualizeNormals; // Toggle for normal visualization
uniform vec3 objectColor;
uniform vec3 lightColor;
uniform vec3 lightPos;

in vec3 fragPos;
in vec3 normal;

void main()
{
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;

    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPos - fragPos); 

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

    vec3 result = (ambient + diffuse) * objectColor;
    FragColor = vec4(result, 1.0);

    if (visualizeNormals) {
        vec3 color = normalize(normal) * 0.5 + 0.5;
        FragColor = vec4(color, 1.0);
    }
}