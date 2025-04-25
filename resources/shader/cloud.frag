#version 330 core

uniform sampler3D tex0;
uniform sampler2D noiseTexture;
uniform sampler2D bluenoiseTexture;
uniform vec3 cameraPos;
uniform vec3 lightPos;
uniform mat4 model;
uniform mat4 invModel;
uniform float uTime;

smooth in vec3 vUV;

out vec4 FragColor;

#define MAX_STEPS 50
#define ABSORPTION_COEFFICIENT 0.9

float noise(vec3 x ) {
  vec3 p = floor(x);
  vec3 f = fract(x);
  f = f*f*(3.0-2.0*f);

  vec2 uv = (p.xy+vec2(37.0,239.0)*p.z) + f.xy;
  vec2 tex = texture(noiseTexture,(uv)/256.0).yx;

  return mix( tex.x, tex.y, f.z ) * 2.0 - 1.0;
}

float fbm(vec3 p) {
  vec3 q = p + uTime * 0.5 * vec3(1.0, -0.2, -1.0);
  float g = noise(q);

  float f = 0.0;
  float scale = 0.5;
  float factor = 2.02;

  for (int i = 0; i < 5; i++) {
      f += scale * noise(q);
      q *= factor;
      factor += 0.21;
      scale *= 0.5;
  }

  return f;
}

float sdSphere(vec3 p, float radius) {
  return length(p) - radius;
}

float scene(vec3 p) {
  float distance = sdSphere(p - 0.5, 0.5);

  float f = fbm(p);

  return -distance + f;
}

vec4 raymarchDiffuse(vec3 rayOrigin, float offset) {
    const float MARCH_SIZE = 0.16;

    vec3 localCameraPos = vec3(invModel * vec4(cameraPos, 1.0));
    vec3 rayDirection = normalize((vUV-vec3(0.5)) - localCameraPos);
    vec3 rayStep = rayDirection * MARCH_SIZE * offset;

    vec3 localSunPos = vec3(invModel * vec4(lightPos, 1.0));
    vec3 lightDir = normalize(localSunPos - rayOrigin);

    vec4 res = vec4(0.0);

    for (int i = 0; i < MAX_STEPS; i++) {
        float density = scene(rayOrigin);

        if (density > 0.0)
        {
            // Directional derivative
            // For fast diffuse lighting
            float diffuse = clamp((scene(rayOrigin) - scene(rayOrigin + 0.3 * lightDir)) / 0.3, 0.0, 1.0 );

            vec3 lin = vec3(0.60,0.60,0.75) * 1.1 + 0.8 * vec3(1.0,0.6,0.3) * diffuse;
            vec4 color = vec4(mix(vec3(1.0, 1.0, 1.0), vec3(0.0, 0.0, 0.0), density), density );
            color.rgb *= lin;

            color.rgb *= color.a;
            res += color * (1.0 - res.a);
        }

        rayOrigin += rayStep;
    }

    return res;
}

void main() {
    vec3 dataPos = vUV;

    // Not sure if this works
    float blueNoise = texture(bluenoiseTexture, vUV.xy / 1024.0).r;
    float offset = fract(blueNoise); // + float(uTime) / sqrt(0.5));


    FragColor = raymarchDiffuse(dataPos, offset);
}
