class Api::ConversationsController < ApplicationController

  before_action :authenticate_user

  def index
    @conversations = current_user.conversations
    render "index.json.jb"
  end
 
  def show
    @conversation = Conversation.find_by(id: params[:id])
    if @conversation == nil
      render json: {}, status: :not_found
    elsif @conversation.sender_id == current_user.id ||@conversation.recipient_id == current_user.id
      render "show.json.jb"
    else
      render json: {}, status: :forbidden
    end
  end

  # Conversations create action is triggered by User update action (when address params are provided)

end
