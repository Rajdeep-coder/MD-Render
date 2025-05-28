class DeviceToken < ApplicationRecord
	self.table_name = :device_tokens
	belongs_to :my_dairy
	belongs_to :customer
end
