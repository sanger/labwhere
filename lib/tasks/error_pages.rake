# frozen_string_literal: true

require 'erb'

namespace :error_pages do
  desc 'copy the error pages from the views to the public folder'
  task copy: :environment do |_t|
    template = create_erb Rails.root.join('app/views/layouts/public_errors.html.erb')
    files = Rails.root.glob('app/views/errors/*.html.erb')
    files.each do |filename|
      error = create_erb filename
      Rails.public_path.join(File.basename(filename, '.erb')).write(yield_erb(template) { error.result })
    end
  end
end

def yield_erb(erb)
  erb.result(binding)
end

def create_erb(file)
  ERB.new File.new(file).read, trim_mode: '%'
end
