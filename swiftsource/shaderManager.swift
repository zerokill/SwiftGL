import OpenGL.GL3
import simd

class ShaderManager {
    private var shaders: [String: Shader] = [:]
    private var currentShader: Shader?

    func loadShader(name: String, vertexPath: String, fragmentPath: String) {
        let shader = Shader(vertexPath: vertexPath, fragmentPath: fragmentPath)
        shaders[name] = shader
    }

    func use(shaderName: String) {
        guard let shader = shaders[shaderName] else {
            print("Shader '\(shaderName)' not found.")
            return
        }
        shader.use()
        currentShader = shader
    }

    func setUniform(_ name: String, value: Float) {
        currentShader?.setUniform(name, value: value)
    }

    func setUniform(_ name: String, value: GLuint) {
        currentShader?.setUniform(name, value: value)
    }

    func setUniform(_ name: String, value: float4x4) {
        currentShader?.setUniform(name, value: value)
    }

    // Add more setUniform methods as needed
}

