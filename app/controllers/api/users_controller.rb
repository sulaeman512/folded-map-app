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
      render json: { message: "User created successfully" }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :bad_request
    end
  end

  # ^^ Start with address info too?

  def show
    @user = User.find(params[:id])
    render "show.json.jb"
  end

  def update
    @user = User.find(params[:id])
    if @user.id == current_user.id
      @user.update(
        first_name: params[:first_name] || @user.first_name,
        last_name: params[:last_name] || @user.last_name,
        email: params[:email] || @user.email,
        street_num: params[:street_num] || @user.street_num,
        street_direction: params[:street_direction] || @user.street_direction,
        street: params[:street] || @user.street,
        zip_code: params[:zip_code] || @user.zip_code,
        block_id: params[:block_id] || @user.block_id,
        image_url: params[:image_url] || @user.image_url,
        how_i_got_here: params[:how_i_got_here] || @user.email,
        what_i_like: params[:what_i_like] || @user.what_i_like,
        what_i_would_change: params[:what_i_would_change] || @user.what_i_would_change,
        birthday: params[:birthday] || @user.birthday,
      )
      if @user.save
        render "show.json.jb"
      else
        render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {}, status: :forbidden
    end

    # ^^ still need to build in a model method to assign block_id based on input address (and maybe to adjust address based on HERE API's result)

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

  def update_password
    # separate update action needed for password and/or email???
  end

end
