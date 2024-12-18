#version 330 core

layout(location = 0) in vec3 aPos;  // FIXME: All of this is not needed for the lightShader
layout(location = 1) in vec3 aNormal;
layout(location = 2) in vec2 aTex;

// Inputs the matrices needed for 3D viewing with perspective
uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

out vec3 normal;

void main()
{
    gl_Position = proj * view * model * vec4(aPos, 1.0);
    normal = aNormal;
}
