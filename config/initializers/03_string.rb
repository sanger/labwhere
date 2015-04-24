class String

  def remove_control_chars
    self.gsub(/[\t\r\n]/,'')
  end
end