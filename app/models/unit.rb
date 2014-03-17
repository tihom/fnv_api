class Unit < ActiveRecord::Base
	default_scope { where(is_hidden: 0) } 

	self.primary_key = 'unit_id'
	has_and_belongs_to_many :items, -> {uniq}

	def self.kg_unit_id
		@@kg_unit_id ||= Unit.where("LOWER(unit_name) = ? AND is_hidden = ?", "kg", 0).first.try(:id)
	end
end