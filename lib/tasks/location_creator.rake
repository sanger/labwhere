# frozen_string_literal: true

Rails.root.glob('lib/location_creator/*.rb').each { |f| require f }
# rubocop:disable Metrics/BlockLength
desc 'locations'
namespace :locations do
  desc 'create some locations'
  task create: :environment do |_t|
    locations = [
      LocationCreator.new('Site' => { location: 'Sanger', container: false },
                          'Building' => { location: 'Ogilvie', container: false },
                          'Room' => { location: 'AA214', container: false },
                          'Freezer' => { location: 'Long Read DTOL Freezer 2', container: true },
                          'Shelf' => { location: 'Shelf 3', container: true },
                          'Rack' => { location: 'Rack 3', container: true },
                          'Tray' => { location: 'Drawer 2', barcode: 'lw-drawer-2-30398',
                                      container: true }),

      LocationCreator.new('Site' => { location: 'Sanger', container: false },
                          'Building' => { location: 'Ogilvie', container: false },
                          'Room' => { location: 'AA309', container: false },
                          'Freezer -20C' => { location: 'LRT020', container: false },
                          'Shelf' => { location: 'SHELF 1', container: false },
                          'Drawer' => { location: 'Drawer 1', barcode: 'lw-drawer-1-37292',
                                        container: true }),

      LocationCreator.new('Site' => { location: 'Sanger', container: false },
                          'Building' => { location: 'Ogilvie', container: false },
                          'Room' => { location: 'AA309', container: false },
                          'Upright fridge +4c' => { location: 'LRT018', container: false },
                          'Shelf' => { location: 'Shelf 1', barcode: 'lw-shelf-1-30503',
                                       container: true }),

      LocationCreator.new('Site' => { location: 'Sanger', container: false },
                          'Building' => { location: 'Ogilvie', container: false },
                          'Room' => { location: 'AA309', container: false },
                          'Freezer -20 upright' => { location: 'LRT006', container: true },
                          'Shelf' => { location: 'Shelf 1', barcode: 'lw-shelf-1-30472',
                                       container: true }),

      LocationCreator.new('Site' => { location: 'Sanger', container: false },
                          'Building' => { location: 'Ogilvie', container: false },
                          'Room' => { location: 'AA309', container: false },
                          'Upright fridge +4c' => { location: 'LRT007', container: true },
                          'Shelf' => { location: 'Shelf 1', barcode: 'lw-shelf-1-30451',
                                       container: true }),

      LocationCreator.new('Site' => { location: 'Sanger', container: false },
                          'Building' => { location: 'Ogilvie', container: false },
                          'Room' => { location: 'AA315', container: false },
                          'Freezer' => { location: 'Freezer1', container: true },
                          'Shelf' => { location: 'Shelf', number: 2, container: true },
                          'Tray' => { location: 'Tray', number: 208, container: true })
    ]

    locations.each(&:run!)
  end
end
# rubocop:enable Metrics/BlockLength
