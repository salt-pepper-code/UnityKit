import SceneKit
import Testing
@testable import UnityKit

@Suite("GameObject Hierarchy")
struct GameObjectHierarchyTests {
    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    // MARK: - Active State

    @Test("GameObject activeSelf reflects active state")
    func activeSelfProperty() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        // Should be active by default
        #expect(obj.activeSelf == true)

        // Set to inactive using setActive
        obj.setActive(false)
        #expect(obj.activeSelf == false)

        // Set back to active
        obj.setActive(true)
        #expect(obj.activeSelf == true)
    }

    @Test("GameObject setActive changes activeSelf")
    func setActiveChangesActiveSelf() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        obj.setActive(false)
        #expect(obj.activeSelf == false)

        obj.setActive(true)
        #expect(obj.activeSelf == true)
    }

    @Test("GameObject enabled property mirrors activeSelf")
    func enabledMirrorsActiveSelf() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        obj.enabled = false
        #expect(obj.activeSelf == false)
        #expect(obj.enabled == false)

        obj.enabled = true
        #expect(obj.activeSelf == true)
        #expect(obj.enabled == true)
    }

    @Test("GameObject activeInHierarchy with no parent")
    func activeInHierarchyNoParent() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        // With no parent (except root), activeInHierarchy equals activeSelf
        #expect(obj.activeInHierarchy == obj.activeSelf)

        obj.setActive(false)
        #expect(obj.activeInHierarchy == false)
    }

    @Test("GameObject activeInHierarchy cascades from parent")
    func activeInHierarchyCascades() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(parent)
        parent.addChild(child)

        // Both active
        #expect(parent.activeInHierarchy == true)
        #expect(child.activeInHierarchy == true)

        // Deactivate parent
        parent.setActive(false)
        #expect(parent.activeInHierarchy == false)
        #expect(child.activeInHierarchy == false) // Child should be inactive too

        // Reactivate parent
        parent.setActive(true)
        #expect(parent.activeInHierarchy == true)
        #expect(child.activeInHierarchy == true)
    }

    @Test("GameObject activeInHierarchy with inactive child of active parent")
    func activeInHierarchyInactiveChild() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(parent)
        parent.addChild(child)

        // Deactivate only child
        child.setActive(false)
        #expect(parent.activeInHierarchy == true)
        #expect(child.activeSelf == false)
        #expect(child.activeInHierarchy == false)
    }

    @Test("GameObject activeInHierarchy with multiple levels")
    func activeInHierarchyMultipleLevels() {
        let scene = self.createTestScene()
        let grandparent = GameObject(name: "Grandparent")
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(grandparent)
        grandparent.addChild(parent)
        parent.addChild(child)

        // All active
        #expect(child.activeInHierarchy == true)

        // Deactivate middle parent
        parent.setActive(false)
        #expect(grandparent.activeInHierarchy == true)
        #expect(parent.activeInHierarchy == false)
        #expect(child.activeInHierarchy == false) // Child affected by parent

        // Reactivate parent
        parent.setActive(true)
        #expect(child.activeInHierarchy == true)
    }

    // MARK: - Parent-Child Relationships

    @Test("GameObject addChild sets parent reference")
    func addChildSetsParent() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(parent)
        parent.addChild(child)

        #expect(child.parent === parent)
    }

    @Test("GameObject addChild adds to children array")
    func addChildAddsToArray() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(parent)
        parent.addChild(child)

        let children = parent.getChildren()
        #expect(children.count == 1)
        #expect(children[0] === child)
    }

    @Test("GameObject addChild multiple children")
    func addMultipleChildren() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child1 = GameObject(name: "Child1")
        let child2 = GameObject(name: "Child2")
        let child3 = GameObject(name: "Child3")

        scene.addGameObject(parent)
        parent.addChild(child1)
        parent.addChild(child2)
        parent.addChild(child3)

        let children = parent.getChildren()
        #expect(children.count == 3)
        #expect(children.contains { $0 === child1 })
        #expect(children.contains { $0 === child2 })
        #expect(children.contains { $0 === child3 })
    }

    @Test("GameObject addChild prevents duplicates")
    func addChildPreventsDuplicates() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(parent)
        parent.addChild(child)
        parent.addChild(child) // Add same child again

        let children = parent.getChildren()
        #expect(children.count == 1) // Should only be added once
    }

    @Test("GameObject addChild propagates scene")
    func addChildPropagatesScene() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(parent)
        #expect(parent.scene === scene)

        parent.addChild(child)
        #expect(child.scene === scene) // Scene should propagate to child
    }

    @Test("GameObject getChild returns correct child by index")
    func getChildByIndex() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child1 = GameObject(name: "Child1")
        let child2 = GameObject(name: "Child2")

        scene.addGameObject(parent)
        parent.addChild(child1)
        parent.addChild(child2)

        let retrieved1 = parent.getChild(0)
        let retrieved2 = parent.getChild(1)

        #expect(retrieved1 === child1)
        #expect(retrieved2 === child2)
    }

    @Test("GameObject getChild returns nil for invalid index")
    func getChildInvalidIndex() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        scene.addGameObject(parent)

        let child = parent.getChild(0)
        #expect(child == nil)

        let outOfBounds = parent.getChild(99)
        #expect(outOfBounds == nil)
    }

    @Test("GameObject removeChild removes from children array")
    func removeChildFromArray() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(parent)
        parent.addChild(child)

        #expect(parent.getChildren().count == 1)

        parent.removeChild(child)

        #expect(parent.getChildren().count == 0)
    }

    @Test("GameObject removeChild removes specific child")
    func removeSpecificChild() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child1 = GameObject(name: "Child1")
        let child2 = GameObject(name: "Child2")

        scene.addGameObject(parent)
        parent.addChild(child1)
        parent.addChild(child2)

        parent.removeChild(child1)

        let children = parent.getChildren()
        #expect(children.count == 1)
        #expect(children[0] === child2)
    }

    @Test("GameObject removeChild when child not present")
    func removeNonExistentChild() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")
        let unrelated = GameObject(name: "Unrelated")

        scene.addGameObject(parent)
        parent.addChild(child)

        // Remove child that was never added
        parent.removeChild(unrelated)

        // Original child should still be there
        #expect(parent.getChildren().count == 1)
        #expect(parent.getChildren()[0] === child)
    }

    // MARK: - Instantiation

    @Test("GameObject instantiate creates a copy")
    func instantiateCreatesClone() {
        let scene = self.createTestScene()
        let original = GameObject(name: "Original")
        scene.addGameObject(original)

        let clone = original.instantiate()

        #expect(clone !== original) // Different objects
        #expect(clone.name == "Original Clone")
    }

    @Test("GameObject instantiate preserves tag")
    func instantiatePreservesTag() {
        let scene = self.createTestScene()
        let original = GameObject(name: "Original")
        original.tag = .custom("TestTag")
        scene.addGameObject(original)

        let clone = original.instantiate()

        #expect(clone.tag == .custom("TestTag"))
    }

    @Test("GameObject instantiate preserves layer")
    func instantiatePreservesLayer() {
        let scene = self.createTestScene()
        let original = GameObject(name: "Original")
        original.layer = .player
        scene.addGameObject(original)

        let clone = original.instantiate()

        #expect(clone.layer == .player)
    }

    @Test("GameObject static instantiate with addToScene")
    func staticInstantiateAddsToScene() {
        let scene = self.createTestScene()
        let original = GameObject(name: "Original")
        scene.addGameObject(original)

        let clone = GameObject.instantiate(original: original, addToScene: true)

        #expect(clone.scene === scene)
        #expect(clone !== original)
    }

    @Test("GameObject static instantiate without addToScene")
    func staticInstantiateWithoutScene() {
        let scene = self.createTestScene()
        let original = GameObject(name: "Original")
        scene.addGameObject(original)

        let clone = GameObject.instantiate(original: original, addToScene: false)

        // Clone should not be in scene initially
        #expect(clone !== original)
        #expect(clone.name == "Original Clone")
    }

    @Test("GameObject static instantiate with parent")
    func staticInstantiateWithParent() {
        let scene = self.createTestScene()
        let original = GameObject(name: "Original")
        let parent = GameObject(name: "Parent")
        scene.addGameObject(original)
        scene.addGameObject(parent)

        let clone = GameObject.instantiate(original: original, parent: parent.transform)

        #expect(clone.parent === parent)
        #expect(parent.getChildren().contains { $0 === clone })
    }

    @Test("GameObject instantiate with children copies hierarchy")
    func instantiateWithChildren() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")
        scene.addGameObject(parent)
        parent.addChild(child)

        let parentClone = parent.instantiate()

        // Clone should have children
        #expect(parentClone.getChildren().count > 0)
    }

    // MARK: - Scene Propagation

    @Test("GameObject setScene propagates to children")
    func setScenePropagates() {
        let scene1 = Scene(allocation: .instantiate)
        let scene2 = Scene(allocation: .instantiate)

        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")
        scene1.addGameObject(parent)
        parent.addChild(child)

        #expect(child.scene === scene1)

        // Change parent's scene
        parent.setScene(scene2)

        // Child should also have new scene
        #expect(child.scene === scene2)
    }

    @Test("GameObject setScene cascades through hierarchy")
    func setSceneCascadesThroughHierarchy() {
        let scene1 = Scene(allocation: .instantiate)
        let scene2 = Scene(allocation: .instantiate)

        let grandparent = GameObject(name: "Grandparent")
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene1.addGameObject(grandparent)
        grandparent.addChild(parent)
        parent.addChild(child)

        #expect(parent.scene === scene1)
        #expect(child.scene === scene1)

        // Change grandparent's scene
        grandparent.setScene(scene2)

        // All descendants should have new scene
        #expect(parent.scene === scene2)
        #expect(child.scene === scene2)
    }

    // MARK: - Edge Cases

    @Test("GameObject with no scene has nil scene reference")
    func noSceneReference() {
        let obj = GameObject(name: "Orphan")
        #expect(obj.scene == nil)
    }

    @Test("GameObject hierarchy maintains consistency after multiple operations")
    func hierarchyConsistency() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child1 = GameObject(name: "Child1")
        let child2 = GameObject(name: "Child2")

        scene.addGameObject(parent)
        parent.addChild(child1)
        parent.addChild(child2)

        #expect(parent.getChildren().count == 2)

        parent.removeChild(child1)
        #expect(parent.getChildren().count == 1)

        parent.addChild(child1)
        #expect(parent.getChildren().count == 2)

        let children = parent.getChildren()
        #expect(children.contains { $0 === child1 })
        #expect(children.contains { $0 === child2 })
    }

    @Test("GameObject layer propagates to children on set")
    func layerPropagationToChildren() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(parent)
        parent.addChild(child)

        parent.layer = .player

        // Layer should propagate to child
        #expect(child.layer == .player)
    }
}
