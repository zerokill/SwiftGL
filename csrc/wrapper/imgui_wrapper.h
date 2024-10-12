// wrapper/imgui_wrapper.h

#ifndef IMGUI_WRAPPER_H
#define IMGUI_WRAPPER_H

#include <stdbool.h>

// Forward declaration of GLFWwindow from GLFW
typedef struct GLFWwindow GLFWwindow;

extern "C" {
// Initialize ImGui with OpenGL3 and GLFW
bool ImGuiWrapper_Init(GLFWwindow* window);

// Render ImGui frame
void ImGuiWrapper_Render(int numLivia);

// Shutdown ImGui
void ImGuiWrapper_Shutdown();

// GLFW Window Management
GLFWwindow* ImGuiWrapper_CreateWindow(int width, int height, const char* title);
void ImGuiWrapper_DestroyWindow(GLFWwindow* window);
bool ImGuiWrapper_ShouldClose(GLFWwindow* window);
void ImGuiWrapper_PollEvents();
void ImGuiWrapper_SwapBuffers(GLFWwindow* window);

// Additional wrapper functions as needed...
}

#endif // IMGUI_WRAPPER_H

