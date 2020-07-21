class Api::BlockPairsController < ApplicationController

  before_action :authenticate_user

  def show
    @block_pair = current_user.block_pair
    if @block_pair == nil
      render json: {}, status: :not_found
    elsif current_user.block_pair.id == @block_pair.id
      render "show.json.jb"
    else
      render json: {}, status: :forbidden
    end
  end

end