package life.corevia.app.data.repository

import android.content.Context
import android.util.Log
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*

/**
 * iOS ChatManager.swift-in Android Repository ekvivalenti.
 */
class ChatRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    suspend fun getConversations(): Result<List<Conversation>> {
        return try {
            val result = api.getConversations()
            Log.d("ChatRepo", "getConversations OK: ${result.size} conversations")
            result.forEachIndexed { i, c ->
                Log.d("ChatRepo", "Conv[$i]: userId=${c.userId}, name=${c.userName}, lastMsg=${c.lastMessage}, time=${c.lastMessageTime}, unread=${c.unreadCount}")
            }
            Result.success(result)
        } catch (e: Exception) {
            Log.e("ChatRepo", "getConversations FAIL: ${e.javaClass.simpleName}: ${e.message}", e)
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
