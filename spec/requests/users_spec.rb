require 'rails_helper'

RSpec.describe "Users", type: :request do
  
  before do
    block_pair1 = BlockPair.create(name: "w_9_7" ,ew_max: 3600, ns_max: 2800)
    block_pair2 = BlockPair.create(name: "w_8_7" ,ew_max: 3200, ns_max: 2800)
    block1 = Block.create(name: "nw_9_7", block_pair_id: block_pair1.id)
    block2 = Block.create(name: "sw_9_7", block_pair_id: block_pair1.id)
    block3 = Block.create(name: "nw_8_7", block_pair_id: block_pair2.id)
    user1 = User.create(email: "user1@gmail.com", password: "password", first_name: "User", last_name: "1", image_url: "1.jpg", birthday: DateTime.new(2001,1,11))
    user2 = User.create(email: "user2@gmail.com", password: "password", first_name: "User", last_name: "2", image_url: "2.jpg", birthday: DateTime.new(2002,2,22))
    user3 = User.create(email: "user3@gmail.com", password: "password", first_name: "User", last_name: "3", image_url: "3.jpg", birthday: DateTime.new(2003,3,30), block_id: block3.id)
    user4 = User.create(email: "user4@gmail.com", password: "password", first_name: "User", last_name: "4", image_url: "4.jpg", birthday: DateTime.new(2004,4,30), block_id: block1.id)
    user5 = User.create(email: "user5@gmail.com", password: "password", first_name: "User", last_name: "5", image_url: "5.jpg", birthday: DateTime.new(2005,5,30), block_id: block1.id)
    user6 = User.create(email: "user6@gmail.com", password: "password", first_name: "User", last_name: "6", image_url: "6.jpg", birthday: DateTime.new(2006,6,30), block_id: block2.id)
    Conversation.create(sender_id: user1.id, recipient_id: user3.id, map_twin: false)
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
    it "should PREVENT (with 403 error) a logged-in user from viewing another user's profile if they don't share a block pair" do
      user = User.fourth
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      user2_id = User.third.id
      get "/api/users/#{user2_id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      expect(response).to have_http_status(403)
    end
    it "should ALLOW a logged-in user to view another user's profile if they share a block pair" do
      user = User.fourth
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      user2_id = User.fifth.id
      get "/api/users/#{user2_id}", headers: {"Authorization" => "Bearer #{jwt}"}
      user = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(user["image_url"]).to eq("5.jpg")
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
      expect(User.count).to eq(5)
    end
    it "should prevent a logged-in user from deleting another user's profile" do
      user_to_delete = User.first
      user2 = User.second
      jwt = JWT.encode(
        {
          user_id: user2.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      delete "/api/users/#{user_to_delete.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      user = JSON.parse(response.body)
      expect(response).to have_http_status(403)
      expect(User.count).to eq(6)
    end
    it "should prevent a guest user from deleting any user's profile" do
      user_to_delete = User.first
      delete "/api/users/#{user_to_delete.id}"
      user = JSON.parse(response.body)
      expect(response).to have_http_status(401)
      expect(User.count).to eq(6)
    end
  end
  describe "PATCH /users/:id" do
    it "should allow a logged-in user to update their own user info" do
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
    it "should prevent a logged-in user from updating another user's info" do
      user_to_update = User.first
      user2 = User.second
      jwt = JWT.encode(
        {
          user_id: user2.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      patch "/api/users/#{user_to_update.id}",
      params: {
        email: "newemail@gmail.com",
        first_name: "Dwayne"
      },
      headers: {"Authorization": "Bearer #{jwt}"}
      user = JSON.parse(response.body)
      expect(response).to have_http_status(403)
    end
    it "should prevent a guest user from updating any user's info" do
      user = User.first
      patch "/api/users/#{user.id}",
      params: {
        email: "newemail@gmail.com",
        first_name: "Dwayne"
      }
      user = JSON.parse(response.body)
      expect(response).to have_http_status(401)
    end
    it "should create conversation between N/S street map twins" do
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
      user2 = User.second
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
      conversation = Conversation.find_by(sender_id: user2.id, recipient_id: user1.id)
      expect(response).to have_http_status(200)
      expect(conversation.map_twin).to eq(true)
    end
    it "should create conversation between E/W street map twins (via lat/lng mirroring)" do
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
        street_num: 3192,
        street_direction: "S",
        street: "Kedzie Ave",
        zip_code: "60623"
      },
      headers: {"Authorization": "Bearer #{jwt}"}
      user2 = User.second
      jwt = JWT.encode(
        {
          user_id: user2.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      patch "/api/users/#{user2.id}",
      params: {
        street_num: 2525,
        street_direction: "N",
        street: "Linden Pl",
        zip_code: "60647"
      },
      headers: {"Authorization": "Bearer #{jwt}"}
      user = JSON.parse(response.body)
      conversation = Conversation.find_by(sender_id: user2.id, recipient_id: user1.id)
      expect(conversation.map_twin).to eq(true)
      expect(response).to have_http_status(200)
    end
  end
end