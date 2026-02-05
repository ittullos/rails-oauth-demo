class ProtectedController < ApplicationController
  before_action :authenticate_user!

  def index
  end

private

  def authenticate_user!
    # For now, just a placeholder - we'll implement Auth0 authentication later
    # redirect_to root_path unless user_signed_in?
  end
end
