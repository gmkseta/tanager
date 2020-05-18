module Foodtax
  class IcPensionIncomeDeduction < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :seq_no
    self.table_name = "ic_1232"

    belongs_to :ic_person, foreign_key: :person_cd, primary_key: :person_cd

    BANK_SAMPLE = ["304", "305", "306", "307", "308"]

    def self.find_or_initialize_by_declare_user(declare_user, code)
      ic_pension_income_deduction = self.find_or_initialize_by(
        cmpy_cd: "00025",
        person_cd: declare_user.person_cd,
        term_cd: "2019",
        declare_seq: "1",
        C0010: code,
      )
      ic_pension_income_deduction
    end

    def self.create_personal_pension(declare_user)
      ic_pension_income_deduction = self.find_or_initialize_by_declare_user(declare_user, "21")
      if ic_pension_income_deduction.new_record?
        ic_pension_income_deduction.seq_no = "1"
      else
        ic_pension_income_deduction.seq_no = Foodtax::IcPensionIncomeDeduction.seq_no_size(declare_user) + 1
      end
      bank = Foodtax::IcPensionIncomeBank.unscoped.find_by(bank_cd: BANK_SAMPLE.sample)

      ic_pension_income_deduction.C0020 = bank.bank_cd
      ic_pension_income_deduction.C0030 = bank.bank_nm
      ic_pension_income_deduction.acct_cd = "111111111111"
      ic_pension_income_deduction.C0040 = ""
      ic_pension_income_deduction.C0050 = declare_user.hometax_individual_income.personal_pension
      ic_pension_income_deduction.C0060 = declare_user.hometax_individual_income.personal_pension
      ic_pension_income_deduction.C0070 = 0.0
      ic_pension_income_deduction.C0080 = declare_user.hometax_individual_income.personal_pension_deduction
      ic_pension_income_deduction.trade_nm = ""
      ic_pension_income_deduction.biz_reg_no = ""
      ic_pension_income_deduction.save!
    end

    def self.create_pension_retirement(declare_user)
      ic_pension_income_deduction = self.find_or_initialize_by_declare_user(declare_user, "11")
      if ic_pension_income_deduction.new_record?
        ic_pension_income_deduction.seq_no = "1"
      else
        ic_pension_income_deduction.seq_no = Foodtax::IcPensionIncomeDeduction.seq_no_size(declare_user) + 1
      end
      bank = Foodtax::IcPensionIncomeBank.unscoped.find_by(bank_cd: BANK_SAMPLE.sample)

      ic_pension_income_deduction.C0020 = bank.bank_cd
      ic_pension_income_deduction.C0030 = bank.bank_nm
      ic_pension_income_deduction.acct_cd = "111111111111"
      ic_pension_income_deduction.C0040 = ""
      ic_pension_income_deduction.C0050 = declare_user.hometax_individual_income.retirement_pension_tax_credit
      ic_pension_income_deduction.C0060 = declare_user.hometax_individual_income.retirement_pension_tax_credit
      ic_pension_income_deduction.C0070 = declare_user.pension_tax_rate
      ic_pension_income_deduction.C0080 = declare_user.retirement_pension_tax_credit_amount
      ic_pension_income_deduction.trade_nm = ""
      ic_pension_income_deduction.biz_reg_no = ""
      ic_pension_income_deduction.save!
    end

    def self.create_pension_account(declare_user)
      ic_pension_income_deduction = self.find_or_initialize_by_declare_user(declare_user, "22")
      if ic_pension_income_deduction.new_record?
        ic_pension_income_deduction.seq_no = "1"
      else
        ic_pension_income_deduction.seq_no = Foodtax::IcPensionIncomeDeduction.seq_no_size(declare_user) + 1
      end
      bank = Foodtax::IcPensionIncomeBank.unscoped.find_by(bank_cd: BANK_SAMPLE.sample)

      ic_pension_income_deduction.C0020 = bank.bank_cd
      ic_pension_income_deduction.C0030 = bank.bank_nm
      ic_pension_income_deduction.acct_cd = "111111111111"
      ic_pension_income_deduction.C0040 = ""
      ic_pension_income_deduction.C0050 = declare_user.hometax_individual_income.pension_account_tax_credit
      ic_pension_income_deduction.C0060 = declare_user.hometax_individual_income.pension_account_tax_credit
      ic_pension_income_deduction.C0070 = declare_user.pension_tax_rate
      ic_pension_income_deduction.C0080 = declare_user.pension_account_tax_credit_amount
      ic_pension_income_deduction.trade_nm = ""
      ic_pension_income_deduction.biz_reg_no = ""
      ic_pension_income_deduction.save!
    end

    def self.seq_no_size(declare_user)
      Foodtax::IcPensionIncomeDeduction.where(
          cmpy_cd: "00025",
          person_cd: declare_user.person_cd,
          term_cd: "2019",
          declare_seq: "1",
        ).length
    end
  end
end