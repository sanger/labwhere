# frozen_string_literal: true

module LabwareCollection
  class UnorderedLocation < Base
    def push
      super do |model, _i|
        location.labwares << model.flush
      end
    end
  end
end
