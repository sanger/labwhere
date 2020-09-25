# frozen_string_literal: true

class String
  ##
  # remove tabs, carriage returns and returns from a string
  def remove_control_chars
    self.tr("\t\r\n", '')
  end

  ##
  # must be camel case.
  # will deconstruct word by capitals and reform it into a string without the last word.
  def remove_last_word
    self.scan(/[A-Z][a-z]+/).tap(&:pop).join
  end
end
