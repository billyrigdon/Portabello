package com.example.portabello

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.IOException
import java.net.InetSocketAddress
import java.net.Socket

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.portabello/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "scanPorts") {
                val ipAddress = call.argument<String>("ipAddress")
                val startPort = call.argument<Int>("startPort")
                val endPort = call.argument<Int>("endPort")

                CoroutineScope(Dispatchers.IO).launch {
                    val scanResult = scanPorts(ipAddress, startPort, endPort)
                    withContext(Dispatchers.Main) {
                        result.success(scanResult)
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun scanPorts(ipAddress: String?, startPort: Int?, endPort: Int?): String {
        val openPorts = mutableListOf<Int>()

        for (port in startPort!!..endPort!!) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                    Socket().use { socket ->
                        socket.connect(InetSocketAddress(ipAddress, port), 200) // 200ms timeout
                        openPorts.add(port)
                    }
                }
            } catch (e: IOException) {
                // Port is closed or not reachable
            }
        }

        return openPorts.joinToString(separator = ", ")
    }
}

