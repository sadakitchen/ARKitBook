//
//  ViewController.swift
//  FirstAR
//
//  Created by Shuichi Tsutsumi on 2017/07/17.
//  Copyright © 2017 Shuichi Tsutsumi. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    // 3D 空間の描画は基本的に SceneKit が担当(SCNScene(UIViewを継承))
    // class ARSCNView : SCNView
    // ARKit 関連の機能を取り扱いつつ、 UIKit ベースの UI 階層内で3次元シーンを描画するためのクラス
    // ARSCNViewオブジェクトを生成した時点で、その sessionプロパティにはすでに ARSessionオブジェクトが生成されて入っている
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // シーンを生成してARSCNViewにセット
        sceneView.scene = SCNScene(named: "art.scnassets/ship.scn")!

        // セッションのコンフィギュレーション(設定)を生成
        // NOTE:
        // オーディオデータも取得するか(providesAudio Dataプロパティ)
        // カメラ入力からシーンのライティングを推定するか(isLightE stimationEnabledプロパティ)
        let configuration = ARWorldTrackingConfiguration()
        
        // セッション開始
        // ARKit 内部でカメラからの入力の画像解析や、デバイスのモーショ ン情報の取得・解析が開始
        // 第２引数はoption
        //sceneView.session.pause() で抜ける
        sceneView.session.run(configuration)
    }
}
