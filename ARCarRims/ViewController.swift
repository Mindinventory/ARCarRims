//
//  ViewController.swift
//  ARCarRims
//
//  Created by mac-00017 on 05/05/22.
//

import UIKit
import ARKit

class ViewController: UIViewController,ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var CollView: UICollectionView!
    var grids = [Grid]()
    var rimsNode = SCNNode()
    var hitTestResult : ARRaycastResult?
    var upDown = 0.0
    var leftRight = 0.0
    var zoom = 0.0
    var selectedRims = "1"
    var cameraNode = SCNNode()
    var arrImages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information and debugOptions
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Create a new scene
        let scene = SCNScene()

        // Set the scene to the view
        sceneView.scene = scene
        //sceneView.allowsCameraControl = true

        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(gestureRecognizer)
        
        arrImages = ["1","2","3","4","5"]
        CollView.register(UINib(nibName: "RimsCollVCell", bundle: .main), forCellWithReuseIdentifier: "RimsCollVCell")
        CollView.reloadData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}

extension ViewController {
    
    @IBAction func btnUP(_ sender: Any) {
        if (hitTestResult != nil) {
            upDown = upDown + 0.01
            updateRimsPosition()
        }
    }
    @IBAction func btnDown(_ sender: Any) {
        if (hitTestResult != nil) {
            upDown = upDown - 0.01
            updateRimsPosition()
        }
    }
    @IBAction func btnLeft(_ sender: Any) {
        if (hitTestResult != nil) {
            leftRight = leftRight - 0.01
            updateRimsPosition()
        }
    }
    @IBAction func btnRight(_ sender: Any) {
        if (hitTestResult != nil) {
            leftRight = leftRight + 0.01
            updateRimsPosition()
        }
    }
    @IBAction func btnMinus(_ sender: Any) {
        if (hitTestResult != nil) {
            zoom = zoom - 0.01
            updateRimsPosition()
        }
    }
    @IBAction func btnPlus(_ sender: Any) {
        if (hitTestResult != nil) {
            zoom = zoom + 0.01
            updateRimsPosition()
        }
    }
    @IBAction func btnReset(_ sender: Any) {
        sceneView.scene.rootNode.childNodes.filter({ $0.name == "rims" }).forEach({ $0.removeFromParentNode() })
        sceneView.scene.rootNode.childNodes.filter({ $0.name == "grid" }).forEach({ $0.removeFromParentNode() })
        sceneView.isUserInteractionEnabled = true
    }
    @IBAction func btnSnapShort(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(sceneView.snapshot(), nil, nil, nil)
    }
}

extension ViewController {
    
    func updateRims(name:String) {
        if (hitTestResult != nil) {
            selectedRims = name
            addPainting(hitTestResult!, img: name)
        }
    }
    
    func updateRimsPosition() {
        rimsNode.position = SCNVector3(hitTestResult!.worldTransform.columns.3.x + Float(leftRight), hitTestResult!.worldTransform.columns.3.y + Float(upDown), hitTestResult!.worldTransform.columns.3.z + Float(zoom))
    }
    
    func addPainting(_ hitResult: ARRaycastResult, img:String) {
        // 1.
        let planeGeometry = SCNPlane(width: 0.45, height: 0.45)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: img)
        planeGeometry.materials = [material]
        
        // 2.
        rimsNode = SCNNode(geometry: planeGeometry)
        rimsNode.name = "rims"
        rimsNode.transform = SCNMatrix4(hitResult.anchor!.transform)
        rimsNode.eulerAngles = SCNVector3(rimsNode.eulerAngles.x + (-Float.pi / 2), rimsNode.eulerAngles.y, rimsNode.eulerAngles.z)
        rimsNode.position = SCNVector3(hitResult.worldTransform.columns.3.x + Float(leftRight), hitResult.worldTransform.columns.3.y + Float(upDown), hitResult.worldTransform.columns.3.z + Float(zoom))
        
        sceneView.scene.rootNode.childNodes.filter({ $0.name == "rims" }).forEach({ $0.removeFromParentNode() })
        sceneView.scene.rootNode.addChildNode(rimsNode)
    }
    
    @objc func tapped(gesture: UITapGestureRecognizer) {
        
        // Get 2D position of touch event on screen
        let touchPosition = gesture.location(in: sceneView)
        
        // Translate those 2D points to 3D points using hitTest (existing plane)
        guard let query = sceneView.raycastQuery(from: touchPosition, allowing: .existingPlaneGeometry, alignment: .any) else { return }
        let results = sceneView.session.raycast(query)
        guard let hitTestResults = results.first else {
            print("no surface found")
            return
        }
        
        // Get hitTest results and ensure that the hitTest corresponds to a grid that has been placed on a wall
        guard let anchor = hitTestResults.anchor as? ARPlaneAnchor, let gridIndex = grids.firstIndex(where: { $0.anchor == anchor }) else {
            return
        }
        grids[gridIndex].removeFromParentNode()
        hitTestResult = hitTestResults
        addPainting(hitTestResults, img: selectedRims)
        sceneView.isUserInteractionEnabled = false
    }
}

extension ViewController {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        
        DispatchQueue.main.async { [weak self] in
            let grid = Grid(anchor: planeAnchor)
            self?.grids.append(grid)
            node.name = "grid"
            node.addChildNode(grid)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        DispatchQueue.main.async { [weak self] in
            
            let grid = self?.grids.filter { grid in
                return grid.anchor.identifier == planeAnchor.identifier
                }.first
            
            guard let foundGrid = grid else {
                return
            }
            
            foundGrid.update(anchor: planeAnchor)
        }
    }
}
extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RimsCollVCell", for: indexPath) as? RimsCollVCell {
            cell.imgView.image = UIImage.init(named: arrImages[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateRims(name: arrImages[indexPath.row])
    }
}

