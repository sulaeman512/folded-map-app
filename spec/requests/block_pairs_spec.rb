require 'rails_helper'

RSpec.describe "BlockPairs", type: :request do
  
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
    Conversation.create(sender_id: user1.id, recipient_id: user3.id, map_twin: false)
  end
  
  describe "GET /block_pair/:id" do
    it "should allow a logged-in user to view their own block pair" do
      user = User.find_by(email: "user4@gmail.com")
      block_pair = BlockPair.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      get "/api/block_pair/#{block_pair.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      block_pair = JSON.parse(response.body)
      expect(response).to have_http_status(200)
    end
    it "should prevent a logged-in user from viewing another block pair; instead shows them their own block pair" do
      user = User.find_by(email: "user4@gmail.com")
      block_pair = BlockPair.second
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      get "/api/block_pair/#{block_pair.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      block_pair = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(block_pair["name"]).to eq("w_9_7")
    end
    it "should prevent a guest user from viewing any block pair" do
      block_pair = BlockPair.first
      get "/api/block_pair/#{block_pair.id}"
      block_pair = JSON.parse(response.body)
      expect(response).to have_http_status(401)
    end
    it "should show a logged-in user their own block pair when attempting to view a non-existent block pair" do
      user = User.find_by(email: "user4@gmail.com")
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      get "/api/block_pair/1", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      block_pair = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(block_pair["name"]).to eq("w_9_7")
    end
  end
end
