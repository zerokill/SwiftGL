import os
import OpenGL.GL3
import simd

import TextureModule

class LeonModel: BaseModel {
    var terrainMesh: TerrainMesh

    var instances: [InstanceData] = []
    var activeInstances: Int = 0

    let dampingFactor: Float = 0.8

    init(mesh: Mesh, shaderName: String, texture: texture_t?, terrainMesh: TerrainMesh) {
        self.terrainMesh = terrainMesh
        super.init(mesh: mesh, shaderName: shaderName, texture: texture)
    }

    func setupInstances(randomPosition: Bool = false) {
        let count = mesh.maxInstanceCount

        instances.reserveCapacity(count)
        for _ in 0..<count {
            instances.append(resetMove())
        }
        mesh.updateInstanceData(instances)
    }

    func shootInstance(position: SIMD3<Float>, direction: SIMD3<Float>, enableExplode: Bool) {
//        Logger.debug("shootInstance", position, direction)
        instances[activeInstances].enable = true
        instances[activeInstances].enableExplode = enableExplode
        instances[activeInstances].modelMatrix = float4x4.translation(position)
        instances[activeInstances].velocity = direction * 0.10

        instances[activeInstances].positionMatrix = float4x4.translation(position)

        // Random initial rotation
        let rotationXMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(0, 1, 0))
        let rotationYMatrix = float4x4(rotationAngle: radians(fromDegrees: Float.random(in: 1..<360)), axis: SIMD3<Float>(1, 0, 0))
        instances[activeInstances].rotationMatrix = rotationXMatrix * rotationYMatrix
        instances[activeInstances].timeAlive = 0
        activeInstances += 1
    }

    func getGroundHeight(atX x: Double, z: Double, terrainScale: Double, terrainVerticalScale: Double) -> (height: Float, normal: SIMD3<Float>) {
        let xPos = x / terrainScale
        let zPos = z / terrainScale

        let x0 = Int(floor(xPos)) + 500
        let x1 = x0 + 1
        let z0 = Int(floor(zPos)) + 500
        let z1 = z0 + 1

        guard z0 > 0, x0 > 0, z0 * 1000 + x0 < terrainMesh.vertices.count else {
            return (0.0, SIMD3<Float>(0, 1, 0)) // Default normal pointing up
        }

        return (terrainMesh.vertices[z0 * 1000 + x0].position.y, terrainMesh.vertices[z0 * 1000 + x0].normal)

//        let h00 = terrainMesh[z0][x0]
//        let h10 = terrainMesh[z0][x1]
//        let h01 = terrainMesh[z1][x0]
//        let h11 = terrainMesh[z1][x1]
//
//        let dx = xPos - Double(x0)
//        let dz = zPos - Double(z0)
//
//        let h0 = lerp(a: h00, b: h10, t: dx)
//        let h1 = lerp(a: h01, b: h11, t: dx)
//        let height = lerp(a: h0, b: h1, t: dz)
//
//        //Logger.info("height: ", Float(height * terrainVerticalScale))
//        return Float(height * terrainVerticalScale)
    }


    override func updateMove(deltaTime: Float) {
        for i in instances.indices {
            let position = SIMD3<Float>(
                instances[i].modelMatrix.columns.3.x,
                instances[i].modelMatrix.columns.3.y,
                instances[i].modelMatrix.columns.3.z
            )

            let heightNormal = getGroundHeight(atX: Double(position.x), z: Double(position.z), terrainScale: 0.1, terrainVerticalScale: 1.0)

            if instances[i].timeAlive >= 0 {
                instances[i].timeAlive += deltaTime
            }

            // Update translation based on velocity and delta time

            if let leonMesh = mesh as? LeonMesh {
//                if (instances[i].velocity.y < 0 ) {
                    // TODO: collision detection now only works if the ball is dropping
                    if ((position.y < heightNormal.height + leonMesh.sphereParameters.radius)) {
                        instances[i].velocity = reflect(instances[i].velocity, over: heightNormal.normal) * dampingFactor
                        instances[i].positionMatrix.columns.3.y = heightNormal.height + leonMesh.sphereParameters.radius;
                    } else if (position.y < leonMesh.sphereParameters.radius) {
                        instances[i].velocity.y = -instances[i].velocity.y;
                        instances[i].velocity *= dampingFactor
                        instances[i].positionMatrix.columns.3.y = leonMesh.sphereParameters.radius;
                    }
//                }

                // Naive gravity
                instances[i].velocity.y -= 0.001;
            }
            let translation = instances[i].velocity
            instances[i].positionMatrix = instances[i].positionMatrix * float4x4.translation(translation)
            if let leonMesh = mesh as? LeonMesh {
                if (abs(instances[i].velocity.y) < 0.001) {
                    if (instances[i].positionMatrix.columns.3.y < heightNormal.height + leonMesh.sphereParameters.radius) {
                        instances[i].positionMatrix.columns.3.y = heightNormal.height + leonMesh.sphereParameters.radius;
                    } else if (instances[i].positionMatrix.columns.3.y < leonMesh.sphereParameters.radius) {
                        instances[i].positionMatrix.columns.3.y = leonMesh.sphereParameters.radius;
                    }
                }
            }
            instances[i].modelMatrix = instances[i].positionMatrix * instances[i].rotationMatrix

            if (instances[i].timeAlive > 8 && instances[i].enable) {
                instances[i].enable = false
                if (instances[i].enableExplode) {
                    for _ in 1...100 {
                        let direction = SIMD3<Float>(x: Float.random(in: -5..<5), y: Float.random(in: -5..<5), z: Float.random(in: -5..<5))
                        shootInstance(position: position, direction: direction, enableExplode: false)
                    }
                }

                activeInstances -= 1
                instances.swapAt(i, activeInstances)    // Efficient removal. Swap is simpler then delete (O(n))
            }
        }
        mesh.updateInstanceData(instances)
    }

    func resetAllInstances() {
        for i in instances.indices {
            instances[i] = resetMove()
        }
    }

    func resetMove() -> InstanceData {
        return InstanceData(
            modelMatrix: matrix_identity_float4x4,
            enable: false,
            enableExplode: false,
            velocity: SIMD3<Float>(),
            positionMatrix: matrix_identity_float4x4,
            rotationMatrix: matrix_identity_float4x4,
            timeAlive: 0)
    }

    override func draw() {
        if let texture = self.texture {
            glBindTexture(texture.type, texture.ID)
        }
        mesh.drawInstances(count: activeInstances)
    }
}


