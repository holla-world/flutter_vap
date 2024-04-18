import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vap/scale_type.dart';

class VapViewForIos extends StatelessWidget {
  final int scaleType;
  final String? id;
  final bool isRepeat;
  final String? path;

  const VapViewForIos({
    super.key,
    this.scaleType = ScaleType.fitCenter,
    this.id,
    this.isRepeat = true,
    this.path,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    creationParams['scaleType'] = scaleType;
    if (id != null) {
      creationParams['id'] = id;
    }
    if (path != null) {
      creationParams['path'] = path;
    }
    creationParams['isRepeat'] = isRepeat;
    return UiKitView(
      viewType: "flutter_vap",
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
