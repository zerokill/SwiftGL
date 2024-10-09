import OpenGL.GL3
import Foundation
import simd

import ShaderModule

class Shader {
    let programID: GLuint

    init(vertexPath: String, fragmentPath: String) {
        programID = createShader("resources/shader/baseCube.vert", "resources/shader/baseCube.frag")
//        // 1. Retrieve the vertex/fragment source code from file paths
//        let vertexCode: String
//        let fragmentCode: String
//
//        do {
//            vertexCode = try String(contentsOfFile: vertexPath, encoding: .utf8)
//            fragmentCode = try String(contentsOfFile: fragmentPath, encoding: .utf8)
//        } catch {
//            fatalError("Failed to read shader files: \(error)")
//        }
//
//        // 2. Compile shaders
//        let vertexShader = Shader.compileShader(source: vertexCode, type: GLenum(GL_VERTEX_SHADER))
//        let fragmentShader = Shader.compileShader(source: fragmentCode, type: GLenum(GL_FRAGMENT_SHADER))
//
//        // 3. Link shaders into a program
//        programID = glCreateProgram()
//        glAttachShader(programID, vertexShader)
//        glAttachShader(programID, fragmentShader)
//        glLinkProgram(programID)
//
//        // Check for linking errors
//        var success: GLint = 0
//        glGetProgramiv(programID, GLenum(GL_LINK_STATUS), &success)
//        if success == GL_FALSE {
//            var infoLog = [GLchar](repeating: 0, count: 512)
//            glGetProgramInfoLog(programID, GLsizei(infoLog.count), nil, &infoLog)
//            let message = String(cString: infoLog)
//            fatalError("ERROR::SHADER::PROGRAM::LINKING_FAILED\n\(message)")
//        }
//
//        // 4. Delete the shaders as they're linked into our program now and no longer necessary
//        glDeleteShader(vertexShader)
//        glDeleteShader(fragmentShader)
    }

    deinit {
        glDeleteProgram(programID)
    }

    func use() {
        glUseProgram(programID)
    }

    // Utility functions for setting shader uniforms

    func setUniform(_ name: String, value: Bool) {
        let location = glGetUniformLocation(programID, name)
        glUniform1i(location, value ? 1 : 0)
    }

    func setUniform(_ name: String, value: Int32) {
        let location = glGetUniformLocation(programID, name)
        glUniform1i(location, value)
    }

    func setUniform(_ name: String, value: Float) {
        let location = glGetUniformLocation(programID, name)
        glUniform1f(location, value)
    }

    func setUniform(_ name: String, value: SIMD3<Float>) {
        let location = glGetUniformLocation(programID, name)
        glUniform3f(location, value.x, value.y, value.z)
    }

    func setUniform(_ name: String, value: SIMD4<Float>) {
        let location = glGetUniformLocation(programID, name)
        glUniform4f(location, value.x, value.y, value.z, value.w)
    }

    func setUniform(_ name: String, value: float4x4) {
        let location = glGetUniformLocation(programID, name)
        withUnsafePointer(to: value) {
            $0.withMemoryRebound(to: Float.self, capacity: 16) { ptr in
                glUniformMatrix4fv(location, 1, GLboolean(GL_FALSE), ptr)
            }
        }
    }

    // Helper function to compile a shader from source code
    private static func compileShader(source: String, type: GLenum) -> GLuint {
        let shader = glCreateShader(type)
        var sourceCString = (source as NSString).utf8String
        var sourceLength = GLint(source.count)
        glShaderSource(shader, 1, &sourceCString, &sourceLength)
        glCompileShader(shader)

        // Check for compilation errors
        var success: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &success)
        if success == GL_FALSE {
            var infoLog = [GLchar](repeating: 0, count: 512)
            glGetShaderInfoLog(shader, GLsizei(infoLog.count), nil, &infoLog)
            let message = String(cString: infoLog)
            let shaderType = (type == GLenum(GL_VERTEX_SHADER)) ? "VERTEX" : "FRAGMENT"
            fatalError("ERROR::SHADER::\(shaderType)::COMPILATION_FAILED\n\(message)")
        }

        return shader
    }
}

