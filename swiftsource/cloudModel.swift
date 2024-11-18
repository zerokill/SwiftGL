import Foundation
import OpenGL.GL3
import simd

import TextureModule

class CloudModel: BaseModel {
    var modelMatrix: float4x4 = matrix_identity_float4x4
    var noiseTexture: texture_t

    init(mesh: Mesh, shaderName: String) {
        let scale = SIMD3<Float>(1.0, 1.0, 1.0)
        modelMatrix = float4x4.translation(SIMD3<Float>(0.0, 10.0, 0.0)) * float4x4.scale(scale)
//        self.noiseTexture = CloudModel.generate3DNoiseTexture(size: 128)
        self.noiseTexture = CloudModel.loadBinaryCube(from: "resources/Engine256.raw")
        super.init(mesh: mesh, shaderName: shaderName, texture: nil)
    }

    // Function to read binary file into a 3D array
    private static func loadBinaryCube(from filePath: String) -> texture_t {
        let size = 256
        let expectedSize = size * size * size // Total number of bytes

        // Open the file
        guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            fatalError("Failed to load texture image")
        }

        // Verify the size of the file
        guard fileData.count == expectedSize else {
            fatalError("Failed to load texture image")
        }

        var noiseData = [UInt8](fileData)

        var texture = texture_t()
        texture.type = GLenum(GL_TEXTURE_3D)
        glGenTextures(1, &texture.ID)
        glBindTexture(texture.type, texture.ID)
        glTexImage3D(texture.type, 0, GL_R8, GLsizei(size), GLsizei(size), GLsizei(size), 0, GLenum(GL_RED), GLenum(GL_UNSIGNED_BYTE), &noiseData)

        glTexParameteri(GLenum(GL_TEXTURE_3D), GLenum(GL_TEXTURE_WRAP_S), GLint(GL_CLAMP))
        glTexParameteri(GLenum(GL_TEXTURE_3D), GLenum(GL_TEXTURE_WRAP_T), GLint(GL_CLAMP))
        glTexParameteri(GLenum(GL_TEXTURE_3D), GLenum(GL_TEXTURE_WRAP_R), GLint(GL_CLAMP))

        glTexParameteri(GLenum(GL_TEXTURE_3D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR);
        glTexParameteri(GLenum(GL_TEXTURE_3D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR);

        return texture
    }

    private static func generate3DNoiseTexture(size: Int) -> texture_t {
        var noiseData = [Float](repeating: 0.0, count: size * size * size)
        for z in 0..<size {
            for y in 0..<size {
                for x in 0..<size {
                    var noiseValue = Float(0.0)
                    if x > 0 && x < 5 {
                        if y > 0 && y < 5 {
                            if z > 0 && z < 5 {
                                noiseValue = Float(1.0)
                            }
                        }
                    }
//                    let noiseValue = Float.random(in: 0.0...0.8)

                    let index = x + y * size + z * size * size
                    noiseData[index] = noiseValue
                }
            }
        }

        var texture = texture_t()
        texture.type = GLenum(GL_TEXTURE_3D)
        glGenTextures(1, &texture.ID)
        glBindTexture(texture.type, texture.ID)
        glTexImage3D(texture.type, 0, GL_RED, GLsizei(size), GLsizei(size), GLsizei(size), 0, GLenum(GL_RED), GLenum(GL_FLOAT), &noiseData)

        glTexParameteri(GLenum(GL_TEXTURE_3D), GLenum(GL_TEXTURE_WRAP_S), GLint(GL_CLAMP_TO_EDGE))
        glTexParameteri(GLenum(GL_TEXTURE_3D), GLenum(GL_TEXTURE_WRAP_T), GLint(GL_CLAMP_TO_EDGE))
        glTexParameteri(GLenum(GL_TEXTURE_3D), GLenum(GL_TEXTURE_WRAP_R), GLint(GL_CLAMP_TO_EDGE))
        glTexParameteri(GLenum(GL_TEXTURE_3D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_LINEAR))
        glTexParameteri(GLenum(GL_TEXTURE_3D), GLenum(GL_TEXTURE_MAG_FILTER), GLint(GL_LINEAR))


        return texture
    }

    override func draw() {
        glEnable(GLenum(GL_BLEND))

        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(self.noiseTexture.type, self.noiseTexture.ID)

        mesh.draw()

        glActiveTexture(GLenum(GL_TEXTURE0))
        glDisable(GLenum(GL_BLEND))
    }
}
