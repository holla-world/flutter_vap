import 'dart:io';

import 'package:flutter/widgets.dart';
import 'vap_view_for_android.dart';
import 'vap_view_for_ios.dart';

import 'scale_type.dart';

class VapView extends StatelessWidget {
  final int scaleType;

  final String? uniqueId;

  final bool isRepeat;

  const VapView({
    super.key,
    this.scaleType = ScaleType.fitCenter,
    this.uniqueId,
    this.isRepeat = true,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return VapViewForAndroid(
        scaleType: scaleType,
        id: uniqueId,
        isRepeat: isRepeat,
      );
    } else if (Platform.isIOS) {
      return VapViewForIos(
        scaleType: scaleType,
        id: uniqueId,
        isRepeat: isRepeat,
      );
    }
    return Container();
  }
}
