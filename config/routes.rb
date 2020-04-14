Rails.application.routes.draw do
  resources :authenticates
  resources :widgets
  resources :users
  resources :sessions

  
  post '/reset', to: 'sessions#reset', as: :reset

  post '/login', to: 'sessions#create', as: :login

  get 'sessions/welcome', to: 'sessions#welcome', as: :welcome

  post 'widgets/search', to: 'widgets#search', as: :search

  get 'sessions/changepassword', to: 'sessions#changepassword', as: :change

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'sessions#new'

  get 'authorized', to: 'sessions#page_requires_login'

end
