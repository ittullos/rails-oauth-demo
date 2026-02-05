class AuthController < ApplicationController
  def callback
    # Extract user information from OAuth response
    auth_info = request.env["omniauth.auth"]

    # Store user information in session
    session[:user_info] = {
      uid: auth_info["uid"],
      name: auth_info["info"]["name"],
      email: auth_info["info"]["email"],
      nickname: auth_info["info"]["nickname"],
      picture: auth_info["info"]["image"],
      provider: auth_info["provider"]
    }

    # Redirect to protected page or where they came from
    redirect_to protected_path, notice: "Successfully authenticated!"
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
