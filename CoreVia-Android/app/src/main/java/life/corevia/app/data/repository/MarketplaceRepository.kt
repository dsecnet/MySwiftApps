package life.corevia.app.data.repository

import life.corevia.app.data.model.CreateReviewRequest
import life.corevia.app.data.model.CreateProductRequest
import life.corevia.app.data.model.MarketplaceProduct
import life.corevia.app.data.model.ProductReview
import life.corevia.app.data.model.ProductsResponse
import life.corevia.app.data.remote.ApiService
import life.corevia.app.util.NetworkResult
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class MarketplaceRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun getProducts(
        productType: String? = null,
        page: Int = 1,
        limit: Int = 20
    ): NetworkResult<ProductsResponse> {
        return try {
            val response = apiService.getMarketplaceProducts(
                productType = productType,
                page = page,
                limit = limit
            )
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: ProductsResponse())
            } else {
                NetworkResult.Error("Məhsullar yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun getProduct(productId: String): NetworkResult<MarketplaceProduct> {
        return try {
            val response = apiService.getMarketplaceProduct(productId)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: MarketplaceProduct())
            } else {
                NetworkResult.Error("Məhsul tapılmadı", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun getProductReviews(productId: String): NetworkResult<List<ProductReview>> {
        return try {
            val response = apiService.getProductReviews(productId)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Rəylər yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun createReview(productId: String, request: CreateReviewRequest): NetworkResult<ProductReview> {
        return try {
            val response = apiService.createProductReview(productId, request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: ProductReview())
            } else {
                NetworkResult.Error("Rəy əlavə edilə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun createProduct(request: CreateProductRequest): NetworkResult<MarketplaceProduct> {
        return try {
            val response = apiService.createMarketplaceProduct(request)
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: MarketplaceProduct())
            } else {
                NetworkResult.Error("Məhsul yaradıla bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun getMyProducts(): NetworkResult<List<MarketplaceProduct>> {
        return try {
            val response = apiService.getMyMarketplaceProducts()
            if (response.isSuccessful) {
                NetworkResult.Success(response.body() ?: emptyList())
            } else {
                NetworkResult.Error("Məhsullar yüklənə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }

    suspend fun deleteProduct(productId: String): NetworkResult<Unit> {
        return try {
            val response = apiService.deleteMarketplaceProduct(productId)
            if (response.isSuccessful) {
                NetworkResult.Success(Unit)
            } else {
                NetworkResult.Error("Məhsul silinə bilmədi", response.code())
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "Şəbəkə xətası")
        }
    }
}
