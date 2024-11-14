// wrapper/imgui_wrapper.cpp

#include "imgui_wrapper.h"
#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"
#include <GLFW/glfw3.h> // Ensure GLFW is included

// Ensure C linkage for the wrapper functions
extern "C" {

bool ImGuiWrapper_Init(GLFWwindow* window) {
    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    // Setup Dear ImGui style
    ImGui::StyleColorsDark();

    // Initialize ImGui backends
    if (!ImGui_ImplGlfw_InitForOpenGL(window, true))
        return false;
    if (!ImGui_ImplOpenGL3_Init("#version 330")) // Adjust GLSL version as needed
        return false;

    return true;
}

void ImGuiWrapper_RenderStart() {
    // Start the Dear ImGui frame
    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
    ImGui::NewFrame();

    ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav;
    ImGui::SetNextWindowBgAlpha(0.35f); // Transparent background
    ImGui::Begin("Example: Simple overlay", NULL, window_flags);
}

config_t ImGuiWrapper_Config() {
    config_t config;
    config.updated = false;

    static float scale = 4.0;
    ImGui::SliderFloat("scale", &scale, 0.0f, 20.0f, "%.3f");
    static int octaves = 9;
    ImGui::SliderInt("octaves", &octaves, 1, 16);
    static float persistence = 0.5;
    ImGui::SliderFloat("persistence", &persistence, 0.0f, 1.0f, "%.3f");
    static float exponent = 2.5;
    ImGui::SliderFloat("exponent", &exponent, 1.0f, 5.0f, "%.3f");
    static float height = 2.0;
    ImGui::SliderFloat("height", &height, -10.0f, 10.0f, "%.3f");
    static int x_offset = 0;
    ImGui::SliderInt("x_offset", &x_offset, 0, 1000);
    static int y_offset = 0;
    ImGui::SliderInt("y_offset", &y_offset, 0, 1000);

    if (config.scale != scale) {
        config.scale = scale;
        config.updated = true;
    }
    if (config.octaves != octaves) {
        config.octaves = octaves;
        config.updated = true;
    }
    if (config.persistence != persistence) {
        config.persistence = persistence;
        config.updated = true;
    }
    if (config.exponent != exponent) {
        config.exponent = exponent;
        config.updated = true;
    }
    if (config.height != height) {
        config.height = height;
        config.updated = true;
    }
    if (config.x_offset != x_offset) {
        config.x_offset = x_offset;
        config.updated = true;
    }
    if (config.y_offset != y_offset) {
        config.y_offset = y_offset;
        config.updated = true;
    }
    return config;
}

void ImGuiWrapper_RenderEnd() {
    // Start the Dear ImGui frame
    ImGui::End();

    // Render ImGui
    ImGui::Render();
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}

void ImGuiWrapper_Shutdown() {
    // Cleanup ImGui backends
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
}

void ImGuiWrapper_Text(const char* text) {
    ImGui::Text(text);
}

GLFWwindow* ImGuiWrapper_CreateWindow(int width, int height, const char* title) {
    if (!glfwInit()) {
        return nullptr;
    }

    // Set OpenGL version (example: 3.3 Core)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // Required on macOS
#endif

    GLFWwindow* window = glfwCreateWindow(width, height, title, nullptr, nullptr);
    if (window == nullptr) {
        glfwTerminate();
        return nullptr;
    }

    glfwMakeContextCurrent(window);
    glfwSwapInterval(1); // Enable vsync

    return window;
}

void ImGuiWrapper_DestroyWindow(GLFWwindow* window) {
    if (window != nullptr) {
        glfwDestroyWindow(window);
    }
    glfwTerminate();
}

bool ImGuiWrapper_ShouldClose(GLFWwindow* window) {
    return glfwWindowShouldClose(window);
}

void ImGuiWrapper_PollEvents() {
    glfwPollEvents();
}

void ImGuiWrapper_SwapBuffers(GLFWwindow* window) {
    glfwSwapBuffers(window);
}

} // extern "C"

