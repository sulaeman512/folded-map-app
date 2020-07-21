class Api::ConversationsController < ApplicationController

  before_action :authenticate_user

  def index
    @conversations = current_user.conversations
    render "index.json.jb"
  end
 
  def create
    sender = current_user
    recipient = User.find_by(id: params[:recipient_id])
    if Conversation.between(current_user.id, recipient.id).present?
      @conversation = Conversation.between(sender.id, recipient.id).first
      redirect_to "show.json.jb"
    elsif current_user.block == nil
      render json: {}, status: 400
    elsif sender.block_pair.id == recipient.block_pair.id
      @conversation = Conversation.create!(
        sender_id: current_user.id,
        recipient_id: params[:recipient_id],
      )
      render "show.json.jb"
    else
      render json: {}, status: :forbidden
    end
  end

  def show
    @conversation = Conversation.find_by(id: params[:id])
    if @conversation == nil
      render json: {}, status: :not_found
    elsif @conversation.sender_id == current_user.id || @conversation.recipient_id == current_user.id
      render "show.json.jb"
    else
      render json: {}, status: :forbidden
    end
  end

end
