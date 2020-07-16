class User < ApplicationRecord

  has_secure_password
  validates :email, presence: true, uniqueness: true

  belongs_to :block, optional: true
  has_many :messages
  has_many :posts
  has_many :comments

  # belongs_to block_pair w/ custom method
  def block_pair
    block.block_pair
  end

  # has_many conversations w/ custom method
  def conversations
    Conversation.where("sender_id = ? OR recipient_id = ?", id, id)
  end

  def display_name
    first_name + " " + last_name[0]
  end

  require 'http'

  # Runs within user controller update action if address params are provided; sends user input to HERE geocoding API, retrieves lat/lng, and standardizes said input for DB storage
  def self.match_address(user, user_street_num, user_street_direction, user_street, user_zip_code)
    
    user_street = user_street.split(" ").join("+")
    @user = user
    @blocks = {
      nw_8_7: [[41.92473, -87.7074], [41.9321, -87.69743]],
      nw_8_8: [[41.93203, -87.70762], [41.93939, -87.6976]],
      nw_8_9: [[41.93929, -87.7078], [41.9467, -87.69782]],
      nw_9_7: [[41.92462, -87.71721], [41.93203, -87.70686]],
      nw_9_8: [[41.93192, -87.71741], [41.93929, -87.7074]],
      nw_9_9: [[41.93923, -87.7176], [41.94663, -87.70762]],
      sw_8_7: [[41.83004, -87.70482], [41.83742, -87.69481]],
      sw_8_8: [[41.82259, -87.70459], [41.83007, -87.69461]],
      sw_8_9: [[41.81543, -87.70443], [41.82278, -87.69441]],
      sw_9_7: [[41.83004, -87.71461], [41.83723, -87.70459]],
      sw_9_8: [[41.82244, -87.714365], [41.83017, -87.70443]],
      sw_9_9: [[41.815315, -87.7142025], [41.82259, -87.70425]]
    }

    request = HTTP.get("https://geocode.search.hereapi.com/v1/geocode?q=#{user_street_num}+#{user_street_direction}+#{user_street}+#{user_zip_code}&apiKey=#{Rails.application.credentials.here_api[:api_key]}")

    @latitude = request.parse["items"][0]["position"]["lat"]
    @longitude = request.parse["items"][0]["position"]["lng"]
    @house_number = request.parse["items"][0]["address"]["houseNumber"]
    @direction = request.parse["items"][0]["address"]["street"][0..0] #grabs first character
    street = request.parse["items"][0]["address"]["street"][2..-1] #shaves off direction and space
    postal_code = request.parse["items"][0]["address"]["postalCode"][0..4]
    
    @user.update(
      street_num: @house_number || @user.street_num,
      street_direction: @direction || @user.street_direction,
      street: street || @user.street,
      zip_code: postal_code || @user.zip_code
    )

    @block_matches = []
    @blocks.each do |k, v|
      find_block_match(k, v)
    end

    assign_block_match

    if @user.block_id != nil
      create_block_pair_conversations
    end

  end

  # Triggered by match_address; looks for block match(es)
  def self.find_block_match(block_key, boundary_coordinates)
    if @latitude.between?(boundary_coordinates[0][0], boundary_coordinates[1][0]) && @longitude.between?(boundary_coordinates[0][1], boundary_coordinates[1][1])
      @block_matches << block_key
    end
  end

  # Triggered by match_address; if more than one match, resolves overlapping match
  def self.assign_block_match
    if @block_matches.length == 1
      @block_match = Block.find_by(name: @block_matches[0])
      @user.update(
        block_id: @block_match.id || @user.block_id
      )
    elsif @block_matches.length > 1
      block1 = @block_matches[0].to_s.split("_")
      block2 = @block_matches[1].to_s.split("_")
      if block1[0] == "nw" && block2[0] == "nw"
        if @direction.downcase == "n"
          if @house_number.to_i.even?
            if block1[1] > block2[1]
              @block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            else
              @block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            end
          else
            if block1[1] < block2[1]
              @block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            else
              @block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            end
          end
        elsif @direction.downcase == "w"
          if @house_number.to_i.even?
            if block1[2] > block2[2]
              @block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            else
              @block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            end
          else
            if block1[2] < block2[2]
              @block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            else
              @block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            end
          end
        end
      elsif block1[0] == "sw" && block2[0] == "sw"
        if @direction.downcase == "s"
          if @house_number.to_i.even?
            if block1[1] > block2[1]
              @block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            else
              @block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            end
          else
            if block1[1] < block2[1]
              @block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            else
              @block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            end
          end
        elsif @direction.downcase == "w"
          if @house_number.to_i.even?
            if block1[2] > block2[2]
              @block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            else
              @block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            end
          else
            if block1[2] < block2[2]
              @block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            else
              @block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: @block_match.id || @user.block_id
              )
            end
          end
        end
      end
    end
  end

  # Triggered by match_address (if block and block_pair exist); creates conversations between new user and all existing users in same block and block pair
  def self.create_block_pair_conversations
    current_user = @user
    block_pair = @block_match.block_pair
    block_pair.users.each do |user|
      if user.id != current_user.id
        conversation = Conversation.create(
          sender_id: current_user.id,
          recipient_id: user.id,
          map_twin: false
        )
      end
    end
  end

end
