class SlackBot
  include Singleton
  extend Forwardable
  def_delegators :@client, :ping, :post

  class << self
    extend Forwardable
    def_delegators :instance, :ping, :post
  end

  def initialize
    @client = Slack::Notifier.new(Rails.application.credentials.dig(:slack, :webhook_url) || "", http_client: client)
  end

  private

  class LogClient
    def self.post(_, params)
      Rails.logger.info "[SlackBot] SlackBot configured not to post to Slack without SLACK_WEBHOOK_URL: #{params}"
    end
  end

  def client
    Rails.application.credentials.dig(:slack, :webhook_url).blank? ? LogClient : Slack::Notifier::Util::HTTPClient
  end
end
