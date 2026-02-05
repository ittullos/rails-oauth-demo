class AuthController < ApplicationController
  # OAuth 2.0 + PKCE Authentication Flow Handler
  # 
  # This controller handles the secure OAuth 2.0 Authorization Code Flow with PKCE:
  # 1. User clicks login → redirected to Auth0 (with PKCE challenge)
  # 2. User authenticates → Auth0 redirects back with authorization code
  # 3. callback() method receives code and exchanges it for tokens (with PKCE verification)
  # 4. Store user info securely in session
  
  def callback
    # PKCE Security: By the time we reach this callback, Auth0 has already:
    # - Verified the authorization code is valid
    # - Verified the code_verifier matches the code_challenge
    # - Confirmed no authorization code interception occurred
    # - Exchanged the code for ID/access tokens
    
    # Extract the full OAuth response from Omniauth
    auth_info = request.env["omniauth.auth"]

    # Verify the response exists
    unless auth_info
      redirect_to root_path, alert: "Authentication failed: No auth info received"
      return
    end

    # Extract credentials (includes ID token, access token, etc.)
    credentials = auth_info["credentials"]
    id_token = credentials&.dig("id_token")
    access_token = credentials&.dig("token")

    # Extract user info from Auth0 response
    user_info = auth_info["info"] || {}
    extra_info = auth_info["extra"] || {}

    # Extract additional claims from the raw_info (ID token claims)
    raw_info = extra_info["raw_info"] || {}

    # Store comprehensive user information in session
    session[:user_info] = {
      # Basic OAuth info
      uid: auth_info["uid"],
      provider: auth_info["provider"],

      # User profile information
      name: user_info["name"],
      email: user_info["email"],
      nickname: user_info["nickname"],
      picture: user_info["image"],

      # ID Token claims (additional Auth0 user metadata)
      given_name: raw_info["given_name"],
      family_name: raw_info["family_name"],
      locale: raw_info["locale"],
      email_verified: raw_info["email_verified"],
      updated_at: raw_info["updated_at"],

      # Authentication metadata
      sub: raw_info["sub"], # Auth0 user ID
      aud: raw_info["aud"], # Audience (your client ID)
      iss: raw_info["iss"], # Issuer (Auth0 domain)
      iat: raw_info["iat"], # Issued at timestamp
      exp: raw_info["exp"],  # Expiration timestamp

      # Store token info securely - use ISO string for proper serialization
      authenticated_at: Time.current.iso8601,
      session_id: session.id
    }

    # Store tokens securely (optional - be careful with token storage)
    session[:tokens] = {
      id_token_present: id_token.present?,
      access_token_present: access_token.present?,
      token_type: credentials&.dig("token_type"),
      expires_at: credentials&.dig("expires_at")
    }

    Rails.logger.info "User #{session[:user_info][:email]} authenticated successfully"

    # Redirect to protected page or where they came from
    redirect_path = session.delete(:redirect_after_login) || protected_path
    redirect_to redirect_path, notice: "Successfully authenticated!"

  rescue => e
    Rails.logger.error "Authentication callback error: #{e.message}"
    redirect_to root_path, alert: "Authentication failed. Please try again."
  end

  def login
    # Initiate OAuth 2.0 Authorization Code Flow with PKCE
    # 
    # When redirecting to /auth/auth0, Omniauth automatically:
    # 1. Generates a random code_verifier (43-128 char string)
    # 2. Creates code_challenge = SHA256(code_verifier) 
    # 3. Redirects to Auth0 with code_challenge (NOT verifier)
    # 4. Auth0 will redirect back with authorization code
    # 5. On callback, will send BOTH code AND code_verifier for verification
    #
    # PKCE prevents attacks where authorization codes are intercepted
    # because the code_verifier never appears in URLs or network traffic
    redirect_to "/auth/auth0", allow_other_host: true
  end

  def logout
    # Clear the session
    session.clear

    # Construct Auth0 logout URL
    domain = ENV["AUTH0_DOMAIN"]
    client_id = ENV["AUTH0_CLIENT_ID"]
    return_to = CGI.escape(root_url)

    logout_url = "https://#{domain}/v2/logout?client_id=#{client_id}&returnTo=#{return_to}"

    redirect_to logout_url, allow_other_host: true
  end

  def failure
    # Handle authentication failure
    redirect_to root_path, alert: "Authentication failed. Please try again."
  end
end
