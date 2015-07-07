namespace :error_pages do
  desc "copy the error pages from the views to the public folder"
  task :copy do |t|
    dest = File.join(Rails.root, "public")
    files = Dir[File.join(Rails.root, "app", "views", "errors", "*.html.erb")]
    files.each do |filename|
      name = File.basename(filename, '.erb')
      FileUtils.cp(filename, File.join(dest, name))
    end
  end
end
