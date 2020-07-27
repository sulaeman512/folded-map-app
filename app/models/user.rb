class User < ApplicationRecord

  has_secure_password
  validates :email, presence: true, uniqueness: true

  belongs_to :block, optional: true
  has_one :block_pair, through: :block
  has_many :messages
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  # belongs_to block_pair w/ custom method
  def block_pair
    if block
      block.block_pair
    else
      nil
    end
  end

  # has_many conversations w/ custom method
  def conversations
    Conversation.where("sender_id = ? OR recipient_id = ?", id, id)
  end

  # method to display user names on front end
  def display_name
    first_name + " " + last_name[0]
  end

  # block coordinate data (SW & NE corners)
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


  # Triggered by user controller update action (only if address params provided); sends user input to HERE geocoding API, retrieves lat/lng, and standardizes input data for cohesive DB data
  def self.match_address(user, user_street_num, user_street_direction, user_street, user_zip_code)
    
    @user = user
    user_street = user_street.split(" ").join("+") # bridges spaces that would otherwise break URL in GET request below

    request = HTTP.get("https://geocode.search.hereapi.com/v1/geocode?q=#{user_street_num}+#{user_street_direction}+#{user_street}+#{user_zip_code}&apiKey=#{Rails.application.credentials.here_api[:api_key]}").parse

    @latitude = request["items"][0]["position"]["lat"]
    @longitude = request["items"][0]["position"]["lng"]
    @house_number = request["items"][0]["address"]["houseNumber"]
    @direction = request["items"][0]["address"]["street"][0..0] # grabs first character (N, S, E, or W)
    @street = request["items"][0]["address"]["street"][2..-1] # shaves off first 2 characters (direction and space that follows)
    @postal_code = request["items"][0]["address"]["postalCode"][0..4]
    
    # standardizes user input based on API data
    @user.update(
      street_num: @house_number || @user.street_num,
      street_direction: @direction || @user.street_direction,
      street: @street || @user.street,
      zip_code: @postal_code || @user.zip_code
    )

    # searches for map twin
    if @direction == "N" || @direction == "S"
      check_map_twin_north_south
    else
      check_map_twin_lat_lng
    end

    # creates conversation between map twins (if found)
    if @map_twin
      conversation = Conversation.create(
        sender_id: @user.id,
        recipient_id: @map_twin.id,
        map_twin: true
      )
    end 

    # assigns block id to user
    @block_matches = []
    @blocks.each do |k, v|
      find_block_match(k, v)
    end
    assign_block_match

  end


  # Triggered by match_address method; seeks direct N/S user address matches
  def self.check_map_twin_north_south
    
    street = @street.split(" ").join("+")
    
    if @direction == "N"
      @search_direction = "S"
    else
      @search_direction = "N"
    end

    map_twin_address = HTTP.get("https://geocode.search.hereapi.com/v1/geocode?q=#{@house_number}+#{@search_direction}+#{street}+Chicago+IL&apiKey=#{Rails.application.credentials.here_api[:api_key]}").parse
    map_twin_house_number = map_twin_address["items"][0]["address"]["houseNumber"]
    map_twin_direction = map_twin_address["items"][0]["address"]["street"][0..0]
    map_twin_street = map_twin_address["items"][0]["address"]["street"][2..-1]
    map_twin_postal_code = map_twin_address["items"][0]["address"]["postalCode"][0..4]
    
    if (map_twin_direction != @direction) && (map_twin_postal_code != @postal_code) && (map_twin_house_number == @house_number) && (map_twin_street == @street)
      @map_twin = User.find_by(street_direction: map_twin_direction, street_num: map_twin_house_number, street: map_twin_street)
    else
      check_map_twin_lat_lng
    end

  end


  # Triggered by match_address OR check_map_twin_north_south methods; seeks map twin for users on either E/W streets or N/S streets that don't have a direct address match on the other side of the city
  def self.check_map_twin_lat_lng
    
    if @latitude > 41.88098667 # average of all latitude points at Madison St intersections in Chicago
      map_twin_lat = 41.88098667 - (@latitude - 41.88098667)
    else
      map_twin_lat = 41.88098667 + (41.88098667 - @latitude)
    end

    map_twin_address = HTTP.get("https://revgeocode.search.hereapi.com/v1/revgeocode?at=#{map_twin_lat}%2C#{@longitude}&lang=en-US&apiKey=#{Rails.application.credentials.here_api[:api_key]}").parse
    map_twin_house_number = map_twin_address["items"][0]["address"]["houseNumber"]
    map_twin_direction = map_twin_address["items"][0]["address"]["street"][0..0]
    map_twin_street = map_twin_address["items"][0]["address"]["street"][2..-1]
    map_twin_postal_code = map_twin_address["items"][0]["address"]["postalCode"][0..4]
    
    @map_twin = User.find_by(street_direction: map_twin_direction, street_num: map_twin_house_number, street: map_twin_street, zip_code: map_twin_postal_code)

  end


  # Triggered by match_address; looks for block match(es)
  def self.find_block_match(block_key, boundary_coords)
    if @latitude.between?(boundary_coords[0][0], boundary_coords[1][0]) && @longitude.between?(boundary_coords[0][1], boundary_coords[1][1])
      @block_matches << block_key.to_s
    end
  end


  # Triggered by match_address; if more than one match, resolves overlapping match (does not deal with 'E' streets yet [anything East of State St])
  def self.assign_block_match
    if @block_matches.length == 1
      @block_match = Block.find_by(name: @block_matches[0])
      @user.update(
        block_id: @block_match.id || @user.block_id
      )
    elsif @block_matches.length > 1
      block1 = @block_matches[0].split("_")
      block2 = @block_matches[1].split("_")
      if @direction == "N" || @direction == "S"
        if @house_number.to_i.even?
          if block1[1] > block2[1]
            @block_match = Block.find_by(name: @block_matches[0])
            @user.update(
              block_id: @block_match.id || @user.block_id
            )
          else
            @block_match = Block.find_by(name: @block_matches[1])
            @user.update(
              block_id: @block_match.id || @user.block_id
            )
          end
        else
          if block1[1] < block2[1]
            @block_match = Block.find_by(name: @block_matches[0])
            @user.update(
              block_id: @block_match.id || @user.block_id
            )
          else
            @block_match = Block.find_by(name: @block_matches[1])
            @user.update(
              block_id: @block_match.id || @user.block_id
            )
          end
        end
      else
        if block1[0] == "nw" && block2[0] == "nw"  
          if @direction == "W"
            if @house_number.to_i.even?
              if block1[2] > block2[2]
                @block_match = Block.find_by(name: @block_matches[0])
                @user.update(
                  block_id: @block_match.id || @user.block_id
                )
              else
                @block_match = Block.find_by(name: @block_matches[1])
                @user.update(
                  block_id: @block_match.id || @user.block_id
                )
              end
            else
              if block1[2] < block2[2]
                @block_match = Block.find_by(name: @block_matches[0])
                @user.update(
                  block_id: @block_match.id || @user.block_id
                )
              else
                @block_match = Block.find_by(name: @block_matches[1])
                @user.update(
                  block_id: @block_match.id || @user.block_id
                )
              end
            end
          end
        elsif block1[0] == "sw" && block2[0] == "sw"
          if @direction == "W"
            if @house_number.to_i.even?
              if block1[2] > block2[2]
                @block_match = Block.find_by(name: @block_matches[1])
                @user.update(
                  block_id: @block_match.id || @user.block_id
                )
              else
                @block_match = Block.find_by(name: @block_matches[0])
                @user.update(
                  block_id: @block_match.id || @user.block_id
                )
              end
            else
              if block1[2] < block2[2]
                @block_match = Block.find_by(name: @block_matches[1])
                @user.update(
                  block_id: @block_match.id || @user.block_id
                )
              else
                @block_match = Block.find_by(name: @block_matches[0])
                @user.update(
                  block_id: @block_match.id || @user.block_id
                )
              end
            end
          end
        end
      end
    end
  end
end
