class AuthController < ApplicationController
  def callback
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
    # Redirect to Auth0 for authentication
    # This will trigger the OAuth flow with PKCE
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
