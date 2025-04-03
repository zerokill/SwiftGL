#version 330 core

#define PI 3.14159265359

//struct PointLight {
//    vec4 position;
//    vec4 color;
//    float intensity;
//};
//
//struct DirectionalLight {
//    vec3 direction;
//    vec3 color;
//    float intensity;
//};
//
//struct SpotLight {
//    vec4 position;
//    vec4 direction;
//    vec4 color;
//    float intensity;
//    float cutOff;
//    float outerCutOff;
//};
//
//struct Material {
//    float kd;
//    float ks;
//};
//
//uniform uint GL_Num_PointLight;
//uniform uint GL_Num_SpotLight;
//
//uniform vec3 GL_AmbientLight;
//uniform DirectionalLight GL_DirectionalLight;
//
//layout(std430, binding=0) buffer GL_PointLight_Buffer
//{
//    PointLight GL_PointLight[];
//};
//
//layout(std430, binding=1) buffer GL_SpotLight_Buffer
//{
//    SpotLight GL_SpotLight[];
//};
//
//float schlickPhase(float k, float cosTheta)
//{
//    float a1 = 1 - k * cosTheta;
//    return 1.0 / (4 * PI) * (1 - k * k) / (a1 * a1);
//}
//
float hgPhase(float g, float cosTheta)
{
	float numer = 1.0f - g * g;
	float denom = 1.0f + g * g + 2.0f * g * cosTheta;
	return numer / (4.0f * PI * denom * sqrt(denom));
}

float dualLobPhase(float g0, float g1, float w, float cosTheta)
{
	return mix(hgPhase(g0, cosTheta), hgPhase(g1, cosTheta), w);
}

//// viewDir: pos ==> camera
//vec3 calculateLight(vec3 pos, vec3 normal, vec3 viewDir, vec3 kd, vec3 ks)
//{
//    // here is a simple blinn-phong model
//    vec3 result = kd * GL_AmbientLight;
//    if(dot(viewDir, normal) <= 0)
//        return result;
//
//    // calculate directional light
//    vec3 lightDir = -vec3(GL_DirectionalLight.direction);
//    vec3 halfDir = normalize(lightDir + viewDir);
//    float intensity = GL_DirectionalLight.intensity;
//    result += (kd * max(dot(lightDir, normal) + 0.1, 0) + ks * pow(max(dot(halfDir, normal), 0), 8)) * intensity * vec3(GL_DirectionalLight.color);
//
//
//    // calculate point light
//    for(int i = 0; i < GL_Num_PointLight; i++)
//    {
//        float distance = length(vec3(GL_PointLight[i].position) - pos);
//        lightDir = normalize(vec3(GL_PointLight[i].position) - pos);
//        halfDir = normalize(lightDir + viewDir);
//        intensity = GL_PointLight[i].intensity / (distance * distance);
//        result += (kd * max(dot(lightDir, normal) + 0.1, 0) + ks * pow(max(dot(halfDir, normal), 0), 8)) * intensity * vec3(GL_PointLight[i].color);
//    }
//    
//    // calculate spot light
//    for(int i = 0; i < GL_Num_SpotLight; i++)
//    {
//        float distance = length(vec3(GL_SpotLight[i].position) - pos);
//        lightDir = normalize(vec3(GL_SpotLight[i].position) - pos);
//        halfDir = normalize(lightDir + viewDir);
//        float spotEffect = dot(-vec3(GL_SpotLight[i].direction), lightDir);
//        if(spotEffect > cos(GL_SpotLight[i].cutOff))
//        {
//            spotEffect = 1.0;
//        }
//        else if(spotEffect <= cos(GL_SpotLight[i].cutOff) && spotEffect > cos(GL_SpotLight[i].outerCutOff))
//        {
//            spotEffect = (spotEffect - cos(GL_SpotLight[i].outerCutOff)) / (cos(GL_SpotLight[i].cutOff) - cos(GL_SpotLight[i].outerCutOff));
//        }
//        else
//        {
//            spotEffect = 0;
//        }
//        intensity = spotEffect * GL_SpotLight[i].intensity / (distance * distance);
//        result += (kd * max(dot(lightDir, normal) + 0.1, 0) + ks * pow(max(dot(halfDir, normal), 0), 8)) * intensity * vec3(GL_SpotLight[i].color);
//    }    
//
//    return result;
//}
//


#define MAX_STEPS 32
#define MAX_LIGHT_STEPS 16

#define absorptionCoef 1
#define scatteringCoef 4
#define extinctionCoef (absorptionCoef + scatteringCoef)

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

uniform vec3 cameraPos;
uniform vec3 lightPos;
uniform vec3 lightColor;
const vec3 AABBMin = vec3(-1, -1, -1);
const vec3 AABBMax = vec3(1, 1, 1);

uniform sampler3D tex0;

in vec3 WorldPos;
out vec4 FragColor;

bool AABBIntersect(vec3 rayOrigin, vec3 rayDir, vec3 boxMin, vec3 boxMax, out vec3 near, out vec3 far);
vec3 worldPos2Coord(vec3 worldPos);
float getTransmittanceLight(vec3 pos, vec3 lightDir, vec3 lightPos, bool directional);
vec3 calculateLightVolume(vec3 pos, vec3 viewDir);

