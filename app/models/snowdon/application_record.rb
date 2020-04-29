class Snowdon::ApplicationRecord < ApplicationRecord
  self.abstract_class = true
  establish_connection SNOWDON_DB

  after_initialize :readonly!
  class << self
    alias_method :ar, :arel_table
  end
end
