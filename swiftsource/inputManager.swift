import CGLFW3

class InputManager {

    var liviaMove: Bool
    var liviaMoved: Bool
    var liviaResetMove: Bool

    var addObject: Bool = false
    var addedObject: Bool = false

    var addLight: Bool = false
    var addedLight: Bool = false

    var toggleNormal: Bool = false

    var updateVelocity: Bool = true
    var updateRotation: Bool = true

    var deltaPosition: SIMD3<Float>
    var deltaYaw: Float
    var deltaPitch: Float

    init() {
        self.liviaMove = false
        self.liviaMoved = false
        self.liviaResetMove = false
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
            updateVelocity = true
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_4)) == GLFW_PRESS) {
            updateVelocity = false
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_5)) == GLFW_PRESS) {
            updateRotation = true
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_6)) == GLFW_PRESS) {
            updateRotation = false
        }

        addedObject = addObject
        addObject = (glfwGetKey(window, Int32(GLFW_KEY_7)) == GLFW_PRESS)

        addedLight = addLight
        addLight = (glfwGetKey(window, Int32(GLFW_KEY_8)) == GLFW_PRESS)

        toggleNormal = (glfwGetKey(window, Int32(GLFW_KEY_9)) == GLFW_PRESS)

        liviaMoved = liviaMove
        liviaMove = (glfwGetKey(window, Int32(GLFW_KEY_SPACE)) == GLFW_PRESS)

        liviaResetMove = false
        if (glfwGetKey(window, Int32(GLFW_KEY_SPACE)) == GLFW_PRESS && glfwGetKey(window, Int32(GLFW_KEY_LEFT_SHIFT)) == GLFW_PRESS) {
            liviaResetMove = true
        }
        self.deltaPosition = SIMD3(0.0, 0.0, 0.0)
        if (glfwGetKey(window, Int32(GLFW_KEY_W)) == GLFW_PRESS) {
            deltaPosition.z += 0.05
        }
        if (glfwGetKey(window, Int32(GLFW_KEY_S)) == GLFW_PRESS) {
            deltaPosition.z -= 0.05
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

