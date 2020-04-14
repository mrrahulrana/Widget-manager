Rails.application.routes.draw do
  resources :widgets
  resources :users
  resources :sessions

  
  post '/reset', to: 'sessions#reset', as: :reset

  post '/login', to: 'sessions#create', as: :login

  get '/delete/:id', to: 'widgets#delete', as: :delete

  get 'sessions/welcome', to: 'sessions#welcome', as: :welcome

  post 'widgets/search', to: 'widgets#search', as: :search

  get '/logout', to: 'sessions#logout', as: :logout

  get '/change', to: 'sessions#change', as: :change

  post '/change', to: 'sessions#changepassword', as: :changepassword

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'sessions#new'

  get 'authorized', to: 'sessions#page_requires_login'

end
