class Snowdon::IndividualIncomeTaxReturn < Snowdon::ApplicationRecord
  enum status: {
    unavailable: 0,
    prepared: 1,
    started: 2,
    file_created: 3,
    paid: 4,
    finished: 5,
  }

  belongs_to :user

  validates :year, presence: true, uniqueness: { scope: :user }
  validates :status, presence: true
  validates :started_at, presence: true, if: :started?
  validates :electronic_file, presence: true, if: :file_created?
  validates :electronic_file_created_at, presence: true, if: :file_created?
  validates :paid_at, presence: true, if: :paid?
  validates :finished_at, presence: true, if: :finished?
  validates :return_response, presence: true, if: :finished?

  def ongoing?
    started? || file_created? || paid? || finished?
  end
end
