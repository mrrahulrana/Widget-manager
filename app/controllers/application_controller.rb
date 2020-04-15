class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authorized
  helper_method :current_user
  helper_method :logged_in?

  def current_user
    #User.find_by(id: session[:user_id])
  end
  def logged_in?
   session[:access_token].present?
  end

  def authorized
    if !logged_in?
     redirect_to unauthorized_path 
    end
  end
end
