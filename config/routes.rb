Rails.application.routes.draw do
  resources :widgets
  resources :users
  resources :sessions

  
  post '/login', to: 'sessions#create'

  get 'sessions/welcome', to: 'sessions#welcome', as: :welcome

  post 'widgets/search', to: 'widgets#search', as: :search

  get 'sessions/resetpassword', to: 'sessions#resetpassword', as: :reset
  get 'sessions/changepassword', to: 'sessions#changepassword', as: :change

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'sessions#new'

  get 'authorized', to: 'sessions#page_requires_login'

end
