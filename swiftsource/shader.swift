import OpenGL.GL3
import Foundation
import simd

import ShaderModule

class Shader {
    let programID: GLuint

    init(vertexPath: String, fragmentPath: String) {
        print("createShader: ", vertexPath, fragmentPath)
        programID = createShader(vertexPath, fragmentPath)
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

    func setUniform(_ name: String, value: GLuint) {
        let location = glGetUniformLocation(programID, name)
        glUniform1ui(location, value)
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

