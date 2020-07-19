class Snowdon::GeneralVatReturnPreForm < Snowdon::ApplicationRecord
  belongs_to :vat_return

  def classification_limit_reached?
    sales_amount_by_other_classifications&.count.to_i >= 2
  end

  def update_sales(code, amount)
    hash = sales_amount_by_other_classifications || {}

    hash[code] = amount

    update(sales_amount_by_other_classifications: hash.compact.presence)
  end
end
