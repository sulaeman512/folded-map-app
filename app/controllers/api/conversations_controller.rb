class Api::ConversationsController < ApplicationController

  before_action :authenticate_user

  def index
    @conversations = current_user.conversations
    render "index.json.jb"
  end
 
  def create
    sender = User.find_by(id: params[:sender_id])
    recipient = User.find_by(id: params[:recipient_id])
    if current_user.id == sender.id && Conversation.between(current_user.id, recipient.id).present?
      @conversation = Conversation.between(sender.id, recipient.id).first
      redirect_to "show.json.jb"
    elsif current_user.block == nil
      render json: {}, status: 400
    elsif current_user.id == sender.id && sender.block_pair.id == recipient.block_pair.id
      @conversation = Conversation.create!(
        sender_id: params[:sender_id],
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

  # Conversations create action is triggered by User update action (when address params are provided)

end
