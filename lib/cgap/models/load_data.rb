class LoadData

  PATH = File.join(Rails.root, "lib","cgap","data")
  TAB = "\t"
  SPLIT = "\r\n"

  attr_reader :filename, :model

  def initialize(filename)
    @filename = filename
    @model = set_model(filename)
  end

  def file
    @file ||= File.open(File.join(PATH, "#{filename}.txt")).read.split(SPLIT)
  end

  def load!
    @fields = file.shift.rstrip.split(TAB)
    file.each do |row|
      model.create(create_attributes row.split(TAB))
    end
    puts "#{model.all.count} records loaded into #{model}"
  end

private

  attr_reader :fields

  def create_attributes(row)
    {}.tap do |attributes|
      fields.each_with_index do |field, i|
        attributes[field] = row[i]
      end
    end
  end

  def set_model(filename)
    "Cgap#{filename.classify}".constantize
  end
  
end