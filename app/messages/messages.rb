# frozen_string_literal: true

# rabbitmq messages
module Messages
  def self.publish(objects)
    Array(objects).each do |object|
      ::Broker::Handle.publish(Message.new(object: object))
    end
  end
end
