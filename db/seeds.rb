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

classification_code_categories = parse_to_hash("#{Dir.getwd}/classification_code_categories.csv")
ClassificationCodeCategory.import!(
    classification_code_categories,
    on_duplicate_key_update: {
        conflict_target: %i(classification_code),
        columns: %i(category updated_at)
    }
)

account_classification_rules = parse_to_hash("#{Dir.getwd}/account_classification_rules.csv")
AccountClassificationRule.import!(
    account_classification_rules,
    on_duplicate_key_update: {
        conflict_target: %i(category classification_code account_classification_code),
        columns: %i(account_classification_name classification_id updated_at)
    }
)