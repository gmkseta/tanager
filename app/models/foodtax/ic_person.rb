module Foodtax
  class IcPerson < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd
    after_initialize :default_user_id

    has_many :ic_families, class_name: "IcFamily", foreign_key: [:cmpy_cd, :person_cd]

    def self.find_or_initialize_by_declare_user(declare_user)
      ic_person = self.find_or_initialize_by(
        cmpy_cd: "00025",
        person_cd: declare_user.person_cd,
        member_cd: declare_user.member_cd,
      )
      ic_person.jumin_no = declare_user.residence_number
      ic_person.name = declare_user.name
      address = declare_user.hometax_address || declare_user.address
      split_address = address.split
      ic_person.addr1 = split_address[0]
      ic_person.addr2 = split_address[1]
      ic_person.tel_no = declare_user.user.phone_number
      ic_person
    end
  end
end
