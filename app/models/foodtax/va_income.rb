module Foodtax
  class VaIncome < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_dates, :default_user_id, :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    NON_VALIDATABLE_ATTRIBUTES = %w(REG_DATE UPDT_DATE REG_USER_ID UPDT_USER_ID)
    validates_presence_of Foodtax::VaIncome.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr)}

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
      )
    end

    def self.import_form(form)
      va_income = self.find_or_initialize_by_vat_form(form)
      index = 1
      %w(28 29 30).each do |k|       
        values = form.converted_hash_by_order_number[k]
        next if values.blank? || values["amount"].blank?
        va_income.seq_no = index
        va_income.uptae = values["name"]
        va_income.jongmok = values["item"]
        va_income.upjong_cd = values["code"]
        va_income.income_amt = values["amount"]
        va_income.easyvat_rate_type = ""
        va_income.easyvat_rate = ""
        va_income.save!
        index = index + 1
      end
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.declare_seq ||= "1"
      self.tax_type = "1"
      self.declare_seq = "1"
      self.tax_type = "1"
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
