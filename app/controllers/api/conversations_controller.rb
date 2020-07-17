class Api::ConversationsController < ApplicationController

  before_action :authenticate_user

  def index
    @conversations = current_user.conversations
    render "index.json.jb"
  end

  def create
    conversation = Conversation.new(
      sender_id: params[:sender_id],
      recipient_id: params[:recipient_id],
      map_twin: params[:map_twin]
    )
    if conversation.save
      render json: { message: "Conversation created successfully" }, status: :created
    else
      render json: { errors: conversation.errors.full_messages }, status: :bad_request
    end
  end

  # ^^ need to call this from User controller update method (upon address input): https://stackoverflow.com/questions/5767222/rails-call-another-controller-action-from-a-controller
 
  def show
    @conversation = Conversation.find_by(id: params[:id])
    if @conversation.sender_id == current_user.id ||@conversation.recipient_id == current_user.id
      render "show.json.jb"
    else
      render json: {}, status: :forbidden
    end
  end

end
