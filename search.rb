require 'twitter'
require 'dotenv'
require 'rbconfig'

Dotenv.load
NAMES = ENV['ONE_PUN_NAMES'].encode("UTF-8").split(',')
INCLUDE_120_HELL = ENV['INCLUDE_120_HELL'] == 'true' ? true : false
INCLUDE_100_HELL = ENV['INCLUDE_100_HELL'] == 'true' ? true : false

MAGUNA = [
  'ティアマト・マグナ',
  'コロッサス・マグナ',
  'リヴァイアサン・マグナ',
  'ユグドラシル・マグナ',
  'シュヴァリエ・マグナ',
  'セレスト・マグナ',
].freeze

class ReliefRequest
  attr_reader :id, :name, :level

  def initialize(str)
    match = str.match(/.*参加者募集！参戦ID：(\w{1,})\nLv(\d{1,3}) (.*)\nhttp.*/)
    if match
      @id = match[1]
      @level = match[2].to_i
      @name = match[3]
    end
  end
end

class Clipboard
  class << self
    def copy(text)
      clipboard.copy(text)
    end

    def clipboard
      @@clipboard ||= Clipboard.new
    end
  end

  def os
    @os ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      :unknown
    end
    )
  end

  def copy(text)
    if os == :macosx
      `echo '#{text}' | pbcopy`
    elsif os == :windows
      `echo '#{text}' | clip`
    else
      puts "#{os} is not supported."
    end
  end
end

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
  return false unless NAMES.include?(r.name)
  return true unless MAGUNA.include?(r.name)
  return true unless r.level == 100
  # マグナ系の場合はHLかどうか判定
  return true if INCLUDE_100_HELL
  return false
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
