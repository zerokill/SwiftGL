// wrapper/imgui_wrapper.h

#ifndef IMGUI_WRAPPER_H
#define IMGUI_WRAPPER_H

#include <stdbool.h>

// Forward declaration of GLFWwindow from GLFW
typedef struct GLFWwindow GLFWwindow;

extern "C" {

// FIXME: Horrible horrible hack
#include "cimgui_wrapper.h"

}

#endif // IMGUI_WRAPPER_H

