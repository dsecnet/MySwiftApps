package life.corevia.app.data.remote

import life.corevia.app.data.local.TokenManager
import okhttp3.Authenticator
import okhttp3.Request
import okhttp3.Response
import okhttp3.Route
import javax.inject.Inject

class TokenRefreshAuthenticator @Inject constructor(
    private val tokenManager: TokenManager
) : Authenticator {
    override fun authenticate(route: Route?, response: Response): Request? {
        if (response.request.header("Authorization-Retry") != null) {
            tokenManager.clearAll()
            return null
        }
        tokenManager.clearAll()
        return null
    }
}
