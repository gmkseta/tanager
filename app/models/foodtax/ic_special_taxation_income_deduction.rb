module Foodtax
  class IcSpecialTaxationIncomeDeduction < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :deduct_cd
    self.table_name = "ic_1061"

    belongs_to :ic_person, foreign_key: :person_cd, primary_key: :person_cd

    def self.find_or_initialize_by_declare_user(declare_user, deduct_cd)
      deduction = self.find_or_initialize_by(
        cmpy_cd: "00025",
        person_cd: declare_user.person_cd,
        term_cd: "2019",
        declare_seq: "1",
        deduct_cd: deduct_cd,
      )
    end

    def self.import_deductions(declare_user)
      personal_deduction = self.find_or_initialize_by_declare_user(
        declare_user,
        "105"
      )
      personal_deduction.create_deduction(
        0,
        declare_user.hometax_individual_income.personal_pension_deduction,
        ""
      )
      personal_deduction.save!

      merchant_deduction = self.find_or_initialize_by_declare_user(
        declare_user,
        "115"
      )
      merchant_deduction.create_deduction(
        declare_user.hometax_individual_income.merchant_pension,
        declare_user.hometax_individual_income.merchant_pension_deduction,
        declare_user.businesses.first.registration_number
      )
      merchant_deduction.save!
    end

    def create_deduction(origin_amount, limited_amount, registration_number)
      self.gonggam_type = ""
      self.target_amt = origin_amount
      self.deduct_amt = limited_amount
      self.biz_reg_no = ""
    end
  end
end