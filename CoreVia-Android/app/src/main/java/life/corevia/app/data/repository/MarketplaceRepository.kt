package life.corevia.app.data.repository

import android.content.Context
import life.corevia.app.data.api.ApiClient
import life.corevia.app.data.models.*

class MarketplaceRepository(context: Context) {

    private val api = ApiClient.getInstance(context).api

    suspend fun getProducts(): Result<List<Product>> {
        return try {
            Result.success(api.getProducts())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getProduct(productId: String): Result<Product> {
        return try {
            Result.success(api.getProduct(productId))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createOrder(request: CreateOrderRequest): Result<Order> {
        return try {
            Result.success(api.createOrder(request))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getOrders(): Result<List<Order>> {
        return try {
            Result.success(api.getOrders())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    companion object {
        @Volatile private var instance: MarketplaceRepository? = null
        fun getInstance(context: Context): MarketplaceRepository =
            instance ?: synchronized(this) {
                instance ?: MarketplaceRepository(context.applicationContext).also { instance = it }
            }
        fun clearInstance() { instance = null }
    }
}
