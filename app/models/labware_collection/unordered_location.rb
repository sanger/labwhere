module LabwareCollection
  class UnorderedLocation < Base
    def push
      super do |model, i|
        location.labwares << model.flush
      end
    end
  end
end