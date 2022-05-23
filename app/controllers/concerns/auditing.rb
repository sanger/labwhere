# frozen_string_literal: true

##
# This concern can be added into any sub-controller which handles audits.
# It will infer the name of the model from the controller name and create the respective find method.
module Auditing
  extend ActiveSupport::Concern

  included do
    # called it modell cos I can't call it model
    modell = to_s.deconstantize.singularize

    define_method :model do
      modell.constantize
    end

    define_method :key do
      modell.foreign_key.to_sym
    end

    before_action :audits, only: [:index]
    helper_method :audits
  end

  ##
  # Audits should only implement the index action as they are system created.
  def index; end

  protected

  ##
  # Get a list of audits for the model.
  def audits
    @audits ||= model.find(params[key]).audits if params[key]
  end
end
