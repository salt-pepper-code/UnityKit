import UIKit

/// Provides access to screen dimensions and display information.
///
/// `Screen` is a static utility class that stores the current screen width and height.
/// These values are typically set by the UnityKit framework when initializing the display
/// and can be used to position UI elements, calculate aspect ratios, or perform screen-space
/// calculations.
///
/// ## Topics
///
/// ### Screen Dimensions
/// - ``width``
/// - ``height``
///
/// ## Example
///
/// ```swift
/// // Access screen dimensions
/// let screenWidth = Screen.width
/// let screenHeight = Screen.height
///
/// // Calculate aspect ratio
/// let aspectRatio = screenWidth / screenHeight
///
/// // Center a UI element
/// let centerX = Screen.width / 2
/// let centerY = Screen.height / 2
///
/// // Position element at screen edge
/// let rightEdge = Screen.width - margin
/// let bottomEdge = Screen.height - margin
/// ```
///
/// - Note: These values are typically set internally by the framework and should be treated as read-only.
/// - Important: The values are in points, not pixels, following UIKit's coordinate system.
public class Screen {
    /// The width of the screen in points.
    ///
    /// This represents the horizontal dimension of the screen. The value is set internally
    /// by the framework when the display is initialized.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Calculate horizontal center
    /// let centerX = Screen.width / 2
    ///
    /// // Position element relative to screen width
    /// let rightEdge = Screen.width - 20
    /// ```
    ///
    /// - Note: This value is in points, not pixels.
    public internal(set) static var width: CGFloat = 0

    /// The height of the screen in points.
    ///
    /// This represents the vertical dimension of the screen. The value is set internally
    /// by the framework when the display is initialized.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Calculate vertical center
    /// let centerY = Screen.height / 2
    ///
    /// // Position element relative to screen height
    /// let bottomEdge = Screen.height - 20
    /// ```
    ///
    /// - Note: This value is in points, not pixels.
    public internal(set) static var height: CGFloat = 0
}
