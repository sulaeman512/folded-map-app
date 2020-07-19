require 'rails_helper'

RSpec.describe "Posts", type: :request do
  
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
  end

  describe "GET /posts" do
    it "should allow a logged-in user to view an index of posts in their block pair" do
      user = User.find_by(email: "user4@gmail.com")
      block_pair = BlockPair.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      get "/api/posts", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      block_pair = BlockPair.first
      posts = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(block_pair.posts.first.text).to eq("Blah blah")
      expect(block_pair.posts.last.text).to eq("Blah blah")
    end
    it "should prevent a guest user from viewing any posts" do
      get "/api/posts"
      posts = JSON.parse(response.body)
      expect(response).to have_http_status(401)
    end
  end
  describe "POST /posts" do
    it "should allow a logged-in user to create a post in their block pair" do
      user = User.find_by(email: "user4@gmail.com")
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      post "/api/posts", headers: {
        "Authorization": "Bearer #{jwt}"
      },
      params: {
        text: "Hello'm",
        image_url: "hellom.jpg"
      }
      posts = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(Post.last.text).to eq("Hello'm")
      expect(Post.count).to eq(3)
    end
    it "should prevent a logged-in without a block/block pair from creating a post" do
      user = User.find_by(email: "user1@gmail.com")
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      post "/api/posts", headers: {
        "Authorization": "Bearer #{jwt}"
      },
      params: {
        block_pair_id: 1,
        text: "Hello'm",
        image_url: "hellom.jpg"
      }
      posts = JSON.parse(response.body)
      expect(response).to have_http_status(400)
      expect(Post.count).to eq(2)
    end
  end
  describe "GET /posts/:id" do
    it "should allow a logged-in user to view a post in their block pair" do
      user = User.find_by(email: "user4@gmail.com")
      post = Post.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      get "/api/posts/#{post.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      post = JSON.parse(response.body)
      expect(response).to have_http_status(200)
    end
    it "should prevent a logged-in user from viewing a post outside of their block pair" do
      user = User.find_by(email: "user4@gmail.com")
      post = Post.last
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      get "/api/posts/#{post.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      post = JSON.parse(response.body)
      expect(response).to have_http_status(403)
    end
    it "should prevent a guest user from viewing any posts" do
      post = Post.first
      get "/api/posts/#{post.id}"
      post = JSON.parse(response.body)
      expect(response).to have_http_status(401)
    end
  end
  describe "PATCH /posts/:id" do
    it "should allow a logged-in user to update their own post" do
      user = User.find_by(email: "user6@gmail.com")
      post = Post.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      patch "/api/posts/#{post.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      },
      params: {
        text: "Everybody, yeah",
        image_url: "rockyourbodyyeah.jpg"
      }
      post = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(post["text"]).to eq("Everybody, yeah")
    end
    it "should prevent a logged-in user from update another user's post" do
      user = User.find_by(email: "user5@gmail.com")
      post = Post.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      patch "/api/posts/#{post.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      },
      params: {
        text: "Everybody, yeah",
        image_url: "rockyourbodyyeah.jpg"
      }
      expect(response).to have_http_status(400)
      expect(post.text).to eq("Blah blah")
    end
  end
  describe "DELETE /posts/:id" do
    it "should allow a logged-in user to destroy their own post" do
      user = User.find_by(email: "user6@gmail.com")
      post = Post.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      delete "/api/posts/#{post.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      expect(response).to have_http_status(200)
      expect(Post.count).to eq(1)
    end
    it "should prevent a logged-in user from destroying another user's post" do
      user = User.find_by(email: "user5@gmail.com")
      post = Post.first
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      delete "/api/posts/#{post.id}", headers: {
        "Authorization": "Bearer #{jwt}"
      }
      expect(response).to have_http_status(403)
      expect(Post.count).to eq(2)
    end
  end
end
