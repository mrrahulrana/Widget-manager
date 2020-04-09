require 'rest-client'
require 'json'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    response = RestClient::Request.new({
      method: :get,
      url: 'https://showoff-rails-react-production.herokuapp.com/api/v1/users/me',
      headers: { Authorization: 'Bearer 887185e6f694842578cbe41ded1b4f584d9ddfa08d62654a689ed2a8a11a9a8e'}
    }).execute do |response, request, result|
      case response.code
      when 400
        [ :error, JSON.parse(response) ]
      when 200
        [ :success, JSON.parse(response) ]
        json=JSON.parse(response)
        render plain: json["data"]["user"]["name"]
      else
        fail "Invalid response #{response.to_str} received."
      end
    end
    
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:firstname, :lastname, :password, :password_confirmed, :email, :imageurl)
    end
end
