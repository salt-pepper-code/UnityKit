import Testing
import SceneKit
@testable import UnityKit

@Suite("GameObject Search")
struct GameObjectSearchTests {

    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    // MARK: - Layer Search Tests

    @Test("Search by layer finds objects on specific layer")
    func searchBySpecificLayer() throws {
        let scene = createTestScene()

        let defaultObj = GameObject(name: "DefaultObject")
        defaultObj.layer = .default
        scene.addGameObject(defaultObj)

        let playerObj = GameObject(name: "PlayerObject")
        playerObj.layer = .player
        scene.addGameObject(playerObj)

        let groundObj = GameObject(name: "GroundObject")
        groundObj.layer = .ground
        scene.addGameObject(groundObj)

        // Search for default layer only (filter out any default scene objects)
        let defaultResults = GameObject.findGameObjects(.layer(.default), in: scene)
            .filter { $0.name == "DefaultObject" }
        #expect(defaultResults.count == 1)
        #expect(defaultResults.first?.name == "DefaultObject")

        // Search for player layer only
        let playerResults = GameObject.findGameObjects(.layer(.player), in: scene)
            .filter { $0.name == "PlayerObject" }
        #expect(playerResults.count == 1)
        #expect(playerResults.first?.name == "PlayerObject")
    }

    @Test("Search with .all layer mask finds all objects")
    func searchAllLayers() {
        let scene = createTestScene()

        let obj1 = GameObject(name: "TestObject1")
        obj1.layer = .default
        scene.addGameObject(obj1)

        let obj2 = GameObject(name: "TestObject2")
        obj2.layer = .player
        scene.addGameObject(obj2)

        let obj3 = GameObject(name: "TestObject3")
        obj3.layer = .ground
        scene.addGameObject(obj3)

        let results = GameObject.findGameObjects(.layer(.all), in: scene)
            .filter { $0.name?.starts(with: "TestObject") ?? false }
        #expect(results.count == 3)
    }

    @Test("Search with combined layer mask finds matching objects")
    func searchCombinedLayers() {
        let scene = createTestScene()

        let defaultObj = GameObject(name: "DefaultObject")
        defaultObj.layer = .default
        scene.addGameObject(defaultObj)

        let playerObj = GameObject(name: "PlayerObject")
        playerObj.layer = .player
        scene.addGameObject(playerObj)

        let groundObj = GameObject(name: "GroundObject")
        groundObj.layer = .ground
        scene.addGameObject(groundObj)

        let environmentObj = GameObject(name: "EnvironmentObject")
        environmentObj.layer = .environment
        scene.addGameObject(environmentObj)

        // Search for default OR player layers
        let combined: GameObject.Layer = [.default, .player]
        let results = GameObject.findGameObjects(.layer(combined), in: scene)
            .filter { ["DefaultObject", "PlayerObject", "GroundObject", "EnvironmentObject"].contains($0.name ?? "") }

        #expect(results.count == 2)
        let names = results.compactMap { $0.name }
        #expect(names.contains("DefaultObject"))
        #expect(names.contains("PlayerObject"))
        #expect(!names.contains("GroundObject"))
        #expect(!names.contains("EnvironmentObject"))
    }

    // MARK: - Name Search Tests

    @Test("Search by exact name finds only matching object")
    func searchExactName() throws {
        let scene = createTestScene()

        let obj1 = GameObject(name: "Player")
        scene.addGameObject(obj1)

        let obj2 = GameObject(name: "PlayerClone")
        scene.addGameObject(obj2)

        let result = try #require(GameObject.find(.name(.exact("Player")), in: scene))
        #expect(result.name == "Player")

        let results = GameObject.findGameObjects(.name(.exact("Player")), in: scene)
        #expect(results.count == 1)
        #expect(results.first?.name == "Player")
    }

    @Test("Search by name contains finds all matches")
    func searchNameContains() {
        let scene = createTestScene()

        let obj1 = GameObject(name: "PlayerCharacter")
        scene.addGameObject(obj1)

        let obj2 = GameObject(name: "EnemyPlayer")
        scene.addGameObject(obj2)

        let obj3 = GameObject(name: "Enemy")
        scene.addGameObject(obj3)

        let results = GameObject.findGameObjects(.name(.contains("Player")), in: scene)
        #expect(results.count == 2)

        let names = results.compactMap { $0.name }
        #expect(names.contains("PlayerCharacter"))
        #expect(names.contains("EnemyPlayer"))
        #expect(!names.contains("Enemy"))
    }

    @Test("Search by name starts with finds matching objects")
    func searchNameStartsWith() {
        let scene = createTestScene()

        let obj1 = GameObject(name: "Player1")
        scene.addGameObject(obj1)

        let obj2 = GameObject(name: "Player2")
        scene.addGameObject(obj2)

        let obj3 = GameObject(name: "Enemy")
        scene.addGameObject(obj3)

        let results = GameObject.findGameObjects(.name(.startWith("Player")), in: scene)
        #expect(results.count == 2)

        let names = results.compactMap { $0.name }
        #expect(names.contains("Player1"))
        #expect(names.contains("Player2"))
        #expect(!names.contains("Enemy"))
    }

    @Test("Search by name .any finds all objects")
    func searchNameAny() {
        let scene = createTestScene()

        let obj1 = GameObject(name: "MyObject1")
        scene.addGameObject(obj1)

        let obj2 = GameObject(name: "MyObject2")
        scene.addGameObject(obj2)

        let results = GameObject.findGameObjects(.name(.any), in: scene)
            .filter { $0.name?.starts(with: "MyObject") ?? false }
        #expect(results.count == 2)
    }

