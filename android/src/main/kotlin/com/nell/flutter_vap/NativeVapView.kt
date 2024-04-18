package com.nell.flutter_vap

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import com.tencent.qgame.animplayer.AnimConfig
import com.tencent.qgame.animplayer.AnimView
import com.tencent.qgame.animplayer.inter.IAnimListener
import com.tencent.qgame.animplayer.util.ScaleType
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import kotlinx.coroutines.DelicateCoroutinesApi
import java.io.File


@DelicateCoroutinesApi
class NativeVapView(
    private val context: Context,
    id: Int,
    private val creationParams: Map<String?, Any?>?
) : MethodChannel.MethodCallHandler, PlatformView {
    private val mContext: Context = context

    private var vapView: AnimView? = null

    private val container = FrameLayout(context)

    private var uniqueId: String? = null

    var onDispose: (() -> Unit)? = null

    private var isRunning = false

    private var maxRetryTime = 2
    private var retryTime = 0

    private val tempPath: StringBuffer = StringBuffer()

    private val mHandler = Handler(Looper.getMainLooper())


    init {

        uniqueId = creationParams?.get("id")?.toString()
        val path = creationParams?.get("path")?.toString()
        Log.d("NativeVapView", "初始化NativeVapView：uniqueId=$uniqueId,path=$path")

        container.setBackgroundColor(Color.TRANSPARENT)
        vapView = createVapView()
        if (path != null) {
            tempPath.delete(0, tempPath.length)
            tempPath.append(path)
            vapView?.startPlay(File(path))
            isRunning = true
        }
    }

    private fun createVapView(): AnimView {
        val layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )

        val vapView = AnimView(context)

        vapView.layoutParams = layoutParams
        container.addView(vapView)


        when (creationParams?.get("scaleType")) {
            1 -> {
                vapView.setScaleType(ScaleType.FIT_XY)
            }

            2 -> {
                vapView.setScaleType(ScaleType.CENTER_CROP)
            }

            else -> {
                vapView.setScaleType(ScaleType.FIT_CENTER)
            }
        }

        if (creationParams?.get("isRepeat") != false) {
            vapView.setLoop(Int.MAX_VALUE)
        }
        vapView.setAnimListener(object : IAnimListener {
            override fun onFailed(errorType: Int, errorMsg: String?) {
                //                GlobalScope.launch(Dispatchers.Main) {
                //                    methodResult?.success(HashMap<String, String>().apply {
                //                        put("status", "failure")
                //                        put("errorMsg", errorMsg ?: "unknown error")
                //                    })
                //
                //                }
                Log.d(
                    "NativeVapView",
                    "${uniqueId}onFailed,errorType=${errorType},errorMsg=${errorMsg}"
                )
                mHandler.postDelayed({
                    isRunning = false
                    if (retryTime < maxRetryTime && tempPath.isNotEmpty()) {
                        Log.d(
                            "NativeVapView",
                            "${uniqueId}失败重试,retryTime=${retryTime},tempPath=${tempPath}"
                        )
                        vapView.stopPlay()
                        destroyVapView(vapView)
                        this@NativeVapView.vapView = createVapView()
                        this@NativeVapView.vapView?.startPlay(File(tempPath.toString()))
                        isRunning = true
                        retryTime = retryTime.inc()
                    }
                }, 1000)

            }

            override fun onVideoConfigReady(config: AnimConfig): Boolean {
                Log.d("NativeVapView", "onVideoConfigReady")
                return true
            }

            override fun onVideoComplete() {
                //                GlobalScope.launch(Dispatchers.Main) {
                //                    methodResult?.success(HashMap<String, String>().apply {
                //                        put("status", "complete")
                //                    })
                //                }
                Log.d("NativeVapView", "onVideoComplete")
                isRunning = false
            }

            override fun onVideoDestroy() {
                Log.d("NativeVapView", "onVideoDestroy,uniqueId=$uniqueId")
                isRunning = false

            }

            override fun onVideoRender(frameIndex: Int, config: AnimConfig?) {
                //                Log.d("NativeVapView", "onVideoRender")
            }

            override fun onVideoStart() {
                Log.d("NativeVapView", "onVideoStart,uniqueId=$uniqueId,retryTime=$retryTime")
                isRunning = true
                retryTime = 0
            }

        })
        return vapView
    }

    private fun destroyVapView(vapView: AnimView) {
        vapView.setAnimListener(null)
        container.removeView(vapView)
        this.vapView = null
    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        Log.d("NativeVapView", "vap通道销毁,uniqueId=$uniqueId")
        onDispose?.invoke()
        tempPath.delete(0, tempPath.length)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "playPath" -> {
                call.argument<String>("path")?.let {
                    val id = call.argument<String>("id")
                    if (uniqueId == id && !isRunning) {
                        mHandler.post {
                            Log.d("NativeVapView", "playPath,id=$id,uniqueId=$uniqueId")
                            if (vapView == null) {
                                vapView = createVapView()
                            }
                            tempPath.delete(0, tempPath.length)
                            tempPath.append(it)
                            vapView?.startPlay(File(it))
                            isRunning = true
                        }
                    }
                }
            }

            "playAsset" -> {
                call.argument<String>("asset")?.let {
                    vapView?.startPlay(mContext.assets, "flutter_assets/$it")
                }
            }

            "stop" -> {
                val id = call.argument<String>("id")
                if (isRunning && id == uniqueId) {
                    Log.d("NativeVapView", "停止播放uniqueId=$uniqueId")
                    vapView?.stopPlay()
                    isRunning = false
                }
            }
        }
    }


}