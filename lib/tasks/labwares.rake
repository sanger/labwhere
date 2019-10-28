namespace :labwares do
  desc "generate a number of fake barcodes to enter into scan page"
  task :generate_barcodes, [:num] => :environment do |_t, args|
    next_id = Labware.last.nil? ? 1 : Labware.last.id + 1
    next_id.upto(next_id + args.num.to_i - 1) do |i|
      puts "Labware:#{i}"
    end
  end
end
