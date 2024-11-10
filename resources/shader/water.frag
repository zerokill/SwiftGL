#version 330 core

out vec4 FragColor;

uniform sampler2D reflectionTexture;
uniform sampler2D refractionTexture;
uniform sampler2D dudvMap;
uniform sampler2D normalMap;
uniform vec3 lightColor;

uniform float moveFactor;

in vec4 clipSpace;
in vec2 texCoord;
in vec3 toCameraVector;
in vec3 fromLightVector;

const float waveStrength = 0.04;
const float shineDamper = 20.0;
const float reflectivity = 0.8;

void main()
{
    vec2 ndc = (clipSpace.xy/clipSpace.w)/2.0 + 0.5;

    vec2 refractionCoords = vec2(ndc.x, ndc.y);
    vec2 reflectionCoords = vec2(ndc.x, -ndc.y);

    vec2 distortedTexCoords = texture(dudvMap, vec2(texCoord.x + moveFactor, texCoord.y)).rg * 0.1;
    distortedTexCoords = texCoord + vec2(distortedTexCoords.x, distortedTexCoords.y+moveFactor);
    vec2 totalDistortion = (texture(dudvMap, distortedTexCoords).rg * 2.0 - 1.0) * waveStrength;

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

    vec4 normalMapColor = texture(normalMap, distortedTexCoords/2.0);
    vec3 normal = vec3(normalMapColor.r * 2.0 - 1.0, normalMapColor.b, normalMapColor.g * 2.0 - 1.0);
    normal = normalize(normal);

    vec3 reflectedLight = reflect(normalize(fromLightVector), normal);
    float specular = max(dot(reflectedLight, viewVector), 0.0);
    specular = pow(specular, shineDamper);
    vec3 specularHightlights = lightColor * specular * reflectivity;

    FragColor = mix(reflectionColor, refractionColor, refractiveFactor);
    FragColor = mix(FragColor, vec4(0.0, 0.3, 0.5, 1.0), 0.2) + vec4(specularHightlights, 0.0);

}
