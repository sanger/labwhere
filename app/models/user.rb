##
# Base user
# Used for auditing, authentication and authorisation purposes.
# Inherited by Guest, Admin and Standard.
class User < ActiveRecord::Base

  include HasActive
  include AddAudit

  belongs_to :team
  has_many :audits, as: :auditable

  validates :login, presence: true, uniqueness: true

  validates :team, existence: true

  validates_uniqueness_of :swipe_card_id, :barcode, allow_blank: true, allow_nil: true

  ##
  # A list of the different types of inherited user.
  def self.types
    %w(Standard Admin)
  end

  ##
  # Is the user a guest i.e. a user that doesn't exist.
  def guest?
    type == "Guest"
  end

  ##
  # Is the user allowed to perform this action.
  # Will always be no for a base user
  def allow?(controller, action)
    false
  end

  ##
  # Find a user by their swipe card id or barcode
  def self.find_by_code(code)
    where("swipe_card_id = :code OR barcode = :code", { code: code}).take || Guest.new
  end

end
