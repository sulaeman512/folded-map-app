class Api::MessagesController < ApplicationController
  
  before_action :authenticate_user

  def create
    @conversation = Conversation.find_by(id: params[:conversation_id])
    if @conversation.sender_id == current_user.id || @conversation.recipient_id == current_user.id
      message = Message.new(
        conversation_id: params[:conversation_id],
        text: params[:text],
        user_id: current_user.id
      )
      if message.save
        render json: { message: "Message created successfully" }, status: :created
      else
        render json: { errors: conversation.errors.full_messages }, status: :bad_request
      end
    else
      render json: {}, status: :forbidden
    end
  end

end
