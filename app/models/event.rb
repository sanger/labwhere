# frozen_string_literal: true

class Event
  include ActiveModel::Model

  attr_accessor :audit
  attr_writer :labware

  validates :audit, presence: true

  validate :check_location_information_exists
  validate :check_labware_information_exists

  delegate :uuid, to: :audit

  def event_type
    @event_type ||= Event.generate_event_type(audit.action)
  end

  def self.generate_event_type(audit_action)
    "labwhere_#{audit_action.tr(' ', '_')}".downcase
  end

  def for_old_audit?
    @for_old_audit ||= begin
      # if the labware record no longer exists, this is an old audit
      return true if labware.blank?

      # if this audit is not the latest for this labware, it is old
      audit.id != labware.audits.last.id
    end
  end


  # human readable string containing as much information as we have about the location
  def location_info
    return location_barcode unless location.present?
    return "#{location.parentage} - #{location.name}" if location.parentage.present?

    location.name
  end

  def location_barcode
    @location_barcode ||= audit.record_data['location']
  end

  def location
    # may return nil if the Location has been deleted since the Audit was created
    @location ||= Location.find_by(barcode: location_barcode)
  end

  def labware_barcode
    @labware_barcode ||= audit.record_data['barcode']
  end

  def labware_uuid
    @labware_uuid ||= begin
      return labware.uuid if labware.present?

      audit.record_data['uuid']
    end
  end

  def labware
    @labware ||= Labware.find_by(barcode: labware_barcode)
  end

  def coordinate
    @coordinate ||= begin
      if audit.id == labware.audits.last.id
        # if this is the latest audit for this labware, we can grab the current coordinate from the labware
        labware.coordinate
      end
      # otherwise, return nil as we're re-firing an old event & don't know the coordinate for the time it occurred
    end
  end

  def as_json(*)
    {
      event: {
        uuid: uuid,
        event_type: event_type,
        occured_at: audit.created_at,
        user_identifier: audit.user.login,
        subjects: subjects,
        metadata: metadata
      },
      lims: 'LABWHERE'
    }
  end

  private

  # validation methods
  def check_location_information_exists
    return if audit.blank?
    return if location_barcode.present?

    errors.add(:base, "The location barcode must be present in 'record_data'")
  end

  def check_labware_information_exists
    return if audit.blank?
    return if labware.present?
    return if audit.record_data['barcode'].present?

    errors.add(:base, "Either the labware attribute, or a labware barcode in 'record_data' must be present")
  end

  # helper methods for json building
  def subjects
    [
      labware_subject, location_subject
    ].compact
  end

  def labware_subject
    {
      role_type: 'labware',
      subject_type: 'labware',
      friendly_name: labware_barcode,
      uuid: labware_uuid
    }
  end

  def location_subject
    return unless location.present?

    {
      role_type: 'location',
      subject_type: 'location',
      friendly_name: location.barcode,
      uuid: location.uuid
    }
  end

  def metadata
    {
      location_coordinate: coordinate.try(:position),
      location_info: location_info
    }
  end
end
