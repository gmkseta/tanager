class Classification < ApplicationRecord
  has_many :simplified_bookkeepings

  scope :relations, ->{ where(classification_type: "Relation") }
  scope :business_expenses, ->{ where(classification_type: "BusinessExpense") }
  scope :account_classifications, ->{ where(classification_type: "AccountClassification") }
  scope :banks, ->{ where(classification_type: "Bank") }
  scope :personal_cards, ->{ where(classification_type: "PersonalCard") }

  EXPENSE_INVOICE_CLASSIFICATION = [18, 19, 53]
  PERSONAL_CARD_CLASSIFICATION_ID = 53

  def self.with_amount(classifications, results, declare_user_id)
    classifications.each do |c|
      c["amount"] = results[c["id"]] || 0
      c["amount"] += BusinessExpense.personal_cards_sum(declare_user_id) if c["id"].eql?(Classification::PERSONAL_CARD_CLASSIFICATION_ID)
    end
    classifications
  end
end
