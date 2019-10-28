module BarcodeUtilities
  ##
  # Take the barcodes for the object and create a string using the defined delimiter.
  def join_barcodes(char = "\n")
    self.collect { |l| l.barcode }.join(char)
  end
end
