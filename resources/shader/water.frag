#version 330 core

out vec4 FragColor;

uniform bool visualizeNormals; // Toggle for normal visualization
uniform vec3 objectColor;
uniform vec3 lightColor;
uniform vec3 lightPos;
uniform float time;

uniform vec3 cameraPos;
uniform samplerCube skybox;

in vec2 texCoord;
in vec3 fragPos;
in vec3 normal;

vec2 hash2(vec2 p ) {
   return fract(sin(vec2(dot(p, vec2(123.4, 748.6)), dot(p, vec2(547.3, 659.3))))*5232.85324);
}
float hash(vec2 p) {
  return fract(sin(dot(p, vec2(43.232, 75.876)))*4526.3257);
}

//Based off of iq's described here: https://iquilezles.org/articles/voronoilines
float voronoi(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float md = 5.0;
    vec2 m = vec2(0.0);
    for (int i = -1;i<=1;i++) {
        for (int j = -1;j<=1;j++) {
            vec2 g = vec2(i, j);
            vec2 o = hash2(n+g);
            o = 0.5+0.5*sin(time+5.038*o);
            vec2 r = g + o - f;
            float d = dot(r, r);
            if (d<md) {
              md = d;
              m = n+g+o;
            }
        }
    }
    return md;
}

float ov(vec2 p) {
    float v = 0.0;
    float a = 0.4;
    for (int i = 0;i<3;i++) {
        v+= voronoi(p)*a;
        p*=2.0;
        a*=0.5;
    }
    return v;
}

void main()
{

	vec2 uv = texCoord.xy;
    vec4 a = vec4(0.2, 0.4, 1.0, 0.5);
    vec4 b = vec4(0.85, 0.9, 1.0, 0.5);
	vec4 voronoiColor = vec4(mix(a, b, smoothstep(0.0, 0.5, ov(uv*5.0))));

    // Compute the view vector
    vec3 viewVector = normalize(fragPos - cameraPos);

    // Reflect the view vector around the normal
    vec3 reflectedVector = reflect(viewVector, normalize(normal));

    // Sample the skybox texture using the reflected vector
    vec3 reflectionColor = texture(skybox, reflectedVector).rgb;

    // Optional: Apply Fresnel effect
    float fresnelFactor = pow(1.0 - dot(normalize(normal), -viewVector), 3.0);

    // Mix with water color if desired
    vec3 waterColor = vec3(0.0, 0.3, 0.5);
    vec3 finalColor = mix(waterColor, reflectionColor, fresnelFactor);

    float alpha = mix(0.2, 0.8, fresnelFactor);

    FragColor = vec4(finalColor, alpha);
//    FragColor = voronoiColor;
}