void main()
{
    // camera ==> pos
    vec3 dir = normalize(WorldPos - cameraPos);
    vec3 near, far;
    if(!AABBIntersect(WorldPos, dir, AABBMin, AABBMax, near, far))
    {
        discard;
    }

    vec4 nearScreenPos = proj * view * vec4(near, 1.0);
    nearScreenPos /= nearScreenPos.w;

    // discard back face if near face is in the camera
    if(length(WorldPos - far) < 1e-3 && nearScreenPos.z < 1.0 && nearScreenPos.z > -1.0)
    {
        discard;
    }

    // camera is inside the box
    if((cameraPos - near).x / dir.x > 0)
    {
        near = cameraPos;
    }

    float stepSize = length(far - near) / float(MAX_STEPS);
    vec3 color = vec3(0.0);
    float transmittance = 1.0;

    // ray marching loop
    for(int i = 0; i < MAX_STEPS; i++)
    {
        vec3 pos = near + dir * stepSize * float(i + 0.5);
        vec3 coord = worldPos2Coord(pos);
        float density = texture(tex0, coord).r;
        transmittance *= exp(-density * extinctionCoef * stepSize);

        vec3 inScattering = calculateLightVolume(pos, -dir);
        float outScattering = scatteringCoef * density;
        vec3 currentLight = inScattering * outScattering;

        color += transmittance * currentLight * stepSize;
    }
	FragColor = vec4(color / (1 - transmittance), 1 - transmittance);
}

bool AABBIntersect(vec3 rayOrigin, vec3 rayDir, vec3 boxMin, vec3 boxMax, out vec3 near, out vec3 far)
{
    mat4 invModel = inverse(model);
    rayOrigin = (invModel * vec4(rayOrigin, 1.0)).xyz;
    rayDir = (invModel * vec4(rayDir, 0.0)).xyz;
    vec3 invDir = 1.0 / rayDir;
    vec3 t0s = (boxMin - rayOrigin) * invDir;
    vec3 t1s = (boxMax - rayOrigin) * invDir;
    vec3 tsmaller = min(t0s, t1s);
    vec3 tbigger = max(t0s, t1s);
    float tmin = max(max(tsmaller.x, tsmaller.y), tsmaller.z);
    float tmax = min(min(tbigger.x, tbigger.y), tbigger.z);
    near = (model * vec4(rayOrigin + rayDir * tmin, 1.0)).xyz;
    far = (model * vec4(rayOrigin + rayDir * tmax, 1.0)).xyz;
    return tmax > tmin;
}

vec3 worldPos2Coord(vec3 worldPos)
{
    vec3 localPos = (inverse(model) * vec4(worldPos, 1.0)).xyz;
    return (localPos - AABBMin) / (AABBMax - AABBMin);
}

float getTransmittanceLight(vec3 pos, vec3 lightDir, vec3 lightPos, bool directional)
{
    float stepSize = length((model * vec4(AABBMax, 1.0) - model * vec4(AABBMin, 1.0)).xyz) / MAX_LIGHT_STEPS / 2;
    if(!directional)
    {
        stepSize = min(stepSize, length(lightPos - pos) / MAX_LIGHT_STEPS);
    }
    float transmittance = 1;
    for(int i = 0; i < MAX_LIGHT_STEPS; i++)
    {
        vec3 coord = worldPos2Coord(pos);
        float density = texture(tex0, coord).r;
        transmittance *= exp(-density * extinctionCoef * stepSize);
        pos += lightDir * stepSize;
    }
    return 2 * transmittance * (1 - transmittance * transmittance);
}

// viewDir: pos ==> camera
vec3 calculateLightVolume(vec3 pos, vec3 viewDir)
{
    vec3 baseColor = vec3(0.3);
    vec3 result = baseColor + vec3(0.1); //GL_AmbientLight;

//    // calculate directional light   
//    vec3 lightDir = -vec3(GL_DirectionalLight.direction);
//    float phase = dualLobPhase(0.5, -0.5, 0.3, dot(lightDir, viewDir));
//    float transmittance = getTransmittanceLight(pos, lightDir, vec3(0), true);
//    float intensity = GL_DirectionalLight.intensity;
//    result += phase * transmittance * intensity * vec3(GL_DirectionalLight.color);
//
//    // calculate point light
//    for(int i = 0; i < GL_Num_PointLight; i++)
//    {
        float distance = length(vec3(lightPos) - pos);
        vec3 lightDir = normalize(vec3(lightPos) - pos);
        float phase = dualLobPhase(0.5, -0.5, 0.3, dot(lightDir, viewDir));
        float transmittance = getTransmittanceLight(pos, lightDir, vec3(lightPos), false);
        float intensity = 1.0 / (distance * distance);
        result += phase * transmittance * intensity * vec3(lightColor);
//    }
//    
//    // calculate spot light
//    for(int i = 0; i < GL_Num_SpotLight; i++)
//    {
//        float distance = length(vec3(GL_SpotLight[i].position) - pos);
//        lightDir = normalize(vec3(GL_SpotLight[i].position) - pos);
//        phase = dualLobPhase(0.5, -0.5, 0.3, dot(lightDir, viewDir));
//        transmittance = getTransmittanceLight(pos, lightDir, vec3(GL_SpotLight[i].position), false);
//        float spotEffect = dot(-vec3(GL_SpotLight[i].direction), lightDir);
//        if(spotEffect > cos(GL_SpotLight[i].cutOff))
//        {
//            spotEffect = 1.0;
//        }
//        else if(spotEffect <= cos(GL_SpotLight[i].cutOff) && spotEffect > cos(GL_SpotLight[i].outerCutOff))
//        {
//            spotEffect = (spotEffect - cos(GL_SpotLight[i].outerCutOff)) / (cos(GL_SpotLight[i].cutOff) - cos(GL_SpotLight[i].outerCutOff));
//        }
//        else
//        {
//            spotEffect = 0;
//        }
//        intensity = spotEffect * GL_SpotLight[i].intensity / (distance * distance);
//        result += phase * transmittance * intensity * vec3(GL_SpotLight[i].color);
//    }    
    return result;
}



