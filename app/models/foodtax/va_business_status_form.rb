module Foodtax
  class VaBusinessStatusForm < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.table_name = "VA_V142_M"
    self.primary_keys = :member_cd, :cmpy_cd
    after_initialize :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    NON_VALIDATABLE_ATTRIBUTES = %w(C0100 REG_DATE UPDT_DATE REG_USER_ID UPDT_USER_ID)
    validates_presence_of Foodtax::VaBusinessStatusForm.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr)}

    validates :C0010, inclusion: { in: %w(01 02) }

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd
      )
    end

    def import_general_form!(form)
      self.C0010 = form.self_rental ? "01" : "02"
      self.C0020 = form.site_area
      self.C0030 = form.lower_ground_floors
      self.C0040 = form.upper_ground_floors
      self.C0050 = form.building_area
      self.C0060 = form.total_floor_area
      self.C0070 = form.rooms_count
      self.C0080 = form.tables_count
      self.C0090 = form.seats_count
      self.C0100 = form.parking_lot ? "Y" : "N"
      self.C0110 = form.employees_count
      self.C0120 = form.passenger_cars_count
      self.C0130 = form.vans_count
      self.C0140 = "0"
      self.C0150 = form == 1 ? "06" : "12"
      self.C0160 = (form.rental_deposit / 1000.0).to_i
      self.C0170 = (form.monthly_rental_fee / 1000.0).to_i
      self.C0180 = (form.electricity_gas_bills / 1000.0).to_i
      self.C0190 = (form.water_bills / 1000.0).to_i
      self.C0200 = (form.wage / 1000.0).to_i
      self.C0210 = (form.etc_expenses / 1000.0).to_i
      self.C0220 = (form.total_monthly_expenses / 1000.0).to_i
      save!
    end

    def validate_rental_deposit?
      errors.add(:C0160, :invalid_rental) if !self_rental? && (self.C0160 + self.C0170 <= 0)
    end

    def self_rental?
      self.C0150.eql?("01")
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
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
