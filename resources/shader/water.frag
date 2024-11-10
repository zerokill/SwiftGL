#version 330 core

out vec4 FragColor;

uniform sampler2D reflectionTexture;
uniform sampler2D refractionTexture;
uniform sampler2D dudvMap;

uniform float moveFactor;

in vec4 clipSpace;
in vec2 texCoord;
in vec3 toCameraVector;

const float waveStrength = 0.02;

void main()
{
    vec2 ndc = (clipSpace.xy/clipSpace.w)/2.0 + 0.5;

    vec2 refractionCoords = vec2(ndc.x, ndc.y);
    vec2 reflectionCoords = vec2(ndc.x, -ndc.y);

    vec2 distortion1 = (texture(dudvMap, vec2(texCoord.x + moveFactor, texCoord.y)).rg * 2.0 - 1.0) * waveStrength;
    vec2 distortion2 = (texture(dudvMap, vec2(-texCoord.x + moveFactor, texCoord.y + moveFactor)).rg * 2.0 - 1.0) * waveStrength;
    vec2 totalDistortion = distortion1 + distortion2;

    refractionCoords += totalDistortion;
    refractionCoords = clamp(refractionCoords, 0.001, 0.999);

    reflectionCoords += totalDistortion;
    reflectionCoords.x = clamp(reflectionCoords.x, 0.001, 0.999);
    reflectionCoords.y = clamp(reflectionCoords.y, -0.999, -0.001);

    vec4 refractionColor = texture(refractionTexture, refractionCoords);
    vec4 reflectionColor = texture(reflectionTexture, reflectionCoords);

    vec3 viewVector = normalize(toCameraVector);
    float refractiveFactor = dot(viewVector, vec3(0.0, 1.0, 0.0));
    refractiveFactor = pow(refractiveFactor, 1.5);

    FragColor = mix(reflectionColor, refractionColor, refractiveFactor);

}
