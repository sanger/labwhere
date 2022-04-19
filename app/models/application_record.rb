# frozen_string_literal: true

# app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def morph
    self.class.descends_from_active_record? ? self : becomes(self.class.superclass)
  end

  class Relation
    include BarcodeUtilities
  end
end
