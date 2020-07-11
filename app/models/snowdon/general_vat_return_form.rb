class Snowdon::GeneralVatReturnForm < Snowdon::ApplicationRecord
  include FoodtaxHelper

  belongs_to :vat_return

  def converted_hash_by_order_number
    @converted_hash_by_order_number ||= begin
      converted_hash = {}
      (attributes.keys - %w{id tax_payer created_at updated_at vat_return_id status}).each do |field|
        converted_hash.merge!(self[field].map{ |s| {s["order_number"].to_s => s }  }.inject(:merge))
      end
      converted_hash
    end
  end

  def value_price(order_number)
    converted_hash_by_order_number[order_number]&.dig("value", "amount") || 0
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
