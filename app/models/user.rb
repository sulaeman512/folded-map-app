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

  def self.match_address(user, street_num, street_direction, street, zip_code)
    street = street.split(" ").join("+")
    request = HTTP.get("https://geocode.search.hereapi.com/v1/geocode?q=#{street_num}+#{street_direction}+#{street}+#{zip_code}&apiKey=#{Rails.application.credentials.here_api[:api_key]}")
    latitude = request.parse["items"][0]["position"]["lat"]
    longitude = request.parse["items"][0]["position"]["lng"]
    house_number = request.parse["items"][0]["address"]["houseNumber"]
    direction = request.parse["items"][0]["address"]["street"][0..0] #grabs first character
    street = request.parse["items"][0]["address"]["street"][2..-1] #shaves off direction and space
    postal_code = request.parse["items"][0]["address"]["postalCode"][0..4]
    user.update(
      street_num: house_number || user.street_num,
      street_direction: direction || user.street_direction,
      street: street || user.street,
      zip_code: postal_code || user.zip_code
    )
  end

  blocks = {
    nw_8_7: [[41.92473, -87.7074], [41.9321, -87.69743]], # 3
    nw_8_8: [[41.93203, -87.70762], [41.93939, -87.6976]], # 5
    nw_8_9: [[41.93929, -87.7078], [41.9467, -87.69782]], # 7
    nw_9_7: [[41.92462, -87.71721], [41.93203, -87.70686]], # Temp IDs - 1
    nw_9_8: [[41.93192, -87.71741], [41.93929, -87.7074]], # 9
    nw_9_9: [[41.93923, -87.7176], [41.94663, -87.70762]], # 11
    
    sw_8_7: [[41.83004, -87.70482], [41.83742, -87.69481]], # 4
    sw_8_8: [[41.82259, -87.70459], [41.83007, -87.69461]], # 6
    sw_8_9: [[41.81543, -87.70443], [41.82278, -87.69441]], # 8
    sw_9_7: [[41.83004, -87.71461], [41.83723, -87.70459]], # Temp IDs - 2
    sw_9_8: [[41.82244, -87.714365], [41.83017, -87.70443]], # 10
    sw_9_9: [[41.815315, -87.7142025], [41.82259, -87.70425]] # 12
  }

end
