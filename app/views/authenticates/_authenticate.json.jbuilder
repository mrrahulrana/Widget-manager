json.extract! authenticate, :id, :email, :password, :created_at, :updated_at
json.url authenticate_url(authenticate, format: :json)
