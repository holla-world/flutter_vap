package com.nell.flutter_vap

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * @author bezier
 * @date 2024/4/19 19:24
 * @version 1.0
 * @description:
 */
object VapManager {
    private const val maxConcurrentAnimations = 5  // 设备支持的最大并发解码数
    private val animationQueue = ArrayDeque<suspend () -> Unit>()
    private val currentAnimations = mutableListOf<String>()

    fun enqueueAnimation(call: suspend () -> Unit) {
        animationQueue.add { call.invoke() }
        if (currentAnimations.size < maxConcurrentAnimations) {
            CoroutineScope(Dispatchers.Main).launch {
                animationQueue.removeFirstOrNull()?.invoke()
            }
        }
    }

    fun add(id: String) {
        currentAnimations.add(id)
    }

    fun remove(id:String){
        currentAnimations.remove(id)
    }

    fun checkAndStartNextAnimation() {
        if (currentAnimations.size < maxConcurrentAnimations && animationQueue.isNotEmpty()) {
            CoroutineScope(Dispatchers.Main).launch {
                animationQueue.removeFirstOrNull()?.invoke()
            }
        }
    }
}