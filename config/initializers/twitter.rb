twitter_config = Rails.application.config_for(:twitter)
$twitter_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = twitter_config[:consumer_key]
  config.consumer_secret = twitter_config[:consumer_secret]
  config.access_token = twitter_config[:access_token]
  config.access_token_secret = twitter_config[:access_token_secret]
end