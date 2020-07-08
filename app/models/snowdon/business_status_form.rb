class Snowdon::BusinessStatusForm < Snowdon::ApplicationRecord
  enum declare_period: { first_half: "상반기", second_half: "하반기" }
  belongs_to :business

  def first_half?
    declare_period.eql?("first_half")
  end
end
