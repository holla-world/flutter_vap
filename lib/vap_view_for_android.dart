import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'scale_type.dart';

class VapViewForAndroid extends StatelessWidget {
  final int scaleType;
  final String? id;
  final bool isRepeat;

  const VapViewForAndroid({
    super.key,
    this.scaleType = ScaleType.fitCenter,
    this.id,
    this.isRepeat = true,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    creationParams['scaleType'] = scaleType;
    if (id != null) {
      creationParams['id'] = id;
    }
    creationParams['isRepeat'] = isRepeat;
    return AndroidView(
      viewType: "flutter_vap",
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
