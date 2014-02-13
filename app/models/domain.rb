class Domain < ActiveRecord::Base
	include PgSearch
	include Searchable
	searchable_fields :name
	include LookupModel
	lookup_field :name

	belongs_to :user
	has_many :term_records

	validates :name, :user_id, presence: true
	validates :name, uniqueness: { scope: :user_id }
end
