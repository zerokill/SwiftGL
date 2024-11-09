#version 330 core

out vec4 FragColor;

uniform sampler2D tex0;
uniform sampler2D tex1;

in vec4 clipSpace;

void main()
{
    vec2 ndc = (clipSpace.xy/clipSpace.w)/2.0 + 0.5;

    vec2 refractionCoords = vec2(ndc.x, ndc.y);
    vec4 refractionColor = texture(tex1, refractionCoords);

    vec2 reflectionCoords = vec2(ndc.x, -ndc.y);
    vec4 reflectionColor = texture(tex0, reflectionCoords);

    FragColor = mix(reflectionColor, refractionColor, 0.5);

}
