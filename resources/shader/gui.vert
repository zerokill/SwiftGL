#version 330 core

layout(location = 0) in vec3 aPos;  // FIXME: All of this is not needed for the lightShader
layout(location = 1) in vec3 aNormal;
layout(location = 2) in vec2 aTex;

out vec2 texCoord;
out vec3 normal;

void main()
{
    gl_Position = vec4(aPos, 1.0);
    normal = aNormal;
    texCoord = aTex;
}

