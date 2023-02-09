# frozen_string_literal: true

if Rails.env.development?

  namespace :docs do
    desc 'generate the api docs'
    task api: :environment do |_t|
      path_to_doc = 'app/views/api/docs/index.html.erb'
      sh("bundle exec apiary preview --path=\"config/api.apib\" --output=\"#{path_to_doc}\" --no-server")
      puts 'Done!'
      puts "Docs have been generated in #{path_to_doc}"
    end
  end
end
