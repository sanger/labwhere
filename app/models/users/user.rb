# frozen_string_literal: true

##
# Base user
# Used for auditing, authentication and authorisation purposes.
# Inherited by Administrator, Technician, Scientist and Guest.
require 'digest/sha1'

class User < ActiveRecord::Base
  include HasActive
  include Auditable
  include SubclassChecker

  belongs_to :team, optional: true

  validates :login, presence: true, uniqueness: true

  validates :team, existence: true

  validates_uniqueness_of :swipe_card_id, :barcode, allow_blank: true, allow_nil: true

  validates_with EitherOrValidator, fields: [:swipe_card_id, :barcode], on: :create

  has_subclasses :administrator, :technician, :scientist, :guest

  before_create :encrypt_swipe_card_id

  before_update :check_password_fields

  ##
  # A list of the different types of inherited user.
  def self.types
    %w(Scientist Technician Administrator)
  end

  ##
  # Is the user allowed to perform this action.
  # Will always be no for a base user
  def allow?(_controller, _action)
    false
  end

  ##
  # Find a user by their swipe card id, barcode, or login
  def self.find_by_code(code)
    return Guest.new if code.blank?

    encrypted_code = Digest::SHA1.hexdigest(code)

    where("swipe_card_id = :encrypted_code OR barcode = :code OR login = :code", { code: code, encrypted_code: encrypted_code }).take || Guest.new
  end

  ##
  # Make sure that the swipe card id and barcode are not added to the audit record for security reasons.
  def as_json(options = {})
    super({ except: [:swipe_card_id, :barcode, :deactivated_at, :team_id] }.merge(options)).merge(uk_dates).merge("team" => team.name)
  end

  private

  def encrypt_swipe_card_id
    return if swipe_card_id.blank? || swipe_card_id == "Guest" # check for guests or blank

    self.swipe_card_id = Digest::SHA1.hexdigest(swipe_card_id)
  end

  def check_password_fields
    # rubocop:todo Lint/AmbiguousBlockAssociation
    remove_password_fields [:swipe_card_id, :barcode].reject { |attr| self[attr].present? }
    # rubocop:enable Lint/AmbiguousBlockAssociation
  end

  def remove_password_fields(attrs)
    restore_attributes(attrs) unless attrs.empty?
  end
end
