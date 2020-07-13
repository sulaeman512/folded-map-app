Rails.application.routes.draw do
  
  # EXAMPLE HTML ROUTE
  # get "/photos" => "photos#index"

  namespace :api do
    
    get "/block_pair/:id" => "block_pairs#show"
    # keeping blockpair singular intentionally

    get "/conversations" => "conversations#index"
    post "/conversations" => "conversations#create"
    get "/conversations/:id" => "conversations#show"

    post "/messages" => "messages#create"
    
    get "/posts" => "posts#index"
    post "/posts" => "posts#create"
    get "/posts/:id" => "posts#show"
    patch "/posts/:id" => "posts#update"
    delete "/posts/:id" => "posts#destroy"

    post "/sessions" => "sessions#create"

    post "/users" => "users#create"
    get "/users/:id" => "users#show"
    patch "/users/:id" => "users#update"
    delete "/users/:id" => "users#destroy"

  end

end
