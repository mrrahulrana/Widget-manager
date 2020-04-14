class AuthenticatesController < ApplicationController

  # GET /authenticates
  # GET /authenticates.json
  def index
   
  end

  def change
render plain: '{ "user":
{
  "current_password" : "'+params[:oldpassword]+'",
  "new_password" : "'+params[:password]+'"
}}'
  end
  # POST /authenticates
  # POST /authenticates.json
  def change1
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
        format.html { redirect_to @user, notice: 'Password changed successfully.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    
    # Only allow a list of trusted parameters through.
    def authenticate_params
      params.require(:authenticate).permit(:email, :oldpassword, :password)
    end
end
