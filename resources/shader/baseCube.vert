#version 330 core

layout(location = 0) in vec3 aPos;
layout(location = 1) in vec3 aColor;
layout(location = 2) in vec2 aTex;
layout(location = 3) in mat4 instanceModel;


out vec3 color;
out vec2 texCoord;

// Inputs the matrices needed for 3D viewing with perspective
uniform mat4 view;
uniform mat4 proj;

void main()
{
    gl_Position = proj * view * instanceModel * vec4(aPos, 1.0);

    color = aColor;
    texCoord = aTex;
}
