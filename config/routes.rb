Rails.application.routes.draw do
  
  # EXAMPLE HTML ROUTE
  # get "/photos" => "photos#index"

  namespace :api do
    
    get "/conversations" => "conversations#index"
    post "/conversations" => "conversations#create"
    get "/conversations/:id" => "conversations#show"

    post "/messages" => "messages#create"

    post "/sessions" => "sessions#create"

    post "/users" => "users#create"
    get "/users/:id" => "users#show"
    patch "/users/:id" => "users#update"
    delete "/users/:id" => "users#destroy"

  end

end
