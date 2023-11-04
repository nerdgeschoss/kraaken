# frozen_string_literal: true

class Kraaken::Logger::Formatter < Logger::Formatter
  def initialize(color)
    @color = color
  end

  def call(severity, time, progname, msg)
    colors = {
      "DEBUG" => :blue,
      "INFO" => :white,
      "WARN" => :yellow,
      "ERROR" => :red,
      "FATAL" => :red
    }
    @color.color(msg.strip, color: colors[severity] || :white) + "\n"
  end
end
