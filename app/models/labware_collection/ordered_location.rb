module LabwareCollection
  class OrderedLocation < Base
    validate :check_coordinates

    def initialize(attributes = {})
      super
      @coordinates ||= location.available_coordinates(start_position, labwares.count)
    end

    def push
      super do |model, i|
        coordinates[i].fill(model.flush)
      end
    end

    private

    def check_coordinates
      unless coordinates.count == labwares.count
        errors.add(:base, I18n.t("errors.messages.not_enough_empty_coordinates"))
      end
    end
  end
end
