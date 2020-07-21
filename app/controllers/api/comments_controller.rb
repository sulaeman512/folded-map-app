class Api::CommentsController < ApplicationController

  before_action :authenticate_user

  def create
    post = Post.find_by(id: params[:post_id])
    if current_user.block_pair && (current_user.block_pair.id == post.block_pair_id)
      @comment = Comment.new(
        user_id: current_user.id,
        post_id: params[:post_id],
        text: params[:text]
      )
      if @comment.save
        render "show.json.jb"
      else
        render json: { errors: @post.errors.full_messages }, status: :bad_request
      end
    else
      render json: {}, status: :bad_request
    end
  end

  def update
    @comment = Comment.find_by(id: params[:id])
    if current_user.id == @comment.user_id
      @comment.update(
        text: params[:text] || @comment.text
      )
      if @comment.save
        render "show.json.jb"
      else
        render json: { errors: @post.errors.full_messages }, status: :bad_request
      end
    else
      render json: {}, status: :forbidden
    end
  end

  def destroy
    @comment = Comment.find_by(id: params[:id])
    if current_user.id == @comment.user_id
      @comment.destroy
      render json: {message: "Comment deleted successfully"}
    else
      render json: {}, status: :forbidden
    end
  end

end
