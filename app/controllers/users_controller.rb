require 'rest-client'
require 'json'

class UsersController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]
  before_action :authorized, only: [:index, :show, :edit, :update, :destroy]
  before_action :set_user, only: [:index, :edit]

  # GET /users
  # GET /users.json
  def index
  end

  # GET /users/new
  def new
    @user = User.new
  end
  
  # GET /users/1/edit
  def edit
    
  end

  # GET /users/1
  # GET /users/1.json
  def show
    response = RestClient::Request.new({
      method: :get,
      url: ENV['API_URL'] + '/users/' + params[:id],
      headers: { Authorization: session[:access_token]}
    }).execute do |response, request, result|
      case response.code
      when 400
        [ :error, JSON.parse(response) ]
      when 200
        [ :success, JSON.parse(response) ]
        json=JSON.parse(response)
        user= User.new
        user.id=json["data"]["user"]["id"]
        user.firstname=json["data"]["user"]["first_name"]
        user.lastname=json["data"]["user"]["last_name"]
        user.email=json["data"]["user"]["email"]
        @user= user
      else
        fail "Invalid response #{response.to_str} received."
      end
    end
  end

# Create user
  def create
    request_body_Data= '{
      "client_id" : "'+ENV['CLIENT_ID']+'",
      "client_secret" : "'+ENV['CLIENT_SECRET']+'",
      "user": {
        "first_name": "'+user_params[:firstname]+'",
        "last_name": "'+user_params[:lastname]+'",
        "password": "'+user_params[:password]+'",
        "email": "'+user_params[:email]+'",
        "image_url": "'+user_params[:imageurl]+'"
      }
    }'
    response = RestClient::Request.new({
      method: :post,
      url: ENV['API_URL'] + '/users',
      payload: request_body_Data,
      headers: { content_type: 'application/json'}
    }).execute do |response, request, result|
      case response.code
      when 400
        [ :error, JSON.parse(response) ]
      when 200
        [ :success, JSON.parse(response) ]
        json=JSON.parse(response)
        user= User.new
        user.id=json["data"]["user"]["id"]
        user.firstname=json["data"]["user"]["first_name"]
        user.lastname=json["data"]["user"]["last_name"]
        user.email=json["data"]["user"]["email"]
        @user= user
        #set user info into session
        session[:access_token] = json["data"]["token"]["access_token"]
        session[:username] = json["data"]["user"]["name"]
        session[:userid] = json["data"]["user"]["id"]
      else
        fail "Invalid response #{response.to_str} received."
      end
    end
    if session[:access_token].present?
      format.html { redirect_to widgets_path, notice: 'User was successfully created.' }
      format.json { render :index, status: :ok, location: widgets_path }
    else
      redirect_to login_path
    end
  end

# POST Update User details
  def update
    request_body_Data= '{ "user":
    {
      "first_name" : "'+params[:firstname]+'",
      "last_name" : "'+params[:lastname]+'",
      "date_of_birth" : "'+params[:dateofbirth]+'",
      "image_url": "'+params[:imageurl]+'"
    }}'
    response = RestClient::Request.new({
      method: :put,
      url: ENV['API_URL'] + '/users/me',
      payload: request_body_Data,
      headers: { Authorization: session[:access_token], content_type: 'application/json'}
    }).execute do |response, request, result|
      case response.code
      when 400
        [ :error, JSON.parse(response) ]
      when 200
        [ :success, JSON.parse(response) ]
        json=JSON.parse(response)
        user= User.new
        user.id=json["data"]["user"]["id"]
        user.firstname=json["data"]["user"]["first_name"]
        user.lastname=json["data"]["user"]["last_name"]
        user.email=json["data"]["user"]["email"]
        @user= user
      else
        fail "Invalid response #{response.to_str} received."
      end
    end
    respond_to do |format|
      if @user
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def check
    #check email valid or not
  emailavailable="false"
  userresponse = RestClient::Request.new({
    method: :get,
    url: ENV['API_URL'] + 'users/email?email='+ params[:email] +'&client_id='+ ENV['CLIENT_ID'] + '&client_secret=' + ENV['CLIENT_SECRET'],
    headers: { content_type: 'application/json'}
  }).execute do |userresponse, request, result|
    case userresponse.code
    when 400
      [ :error, JSON.parse(userresponse) ]
    when 200
      [ :success, JSON.parse(userresponse) ]
      userjson=JSON.parse(userresponse)
      emailavailable=userjson["data"]["available"]
    else
      fail "Invalid response #{userresponse.to_str} received."
    end
  end
  respond_to do |format|
    if emailavailable.to_s = "true"
      format.html { redirect_to new_user_path, notice: 'Email is available.' }
      format.json { render :new, status: :ok, location: new_user_path }
    else
      format.html { redirect_to new_user_path, notice: 'Email is already registered.' }
      format.json { render json: @user.errors, status: :unprocessable_entity }
    end
  end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
   def set_user
    response = RestClient::Request.new({
      method: :get,
      url: ENV['API_URL'] + '/users/me',
      headers: { Authorization: session[:access_token], content_type: 'application/json'}
    }).execute do |response, request, result|
      case response.code
      when 400
        [ :error, JSON.parse(response) ]
      when 200
        [ :success, JSON.parse(response) ]
        json=JSON.parse(response)
        user= User.new
        user.id=json["data"]["user"]["id"]
        user.firstname=json["data"]["user"]["first_name"]
        user.lastname=json["data"]["user"]["last_name"]
        user.dateofbirth=json["data"]["user"]["date_of_birth"]
        user.email=json["data"]["user"]["email"]
        session[:username] = json["data"]["user"]["name"]
        session[:userid] = json["data"]["user"]["id"]
        @user= user
      else
        fail "Invalid response #{response.to_str} received."
      end
    end
  end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:id, :firstname, :lastname, :password, :password_confirmed, :dateofbirth, :email, :imageurl)
    end
end
