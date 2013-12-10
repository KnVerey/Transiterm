class TermRecord < ActiveRecord::Base
	belongs_to :collection, touch: true
	belongs_to :domain
	belongs_to :source

	validates :domain, presence: true
	validates :source, presence: true
end
