#version 330 core

layout(location = 0) in vec3 aPos;
layout(location = 1) in vec3 aColor;

out vec3 color;
//out vec3 pos;

uniform vec3 uScale;
uniform vec3 uPosition;

void main()
{
    vec3 scaledPositon = aPos * uScale;
    vec3 finalPosition = scaledPositon + uPosition;
    gl_Position = vec4(
            finalPosition,
            1.0);
    color = aColor;
}
