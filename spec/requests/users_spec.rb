require 'rails_helper'

RSpec.describe "Users", type: :request do
  
  before do
    user1 = User.create(email: "user1@gmail.com", password: "password", first_name: "User", last_name: "1", image_url: "1.jpg", birthday: DateTime.new(2001,1,11))
    user2 = User.create(email: "user2@gmail.com", password: "password", first_name: "User", last_name: "2", image_url: "2.jpg", birthday: DateTime.new(2002,2,22))
    user3 = User.create(email: "user3@gmail.com", password: "password", first_name: "User", last_name: "3", image_url: "3.jpg", birthday: DateTime.new(2003,3,30))
    Conversation.create(sender_id: user1.id, recipient_id: user3.id, map_twin: false)
    BlockPair.create(name: "w_9_7" ,ew_max: 3600, ns_max: 2800)
    # BlockPair.create([
    #   {name: "w_8_7" ,ew_max: 3200, ns_max: 2800},
    #   {name: "w_8_8" ,ew_max: 3200, ns_max: 3200},
    #   {name: "w_8_9" ,ew_max: 3200, ns_max: 3600},
    #   {name: "w_9_8" ,ew_max: 3600, ns_max: 3200},
    #   {name: "w_9_9" ,ew_max: 3600, ns_max: 3600},
    # ])
    Block.create(name: "nw_9_7", block_pair_id: 1)
    # Block.create([
    #   {name: "sw_9_7", block_pair_id: 1},
    #   {name: "nw_8_7", block_pair_id: 2},
    #   {name: "sw_8_7", block_pair_id: 2},
    #   {name: "nw_8_8", block_pair_id: 3},
    #   {name: "sw_8_8", block_pair_id: 3},
    #   {name: "nw_8_9", block_pair_id: 4},
    #   {name: "sw_8_9", block_pair_id: 4},
    #   {name: "nw_9_8", block_pair_id: 5},
    #   {name: "sw_9_8", block_pair_id: 5},
    #   {name: "nw_9_9", block_pair_id: 6},
    #   {name: "sw_9_9", block_pair_id: 6}
    #   ])
  end

  describe "GET /users/:id" do
    it "should allow a logged-in user to view their own info" do
      user = User.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      user_id = User.first.id
      get "/api/users/#{user_id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      user = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(user["image_url"]).to eq("1.jpg")
    end
    it "should PREVENT (with 403 error) a logged-in user from viewing another user's profile if they don't share a conversation" do
      user = User.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      user2_id = User.second.id
      get "/api/users/#{user2_id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      expect(response).to have_http_status(403)
    end
    it "should ALLOW a logged-in user to view another user's profile if they share a conversation" do
      user = User.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      user3_id = User.third.id
      get "/api/users/#{user3_id}", headers: {"Authorization" => "Bearer #{jwt}"}
      user = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(user["image_url"]).to eq("3.jpg")
    end
    it "should PREVENT a guest user from viewing any user's profile" do
      user = User.first
      get "/api/users/#{user.id}"
      expect(response).to have_http_status(401)
    end
  end
  describe "DELETE /users/:id" do
    it "should allow a logged-in user to delete their own profile" do
      user_to_delete = User.first
      jwt = JWT.encode(
        {
          user_id: user_to_delete.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      delete "/api/users/#{user_to_delete.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      user = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(User.count).to eq(2)
    end
  end
  describe "PATCH /users/:id" do
    it "should update an existing user" do
      user = User.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      patch "/api/users/#{user.id}",
      params: {
        email: "newemail@gmail.com",
        first_name: "Dwayne"
      },
      headers: {"Authorization": "Bearer #{jwt}"}
      user = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(user["first_name"]).to eq("Dwayne")
    end
    it "should create conversation between map twins" do
      user1 = User.first
      jwt = JWT.encode(
        {
          user_id: user1.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      patch "/api/users/#{user1.id}",
      params: {
        street_num: 2739,
        street_direction: "N",
        street: "Central Park Ave",
        zip_code: "60647"
      },
      headers: {"Authorization": "Bearer #{jwt}"}
      user2 = User.first
      jwt = JWT.encode(
        {
          user_id: user2.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      patch "/api/users/#{user2.id}",
      params: {
        street_num: 2739,
        street_direction: "S",
        street: "Central Park Ave",
        zip_code: "60623"
      },
      headers: {"Authorization": "Bearer #{jwt}"}
      user = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(Conversation.count).to eq(2)
    end
  end
end