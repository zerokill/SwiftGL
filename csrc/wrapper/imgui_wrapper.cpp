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

void ImGuiWrapper_Render(stats_t stats) {
    // Start the Dear ImGui frame
    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
    ImGui::NewFrame();

    ImGuiIO& io = ImGui::GetIO();
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav;
    ImGui::SetNextWindowBgAlpha(0.35f); // Transparent background
    if (ImGui::Begin("Example: Simple overlay", NULL, window_flags))
    {
        ImGui::Text("Simple overlay\n");
        ImGui::Separator();
        ImGui::Text("Num Livia: %0d", stats.numLivia);
        ImGui::Text("fps: %.1f", stats.fps);
        ImGui::Text("updateTime: %f", stats.updateTime);
        ImGui::Text("renderTime: %f", stats.renderTime);
        if (ImGui::IsMousePosValid())
            ImGui::Text("Mouse Position: (%.1f,%.1f)", io.MousePos.x, io.MousePos.y);
        else
            ImGui::Text("Mouse Position: <invalid>");
    }
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

