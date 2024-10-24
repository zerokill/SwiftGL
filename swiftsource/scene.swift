class Scene {
    var models: [Model] = []

    func update(deltaTime: Float, input: InputManager, camera: Camera) {
        if (input.liviaMove && !input.liviaMoved) {
            models[0].shootInstance(position: camera.position, direction: camera.front, enableExplode: true)
        }
        if (input.liviaResetMove) {
            models[0].resetAllInstances()
        }

        for model in models {
            model.updateMove(deltaTime: deltaTime, updateVelocity: input.updateVelocity, updateRotation: input.updateRotation)
        }
    }
}
