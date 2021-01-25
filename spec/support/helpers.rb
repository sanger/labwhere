# frozen_string_literal: true

module Helpers
  # create a tempfile, add some data and set the content type.
  def create_temp_file(name, type, content_type, data = "foo")
    temp_file = Tempfile.new([name, type])
    temp_file.write(data)
    temp_file.rewind # rewind writes the data otherwise the file is still empty
    file = ActionDispatch::Http::UploadedFile.new(tempfile: temp_file)

    # doesn't work if set in the initializer
    file.content_type = content_type
    file.original_filename = "#{name}#{type}"
    file
  end
end
