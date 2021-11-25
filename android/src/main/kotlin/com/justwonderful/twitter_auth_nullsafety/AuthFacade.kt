package com.justwonderful.twitter_auth_nullsafety

import android.annotation.SuppressLint
import android.app.Activity
import android.os.Build
import android.util.Log
import android.webkit.CookieManager
import android.webkit.CookieSyncManager
import com.twitter.sdk.android.core.*
import com.twitter.sdk.android.core.TwitterCore
import com.twitter.sdk.android.core.identity.TwitterAuthClient

class TwitterAuthFacade private constructor(
    private val activity: Activity,
    private val response: ITwitterAuthFacade,
    private val token: String, private val secret: String
) : Callback<TwitterSession>() {
    lateinit var authClient: TwitterAuthClient
    private var withEmail: Boolean = false

    companion object {
        @SuppressLint("StaticFieldLeak")
        @Volatile
        private var instance_: TwitterAuthFacade? = null

        fun instance(
            activity: Activity,
            response: ITwitterAuthFacade,
            apiToken: String, apiTokenSecret: String
        ): TwitterAuthFacade {
            val checkInstance = instance_
            if (checkInstance != null) {
                return checkInstance
            }

            return synchronized(this) {
                val checkInstanceAgain = instance_
                if (checkInstanceAgain != null) {
                    checkInstanceAgain
                } else {
                    val created = TwitterAuthFacade(
                        activity, response, apiToken, apiTokenSecret
                    )

                    created.configureClient()

                    instance_ = created
                    created
                }
            }
        }
    }

    private fun configureClient() {
        val authConfig = TwitterAuthConfig(token, secret)

        val config = TwitterConfig.Builder(activity.applicationContext)
            .logger(DefaultLogger(Log.DEBUG))
            .twitterAuthConfig(authConfig)
            .debug(true)
            .build()

        Twitter.initialize(config)

        authClient = TwitterAuthClient()
    }

    fun login(requestEmail: Boolean? = null) {
        requestEmail?.let { withEmail = it }
        try {
            authClient.authorize(activity, this)
        } catch (ex: TwitterAuthException) {
            throw AuthException(ex.message, ex.stackTrace)
        } catch (ex: TwitterException) {
            throw AuthException(ex.message, ex.stackTrace)
        }
    }

    fun logout() {
        val cookieManager = CookieManager.getInstance()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP)
            CookieSyncManager.createInstance(activity.applicationContext)
        cookieManager.setAcceptCookie(true)

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP)
            cookieManager.removeSessionCookie()
        else cookieManager.removeSessionCookies {
            Log.i("TwitterAuth2Plugin: ", "Remove session cookies -> $it")
        }

//        configureClient()
        TwitterCore.getInstance().sessionManager.clearActiveSession()
    }

    fun currentSession(): TwitterAuthResult {
        try {
            val twitterSession = TwitterCore.getInstance().sessionManager.activeSession
            return when {
                twitterSession != null -> {
                    return buildAuthResult(
                        isSuccessful = true,
                        session = twitterSession,
                    )
                }
                else -> TwitterAuthResult.build(false) {}
            }
        } catch (ex: TwitterAuthException) {
            throw AuthException(ex.message, ex.stackTrace)
        } catch (ex: TwitterException) {
            throw AuthException(ex.message, ex.stackTrace)
        }
    }

    override fun success(result: Result<TwitterSession>?) {
        if (result?.data != null && withEmail)
            try {
                authClient.requestEmail(result.data, object : Callback<String>() {
                    override fun success(value: Result<String>?) {
                        Log.i("AuthFacade: ", "Email ==> ${value?.data}")

                        response.success(
                            buildAuthResult(
                                isSuccessful = result.response?.isSuccessful,
                                session = result.data,
                                emailAddress = value?.data
                            )
                        )
                    }

                    override fun failure(exception: TwitterException?) {
                        Log.e("AuthFacade: ", "Error ==> ${exception?.message}\n")

                        response.failure(
                            AuthException(
                                exception?.message,
                                exception?.stackTrace
                            )
                        )
                    }
                })
            } catch (ex: TwitterAuthException) {
                response.failure(
                    AuthException(
                        ex.message,
                        ex.stackTrace
                    )
                )
            } catch (ex: TwitterException) {
                response.failure(
                    AuthException(
                        ex.message,
                        ex.stackTrace
                    )
                )
            }
        else
            response.success(
                buildAuthResult(
                    isSuccessful = result?.response?.isSuccessful,
                    session = result?.data,
                )
            )
    }

    override fun failure(exception: TwitterException?) {
        response.failure(
            AuthException(
                exception?.message,
                exception?.stackTrace
            )
        )
    }

    private fun buildAuthResult(
        emailAddress: String? = null,
        session: TwitterSession?,
        isSuccessful: Boolean?
    ): TwitterAuthResult {
        return TwitterAuthResult.build(isSuccessful ?: false) {
            id = session?.id.toString()
            userId = session?.userId.toString()
            username = session?.userName
            email = emailAddress
            authToken = session?.authToken?.token
            authSecret = session?.authToken?.secret
        }
    }
}

interface ITwitterAuthFacade {
    fun success(result: TwitterAuthResult?)
    fun failure(exception: AuthException?)
}

class TwitterAuthResult private constructor(
    val id: String?, val userId: String?,
    val username: String?, val email: String?,
    val authToken: String?, val authSecret: String?,
    val status: Boolean,
) {
    private constructor(builder: Builder) : this(
        builder.id,
        builder.userId, builder.username, builder.email,
        builder.authToken, builder.authSecret,
        builder.status
    )

    companion object {
        inline fun build(status: Boolean, block: Builder.() -> Unit): TwitterAuthResult =
            Builder(status).apply(block).build()
    }

    class Builder(var status: Boolean) {
        var id: String? = null
        var userId: String? = null
        var username: String? = null
        var email: String? = null
        var authToken: String? = null
        var authSecret: String? = null

        fun build() = TwitterAuthResult(this)
    }

    fun toMap(): HashMap<String?, String?> {
        return object : HashMap<String?, String?>() {
            init {
                put("id", id)
                put("user_id", userId)
                put("username", username)
                put("email", email)
                put("auth_token", authToken)
                put("auth_secret", authSecret)
                put("status", "$status")
            }
        }
    }
}

class AuthException(
    override val message: String?,
    val trace: Array<StackTraceElement>?
) : Exception(message)