    // MARK: - Tag Search Tests

    @Test("Search by tag finds matching objects")
    func searchByTag() {
        let scene = createTestScene()

        let obj1 = GameObject(name: "Object1")
        obj1.tag = .custom("Player")
        scene.addGameObject(obj1)

        let obj2 = GameObject(name: "Object2")
        obj2.tag = .custom("Enemy")
        scene.addGameObject(obj2)

        let obj3 = GameObject(name: "Object3")
        obj3.tag = .custom("Player")
        scene.addGameObject(obj3)

        let results = GameObject.findGameObjects(.tag(.custom("Player")), in: scene)
        #expect(results.count == 2)

        let names = results.compactMap { $0.name }
        #expect(names.contains("Object1"))
        #expect(names.contains("Object3"))
        #expect(!names.contains("Object2"))
    }

    // MARK: - Combined Search Tests

    @Test("Search by name and tag finds matching objects")
    func searchNameAndTag() throws {
        let scene = createTestScene()

        let obj1 = GameObject(name: "Player1")
        obj1.tag = .custom("Player")
        scene.addGameObject(obj1)

        let obj2 = GameObject(name: "Player2")
        obj2.tag = .custom("Enemy")
        scene.addGameObject(obj2)

        let obj3 = GameObject(name: "Enemy1")
        obj3.tag = .custom("Player")
        scene.addGameObject(obj3)

        let result = try #require(GameObject.find(.nameAndTag(.startWith("Player"), .custom("Player")), in: scene))
        #expect(result.name == "Player1")

        let results = GameObject.findGameObjects(.nameAndTag(.startWith("Player"), .custom("Player")), in: scene)
        #expect(results.count == 1)
        #expect(results.first?.name == "Player1")
    }

    // MARK: - Camera Search Tests

    @Test("Search for camera objects")
    func searchCamera() throws {
        let scene = createTestScene()

        let cameraNode = SCNNode()
        cameraNode.name = "MainCamera"
        cameraNode.camera = SCNCamera()
        let cameraObj = GameObject(cameraNode)
        scene.addGameObject(cameraObj)

        let regularObj = GameObject(name: "RegularObject")
        scene.addGameObject(regularObj)

        let result = try #require(GameObject.find(.camera(.exact("MainCamera")), in: scene))
        #expect(result.name == "MainCamera")

        let results = GameObject.findGameObjects(.camera(.any), in: scene)
        #expect(results.count >= 1)
        #expect(results.contains(where: { $0.name == "MainCamera" }))
    }

    // MARK: - Light Search Tests

    @Test("Search for light objects")
    func searchLight() throws {
        let scene = createTestScene()

        let lightNode = SCNNode()
        lightNode.name = "DirectionalLight"
        lightNode.light = SCNLight()
        let lightObj = GameObject(lightNode)
        scene.addGameObject(lightObj)

        let regularObj = GameObject(name: "RegularObject")
        scene.addGameObject(regularObj)

        let result = try #require(GameObject.find(.light(.exact("DirectionalLight")), in: scene))
        #expect(result.name == "DirectionalLight")

        let results = GameObject.findGameObjects(.light(.any), in: scene)
        #expect(results.count == 1)
        #expect(results.first?.name == "DirectionalLight")
    }

    // MARK: - Hierarchical Search Tests

    @Test("Search finds objects in nested hierarchy")
    func searchNestedHierarchy() {
        let scene = createTestScene()

        let parent = GameObject(name: "HierarchyParent")
        parent.layer = .default
        scene.addGameObject(parent)

        let child = GameObject(name: "HierarchyChild")
        child.layer = .default
        parent.addChild(child)

        let grandchild = GameObject(name: "HierarchyGrandchild")
        grandchild.layer = .default
        child.addChild(grandchild)

        let results = GameObject.findGameObjects(.layer(.default), in: scene)
            .filter { $0.name?.starts(with: "Hierarchy") ?? false }
        #expect(results.count == 3)

        let names = results.compactMap { $0.name }
        #expect(names.contains("HierarchyParent"))
        #expect(names.contains("HierarchyChild"))
        #expect(names.contains("HierarchyGrandchild"))
    }

    @Test("Search in specific GameObject subtree")
    func searchInSubtree() {
        let scene = createTestScene()

        let parent1 = GameObject(name: "Parent1")
        scene.addGameObject(parent1)

        let child1 = GameObject(name: "Child1")
        parent1.addChild(child1)

        let parent2 = GameObject(name: "Parent2")
        scene.addGameObject(parent2)

        let child2 = GameObject(name: "Child2")
        parent2.addChild(child2)

        // Search only in parent1 subtree
        let results = GameObject.findGameObjects(.name(.contains("Child")), in: parent1)
        #expect(results.count == 1)
        #expect(results.first?.name == "Child1")
    }

    // MARK: - Edge Cases

    @Test("Search in nil scene returns empty")
    func searchNilScene() {
        let result = GameObject.find(.name(.any), in: nil)
        #expect(result == nil)

        let results = GameObject.findGameObjects(.name(.any), in: nil)
        #expect(results.isEmpty)
    }

    @Test("Search with no matches returns empty")
    func searchNoMatches() {
        let scene = createTestScene()

        let obj = GameObject(name: "Object")
        obj.layer = .default
        scene.addGameObject(obj)

        let results = GameObject.findGameObjects(.name(.exact("NonExistent")), in: scene)
        #expect(results.isEmpty)
    }
}
