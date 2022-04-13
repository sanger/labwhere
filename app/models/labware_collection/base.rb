# frozen_string_literal: true

module LabwareCollection
  class Base
    include Enumerable
    include ActiveModel::Model

    attr_accessor :location, :labwares, :user, :original_locations, :start_position, :coordinates

    validates_presence_of :location, :user, :labwares

    def initialize(attributes = {})
      super
      @original_locations = []
    end

    def push()
      if valid?
        ActiveRecord::Base.transaction do
          labwares.each_with_index do |labware, i|
            model = find_labware(labware)
            add_original_location(model)
            yield(model, i) if block_given?
            model.create_audit(user)
          end
        end
      end
      self
    end

    def each(&block)
      labwares.each(&block)
    end

    def original_location_names
      original_locations.uniq.join(', ')
    end

    def labwares=(labwares) # rubocop:todo Lint/DuplicateMethods
      @labwares = labwares.uniq
    end

    private

    def find_labware(labware)
      Labware.find_or_initialize_by_barcode(labware)
    end

    def add_original_location(labware)
      original_locations << labware.location.name unless labware.location.empty?
    end
  end
end
