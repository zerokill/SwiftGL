import TextureModule
import ImguiModule

class Scene {
    var models: [BaseModel] = []

    var light: LightModel? = nil

    var grid: Mesh? = nil
    var skybox: SkyboxModel? = nil

    var terrain: TerrainModel
    var water: WaterModel

    var octaves: Int = 4
    var previousConfig: config_t = config_t()

    init(terrain: TerrainModel, water: WaterModel) {
        Logger.info("scene init");

        self.terrain = terrain
        self.water = water

        if let model = ResourceManager.shared.getModel(name: "liviaModel") {
            Logger.info("liviaModel loaded");
            models.append(model);
        }
        if let model = ResourceManager.shared.getModel(name: "leonModel") {
            Logger.info("leonModel loaded");
            models.append(model);
        }
    }

    func update(deltaTime: Float, input: InputManager, camera: Camera, config: config_t) {
        if (config.scale != previousConfig.scale || config.octaves != previousConfig.octaves || config.persistence != previousConfig.persistence) {
            terrain.mesh = TerrainMesh(width: 1000, depth: 1000, scale: config.scale, octaves: Int(config.octaves), persistence: config.persistence, seed: 1)
            previousConfig = config
        }

        if (input.addLight && !input.addedLight) {
            if let lightSphere = ResourceManager.shared.getModel(name: "leonModel")?.mesh {
                let lightModel = LightModel(mesh: lightSphere, shaderName: "lightShader", texture: nil, position: camera.position, terrainMesh: terrain.mesh)
                light = lightModel
            }
        }

        if (input.addObject && !input.addedObject) {
            if let objectSphere = ResourceManager.shared.getModel(name: "leonModel")?.mesh {
                let objectModel = ObjectModel(mesh: objectSphere, shaderName: "objectShader", texture: nil, position: camera.position, terrainMesh: terrain.mesh)
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

        water.moveFactor += water.WAVE_SPEED * deltaTime;

    }
}
