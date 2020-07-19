require 'rails_helper'

RSpec.describe "Comments", type: :request do
  
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
    Conversation.create(sender_id: user1.id, recipient_id: user3.id, map_twin: false)
    post1 = Post.create(block_pair_id: block_pair1.id, user_id: user6.id, text: "Blah blah", image_url: "blah.jpg")
    post2 = Post.create(block_pair_id: block_pair2.id, user_id: user7.id, text: "Hey hey", image_url: "hey.jpg")
    comment1 = Comment.create(user_id: user4.id, post_id: post1.id, text: "Nope")
  end
  
  describe "POST /comments" do
    it "should allow a logged-in user to create a comment on a post in their block pair" do
      user = User.find_by(email: "user4@gmail.com")
      post = Post.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      post "/api/comments", headers: {
        "Authorization": "Bearer #{jwt}"
      },
      params: {
        post_id: post.id,
        text: "This is a comment"
      }
      expect(response).to have_http_status(201)
      expect(Comment.second.text).to eq("This is a comment")
      expect(Comment.count).to eq(2)
    end
    it "should prevent a logged-in from creating a comment on a post outside their block pair" do
      user = User.find_by(email: "user4@gmail.com")
      post = Post.second
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      post "/api/comments", headers: {
        "Authorization": "Bearer #{jwt}"
      },
      params: {
        post_id: post.id,
        text: "This is a comment"
      }
      expect(response).to have_http_status(400)
      expect(Comment.count).to eq(1)
    end
  end
  describe "PATCH /comments/:id" do
    it "should allow a logged-in user to update one of their comments" do
      user = User.find_by(email: "user4@gmail.com")
      comment = Comment.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      patch "/api/comments/#{comment.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      },
      params: {
        text: "Yep!"
      }
      expect(response).to have_http_status(201)
      expect(Comment.first.text).to eq("Yep!")
    end
    it "should prevent a logged-in user from update another user's comments" do
      user = User.find_by(email: "user5@gmail.com")
      comment = Comment.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      patch "/api/comments/#{comment.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      },
      params: {
        text: "Yep!"
      }
      expect(response).to have_http_status(403)
      expect(Comment.first.text).to eq("Nope")
    end
  end
  describe "DELETE /comments/:id" do
    it "should allow a logged-in user to destroy one of their comments" do
      user = User.find_by(email: "user4@gmail.com")
      comment = Comment.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      delete "/api/comments/#{comment.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      expect(response).to have_http_status(200)
      expect(Comment.count).to eq(0)
    end
    it "should prevent a logged-in user from destroying another user's comments" do
      user = User.find_by(email: "user5@gmail.com")
      comment = Comment.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      delete "/api/comments/#{comment.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      expect(response).to have_http_status(403)
      expect(Comment.count).to eq(1)
    end
  end
end
