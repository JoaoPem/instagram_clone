Rails.application.routes.draw do
  get "graph/show"
  resources :posts

  devise_for :users

  root "home#index"

  post "toggle_like", to: "likes#toggle_like", as: :toggle_like

  resources :comments, only: [ :create, :destroy ]

  resources :users, only: [ :show, :index ]

  post "follow", to: "follows#follow", as: :follow
  delete "unfollow", to: "follows#unfollow", as: :unfollow
  delete "cancel_request", to: "follows#cancel_request", as: :cancel_request
  post "accept_follow", to: "follows#accept_follow", as: :accept_follow
  delete "decline_follow", to: "follows#decline_follow", as: :decline_follow

  resources :home do
    collection do
      get :graph_data
    end
  end

  get "graph", to: "graph#show"
  get "graph_data", to: "graph#graph_data"
end
