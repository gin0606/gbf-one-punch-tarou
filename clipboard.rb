require 'rbconfig'

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
    case RbConfig::CONFIG['host_os']
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
      raise "#{os} is not supported."
    end
  end
end
