import Flutter
import UIKit
import QGVAPlayer

public class FlutterVapPlugin:NSObject,FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
        registrar.register(NativeVapViewFactory(registrar: registrar), withId: "flutter_vap")
    }
}
class NativeVapViewFactory: NSObject,FlutterPlatformViewFactory {
    var viewList:[FlutterVapVew] = []
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        //        print("FlutterVapPlugin create(withFram \(String(describing: args))")
        let view = FlutterVapVew(frame: frame, viewId: viewId, args: args, registrar: _registrar)
        let address = "\(Unmanaged.passUnretained(view).toOpaque())"
        viewList.append(view)
        view.deinitBlock = { [weak self] in
            guard let `self` = self else { return }
            var indexTagView = -1
            for (index,value) in self.viewList.enumerated(){
                let viewAddress = "\(Unmanaged.passUnretained(value).toOpaque())"
                if address == viewAddress{
                    indexTagView = index
                    break
                }
            }
            if indexTagView >= 0,indexTagView<self.viewList.count{
                self.viewList.remove(at: indexTagView)
            }
        }
        return view
    }
    deinit {
        self.viewList.forEach { view in
            view._wrapView?.removeFromSuperview()
            view._view.removeFromSuperview()
        }
        self.viewList.removeAll()
    }
    var _registrar:FlutterPluginRegistrar!
    init(registrar:FlutterPluginRegistrar){
        super.init()
        _registrar = registrar
        let channel = FlutterMethodChannel(name: "flutter_vap_controller", binaryMessenger: registrar.messenger())
        channel.setMethodCallHandler {[weak self] cell, result in
            guard let `self` = self else { return }
            self.viewList.forEach { view in
                view.changeVAP(cell)
            }
        }
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
}
class FlutterVapVew:NSObject,FlutterPlatformView, HWDMP4PlayDelegate {
    var deinitBlock:(()->())?
    var _view:UIView = UIView()
    var _registrar:FlutterPluginRegistrar?
    var _wrapView:QGVAPWrapView?
    var _result:FlutterResult?
    //播放中就是ture，其他状态false
    var playStatus:Bool = false
    var locationPath:String?
    var args:[String:Any]?
    var playNum:Int = -1
    deinit {
        self.deinitBlock?()
    }
    func view() -> UIView {
        _view
    }
    init(frame:CGRect,viewId:Int64,args:Any?,registrar:FlutterPluginRegistrar){
        super.init()
        _view.frame = frame
        _registrar = registrar
        self.args = args as? [String:Any] ?? [:]
        if let args = self.args, let path = args["path"] as? String {
            ///如果有path则自动播放
            self.playByPath(path)
        }
        // NotificationCenter.default.addObserver(self, selector: #selector(flutterWillBack), name: Notification.Name("FLUTTER_SCENE_WILL_APPEAR"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(flutterWillBack), name: Notification.Name("FLUTTER_SCENE_CHANNEL_NOTICE"), object: nil)
    }
    func channelNotice(note: Notification){
        guard let infoObjc = note.object as? [String:Any],
              let cell = infoObjc["cell"] as? FlutterMethodCall
        else { return }
        if let id = infoObjc["id"] as? String{
            
        }
        self.changeVAP(cell)
    }
    func changeVAP(_ cell:FlutterMethodCall){
        
        guard let arguments = cell.arguments as? [String:Any] else { return }
        if let id = arguments["id"] as? String,let nowId = self.args?["id"] as? String,nowId != id{
            //            print("FlutterVapPlugin ID不一样")
            return
        }
        
        if let isRepeat = self.args?["isRepeat"] as? Bool{
            self.playNum = isRepeat == true ? -1 : 1
        }
        if cell.method == "playPath", let path = arguments["path"] as? String{
            self.playByPath(path)
            return
        }
        if cell.method == "playAsset",
           let asset = arguments["asset"] as? String,
           let assetPath = _registrar?.lookupKey(forAsset: asset),
           let path = Bundle.main.path(forResource: assetPath, ofType: nil){
            self.playByPath(path)
            return
        }
        if cell.method == "stop"{
            if let _wrapView = _wrapView {
                _wrapView.removeFromSuperview()
            }
            self.playStatus = false
            return
        }
        
    }
    
    
    func playByPath(_ path:String,_ number:Int = 0){
        let address = "\(Unmanaged.passUnretained(self).toOpaque())"
        //        if _view.height == 0 {
        //            if number == 5{
        //                return
        //            }
        //            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(1)){[weak self] in
        //                DispatchQueue.main.async {
        //                    self?.playByPath(path,number+1)
        //                }
        //            }
        //             return
        //        }
        if playStatus{
            return
        }
        playStatus = true
        _wrapView?.stopHWDMP4()
        if let _wrapView = _wrapView {
            _wrapView.removeFromSuperview()
        }
        //        playNum = 1
        locationPath = path
        _wrapView = QGVAPWrapView.init(frame: _view.bounds)
        _wrapView?.center = _view.center
        _wrapView?.contentMode = .aspectFit
        _wrapView?.autoDestoryAfterFinish = true
        _view.addSubview(_wrapView!)
        _wrapView?.playHWDMP4(path, repeatCount: self.playNum, delegate: self)
        
    }
    @objc func flutterWillBack(note: Notification){
        //        guard let infoObjc = note.object as? [String:Any],
        //              let address = infoObjc["address"] as? String,
        //              let topVC = UIApplication.getTopViewController()
        //                else { return }
        //        var nowAddress = ""
        //        if let topVC = topVC as? PersonalCenterScene,let fluttreVc = topVC.flutterViewController{
        //            nowAddress = "\(Unmanaged.passUnretained(fluttreVc).toOpaque())"
        //        }else if let topVC = topVC as? FlutterBasicScane{
        //            nowAddress = "\(Unmanaged.passUnretained(topVC).toOpaque())"
        //        }else if let topVC = topVC as? FlutterRechargeScene ,let fluttreVc = topVC.flutterViewController{
        //            nowAddress = "\(Unmanaged.passUnretained(fluttreVc).toOpaque())"
        //        }
        playStatus = false
        //        if nowAddress == address ,let locationPath = locationPath{
        //             playByPath(locationPath)
        //        }
    }
    
    //    vapWrap_viewshouldStartPlayMP4
    func vapWrap_viewshouldStartPlayMP4(_ container: UIView, config: QGVAPConfigModel) -> Bool {
        //        print("vap 调试 vapWrap_viewshouldStartPlayMP4 \(_view.bounds)")
        return true
    }
    func vapWrap_viewDidStartPlayMP4(_ container: UIView) {
        //        print("vap 调试 vapWrap_viewDidStartPlayMP4 \(container.bounds)")
        playStatus = true
    }
    func vapWrap_viewDidStopPlayMP4(_ lastFrameIndex: Int, view container: UIView) {
        //        print("vap 调试 vapWrap_viewDidStopPlayMP4")
        playStatus = false
    }
    
    func vapWrap_viewDidFinishPlayMP4(_ totalFrameCount: Int, view container: UIView) {
        DispatchQueue.main.async {
            if self.playNum == 1{
                self._wrapView?.removeFromSuperview()
                self._view.removeFromSuperview()
            }
        }
    }
}



