import TextureModule

class Scene {
    var models: [BaseModel] = []

    var light: LightModel? = nil

    var grid: Mesh? = nil

    init() {
        Logger.info("scene init");

        if let model = ResourceManager.shared.getModel(name: "liviaModel") {
            Logger.info("liviaModel loaded");
            models.append(model);
        }
        if let model = ResourceManager.shared.getModel(name: "leonModel") {
            Logger.info("leonModel loaded");
            models.append(model);
        }
    }

    func update(deltaTime: Float, input: InputManager, camera: Camera) {
        for model in models {
            if let leonModel = model as? LeonModel {
                if (input.liviaMove && !input.liviaMoved) {
                    leonModel.shootInstance(position: camera.position, direction: camera.front, enableExplode: true)
                }
            }
            if let liviaModel = model as? LiviaModel {
                if (input.liviaResetMove) {
                    liviaModel.resetAllInstances()
                }
            }

            model.updateMove(deltaTime: deltaTime)
        }

        if (input.addLight && !input.addedLight) {
            if let lightTexture = ResourceManager.shared.getTexture(name: "leonTexture") {
                let lightSpereParameters = SphereParameters(radius: 0.2, latitudeBands: 20, longitudeBands: 20)
                let lightSphere = LeonMesh(sphere: lightSpereParameters)
                let lightModel = LightModel(mesh: lightSphere, shaderName: "lightShader", texture: lightTexture) // FIXME: Ideally a texture is not needed for this one
                lightModel.mesh.maxInstanceCount = 1;
                lightModel.setupInstances()
                lightModel.addInstance(position: camera.position)
                light = lightModel
            }
        }

        if (input.addObject && !input.addedObject) {
            if let objectTexture = ResourceManager.shared.getTexture(name: "leonTexture") {
                let objectSpereParameters = SphereParameters(radius: 0.2, latitudeBands: 20, longitudeBands: 20)
                let objectSphere = LeonMesh(sphere: objectSpereParameters)
                let objectModel = LightModel(mesh: objectSphere, shaderName: "objectShader", texture: objectTexture) // FIXME: Ideally a texture is not needed for this one
                objectModel.mesh.maxInstanceCount = 1;
                objectModel.setupInstances()
                objectModel.addInstance(position: camera.position)
                models.append(objectModel)
            }
        }

        light?.updateMove(deltaTime: deltaTime)
    }
}
