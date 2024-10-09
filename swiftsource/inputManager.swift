import CGLFW3

class InputManager {

    var scalePos: scale_pos_t

    init() {
        // Initialize scale and position
        let VEC_INIT = vec3_t(x: 1.0, y: 1.0, z: 1.0)
        let VEC_CLEAR = vec3_t(x: 0.0, y: 0.0, z: 0.0)
        self.scalePos = scale_pos_t(scale: VEC_INIT, position: VEC_CLEAR)
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
        if (glfwGetKey(window, Int32(GLFW_KEY_5)) == GLFW_PRESS) {
            scalePos.scale.x = 0.3
            scalePos.scale.y = 0.3
            scalePos.scale.z = 0
        }
        scalePos.position.y = 0
        scalePos.position.x = 0
        if (glfwGetKey(window, Int32(GLFW_KEY_UP)) == GLFW_PRESS) {
            scalePos.position.y += 0.01
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_DOWN)) == GLFW_PRESS) {
            scalePos.position.y -= 0.01
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_LEFT)) == GLFW_PRESS) {
            scalePos.position.x -= 0.01
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_RIGHT)) == GLFW_PRESS) {
            scalePos.position.x += 0.01
        }
    }
    // GLFW callback functions can be set up here
}

