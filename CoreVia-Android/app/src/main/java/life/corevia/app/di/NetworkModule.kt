package life.corevia.app.di

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import life.corevia.app.BuildConfig
import life.corevia.app.data.local.TokenManager
import life.corevia.app.data.remote.ApiService
import life.corevia.app.data.remote.AuthInterceptor
import life.corevia.app.util.Constants
import okhttp3.CertificatePinner
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import timber.log.Timber
import java.util.concurrent.TimeUnit
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideJson(): Json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
        encodeDefaults = true
    }

    @Provides
    @Singleton
    fun provideOkHttpClient(tokenManager: TokenManager): OkHttpClient {
        val builder = OkHttpClient.Builder()
            .addInterceptor(AuthInterceptor(tokenManager))
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)

        // ── SSL Certificate Pinning ──────────────────────────────────
        // api.corevia.life üçün leaf + intermediate CA pin-lər
        if (!BuildConfig.DEBUG) {
            val certificatePinner = CertificatePinner.Builder()
                .add(
                    "api.corevia.life",
                    "sha256/+HqKaqge8gUxRdJ6dHhZhpr+54rxXMm4UPbAcPzgZMA=", // Leaf cert
                    "sha256/iFvwVyJSxnQdyaUvUERIf+8qk7gRze3612JMwoO3zdU="  // Intermediate CA
                )
                .build()
            builder.certificatePinner(certificatePinner)
        }

        // ── HTTP Logging — yalnız DEBUG build-da aktiv ────────────────
        if (BuildConfig.DEBUG) {
            val loggingInterceptor = HttpLoggingInterceptor { message ->
                Timber.tag("OkHttp").d(message)
            }.apply {
                level = HttpLoggingInterceptor.Level.BODY
            }
            builder.addInterceptor(loggingInterceptor)
        }

        return builder.build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient, json: Json): Retrofit {
        val contentType = "application/json".toMediaType()
        return Retrofit.Builder()
            .baseUrl(Constants.BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(json.asConverterFactory(contentType))
            .build()
    }

    @Provides
    @Singleton
    fun provideApiService(retrofit: Retrofit): ApiService {
        return retrofit.create(ApiService::class.java)
    }
}
