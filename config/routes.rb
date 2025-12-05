Rails.application.routes.draw do
  devise_for :users
  get 'home/index'
  root "home#index"
  resources :training_records
  get 'analysis', to: 'analysis#index'
  get "menus/lighter", to: "menus#lighter"
  get "menus/heavier", to: "menus#heavier"



  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
