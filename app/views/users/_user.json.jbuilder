json.extract! user, :id, :firstname, :lastname, :password, :password_confirmed, :email, :imageurl, :created_at, :updated_at
json.url user_url(user, format: :json)
