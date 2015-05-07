class User < ActiveRecord::Base

  include HasActive

  belongs_to :team

  validates_presence_of :login, :swipe_card, :barcode

  validates_uniqueness_of :login

  validates :team, existence: true

  #TODO: Improve the way this is done. You can't use subclasses due to eager loading. This is fine in production but not in development.
  def self.types
    %w(Standard Admin)
  end

end
