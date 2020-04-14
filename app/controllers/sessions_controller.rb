class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:new, :create, :welcome]
  before_action :clear_session, only: [:new, :create,:logout]

  def new
  end

  def index

  end

  def logout
   redirect_to new_session_path
  end

  def create
    request_body_Data= '{
      "grant_type": "password",
      "client_id" : "'+ENV['CLIENT_ID']+'",
      "client_secret" : "'+ENV['CLIENT_SECRET']+'",
      "username" : "'+params[:username]+'",
      "password" : "'+params[:password]+'"
    }'
    response = RestClient::Request.new({
      method: :post,
      url: 'https://showoff-rails-react-production.herokuapp.com/oauth/token',
      payload: request_body_Data,
      headers: { content_type: 'application/json' }
    }).execute do |response, request, result|
      case response.code
      when 400
        [ :error, JSON.parse(response) ]
      when 200
        [ :success, JSON.parse(response) ]
        json=JSON.parse(response)
        session[:access_token] = 'Bearer ' + json["data"]["token"]["access_token"]
      else
        #fail "Invalid response #{response.to_str} received."
      end
    end
     #get user info
     if session[:access_token].present?
      userresponse = RestClient::Request.new({
        method: :get,
        url: ENV['API_URL'] + '/users/me',
        headers: { Authorization: session[:access_token]}
      }).execute do |userresponse, request, result|
        case userresponse.code
        when 400
          [ :error, JSON.parse(userresponse) ]
        when 200
          [ :success, JSON.parse(userresponse) ]
          userjson=JSON.parse(userresponse)
          session[:username] = userjson["data"]["user"]["name"]
          session[:userid] = userjson["data"]["user"]["id"]
        else
          #fail "Invalid response #{response.to_str} received."
        end
      end
    end
    respond_to do |format|
      if session[:userid].present?
        format.html { redirect_to widgets_path, notice: 'logged in successfully.' }
        format.json { render :index, status: :ok, location: widgets_path }
      else
        format.html { redirect_to new_session_path, notice: 'Username or Password incorrect!' }
      end
    end
  end

 
# Reset user password
def reset
  request_body_Data= '{ "user":
  {
    "email" : "'+params[:email]+'"
  }}'
  response = RestClient::Request.new({
    method: :put,
    url: ENV['API_URL'] + 'users/reset_password',
    payload: request_body_Data,
    headers: { Authorization: ENV['AUTH2_TOKEN'], content_type: 'application/json'}
  }).execute do |response, request, result|
    case response.code
    when 400
      [ :error, JSON.parse(response) ]
    when 200
      [ :success, JSON.parse(response) ]
    else
      fail "Invalid response #{response.to_str} received."
    end
  end
  json=JSON.parse(response)
  respond_to do |format|
    if json["code"]
      format.html { redirect_to @user, notice: json["message"] }
      format.json { render :show, status: :ok, location: @user }
    else
      format.html { render :edit }
      format.json { render json: @user.errors, status: :unprocessable_entity }
    end
  end
end

def change
end

# POST /changepassword
def changepassword
      request_body_Data= '{ "user":
      {
        "current_password" : "'+params[:oldpassword]+'",
        "new_password" : "'+params[:password]+'"
      }}'
      response = RestClient::Request.new({
        method: :put,
        url: ENV['API_URL'] + 'users/me/password',
        payload: request_body_Data,
        headers: { Authorization: ENV['AUTH2_TOKEN'], content_type: 'application/json'}
      }).execute do |response, request, result|
        case response.code
        when 400
          [ :error, JSON.parse(response) ]
        when 200
          [ :success, JSON.parse(response) ]
        else
          fail "Invalid response #{response.to_str} received."
        end
      end
      json=JSON.parse(response)
      respond_to do |format|
        if json["data"]["token"]["created_at"]
          format.html { redirect_to widgets_path, notice: 'Password changed successfully.' }
          format.json { render :index, status: :ok, location: widgets_path }
        else
          format.html { render :chnage }
          format.json { render json: json, status: :unprocessable_entity }
        end
      end
  end

  

  def page_requires_login
  end

  def show
  end

  def welcome
  end

  private
  def clear_session
    session[:access_token] = ""
    session[:username] = ""
    session[:userid] =""
  end


end
