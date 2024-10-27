import TextureModule

class Scene {
    var models: [Model] = []

    var light: Model? = nil

    func update(deltaTime: Float, input: InputManager, camera: Camera) {
        if (input.liviaMove && !input.liviaMoved) {
            models[0].shootInstance(position: camera.position, direction: camera.front, enableExplode: true)
        }
        if (input.liviaResetMove) {
            models[0].resetAllInstances()
        }

        if (input.addLight && !input.addedLight) {
            let lightTexture = texture("resources/leon.png", GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE0), GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE))  // FIXME: Textures should be loaded and stored ahead of time
            let lightSpereParameters = SphereParameters(radius: 0.2, latitudeBands: 20, longitudeBands: 20)
            let lightSphere = LeonMesh(sphere: lightSpereParameters)
            let lightModel = Model(mesh: lightSphere, shaderName: "lightShader", texture: lightTexture) // FIXME: Ideally a texture is not needed for this one
            lightModel.setupInstances()
            lightModel.addInstance(position: camera.position)
            light = lightModel
        }

        if (input.addObject && !input.addedObject) {
            let objectTexture = texture("resources/leon.png", GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE0), GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE))  // FIXME: Textures should be loaded and stored ahead of time
            let objectSpereParameters = SphereParameters(radius: 0.2, latitudeBands: 20, longitudeBands: 20)
            let objectSphere = LeonMesh(sphere: objectSpereParameters)
            let objectModel = Model(mesh: objectSphere, shaderName: "objectShader", texture: objectTexture) // FIXME: Ideally a texture is not needed for this one
            objectModel.setupInstances()
            objectModel.addInstance(position: camera.position)
            models.append(objectModel)
        }

        for model in models {
            model.updateMove(deltaTime: deltaTime, updateVelocity: input.updateVelocity, updateRotation: input.updateRotation)
        }

        light?.updateMove(deltaTime: deltaTime, updateVelocity: input.updateVelocity, updateRotation: input.updateRotation)
    }
}
