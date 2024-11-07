#version 330 core

uniform sampler2D tex0;

in vec2 texCoord;
in vec3 normal;

out vec4 FragColor;

void main() {
    vec4 texColor =  texture(tex0, texCoord);
    FragColor = texColor;
}

