#version 330 core

layout(location = 0) in vec3 aPos;
layout(location = 2) in vec2 aTex;

out vec2 texCoord;

// GL_CLIP_DISTANCE0 is enabled globally; an unwritten gl_ClipDistance is
// undefined and can clip parts of the full-screen quad.
out float gl_ClipDistance[1];

void main()
{
    gl_Position = vec4(aPos.xy, 0.0, 1.0);
    texCoord = aTex;
    gl_ClipDistance[0] = 1.0;
}
