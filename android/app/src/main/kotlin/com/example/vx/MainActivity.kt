package com.example.vx

import android.app.ActivityManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

import io.flutter.view.TextureRegistry
import android.graphics.SurfaceTexture
import android.view.Surface

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.vx/performance"
    private val VIDEO_CHANNEL = "com.example.vx/video_texture"
    private val textures = mutableMapOf<Long, TextureRegistry.SurfaceTextureEntry>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getMemoryInfo" -> {
                    result.success(getMemoryInfo())
                }
                "clearNativeCache" -> {
                    result.success(clearCache())
                }
                "optimizeMemory" -> {
                    System.gc()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VIDEO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "createTexture" -> {
                    val entry = flutterEngine.renderer.createSurfaceTexture()
                    val textureId = entry.id()
                    textures[textureId] = entry
                    result.success(textureId)
                }
                "disposeTexture" -> {
                    val textureId = call.argument<Long>("textureId")
                    textures.remove(textureId)?.release()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getMemoryInfo(): Map<String, Any> {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfo)

        return mapOf(
            "availMem" to memoryInfo.availMem,
            "totalMem" to memoryInfo.totalMem,
            "threshold" to memoryInfo.threshold,
            "lowMemory" to memoryInfo.lowMemory
        )
    }

    private fun clearCache(): Boolean {
        return try {
            val cacheDir = cacheDir
            deleteDir(cacheDir)
        } catch (e: Exception) {
            false
        }
    }

    private fun deleteDir(dir: File?): Boolean {
        if (dir != null && dir.isDirectory) {
            val children = dir.list()
            if (children != null) {
                for (i in children.indices) {
                    val success = deleteDir(File(dir, children[i]))
                    if (!success) {
                        return false
                    }
                }
            }
            return dir.delete()
        } else if (dir != null && dir.isFile) {
            return dir.delete()
        } else {
            return false
        }
    }
}
