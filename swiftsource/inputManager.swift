import CGLFW3

class InputManager {

    var scalePos: scale_pos_t
    var liviaAdd: Bool
    var liviaDelete: Bool

    var deltaPosition: SIMD3<Float>
    var deltaYaw: Float
    var deltaPitch: Float

    init() {
        // Initialize scale and position
        let VEC_INIT = vec3_t(x: 1.0, y: 1.0, z: 1.0)
        let VEC_CLEAR = vec3_t(x: 0.0, y: 0.0, z: 0.0)
        self.liviaAdd = false
        self.liviaDelete = false
        self.scalePos = scale_pos_t(scale: VEC_INIT, position: VEC_CLEAR)
        self.deltaPosition = SIMD3(0.0, 0.0, 0.0)
        self.deltaYaw = 0.0
        self.deltaPitch = 0.0
    }

    func processInput(window: OpaquePointer!) {
        if (glfwGetKey(window, Int32(GLFW_KEY_ESCAPE)) == GLFW_PRESS) {
            glfwSetWindowShouldClose(window, GLFW_TRUE)
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_1)) == GLFW_PRESS) {
            glPolygonMode(GLenum(GL_FRONT_AND_BACK), GLenum(GL_LINE))
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_2)) == GLFW_PRESS) {
            glPolygonMode(GLenum(GL_FRONT_AND_BACK), GLenum(GL_FILL))
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_3)) == GLFW_PRESS) {
            scalePos.scale.x += 0.01
            scalePos.scale.y += 0.01
            scalePos.scale.z = 0
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_4)) == GLFW_PRESS) {
            scalePos.scale.x -= 0.01
            scalePos.scale.y -= 0.01
            scalePos.scale.z = 0
        }
        liviaAdd = false
        if (glfwGetKey(window, Int32(GLFW_KEY_5)) == GLFW_PRESS) {
            liviaAdd = true
        }
        liviaDelete = false
        if (glfwGetKey(window, Int32(GLFW_KEY_6)) == GLFW_PRESS) {
            liviaDelete = true
        }
//        scalePos.position.y = 0
//        scalePos.position.x = 0
//        if (glfwGetKey(window, Int32(GLFW_KEY_UP)) == GLFW_PRESS) {
//            scalePos.position.y += 0.01
//        }
//        if (glfwGetKey(window, Int32(GLFW_KEY_DOWN)) == GLFW_PRESS) {
//            scalePos.position.y -= 0.01
//        }
//        if (glfwGetKey(window, Int32(GLFW_KEY_LEFT)) == GLFW_PRESS) {
//            scalePos.position.x -= 0.01
//        }
//        if (glfwGetKey(window, Int32(GLFW_KEY_RIGHT)) == GLFW_PRESS) {
//            scalePos.position.x += 0.01
//        }
//        if (glfwGetKey(window, Int32(GLFW_KEY_RIGHT)) == GLFW_PRESS) {
//            scalePos.position.x += 0.01
//        }

        self.deltaPosition = SIMD3(0.0, 0.0, 0.0)
        if (glfwGetKey(window, Int32(GLFW_KEY_W)) == GLFW_PRESS) {
            deltaPosition.z -= 0.05
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_S)) == GLFW_PRESS) {
            deltaPosition.z += 0.05
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_A)) == GLFW_PRESS) {
            deltaPosition.x -= 0.05
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_D)) == GLFW_PRESS) {
            deltaPosition.x += 0.05
        }

        if (glfwGetKey(window, Int32(GLFW_KEY_UP)) == GLFW_PRESS) {
            deltaPitch += 0.01
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_DOWN)) == GLFW_PRESS) {
            deltaPitch -= 0.01
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_LEFT)) == GLFW_PRESS) {
            deltaYaw -= 0.01
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_RIGHT)) == GLFW_PRESS) {
            deltaYaw += 0.01
        }
    }
    // GLFW callback functions can be set up here
}

