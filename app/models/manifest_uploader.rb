class ManifestUploader

  include ActiveModel::Model 

  attr_accessor :file, :start_row

  def start_row
    @start_row ||= 1
  end
  
end