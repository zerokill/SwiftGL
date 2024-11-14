#version 330 core

uniform sampler2D tex0;

in vec2 texCoord;
in vec3 normal;

out vec4 FragColor;

vec3 ACESFilm(vec3 x) {
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((x*(a*x + b))/(x*(c*x + d) + e), 0.0, 1.0);
}


void main() {
    const float gamma = 2.2;
    vec3 hdrColor = texture(tex0, texCoord).rgb;
  
//    // reinhard tone mapping
//    vec3 mapped = hdrColor / (hdrColor + vec3(1.0));

    // Use in shader
    vec3 mapped = ACESFilm(hdrColor * 1.0);

//    // gamma correction 
//    mapped = pow(mapped, vec3(1.0 / gamma));
  
    FragColor = vec4(mapped, 1.0);
}

