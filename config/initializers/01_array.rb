# frozen_string_literal: true

# Array extension
class Array
  include BarcodeUtilities

  def second
    at(1)
  end
end
