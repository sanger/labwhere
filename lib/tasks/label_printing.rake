Dir[File.join(Rails.root,"lib","label_printing","*.rb")].each { |f| require f }

namespace :labels do

  desc "print some labels"
  task :print, [:printer_id, :location_ids] => :environment do |t, args|
    location_ids = args.location_ids.split(' ').map(&:to_i)
    label_printing = LabelPrinting.new(args.printer_id, location_ids.length == 1 ? location_ids.first : location_ids)
    puts label_printing.json
    label_printing.run
  end
  
end