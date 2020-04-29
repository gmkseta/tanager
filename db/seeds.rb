# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
def parse_to_hash(file_path, col_sep = ",", columns = nil)
  rows = CSV.read(file_path, col_sep: col_sep)
  header = rows[0]
  selected_columns = columns.nil? ? header : columns

  rows[1..-1].map do |row|
    header.zip(row).to_h.select { |k, v| selected_columns.include?(k.to_s) }
  end
end

parse_to_hash("#{Dir.getwd}/classification_code_categories.csv").map do |params|
  ClassificationCodeCategory.create!(params)
end

parse_to_hash("#{Dir.getwd}/account_classification_rules.csv").map do |params|
  AccountClassificationRule.create!(params)
end
