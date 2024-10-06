#ifndef __GRAPHICS_H__
#define __GRAPHICS_H__

#include <GLFW/glfw3.h>

#define TARGET_FPS 60

typedef struct {
    float x;
    float y;
    float z;
} vec3_t;

typedef struct {
    vec3_t scale;
    vec3_t position;
} scale_pos_t;

int simpleShader(GLFWwindow* window, int width, int height);
int textureShader(GLFWwindow* window, int width, int height);
int cubeShader(GLFWwindow* window, int width, int height);
int shadertoy(GLFWwindow* window, int width, int height);

void processInput(GLFWwindow* window, scale_pos_t *scale_pos);

#endif
