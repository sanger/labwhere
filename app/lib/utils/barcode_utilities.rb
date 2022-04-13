# frozen_string_literal: true

module BarcodeUtilities
  ##
  # Take the barcodes for the object and create a string using the defined delimiter.
  def join_barcodes(char = "\n")
    extract_barcodes.join(char)
  end

  # Extract the barcodes from the input object(s)
  def extract_barcodes
    self.collect(&:barcode)
  end
end
