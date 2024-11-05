import TextureModule

class Scene {
    var models: [BaseModel] = []

    var light: LightModel? = nil

    var grid: Mesh? = nil
    var skybox: SkyboxModel? = nil
    var terrain: TerrainModel? = nil

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
        if (input.addLight && !input.addedLight) {
            if let lightSphere = ResourceManager.shared.getModel(name: "leonModel")?.mesh {
                let lightModel = LightModel(mesh: lightSphere, shaderName: "lightShader", texture: nil, position: camera.position)
                light = lightModel
            }
        }

        if (input.addObject && !input.addedObject) {
            if let objectSphere = ResourceManager.shared.getModel(name: "leonModel")?.mesh {
                let objectModel = LightModel(mesh: objectSphere, shaderName: "objectShader", texture: nil, position: camera.position)
                models.append(objectModel)
            }
        }

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

        light?.updateMove(deltaTime: deltaTime)
    }
}
