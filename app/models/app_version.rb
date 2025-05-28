class AppVersion < ApplicationRecord
	validates :name, :platform, :version, presence: true
  validates :required, inclusion: { in: [true, false] }
end
