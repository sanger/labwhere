module Auditing

  extend ActiveSupport::Concern

  included do 
    _model = self.to_s.deconstantize.singularize

    define_method :model do 
      _model.constantize
    end

    define_method :key do
      _model.foreign_key.to_sym
    end

    before_action :audits, only: [:index]
    helper_method :audits
  end

  def index
  end

protected

  def audits
    @audits = model.find(params[key]).audits
  end

end