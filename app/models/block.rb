class Block < ApplicationRecord

  has_many :users
  belongs_to :block_pair

end
