#version 330 core

layout(location = 0) in vec3 aPos;
layout(location = 1) in vec3 aNormal;
layout(location = 2) in vec2 aTex;
layout(location = 3) in mat4 instanceModel;


out vec2 texCoord;
out vec3 normal;
out vec3 fragPos;

// Inputs the matrices needed for 3D viewing with perspective
uniform mat4 view;
uniform mat4 proj;
uniform float rotation_x;
uniform float rotation_y;
uniform vec4 plane;

void main()
{
    // Create a rotation matrix around the Y-axis
    mat4 rotationY = mat4(
        cos(rotation_y), 0.0, sin(rotation_y), 0.0,
        0.0,             1.0, 0.0,             0.0,
       -sin(rotation_y), 0.0, cos(rotation_y), 0.0,
        0.0,             0.0, 0.0,             1.0
    );

    // Rotation matrix around X-axis
    mat4 rotationX = mat4(
        1.0, 0.0,              0.0,             0.0,
        0.0, cos(rotation_x), -sin(rotation_x), 0.0,
        0.0, sin(rotation_x),  cos(rotation_x), 0.0,
        0.0, 0.0,              0.0,             1.0
    );

    // Apply rotation to the instance model matrix
    mat4 transformedModel = instanceModel * rotationY * rotationX;

    vec4 worldPosition = transformedModel * vec4(aPos, 1.0);
    gl_Position = proj * view * worldPosition;
    gl_ClipDistance[0] = dot(worldPosition, plane);

    normal = mat3(transpose(inverse(transformedModel))) * aNormal;
    texCoord = aTex;
    fragPos = vec3(transformedModel * vec4(aPos, 1.0));
}
