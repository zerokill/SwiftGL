#version 330 core

layout(location = 0) in vec3 aPos;
layout(location = 1) in vec3 aColor;
layout(location = 2) in vec2 aTex;

out vec3 color;
out vec2 texCoord;

uniform vec3 uScale;
uniform vec3 uPosition;

// Inputs the matrices needed for 3D viewing with perspective
uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

void main()
{
//    vec3 scaledPositon = aPos * uScale;
//    vec3 finalPosition = scaledPositon + uPosition;
//    gl_Position = vec4(
//            finalPosition,
//            1.0);
    gl_Position = proj * view * model * vec4(aPos, 1.0);
    color = aColor;
    texCoord = aTex;
}
