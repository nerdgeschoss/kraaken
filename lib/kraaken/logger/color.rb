# frozen_string_literal: true

class Kraaken::Logger::Color
  CLEAR = "\e[0m"
  BOLD = "\e[1m"

  # Colors
  BLACK = "\e[30m"
  RED = "\e[31m"
  GREEN = "\e[32m"
  YELLOW = "\e[33m"
  BLUE = "\e[34m"
  MAGENTA = "\e[35m"
  CYAN = "\e[36m"
  WHITE = "\e[37m"
  GRAY = "\e[90m"

  def color(text, color:, bold: false)
    color = self.class.const_get(color.to_s.upcase) if color.is_a?(Symbol)
    bold = bold ? BOLD : ""
    "#{bold}#{color}#{text}#{CLEAR}"
  end
end
