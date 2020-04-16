class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:new, :index, :create, :reset,:unauthorized, :logout]
  before_action :clear_session, only: [:new, :create,:logout]
  after_action :get_userinfo, only: [:create,:changepassword]

  # GET /login page
  def new
  end

  # GET /reset password
  def index

  end

  # GET /logout
  def logout
   redirect_to new_session_path
  end

  #POST /Login page
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
    
    respond_to do |format|
      if session[:access_token].present?
        format.html { redirect_to widgets_path, notice: 'logged in successfully.' }
        format.json { render :index, status: :ok, location: widgets_path }
      else
        format.html { redirect_to new_session_path, notice: 'Username or Password incorrect!' }
      end
    end
  end
 
# POST /Reset user password
def reset
  request_body_Data = '{
    "user" : {
        "email" : "'+params[:email]+'"
    },
    "client_id" : "'+ENV['CLIENT_ID']+'",
    "client_secret" : "'+ENV['CLIENT_SECRET']+'"
  }'

    jsonresult=""
    response = RestClient::Request.new({
      method: :post,
      url: ENV['API_URL'] + 'users/reset_password',
      payload: request_body_Data,
      headers: {content_type: 'application/json'}
    }).execute do |response, request, result|
      case response.code
      when 400
        [ :error, JSON.parse(response) ]
      when 200
        [ :success, JSON.parse(response) ]
      else
        #fail "Invalid response #{response.to_s} received."
      end
      json=JSON.parse(response)
      jsonresult=json
    end
    
    respond_to do |format|
      if jsonresult["code"].to_i >= 0
        format.html { redirect_to sessions_path, notice: jsonresult["message"] }
        format.json { render :new, status: :ok, location: sessions_path }
      else
        format.html { redirect_to sessions_path, notice: jsonresult["message"] }
      end
    end
  
end

# GET /changepassword
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
        method: :post,
        url: ENV['API_URL'] + 'users/me/password',
        payload: request_body_Data,
        headers: { Authorization: session[:access_token], content_type: 'application/json'}
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
      respond_to do |format|
        if session[:access_token].present?
          format.html { redirect_to widgets_path, notice: 'password changed successfully.' }
          format.json { render :index, status: :ok, location: widgets_path }
        else
          format.html { redirect_to new_session_path, notice: 'Password details incorrect!' }
        end
      end
  end

  def show
  end

  def unauthorized
    
  end

  private
  def get_userinfo
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
  end


  def clear_session
    session[:access_token] = ""
    session[:username] = ""
    session[:userid] =""
  end


end
