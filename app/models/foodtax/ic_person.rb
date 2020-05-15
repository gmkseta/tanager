module Foodtax
  class IcPerson < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd
    after_initialize :default_user_id

    def initialize_by_declare_user(declare_user, member_cd)
      self.cmpy_cd = "00025"
      self.person_cd = "P#{"%06d" % declare_user.id}"
      self.jumin_no = declare_user.residence_number
      self.name = declare_user.name
      self.member_cd = member_cd
      address = declare_user.hometax_address || declare_user.address
      split_address = address.split
      self.addr1 = split_address[0]
      self.addr2 = split_address[1]
      self.tel_no = declare_user.phone_number
    end
  end
end
