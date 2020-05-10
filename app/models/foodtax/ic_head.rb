module Foodtax
  class IcHead < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq

    def declare_file      
      results = Foodtax::IcHead.execute_procedure :sp_ic_head_file_gen_only_hometax,
        cmpy_cd: cmpy_cd,
        person_cd: person_cd,
        term_cd: term_cd,
        declare_seq: declare_seq,
        form_cd: '',
        login_user_id: '',
        return_val1: ''
      results.flatten.first["result"]
    end
  end
end
