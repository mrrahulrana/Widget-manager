class WidgetsController < ApplicationController
  before_action :set_widget, only: [:index, :show, :edit, :update, :destroy]

  # GET /widgets
  # GET /widgets.json
  def index
    
  end

  # GET /widgets/1
  # GET /widgets/1.json
  def show
  end

  # GET /widgets/new
  def new
    @widget = Widget.new
  end

  # GET /widgets/1/edit
  def edit
    @widget = @widgetlist.widgets.find {|widget| widget.id == params[:id].to_i}
  end

  # GET /widgets/search
  def search
   response = RestClient::Request.new({
    method: :get,
    url: ENV['API_URL'] + '/widgets/visible?client_id=' + ENV['CLIENT_ID'] + '&client_secret=' + ENV['CLIENT_SECRET'] + '&term=' + params[:searchkey],
    headers: { Authorization: ENV['AUTH2_TOKEN'], content_type: 'application/json'}
  }).execute do |response, request, result|
    case response.code
    when 400
      [ :error, JSON.parse(response) ]
    when 200
      [ :success, JSON.parse(response) ]
      json=JSON.parse(response)
      rec = Array.new
      json["data"]["widgets"].each do |item|
          widget= Widget.new 
          widget.id=item["id"]
          widget.name=item["name"]
          widget.description=item["description"]
          widget.kind=item["kind"]
          widget.userid=item["user"]["id"]
          widget.username=item["user"]["name"]
          widget.owner=item["owner"]
          rec << widget
      end
      @widgetlist= WidgetList.new
      @widgetlist.widgets = rec
      #render plain: @widgetlist.widgets.count
    else
      fail "Invalid response #{response.to_str} received."
    end
    
  end
  end

  # POST /widgets
  # POST /widgets.json
  def create
    #@widget.valid?
    request_body_Data= '{ "widget":
    {
      "name" : "'+widget_params[:name]+'",
      "description" : "'+widget_params[:description]+'",
      "kind" : "'+widget_params[:kind]+'"
    }}'
    response = RestClient::Request.new({
      method: :post,
      url: ENV['API_URL'] + '/widgets',
      payload: request_body_Data,
      headers: { Authorization: ENV['AUTH2_TOKEN'], content_type: 'application/json'}
    }).execute do |response, request, result|
      case response.code
      when 400
        [ :error, JSON.parse(response) ]
      when 200
        [ :success, JSON.parse(response) ]
        json=JSON.parse(response)
        @widget= Widget.new do |widget|
          widget.id=json["data"]["widget"]["id"]
          widget.name=json["data"]["widget"]["name"]
          widget.description=json["data"]["widget"]["description"]
          widget.kind=json["data"]["widget"]["kind"]
          widget.userid=json["data"]["widget"]["user"]["id"]
          widget.username=json["data"]["widget"]["user"]["name"]
          widget.owner=json["data"]["widget"]["owner"]
        end
      else
        fail "Invalid response #{response.to_str} received."
      end
    end

    respond_to do |format|
      if @widget
        format.html { redirect_to @widget, notice: 'Widget was successfully created.' }
        format.json { render :show, status: :created, location: @widget }
      else
        format.html { render :new }
        format.json { render json: @widget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /widgets/1
  # PATCH/PUT /widgets/1.json
  def update
    request_body_Data= '{ "widget":
    {
      "name" : "'+params[:name]+'",
      "description" : "'+params[:description]+'"
    }}'
    response = RestClient::Request.new({
      method: :put,
      url: ENV['API_URL'] + '/widgets/' + params[:id],
      payload: request_body_Data,
      headers: { Authorization: ENV['AUTH2_TOKEN'], content_type: 'application/json'}
    }).execute do |response, request, result|
      case response.code
      when 400
        [ :error, JSON.parse(response) ]
      when 200
        [ :success, JSON.parse(response) ]
        json=JSON.parse(response)
        @widget= Widget.new do |widget|
          widget.id=json["data"]["widget"]["id"]
          widget.name=json["data"]["widget"]["name"]
          widget.description=json["data"]["widget"]["description"]
          widget.kind=json["data"]["widget"]["kind"]
          widget.userid=json["data"]["widget"]["user"]["id"]
          widget.username=json["data"]["widget"]["user"]["name"]
          widget.owner=json["data"]["widget"]["owner"]
        end
      else
        fail "Invalid response #{response.to_str} received."
      end
    end
    respond_to do |format|
      if @widget
        format.html { redirect_to @widget, notice: 'Widget was successfully updated.' }
        format.json { render :show, status: :ok, location: @widget }
      else
        format.html { render :edit }
        format.json { render json: @widget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /widgets/1
  # DELETE /widgets/1.json
  def delete
    resultmessage='Fail'
    response = RestClient::Request.new({
      method: :delete,
      url: ENV['API_URL'] + '/widgets/' + params[:id],
      headers: { Authorization: ENV['AUTH2_TOKEN'], content_type: 'application/json'}
    }).execute do |response, request, result|
      case response.code
      when 400
        [ :error, JSON.parse(response) ]
      when 200
        [ :success, JSON.parse(response) ]
        json=JSON.parse(response)
        resultmessage=json["message"]
      else
        fail "Invalid response #{response.to_str} received."
      end
    end
    if resultmessage == 'Success'
    respond_to do |format|
      format.html { redirect_to widgets_path, notice: 'Widget was successfully deleted.' }
      format.json { head :no_content }
    end
  end
end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_widget
      response = RestClient::Request.new({
        method: :get,
        url: ENV['API_URL'] + '/widgets',
        headers: { Authorization: ENV['AUTH2_TOKEN'], content_type: 'application/json'}
      }).execute do |response, request, result|
        case response.code
        when 400
          [ :error, JSON.parse(response) ]
        when 200
          [ :success, JSON.parse(response) ]
          json=JSON.parse(response)
          rec = Array.new
          json["data"]["widgets"].each do |item|
              widget= Widget.new 
              widget.id=item["id"]
              widget.name=item["name"]
              widget.description=item["description"]
              widget.kind=item["kind"]
              widget.userid=item["user"]["id"]
              widget.username=item["user"]["name"]
              widget.owner=item["owner"]
              rec << widget
          end
          @widgetlist= WidgetList.new
          @widgetlist.widgets = rec
          #render plain: @widgetlist.widgets.count
        else
          fail "Invalid response #{response.to_str} received."
        end
      end
    end

    # Only allow a list of trusted parameters through.
    def widget_params
      params.require(:widget).permit(:id, :name, :description, :kind, :searchkey)
    end
end
