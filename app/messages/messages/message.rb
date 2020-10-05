# frozen_string_literal: true

module Messages
  # Message
  # Creates a message in the correct structure for the warehouse
  class Message
    include ActiveModel::Model

    attr_accessor :object

    # Content as json string
    def payload
      object.to_json
    end
  end
end
