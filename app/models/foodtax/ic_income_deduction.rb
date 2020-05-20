module Foodtax
  class IcIncomeDeduction < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :gonggam_cd
    self.table_name = "ic_1060"
    
    belongs_to :ic_person, foreign_key: :person_cd, primary_key: :person_cd

    def self.find_or_initialize_by_declare_user(declare_user, gonggam_cd)
      ic_income_deduction = self.find_or_initialize_by(
        cmpy_cd: "00025",
        person_cd: declare_user.person_cd,
        term_cd: "2019",
        declare_seq: "1",
        gonggam_cd: gonggam_cd,
      )
    end

    def self.import_deductions(declare_user)
      self_deduction = self.find_or_initialize_by_declare_user(
        declare_user,
        "F01"
      )
      self_deduction.create_deduction(0, 1, 1500000)

      spouse_count = declare_user
                      .deductible_persons
                      .select {|s| s.spouse? }
                      .length
      if spouse_count > 0
        spouse_deduction = self.find_or_initialize_by_declare_user(
          declare_user,
          "F02"
        )
        spouse_deduction.create_deduction(0, 1, 1500000)
      end

      dependants_count = declare_user.deductible_persons.dependants_count
      if dependants_count > 0
        dependants_deduction = self.find_or_initialize_by_declare_user(
          declare_user,
          "F03"
        )
        dependants_deduction.create_deduction(
          0,
          dependants_count,
          1500000 * dependants_count
        )
      end

      elder_count = declare_user
                      .deductible_persons
                      .elder_count +
                      (declare_user.elder? ? 1 : 0)

      if elder_count > 0
        elder_deduction = self.find_or_initialize_by_declare_user(
          declare_user,
          "F05"
        )
        elder_deduction.create_deduction(
          0,
          elder_count,
          1000000 * elder_count
        )
      end

      disabled_count = declare_user
                        .deductible_persons
                        .disabled_count +
                        (declare_user.disabled ? 1 : 0)

      if disabled_count > 0
        disabled_deduction = self.find_or_initialize_by_declare_user(
          declare_user, 
          "F06"
        )
        disabled_deduction.create_deduction(
          0,
          disabled_count,
          2000000 * disabled_count
        )
      end

      if declare_user.woman_deduction?
        woman_deduction = self.find_or_initialize_by_declare_user(
          declare_user, 
          "F07"
        )
        woman_deduction.create_deduction(0, 1, 500000)
      end

      if declare_user.single_parent?
        single_parent_deduction = self.find_or_initialize_by_declare_user(
          declare_user,
          "F14"
        )
        single_parent_deduction.create_deduction(0, 1, 1000000)
      end

      personal_deduction_amount = declare_user
                                    .deductible_persons.sum(&:deduction_amount) + 
                                    declare_user
                                      .deduction_amount
      if personal_deduction_amount > 0
        personal_deduction = self.find_or_initialize_by_declare_user(
          declare_user, 
          "F29"
        )
        personal_deduction.create_deduction(personal_deduction_amount, 0, 0)
        Foodtax::IcPensionIncomeDeduction.create_personal_pension(declare_user)
      end

      national_pension_deduction_amount = declare_user
                                            .hometax_individual_income
                                            .national_pension

      if national_pension_deduction_amount > 0
        national_pension = self.find_or_initialize_by_declare_user(
          declare_user, 
          "F31"
        )
        national_pension.create_deduction(national_pension_deduction_amount, 0, 0)
      end

      personal_pension_deduction = declare_user
                                    .hometax_individual_income
                                    .personal_pension_deduction
      merchant_pension_deduction = declare_user
                                    .hometax_individual_income
                                    .merchant_pension_deduction

      special_deduction_amount = personal_pension_deduction + merchant_pension_deduction
      if special_deduction_amount > 0
        special_deduction = self.find_or_initialize_by_declare_user(
          declare_user, 
          "F59"
        )
        special_deduction.create_deduction(special_deduction_amount, 0, 0)
        ic_special_taxation_income_deduction =
          Foodtax::IcSpecialTaxationIncomeDeduction.import_deductions(declare_user)
      end

      total_amount = personal_deduction_amount +
                      special_deduction_amount +
                      national_pension_deduction_amount

      if total_amount > 0
        total_deduction = self.find_or_initialize_by_declare_user(
          declare_user, 
          "199"
        )
        total_deduction.create_deduction(total_amount, 0, 0)
      end
    end

    def create_deduction(amount, person_count, person_amount)
      self.deduct_amt = amount
      self.person_cnt = person_count
      self.person_amt = person_amount
      save!
    end
  end
end
