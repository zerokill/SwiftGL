#version 330 core

layout(location = 0) in vec3 aPos;  // FIXME: All of this is not needed for the lightShader

// Inputs the matrices needed for 3D viewing with perspective
uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

smooth out vec3 vUV;

void main()
{
    vec4 worldPosition = model * vec4(aPos, 1.0);
    gl_Position = proj * view * worldPosition;
    vUV = aPos + vec3(0.5);
}

