class SendSlackMessageJob < ApplicationJob
  queue_as :send_slack_message

  def perform(message, channel)    
    message = "[테스트] #{message}" if Rails.env.development?
    SlackBot.ping("#{message}", channel: "#{channel}")
  end
end
