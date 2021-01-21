# frozen_string_literal: true

class CsvFileValidator < ActiveModel::Validator
  def validate(record)
    the_file = record.params[record.form_sym][:file]

    if the_file.nil?
      record.errors.add(:file, 'is empty')
      return
    end

    extension = ''
    if the_file.instance_of?(ActionDispatch::Http::UploadedFile)
      extension = File.extname(the_file.original_filename)
      return if extension == '.csv'
    end

    message = 'must be a csv.'
    message += " Provided: #{extension}" if extension.present?
    record.errors.add(:file, message)
  end
end
