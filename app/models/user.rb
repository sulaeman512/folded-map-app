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

  def self.check_block(block_key, boundary_coordinates)
    @block_matches = []
    if @latitude.between?(boundary_coordinates[0][0], boundary_coordinates[1][0]) && @longitude.between?(boundary_coordinates[0][1], boundary_coordinates[1][1])
      @block_matches << block_key
    end
    if @block_matches.length == 1
      block_match = Block.find_by(name: @block_matches[0])
      @user.update(
        block_id: block_match.id || @user.block_id
      )
    elsif @block_matches.length > 1
      block_1 = @block_matches[0].to_s.split("_")
      block_2 = @block_matches[1].to_s.split("_")
      if block_1[0] == "nw" && block_2[0] == "nw"
        if street_direction.downcase == "n"
          if street_num.to_i.even?
            if block_1[1] > block_2[1]
              block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: block_match || @user.block_id
              )
            else
              block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: block_match || @user.block_id
              )
            end
          else
            if block_1[1] < block_2[1]
              block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: block_match || @user.block_id
              )
            else
              block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: block_match || @user.block_id
              )
            end
          end
        elsif street_direction.downcase == "w"
          if street_num.to_i.even?
            if block_1[2] > block_2[2]
              block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: block_match || @user.block_id
              )
            else
              block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: block_match || @user.block_id
              )
            end
          else
            if block_1[2] < block_2[2]
              block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: block_match || @user.block_id
              )
            else
              block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: block_match || @user.block_id
              )
            end
          end
        end
      elsif block_1[0] == "sw" && block_2[0] == "sw"
        if street_direction.downcase == "s"
          if street_num.to_i.even?
            if block_1[1] > block_2[1]
              block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: block_match || @user.block_id
              )
            else
              block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: block_match || @user.block_id
              )
            end
          else
            if block_1[1] < block_2[1]
              block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: block_match || @user.block_id
              )
            else
              block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: block_match || @user.block_id
              )
            end
          end
        elsif street_direction.downcase == "w"
          if street_num.to_i.even?
            if block_1[2] > block_2[2]
              block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: block_match || @user.block_id
              )
            else
              block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: block_match || @user.block_id
              )
            end
          else
            if block_1[2] < block_2[2]
              block_match = Block.where("name = ?", @block_matches[1])
              @user.update(
                block_id: block_match || @user.block_id
              )
            else
              block_match = Block.where("name = ?", @block_matches[0])
              @user.update(
                block_id: block_match || @user.block_id
              )
            end
          end
        end
      end
    end
  end

  require 'http'

  def self.match_address(user, street_num, street_direction, street, zip_code)
    
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
    
    street = street.split(" ").join("+")
    request = HTTP.get("https://geocode.search.hereapi.com/v1/geocode?q=#{street_num}+#{street_direction}+#{street}+#{zip_code}&apiKey=#{Rails.application.credentials.here_api[:api_key]}")
    @latitude = request.parse["items"][0]["position"]["lat"]
    @longitude = request.parse["items"][0]["position"]["lng"]
    house_number = request.parse["items"][0]["address"]["houseNumber"]
    direction = request.parse["items"][0]["address"]["street"][0..0] #grabs first character
    street = request.parse["items"][0]["address"]["street"][2..-1] #shaves off direction and space
    postal_code = request.parse["items"][0]["address"]["postalCode"][0..4]
    @user.update(
      street_num: house_number || @user.street_num,
      street_direction: direction || @user.street_direction,
      street: street || @user.street,
      zip_code: postal_code || @user.zip_code
    )
    @blocks.each do |k, v|
      check_block(k, v)
    end
  end

end
