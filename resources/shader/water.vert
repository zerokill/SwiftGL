#version 330 core

layout(location = 0) in vec3 aPos;  // FIXME: All of this is not needed for the lightShader

// Inputs the matrices needed for 3D viewing with perspective
uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

out vec4 clipSpace;

void main()
{
    clipSpace = proj * view * model * vec4(aPos, 1.0);
    gl_Position = clipSpace;
}
