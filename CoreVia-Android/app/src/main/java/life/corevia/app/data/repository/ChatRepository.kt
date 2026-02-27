package life.corevia.app.data.repository

import life.corevia.app.data.model.ChatConversation
import life.corevia.app.data.model.ChatMessage
import life.corevia.app.data.model.ChatMessageCreate
import life.corevia.app.data.model.MessageLimitResponse
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ChatRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun getConversations(): NetworkResult<List<ChatConversation>> {
        return try {
            val response = apiService.getConversations()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Söhbətlər yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun getChatHistory(userId: String): NetworkResult<List<ChatMessage>> {
        return try {
            val response = apiService.getChatHistory(userId)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Mesajlar yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun sendMessage(receiverId: String, message: String): NetworkResult<ChatMessage> {
        return try {
            val response = apiService.sendMessage(ChatMessageCreate(receiverId, message))
            if (response.isSuccessful) {
                NetworkResult.Success(response.body()!!)
            } else {
                NetworkResult.Error("Mesaj göndərilə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun getMessageLimit(): NetworkResult<MessageLimitResponse> {
        return try {
            val response = apiService.getMessageLimit()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: MessageLimitResponse())
            } else {
                NetworkResult.Error("Limit yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
