# ARKit Car Rims
ARKit - Placing Virtual Objects in Augmented Reality 

Learn best practices for visual feedback, gesture interactions, and realistic rendering in AR experiences, as well as tips for building SceneKit-based AR apps.

# Requirements
You should be using XCode 9.x.

ARKit is available on any iOS 11 device, but the world tracking features that enable high-quality AR experiences require a device with the A9 chip or later processor.

**IMPORTANT: Here’s the list of iPhone and iPad models compatible with ARKit in iOS 11 (with A9 Chip)**

* The 2017 9.7-inch iPad
* All variants of the iPad Pro
* iPhone 7 Plus
* iPhone 7
* iPhone 6s Plus
* iPhone 6s
* iPhone SE
* iPhone 8
* iPhone 8 Plus
* iPhone X / iPhone 10
* All new iPhones newer than the previous mentioned

# Overview
Augmented reality offers new ways for users to interact with real and virtual 3D content in your app. However, many of the fundamental principles of human interface design are still valid. Convincing AR illusions also require careful attention to 3D asset design and rendering. By following this article's guidelines for AR human interface principles and experimenting with this example code, you can create immersive, intuitive augmented reality experiences.

# Feedback
**Help users recognize when your app is ready for real-world interactions.** Tracking the real-world environment involves complex algorithms whose timeliness and accuracy are affected by real-world conditions.

The `FocusSquare` class in this example project draws a square outline in the AR view, giving the user hints about the status of ARKit world tracking. The square changes size to reflect estimated scene depth, and switches between open and closed states with a "lock" animation to indicate whether ARKit has detected a plane suitable for placing an object.

**Help users understand the relationship of your app's virtual content to the real world.** Use visual cues in your UI that react to changes in camera position relative to virtual content.

The focus square disappears after the user places an object in the scene, and reappears when the user points the camera away from the object.

# Direct Manipulation
**Provide common gestures, familiar to users of other iOS apps, for interacting with real-world objects.** See the `Gesture` class in this example for implementations of the gestures available in this example app, such as one-finger dragging to move a virtual object and two-finger rotation to spin the object.

Map touch gestures into a restricted space so the user can more easily control results. Touch gestures are inherently two-dimensional, but an AR experience involves the three dimensions of the real world. For example:

* Limit object dragging to the two-dimensional plane the object rests on. (Especially if a plane represents the ground or floor, it often makes sense to ignore the plane's extent while dragging.)

* Limit object rotation to a single axis at a time. (In this example, each object rests on a plane, so the object can rotate around a vertical axis.)

* Don't allow the user to resize virtual objects, or offer this ability only sparingly. A virtual object inhabits the real world more convincingly when it has an intuitive intrinsic size. Additionally, a user may become confused as to whether they're resizing an object or changing its depth relative to the camera. (If you do provide object resizing, use pinch gestures.)

While the user is dragging a virtual object, smooth the changes in its position so that it doesn't appear to jump while moving. See the updateVirtualObjectPosition method in this example's ViewController class for an example of smoothing based on perceived distance from the camera.

# User Control
**Strive for a balance between accurately placing virtual content and respecting the user's input.** For example, consider a situation where the user attempts to place content that should appear on top of a flat surface.

* First, try to place content by using the [`raycastQuery(from point:allowing target:alignment:)`](https://developer.apple.com/documentation/arkit/arframe/3194578-raycastquery) method to search for an intersection with a plane anchor. If you don't find a plane anchor, there might still be a plane at the target location that has not yet been identified by plane detection.

* Lacking a plane anchor, you can hit-test against scene features to get a rough estimate for where to place content right away, and refine that estimate over time as ARKit detects planes.

* When plane detection provides a better estimate for where to place content, use animation to subtly move that content to its new position. Having user-placed content suddenly jump to a new position can break the AR illusion and confuse the user.

* Filter out hit test results which are too close or too far away. In most scenarios there exists a reasonable limit for how far away virtual content can be placed. To prevent users from accidentally placing virtual content too far away you can make use of the distance property of `ARRaycastResult` to filter out hit tests which exeed the limit.

**Avoid interrupting the AR experience.** If the user transitions to another fullscreen UI in your app, the AR view might not be an expected state when coming back.

# Testing
For testing and debugging AR experiences, it helps to have a live visualization of the scene processing that ARKit performs. See the `showDebugVisuals` method in this project's `ViewController` class for world tracking visualization, and the `HitTestVisualization` class for a demonstration of ARKit's feature detection methods.

# Best Practices and Limitations
World tracking is an inexact science. This process can often produce impressive accuracy, leading to realistic AR experiences. However, it relies on details of the device’s physical environment that are not always consistent or are difficult to measure in real time without some degree of error. To build high-quality AR experiences, be aware of these caveats and tips.

**Design AR experiences for predictable lighting conditions.** World tracking involves image analysis, which requires a clear image. Tracking quality is reduced when the camera can’t see details, such as when the camera is pointed at a blank wall or the scene is too dark.

**Use tracking quality information to provide user feedback.** World tracking correlates image analysis with device motion. ARKit develops a better understanding of the scene if the device is moving, even if the device moves only subtly. Excessive motion—too far, too fast, or shaking too vigorously—results in a blurred image or too much distance for tracking features between video frames, reducing tracking quality. The ARCamera class provides tracking state reason information, which you can use to develop UI that tells a user how to resolve low-quality tracking situations.

**Allow time for plane detection to produce clear results, and disable plane detection when you have the results you need.** Plane detection results vary over time—when a plane is first detected, its position and extent may be inaccurate. As the plane remains in the scene over time, ARKit refines its estimate of position and extent. When a large flat surface is in the scene, ARKit may continue changing the plane anchor’s position, extent, and transform after you’ve already used the plane to place content.

# LICENSE!
ARCarRims [MIT-licensed.](https://github.com/PiyushSelarka/ARCarRims/blob/main/LICENSE)

# Let us know!
We’d be really happy if you send us links to your projects where you use our component. Just send an email to sales@mindinventory.com And do let us know if you have any questions or suggestion regarding our work.
