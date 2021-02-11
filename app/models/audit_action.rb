# frozen_string_literal: true

# The audit action pervades through the whole application
# It is time to give it a drawer
class AuditAction
  CREATE = 'create'
  UPDATE = 'update'
  DESTROY = 'destroy'
  REMOVE_ALL_LABWARES = 'remove_all_labwares'
  MANIFEST_UPLOAD = 'manifest_upload'
  EMPTY_LOCATION = 'empty_location'

  # a list of all the current actions
  ALL = {
    'create' => {
      description: 'create',
      display_text: 'Created'
    },
    'update' => {
      description: 'update',
      display_text: 'Updated'
    },
    'destroy' => {
      description: 'destroy',
      display_text: 'Destroyed'
    },
    # auditable_type is location
    'remove_all_labwares' => {
      description: 'remove all labwares',
      display_text: 'Removed all labwares'
    },
    'manifest_upload' => {
      description: 'uploaded from manifest',
      display_text: 'Uploaded from manifest'
    },
    # auditable_type is labware
    'empty_location' => {
      description: 'update when location emptied',
      display_text: 'Updated when location emptied'
    }
  }.freeze

  attr_reader :description, :display_text, :key

  # get the key and assign it to an instance
  # if the key is not a standard action display as is
  def initialize(key)
    @key = key
    action = ALL[key]

    if action.nil?
      @description = @display_text = key
    else
      @description, @display_text = action.values_at(:description, :display_text)
    end
  end

  # needed for sending events to warehouse
  def event_type
    @event_type ||= "labwhere_#{description.tr(' ', '_')}".downcase
  end

  # equality operator. To check that the state of one object
  # is equal to another for testing
  # if you don't have this method it will check if objects
  # are the same
  def ==(other)
    other.class == self.class && other.state == state
  end

  protected

  def state
    [description, display_text]
  end
end
