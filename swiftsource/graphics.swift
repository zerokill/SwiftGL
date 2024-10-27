import Foundation
import OpenGL.GL3
import CGLFW3
import ShaderModule
import GraphicsModule
import Darwin.C

func getPrimaryMonitor() -> OpaquePointer? {
    return glfwGetPrimaryMonitor()
}

func getVideoMode(for monitor: OpaquePointer?) -> UnsafePointer<GLFWvidmode>? {
    return glfwGetVideoMode(monitor)
}

func initializeWindow(options: Options) -> OpaquePointer? {
    // Initialize GLFW
    if glfwInit() == GLFW_FALSE {
        Logger.error("Failed to initialize GLFW")
        return nil
    }

    // Set window hints (optional, based on your OpenGL requirements)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
    // glfwWindowHint(GLFW_DECORATED, GLFW_FALSE) // Optional: Remove window decorations for borderless windowed mode

    // Select the primary monitor
    guard let primaryMonitor = getPrimaryMonitor() else {
        Logger.error("Failed to get primary monitor")
        glfwTerminate()
        return nil
    }

    // Retrieve the video mode of the primary monitor
    guard let videoMode = getVideoMode(for: primaryMonitor) else {
        Logger.error("Failed to get video mode for primary monitor")
        glfwTerminate()
        return nil
    }

    var window: OpaquePointer? = nil

    // Extract width, height, and refresh rate from the video mode
    if options.fullscreen {
        let width = Int(videoMode.pointee.width)
        let height = Int(videoMode.pointee.height)
        let refreshRate = Int(videoMode.pointee.refreshRate)

        Logger.info("Primary Monitor Resolution: \(width)x\(height) @ \(refreshRate)Hz")

        // Create a full-screen window
        window = glfwCreateWindow(Int32(width), Int32(height), "OpenGL Full-Screen Window", primaryMonitor, nil)
    } else {
        let width = options.width
        let height = options.height
        let refreshRate = Int(videoMode.pointee.refreshRate)

        Logger.info("Window Resolution: \(width)x\(height) @ \(refreshRate)Hz")

        // Create a full-screen window
        window = glfwCreateWindow(Int32(width), Int32(height), "OpenGL Window", nil, nil)
    }

    if window == nil {
        Logger.error("Failed to create GLFW full-screen window")
        glfwTerminate()
        return nil
    }

    // Make the OpenGL context current
    glfwMakeContextCurrent(window)
    glfwSwapInterval(1) // 1 to enable V-Sync, 0 to disable

    return window
}

func runGraphics(options: Options) {
    guard let window = initializeWindow(options: options) else {
        Logger.error("Failed to create GLFW window")
        glfwTerminate()
        exit(1)
    }

    switch options.program {
        case 1:
            liviaRender(window: window, width: options.width, height: options.height)
        case 2:
            shadertoySwift(window: window, width: options.width, height: options.height)
        case 3:
            infiniteGrid(window: window, width: options.width, height: options.height)
        default:
            Logger.error("Unknown program")
    }

    // Terminate GLFW
    glfwDestroyWindow(window)
    glfwTerminate()
}
