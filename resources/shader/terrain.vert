#version 330 core

layout(location = 0) in vec3 aPos;  // FIXME: All of this is not needed for the lightShader
layout(location = 1) in vec3 aNormal;
layout(location = 2) in vec2 aTex;

// Inputs the matrices needed for 3D viewing with perspective
uniform mat4 view;
uniform mat4 proj;

uniform vec4 plane;

out vec3 normal;
out vec3 fragPos;

void main()
{
    vec4 worldPosition = vec4(aPos, 1.0);
    gl_Position = proj * view * worldPosition;
    gl_ClipDistance[0] = dot(worldPosition, plane);

    fragPos = vec3(vec4(aPos, 1.0));
    normal = aNormal;
}

