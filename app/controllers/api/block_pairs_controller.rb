class Api::BlockPairsController < ApplicationController

  before_action :authenticate_user

  def show
    @block_pair = BlockPair.find_by(id: params[:id])
    @user = User.find(current_user.id)
    if @block_pair == nil
      render json: {}, status: :not_found
    elsif @user.block && @user.block.block_pair && (@user.block_pair.id == @block_pair.id)
      render "show.json.jb"
    else
      render json: {}, status: :unauthorized
    end
  end

end
