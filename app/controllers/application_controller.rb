class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Authentication helper methods
  def user_signed_in?
    session[:user_info].present?
  end
  
  def current_user
    session[:user_info] if user_signed_in?
  end
  
  def authenticate_user!
    redirect_to login_path unless user_signed_in?
  end
  
  # Make these methods available in views
  helper_method :user_signed_in?, :current_user
end
