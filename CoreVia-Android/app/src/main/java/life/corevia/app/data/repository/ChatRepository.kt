package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*

/**
 * iOS ChatManager.swift-in Android Repository ekvivalenti.
 */
class ChatRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    suspend fun getConversations(): Result<List<Conversation>> {
        return try {
            Result.success(api.getConversations())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getChatHistory(userId: String): Result<List<ChatMessage>> {
        return try {
            Result.success(api.getChatHistory(userId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun sendMessage(request: SendMessageRequest): Result<ChatMessage> {
        return try {
            Result.success(api.sendMessage(request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getMessageLimit(): Result<MessageLimitResponse> {
        return try {
            Result.success(api.getMessageLimit())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: ChatRepository? = null
        fun getInstance(context: Context): ChatRepository =
            instance ?: synchronized(this) {
                instance ?: ChatRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
