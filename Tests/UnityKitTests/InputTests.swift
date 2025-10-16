import Testing
import Foundation
@testable import UnityKit

@Suite("Input System", .serialized)
struct InputTests {

    // MARK: - Keyboard Tests

    @Test("getKey returns false when key is not pressed")
    func getKeyNotPressed() {
        Input.resetForTesting()

        #expect(Input.getKey("W") == false)
        #expect(Input.getKey("Space") == false)
    }

    @Test("getKey returns true when key is held down")
    func getKeyPressed() {
        Input.resetForTesting()

        Input.setKeyDown("W")

        #expect(Input.getKey("W") == true)
        #expect(Input.getKey("w") == true) // Case insensitive
    }

    @Test("getKeyDown returns true only on frame key is pressed")
    func getKeyDown() {
        Input.resetForTesting()

        Input.setKeyDown("Space")

        #expect(Input.getKeyDown("Space") == true)
        #expect(Input.getKey("Space") == true)

        // After update, getKeyDown should be false but getKey still true
        Input.update()

        #expect(Input.getKeyDown("Space") == false)
        #expect(Input.getKey("Space") == true)
    }

    @Test("getKeyUp returns true only on frame key is released")
    func getKeyUp() {
        Input.resetForTesting()

        // Press key
        Input.setKeyDown("A")
        #expect(Input.getKey("A") == true)

        Input.update()

        // Release key
        Input.setKeyUp("A")
        #expect(Input.getKeyUp("A") == true)
        #expect(Input.getKey("A") == false)

        // After update, getKeyUp should be false
        Input.update()
        #expect(Input.getKeyUp("A") == false)
    }

    @Test("anyKey returns true when any key is pressed")
    func anyKeyPressed() {
        Input.resetForTesting()

        #expect(Input.anyKey == false)

        Input.setKeyDown("Q")
        #expect(Input.anyKey == true)

        Input.setKeyUp("Q")
        #expect(Input.anyKey == false)
    }

    @Test("anyKeyDown returns true when any key starts being pressed")
    func anyKeyDown() {
        Input.resetForTesting()

        #expect(Input.anyKeyDown == false)

        Input.setKeyDown("E")
        #expect(Input.anyKeyDown == true)

        Input.update()
        #expect(Input.anyKeyDown == false)
    }

    @Test("Multiple keys can be pressed simultaneously")
    func multipleKeysPressed() {
        Input.resetForTesting()

        Input.setKeyDown("W")
        Input.setKeyDown("Shift")

        #expect(Input.getKey("W") == true)
        #expect(Input.getKey("Shift") == true)
        #expect(Input.getKey("A") == false)
    }

    @Test("Key input is case insensitive")
    func keyCaseInsensitive() {
        Input.resetForTesting()

        Input.setKeyDown("w")

        #expect(Input.getKey("W") == true)
        #expect(Input.getKey("w") == true)
        #expect(Input.getKeyDown("W") == true)
        #expect(Input.getKeyDown("w") == true)
    }

    // MARK: - Mouse Tests

    @Test("getMouseButton returns false when button is not pressed")
    func getMouseButtonNotPressed() {
        Input.resetForTesting()

        #expect(Input.getMouseButton(0) == false) // Left button
        #expect(Input.getMouseButton(1) == false) // Right button
        #expect(Input.getMouseButton(2) == false) // Middle button
    }

    @Test("getMouseButton returns true when button is held down")
    func getMouseButtonPressed() {
        Input.resetForTesting()

        Input.setMouseButtonDown(0)

        #expect(Input.getMouseButton(0) == true)
        #expect(Input.getMouseButton(1) == false)
    }

    @Test("getMouseButtonDown returns true only on frame button is pressed")
    func getMouseButtonDown() {
        Input.resetForTesting()

        Input.setMouseButtonDown(0)

        #expect(Input.getMouseButtonDown(0) == true)
        #expect(Input.getMouseButton(0) == true)

        // After update, getMouseButtonDown should be false but getMouseButton still true
        Input.update()

        #expect(Input.getMouseButtonDown(0) == false)
        #expect(Input.getMouseButton(0) == true)
    }

    @Test("getMouseButtonUp returns true only on frame button is released")
    func getMouseButtonUp() {
        Input.resetForTesting()

        // Press button
        Input.setMouseButtonDown(1)
        #expect(Input.getMouseButton(1) == true)

        Input.update()

        // Release button
        Input.setMouseButtonUp(1)
        #expect(Input.getMouseButtonUp(1) == true)
        #expect(Input.getMouseButton(1) == false)

        // After update, getMouseButtonUp should be false
        Input.update()
        #expect(Input.getMouseButtonUp(1) == false)
    }

    @Test("Multiple mouse buttons can be pressed simultaneously")
    func multipleMouseButtonsPressed() {
        Input.resetForTesting()

        Input.setMouseButtonDown(0)
        Input.setMouseButtonDown(1)

        #expect(Input.getMouseButton(0) == true)
        #expect(Input.getMouseButton(1) == true)
        #expect(Input.getMouseButton(2) == false)
    }

