#version 330 core

uniform vec2 iResolution;
uniform float iTime;

uniform bool visualizeNormals; // Toggle for normal visualization
uniform vec3 objectColor;
uniform vec3 lightColor;
uniform vec3 lightPos;

out vec4 FragColor;

in vec2 texCoord;
in vec3 fragPos;
in vec3 normal;

uniform sampler2D tex0;

void main()
{
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;

    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPos - fragPos);

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

    vec3 result = (ambient + diffuse);
    vec4 texColor =  texture(tex0, texCoord);

    FragColor = vec4(result, 1.0) * texColor;

    if (visualizeNormals) {
        vec3 color = normalize(normal) * 0.5 + 0.5;
        FragColor = vec4(color, 1.0);
    }
}
