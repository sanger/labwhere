# frozen_string_literal: true

module Cgap
  class LoadData
    TAB = "\t"
    SPLIT = "\r\n"

    attr_reader :filename, :model, :path, :split

    def initialize(filename, path = "lib/cgap/data", split = "\r\n")
      @split = split
      @path = File.join(Rails.root, path)
      @filename = filename
      @model = set_model(filename)
    end

    def file
      @file ||= File.open(File.join(path, "#{filename}.txt")).read.split(split)
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
      "Cgap::#{filename.split("_").first.classify}".constantize
    end
  end
end
