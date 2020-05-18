module Foodtax
  class IcPrepaidTax < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq
    self.table_name = "ic_1100"

    belongs_to :ic_person, foreign_key: :person_cd, primary_key: :person_cd

    def self.find_or_initialize_by_declare_user(declare_user)
      ic_prepaid_tax = self.find_or_initialize_by(
        cmpy_cd: "00025",
        person_cd: declare_user.person_cd,
        term_cd: "2019",
        declare_seq: "1"
      )
    end

    def self.import_prepaid_tax(declare_user)
      prepaid_tax = self.find_or_initialize_by_declare_user(
        declare_user
      )
      return if declare_user.prepaid_tax_sum <= 0
      prepaid_tax.C0010 = declare_user.prepaid_tax_sum
      prepaid_tax.C0020 = 0
      prepaid_tax.C0030 = 0
      prepaid_tax.C0040 = 0
      prepaid_tax.C0050 = 0
      prepaid_tax.C0060 = 0
      prepaid_tax.C0070 = 0
      prepaid_tax.C0080 = 0
      prepaid_tax.C0090 = 0
      prepaid_tax.C0100 = 0
      prepaid_tax.C0110 = declare_user.prepaid_tax_sum
      prepaid_tax.save!
    end

    private

    def initialize_rural_taxes
      prepaid_tax.C0120 = 0
      prepaid_tax.C0130 = 0
      prepaid_tax.C0140 = 0
      prepaid_tax.C0150 = 0
    end
  end
end