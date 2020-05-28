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

    def self.import(declare_user, calculated_tax)
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

      if calculated_tax.online_declare_credit_amount > 0
        online_declare_tax_credit = self.find_or_initialize_by_declare_user(
          declare_user,
          "244"
        )
        online_declare_tax_credit.create_credit_exemption(
          index+=1,
          0,
          calculated_tax.online_declare_credit_amount
        )
      end

      base_calculated_tax = [calculated_tax.calculated_tax -
        declare_user.base_tax_credit_amount -
          declare_user.children_tax_credit_amount -
            declare_user.newborn_baby_tax_credit_amount -
              calculated_tax.online_declare_credit_amount, 0].max

      balanced_retirement = [declare_user.retirement_pension_tax_credit_amount,
                              base_calculated_tax].min

      if base_calculated_tax > 0 && balanced_retirement > 0
        retirement_pension_tax_credit = self.find_or_initialize_by_declare_user(
          declare_user,
          "275"
        )

        balanced_retirement_tax_credit = (
          balanced_retirement /
            declare_user.pension_tax_rate
          ).ceil.to_i

        retirement_pension_tax_credit.create_credit_exemption(
          index+=1,
          balanced_retirement_tax_credit,
          balanced_retirement
        )
        Foodtax::IcPensionIncomeDeduction.create_pension_retirement(
          declare_user,
          balanced_retirement_tax_credit,
          balanced_retirement
        )
      end

      base_calculated_tax = [base_calculated_tax - balanced_retirement, 0].max

      balanced_pension_account = [ declare_user.pension_account_tax_credit_amount,
                                   base_calculated_tax].min

      if base_calculated_tax > 0 && balanced_pension_account > 0
        pension_account_tax_credit = self.find_or_initialize_by_declare_user(
          declare_user,
          "276"
        )

        balanced_pension_account_tax_credit = (
          balanced_pension_account /
            declare_user.pension_tax_rate
          ).ceil.to_i

        pension_account_tax_credit.create_credit_exemption(
          index+=1,
          balanced_pension_account_tax_credit,
          balanced_pension_account
        )
        Foodtax::IcPensionIncomeDeduction.create_pension_account(
          declare_user,
          balanced_pension_account_tax_credit,
          balanced_pension_account
        )
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
