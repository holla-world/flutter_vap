import 'dart:async';
import 'package:flutter/services.dart';

class VapController {
  static const MethodChannel _channel = MethodChannel('flutter_vap_controller');

  static Future<Map<dynamic, dynamic>?> playPath(String path,
      {String? id}) async {
    var arguments = {"path": path};
    if (id != null) {
      arguments['id'] = id;
    }
    return _channel.invokeMethod('playPath', arguments).then((value) {
      if (value == null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _channel.invokeMethod('playPath', arguments);
        });
      }
    });
  }

  static Future<Map<dynamic, dynamic>?> playAsset(String asset) {
    return _channel.invokeMethod('playAsset', {"asset": asset});
  }

  static stop({String? id}) {
    var arguments = {"id": id};
    _channel.invokeMethod('stop', arguments);
  }
}