    @Test("Invalid mouse button indices return false")
    func invalidMouseButtonIndices() {
        Input.resetForTesting()

        #expect(Input.getMouseButton(-1) == false)
        #expect(Input.getMouseButton(3) == false)
        #expect(Input.getMouseButton(10) == false)

        #expect(Input.getMouseButtonDown(-1) == false)
        #expect(Input.getMouseButtonDown(3) == false)

        #expect(Input.getMouseButtonUp(-1) == false)
        #expect(Input.getMouseButtonUp(3) == false)
    }

    @Test("Mouse position can be set and retrieved")
    func mousePosition() {
        Input.resetForTesting()

        let position = Vector2(100, 200)
        Input.setMousePosition(position)

        #expect(Input.mousePosition == position)
    }

    @Test("Mouse position updates correctly")
    func mousePositionUpdates() {
        Input.resetForTesting()

        Input.setMousePosition(Vector2(50, 75))
        #expect(Input.mousePosition == Vector2(50, 75))

        Input.setMousePosition(Vector2(150, 225))
        #expect(Input.mousePosition == Vector2(150, 225))
    }

    // MARK: - Combined Input Tests

    @Test("Keyboard and mouse can be used together")
    func keyboardAndMouseTogether() {
        Input.resetForTesting()

        Input.setKeyDown("W")
        Input.setMouseButtonDown(0)
        Input.setMousePosition(Vector2(100, 100))

        #expect(Input.getKey("W") == true)
        #expect(Input.getMouseButton(0) == true)
        #expect(Input.mousePosition == Vector2(100, 100))
    }

    // MARK: - Update Cycle Tests

    @Test("update() clears frame-specific states")
    func updateClearsFrameStates() {
        Input.resetForTesting()

        Input.setKeyDown("Space")
        Input.setMouseButtonDown(0)

        #expect(Input.getKeyDown("Space") == true)
        #expect(Input.getMouseButtonDown(0) == true)

        // After update, Down states should be cleared
        Input.update()

        #expect(Input.getKeyDown("Space") == false)
        #expect(Input.getMouseButtonDown(0) == false)

        // But pressed states should persist
        #expect(Input.getKey("Space") == true)
        #expect(Input.getMouseButton(0) == true)
    }

    @Test("update() clears Up states")
    func updateClearsUpStates() {
        Input.resetForTesting()

        // Press and hold
        Input.setKeyDown("A")
        Input.setMouseButtonDown(1)
        Input.update()

        // Release
        Input.setKeyUp("A")
        Input.setMouseButtonUp(1)

        #expect(Input.getKeyUp("A") == true)
        #expect(Input.getMouseButtonUp(1) == true)

        // After update, Up states should be cleared
        Input.update()

        #expect(Input.getKeyUp("A") == false)
        #expect(Input.getMouseButtonUp(1) == false)
    }

    // MARK: - State Persistence Tests

    @Test("Held keys persist across frames")
    func heldKeysPersist() {
        Input.resetForTesting()

        Input.setKeyDown("W")
        #expect(Input.getKey("W") == true)

        // Simulate multiple frames
        Input.update()
        #expect(Input.getKey("W") == true)

        Input.update()
        #expect(Input.getKey("W") == true)

        // Until released
        Input.setKeyUp("W")
        #expect(Input.getKey("W") == false)
    }

    @Test("Held mouse buttons persist across frames")
    func heldMouseButtonsPersist() {
        Input.resetForTesting()

        Input.setMouseButtonDown(0)
        #expect(Input.getMouseButton(0) == true)

        // Simulate multiple frames
        Input.update()
        #expect(Input.getMouseButton(0) == true)

        Input.update()
        #expect(Input.getMouseButton(0) == true)

        // Until released
        Input.setMouseButtonUp(0)
        #expect(Input.getMouseButton(0) == false)
    }

    // MARK: - Edge Cases

    @Test("Empty key string")
    func emptyKeyString() {
        Input.resetForTesting()

        Input.setKeyDown("")
        #expect(Input.getKey("") == true)

        Input.setKeyUp("")
        #expect(Input.getKey("") == false)
    }

    @Test("Special character keys")
    func specialCharacterKeys() {
        Input.resetForTesting()

        Input.setKeyDown("!")
        #expect(Input.getKey("!") == true)

        Input.setKeyDown("@#$")
        #expect(Input.getKey("@#$") == true)
    }

    @Test("All three mouse buttons work correctly")
    func allMouseButtons() {
        Input.resetForTesting()

        // Test left button (0)
        Input.setMouseButtonDown(0)
        #expect(Input.getMouseButton(0) == true)
        Input.setMouseButtonUp(0)

        Input.update()

        // Test right button (1)
        Input.setMouseButtonDown(1)
        #expect(Input.getMouseButton(1) == true)
        Input.setMouseButtonUp(1)

        Input.update()

        // Test middle button (2)
        Input.setMouseButtonDown(2)
        #expect(Input.getMouseButton(2) == true)
        Input.setMouseButtonUp(2)
    }
}
