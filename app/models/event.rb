# frozen_string_literal: true

class Event
  include ActiveModel::Model

  attr_accessor :audit
  attr_writer :labware

  validates :audit, presence: true

  validate :check_audit_is_labware_type
  validate :check_location_information_exists
  validate :check_labware_information_exists

  delegate :uuid, to: :audit

  # Are we firing an event for a newly created audit,
  # or re-firing an event for an 'old' audit?
  # It affects how much data we send in the event - whether we expect it to still be relevant
  def for_old_audit?
    @for_old_audit ||= begin
      # The labware record shouldn't be missing,
      # but if it is, treat this as an 'old' audit
      if labware.blank?
        true
      else
        # if this audit is not the latest for this labware,
        # we shouldn't expect current info on the labware to be
        # relevant to the time the audit was created
        audit.id != labware.audits.last.id
      end
    end
  end

  def location
    # may return nil if the location has been deleted since the audit was created
    @location ||= Location.find_by(barcode: location_barcode)
  end

  def location_barcode
    @location_barcode ||= audit.record_data['location']
  end

  # human readable string containing as much information as we have about the location
  def location_info
    return location_barcode if location.blank?
    return "#{location.parentage} - #{location.name}" if location.parentage.present?

    location.name
  end

  def labware
    @labware ||= Labware.find_by(barcode: labware_barcode)
  end

  def labware_barcode
    @labware_barcode ||= audit.record_data['barcode']
  end

  def labware_uuid
    @labware_uuid ||= begin
      if labware.present?
        labware.uuid
      else
        audit.record_data['uuid']
      end
    end
  end

  def coordinate
    @coordinate ||= begin
      unless for_old_audit?
        # if we are firing an event for a newly created audit, we can grab the current coordinate from the labware
        labware.coordinate
      end
      # otherwise, return nil as we're re-firing an old event & don't know the coordinate for the time it occurred
    end
  end

  # hash which will get sent as the event body to the warehouse
  def as_json(*)
    {
      event: {
        uuid: uuid,
        event_type: audit.event_type,
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
  def check_audit_is_labware_type
    return if audit.blank? # validation is neater with this check here
    return if audit.auditable_type == 'Labware'

    errors.add(:base, 'Events can only be created for Audits where the auditable type is Labware')
  end

  def check_location_information_exists
    return if audit.blank? # validation is neater with this check here
    return if location_barcode.present?

    errors.add(:base, "The location barcode must be present in 'record_data'")
  end

  def check_labware_information_exists
    return if audit.blank? # validation is neater with this check here
    return if labware.present?
    return if audit.record_data['barcode'].present?

    errors.add(:base, "Either the labware attribute, or a labware barcode in 'record_data' must be present")
  end

  # helper methods for json building
  def subjects
    [
      labware_subject, location_subject
    ].compact # in case location is nil
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
    return if location.blank?

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
