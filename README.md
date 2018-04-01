<p align="center">
    <img width="250" height="250" src="3DVisualizer-iOS/CSDTModelViewer/Assets.xcassets/AppIcon.appiconset/3DVisualizerIconDesign-1024.png">
</p>

# 3D_Visualizer_iOS
This is an iOS application for visualizing 3D CAD models, created using SceneKit, Model I/O and ARKit.

## Features

### Fetch Models
*  Fetch the models using a valid web link or use the default wigwam model. If the link is invalid, the application will fall back to using the default wigwam model.
* Pick a model from the Device/Server list. For Server, the app presents a grid-like layout displaying all the images of projects fetched from the projects API from CSDT. The user can view the image in detail and display the image using AR if no 3D model data are found. If there is a 3D model associated with the project, the user can visualize it in 3D and AR.
* Import models from a third-party source (e.g. mail attachment), visualize it and save on device.

### Manupulate models with SceneKit
* Zoom, move and rotate model with gestures
* Manipulate the color of the model with segmented control
* Adjust light intensity with slider
* Change the position of the light with a tap on the scene
* Pick the color of model with a horizontally-scrollable picker interface.
* Settings Page
    * Change the scale factor used for the AR model
        * **For large models like wigwam, a very small factor such 0.002 is needed to display AR content correctly**
    * Pick from light types: omnidirectional, directional, probe, spot or ambient
    * Pick from blend modes: add, alpha, multiply, subtract, screen or replace
    * Animations! Choose from no animation or infinite rotation
    * Change the slider behavior: changing light intensity or color temperature

Relevant code needed to set up SceneKit - obtained from WWDC Presentation

```swift
import UIKit
import SceneKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // create a new scene
        let scene = SCNScene(named: "art.scnassets/wigwaam.stl")!

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)

        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)

        //additional setups
        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.white
    }
}
```

### Project models to the real world using Augmented Reality
* Wait until the device has found a surface to place the model.
* This app will highlight the the plane detected by ARKit.
* Once the plane is shown, tapping the plane will place the AR model on the plane
* Zoom the AR model with pinch gesture
* Rotate the AR model with rotation gesture
    *  Choose from 3 rotation axes: X, Y and Z
* Once the model is loaded, pan gesture can be used to adjust the position of the light projected onto the model.
* The AR model inherits all the settings from the previous SceneKit view.
* The image selected from the 2D list can be projected to the AR surface. (Only on a horizontal surface)
    * In the future, once the newest ARKit features are out of beta stage, the image can be projected to a vertical surface like a wall.

Relevant code needed to setup AR - from a WWDC 2017 video

```swift
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/wigwam.stl")!
        // Set the scene to the view
        sceneView.scene = scene
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
}
```
### Third Party Libraries Used:
* [Alamofire](https://github.com/Alamofire/Alamofire)  ( Swift Networking Library )

### **Thanks for viewing!**
