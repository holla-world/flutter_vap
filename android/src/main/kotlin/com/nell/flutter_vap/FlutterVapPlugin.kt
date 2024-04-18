package com.nell.flutter_vap

import android.util.Log
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterVapPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var nativeVapViewFactory: NativeVapViewFactory

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_vap_controller")
        channel.setMethodCallHandler(this)
        Log.d("NativeVapView", "onAttachedToEngine")
        nativeVapViewFactory = NativeVapViewFactory()
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "flutter_vap",
            nativeVapViewFactory
        )

    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            else -> {
                if (this::nativeVapViewFactory.isInitialized) {
                    nativeVapViewFactory.onMethodCall(call, result)
                }
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        if (this::channel.isInitialized) {
            channel.setMethodCallHandler(null)
        }
    }
}
