package com.tikalk.moveshuttle

import android.content.Intent
import android.os.Bundle
import android.util.Log

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import com.google.android.gms.actions.NoteIntents

import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        const val TAG  = "MainActivity"
    }
    var savedNote: String? = null
    lateinit var channel : MethodChannel
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        Log.i(TAG, "onCreate:")

        val intent = intent
        val action = intent.action
        val type = intent.type
        Log.i(TAG, "onCreate: ${intent.action}")

//        if (NoteIntents.ACTION_CREATE_NOTE == action && type != null) {
//            if ("text/plain" == type) {
//                savedNote = intent.getStringExtra(Intent.EXTRA_TEXT)
//            }
//        }
//
//        channel = MethodChannel(flutterView, "app.channel.shared.data")
//
//        channel.setMethodCallHandler { methodCall, result ->
//            Log.i(TAG,"setMethodCallHandler: ")
//            if (methodCall.method.contentEquals("getSavedNote")) {
//                result?.success(savedNote)
//                savedNote = null
//            }
//        }
    }

}
