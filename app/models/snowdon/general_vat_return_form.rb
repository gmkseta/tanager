class Snowdon::GeneralVatReturnForm < Snowdon::ApplicationRecord
  include FoodtaxHelper

  enum status: {
    declarable: 0,
    supplementary_data: 1,
    not_declarable: 2,
  }

  belongs_to :vat_return

  validates :status, presence: true

  def to_h(field_name)
    self[field_name].map { |s| { s["order_number"] => s } }.inject(:merge)
  end

  def declarable?
    status.eql?(:declarable)
  end

  def converted_hash_by_order_number
    @converted_hash_by_order_number ||= begin
      converted_hash = {}
      (attributes.keys - %w{id tax_payer created_at updated_at vat_return_id status summaries}).each do |field|
        converted_hash.merge!(to_h(field))
      end
      converted_hash
    end
  end

  def value_price(order_number)
    converted_hash_by_order_number[order_number]&.dig("value", "price") || 0
  end

  def value_vat(order_number)
    converted_hash_by_order_number[order_number]&.dig("value", "vat") || 0
  end

  def period_start_date
    vat_return.period.eql?(1) ? "#{vat_return.year}0101"  : "#{vat_return.year}0701"
  end

  def period_end_date
    vat_return.period.eql?(1) ? "#{vat_return.year}0630"  : "#{vat_return.year}1231"
  end

  def primary_classification
    converted_hash_by_order_number["28"]
  end

  def date_range
    vat_return_period_datetime_range(
      taxation_type: vat_return.business.taxation_type,
      year: vat_return.year,
      period: vat_return.period,
    )
  end
end
