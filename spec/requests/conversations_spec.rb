require 'rails_helper'

RSpec.describe "Conversations", type: :request do

  before do
    block_pair1 = BlockPair.create(name: "w_9_7" ,ew_max: 3600, ns_max: 2800)
    block_pair2 = BlockPair.create(name: "w_8_7" ,ew_max: 3200, ns_max: 2800)
    block1 = Block.create(name: "nw_9_7", block_pair_id: block_pair1.id)
    block2 = Block.create(name: "sw_9_7", block_pair_id: block_pair1.id)
    block3 = Block.create(name: "nw_8_7", block_pair_id: block_pair2.id)
    user1 = User.create(email: "user1@gmail.com", password: "password", first_name: "User", last_name: "1", image_url: "1.jpg", birthday: DateTime.new(2001,1,11))
    user2 = User.create(email: "user2@gmail.com", password: "password", first_name: "User", last_name: "2", image_url: "2.jpg", birthday: DateTime.new(2002,2,22))
    user3 = User.create(email: "user3@gmail.com", password: "password", first_name: "User", last_name: "3", image_url: "3.jpg", birthday: DateTime.new(2003,3,30))
    user4 = User.create(email: "user4@gmail.com", password: "password", first_name: "User", last_name: "4", image_url: "4.jpg", birthday: DateTime.new(2004,4,30), block_id: block1.id)
    user5 = User.create(email: "user5@gmail.com", password: "password", first_name: "User", last_name: "5", image_url: "5.jpg", birthday: DateTime.new(2005,5,30), block_id: block1.id)
    user6 = User.create(email: "user6@gmail.com", password: "password", first_name: "User", last_name: "6", image_url: "6.jpg", birthday: DateTime.new(2006,6,30), block_id: block2.id)
    user7 = User.create(email: "user7@gmail.com", password: "password", first_name: "User", last_name: "7", image_url: "7.jpg", birthday: DateTime.new(2007,7,30), block_id: block3.id)
    Conversation.create(sender_id: user3.id, recipient_id: user1.id, map_twin: false)
    Conversation.create(sender_id: user4.id, recipient_id: user1.id, map_twin: false)
    Conversation.create(sender_id: user4.id, recipient_id: user2.id, map_twin: false)
  end

  describe "GET /conversations" do
    it "allows logged-in user to view index of their conversations" do
      user = User.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      get "/api/conversations", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      expect(response).to have_http_status(200)
    end
    it "prevents guest user from viewing a conversations index" do
      get "/api/conversations"
      expect(response).to have_http_status(401)
    end
  end
  describe "GET /conversations/:id" do
    it "allows logged-in user to view a specific one of their conversations" do
      user = User.first
      conversation = Conversation.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      get "/api/conversations/#{conversation.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      expect(response).to have_http_status(200)
    end
    it "prevents logged-in user from viewing a conversation they're not a part of" do
      user = User.first
      conversation = Conversation.third
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      get "/api/conversations/#{conversation.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      expect(response).to have_http_status(403)
    end
    it "prevents guest user from viewing any conversation" do
      conversation = Conversation.third
      get "/api/conversations/#{conversation.id}"
      expect(response).to have_http_status(401)
    end
    it "gives a not_found error when a logged-in user tries to view a non-existent conversation" do
      user = User.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      get "/api/conversations/999", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      expect(response).to have_http_status(:not_found)
    end
  end
  describe "POST /conversations" do
    it "prevents logged-in user without block from creating a conversation" do
      user = User.first
      user2 = User.second
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      post "/api/conversations",
      params: {
        sender_id: user.id,
        recipient_id: user2.id,
      },
      headers: {"Authorization": "Bearer #{jwt}"}
      expect(response).to have_http_status(400)
      expect(Conversation.count).to eq(3)
    end
    it "prevents logged-in user from creating a conversation with someone outside their block pair" do
      user = User.find_by(email: "user7@gmail.com")
      user2 = User.find_by(email: "user6@gmail.com")
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      post "/api/conversations",
      params: {
        sender_id: user.id,
        recipient_id: user2.id,
      },
      headers: {"Authorization": "Bearer #{jwt}"}
      expect(response).to have_http_status(403)
      expect(Conversation.count).to eq(3)
    end
    it "allows logged-in user to create a conversation with someone in their block pair" do
      user = User.fifth
      user2 = User.fourth
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      post "/api/conversations",
      params: {
        sender_id: user.id,
        recipient_id: user2.id,
      },
      headers: {"Authorization": "Bearer #{jwt}"}

      expect(response).to have_http_status(200)
      expect(Conversation.count).to eq(4)
    end
    it "prevents guestin user from creating a conversation" do
      post "/api/conversations",
      params: {
        sender_id: 1,
        recipient_id: 2,
      }
      expect(response).to have_http_status(401)
    end
  end
end
