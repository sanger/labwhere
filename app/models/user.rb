class User < ActiveRecord::Base

  include HasActive
  include AddAudit

  belongs_to :team
  has_many :audits, as: :auditable

  validates_presence_of :login

  validates_uniqueness_of :login, :swipe_card_id, :barcode

  validates :team, existence: true

  def self.types
    %w(Standard Admin)
  end

  def guest?
    type == "Guest"
  end

  def allow?(controller, action)
    false
  end

  def self.find_by_code(code)
    where("swipe_card_id = :code OR barcode = :code", { code: code}).take || Guest.new
  end

end
