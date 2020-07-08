module Foodtax
  class VaPenalty < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.table_name = "va_addtax"
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_dates, :default_user_id, :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    NON_VALIDATABLE_ATTRIBUTES = %w(REG_DATE UPDT_DATE REG_USER_ID UPDT_USER_ID)
    validates_presence_of Foodtax::VaPenalty.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr)}

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
      )
    end

    def import_form(form)
      supply1 = form.converted_hash_by_order_number["61"]
      supply2 = form.converted_hash_by_order_number["67"]
      supply4 = form.converted_hash_by_order_number["73"]
      supply5 = form.converted_hash_by_order_number["74"]
      total_sum = form.converted_hash_by_order_number["79"]

      self.supply1_amt = supply1.dig("value", "amount")
      self.add1_amt = supply1.dig("value", "vat")

      self.supply2_amt = supply2.dig("value", "amount")
      self.add2_amt = supply2.dig("value", "vat")

      self.supply3_amt = 0
      self.add3_amt = 0

      %w(69 70 71 72).each do |key|        
        penalty = form.converted_hash_by_order_number[key]
        self.supply3_amt += penalty.dig("value", "amount")
        self.add3_amt += penalty.dig("value", "amount")
      end

      self.supply4_amt = supply4.dig("value", "amount")
      self.add4_amt = supply4.dig("value", "vat")

      self.supply5_amt = supply5.dig("value", "amount")
      self.add5_amt = supply5.dig("value", "vat")
      
      self.add_sum_amt = total_sum.dig("value", "vat")
      save!
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.term_cd ||= "#{tax_declare_year}#{tax_declare_term}"
      self.declare_seq ||= "1"
    end

    def default_dates
      self.REG_DATE ||= Time.now.strftime("%F %T")
      self.UPDT_DATE ||= Time.now.strftime("%F %T")
    end

    def default_user_id
      self.REG_USER_ID = "KCD" if self.REG_USER_ID.blank?
      self.UPDT_USER_ID = "KCD" if self.UPDT_USER_ID.blank?
    end
  end
end
