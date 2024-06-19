# frozen_string_literal: true

require '../../app/lib/utils/barcode_utilities'

# Array extension
class Array
  include BarcodeUtilities

  def second
    at(1)
  end
end
