class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Authentication helper methods
  def user_signed_in?
    session[:user_info].present? && session_valid?
  end

  def current_user
    session[:user_info] if user_signed_in?
  end
  
  def current_tokens
    session[:tokens] if user_signed_in?
  end

  def authenticate_user!
    unless user_signed_in?
      session[:redirect_after_login] = request.fullpath
      redirect_to login_path
    end
  end
  
  def session_valid?
    return false unless session[:user_info].present?
    
    # Check if session has expired (optional security measure)
    authenticated_at = session[:user_info]['authenticated_at']
    return false unless authenticated_at
    
    # Sessions expire after 24 hours
    session_age = Time.current - Time.parse(authenticated_at.to_s)
    session_age < 24.hours
  rescue
    false
  end

  # Make these methods available in views
  helper_method :user_signed_in?, :current_user, :current_tokens
end
