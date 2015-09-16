##
# Base user
# Used for auditing, authentication and authorisation purposes.
# Inherited by Guest, Admin and Standard.
class User < ActiveRecord::Base

  include HasActive
  include Auditable
  include SubclassChecker

  belongs_to :team

  validates :login, presence: true, uniqueness: true

  validates :team, existence: true

  validates_uniqueness_of :swipe_card_id, :barcode, allow_blank: true, allow_nil: true

  validates_with EitherOrValidator, fields: [:swipe_card_id, :barcode]

  has_subclasses :administrator, :scientist, :guest

  ##
  # A list of the different types of inherited user.
  def self.types
    %w(Scientist Administrator)
  end

  ##
  # Is the user a guest i.e. a user that doesn't exist.
  # def guest?
  #   type == "Guest"
  # end

  ##
  # Is the user allowed to perform this action.
  # Will always be no for a base user
  def allow?(controller, action)
    false
  end

  ##
  # Find a user by their swipe card id or barcode
  def self.find_by_code(code)
    return Guest.new if code.blank?
    where("swipe_card_id = :code OR barcode = :code", { code: code}).take || Guest.new
  end

  ##
  # Make sure that the swipe card id and barcode are not added to the audit record for security reasons.
  def as_json(options = {})
    super({ except: [:swipe_card_id, :barcode, :deactivated_at, :team_id]}.merge(options)).merge(uk_dates).merge("team" => team.name)
  end

end
