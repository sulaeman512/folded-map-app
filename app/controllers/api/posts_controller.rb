class Api::PostsController < ApplicationController

  before_action :authenticate_user

  def index
    user = User.find(current_user.id)
    if user.block && user.block_pair
      @posts = Post.where("block_pair_id = ?", user.block.block_pair.id)
      render "index.json.jb"
    else
      render json: {}
    end
  end

  def create
    user = User.find(current_user.id)
    if user.block && user.block_pair
      @post = Post.new(
        block_pair_id: user.block_pair.id,
        user_id: current_user.id,
        text: params[:text],
        image_url: params[:image_url]
      )
      if @post.save
        render "show.json.jb"
      else
        render json: { errors: @post.errors.full_messages }, status: :bad_request
      end
    else
      render json: {}, status: :bad_request
    end
  end

  def show
    @post = Post.find(params[:id])
    block_pair_id = @post.block_pair.id
    user = User.find(current_user.id)
    if user.block && user.block_pair && (user.block_pair.id == block_pair_id)
      render "show.json.jb"
    else
      render json: {}, status: :forbidden
    end
  end

  def update
    @post = Post.find(params[:id])
    if current_user.id == @post.user_id
      @post.update(
        text: params[:text] || @post.text,
        image_url: params[:image_url] || @post.image_url
      )
      if @post.save
        render "show.json.jb"
      else
        render json: { errors: @post.errors.full_messages }, status: :bad_request
      end
    else
      render json: {}, status: :bad_request
    end
  end

  def destroy
    @post = Post.find(params[:id])
    if current_user.id == @post.user_id
      @post.destroy
      render json: {message: "Post deleted successfully"}
    else
      render json: {}, status: :forbidden
    end
  end

end
