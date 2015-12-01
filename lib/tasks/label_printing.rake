Dir[File.join(Rails.root,"lib","label_printing","*.rb")].each { |f| require f }

namespace :labels do

  desc "print some labels"
  task :print, [:printer_id, :location_id] => :environment do |t, args|
    label_printing = LabelPrinting.new(args.printer_id, args.location_id)
    puts label_printing.json
    label_printing.run
  end
  
end