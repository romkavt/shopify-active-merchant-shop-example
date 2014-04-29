class Order < ActiveRecord::Base
	has_many :product
end
