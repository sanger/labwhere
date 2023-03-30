# frozen_string_literal: true

require Rails.root.join('app/lib/utils/barcode_utilities.rb')

# Array extension
class Array
  include BarcodeUtilities

  def second
    at(1)
  end
end
