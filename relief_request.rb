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

  def maguna?
    MAGUNA.include?(name)
  end

  def hl_maguna?
    level >= 100 && maguna?
  end
end
