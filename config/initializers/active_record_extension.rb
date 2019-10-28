# frozen_string_literal: true

module ActiveRecordExtension
  def morph
    self.class.descends_from_active_record? ? self : self.becomes(self.class.superclass)
  end
end

ActiveRecord::Base.include ActiveRecordExtension
