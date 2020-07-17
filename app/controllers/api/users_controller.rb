class Api::UsersController < ApplicationController
  
  before_action :authenticate_user, except: [:create]

  def create
    @user = User.new(
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )
    if @user.save
      render "show.json.jb"
    else
      render json: { errors: @user.errors.full_messages }, status: :bad_request
    end
  end

  def show
    @user = User.find(params[:id])
    if (@user.id == current_user.id) || Conversation.find_by(sender_id: current_user.id, recipient_id: @user.id) || Conversation.find_by(sender_id: @user.id, recipient_id: current_user.id)
      render "show.json.jb"
    else
      render json: {}, status: :forbidden
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.id == current_user.id
      @user.update(
        first_name: params[:first_name] || @user.first_name,
        last_name: params[:last_name] || @user.last_name,
        email: params[:email] || @user.email,
        block_id: params[:block_id] || @user.block_id,
        image_url: params[:image_url] || @user.image_url,
        how_i_got_here: params[:how_i_got_here] || @user.email,
        what_i_like: params[:what_i_like] || @user.what_i_like,
        what_i_would_change: params[:what_i_would_change] || @user.what_i_would_change,
        birthday: params[:birthday] || @user.birthday
      )
      if params[:street_num] || params[:street_direction] || params[:street] || params[:zip_code]
        User.match_address(@user, params[:street_num], params[:street_direction], params[:street], params[:zip_code])
      end
      if params[:password]
        if @user.authenticate(params[:old_password])
          @user.update!(
            password: params[:password],
            password_confirmation: params[:password_confirmation]
          )
        end
      end
      if @user.save
        render "show.json.jb"
      else
        render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {}, status: :forbidden
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.id == current_user.id
      @user.destroy
      render json: {message: "User deleted successfully"}
    else
      render json: {}, status: :forbidden
    end
  end

end
