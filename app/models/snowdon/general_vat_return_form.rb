class Snowdon::GeneralVatReturnForm < Snowdon::ApplicationRecord
  belongs_to :vat_return

  def converted_hash_by_order_number
    @converted_hash_by_order_number ||= begin
      converted_hash = {}
      (accessed_fields - %w{id tax_payer created_at updated_at vat_return_id status}).each do |field|
        converted_hash.merge!(self[field].map{ |s| {s["order_number"].to_s => s }  }.inject(:merge))
      end
      converted_hash
    end
  end
end
