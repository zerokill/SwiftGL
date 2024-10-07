#ifndef __TEXTURE_H__
#define __TEXTURE_H__

#include <OpenGL/gl3.h>
#include <GLFW/glfw3.h>

#include "stb_image.h"

typedef struct
{
    GLuint ID;
    GLenum type;

} texture_t;


texture_t texture(const char* image, GLenum texType, GLenum slot, GLenum format, GLenum pixelType);
void texUnit(texture_t texture, unsigned int shader, const char* uniform, GLuint unit);

#endif
