#version 330 core

layout(location = 0) in vec3 aPos;

out vec3 texCoord;

// Inputs the matrices needed for 3D viewing with perspective
uniform mat4 view;
uniform mat4 proj;

out vec3 normal;

void main()
{
    texCoord = aPos;
    vec4 pos = proj * view * vec4(aPos, 1.0);
    gl_Position = pos.xyww;
}

