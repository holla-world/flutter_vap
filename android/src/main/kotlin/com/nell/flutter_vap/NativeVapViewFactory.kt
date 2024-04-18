package com.nell.flutter_vap

import android.content.Context
import android.util.ArrayMap
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlinx.coroutines.DelicateCoroutinesApi

class NativeVapViewFactory :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    @OptIn(DelicateCoroutinesApi::class)
    val viewMap = ArrayMap<Int, NativeVapView>()

    @OptIn(DelicateCoroutinesApi::class)
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        Log.d("NativeVapView", "NativeVapViewFactory create")
        val nativeVapView = NativeVapView(context, viewId, creationParams)
        nativeVapView.onDispose = {
            viewMap.remove(viewId)
        }
        viewMap[viewId] = nativeVapView
        return nativeVapView

    }

    @OptIn(DelicateCoroutinesApi::class)
    fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        for (view in viewMap.values) {
            view.onMethodCall(call, result)
        }
    }
}