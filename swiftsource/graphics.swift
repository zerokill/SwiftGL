import OpenGL.GL3
import CGLFW3
import ShaderModule
import GraphicsModule
import Darwin.C

func runGraphics() {
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
    guard let window = glfwCreateWindow(1600, 1200, "Hello, OpenGL!", nil, nil) else {
        print("Failed to create GLFW window")
        glfwTerminate()
        exit(1)
    }

    // Make the window's context current
    glfwMakeContextCurrent(window)

//    shadertoySwift(window: window, width: 800, height: 600)
//    cubeShader(window, 800, 600)
//    cubeShaderSwift(window: window, width: 801, height: 600)
//    cubeExample(window: window, width: 800, height: 600)
    liviaRender(window: window, width: 1600, height: 1200)

    // Terminate GLFW
    glfwTerminate()
}
