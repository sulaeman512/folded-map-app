Rails.application.routes.draw do
  
  # EXAMPLE HTML ROUTE
  # get "/photos" => "photos#index"

  namespace :api do
    
    post "/users" => "users#create"

    post "/sessions" => "sessions#create"

  end

end
