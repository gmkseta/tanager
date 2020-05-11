class Snowdon::Phone < Snowdon::ApplicationRecord
  BLOCKED_NUMBERS_CACHE_KEY = "phones:blocked_numbers".freeze

  belongs_to :user, optional: true

  validates :user, uniqueness: true, allow_nil: true
  validates :number, format: { with: /\A01[016789]\d{8}\z/ }, uniqueness: true
  validates :blocked, inclusion: { in: [true, false] }

  after_update :update_blocked_numbers_cache, if: :saved_change_to_blocked?

  scope :blocked, -> { where(blocked: true) }

  class << self
    def blocked?(number)
      $redis.sismember(BLOCKED_NUMBERS_CACHE_KEY, number)
    end
  end

  def generate_confirmation_token(sent_at: Time.current)
    return if confirmation_token && confirmation_sent_at
    update(confirmation_token: SecureRandom.base10(6), confirmation_sent_at: sent_at)
  end

  def confirm(user)
    update(user: user, confirmation_token: nil, confirmed_at: Time.zone.now)
  end

  def confirmed?
    user.present?
  end

  def partial_number
    "#{number.first(3)}**#{number.last(4)}"
  end

  def formatted_number
    number.scan(/(\d{3})(\d{4})(\d{4})/).flatten.join("-")
  end

  private

  def update_blocked_numbers_cache
    blocked? ? $redis.sadd(BLOCKED_NUMBERS_CACHE_KEY, number) : $redis.srem(BLOCKED_NUMBERS_CACHE_KEY, number)
  end
end
