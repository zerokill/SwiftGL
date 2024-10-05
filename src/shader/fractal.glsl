#version 330 core

uniform vec2 iResolution;
uniform float iTime;

out vec4 FragColor;

in vec3 color;
in vec3 pos;

void mainImage( out vec4 fragColor, in vec2 fragCoord );

void main()
{
    mainImage(FragColor, gl_FragCoord.xy);
}

const float MAX_ITER = 512.0;


float mandelbrot(vec2 uv) {
    vec2 c = 1.0 * uv - vec2(0.7, 0.0);
    c= c / pow(iTime, 4.0) - vec2(0.65, 0.45);
    vec2 z = vec2(0.0);

    float l = 0.0;

    for (float i = 0; i < MAX_ITER; i++) {
        z = vec2(z.x * z.x - z.y * z.y,
                2.0 * z.x * z.y) + c;

        if (dot(z, z) > 32.0) return l / MAX_ITER;
        l++;
    }
    return 0.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord - 0.9 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);

    float m = mandelbrot(uv);
    col += m;

    fragColor = vec4(col, 1.0);
}

