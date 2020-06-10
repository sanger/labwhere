class ManifestUploader

  include ActiveModel::Model 

  attr_accessor :file, :start_row

  def start_row
    @start_row ||= 1
  end

  def data
    @data ||= CSV.parse(file)
  end

  def run
    file.each do |row|
      Labware.
    end
  end
  
end