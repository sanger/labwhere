require 'erb'

namespace :error_pages do
  desc "copy the error pages from the views to the public folder"
  task :copy do |t|
    template = create_erb File.join(Rails.root, "app", "views", "layouts", "public_errors.html.erb")
    files = Dir[File.join(Rails.root, "app", "views", "errors", "*.html.erb")]
    files.each do |filename|
      error = create_erb filename
      File.open(File.join(Rails.root, "public", File.basename(filename,".erb")), "w+") do |f|
        f.write yield_erb(template) { error.result }
      end
    end
  end
end

def yield_erb(erb)
  erb.result(binding)
end

def create_erb(file)
  ERB.new File.new(file).read, nil, "%"
end
