#version 330 core

// Upsamples the half-res cloud pass onto the screen. The cloud color is
// premultiplied, so the blend is glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA).
uniform sampler2D uCloudTex;

in vec2 texCoord;

out vec4 FragColor;

void main()
{
    FragColor = texture(uCloudTex, texCoord);
}
