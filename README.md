# 3D_Visualizer_iOS
This is an iOS application for visualizing 3D CAD models, created using SceneKit, Model I/O and ARKit.

## Features

### Fetch Models
*  Fetch the models using a valid web link or use the default wigwam model. If the link is invalid, the application will fall back to using the default wigwam model.

### Manupulate models with SceneKit
* Zoom, move and rotate model with gestures
* Manipulate the color of the model with segmented control
* Adjust light intensity with slider
* Settings Page
    * Pick from light types: omnidirectional, directional, probe, spot or ambient
    * Pick from blend modes: add, alpha, multiply, subtract, screen or replace
    * Animations! Choose from no animation or infinite rotation

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
* Once the model is loaded, pan gesture can be used to adjust the position of the light projected onto the model.
* The AR model inherits all the settings from the previous SceneKit view.

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


## Thanks for viewing!
