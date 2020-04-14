class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:new, :create, :welcome]

  def new
  end

  def index

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
        session[:access_token] = json["data"]["token"]["access_token"]
      else
        fail "Invalid response #{response.to_str} received."
      end
    end
    if session[:access_token].present?
      redirect_to widgets_path
    else
      redirect_to login_path
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



  

  def page_requires_login
  end

  def show
  end

  def welcome
  end


end
