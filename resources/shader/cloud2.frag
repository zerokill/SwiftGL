#version 330 core

uniform sampler3D tex0;
uniform sampler2D noiseTexture;
uniform vec3 cameraPos;
uniform vec3 lightPos;
uniform vec3 lightColor;
uniform mat4 model;
uniform float uTime;

smooth in vec3 vUV;

out vec4 FragColor;

#define MAX_STEPS 100

float sdSphere(vec3 p, float radius) {
    return length(p) - radius;
}

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

  for (int i = 0; i < 6; i++) {
      f += scale * noise(q);
      q *= factor;
      factor += 0.21;
      scale *= 0.5;
  }

  return f;
}

float scene(vec3 p) {
  float distance = sdSphere(p, 1.0);

  float f = fbm(p);

  return -distance + f;
}

const float MARCH_SIZE = 0.08;

vec4 raymarch(vec3 rayOrigin, vec3 rayDirection) {
  float depth = 0.0;
  vec3 p = rayOrigin + depth * rayDirection;
  
  vec4 res = vec4(0.0);

  for (int i = 0; i < MAX_STEPS; i++) {
    float density = scene(p);

    // We only draw the density if it's greater than 0
    if (density > 0.0) {
      vec4 color = vec4(mix(vec3(1.0,1.0,1.0), vec3(0.0, 0.0, 0.0), density), density );
      color.rgb *= color.a;
      res += color*(1.0-res.a);
    }

    depth += MARCH_SIZE;
    p = rayOrigin + depth * rayDirection;
  }

  return res;
}

void main() {
  // Ray Origin - camera
  vec3 localCameraPos = vec3(inverse(model) * vec4(cameraPos, 1.0));

  // Ray Direction
  vec3 rd = normalize(vUV - localCameraPos);
  
  vec3 color = vec3(0.0);
  vec4 res = raymarch(localCameraPos, rd);
  color = res.rgb;

  FragColor = vec4(color, 1.0);
}
