//
//  Copyright © 2018 Shuichi Tsutsumi. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self

        // シーンを生成してARSCNViewにセット
        sceneView.scene = SCNScene()
        
        // セッションのコンフィギュレーションを生成
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical] // 平面の検出設定

        // セッション開始
        sceneView.session.run(configuration)
    }
}

// 平面検出に関するイベントをフックする - ARSessionDelegate
// 以下は継承して平面検出部分を抜き出している
// sceneView.session.delegate = self

// 平面が新たに検出された(アンカーがセッションに追加された)
// func session(_ session: ARSession, didAdd anchors: [ARAnchor])
// 検出済みの平面が更新された(アンカーが更新された)
// func session(_ session: ARSession, didUpdate anchors: [ARAnchor])
// 検出済みの平面が削除された(アンカーがセッションから削除された)
// func session(_ session: ARSession, didRemove anchors: [ARAnchor])

// ARAnchorとは、AR シーンの 3D 空間内に何らかのオブジェクトを設置するための位置・向きを表すクラス
// アンカーを一意に決める UUID型の identifierプロパティ
// var identifier: UUID { get }
// 3D 空間における位置と回転(向き)を決める simd_float4x4型 のtransformプロパティ
// var transform: simd_float4x4 { get }
// を持っている

// ARAnchor は ARPlaneAnchor というサブクラスをがある
// 平面を表すための中心位置を示す centerプロパティ
// var center: simd_float3 { get }
// 大きさ(x:幅・z:奥行き)を示す extentプロパティ (y値は常にゼロ)
// var extent: simd_float3 { get }

// 平面検出に関するイベントをフックする - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    // 新しいアンカーに対応するノードがシーンに追加された
    // 注意）renderer(_:didAdd:for:)の引数に渡さ れる SCNNodeオブジェクトには、ジオメトリが割り当てられていない
    // そのままでは検出した平面は可視化されていない
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("anchor:\(anchor), node: \(node), node geometry: \(String(describing: node.geometry))")
        
        // 平面検出時は ARPlaneAnchor 型のアンカーが得られる
        guard let planeAnchor = anchor as? ARPlaneAnchor else { fatalError() }
        
        // アライメントによって色をわける
        let color: UIColor = planeAnchor.alignment == .horizontal ? UIColor.yellow : UIColor.blue
        
        // 平面ジオメトリを持つノードを作成し、
        // 検出したアンカーに対応するノードに子ノードとして持たせる
        planeAnchor.addPlaneNode(on: node, contents: color.withAlphaComponent(0.3))
        
        // ===================================
        // 平面ジオメトリを作成......(1)
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        geometry.materials.first?.diffuse.contents = UIColor.green
        // 平面ジオメトリを持つノードを作成
        let planeNode = SCNNode(geometry: geometry)
        // 平面ジオメトリを持つノードを x 軸まわりに 90 度回転......(2)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        DispatchQueue.main.async(execute: {
            // 検出したアンカーに対応するノードに子ノードとして持たせる
            node.addChildNode(planeNode)
        })
        // ===================================
    }
    
    // 対応するアンカーの現在の状態に合うようにノードが(これから)更新される
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        // 何かの下準備
    }
    
    // 対応するアンカーの現在の状態に合うようにノードが更新された
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
        planeAnchor.updatePlaneNode(on: node)
    }
    
    // 削除されたアンカーに対応するノードがシーンから削除された
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("\(self.classForCoder)/" + #function)
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
        planeAnchor.findPlaneNode(on: node)?.removeFromParentNode()
    }
}
