require "graphql/client/http"

module IndividualIncome
  class DeclareRecord
    def default_record
      "52C110700" + user.address_phone_number + user.business_phone_number + user.cellphone_number + user.email
    end
  end
end
