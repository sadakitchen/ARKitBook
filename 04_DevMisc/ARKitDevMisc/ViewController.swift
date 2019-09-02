//
//  ViewController.swift
//  ARDebug
//
//  Created by Shuichi Tsutsumi on 2017/07/17.
//  Copyright © 2017 Shuichi Tsutsumi. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    private var virtualObjectNode: SCNNode!
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var trackingStateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 仮想オブジェクトのノードを作成
        virtualObjectNode = loadModel()

        sceneView.delegate = self
        
        // シーンを生成してARSCNViewにセット
        sceneView.scene = SCNScene()
        
        // セッションのコンフィギュレーションを生成
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true

        // デバッグオプション
        // showWorldOrigin: ワールド座標の原点を可視化する
        // showFeaturePoints: ARKit が検出した 3D 特徴点群を可視化する
        // ARSCNDebugOptionsは SCNDebugOptionsの typealiasなので、debugOptions プロパティに他の(ARSCNDebugOptionsではない)オプションと一緒に指定できます。
//        sceneView.debugOptions = [.showBoundingBoxes]
//        sceneView.debugOptions = [.showWireframe]
        sceneView.debugOptions = [.renderAsWireframe]

        // セッション開始
        sceneView.session.run(configuration)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func loadModel() -> SCNNode {
        guard let scene = SCNScene(named: "duck.scn", inDirectory: "models.scnassets/duck") else {fatalError()}
        
        let modelNode = SCNNode()
        for child in scene.rootNode.childNodes {
            modelNode.addChildNode(child)
        }
        
        return modelNode
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
        print("anchor:\(anchor), node: \(node), node geometry: \(String(describing: node.geometry))")
        // 平面アンカーを可視化
        planeAnchor.addPlaneNode(on: node, contents: UIColor.yellow)
        
        DispatchQueue.main.async(execute: {
            // 仮想オブジェクトを乗せる
            node.addChildNode(self.virtualObjectNode)
        })
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
        DispatchQueue.main.async(execute: {
            planeAnchor.updatePlaneNode(on: node)
        })
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("\(self.classForCoder)/" + #function)
    }

    // MARK: - ARSessionObserver
    // トラッキング状態に変化があ ると呼ばれるメソッド
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("trackingState: \(camera.trackingState)") // トラッキング情報が trackingState に入っている
        
        // NOTE: ARCamera.TrackingState の enum
        // notAvailable: トラッキング不可
        // limited(ARCamera.TrackingState.Reason): トラッキング品質が制限されている
        // normal: 正常にトラッキングが行えている
        
        // limitedの ARCamera.TrackingState.Reason : 理由
        // initializing: 初期化処理中
        // relocalizing: セッション中断後の再開処理中
        // excessiveMotion: デバイスの動きが速すぎる
        // insufficientFeatures: カメラに映るシーン内の識別可能な特徴が十分でない(もっとテクスチャのある平面が必要)
        
        trackingStateLabel.text = camera.trackingState.description
    }
}

