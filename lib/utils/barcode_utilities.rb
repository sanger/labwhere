module BarcodeUtilities

  def join_barcodes(char = "\n")
    self.collect{ |l| l.barcode }.join(char)
  end
  
end