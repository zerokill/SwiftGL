#version 330 core

layout(location = 0) in vec3 aPos;

// Inputs the matrices needed for 3D viewing with perspective
uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

smooth out vec3 vUV;
smooth out vec3 vWorldPos;

// GL_CLIP_DISTANCE0 is enabled globally; leaving gl_ClipDistance unwritten
// makes it undefined and the driver clips random chunks of the slab.
out float gl_ClipDistance[1];

void main()
{
    vec4 worldPosition = model * vec4(aPos, 1.0);
    vec4 clipPos = proj * view * worldPosition;
    // The slab extends past the camera's far plane; unclamped, the far
    // triangles get frustum-clipped and leave straight-edged holes in the
    // sky with no fragments at all. Clamp z so the geometry always
    // rasterizes; the raymarch works in world space and doesn't care.
    clipPos.z = min(clipPos.z, clipPos.w * 0.9999);
    gl_Position = clipPos;
    vUV = aPos + vec3(0.5);
    vWorldPos = worldPosition.xyz;
    gl_ClipDistance[0] = 1.0;
}
