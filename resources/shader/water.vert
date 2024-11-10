#version 330 core

layout(location = 0) in vec3 aPos;  // FIXME: All of this is not needed for the lightShader

// Inputs the matrices needed for 3D viewing with perspective
uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;
uniform vec3 cameraPos;
uniform vec3 lightPos;

out vec4 clipSpace;
out vec2 texCoord;
out vec3 toCameraVector;
out vec3 fromLightVector;

const float tiling = 1.0;

void main()
{
    vec4 worldPosition = model * vec4(aPos, 1.0);
    clipSpace = proj * view * worldPosition;
    gl_Position = clipSpace;
    texCoord = vec2(aPos.x/2.0 + 0.5, aPos.z/2.0 + 0.5) * tiling;
    toCameraVector = cameraPos - worldPosition.xyz;
    fromLightVector = worldPosition.xyz - lightPos;
}
