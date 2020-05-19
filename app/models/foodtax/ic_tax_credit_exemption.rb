module Foodtax
  class IcTaxCreditExemption < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :seq_no
    self.table_name = "ic_1070"
    after_initialize :default_user_id

    belongs_to :ic_person, foreign_key: :person_cd, primary_key: :person_cd

    def self.find_or_initialize_by_declare_user(declare_user, code)
      ic_tax_credit_exemption = self.find_or_initialize_by(
        cmpy_cd: "00025",
        person_cd: declare_user.person_cd,
        term_cd: "2019",
        declare_seq: "1",
        C0010: code,
      )
      ic_tax_credit_exemption
    end

    def self.import_credit_exemption(declare_user)
      index = 1
      if declare_user.base_tax_credit_amount > 0
        base_tax_credit = self.find_or_initialize_by_declare_user(
          declare_user,
          "284"
        )
        base_tax_credit.create_credit_exemption(index+=1, 0, 70000)
      end

      if declare_user.children_tax_credit_amount > 0
        children_tax_credit = self.find_or_initialize_by_declare_user(
          declare_user,
          "273"
        )
        children_tax_credit.create_credit_exemption(
          index+=1,
          declare_user.deductible_children_size,
          declare_user.children_tax_credit_amount
        )
      end

      if declare_user.newborn_baby_tax_credit_amount > 0
        new_born_tax_credit = self.find_or_initialize_by_declare_user(
          declare_user,
          "290"
        )
        new_born_tax_credit.create_credit_exemption(
          index+=1,
          declare_user.new_born_children_or_adopted_count,
          declare_user.newborn_baby_tax_credit_amount
        )
      end

      if declare_user.calculated_tax.online_declare_credit_amount > 0
        online_declare_tax_credit = self.find_or_initialize_by_declare_user(
          declare_user,
          "244"
        )
        online_declare_tax_credit.create_credit_exemption(
          index+=1,
          0,
          declare_user.calculated_tax.online_declare_credit_amount
        )
      end

      if declare_user.retirement_pension_tax_credit_amount > 0
        retirement_pension_tax_credit = self.find_or_initialize_by_declare_user(
          declare_user,
          "275"
        )
        retirement_pension_tax_credit.create_credit_exemption(
          index+=1,
          declare_user.hometax_individual_income.retirement_pension_tax_credit,
          declare_user.retirement_pension_tax_credit_amount
        )
        Foodtax::IcPensionIncomeDeduction.create_pension_retirement(declare_user)
      end

      if declare_user.pension_account_tax_credit_amount > 0
        pension_account_tax_credit = self.find_or_initialize_by_declare_user(
          declare_user,
          "276"
        )
        pension_account_tax_credit.create_credit_exemption(
          index+=1,
          declare_user.hometax_individual_income.pension_account_tax_credit,
          declare_user.pension_account_tax_credit_amount,
        )
        Foodtax::IcPensionIncomeDeduction.create_pension_account(declare_user)
      end
    end

    def create_credit_exemption(seq_no, source_amount, amount)
      self.seq_no = seq_no
      self.C0020 = source_amount
      self.C0030 = amount
      self.biz_reg_no = ""
      self.gonggam_type = "02"
      self.income_seq_no = "0"
      save!
    end
  end
end
