package com.example.nowbar_flutter_example

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private companion object {
        const val METHOD_CHANNEL = "nowbar/live_timer"
        const val CHANNEL_ID = "nowbar_timer"
        const val CHANNEL_NAME = "타이머"
        const val NOTIFICATION_ID = 4201
        const val EXTRA_REQUEST_PROMOTED = "android.requestPromotedOngoing"
        const val SEGMENT_COLOR = 0xFF503164.toInt()
        val LEGACY_EXPERIMENT_IDS = intArrayOf(4101, 4102)
    }

    private val notificationManager: NotificationManager
        get() = getSystemService(NotificationManager::class.java)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        LEGACY_EXPERIMENT_IDS.forEach(notificationManager::cancel)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val seconds = call.argument<Int>("seconds") ?: 0
                    val totalSeconds = call.argument<Int>("totalSeconds") ?: seconds
                    startTimer(seconds, totalSeconds)
                    result.success(null)
                }

                "stop" -> {
                    notificationManager.cancel(NOTIFICATION_ID)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun startTimer(seconds: Int, totalSeconds: Int) {
        ensureChannel()

        val endAt = System.currentTimeMillis() + seconds * 1000L
        val segmentLength = if (totalSeconds > 0) totalSeconds else seconds

        val style = Notification.ProgressStyle()
            .setStyledByProgress(false)
            .setProgressSegments(
                listOf(
                    Notification.ProgressStyle.Segment(segmentLength).setColor(SEGMENT_COLOR)
                )
            )

        val builder = Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("타이머")
            .setContentText("종료까지 남은 시간")
            .setShortCriticalText("타이머")
            .setStyle(style)
            .setOngoing(true)
            .setShowWhen(true)
            .setWhen(endAt)
            .setUsesChronometer(true)
            .setChronometerCountDown(true)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setCategory(Notification.CATEGORY_STOPWATCH)

        builder.extras.putBoolean(EXTRA_REQUEST_PROMOTED, true)

        notificationManager.notify(NOTIFICATION_ID, builder.build())
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        if (notificationManager.getNotificationChannel(CHANNEL_ID) != null) {
            return
        }
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH
        ).apply { lockscreenVisibility = Notification.VISIBILITY_PUBLIC }
        notificationManager.createNotificationChannel(channel)
    }
}
