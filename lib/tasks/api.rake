if Rails.env == "development"
  require 'raml'

  namespace :docs do
    desc "generate the api docs"
    task :api do |t|
      puts "generating api docs..." 
      Raml.document(File.join(Rails.root,"config","api.raml"), File.join(Rails.root,"app","views","api","docs","index.html.erb"))
      puts "done"
    end
  end
end