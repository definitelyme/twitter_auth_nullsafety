package com.justwonderful.twitter_auth_nullsafety

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import android.util.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** TwitterAuthNullsafetyPlugin */
class TwitterAuthNullsafetyPlugin : FlutterPlugin, MethodCallHandler,
    PluginRegistry.ActivityResultListener,
    ActivityAware, ITwitterAuthFacade {
    private lateinit var channel: MethodChannel
    private lateinit var _twitterLogin: TwitterAuthFacade
    private lateinit var activity: Activity
    private lateinit var context: Context

    private var pendingResult: Result? = null

    companion object {
        private const val METHOD_INSTANCE = "instance"
        private const val METHOD_GET_SESSION = "getSession"
        private const val METHOD_LOGIN = "login"
        private const val METHOD_LOGOUT = "logOut"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "twitter_auth_nullsafety")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            METHOD_INSTANCE -> {
                val arguments = call.arguments as ArrayList<*>
                val apiToken = arguments[0] as String
                val apiTokenSecret = arguments[1] as String
                if (apiToken.isNotEmpty() && apiTokenSecret.isNotEmpty()) {
                    _twitterLogin = TwitterAuthFacade.instance(
                        activity, this, apiToken, apiTokenSecret
                    )
                    //result.success(_twitterLogin)
                    result.success(null)
                } else {
                    result.error(
                        "invalid-api-keys",
                        "Invalid API Token or API Token Secret!",
                        "API Token: $apiToken, API Token Secret: $apiTokenSecret"
                    )
                }
                return
            }
            METHOD_LOGIN -> {
                setPendingResult(result)

                val arguments = call.arguments as ArrayList<*>
                val requestEmail = arguments[0] as Boolean?

                try {
                    _twitterLogin.login(requestEmail)
                } catch (ex: AuthException) {
                    result.success(exceptionToMap(ex))
                }
                return
            }
            METHOD_GET_SESSION -> {
                try {
                    val currentSession = _twitterLogin.currentSession()
                    result.success(currentSession.toMap())
                } catch (ex: AuthException) {
                    result.success(exceptionToMap(ex))
                }
                return
            }
            METHOD_LOGOUT -> {
                try {
                    _twitterLogin.logout()
                    result.success(null)
                } catch (ex: AuthException) {
                    result.success(exceptionToMap(ex))
                }
                return
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        _twitterLogin.authClient.onActivityResult(requestCode, resultCode, data)
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this)
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        //
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this)
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        //
    }

    private fun setPendingResult(result: Result) {
        if (pendingResult != null) {
            val map: HashMap<String?, Any?> = object : HashMap<String?, Any?>() {
                init {
                    put("status", "in_progress")
                    put(
                        "errorMessage", "Method 'login()' called while another Twitter " +
                                "login operation was in progress."
                    )
                }
            }
            pendingResult!!.success(map)
        }
        pendingResult = result
    }

    override fun success(result: TwitterAuthResult?) {
        if (pendingResult != null) {
            val map: HashMap<String?, Any?> = object : HashMap<String?, Any?>() {
                init {
                    put("status", "loggedIn")
                    put("session", result?.toMap())
                }
            }
            pendingResult!!.success(map)
            pendingResult = null
        }
    }

    override fun failure(exception: AuthException?) {
        if (pendingResult != null) {
            pendingResult!!.success(exceptionToMap(exception))
            pendingResult = null
        }
    }

    private fun exceptionToMap(exception: AuthException?): HashMap<String?, String?> {
        return object : HashMap<String?, String?>() {
            init {
                put("status", "failed")
                put("errorMessage", exception?.message)
            }
        }
    }
}
