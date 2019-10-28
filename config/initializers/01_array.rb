# frozen_string_literal: true

class Array
  include BarcodeUtilities

  def second
    self.at(1)
  end
end
