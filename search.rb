require 'twitter'
require 'dotenv'
require './clipboard.rb'
require './relief_request.rb'

Dotenv.load

ONE_PUN_NAMES = ENV['ONE_PUN_NAMES'].encode("UTF-8").split(',')
INCLUDE_120_HELL = ENV['INCLUDE_120_HELL'] == 'true'
INCLUDE_100_HELL = ENV['INCLUDE_100_HELL'] == 'true'

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

options = {
  track: "ID Lv50,Lv60,,Lv70,Lv75,Lv100#{ INCLUDE_120_HELL ? ',Lv120' : '' }"
}

def hairu?(r)
  return false unless ONE_PUN_NAMES.include?(r.name)
  # マグナ系の場合はHLかどうか判定
  return true unless r.maguna?
  return true unless r.hl_maguna?
  return INCLUDE_100_HELL
end

client.filter(options) do |object|
  return unless object.is_a?(Twitter::Tweet)
  r = ReliefRequest.new(object.text)
  if hairu?(r)
    puts "Lv#{r.level} #{r.name} #{r.id}"
    Clipboard.copy(r.id)
  else
    puts "reject --- Lv#{r.level} #{r.name} #{r.id}"
  end
end
