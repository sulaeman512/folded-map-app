require 'rails_helper'

RSpec.describe "Messages", type: :request do
  
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
    Conversation.create(sender_id: user3.id, recipient_id: user1.id, map_twin: false)
    Conversation.create(sender_id: user4.id, recipient_id: user1.id, map_twin: false)
    Conversation.create(sender_id: user4.id, recipient_id: user2.id, map_twin: false)
  end
  
  describe "POST /messages" do
    it "allows logged-in user to create a message in a conversation they're in" do
      user = User.first
      conversation = Conversation.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      post "/api/messages",
        params: {
          conversation_id: conversation.id,
          text: "Hey",
          user_id: user.id,
        },
        headers: {"Authorization": "Bearer #{jwt}"}
      expect(response).to have_http_status(201)
      expect(Message.count).to eq(1)
    end
    it "prevents logged-in user from creating a message in a conversation they're not part of" do
      user = User.first
      conversation = Conversation.third
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      post "/api/messages",
        params: {
          conversation_id: conversation.id,
          text: "Hey",
          user_id: user.id,
        },
        headers: {"Authorization": "Bearer #{jwt}"}
      expect(response).to have_http_status(403)
      expect(Message.count).to eq(0)
    end
  end
end
