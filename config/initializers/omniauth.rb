# OAuth 2.0 Configuration with PKCE Security
# 
# PKCE (Proof Key for Code Exchange) is automatically implemented by Auth0
# to prevent authorization code interception attacks. Here's how it works:
#
# 1. Client generates random 'code_verifier' (43-128 characters)
# 2. Client creates 'code_challenge' = SHA256(code_verifier)
# 3. Authorization request includes code_challenge (NOT the verifier)
# 4. Auth0 returns authorization code as usual
# 5. Token exchange includes BOTH code AND original code_verifier
# 6. Auth0 verifies SHA256(code_verifier) == stored code_challenge
#
# Security Benefit: Even if authorization code is intercepted, attacker
# cannot exchange it without the original code_verifier, which never
# leaves the client application.

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    ENV["AUTH0_CLIENT_ID"],
    ENV["AUTH0_CLIENT_SECRET"], 
    ENV["AUTH0_DOMAIN"],
    callback_path: "/auth/auth0/callback",
    authorize_params: {
      scope: "openid email profile" # Standard OpenID Connect scopes
    },
    token_params: {
      scope: "openid email profile"
    }
    # PKCE is automatically enabled by Auth0 - no additional config needed!
  )
end

# Security Configuration
# - Allow both POST and GET for OAuth callbacks
# - CSRF protection is handled by omniauth-rails_csrf_protection gem
OmniAuth.config.allowed_request_methods = [:post, :get]
