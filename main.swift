import OpenGL.GL3
import CGLFW3
import ShaderModule
import GraphicsModule
import Darwin.C


// Initialize GLFW
if glfwInit() == GLFW_FALSE {
    print("Failed to initialize GLFW")
    exit(1)
}

// Set window hints (optional)
glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3)
#if !os(macOS)
glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
#endif

// Create a windowed mode window and its OpenGL context
guard let window = glfwCreateWindow(800, 600, "Hello, OpenGL!", nil, nil) else {
    print("Failed to create GLFW window")
    glfwTerminate()
    exit(1)
}

// Make the window's context current
glfwMakeContextCurrent(window)

shadertoy(window, 800, 600)

// Terminate GLFW
glfwTerminate()

