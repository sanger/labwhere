module HasBarcode

  extend ActiveSupport::Concern

  included do
    
  end

  def generate_barcode
    update_column(:barcode, "#{self.name}:#{self.id}")
  end
end